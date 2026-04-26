import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_mobile/features/auth/domain/models/register_model.dart';
import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/auth_routes.dart';

class RegisterController {
  static const _storage = FlutterSecureStorage();

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
        debugPrint("Token stocké");
        await _storage.write(key: 'auth_token', value: token);
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
