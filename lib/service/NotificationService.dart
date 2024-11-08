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
      "type": "service_account",
      "project_id": "tiktok-clone-app-daf34",
      "private_key_id": "6932c292c10cec29a49294493414a6e7d5809b73",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDqLn+bZBuskUhg\n1gleugjlAVK2oLZHmQRy84M1nTc0Af3tQTfXgcLVlz4t7zxO++7kpyLMMZpjXAq4\nuOU6bZhcR2A83IK5CTsp0vVx6jYd7KEEe0I0TO9WdLIbw645Fm3r6QYEPtU8RMNU\nBQwRqgGll4v1Bhcwwf8SvkRTc64zBujWxxjnizzwEapee/NkPEMB4NMsgV/Q/AG+\ngCQClJSpIeERjSfxGzUt6kQdGr2WSBBwTV9SyCSdNqVrF++RgfPHa2CsA9tGk6LK\nHF/g5rIJX6itgFiFSyzGR9DKsOGY6ZKou51xA4KvRv+C49+MMZ+1bQQ3nquxVTJk\nGg8w8D99AgMBAAECggEAOb64BBjyEwIrGwfEPTm55kBGhVaJRAvpEzBVRyPqgBZK\np1WI38j1QmZeNIT0tdQ9MuA8viWwGHaShTzAd4EdTAnkovVL/bUXQ+erUsjqScQ2\n6yw6pbtf3A1/+sUsgZK0jbLC40qcGZWqJZ5t/LATYmIFZqi3ELSRgW1t2zcf+iAt\n7h426MgtyTBliSPhRvrsa2QRmVZvawyA/krv2NXaNLv0bm9fmD5vwG10q9MGTvjZ\nJ+OTK1ZKwjs8SI5rIEh+RhLre3BGxHIiZRfBTLZKd1esAtGrm1w9NLbRJ+HwLTg5\nKytrNo3EZBigh4IZYQEx4wAiWf06gSnqxns0Eqg5sQKBgQD/qOlkrorX1VjMD/Te\nn3hrKe037s+nU1i7TU3x65X55mzf/UmA72wPSaysjstGWFm5naE50ee0kaauxjwL\nmnxYbuvENQt2hkvOEofJO+DsxaiLCZB4gizQx52jp9lUjD4Vg8aLSZEtWJ2TuPY1\nckEkOa0ttS+7g4nVDvV79L3PrQKBgQDqfkU6CdkwxUly38lBc4oRQWlZ7bsF/aYg\nPXOSFoYphHO2JbyEcWCC/UM96cqB4B69hsjp16X0MnwQAl8CpHeCVMbTNe78CEj1\nS5Fdz3TClM0L5fHrdQIlFuXOH9/MpmRQwzkIONUyMVXaHx7+Ad4HZyOzOph3Y+/3\niq3T3bXpEQKBgD9gKesxcW2rj4WWdwcw1PMLw6hX5NX/zUExGp9b3SPDwT2NVklG\nEK2Bf/KOu0lG4Ycn0i25IQ0cBgvRTFU8CJMLfBp5Y8wP4n7FDTAPTeSj4vIEfvHA\no0dmFGfbVf6lfUZsEi25IOnyy60w7qe1GPzX51wrTBfZtbNBMA14UA1JAoGBAIKZ\nGM0eNwxmlGWaJWiChN7fY2Fmecb4YdGK6Bbw3H+6+Qb1NW0+B9ZsX0rYLqTuwbAk\npTk3lYHPrDDuYSQDnVvFA4cWfqd3pcqX77ojlI/ad+ishHPykuM9QXfvYKGF+lDQ\nqa7emD6AI6R7uLMXLyVIWCW1+LxluHxRjEZ3MJ1BAoGBAJ6NoYxWDvZW29TEjdWV\nBM8svYV2sL3gHZfpurU6aqVo2rdd8CwK8sIG1rpYHBqT4elMMb5eru8URBppumbH\nGGRsAA/g9vW0pAgWrUycrPyxqlYOpOigY/eIY31fgwTAMJhdYnv/ICLP5/xFEuWU\nyax+4Y1GtrPIua7ju2qYqoDa\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-z0xwd@tiktok-clone-app-daf34.iam.gserviceaccount.com",
      "client_id": "113920812706969494946",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-z0xwd%40tiktok-clone-app-daf34.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
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
    final String apiUrl = 'https://fcm.googleapis.com/v1/projects/tiktok-clone-app-daf34/messages:send'; // Địa chỉ API V1

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