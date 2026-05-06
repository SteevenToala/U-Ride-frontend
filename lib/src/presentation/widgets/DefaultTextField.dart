import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {

  String text;
  String? initialValue;
  Function(String text) onChanged;
  IconData icon;
  EdgeInsetsGeometry margin;
  String? Function(String?)? validator;
  Color backgroundColor;
  TextInputType keyboardType;
  bool obscureText;
  Widget? suffixIcon;

  DefaultTextField({
    required this.text,
    required this.icon,
    required this.onChanged,
    this.margin = const EdgeInsets.symmetric(vertical: 15),
    this.validator,
    this.backgroundColor = Colors.white,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextFormField(
        onChanged: onChanged,
        obscureText: obscureText,
        style: TextStyle(fontSize: 15, color: Colors.white),
        initialValue: initialValue,
        validator: validator,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: text,
          labelStyle: TextStyle(color: Colors.white60, fontSize: 14),
          border: InputBorder.none,
          suffixIcon: suffixIcon,
          prefixIcon: Icon(icon, color: Color(0xFF00B4D8), size: 22),
        ),
      ),
    );
  }
}