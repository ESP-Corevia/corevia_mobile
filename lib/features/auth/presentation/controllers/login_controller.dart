import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/auth_routes.dart';

class LoginController {
  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiService.post(
        AuthRoutes.login(),
        {'email': email, 'password': password},
      );

      final token = res['token'] as String?;
      if (token != null && token.isNotEmpty) {
        debugPrint("Token reçu : $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return true;
      } else {
        debugPrint("Erreur login : token absent");
        return false;
      }
    } catch (e) {
      debugPrint("Erreur login : $e");
      return false;
    }
  }
}
