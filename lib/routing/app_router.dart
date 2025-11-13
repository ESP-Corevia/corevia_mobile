import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_mobile/features/home/presentation/screens/home_screen.dart';
import 'package:corevia_mobile/features/account/presentation/screens/account_screen.dart';
import 'package:corevia_mobile/features/statistics/presentation/screens/statistics_screen.dart';

enum AppRoute { home, scanner, search, stats, account }

class AppRouter {
  static const String home = '/';
  static const String scanner = '/scanner';
  static const String search = '/search';
  static const String stats = '/stats';
  static const String account = '/account';

  static final _storage = const FlutterSecureStorage();
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  // Configuration du routeur
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: home,
    routes: [
      // Route d'accueil
      GoRoute(
        path: home,
        builder: (context, state) => const HomeScreen(),
      ),
      
      // Route des statistiques
      GoRoute(
        path: stats,
        builder: (context, state) => const StatisticsScreen(),
      ),
      
      // Route du compte
      GoRoute(
        path: account,
        builder: (context, state) => const AccountScreen(),
      ),
      
      // Routes supplémentaires (à implémenter plus tard)
      GoRoute(
        path: scanner,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Scanner Screen')),
        ),
      ),
      GoRoute(
        path: search,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Search Screen')),
        ),
      ),
    ],
    redirect: (context, state) async {
      // Vérification de l'authentification si nécessaire
      final token = await _storage.read(key: 'jwt_token');
      debugPrint("AppRouter token: $token");
      
      // Si l'utilisateur n'est pas connecté et essaie d'accéder à une page protégée
      // Rediriger vers la page de connexion
      // if (token == null && state.location != '/login') {
      //   return '/login';
      // }
      
      return null; // Pas de redirection nécessaire
    },
  );
}