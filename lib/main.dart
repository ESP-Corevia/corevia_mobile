import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

void main() async {
  // Assurez-vous que Flutter est initialisé avant de charger le fichier .env
  WidgetsFlutterBinding.ensureInitialized();

  // Chargez le fichier .env
  await dotenv.load(fileName: ".env");

  // Shared preferences pour savoir si l'onboarding a déjà été vu
  // Si non, on affiche le slider dès l'ouverture
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final onboardingNotifier = ValueNotifier<bool>(!onboardingDone);


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
      ],
      child: MyApp(
        onboardingNotifier: onboardingNotifier,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> onboardingNotifier;
  late final GoRouter _router;

  MyApp({
    super.key,
    required this.onboardingNotifier,
  }) : _router = createRouter(onboardingNotifier);

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
