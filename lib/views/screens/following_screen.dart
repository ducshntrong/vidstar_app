import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';

import '../../controllers/profile_controller.dart';

class FollowingScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Following")),
      body: Obx(() {
        if (profileController.following.isEmpty) {
          return const Center(child: Text("No following found."));
        }
        return ListView.builder(
          itemCount: profileController.following.length,
          itemBuilder: (context, index) {
            var following = profileController.following[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(following['profilePhoto'] ?? ''),
              ),
              title: Text(following['name'] ?? 'Unknown'),
              trailing: ElevatedButton(
                onPressed: () {

                },
                child: Text("View"),
              ),
            );
          },
        );
      }),
    );
  }
}