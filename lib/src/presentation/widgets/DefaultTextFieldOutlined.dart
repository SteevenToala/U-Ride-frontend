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
      // height: 45, // Removed fixed height to avoid overflow with errors
      margin: margin,
      child: TextFormField(
        controller: controller,
        onChanged: (text) {
          if (onChanged != null) onChanged!(text);
        },
        validator: validator,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          label: Text(
            text,
            style: TextStyle(
              color: Colors.white
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 35, 161, 183),
              width: 2
            )
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 34, 101, 202),
              width: 2
            )
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.red,
              width: 2
            )
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.redAccent,
              width: 2
            )
          ),
          errorStyle: TextStyle(color: Colors.orangeAccent),
          suffixIcon: suffixIcon,
          prefixIcon: Container(
            margin: EdgeInsets.only(top: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                ),
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.white,
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}