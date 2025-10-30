import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_mobile/features/home/presentation/screens/home_screen.dart';

enum AppRoute { home, scanner, search }

class AppRouter {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Route names
  static const String home = '/';
  static const String scanner = '/scanner';
  static const String search = '/search';

  // Generate route based on settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) {
        return FutureBuilder<String?>(
          future: _storage.read(key: 'jwt_token'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final token = snapshot.data;
            debugPrint("AppRouter token: $token");

            // Handle routing based on route name
            switch (settings.name) {
              case home:
                return const HomeScreen();
              case scanner:
                return const Scaffold(body: Center(child: Text('Scanner Screen')));
              case search:
                return const Scaffold(body: Center(child: Text('Search Screen')));
              default:
                return const HomeScreen();
            }
          },
        );
      },
    );
  }
}