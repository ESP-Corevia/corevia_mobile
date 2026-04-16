import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/chat_message.dart';
import '../domain/rag_agent.dart';

class RagChatStorage {
  static const FlutterSecureStorage _secure = FlutterSecureStorage();

  static const _userIdKey = 'rag_user_id';
  static const _historyPrefix = 'rag_user_history:';
  static const _selectedAgentKey = 'rag_selected_agent';
  static const _maxHistoryItems = 50;

  Future<String> getOrCreateUserId() async {
    final existing = (await _secure.read(key: _userIdKey))?.trim();
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4();
    await _secure.write(key: _userIdKey, value: id);
    return id;
  }

  Future<void> resetUserId() async {
    await _secure.delete(key: _userIdKey);
  }

  Future<String> getSelectedAgentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedAgentKey) ?? RagAgents.medecinGeneraliste.id;
  }

  Future<void> setSelectedAgentId(String agentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedAgentKey, agentId);
  }

  String _historyKey(String agentId) => '$_historyPrefix$agentId';

  Future<List<ChatMessage>> loadUserHistory(String agentId) async {
    final raw = (await _secure.read(key: _historyKey(agentId)))?.trim();
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return [];
      final items = decoded['items'];
      if (items is! List) return [];

      final messages = <ChatMessage>[];
      for (final item in items) {
        if (item is! Map) continue;
        final content = (item['content'] ?? '').toString();
        final ts = item['ts'];
        if (content.trim().isEmpty) continue;

        DateTime? timestamp;
        if (ts is int) {
          timestamp = DateTime.fromMillisecondsSinceEpoch(ts);
        } else if (ts is String) {
          final parsed = int.tryParse(ts);
          if (parsed != null) {
            timestamp = DateTime.fromMillisecondsSinceEpoch(parsed);
          }
        }

        messages.add(ChatMessage(
          role: ChatRole.user,
          content: content,
          timestamp: timestamp,
        ));
      }
      return messages;
    } catch (_) {
      return [];
    }
  }

  Future<void> appendUserMessage(String agentId, ChatMessage message) async {
    if (message.role != ChatRole.user) return;
    if (message.content.trim().isEmpty) return;

    final existing = await _readHistoryItems(agentId);
    existing.add({
      'content': message.content,
      'ts': message.timestamp.millisecondsSinceEpoch,
    });

    final trimmed = existing.length > _maxHistoryItems
        ? existing.sublist(existing.length - _maxHistoryItems)
        : existing;

    await _secure.write(
      key: _historyKey(agentId),
      value: jsonEncode({'v': 1, 'items': trimmed}),
    );
  }

  Future<void> clearUserHistory(String agentId) async {
    await _secure.delete(key: _historyKey(agentId));
  }

  Future<void> clearAll() async {
    await _secure.delete(key: _userIdKey);

    try {
      final all = await _secure.readAll();
      for (final key in all.keys) {
        if (key.startsWith(_historyPrefix)) {
          await _secure.delete(key: key);
        }
      }
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedAgentKey);
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> _readHistoryItems(String agentId) async {
    final raw = (await _secure.read(key: _historyKey(agentId)))?.trim();
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return [];
      final items = decoded['items'];
      if (items is! List) return [];

      return items
          .whereType<Map>()
          .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}

