import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final String currentLocation;

  const BottomNavBar({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.home_filled, 'route': '/home'},
      {'icon': Icons.bar_chart, 'route': '/stats'},
      {'icon': Icons.chat_bubble_outline, 'route': '/chat'},
      {'icon': Icons.calendar_today, 'route': '/calendar'},
      {'icon': Icons.person_outline, 'route': '/account'},
    ];

    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: bottomInset > 0 ? bottomInset : 8,
      ),
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isActive = currentLocation == item['route'];
            return Expanded(
              child: GestureDetector(
                onTap: () => context.go(item['route'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isActive 
                        ? const Color(0xFF34C759).withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: isActive 
                              ? const Color(0xFF34C759)
                              : const Color(0xFF8E8E93),
                          size: 24,
                        ),
                        if (isActive) ...[
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34C759),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}