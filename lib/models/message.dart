import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String message;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final bool seen;
  final String chatId;

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
      timestamp: DateTime.tryParse(json['timestamp']) ?? DateTime.now(),
      seen: json['seen'] ?? false,
      chatId: json['chatId'] ?? '',
    );
  }
}
