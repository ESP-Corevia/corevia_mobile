import 'package:flutter/material.dart';
import 'package:corevia_mobile/core/theme/colors.dart';

class InitialsAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 60,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildInitials(),
              loadingBuilder: (_, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildInitials();
              },
            )
          : _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.green[100],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.bold,
          color: AppColors.green,
        ),
      ),
    );
  }
}
