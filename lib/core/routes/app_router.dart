import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Les écrans
import '../../features/calendar/presentation/screens/calendar_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/account/presentation/screens/edit_account_screen.dart';
import '../../features/statistics/presentation/screens/statistics_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/chat/presentation/screens/chat_screen_ai.dart' as ai_chat;
import '../../features/chat/presentation/screens/conversations_list_screen.dart';

// La barre de navigation
import '../../widgets/navigation_bar.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Route pour la page de connexion
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // ShellRoute pour les routes protégées (accessibles après connexion)
    // Route pour la liste des conversations
    GoRoute(
      path: '/conversations',
      builder: (context, state) => const ConversationsListScreen(),
    ),
    // Route pour une conversation spécifique
    GoRoute(
      path: '/chat/ai/:conversationId',
      builder: (context, state) => ai_chat.ChatScreen(
        conversationId: state.pathParameters['conversationId'] ?? 'new',
      ),
    ),
    // ShellRoute pour les écrans avec BottomNavigationBar
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Contenu principal
              child,
              // Barre de navigation positionnée en bas
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BottomNavBar(currentLocation: state.uri.toString()),
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(
          path: '/chat/ai/new',
          builder: (context, state) => const ai_chat.ChatScreen(conversationId: 'new'),
        ),
        GoRoute(
          path: '/chat/ai/:conversationId',
          builder: (context, state) => ai_chat.ChatScreen(
            conversationId: state.pathParameters['conversationId']!,
          ),
        ),
        GoRoute(
          path: '/calendar',
          builder: (context, state) => const CalendarScreen(),
        ),
        GoRoute(
          path: '/account',
          builder: (context, state) => const AccountScreen(),
        ),
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
