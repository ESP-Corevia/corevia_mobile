import 'package:flutter/material.dart';

class AppColors {
  // Couleur principale
  static const MaterialColor green = MaterialColor(
    0xFF008000, // Couleur de base
    <int, Color>{
      50: Color(0xFFE5FCE0),
      100: Color(0xFFCCF9C1),
      200: Color(0xFFB3F6A2),
      300: Color(0xFF99F383),
      400: Color(0xFF80F064),
      500: Color(0xFF008000),
      600: Color(0xFF006600),
      700: Color(0xFF004D00),
      800: Color(0xFF003300),
      900: Color(0xFF001A00),
    },
  );

  // Autres couleurs
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color red = Colors.red;
  static const Color transparent = Colors.transparent;
}
