import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final String currentLocation;

  const BottomNavBar({
    super.key,
    required this.currentLocation,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_filled, 'route': '/home'},
      {'icon': Icons.bar_chart, 'route': '/stats'},
      {'icon': Icons.chat_bubble_outline, 'route': '/chat'},
      {'icon': Icons.calendar_today, 'route': '/calendar'},
      {'icon': Icons.person_outline, 'route': '/profile'},
    ];

    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1F),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: items.map((item) {
            final isActive = currentLocation.startsWith(item['route'] as String);
            return GestureDetector(
              onTap: () => context.go(item['route'] as String),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isActive ? const Color(0xFF34C759) : const Color(0xFF8E8E93),
                      size: 24,
                    ),
                    if (isActive)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34C759),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}