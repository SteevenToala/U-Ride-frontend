import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {

  Function() onPressed;
  String text;
  Color color;
  Color textColor;
  EdgeInsetsGeometry margin;
  double? width;
  double height;
  IconData? iconData;
  Color iconColor;

  DefaultButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.symmetric(vertical: 15),
    this.height = 45,
    this.width,
    this.iconData,
    this.iconColor = Colors.blueAccent
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: color == Colors.white 
          ? LinearGradient(
              colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
        color: color != Colors.white ? color : null,
        boxShadow: [
          BoxShadow(
            color: (color == Colors.white ? Color(0xFF00B4D8) : color).withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconData != null) ...[
              Icon(iconData, color: Colors.white, size: 24),
              SizedBox(width: 10),
            ],
            Text(
              text,
              style: TextStyle(
                color: color == Colors.white ? Colors.white : textColor,
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