import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../service/NotificationService.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  // Danh sách tin nhắn trong đoạn chat hiện tại
  final RxList<Message> _messages = RxList<Message>([]);
  List<Message> get messages => _messages;

  // Danh sách người dùng để tìm kiếm
  final Rx<List<User>> _users = Rx<List<User>>([]);
  List<User> get users => _users.value;

  // Tìm kiếm người dùng theo tên hoặc lấy tất cả ngoại trừ người dùng hiện tại
  void searchUsers(String keyword) {
    String lowerCaseTypedUser = keyword.toLowerCase();

    if (keyword.isEmpty) {
      fetchUsers(); // Gọi lại hàm để lấy tất cả người dùng nếu không nhập từ khóa
      return;
    }

    _users.bindStream(
      firestore.collection('users').snapshots().map((QuerySnapshot query) {
        return query.docs
            .where((elem) =>
        elem['name'] != null &&
            elem['name'].toLowerCase().contains(lowerCaseTypedUser) &&
            elem['uid'] != authController.user.uid) // Loại bỏ người dùng hiện tại
            .map((elem) => User.fromSnap(elem))
            .toList();
      }),
    );
  }

  // Lấy tất cả người dùng ngoại trừ người dùng hiện tại
  void fetchUsers() {
    _users.bindStream(
      firestore.collection('users').snapshots().map((snapshot) {
        return snapshot.docs
            .where((doc) => doc['uid'] != authController.user.uid)
            .map((doc) => User.fromSnap(doc))
            .toList();
      }),
    );
  }

  var chats = <Chat>[].obs;
  Future<void> fetchUserChats() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection('chats')
          .where('users', arrayContains: authController.user.uid)
          .get();

      chats.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        chats.add(Chat.fromJson(data));
      }

      // Sắp xếp danh sách chats theo lastTimestamp mới nhất
      chats.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));

      print("Fetched chats: ${chats.length}");
    } catch (e) {
      print("Error fetching chats: $e");
    }
  }

  //lắng nghe các thay đổi trong chats và cập nhật ds chats
  void listenForChats() {
    firestore.collection('chats')
        .where('users', arrayContains: authController.user.uid)
        .snapshots()
        .listen((snapshot) {
      chats.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        chats.add(Chat.fromJson(data));
      }
      chats.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp)); // Sắp xếp lại
      print("Updated chats: ${chats.length}");
    });
  }

  // Lấy tất cả tin nhắn của đoạn chat dựa trên chatId
  Stream<List<Message>> fetchMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  //Cập nhật Trạng thái tin nhắn khi ng Nhận Xem
  Future<void> markMessagesAsSeen(String chatId, String receiverId) async {
    // Lấy danh sách tin nhắn chưa được xem
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('seen', isEqualTo: false)
        .where('receiverId', isEqualTo: receiverId)
        .get();

    // Cập nhật trạng thái tin nhắn thành đã xem
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.update({'seen': true});
    }
    // Cập nhật trường isRead cho chat
    final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
    // Kiểm tra xem có tin nhắn nào chưa được xem không
    final unreadMessagesCount = messagesSnapshot.docs.length;
    // Cập nhật isRead nếu không còn tin nhắn chưa xem
    if (unreadMessagesCount > 0) {
      await chatDoc.update({'isRead': true});
    }
  }

  final NotificationService notificationService;
  ChatController(this.notificationService);
  // Gửi tin nhắn và cập nhật vào Firestore
  Future<void> sendMessage(String chatId, String message, String senderId, String receiverId) async {
    // Gửi tin nhắn
    String messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final newMessage = Message(
      messageId: messageId,
      message: message,
      senderId: senderId,
      receiverId: receiverId,
      timestamp: DateTime.now(),
      chatId: chatId,
    );

    // Lưu tin nhắn vào Firestore
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(newMessage.toJson());

    // Cập nhật thông tin cuộc trò chuyện
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastTimestamp': FieldValue.serverTimestamp(),
      'users': FieldValue.arrayUnion([senderId, receiverId]),
      'senderId': senderId,
      'receiverId': receiverId,
      'lastMessageSenderId': senderId, // Gán ID người gửi tin nhắn cuối
      'isRead': false,
    }, SetOptions(merge: true)); // Sử dụng merge để giữ lại các trường khác

    // Gửi thông báo cho người nhận tin nhắn
    if (senderId != receiverId) {
      DocumentSnapshot userDoc = await firestore.collection('users').doc(senderId).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      await notificationService.createNotification(
        Notifications(
          id: 'Notification_${DateTime.now().millisecondsSinceEpoch}',
          profileImage: userData['profilePhoto'],
          username: userData['name'],
          content: " sent you a message.",
          date: DateTime.now(),
          recipientId: receiverId,
          videoId: '',
          isRead: false,
          type: "message",
          senderId: senderId,
        ),
      );
    }

    // // Gửi thông báo cho người nhận tin nhắn
    // if (senderId != receiverId) {
    //   DocumentSnapshot userDoc = await firestore.collection('users').doc(receiverId).get();
    //   String? fcmToken = userDoc['fcmToken']; // Lấy token FCM của người nhận
    //
    //   if (fcmToken != null) {
    //     await notificationService.sendPushNotification(fcmToken, message, senderId);
    //   }
    // }
  }
}

