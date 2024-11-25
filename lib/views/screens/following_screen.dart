import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';

import '../../constants.dart';
import '../../controllers/profile_controller.dart';
import '../../service/UserService.dart';

class FollowingScreen extends StatelessWidget {
  final ProfileController profileController = Get.find<ProfileController>();

  FollowingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Following")),
      body: Obx(() {
        if (profileController.following.isEmpty) {
          return const Center(child: Text("No following found."));
        }
        return ListView.builder(
          itemCount: profileController.following.length,
          itemBuilder: (context, index) {
            var followingUid = profileController.following[index]['uid'];

            // Tạo một UserStatusService cho từng người theo dõi
            UserService userService = UserService(firestore, followingUid);

            return FutureBuilder<Map<String, dynamic>?>(
              future: userService.getUserData(followingUid),
              builder: (context, userSnapshot) {
                // Kiểm tra trạng thái kết nối
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError) {
                  return const ListTile(
                    title: Text("Error fetching user data"),
                  );
                }

                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return const ListTile(
                    title: Text("User not found"),
                  );
                }

                final userData = userSnapshot.data!;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userData['profilePhoto'] ?? ''),
                  ),
                  title: Text(userData['name'] ?? 'Unknown'),
                  trailing: ElevatedButton(
                    onPressed: () {
                    },
                    child: const Text("View"),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}