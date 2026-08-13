import 'package:flutter/material.dart';
class SmallColorLines extends StatelessWidget {
  const SmallColorLines();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _line(const Color(0xFF9142E7)),
        const SizedBox(width: 4),
        _line(const Color(0xFF7145D2)),
        const SizedBox(width: 4),
        _line(const Color(0xFF5B79DB)),
        const SizedBox(width: 4),
        _line(const Color(0xFF45B5C0)),
      ],
    );
  }

  Widget _line(Color color) {
    return Container(
      width: 16,
      height: 2,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
