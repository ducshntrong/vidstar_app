import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final String lastMessage;
  final Timestamp lastTimestamp;
  final List<String> users;
  final String senderId;
  final String receiverId;
  final String lastMessageSenderId;
  final bool isRead;

  Chat({
    required this.chatId,
    required this.lastMessage,
    required this.lastTimestamp,
    required this.users,
    required this.senderId,
    required this.receiverId,
    required this.lastMessageSenderId,
    this.isRead = false,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'] ?? '',
      lastMessage: json['lastMessage'] ?? '',
      lastTimestamp: json['lastTimestamp'] ?? Timestamp.now(),
      users: List<String>.from(json['users'] ?? []),
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      lastMessageSenderId: json['lastMessageSenderId'] ?? '',
      isRead: json['isRead'] ?? false,
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
      'lastMessageSenderId': lastMessageSenderId,
      'isRead': isRead,
    };
  }
}