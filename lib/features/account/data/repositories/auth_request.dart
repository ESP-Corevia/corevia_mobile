import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/auth_routes.dart';

class Auth {
  static Future<dynamic> login(String email, String password) {
    return ApiService.post(
      AuthRoutes.login(),
      {
        "email": email,
        "password": password,
      },
    );
  }

  static Future<dynamic> logout() {
    return ApiService.get(
      AuthRoutes.logout()
    );
  }
}