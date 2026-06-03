import 'package:flutter/material.dart';

class AppTheme {
  // ── Role colors ──────────────────────────────────────────────────────────
  static const Color driverColor      = Color(0xFFF97316);  // orange-500
  static const Color driverColorLight = Color(0xFFFB923C);  // orange-400

  static const Color passengerColor      = Color(0xFF8B5CF6);  // violet-500
  static const Color passengerColorLight = Color(0xFFA78BFA);  // violet-400

  // ── Shared accent (auth screens, neutral actions) ────────────────────────
  static const Color accentColor     = Color(0xFF06B6D4);  // cyan-500
  static const Color accentColorDark = Color(0xFF0891B2);  // cyan-600

  // ── Backgrounds ──────────────────────────────────────────────────────────
  static const Color backgroundDark          = Color(0xFF09121E);
  static const Color backgroundDarkSecondary = Color(0xFF111827);
  static const Color backgroundDarkCard      = Color(0xFF162033);
  static const Color cardOverlay             = Color.fromRGBO(255, 255, 255, 0.07);
  static const Color dividerColor            = Color.fromRGBO(255, 255, 255, 0.08);
  static const Color inputFill               = Color.fromRGBO(255, 255, 255, 0.06);
  static const Color borderSubtle            = Color(0xFF1E2A3F);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textMuted = Color(0xFF8BA3BC);
  static const Color textFaint = Color(0xFF4A6278);

  // ── Semantic / Status ────────────────────────────────────────────────────
  static const Color statusScheduledColor = Color(0xFFF59E0B);  // amber — precio y estado "pendiente"
  static const Color statusFinishedColor  = Color(0xFF3B82F6);  // blue  — estado "finalizado/activo"

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF09121E), Color(0xFF111827), Color(0xFF1A2744)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0891B2), Color(0xFF06B6D4)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient passengerGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient driverGradient = LinearGradient(
    colors: [Color(0xFFEA6310), Color(0xFFF97316)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Helpers ───────────────────────────────────────────────────────────────
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
