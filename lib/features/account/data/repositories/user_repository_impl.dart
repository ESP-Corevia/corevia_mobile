import 'package:flutter/foundation.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../networking/api_service.dart';
import '../../../../networking/routes/user_routes.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      final sessionResult = await FlutterBetterAuth.client.getSession();
      final dynamic data = sessionResult.data;
      final dynamic session = data?.session;
      final String? sessionToken =
          (session?.token ?? data?.token)?.toString();
      if (sessionToken != null && sessionToken.isNotEmpty) {
        token = sessionToken;
        await prefs.setString('auth_token', sessionToken);
      }
    }

    return {
      if (token != null && token.isNotEmpty)
        'Cookie': 'better-auth.session_token=$token',
    };
  }

  @override
  Future<User> fetchCurrentUser() async {
    // 1. Recuperer les donnees de session BetterAuth
    final sessionResult = await FlutterBetterAuth.client.getSession();
    final dynamic sessionData = sessionResult.data;
    final dynamic sessionUser = sessionData?.user;

    debugPrint('=== USER REPOSITORY DEBUG ===');
    debugPrint('sessionData: $sessionData');
    debugPrint('sessionUser: $sessionUser');
    if (sessionUser != null) {
      debugPrint('sessionUser.name: ${sessionUser.name}');
      debugPrint('sessionUser.email: ${sessionUser.email}');
      debugPrint('sessionUser.id: ${sessionUser.id}');
      debugPrint('sessionUser.image: ${sessionUser.image}');
    }

    // 2. Tenter de recuperer les donnees completes via l'API /api/me
    Map<String, dynamic>? apiUserData;
    try {
      final headers = await _getAuthHeaders();
      debugPrint('Headers: $headers');
      final meResponse = await ApiService.get(
        UserRoutes.me(),
        headers: headers,
      );
      debugPrint('/api/me response: $meResponse');

      if (meResponse is Map<String, dynamic>) {
        final rawData = meResponse['user'] ?? meResponse;
        debugPrint('/api/me rawData: $rawData');
        if (rawData is Map<String, dynamic>) {
          apiUserData = Map<String, dynamic>.from(rawData);
        }
      }
    } catch (e) {
      debugPrint('UserRepository: /api/me FAILED: $e');
    }

    // 3. Fusionner : API + session BetterAuth
    if (apiUserData != null) {
      if (sessionUser != null) {
        apiUserData['name'] ??= sessionUser.name?.toString();
        apiUserData['email'] ??= sessionUser.email?.toString();
        apiUserData['image'] ??= sessionUser.image?.toString();
        apiUserData['id'] ??= sessionUser.id?.toString();
      }
      debugPrint('Final user data (API): $apiUserData');
      return User.fromJson(apiUserData);
    }

    // 4. Fallback: utiliser uniquement les donnees de session
    if (sessionUser != null) {
      debugPrint('Using fallback session data');
      return User(
        id: sessionUser.id?.toString() ?? '',
        name: sessionUser.name?.toString() ?? '',
        email: sessionUser.email?.toString() ?? '',
        image: sessionUser.image?.toString(),
      );
    }

    debugPrint('No user data found at all!');
    throw Exception('Impossible de recuperer les donnees utilisateur');
  }

  @override
  Future<User> updateUser(String userId, Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    final response = await ApiService.put(
      UserRoutes.update(userId),
      data,
      headers: headers,
    );

    if (response is Map<String, dynamic>) {
      final userData = response['user'] ?? response;
      if (userData is Map<String, dynamic>) {
        return User.fromJson(userData);
      }
    }

    throw Exception('Erreur lors de la mise a jour du profil');
  }
}
