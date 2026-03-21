import 'package:corevia_mobile/networking/api_service.dart';
import 'package:corevia_mobile/networking/routes/user_routes.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/home_data.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeData> getHomeData() async {
    try {
      final sessionResult = await FlutterBetterAuth.client.getSession();
      final dynamic sessionData = sessionResult.data;
      final dynamic sessionUser = sessionData?.user;
      if (sessionUser != null) {
        return HomeData(
          title: 'Bienvenue sur CoreVia',
          description: 'Votre application de gestion CoreVia',
          userName: (sessionUser.name ?? 'Utilisateur').toString(),
          userImage: sessionUser.image?.toString(),
          alertsCount: 0,
          appointmentsThisMonth: 0,
          completedAppointments: 0,
          pendingAppointments: 0,
          medicationAdherenceRate: 0,
        );
      }

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        final sessionResult = await FlutterBetterAuth.client.getSession();
        final dynamic data = sessionResult.data;
        final dynamic session = data?.session;
        final String? sessionToken = (session?.token ?? data?.token)?.toString();
        if (sessionToken != null && sessionToken.isNotEmpty) {
          token = sessionToken;
          await prefs.setString('auth_token', sessionToken);
        }
      }

      final headers = {
        if (token != null && token.isNotEmpty)
          'Cookie': 'better-auth.session_token=$token',
      };

      final meResponse = await ApiService.get(
        UserRoutes.me(),
        headers: headers,
      );
      if (meResponse is! Map<String, dynamic>) {
        throw Exception('Format de reponse invalide');
      }
      final response = {
        'user': meResponse['user'] ?? meResponse,
        'stats': const {},
        'alertsCount': 0,
      };

      final user = _asMap(response['user']);
      final stats = _asMap(response['stats']);

      return HomeData(
        title: 'Bienvenue sur CoreVia',
        description: 'Votre application de gestion CoreVia',
        userName: (user['name'] ?? 'Utilisateur').toString(),
        userImage: user['image']?.toString(),
        alertsCount: _asInt(response['alertsCount']),
        appointmentsThisMonth: _asInt(stats['appointmentsThisMonth']),
        completedAppointments: _asInt(stats['completedAppointments']),
        pendingAppointments: _asInt(stats['pendingAppointments']),
        medicationAdherenceRate: _asInt(stats['medicationAdherenceRate']),
      );
    } catch (_) {
      return const HomeData(
        title: 'Bienvenue sur CoreVia',
        description: 'Votre application de gestion CoreVia',
        userName: 'Georges',
        userImage: 'https://i.pravatar.cc/150?img=32',
        alertsCount: 0,
        appointmentsThisMonth: 0,
        completedAppointments: 0,
        pendingAppointments: 0,
        medicationAdherenceRate: 0,
      );
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return const {};
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
