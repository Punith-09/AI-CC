import 'package:flutter/material.dart';

class SignUpStepHeader extends StatelessWidget {
  static const Color primaryBlue = Color(0xFF2F5BEA);
  final int currentStep;

  const SignUpStepHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B1F2A),
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 14),
      child: LayoutBuilder(builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / 4;
        return Stack(children: [
          Positioned(
            top: 18,
            left: itemWidth / 2,
            right: itemWidth / 2,
            child: Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    height: 2,
                    color: i < currentStep
                        ? primaryBlue
                        : const Color(0xFFD7D9DE),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(child: _node(i)),
            ),
          ),
        ]);
      }),
    );
  }

  Widget _node(int index) {
    final done = index < currentStep;
    final active = index == currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? const Color(0xFF0B1F2A) : Colors.white,
            border: Border.all(
              color: done || active ? Colors.white30 : const Color(0xFFD7D9DE),
              width: 2,
            ),
          ),
          child: done
              ? const Icon(Icons.check, color: Colors.blue, size: 21)
              : Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : const Color(0xFF8A909C),
                  ),
                ),
        ),
        const SizedBox(height: 7),
        Text(
          _label(index),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            height: 1.1,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? const Color(0xFF172033) : const Color(0xFF8A909C),
          ),
        ),
      ],
    );
  }

  String _label(int index) => const [
        'Basic\nInformation',
        'Professional\nProfile',
        'Personal\nDetails',
        'Portfolio',
      ][index];
}
