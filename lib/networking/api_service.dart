import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.0.2:3000';

  static Future<dynamic> get(
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse("$baseUrl$path")
        .replace(queryParameters: params);

    try {
      final res = await http.get(
        uri,
        headers: headers,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('La requête a expiré. Vérifie ta connexion !');
        },
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body);
      } else {
        throw Exception("Erreur GET $path : ${res.statusCode} - ${res.body}");
      }
    } catch (e) {
      throw Exception("Erreur réseau GET : $e");
    }
  }

  static Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
    {Map<String, String>? headers}
  ) async {
     try {
        final res = await http.post(
          Uri.parse("$baseUrl$path"),
          headers: {
            "Content-Type": "application/json",
            ...?headers,
          },
          body: jsonEncode(body),
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('La requête POST a expiré. Vérifie ta connexion !');
          },
        );

        if (res.statusCode >= 200 && res.statusCode < 300) {
          return jsonDecode(res.body);
        } else {
          throw Exception("Erreur POST : ${res.statusCode}");
        }
     } catch (e) {
        throw Exception("Erreur réseau POST : $e");
     }
  }
}
