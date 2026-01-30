import 'package:corevia_mobile/features/auth/domain/models/register_model.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';

class RegisterController {
  Future<bool> register(RegisterModel data) async {
    try {
      final result = await FlutterBetterAuth.client.signUp.email(
        name: "${data.firstName} ${data.lastName}",
        email: data.email,
        password: data.password,
      );

      return result.data != null; // token ou session gérés automatiquement
    } catch (_) {
      return false;
    }
  }
}

