import 'package:corevia_mobile/features/auth/domain/models/login_model.dart';

import '../models/register_model.dart';

abstract class AuthRepository {
  Future<String> login(LoginModel data);
  Future<void> register(RegisterModel data);
}
