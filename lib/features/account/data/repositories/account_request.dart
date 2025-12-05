import '../../../../networking/api_service.dart';

class Account {
  static Future<dynamic> getProfile(String userId) async {
    return await ApiService.get(
      "https://mon-back.com/users/$userId",
    );
  }
}