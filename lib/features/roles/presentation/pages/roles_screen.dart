// import 'package:flutter/material.dart';
// import '../auth/presentation/pages/audience_signup_screen.dart';
// import '../auth/presentation/pages/signup_screen.dart';
// import './widgets/role_card.dart';
//
// class RolesScreen extends StatefulWidget {
//   const RolesScreen({super.key});
//
//   @override
//   State<RolesScreen> createState() => _ChooseRoleScreenState();
// }
//
// class _ChooseRoleScreenState extends State<RolesScreen> {
//   String selectedRole = '';
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF020E18),
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF061A29),
//               Color(0xFF03121D),
//               Color(0xFF020A12),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // ---------------------------------------------------------
//               // TOP BAR
//               // ---------------------------------------------------------
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: const Icon(
//                         Icons.arrow_back_ios_new_rounded,
//                         color: Colors.white70,
//                         size: 17,
//                       ),
//                     ),
//
//                     const Spacer(),
//
//                     const Text(
//                       'Choose Your Role',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w600,
//                         letterSpacing: 0.1,
//                       ),
//                     ),
//
//                     const Spacer(),
//
//                     // Keeps the title perfectly centered.
//                     const SizedBox(width: 17),
//                   ],
//                 ),
//               ),
//
//               // ---------------------------------------------------------
//               // PROGRESS INDICATOR
//               // ---------------------------------------------------------
//               Padding(
//                 padding: const EdgeInsets.only(top: 3),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _progressDot(active: true),
//                     const SizedBox(width: 6),
//                     _progressDot(),
//                     const SizedBox(width: 6),
//                     _progressDot(),
//                   ],
//                 ),
//               ),
//
//               // ---------------------------------------------------------
//               // MAIN CONTENT
//               // ---------------------------------------------------------
//               Expanded(
//                 child: SingleChildScrollView(
//                   physics: const BouncingScrollPhysics(),
//                   padding: EdgeInsets.symmetric(
//                     horizontal: size.width < 360 ? 15 : 18,
//                   ),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 28),
//
//                       // Heading
//                       RichText(
//                         textAlign: TextAlign.center,
//                         text: const TextSpan(
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             height: 1.15,
//                             fontWeight: FontWeight.w700,
//                           ),
//                           children: [
//                             TextSpan(text: 'How will you use the\n'),
//                             TextSpan(
//                               text: 'platform',
//                               style: TextStyle(
//                                 color: Color(0xFF9B6CFF),
//                               ),
//                             ),
//                             TextSpan(text: '?'),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 9),
//
//                       const Text(
//                         'Select the type of account\nthat matches your goal.',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Color(0xFF8B9BA8),
//                           fontSize: 8.5,
//                           height: 1.45,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//
//                       const SizedBox(height: 25),
//
//                       // -------------------------------------------------
//                       // AUDIENCE CARD
//                       // -------------------------------------------------
//                       RoleCard(
//                         icon: Icons.visibility_rounded,
//                         title: "I'M AN AUDIENCE",
//                         bullets: const [
//                           'Browse and discover\noutstanding talent.',
//                           'Network and find creative\ncollaborators.',
//                         ],
//                         iconColor: const Color(0xFFB889FF),
//                         borderColor: const Color(0xFF6846B8),
//                         glowColor: const Color(0xFF7045FF),
//                         selected: selectedRole == 'audience',
//                         onTap: () {
//                           setState(() {
//                             selectedRole = 'audience';
//                           });
//
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                               const AudienceSignUpScreen(),
//                             ),
//                           );
//                         },
//                       ),
//
//                       const SizedBox(height: 10),
//
//                       // -------------------------------------------------
//                       // ARTIST CARD
//                       // -------------------------------------------------
//                       RoleCard(
//                         icon: Icons.auto_awesome_rounded,
//                         title: "I'M AN ARTIST",
//                         bullets: const [
//                           'Showcase your portfolio,\napply to castings.',
//                           'and earn industry\nopportunities.',
//                         ],
//                         iconColor: const Color(0xFF63E8FF),
//                         borderColor: const Color(0xFF087A96),
//                         glowColor: const Color(0xFF00B9E9),
//                         selected: selectedRole == 'artist',
//                         onTap: () {
//                           setState(() {
//                             selectedRole = 'artist';
//                           });
//
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const SignUpWizardPage(),
//                             ),
//                           );
//                         },
//                       ),
//
//                       const SizedBox(height: 25),
//                     ],
//                   ),
//                 ),
//               ),
//
//               // ---------------------------------------------------------
//               // BACK TO LOGIN
//               // ---------------------------------------------------------
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 13),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 40,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     style: OutlinedButton.styleFrom(
//                       backgroundColor: const Color(0xFF062131),
//                       side: const BorderSide(
//                         color: Color(0xFF17475B),
//                         width: 1,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(9),
//                       ),
//                       padding: EdgeInsets.zero,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Container(
//                           width: 24,
//                           height: 24,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: const Color(0xFF123746),
//                             border: Border.all(
//                               color: const Color(0xFF275A6C),
//                               width: 0.8,
//                             ),
//                           ),
//                           child: const Icon(
//                             Icons.arrow_back_rounded,
//                             size: 13,
//                             color: Colors.white70,
//                           ),
//                         ),
//                         const SizedBox(width: 9),
//                         const Text(
//                           'Back to Login',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 9,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _progressDot({bool active = false}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       width: active ? 18 : 5,
//       height: 3,
//       decoration: BoxDecoration(
//         color: active
//             ? const Color(0xFF9B6CFF)
//             : const Color(0xFF304252),
//         borderRadius: BorderRadius.circular(10),
//       ),
//     );
//   }
// }



import 'package:aicc/common/widgets/app_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/pages/audience_signup_screen.dart';
import '../../../auth/presentation/pages/signup_screen.dart';
import '../widgets/role_card.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: double.infinity,
        height: double.infinity,
        child:
        AppBackground(
            child: SafeArea(
              child: Column(
                children: [

                  SizedBox(
                    height: 38,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // IconButton(
                            //     onPressed: (){
                            //       context.pop();
                            //     },
                            //     icon: Icon(
                            //       Icons.arrow_back_ios_new_rounded,
                            //       color: Colors.white70,
                            //       size: 18,
                            //     ),
                            // ),
                            // SizedBox(width: 80),
                            Text(
                              'Choose Your Role',
                              style:
                              GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 17,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF067FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 17,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC267FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 17,
                        height: 3,
                        decoration: BoxDecoration(
                          color: const Color(0xFF9B67FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),

                  // ==============================
                  // CONTENT
                  // ==============================
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 26),

                          // ==========================
                          // TITLE
                          // ==========================
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'How will you use \n the ',
                                  style:  GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 28,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  // TextStyle(
                                  //   color: Colors.white,
                                  //   fontSize: 28,
                                  //   letterSpacing: 2,
                                  //   fontWeight: FontWeight.w700,
                                  // ),
                                ),
                                TextSpan(
                                  text: 'platform?',
                                  style:  GoogleFonts.montserrat(
                                    color: AppColors.purple,
                                    fontSize: 28,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 9),

                           Text(
                            'Select the type of account\nthat matches your goal.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              color: Color(0xFF82939F),
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 27),

                          RoleCard(
                            icon: Icons.visibility_rounded,
                            title: "I'M AN AUDIENCE",
                            bullets: const [
                              'Browse and discover outstanding talent.',
                              'Network and find creative collaborators.',
                            ],
                            iconColor: const Color(0xFFC28BFF),
                            borderColor: const Color(0xFF7145C9),
                            glowColor: const Color(0xFF7B4DFF),
                            selected: selectedRole == 'audience',
                            onTap: () {
                              setState(() {
                                selectedRole = 'audience';
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const AudienceSignUpScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 30),

                          // ==========================
                          // ARTIST
                          // ==========================
                          RoleCard(
                            icon: Icons.auto_awesome_rounded,
                            title: "I'M AN ARTIST",
                            bullets: const [
                              'Showcase your portfolio, apply to castings.',
                              'and earn industry opportunities.',
                            ],
                            iconColor: const Color(0xFF4DE7FF),
                            borderColor: const Color(0xFF087F9C),
                            glowColor: const Color(0xFF00C7F0),
                            selected: selectedRole == 'artist',
                            onTap: () {
                              setState(() {
                                selectedRole = 'artist';
                              });

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpWizardPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),


                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF062331),
                          side: const BorderSide(
                            color: Color(0xFF185064),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: const Color(0xFF103746),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.secondary,
                                  width: 0.7,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white70,
                                size: 12,
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),

      ),
    );
  }
}