import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String userName;
  final String userAvatar;

  const HomeHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.userName,
    required this.userAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(userAvatar),
                child: userAvatar.isEmpty
                    ? const Icon(Icons.person, size: 24)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
