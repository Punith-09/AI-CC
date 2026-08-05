import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../data/datasource/comments_data.dart';
import '../../data/models/comment_model.dart';

class CommentsBottomSheet extends StatefulWidget {
  const CommentsBottomSheet({super.key});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * .75,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "Comments",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: dummyComments.length,
              itemBuilder: (context, index) {
                final comment = dummyComments[index];

                return ListTile(
                  minVerticalPadding: 12,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(comment.profileImage),
                  ),
                  title: Row(
                    children: [
                      Text(
                        comment.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (comment.isVerified)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: 16,
                            color: Colors.blue,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment.comment),
                      const SizedBox(height: 4),
                      Text(
                        '${comment.time} ',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  trailing: SizedBox(
                    width: 30,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              final updatedLiked = !comment.isLiked;
                              final updatedLikes = updatedLiked
                                  ? comment.likes + 1
                                  : comment.likes - 1;
                              dummyComments[index] = comment.copyWith(
                                isLiked: updatedLiked,
                                likes: updatedLikes,
                              );
                            });
                          },
                          child: Icon(
                            comment.isLiked
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: comment.isLiked
                                ? const Color(0xFF00FFD9)
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${comment.likes}",
                          style: const TextStyle(
                            fontSize: 9,
                            height: 1,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                            Color(0xffCC3EFF)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: TextField(
                          autofocus: true,
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          cursorColor: const Color(0xFF00FFD9),
                          decoration: const InputDecoration(
                            hintText: "Write a comment...",
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, Color(0xffCC3EFF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (_commentController.text.trim().isEmpty) return;

                        setState(() {
                          dummyComments.insert(
                            0,
                            CommentModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              profileImage: 'assets/images/profile5.jpeg',
                              username: 'You',
                              comment: _commentController.text.trim(),
                              time: 'Now',
                              likes: 0,
                              isVerified: false,
                            ),
                          );

                          _commentController.clear();
                        });
                      },
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}