import 'package:flutter/material.dart';
import 'package:indriver_clone_flutter/src/presentation/theme/AppTheme.dart';

class DefaultButton extends StatelessWidget {

  final Function() onPressed;
  final String text;
  final Color color;
  final Color textColor;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double height;
  final IconData? iconData;
  final Color iconColor;

  const DefaultButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.white,
    this.margin = const EdgeInsets.symmetric(vertical: 15),
    this.height = 52,
    this.width,
    this.iconData,
    this.iconColor = Colors.white,
  });

  LinearGradient get _gradient {
    if (color == Colors.white) return AppTheme.accentGradient;
    return AppTheme.buttonGradientForColor(color);
  }

  Color get _glowColor {
    if (color == Colors.white) return AppTheme.accentColor;
    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _gradient,
        boxShadow: [
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.45),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          overlayColor: Colors.white.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[
              Icon(iconData, color: Colors.white, size: 22),
              const SizedBox(width: 10),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
