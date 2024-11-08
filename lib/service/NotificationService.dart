import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../constants.dart';
import '../models/notification.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class NotificationService {
  final FirebaseFirestore firestore;

  NotificationService(this.firestore);

  Future<void> createNotification(Notifications notification) async {
    // Đảm bảo ID đã dc gán cho notification
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
        // Ktra nội dung thông báo để xóa
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
        'isRead': true,
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

      return notifications;
    });
  }

  // update thông báo
  Future<void> updateNotification(Notifications notification) async {
    try {
      // Cập nhật thông báo dựa trên ID
      await firestore.collection('notifications').doc(notification.id).update(notification.toJson());
    } catch (e) {
      print("Error updating notification: $e");
    }
  }

  // Hàm lấy token FCM
  Future<void> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      await firestore.collection('users').doc(authController.user.uid).update({
        'fcmToken': token,
      });
      print('Token FCM được lưu thành công: $token');
    } else {
      print('Không thể lấy token FCM.');
    }
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {

    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    // Close the HTTP client
    client.close();

    // Return the access token
    return credentials.accessToken.data;

  }

  // Hàm gửi thông báo FCM sử dụng API V1
  Future<void> sendNotification(String receiverFcmToken, String message, String senderName) async {
    final String serverKey = await getAccessToken() ;
    final String apiUrl = 'https://fcm.googleapis.com/v1/projects/your-projectid/messages:send'; // Địa chỉ API V1

    final Map<String, dynamic> notificationData = {
      'message': {
        'token': receiverFcmToken,
        'notification': {
          'title': senderName,
          'body': message,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': message,
        },
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey', // Lấy Access Token từ Google Cloud
        },
        body: jsonEncode(notificationData),
      );

      if (response.statusCode != 200) {
        print('Gửi thông báo thất bại: ${response.body}');
      } else {
        print('Thông báo được gửi thành công: ${response.body}');
      }
    } catch (e) {
      print('Đã xảy ra lỗi khi gửi thông báo: $e');
    }
  }
}