import "package:flutter/material.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../core/constants/app_colors.dart";

class ExploreAppbar extends StatelessWidget{
  const ExploreAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    return  Row(

      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.all(5),
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
        Text(
          "Explore Talent",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.white,
            fontSize: 22
          ),
        ),

            Icon(LucideIcons.filter,size: 24,),

      ],
    );
  }
}