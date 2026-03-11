import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/auth_routes.dart';

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  static void _log(String method, String url, {int? status, String? body}) {
    if (!kDebugMode) return;
    final statusStr = status != null ? ' → $status' : '';
    debugPrint('[$method]$statusStr $url');
    if (body != null && body.isNotEmpty && body != '{}') debugPrint('  body: $body');
  }

  static Map<String, String> _jsonHeaders([Map<String, String>? extra]) => {
    'Content-Type': 'application/json',
    'Origin': baseUrl,
    ...?extra,
  };

  static Map<String, String> _getHeaders([Map<String, String>? extra]) => {
    'Origin': baseUrl,
    ...?extra,
  };

  // ── Public requests ─────────────────────────────────────────────────────────

  static Future<dynamic> get(
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse("$baseUrl$path").replace(queryParameters: params);
    _log('GET', uri.toString());
    try {
      final res = await http.get(uri, headers: _getHeaders(headers)).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Requête GET expirée'),
      );
      _log('GET', uri.toString(), status: res.statusCode);
      if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body);
      throw Exception("Erreur GET $path : ${res.statusCode} - ${res.body}");
    } catch (e) {
      throw Exception("Erreur réseau GET : $e");
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final url = "$baseUrl$path";
    _log('POST', url, body: jsonEncode(body));
    try {
      final res = await http.post(
        Uri.parse(url),
        headers: _jsonHeaders(headers),
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Requête POST expirée'),
      );
      _log('POST', url, status: res.statusCode, body: res.body);
      if (res.statusCode >= 200 && res.statusCode < 300) return jsonDecode(res.body);
      throw Exception("Erreur POST : ${res.statusCode} ${res.body}");
    } catch (e) {
      throw Exception("Erreur réseau POST : $e");
    }
  }

  // ── Protected requests (auto-injects Bearer token) ─────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';
    if (kDebugMode) {
      debugPrint('  auth token: ${token.isEmpty ? "(empty)" : "${token.substring(0, token.length.clamp(0, 20))}..."}');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<dynamic> authGet(String path, {Map<String, String>? params}) async {
    return get(path, params: params, headers: await _authHeaders());
  }

  static Future<dynamic> authPost(String path, Map<String, dynamic> body) async {
    return post(path, body, headers: await _authHeaders());
  }

  // ── Auth helpers ────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    try {
      await authPost(AuthRoutes.logout(), {});
    } catch (_) {
      // Ignore server errors — always clear local session
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
}
