import 'package:flutter/material.dart';

class SignupTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final bool requiredField;
  final int maxLines;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const SignupTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.requiredField = false,
    this.maxLines = 1,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        validator: validator ??
            (requiredField
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "$label is required";
                    }
                    return null;
                  }
                : null),
        decoration: InputDecoration(
          labelText: requiredField ? "$label *" : label,
          labelStyle: const TextStyle(color: Colors.white70),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFF0B1F2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF2F5BEA),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}