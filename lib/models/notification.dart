import 'package:timeago/timeago.dart' as timeago;

class Notifications {
  String id;
  String profileImage;
  String username;
  String content;
  DateTime date;
  String recipientId;
  String videoId;
  bool isRead;
  String type;
  String senderId;

  Notifications({
    required this.id,
    required this.profileImage,
    required this.username,
    required this.content,
    required this.date,
    required this.recipientId,
    required this.videoId,
    required this.type,
    required this.senderId,
    this.isRead = false, // Mặc định là chưa đọc
  });

  Map<String, dynamic> toJson() => {
    'id': id, // Thêm ID vào JSON
    'profileImage': profileImage,
    'username': username,
    'content': content,
    'date': date.toIso8601String(),
    'recipientId': recipientId,
    'videoId': videoId,
    'isRead': isRead,
    'type': type,
    'senderId': senderId,
  };

  static Notifications fromJson(Map<String, dynamic> json) {
    return Notifications(
      id: json['id'],
      profileImage: json['profileImage'],
      username: json['username'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      recipientId: json['recipientId'],
      videoId: json['videoId'],
      isRead: json['isRead'] ?? false,
      type: json['type'],
      senderId: json['senderId'],
    );
  }

  String get timeAgo => timeago.format(date);
}