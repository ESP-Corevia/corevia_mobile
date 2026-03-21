import 'package:flutter/material.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController {
  /// Retourne un Map avec les donnees user si login reussi, null sinon
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final client = FlutterBetterAuth.client;
      final result = await client.signIn.email(
        email: email,
        password: password,
      );

      if (result.data != null) {
        final token = result.data!.token;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        final user = result.data!.user;
        return {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'image': user.image,
          'phoneNumber': user.phoneNumber,
        };
      } else {
        debugPrint("Erreur login : ${result.error?.message}");
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
