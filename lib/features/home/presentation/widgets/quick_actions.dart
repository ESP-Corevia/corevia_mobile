import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class QuickActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.blue,
  });
}

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;

  const QuickActions({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: actions
            .map(
              (action) => _QuickActionItem(
                icon: action.icon,
                label: action.label,
                onTap: action.onTap,
                color: action.color,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 64) / 3,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
