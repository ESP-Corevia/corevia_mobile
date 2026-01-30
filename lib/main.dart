import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_better_auth/flutter_better_auth.dart';

void main() async {
  // Assurez-vous que Flutter est initialisé avant de charger le fichier .env
  WidgetsFlutterBinding.ensureInitialized();

  // Chargez le fichier .env
  await dotenv.load(fileName: ".env");
  
  await FlutterBetterAuth.initialize(
    url: '${dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000'}/api/auth',
  );

  // Onboarding
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final onboardingNotifier = ValueNotifier<bool>(!onboardingDone);

  // Auth state
  final authNotifier = ValueNotifier<bool>(false);

  // 🔹 Vérifie la session persistée dès le lancement
  final result = await FlutterBetterAuth.client.getSession();
  authNotifier.value = result.data != null; // true si connecté, false sinon

  // await checkAuth(authNotifier);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(HomeRepositoryImpl()),
        ),
        // Ajoutez d'autres providers ici au besoin
        ChangeNotifierProvider<ValueNotifier<bool>>.value(
          value: onboardingNotifier,
        ),
        ChangeNotifierProvider<ValueNotifier<bool>>.value(
          value: authNotifier,
        ),
      ],
      child: MyApp(
        onboardingNotifier: onboardingNotifier,
        authNotifier: authNotifier,
        initialRoute: '/onboarding',
      ),
    ),
  );
}

// // Vérifie la session BetterAuth
// Future<void> checkAuth(ValueNotifier<bool> authNotifier) async {
//   final result = await FlutterBetterAuth.client.getSession();
//   authNotifier.value = result.data != null;
// }

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> onboardingNotifier;
  final ValueNotifier<bool> authNotifier;
  final String initialRoute;
  late final GoRouter _router;

  MyApp({
    super.key,
    required this.onboardingNotifier,
    required this.authNotifier,
    required this.initialRoute,
  }) : _router = createRouter(onboardingNotifier, authNotifier);

  @override
  Widget build(BuildContext context) {
    return BetterAuthProvider(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'CoreVia Mobile',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
