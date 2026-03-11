import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/auth_routes.dart';

class LoginController {
  static const _storage = FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final res = await ApiService.post(
        AuthRoutes.login(),
        {'email': email, 'password': password},
      );

      final token = res['token'] as String?;
      if (token != null && token.isNotEmpty) {
        debugPrint("Token stocké");
        await _storage.write(key: 'auth_token', value: token);
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
