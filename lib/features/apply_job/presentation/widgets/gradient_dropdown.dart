import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GradientDropdown extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final String? value;
  final ValueChanged<String?>? onChanged;

  const GradientDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.items,
    this.value,
    this.onChanged,
  });

  @override
  State<GradientDropdown> createState() => _GradientDropdownState();
}

class _GradientDropdownState extends State<GradientDropdown> {
  String? selected;

  @override
  void initState() {
    super.initState();
    selected = widget.value ?? widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Row(
          children: [

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Color(0xff20D5FF),
                  Color(0xffCC3EFF),
                ],
              ).createShader(bounds),
              child: Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xff20D5FF),
                Color(0xffCC3EFF),
              ],
            ),
          ),

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(17),
            ),

            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                dropdownColor: AppColors.card,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.greyText,
                  size: 28,
                ),

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),

                items: widget.items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    selected = value;
                  });

                  widget.onChanged?.call(value);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}