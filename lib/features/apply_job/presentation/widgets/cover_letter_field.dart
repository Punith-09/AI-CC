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

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    // Rebuild only when the character count changes.
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final int length = widget.controller.text.length;
    final bool hasText = length > 0;
    final bool isLimitReached = length >= _maxCharacters;

    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary,
          width: 1.2,
        ),
      ),
      child: Stack(
        children: [
          // Text input
          Positioned.fill(
            child: TextField(
              controller: widget.controller,

              // Prevent entering more than 20 characters.
              maxLength: _maxCharacters,

              // Multiline input.
              minLines: null,
              maxLines: null,
              expands: true,

              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,

              // Typed text.
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),

              cursorColor: AppColors.primary,
              cursorWidth: 2,

              decoration: const InputDecoration(
                // IMPORTANT:
                // Force the TextField itself to be black.
                filled: true,
                fillColor: Colors.black,

                // Remove Flutter's default underline/borders.
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,

                // Remove default internal padding.
                contentPadding: EdgeInsets.zero,
                isDense: true,

                // Hint shown when the field is empty.
                hintText:
                "Write a message, Why You're perfect for this role\n"
                    "(20 Characters)",

                hintStyle: TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.4,

                  // DO NOT add backgroundColor here.
                ),

                // Hide Flutter's built-in character counter.
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
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$length / $_maxCharacters',
                    style: TextStyle(
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
