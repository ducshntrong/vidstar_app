import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final List<String> users;
  final String senderId;
  final String receiverId;

  Chat({
    required this.chatId,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.users,
    required this.senderId,
    required this.receiverId,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'] as String? ?? '', // Cung cấp giá trị mặc định
      lastMessage: json['lastMessage'] as String? ?? '',
      lastTimestamp: json['lastTimestamp'] as Timestamp? ?? Timestamp.now(), // Hoặc giá trị mặc định khác
      users: List<String>.from(json['users'] as List<dynamic>? ?? []),
      senderId: json['senderId'] as String? ?? '',
      receiverId: json['receiverId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'lastMessage': lastMessage,
      'lastTimestamp': lastTimestamp,
      'users': users,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }
}
