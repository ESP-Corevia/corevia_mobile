import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:corevia_mobile/features/auth/domain/models/register_model.dart';
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/auth_routes.dart';

class RegisterController {
  Future<bool> register(RegisterModel data) async {
    try {
      final res = await ApiService.post(
        AuthRoutes.register(),
        {
          'name': '${data.firstName} ${data.lastName}',
          'email': data.email,
          'password': data.password,
        },
      );

      final token = res['token'] as String?;
      if (token != null && token.isNotEmpty) {
        debugPrint("Token reçu : $token");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        return true;
      } else {
        debugPrint("Erreur register : token absent");
        return false;
      }
    } catch (e) {
      debugPrint("Erreur register : $e");
      return false;
    }
  }
}
