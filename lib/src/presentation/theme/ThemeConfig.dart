import 'package:flutter/material.dart';
import 'AppTheme.dart';

class ThemeConfig {
  static final ThemeData appTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppTheme.passengerColor,
    scaffoldBackgroundColor: AppTheme.backgroundDark,
    canvasColor: AppTheme.backgroundDarkSecondary,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppTheme.passengerColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 18,
        letterSpacing: 0.5,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: AppTheme.passengerColor,
      secondary: AppTheme.driverColor,
      tertiary: AppTheme.accentColor,
      surface: AppTheme.backgroundDarkSecondary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppTheme.inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppTheme.accentColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIconColor: AppTheme.accentColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.2,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppTheme.cardOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.dividerColor, width: 1),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    drawerTheme: const DrawerThemeData(
      backgroundColor: AppTheme.backgroundDarkSecondary,
      elevation: 0,
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white54,
      textColor: Colors.white70,
      selectedColor: Colors.white,
    ),

    dividerTheme: const DividerThemeData(
      color: AppTheme.dividerColor,
      thickness: 1,
      space: 1,
    ),

    iconTheme: const IconThemeData(color: Colors.white70),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 15),
      bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
      titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
      labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
    ),
  );
}
