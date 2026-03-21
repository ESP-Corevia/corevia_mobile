import 'package:corevia_mobile/features/auth/domain/models/register_model.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController {
  /// Retourne un Map avec les donnees user si register reussi, null sinon
  Future<Map<String, dynamic>?> register(RegisterModel data) async {
    try {
      final result = await FlutterBetterAuth.client.signUp.email(
        name: "${data.firstName} ${data.lastName}",
        email: data.email,
        password: data.password,
      );

      if (result.data != null) {
        final token = result.data!.token;
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        final user = result.data!.user;
        return {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'image': user.image,
          'phoneNumber': user.phoneNumber,
        };
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
