import 'dart:ui';
import 'package:flutter/material.dart';

// Widget pillShadow
class PillShadow extends StatelessWidget {
  final String assetPath;
  final double widthValue;
  final double heightValue;

  const PillShadow({
    super.key,
    required this.assetPath,
    required this.widthValue,
    required this.heightValue,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ombre (décalée)
        Transform.translate(
          offset: Offset(0, 4), // Décalage Y pour l'ombre
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                assetPath,
                width: widthValue,
                height: heightValue,
                fit: BoxFit.contain,
                color: Colors.black,
              ),
            ),
          ),
        ),

        // Image normale par-dessus
        Image.asset(
          assetPath,
          width: widthValue,
          height: heightValue,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
