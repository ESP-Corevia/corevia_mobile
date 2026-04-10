import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'core/notification/pillbox_notification.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/pillbox/data/repositories/pillbox_repository_impl.dart';
import 'features/pillbox/presentation/providers/medication_search_provider.dart';
import 'features/pillbox/presentation/providers/pillbox_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'core/providers/notifiers.dart';
import 'networking/api_service.dart';
import 'networking/routes/auth_routes.dart';

void main() async {
  // Assurez-vous que Flutter est initialisé avant de charger le fichier .env
  WidgetsFlutterBinding.ensureInitialized();

  // Chargez le fichier .env
  await dotenv.load(fileName: ".env");

  // Initialize timezones and local notifications
  tz_data.initializeTimeZones();
  await initializePillboxNotifications();

  // Onboarding
  final prefs = await SharedPreferences.getInstance();
  bool? hasCompletedOnboarding = prefs.getBool('onboarding_done');

  // 🔥 true = onboarding nécessaire, false = déjà fait
  bool onboardingNeeded =
      (hasCompletedOnboarding == null || hasCompletedOnboarding == false);

  debugPrint('hasCompletedOnboarding: $hasCompletedOnboarding');
  debugPrint('onboardingNeeded: $onboardingNeeded');

  final onboardingNotifier =
      OnboardingNotifier(onboardingNeeded); // ⬅️ Utilise la classe spécifique

  // Auth state
  final authNotifier = AuthNotifier(false); // ⬅️ Utilise la classe spécifique

  // 🔹 Vérifie la session avec le serveur dès le lancement
  const secureStorage = FlutterSecureStorage();
  final token = await secureStorage.read(key: 'auth_token');
  if (token != null && token.isNotEmpty) {
    // Optimistic: assume logged in, then verify with server
    authNotifier.value = true;
    try {
      final session = await ApiService.authGet(AuthRoutes.getSession());
      final valid = session != null && session['session'] != null;
      if (!valid) {
        // Server explicitly says session is invalid → clear token
        await secureStorage.delete(key: 'auth_token');
        authNotifier.value = false;
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('403')) {
        // Token rejected by server → clear it
        await secureStorage.delete(key: 'auth_token');
        authNotifier.value = false;
      }
      // Other errors (network, timeout) → keep token, stay logged in
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(HomeRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (context) => PillboxProvider(PillboxRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              MedicationSearchProvider(PillboxRepositoryImpl()),
        ),
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
