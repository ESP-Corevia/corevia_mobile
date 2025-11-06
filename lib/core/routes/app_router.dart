import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Les écrans
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/account/presentation/screens/edit_account_screen.dart';

//  la navbar
import '../../widgets/navigation_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavBar(
            currentLocation: state.uri.toString(),
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        // Ajoutez d'autres routes ici
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        )
      ],
    ),
    // Routes sans NavBar
    GoRoute(
      path: '/edit-account',
      builder: (context, state) => const EditAccountScreen(), // Écran sans NavBar
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
