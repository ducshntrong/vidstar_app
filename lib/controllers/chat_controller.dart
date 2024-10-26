import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';

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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Message.fromJson(doc.data() as Map<String, dynamic>);
      }).toList().reversed.toList(); // Đảo ngược danh sách ở đây
    });
  }

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
      'users': FieldValue.arrayUnion([senderId, receiverId]), // Đảm bảo cả hai người dùng đều được lưu
      'senderId': senderId,
      'receiverId': receiverId,
    }, SetOptions(merge: true)); // Sử dụng merge để giữ lại các trường khác

  }

}

