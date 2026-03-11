import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'core/providers/notifiers.dart';
import 'networking/api_service.dart';
import 'networking/routes/auth_routes.dart';

void main() async {
  // Assurez-vous que Flutter est initialisé avant de charger le fichier .env
  WidgetsFlutterBinding.ensureInitialized();

  // Chargez le fichier .env
  await dotenv.load(fileName: ".env");

  // Onboarding
  final prefs = await SharedPreferences.getInstance();
  bool? hasCompletedOnboarding = prefs.getBool('onboarding_done');
  
  // 🔥 true = onboarding nécessaire, false = déjà fait
  bool onboardingNeeded = (hasCompletedOnboarding == null || hasCompletedOnboarding == false);
  
  debugPrint('hasCompletedOnboarding: $hasCompletedOnboarding');
  debugPrint('onboardingNeeded: $onboardingNeeded');
  
  final onboardingNotifier = OnboardingNotifier(onboardingNeeded); // ⬅️ Utilise la classe spécifique

  // Auth state
  final authNotifier = AuthNotifier(false); // ⬅️ Utilise la classe spécifique

  // 🔹 Vérifie la session avec le serveur dès le lancement
  final token = prefs.getString('auth_token');
  if (token != null && token.isNotEmpty) {
    // Optimistic: assume logged in, then verify with server
    authNotifier.value = true;
    try {
      final session = await ApiService.authGet(AuthRoutes.getSession());
      final valid = session != null && session['session'] != null;
      if (!valid) {
        // Server explicitly says session is invalid → clear token
        await prefs.remove('auth_token');
        authNotifier.value = false;
      }
    } catch (_) {
      // Network error or server unreachable → keep token, stay logged in
      // The next protected API call will fail with 401 if token is truly invalid
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(HomeRepositoryImpl()),
        ),
        // Ajoutez d'autres providers ici au besoin
        ChangeNotifierProvider<OnboardingNotifier>.value(
          value: onboardingNotifier,
        ),
        ChangeNotifierProvider<AuthNotifier>.value(
          value: authNotifier,
        ),
      ],
      child: MyApp(
        onboardingNotifier: onboardingNotifier,
        authNotifier: authNotifier,
      ),
    ),
  );
}


class MyApp extends StatelessWidget {
  final OnboardingNotifier onboardingNotifier;
  final AuthNotifier authNotifier;
  late final GoRouter _router;

  MyApp({
    super.key,
    required this.onboardingNotifier,
    required this.authNotifier,
  }) : _router = createRouter(onboardingNotifier, authNotifier);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CoreVia Mobile',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
