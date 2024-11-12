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
        appBar: AppBar(
          backgroundColor: Colors.black87,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Container(
              color: Colors.white10,
              child: TabBar(
                tabs: [
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none_outlined, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Notifications', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/msg.png',
                          height: 25,
                          width: 25,
                        ),
                        const SizedBox(width: 8),
                        const Text('Messages', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF4778FD),
                indicatorWeight: 1.0,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
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




