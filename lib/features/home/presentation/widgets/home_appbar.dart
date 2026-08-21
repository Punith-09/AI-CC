import "package:aicc/core/routes/app_routes.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:lucide_icons_flutter/lucide_icons.dart";

import "../../../../core/constants/app_colors.dart";

class HomeAppbar extends StatelessWidget{
  const HomeAppbar({super.key});
  @override
  Widget build(BuildContext context) {
    return
      Padding(
          padding: EdgeInsets.symmetric(vertical: 0,horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
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
                      context.push(AppRoutes.messages);
                    },
                    icon: Icon(LucideIcons.mail,size: 26,)
                )
                ,
                SizedBox(width: 25),
                IconButton(
                    onPressed: (){
                      context.push(AppRoutes.activity);
                    },
                    icon:Icon(LucideIcons.bell,size: 26)
                )
              ],
            )
          ],
        ),
      );

  }
}