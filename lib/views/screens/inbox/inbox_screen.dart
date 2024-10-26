import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';
import 'package:vidstar_app/views/screens/video_screen2.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/notification.dart';
import '../../../service/NotificationService.dart';
import 'chatList_screen.dart';
import 'chat_screen.dart';
import 'notification_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Số lượng tab
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Container chứa TabBar
              Container(
                color: Colors.white10,
                child: const TabBar(
                  tabs: [
                    Tab(text: 'Notifications'),
                    Tab(text: 'Messages'),
                  ],
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    NotificationScreen(),
                    ChatListScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


