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

    return Padding(
      padding: EdgeInsets.only(bottom: 6 + bottomInset),
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1F),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: items.map((item) {
            final route = item['route'] as String;
            final isActive = currentLocation.startsWith(route);

            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () => context.go(route),
                child: SizedBox(
                  height: double.infinity,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF4B504B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            color: isActive ? Colors.white : const Color(0xFF8E8E93),
                            size: 24,
                          ),
                          if (isActive) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 16,
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34C759),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ],
                      ),
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
