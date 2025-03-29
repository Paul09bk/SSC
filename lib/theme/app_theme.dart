import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs principales
  static const Color primaryColor = Color(0xFF3D5AFE); // Bleu vif
  static const Color accentColor = Color(0xFFFFD600);  // Jaune
  static const Color backgroundColor = Color(0xFF121212); // Fond sombre
  static const Color cardColor = Color(0xFF1E1E1E); // Carte sombre
  static const Color successColor = Color(0xFF4CAF50); // Vert
  static const Color errorColor = Color(0xFFF44336); // Rouge

  // Thème sombre
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      surface: cardColor,
      error: errorColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
      displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
      displaySmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    ),
  );
}