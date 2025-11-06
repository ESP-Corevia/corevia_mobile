import 'package:flutter/material.dart';

class ProMemberBadge extends StatelessWidget {
  const ProMemberBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: 16,
          ),
          SizedBox(width: 4),
          Text(
            'Pro member',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}