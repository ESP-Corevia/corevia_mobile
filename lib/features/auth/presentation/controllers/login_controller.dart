import 'package:flutter/material.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  Future<bool> login(String email, String password) async {
    try {
      final client = FlutterBetterAuth.client;
      final result = await client.signIn.email(
        email: email,
        password: password,
      );

      if (result.data != null) {
        // token et session gérés automatiquement par le client
        debugPrint("Token reçu : ${result.data?.token}");
        final token = result.data!.token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return true;
      } else {
        debugPrint("Erreur login : ${result.error?.message}");
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}

