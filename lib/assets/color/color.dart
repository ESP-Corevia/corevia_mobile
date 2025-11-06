
import 'package:flutter/material.dart';

class AppColors {
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
      }
  );// our shade50
  static const Color secondary = Color(0xFFFF0000); // Rouge
  static const Color background = Color(0xFFFFFFFF); // Blanc
  static const Color textPrimary = Color(0xFF000000); // Noir
  static const Color textSecondary = Color(0xFF888888); // Gris
}
