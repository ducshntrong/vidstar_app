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
    this.fillColor = const Color(0xFF1E1E1E), // Nền mặc định màu tối
    this.textColor = Colors.white, // Màu chữ mặc định là trắng
    this.iconColor = Colors.white, // Màu icon mặc định là trắng
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(
        color: textColor, // Màu chữ của input
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 18,
          color: Colors.grey[400], // Màu nhạt khi không focus
        ),
        prefixIcon: Icon(
          icon,
          color: iconColor, // Màu icon
        ),
        filled: true,
        fillColor: fillColor, // Nền input
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[700]!, // Màu đường viền khi không focus
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.redAccent, // Màu đường viền khi focus
            width: 2,
          ),
        ),
      ),
      obscureText: isObscure,
    );
  }
}

