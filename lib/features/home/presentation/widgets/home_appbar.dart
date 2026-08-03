import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../core/constants/app_colors.dart";

class HomeAppbar extends StatelessWidget{
  const HomeAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsetsGeometry.all(5),
          decoration: BoxDecoration(
            color:AppColors.white ,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 2.0),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon( LucideIcons.clapperboard,
              size: 24,color: AppColors.black),
        ),
        Row(
          children: [
            IconButton(
                onPressed: (){
                  context.go("/creatorProfile");
                  },
                icon: Icon(LucideIcons.mail,size: 26,)
            )
            ,
            SizedBox(width: 35),
            IconButton(
                onPressed: (){
                  context.go('/activity');
                  },
                icon:Icon(LucideIcons.bell,size: 26)
            )
          ],
        )
      ],
    );
  }
}