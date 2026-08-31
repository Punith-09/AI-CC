// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:lucide_icons_flutter/lucide_icons.dart';
// import '../../../../common/widgets/app_background.dart';
// import '../../../../core/constants/app_colors.dart';
// import '../../../../core/routes/app_routes.dart';
// import '../widgets/action_button.dart';
// import '../widgets/footer_decoration.dart';
// import '../widgets/logo_widget.dart';
// import '../widgets/small_color_lines.dart';
// import '../widgets/section_title.dart';
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//
//     SystemChrome.setSystemUIOverlayStyle(
//       const SystemUiOverlayStyle(
//         statusBarColor: Color(0xFF0A3040),
//         statusBarIconBrightness: Brightness.light,
//         systemNavigationBarColor: Color(0xFF061B24),
//         systemNavigationBarIconBrightness: Brightness.light,
//       ),
//     );
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF061B24),
//       body: AppBackground(
//         child: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final height = constraints.maxHeight;
//
//               return SingleChildScrollView(
//                 physics: const NeverScrollableScrollPhysics(),
//                 child: SizedBox(
//                   height: height,
//                   child: Column(
//                     children: [
//                       SizedBox(height: height * 0.075),
//
//                       const LogoWidget()
//                           .animate()
//                           .fade(duration: 1200.ms)
//                           .scale(
//                             begin: const Offset(.82, .82),
//                             end: const Offset(1, 1),
//                             duration: 1000.ms,
//                             curve: Curves.easeOutBack,
//                           ),
//
//                       SizedBox(height: height * 0.045),
//
//                       Text(
//                         'AICC',
//                         style: GoogleFonts.alfaSlabOne(
//                           fontSize: 57,
//                           height: .95,
//                           color: Colors.white,
//                           letterSpacing: 3.0,
//                         ),
//                       )
//                           .animate(delay: 200.ms)
//                           .fade(duration: 800.ms)
//                           .slideY(
//                             begin: .25,
//                             end: 0,
//                             curve: Curves.easeOut,
//                           ),
//
//                       SizedBox(height: height * 0.025),
//
//                       const SectionTitle()
//                           .animate(delay: 350.ms)
//                           .fade(duration: 800.ms)
//                           .slideY(
//                             begin: .2,
//                             end: 0,
//                             curve: Curves.easeOut,
//                           ),
//
//                       const SizedBox(height: 10),
//
//
//                       const SmallColorLines()
//                           .animate(delay: 450.ms)
//                           .fade(duration: 700.ms),
//
//                       const SizedBox(height: 17),
//
//
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 55),
//                         child: Text(
//                           "Connecting India's top talent with\n"
//                           "visionary casting directors.",
//                           textAlign: TextAlign.center,
//                           style: GoogleFonts.montserrat(
//                             color: const Color(0xFFA9B2B8),
//                             fontSize: 16.5,
//                             height: 1.55,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       )
//                           .animate(delay: 550.ms)
//                           .fade(duration: 900.ms)
//                           .slideY(
//                             begin: .2,
//                             end: 0,
//                             curve: Curves.easeOut,
//                           ),
//
//                       const Spacer(),
//
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(39, 0, 39, 0),
//                         child: Column(
//                           children: [
//
//                             ActionButton(
//                               title: 'Login',
//                               icon: LucideIcons.userRound,
//                               gradient: const LinearGradient(
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                                 colors: AppColors.authBtnGradient
//                               ),
//                               borderColor: const Color(0xFFB15AFF),
//                               glowColor: Color(0x889B3FE4),
//                               onTap: () {
//                                 context.push(AppRoutes.login);
//                               },
//                             )
//                                 .animate(delay: 800.ms)
//                                 .fade(duration: 700.ms)
//                                 .slideY(
//                                   begin: .4,
//                                   end: 0,
//                                   curve: Curves.easeOutCubic,
//                                 ),
//
//                             const SizedBox(height: 20),
//
//
//                             ActionButton(
//                               title: 'Create Account',
//                               icon: LucideIcons.userRoundPlus,
//                               backgroundColor: const Color(0xFF071F2A),
//                               borderColor: const Color(0xFF17647C),
//                               onTap: () {
//                                 context.push(AppRoutes.signup);
//                               },
//                             )
//                                 .animate(delay: 950.ms)
//                                 .fade(duration: 700.ms)
//                                 .slideY(
//                                   begin: .4,
//                                   end: 0,
//                                   curve: Curves.easeOutCubic,
//                                 ),
//
//                             const SizedBox(height: 34),
//
//                             const FooterDecoration()
//                                 .animate(delay: 1100.ms)
//                                 .fade(duration: 700.ms),
//
//                             const SizedBox(height: 12),
//
//
//                             Text(
//                               "By continuing, you agree to AICC's",
//                               textAlign: TextAlign.center,
//                               style: GoogleFonts.montserrat(
//                                 color: const Color(0xFF89969D),
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//
//                             const SizedBox(height: 7),
//
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   'Terms of Service',
//                                   style: GoogleFonts.montserrat(
//                                     color: const Color(0xFF8750DB),
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   'and',
//                                   style: GoogleFonts.montserrat(
//                                     color: const Color(0xFF89969D),
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   'Privacy Policy',
//                                   style: GoogleFonts.montserrat(
//                                     color: const Color(0xFF8750DB),
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//
//                             const SizedBox(height: 32),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../common/widgets/app_background.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/action_button.dart';
import '../widgets/footer_decoration.dart';
import '../widgets/logo_widget.dart';
import '../widgets/small_color_lines.dart';
import '../widgets/section_title.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0A3040),
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF061B24),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF061B24),
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              final horizontalPadding = (width * 0.108).clamp(32.0, 55.0);

              final descriptionPadding = (width * 0.13).clamp(40.0, 60.0);

              final titleSize = (width * 0.158).clamp(42.0, 57.0);

              return Column(
                children: [

                  SizedBox(height: (height * 0.075).clamp(40.0, 60.0)),

                  const LogoWidget(),

                  SizedBox(height: (height * 0.045).clamp(25.0, 38.0)),

                  Text(
                        'AICC',
                        style: GoogleFonts.alfaSlabOne(
                          fontSize: titleSize,
                          height: .95,
                          color: Colors.white,
                          letterSpacing: 3.0,
                        ),
                      )
                      .animate(delay: 200.ms)
                      .fade(duration: 800.ms)
                      .slideY(begin: .25, end: 0, curve: Curves.easeOut),

                  SizedBox(height: (height * 0.025).clamp(14.0, 22.0)),


                  const SectionTitle()
                      .animate(delay: 350.ms)
                      .fade(duration: 800.ms)
                      .slideY(begin: .2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 8),

                  const SmallColorLines()
                      .animate(delay: 450.ms)
                      .fade(duration: 700.ms),

                  const SizedBox(height: 15),

                  Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: descriptionPadding,
                        ),
                        child: Text(
                          "Connecting India's top talent with\n"
                          "visionary casting directors.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFFA9B2B8),
                            fontSize: 16,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      )
                      .animate(delay: 550.ms)
                      .fade(duration: 900.ms)
                      .slideY(begin: .2, end: 0, curve: Curves.easeOut),


                  const Spacer(),

                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: Column(
                      children: [

                        SizedBox(
                              height: 60,
                              width: width * 0.65,
                              child: ActionButton(
                                title: 'Login',
                                icon: LucideIcons.userRound,
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: AppColors.authBtnGradient,
                                ),
                                borderColor: const Color(0xFFB15AFF),
                                glowColor: const Color(0x889B3FE4),
                                onTap: () {
                                  context.push(AppRoutes.login);
                                },
                              ),
                            )
                            .animate(delay: 800.ms)
                            .fade(duration: 700.ms)
                            .slideY(
                              begin: .4,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),

                        const SizedBox(height: 18),


                        SizedBox(
                              height: 60,
                              width: width * 0.65,
                              child: ActionButton(
                                title: 'Create Account',
                                icon: LucideIcons.userRoundPlus,
                                backgroundColor: const Color(0xFF071F2A),
                                borderColor: const Color(0xFF17647C),
                                onTap: () {
                                  context.push(AppRoutes.role);
                                },
                              ),
                            )
                            .animate(delay: 950.ms)
                            .fade(duration: 700.ms)
                            .slideY(
                              begin: .4,
                              end: 0,
                              curve: Curves.easeOutCubic,
                            ),

                        const SizedBox(height: 30),

                        const FooterDecoration()
                            .animate(delay: 1100.ms)
                            .fade(duration: 700.ms),

                        const SizedBox(height: 10),

                        Text(
                          "By continuing, you agree to AICC's",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            color: const Color(0xFF89969D),
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Terms of Service',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF8750DB),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'and',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF89969D),
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Privacy Policy',
                              style: GoogleFonts.montserrat(
                                color: const Color(0xFF8750DB),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
