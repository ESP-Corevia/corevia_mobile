import 'package:corevia_mobile/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  final int currentIndex;

  const NavigationMenu({super.key, required this.currentIndex,});

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Évite de recharger la même page

    Widget page;
    switch (index) {
      case 0:
        page = const HomeScreen();
        break;
      default:
        page = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: [
        const NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
        const NavigationDestination(
            icon: Icon(Iconsax.scanner), label: 'Scanner'),
        const NavigationDestination(
            icon: Icon(Iconsax.search_normal), label: 'Search'),
      ],
    );
  }
}
