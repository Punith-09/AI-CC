import 'package:flutter/material.dart';

class SignupDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;
  final bool requiredField;

  const SignupDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: const Color(0xFF123B4A),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        validator: requiredField
            ? (value) {
          if (value == null || value.isEmpty) {
            return "Please select $label";
          }
          return null;
        }
            : null,
        decoration: InputDecoration(
          labelText: requiredField ? "$label *" : label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF0B1F2A),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.white24,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF2F5BEA),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
        items: items.isEmpty
            ? [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text(''),
                )
              ]
            : items
                .toSet()
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
                .toList(),
        onChanged: onChanged,
      ),
    );
  }
}