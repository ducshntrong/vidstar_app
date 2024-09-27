import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';

import '../../controllers/profile_controller.dart';

class FollowerScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();
  FollowerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Followers")),
      body: Obx(() {
        if (profileController.followers.isEmpty) {
          return const Center(child: Text("No followers found.",));
        }
        return ListView.builder(
          itemCount: profileController.followers.length,
          itemBuilder: (context, index) {
            var follower = profileController.followers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(follower['profilePhoto'] ?? ''),
              ),
              title: Text(follower['name'] ?? 'Unknown'),
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