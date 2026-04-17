import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'features/account/presentation/providers/user_provider.dart';
import 'features/account/data/repositories/user_repository_impl.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Onboarding
  final prefs = await SharedPreferences.getInstance();
  bool? hasCompletedOnboarding = prefs.getBool('onboarding_done');
  bool onboardingNeeded =
      (hasCompletedOnboarding == null || hasCompletedOnboarding == false);

  debugPrint('hasCompletedOnboarding: $hasCompletedOnboarding');
  debugPrint('onboardingNeeded: $onboardingNeeded');

  final onboardingNotifier = OnboardingNotifier(onboardingNeeded);
  final authNotifier = AuthNotifier(false);

  // Verify session with server
  const secureStorage = FlutterSecureStorage();
  final token = await secureStorage.read(key: 'auth_token');
  if (token != null && token.isNotEmpty) {
    authNotifier.value = true;
    try {
      final session = await ApiService.authGet(AuthRoutes.getSession());
      final valid = session != null && session['session'] != null;
      if (!valid) {
        await secureStorage.delete(key: 'auth_token');
        authNotifier.value = false;
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('401') || msg.contains('403')) {
        await secureStorage.delete(key: 'auth_token');
        authNotifier.value = false;
      }
    }
  }

  // Load user data from cache
  final userProvider = UserProvider(UserRepositoryImpl());
  await userProvider.loadUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(HomeRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => PillboxProvider(PillboxRepositoryImpl()),
        ),
        ChangeNotifierProvider(
          create: (_) => MedicationSearchProvider(PillboxRepositoryImpl()),
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: userProvider,
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
