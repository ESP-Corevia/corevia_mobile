import 'package:corevia_mobile/features/auth/domain/models/login_model.dart';

import '../../../../networking/routes/auth_routes.dart';
import '../../domain/models/register_model.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:corevia_mobile/networking/api_service.dart';


class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> login(LoginModel data) async {
    final res = await ApiService.post(
      AuthRoutes.login(),
      data.toJson(),
    );

    return res['token'] != null ? res['token'] as String : ''; 
  }

  @override
  Future<void> register(RegisterModel data) {
    return ApiService.post(
      AuthRoutes.register(),
      data.toJson(),
    );
  }
}