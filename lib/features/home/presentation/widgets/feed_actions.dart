import 'package:aicc/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'comments_bottom_sheet.dart';

class FeedActions extends StatefulWidget {
  const FeedActions({super.key});

  @override
  State<FeedActions> createState() => _FeedActionsState();
}

class _FeedActionsState extends State<FeedActions> {
  bool liked=false;
  bool saved=false;
  @override
  Widget build(BuildContext context) {
    return
      Container(
        padding: const EdgeInsets.only(left: 16,top: 0,right: 16,bottom: 0),
        child: Row(
          children: [
            IconButton(
                onPressed: (){
                  setState(() {
                    liked=!liked;
                  });
                },
                icon: liked?Icon(
                  Icons.favorite,
                  size: 35,color: Color(0xFF00FFD9),
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00FFC4),
                      blurRadius: 30,
                      offset: Offset.zero,
                    ),
                  ],):
                Icon(
                    Icons.favorite_border,
                    size: 35
                )
            ),


            const SizedBox(width: 18),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: const Color(0xFF102B36),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  builder: (context) {
                    return const CommentsBottomSheet();
                  },
                );
              },
              icon: const Icon(
                LucideIcons.messageCircle,
                size: 28,
              ),
            ),


            const SizedBox(width: 18),

            const Icon(
              LucideIcons.send,
              size: 28,
            ),

            const Spacer(),

            IconButton(
                onPressed: (){
                  setState(() {
                    saved=!saved;
                  });
                },
                icon: saved?Icon(Icons.bookmark, size: 35 ):Icon(Icons.bookmark_border, size: 35)
            ),
          ],
        ) ,
      );
  }
}