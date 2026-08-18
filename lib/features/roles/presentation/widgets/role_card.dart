// import 'dart:ui';
//
// import 'package:flutter/material.dart';
//
// class RoleCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final List<String> bullets;
//   final Color iconColor;
//   final Color borderColor;
//   final Color glowColor;
//   final bool selected;
//   final VoidCallback onTap;
//
//   const RoleCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.bullets,
//     required this.iconColor,
//     required this.borderColor,
//     required this.glowColor,
//     required this.selected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         width: double.infinity,
//         constraints: const BoxConstraints(
//           minHeight: 92,
//         ),
//         padding: const EdgeInsets.symmetric(
//           horizontal: 11,
//           vertical: 11,
//         ),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(9),
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFF102D42).withOpacity(0.95),
//               const Color(0xFF061D2C).withOpacity(0.96),
//             ],
//           ),
//           border: Border.all(
//             color: selected
//                 ? glowColor.withOpacity(0.9)
//                 : borderColor.withOpacity(0.7),
//             width: selected ? 1.2 : 0.8,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: glowColor.withOpacity(
//                 selected ? 0.30 : 0.13,
//               ),
//               blurRadius: selected ? 14 : 8,
//               spreadRadius: selected ? 1 : 0,
//             ),
//           ],
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // -----------------------------------------------------------
//             // ICON
//             // -----------------------------------------------------------
//             _GlowIcon(
//               icon: icon,
//               color: iconColor,
//               glowColor: glowColor,
//             ),
//
//             const SizedBox(width: 10),
//
//             // -----------------------------------------------------------
//             // TEXT
//             // -----------------------------------------------------------
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 8.5,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 0.15,
//                     ),
//                   ),
//
//                   const SizedBox(height: 7),
//
//                   ...bullets.map(
//                         (text) => Padding(
//                       padding: const EdgeInsets.only(bottom: 4),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(
//                               top: 3.5,
//                               right: 5,
//                             ),
//                             width: 3,
//                             height: 3,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: iconColor,
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               text,
//                               style: const TextStyle(
//                                 color: Color(0xFF91A4B1),
//                                 fontSize: 6.5,
//                                 height: 1.25,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(width: 5),
//
//             // -----------------------------------------------------------
//             // RIGHT ARROW
//             // -----------------------------------------------------------
//             Container(
//               width: 21,
//               height: 21,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF0A2738),
//                 border: Border.all(
//                   color: borderColor.withOpacity(0.8),
//                   width: 0.7,
//                 ),
//               ),
//               child: Icon(
//                 Icons.chevron_right_rounded,
//                 color: iconColor,
//                 size: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _GlowIcon extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final Color glowColor;
//
//   const _GlowIcon({
//     required this.icon,
//     required this.color,
//     required this.glowColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 32,
//       height: 32,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: RadialGradient(
//           colors: [
//             glowColor.withOpacity(0.45),
//             const Color(0xFF082033),
//             const Color(0xFF061622),
//           ],
//           stops: const [0.0, 0.55, 1.0],
//         ),
//         border: Border.all(
//           color: color.withOpacity(0.5),
//           width: 0.8,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: glowColor.withOpacity(0.35),
//             blurRadius: 10,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Center(
//         child: Icon(
//           icon,
//           color: color,
//           size: 18,
//         ),
//       ),
//     );
//   }
// }



import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> bullets;

  final Color iconColor;
  final Color borderColor;
  final Color glowColor;

  final bool selected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.bullets,
    required this.iconColor,
    required this.borderColor,
    required this.glowColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        height: 150,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 9,
        ),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),

          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF123349),
              Color(0xFF082334),
              Color(0xFF061A28),
            ],
          ),

          border: Border.all(
            color: AppColors.white,
            width: 0.8,
          ),

          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(1),
              blurRadius: 10,
              spreadRadius: 2
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center
          ,
          children: [

            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,

                gradient: RadialGradient(
                  colors: [
                    glowColor.withOpacity(0.55),
                    const Color(0xFF092236),
                    const Color(0xFF061824),
                  ],

                ),

                border: Border.all(
                  color: iconColor.withOpacity(0.65),
                  width: 0.8,
                ),

                boxShadow: [
                  BoxShadow(
                    color: glowColor.withOpacity(0.45),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 30),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // First bullet
                  _BulletText(
                    text: bullets[0],
                    color: iconColor,
                  ),

                  const SizedBox(height: 4),

                  // Second bullet
                  _BulletText(
                    text: bullets[1],
                    color: iconColor,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 7),

            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF082638),
                border: Border.all(
                  color: borderColor.withOpacity(0.8),
                  width: 0.7,
                ),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: iconColor,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletText extends StatelessWidget {
  final String text;
  final Color color;

  const _BulletText({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            top: 3,
            right: 5,
          ),
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),

        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF91A2AE),
              fontSize: 10,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}