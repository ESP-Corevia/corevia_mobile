import 'package:flutter/material.dart' hide NavigationBar;
import 'package:corevia_mobile/widgets/navigation_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Welcome to the Home Screen!'),
      ),
      bottomNavigationBar: const NavigationMenu(currentIndex: 0),
    );
  }
}