import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/ai_insight_card.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/profile_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1F5A6A),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        title: const Text(
          "Rahul Sharma",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.photo_camera_outlined),
          ),
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(Icons.more_vert),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1F5A6A),
              Color(0xFF123B4A),
              Color(0xFF0B1F2A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const ProfileHeader(),

              const Divider(color: Colors.white10, height: 1),

              Expanded(
                child: ListView(
                  reverse: false,
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                  children: const [
                    Center(
                      child: Chip(
                        backgroundColor: Color(0xFF0B1F2A),
                        label: Text(
                          "TODAY",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),

                    SizedBox(height: 18),

                    MessageBubble(
                      isSender: false,
                      time: "10:32 AM",
                      message:
                          "Hi Rahul here! I just saw your audition clip for the Summer Thriller project. Your energy is exactly what we need.",
                    ),

                    SizedBox(height: 12),

                    MessageBubble(
                      isSender: false,
                      time: "10:33 AM",
                      message:
                          "Could you send over your updated portfolio? Specifically looking for more close-up shots and your recent work in drama.",
                    ),

                    SizedBox(height: 20),

                    MessageBubble(
                      isSender: true,
                      time: "10:45 AM",
                      message:
                          "Hi Mr. Sharma! Thank you so much for the feedback. I'm thrilled to hear you liked the clip!",
                    ),

                    SizedBox(height: 14),

                    MessageBubble(
                      isSender: true,
                      time: "10:46 AM",
                      message:
                          "I've updated my portfolio with the requested drama reels and headshots.",
                    ),

                    SizedBox(height: 20),

                    AIInsightCard(),

                    SizedBox(height: 20),

                    MessageBubble(
                      isSender: false,
                      time: "11:05 AM",
                      message:
                          "Perfect! Reviewing them now. Are you available for a screen test this Friday in Mumbai?",
                    ),

                    SizedBox(height: 12),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        backgroundColor: Color(0xFF123B4A),
                        avatar: Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        label: Text(
                          "New Portfolio Shared",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                  ],
                ),
              ),

              ChatInput(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
