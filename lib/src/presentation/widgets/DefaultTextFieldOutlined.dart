import 'package:flutter/material.dart';

class DefaultTextFieldOutlined extends StatelessWidget {

  String text;
  Function(String text)? onChanged; // Made optional since we use controller
  IconData icon;
  EdgeInsetsGeometry margin;
  String? Function(String?)? validator;
  bool obscureText;
  Widget? suffixIcon;
  TextEditingController? controller; // Added controller support

  DefaultTextFieldOutlined({
    required this.text,
    required this.icon,
    this.onChanged,
    this.margin = const EdgeInsets.only(top: 50, left: 20, right: 20),
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: TextFormField(
        controller: controller,
        onChanged: (text) {
          if (onChanged != null) onChanged!(text);
        },
        validator: validator,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelText: text,
          labelStyle: TextStyle(color: Colors.white60, fontSize: 14),
          prefixIcon: Icon(icon, color: Color(0xFF00B4D8), size: 22),
          suffixIcon: suffixIcon,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Color(0xFF00B4D8), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white10, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5), width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
          errorStyle: TextStyle(color: Colors.redAccent, fontSize: 11),
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
        ),
      ),
    );
  }
}