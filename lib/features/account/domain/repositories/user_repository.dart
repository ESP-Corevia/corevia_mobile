import '../entities/user.dart';

abstract class UserRepository {
  Future<User> fetchCurrentUser();
  Future<User> updateUser(String userId, Map<String, dynamic> data);
}
