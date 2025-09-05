import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:corevia_mobile/screens/home_screen.dart';

class AppRouter {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

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

            // **Allow Normal Navigation** for valid pages
            switch (settings.name) {
              case '/home':
                return const HomeScreen();
              default:
                return const HomeScreen();
            }
          },
        );
      },
    );
  }
}