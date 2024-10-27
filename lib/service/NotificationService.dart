import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseFirestore firestore;

  NotificationService(this.firestore);

  Future<void> createNotification(Notifications notification) async {
    // Đảm bảo rằng ID đã được gán cho notification
    await firestore.collection('notifications').doc(notification.id).set(notification.toJson());
  }

  Future<void> deleteNotification(String recipientId, String senderId, String type, String content) async {
    try {
      var notificationQuery = await firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: recipientId)
          .where('senderId', isEqualTo: senderId)
          .where('type', isEqualTo: type)
          .get();

      for (var doc in notificationQuery.docs) {
        // Kiểm tra nội dung thông báo để xóa
        if (doc.data()['content'] == content) {
          await doc.reference.delete(); // Xóa thông báo
        }
      }
    } catch (e) {
      print("Error deleting notification: $e");
    }
  }

  Future<List<Notifications>> getNotifications(String recipientId) async {
    List<Notifications> notifications = [];
    try {
      var snapshot = await firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: recipientId)
          .get();

      for (var doc in snapshot.docs) {
        notifications.add(Notifications.fromJson(doc.data() as Map<String, dynamic>));
      }

      // Sắp xếp danh sách thông báo theo thời gian
      notifications.sort((a, b) => b.date.compareTo(a.date)); // Sắp xếp theo thứ tự giảm dần
    } catch (e) {
      print("Error fetching notifications: $e");
    }
    return notifications;
  }

  //đánh dấu một thông báo là đã đọc.
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await firestore.collection('notifications').doc(notificationId).update({
        'isRead': true, // Đánh dấu là đã đọc
      });
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Stream<List<Notifications>> getNotificationsStream(String recipientId) {
    return firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: recipientId)
        .snapshots() //Sd snapshots() để lắng nghe các thay đổi trong bộ sưu tập thông báo.
        .map((snapshot) {
      // Chuyển đổi docs thành danh sách Notifications
      List<Notifications> notifications = snapshot.docs
          .map((doc) => Notifications.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Sắp xếp danh sách thông báo theo thời gian (mới nhất trước)
      notifications.sort((a, b) => b.date.compareTo(a.date));

      return notifications; // Trả về danh sách đã sắp xếp
    });
  }
  // Hàm gửi thông báo FCM
  Future<void> sendPushNotification(String token, String message, String senderId) async {
    final url = 'https://fcm.googleapis.com/fcm/send';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=YOUR_SERVER_KEY', // Thay YOUR_SERVER_KEY bằng server key của bạn
    };

    final body = json.encode({
      'to': token,
      'notification': {
        'title': 'New Message',
        'body': message,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK', // Hành động khi nhấp vào thông báo
      },
      'data': {
        'senderId': senderId,
        // Thêm thông tin bổ sung nếu cần
      },
    });

    await http.post(Uri.parse(url), headers: headers, body: body);
  }
}