import 'package:aicc/core/constants/app_colors.dart';
import 'package:aicc/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreatorHeader extends StatelessWidget {
  const CreatorHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child:
      Stack(
        children:
        [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff071A33),
                    Color(0xff112F58),
                    Color(0xff1A2258),
                    Color(0xff08131F),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.45),
                    blurRadius: 120,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: -70,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(.35),
                    blurRadius: 120,
                    spreadRadius: 35,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(.20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),


          Positioned(
            top: 90,
            left: 70,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 150,
            right: 100,
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Colors.purpleAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            top: 210,
            left: 250,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
            ),
          ),


          Positioned(
            top: 60,
            left: 20,
            child: _CircleButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () {
                context.pop();
              },
            ),
          ),


          Positioned(
            top: 60,
            right: 20,
            child: _CircleButton(
              icon: Icons.settings_outlined,
              onTap: () {},
            ),
          ),
        ]
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.35),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}


