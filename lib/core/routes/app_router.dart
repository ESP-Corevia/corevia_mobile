import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Les écrans
import '../../features/home/presentation/screens/home_screen.dart';

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
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
