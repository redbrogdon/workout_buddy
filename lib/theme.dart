import 'package:flutter/material.dart';

class WorkoutBuddyTheme {
  static const Color planetPurple = Color(0xFF6D2077);
  static const Color planetYellow = Color(0xFFFEB822);
  static const Color darkGrey = Color(0xFF1D1D1D);

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: planetPurple,
        primary: planetPurple,
        secondary: planetYellow,
        surface: Colors.white,
        onSurface: darkGrey,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F0F9),
      appBarTheme: const AppBarTheme(
        backgroundColor: planetPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: planetPurple,
          letterSpacing: -1.0,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.bold,
          color: planetPurple,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkGrey,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: planetYellow,
          foregroundColor: darkGrey,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: planetPurple,
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: planetPurple, width: 2),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: planetPurple,
        brightness: Brightness.dark,
        primary: planetPurple,
        secondary: planetYellow,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkGrey,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
