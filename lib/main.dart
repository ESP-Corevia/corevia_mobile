import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/home/data/repositories/home_repository_impl.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => HomeProvider(HomeRepositoryImpl()),
        ),
        // Ajoutez d'autres providers ici au besoin
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CoreVia Mobile',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
