import 'package:flutter/material.dart';

/// Tema principal de la aplicación Eventos UNACH.
/// Utiliza Material Design 3 con una paleta de colores inspirada
/// en la identidad institucional de la Universidad.
class AppTheme {
  // Colores principales de la app
  static const Color primaryColor = Color.fromRGBO(0, 45, 100, 1);
  static const Color secondaryColor = Color.fromARGB(255, 0, 23, 50);
  static const Color tertiaryColor = Color.fromRGBO(220, 160, 12, 1);
  static const Color surfaceColor = Color(0xFFF5F5F5);
  static const Color errorColor = Color(0xFFB00020);

  /// Esquema de colores claro basado en Material 3
  static ColorScheme get colorScheme => ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(0, 45, 100, 1),
    secondary: const Color.fromARGB(255, 0, 23, 50),
    tertiary: const Color.fromRGBO(220, 160, 12, 1),
    surface: surfaceColor,
    error: errorColor,
    brightness: Brightness.light,
  );

  /// Tema principal de la aplicación
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Roboto',
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
