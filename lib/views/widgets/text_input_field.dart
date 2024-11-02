import 'package:flutter/material.dart';
import 'package:vidstar_app/constants.dart';

class TextInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isObscure;
  final IconData icon;
  final Color fillColor;
  final Color textColor;
  final Color iconColor;

  const TextInputField({
    Key? key,
    required this.controller,
    required this.labelText,
    this.isObscure = false,
    required this.icon,
    this.fillColor = const Color(0xFF1E1E1E),
    this.textColor = Colors.white,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor,
        ),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[700]!,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
      ),
      obscureText: isObscure,
    );
  }
}

