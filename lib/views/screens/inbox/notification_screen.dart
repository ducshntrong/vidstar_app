import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/views/widgets/custom_icon.dart';

import '../../../controllers/auth_controller.dart';
import '../../../models/notification.dart';
import '../../../service/NotificationService.dart';
import '../profile_screen.dart';
import '../video_screen2.dart';

// class NotificationScreen extends StatelessWidget {
//   final NotificationService notificationService = Get.find<NotificationService>();
//
//   NotificationScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final String recipientId = Get.find<AuthController>().user.uid; // Lấy ID người dùng hiện tại
//
//     return FutureBuilder<List<Notifications>>(
//       future: notificationService.getNotifications(recipientId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No notifications'));
//         }
//
//         final notifications = snapshot.data!;
//
//         return ListView.builder(
//           itemCount: notifications.length,
//           itemBuilder: (context, index) {
//             final notificationItem = notifications[index];
//
//             return NotificationTile(
//               notification: notificationItem,
//               onTap: () async {
//                 // Đánh dấu thông báo là đã đọc
//                 await notificationService.markNotificationAsRead(notificationItem.id);
//                 // Cập nhật danh sách thông báo
//                 (context as Element).reassemble(); // Cách tạm thời để cập nhật trạng thái
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService notificationService = Get.find<NotificationService>();

  @override
  Widget build(BuildContext context) {
    final String recipientId = Get.find<AuthController>().user.uid;

    return StreamBuilder<List<Notifications>>(
      stream: notificationService.getNotificationsStream(recipientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        final notifications = snapshot.data!;

        return ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notificationItem = notifications[index];

            return NotificationTile(
              notification: notificationItem,
              onTap: () async {
                await notificationService.markNotificationAsRead(notificationItem.id);
              },
            );
          },
        );
      },
    );
  }
}

class NotificationTile extends StatelessWidget {
  final Notifications notification;
  final VoidCallback onTap;

  const NotificationTile({Key? key, required this.notification, required this.onTap}) : super(key: key);

  void _handleTap(BuildContext context) {
    onTap(); // Gọi hàm onTap khi click vào thông báo

    // Xử lý điều hướng dựa trên loại thông báo
    if (notification.type == 'like' || notification.type == 'comment'
        || notification.type == 'likeComment' || notification.type == 'repost'
        || notification.type == 'reply') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoScreen2(videoId: notification.videoId),
        ),
      );
    } else if (notification.type == 'follow') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(uid: notification.senderId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _handleTap(context),
      child: Container(
        color: notification.isRead ? Colors.transparent : Colors.grey[800],
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(notification.profileImage),
          ),
          title: Row(
            children: [
              Text(
                notification.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Expanded(
                child: Text(
                  notification.content,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          subtitle: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 12), // Biểu tượng thời gian
              const SizedBox(width: 4),
              Text(
                notification.timeAgo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: notification.isRead ? const Icon(Icons.check, color: Colors.green) : null,
        ),
      ),
    );
  }
}