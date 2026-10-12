// import 'package:flutter/material.dart';
//
// import '../../../../core/constants/app_colors.dart';
//
// class CoverLetterField extends StatefulWidget {
//   final TextEditingController controller;
//
//   const CoverLetterField({
//     super.key,
//     required this.controller,
//   });
//
//   @override
//   State<CoverLetterField> createState() => _CoverLetterFieldState();
// }
//
// class _CoverLetterFieldState extends State<CoverLetterField> {
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(_onTextChanged);
//   }
//
//   @override
//   void dispose() {
//     widget.controller.removeListener(_onTextChanged);
//     super.dispose();
//   }
//
//   void _onTextChanged() {
//     setState(() {});
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final length = widget.controller.text.length;
//
//     return Container(
//       width: double.infinity,
//       height: 200,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppColors.primary,
//           width: 1.2,
//         ),
//       ),
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: TextField(
//               controller: widget.controller,
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: Colors.white,
//                 height: 1.4,
//               ),
//               cursorColor: AppColors.primary,
//               decoration: const InputDecoration(
//                 isDense: true,
//                 contentPadding: EdgeInsets.zero,
//                 border: InputBorder.none,
//                 hintText:
//                     "Write a message , Why Your prefect for this role\n( 20 Characters )",
//                 hintStyle: TextStyle(
//                   color: Color(0xFF9E9E9E),
//                   backgroundColor: AppColors.black,
//                   fontSize: 14,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ),
//           if (length > 0)
//             Positioned(
//               right: 0,
//               bottom: 0,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withValues(alpha: 0.8),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   "$length / 20",
//                   style: TextStyle(
//                     color: length >= 20
//                         ? const Color(0xFF10B981)
//                         : AppColors.primary,
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

class CoverLetterField extends StatefulWidget {
  final TextEditingController controller;

  const CoverLetterField({
    super.key,
    required this.controller,
  });

  @override
  State<CoverLetterField> createState() => _CoverLetterFieldState();
}

class _CoverLetterFieldState extends State<CoverLetterField> {
  static const int _maxCharacters = 20;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTextChanged() {
    // Rebuild only when the character count changes.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final int length = widget.controller.text.length;
    final bool hasText = length > 0;
    final bool isLimitReached = length >= _maxCharacters;
    final bool isFocused = _focusNode.hasFocus;

    final bgColor = isDark ? const Color(0xFF141414) : const Color(0xFFF8FAFC);
    final borderColor = isFocused
        ? AppColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0));

    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          // Text input
          Positioned.fill(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,

              // Prevent entering more than 20 characters.
              maxLength: _maxCharacters,

              // Multiline input.
              minLines: null,
              maxLines: null,
              expands: true,

              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,

              // Typed text.
              style: GoogleFonts.poppins(
                color: isDark ? Colors.white : AppColors.lightText,
                fontSize: 14.5,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),

              cursorColor: AppColors.primary,
              cursorWidth: 2,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,

                contentPadding: EdgeInsets.zero,
                isDense: true,

                hintText:
                    "Write a message, Why You're perfect for this role\n"
                    "(20 Characters)",

                hintStyle: GoogleFonts.poppins(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),

                counterText: '',
              ),
            ),
          ),

          // Custom character counter.
          if (hasText)
            Positioned(
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.transparent,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$length / $_maxCharacters',
                    style: GoogleFonts.poppins(
                      color: isLimitReached
                          ? const Color(0xFF10B981)
                          : AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
