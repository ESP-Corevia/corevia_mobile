import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../networking/api_service.dart';
import '../domain/chat_message.dart';

class AiChatService {
  static const _storage = FlutterSecureStorage();

  late final Dio _dio;

  AiChatService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiService.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: Duration.zero,
      headers: {
        'Content-Type': 'application/json',
        'Origin': ApiService.baseUrl,
        if (ApiService.hostHeader != null) 'Host': ApiService.hostHeader!,
      },
    ));

    if (kDebugMode) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) {
          return host == '10.0.2.2' || host.endsWith('.corevia.local');
        };
        return client;
      };
    }
  }

  CancelToken streamChat({
    required List<ChatMessage> messages,
    required void Function(String delta) onDelta,
    required void Function(String error) onError,
    required void Function() onDone,
  }) {
    final cancelToken = CancelToken();

    _doStream(
      messages: messages,
      onDelta: onDelta,
      onError: onError,
      onDone: onDone,
      cancelToken: cancelToken,
    );

    return cancelToken;
  }

  Future<void> _doStream({
    required List<ChatMessage> messages,
    required void Function(String delta) onDelta,
    required void Function(String error) onError,
    required void Function() onDone,
    required CancelToken cancelToken,
  }) async {
    try {
      final token = await _storage.read(key: 'auth_token') ?? '';

      final response = await _dio.post<ResponseBody>(
        '/chat',
        data: {
          'messages': messages
              .where((m) => !m.isError)
              .map((m) => m.toApiMessage())
              .toList(),
        },
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Authorization': 'Bearer $token'},
        ),
        cancelToken: cancelToken,
      );

      final stream = response.data?.stream;
      if (stream == null) {
        onError('Empty response from server');
        onDone();
        return;
      }

      String buffer = '';

      await for (final chunk in stream) {
        if (cancelToken.isCancelled) break;

        buffer += utf8.decode(chunk, allowMalformed: true);

        while (buffer.contains('\n')) {
          final newlineIndex = buffer.indexOf('\n');
          final line = buffer.substring(0, newlineIndex).trim();
          buffer = buffer.substring(newlineIndex + 1);

          if (line.isEmpty) continue;

          _parseLine(line, onDelta: onDelta, onError: onError);
        }
      }

      if (buffer.trim().isNotEmpty) {
        _parseLine(buffer.trim(), onDelta: onDelta, onError: onError);
      }

      onDone();
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        onDone();
        return;
      }
      if (e.response?.statusCode == 401) {
        onError('Session expirée. Veuillez vous reconnecter.');
      } else {
        onError('Erreur réseau : ${e.message ?? "connexion impossible"}');
      }
      onDone();
    } catch (e) {
      onError('Erreur inattendue : $e');
      onDone();
    }
  }

  /// Parse a single line from the SSE stream.
  ///
  /// The backend sends Server-Sent Events with JSON payloads:
  ///   data: {"type":"text-delta","id":"0","delta":"Hello"}
  ///   data: {"type":"error","message":"..."}
  ///   data: {"type":"finish-step",...}
  void _parseLine(
    String line, {
    required void Function(String delta) onDelta,
    required void Function(String error) onError,
  }) {
    if (!line.startsWith('data: ')) return;

    final jsonStr = line.substring(6); // strip "data: "

    try {
      final data = jsonDecode(jsonStr);
      if (data is! Map<String, dynamic>) return;

      switch (data['type']) {
        case 'text-delta':
          final delta = data['delta'] as String?;
          if (delta != null) onDelta(delta);
          break;
        case 'error':
          final msg = data['message'] as String? ?? data.toString();
          onError(msg);
          break;
      }
    } catch (_) {
      // Skip unparseable lines
    }
  }

  void dispose() {
    _dio.close();
  }
}
