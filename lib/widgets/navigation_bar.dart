import 'package:corevia_mobile/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class NavigationMenu extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onItemSelected;

  const NavigationMenu({
    super.key, 
    required this.currentIndex,
    this.onItemSelected,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Avoid reloading the same page
    
    // If there's a custom onItemSelected callback, use it
    if (onItemSelected != null) {
      onItemSelected!(index);
      return;
    }
    
    // Otherwise use default navigation
    String route;
    switch (index) {
      case 0:
        route = AppRouter.home;
        break;
      case 1:
        route = AppRouter.scanner;
        break;
      case 2:
        route = AppRouter.search;
        break;
      default:
        route = AppRouter.home;
    }
    
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onItemTapped(context, index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Iconsax.home), 
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Iconsax.scanner), 
          label: 'Scanner',
        ),
        NavigationDestination(
          icon: Icon(Iconsax.search_normal), 
          label: 'Search',
        ),
      ],
    );
  }
}
