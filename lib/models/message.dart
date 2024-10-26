import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String messageId;
  String message;
  String senderId;
  String receiverId;
  DateTime timestamp;
  bool seen;
  String chatId;

  Message({
    required this.messageId,
    required this.message,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.seen = false,
    required this.chatId,
  });

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'message': message,
    'senderId': senderId,
    'receiverId': receiverId,
    'timestamp': timestamp.toIso8601String(),
    'seen': seen,
    'chatId': chatId,
  };

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['messageId'] ?? '',
      message: json['message'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      seen: json['seen'] ?? false,
      chatId: json['chatId'] ?? '',
    );
  }
}
