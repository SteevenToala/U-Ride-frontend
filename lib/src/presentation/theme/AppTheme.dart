import 'package:flutter/material.dart';

class AppTheme {
  // ── Role colors ─────────────────────────────────────────────
  static const Color driverColor      = Color(0xFFE65100);  // Deep orange
  static const Color driverColorLight = Color(0xFFF57C00);  // Medium orange
  static const Color passengerColor      = Color(0xFF1565C0); // Deep blue
  static const Color passengerColorLight = Color(0xFF1E88E5); // Medium blue

  // ── Shared accent (auth screens, neutral actions) ────────────
  static const Color accentColor     = Color(0xFF00C896); // Teal
  static const Color accentColorDark = Color(0xFF00A37A); // Dark teal

  // ── Backgrounds ──────────────────────────────────────────────
  static const Color backgroundDark          = Color(0xFF09131E);
  static const Color backgroundDarkSecondary = Color(0xFF122035);
  static const Color cardOverlay             = Color.fromRGBO(255, 255, 255, 0.07);
  static const Color dividerColor            = Color.fromRGBO(255, 255, 255, 0.08);
  static const Color inputFill               = Color.fromRGBO(255, 255, 255, 0.06);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF09131E), Color(0xFF122035), Color(0xFF1A3558)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00A37A)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient passengerGradient = LinearGradient(
    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient driverGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFF57C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Helpers ───────────────────────────────────────────────────
  static Color colorForRoleId(String id) =>
      id == 'STUDENT' ? passengerColor : driverColor;

  static Color colorLightForRoleId(String id) =>
      id == 'STUDENT' ? passengerColorLight : driverColorLight;

  static LinearGradient gradientForRoleId(String id) =>
      id == 'STUDENT' ? passengerGradient : driverGradient;

  static LinearGradient buttonGradientForColor(Color color) {
    return LinearGradient(
      colors: [
        HSLColor.fromColor(color).withLightness(
          (HSLColor.fromColor(color).lightness + 0.12).clamp(0.0, 1.0),
        ).toColor(),
        color,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
