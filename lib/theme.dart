import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CeruleanEdgeTheme {
  // Brand Colors
  static const Color background = Color(0xFF0e141b);
  static const Color surface = Color(0xFF0e141b);
  static const Color surfaceVariant = Color(0xFF30353d);

  static const Color primary = Color(0xFFa4e6ff); // Electric Blue
  static const Color onPrimary = Color(0xFF003543);
  static const Color primaryContainer = Color(0xFF00d1ff);
  static const Color onPrimaryContainer = Color(0xFF00566a);

  static const Color secondary = Color(0xFF9ccaff); // Deep Cerulean
  static const Color onSecondary = Color(0xFF003256);
  static const Color secondaryContainer = Color(0xFF005a95);
  static const Color onSecondaryContainer = Color(0xFFa9d1ff);

  static const Color tertiary = Color(0xFFcfddfb); // Navy Slate
  static const Color onTertiary = Color(0xFF233148);
  static const Color tertiaryContainer = Color(0xFFb3c1de);
  static const Color onTertiaryContainer = Color(0xFF414f68);

  static const Color outline = Color(0xFF859399);
  static const Color outlineVariant = Color(0xFF3c494e);

  static const Color onBackground = Color(0xFFdee2ed);
  static const Color onSurface = Color(0xFFdee2ed);
  static const Color onSurfaceVariant = Color(0xFFbbc9cf);

  static ThemeData get dark {
    final baseTextTheme = GoogleFonts.lexendTextTheme(
      ThemeData.dark().textTheme,
    );

    final textTheme = baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 32,
        letterSpacing: -0.01,
        color: onSurface,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: onSurface,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: onSurface,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: onSurface,
      ),
      bodySmall: baseTextTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: onSurfaceVariant,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.05,
        color: onSurface,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        elevation: 0,
      ),
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: const Color(
          0xFF1b2028,
        ).withValues(alpha: 0.6), // Translucent surface container
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary,
          foregroundColor: onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}
