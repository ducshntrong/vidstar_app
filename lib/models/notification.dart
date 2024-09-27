import 'package:timeago/timeago.dart' as timeago;

class Notifications {
  String id; // ID của thông báo
  String profileImage; // URL hoặc đường dẫn đến ảnh hồ sơ
  String username; // Tên người dùng gửi thông báo
  String content; // Nội dung thông báo
  DateTime date; // Thời gian thông báo được tạo
  String recipientId; // ID của người nhận thông báo
  String videoId; // ID của video liên quan đến thông báo
  bool isRead; // Kiểm tra xem thông báo đã được xem hay chưa
  String type; // Loại thông báo (like, comment, follow)
  String senderId; // ID của người gửi thông báo

  Notifications({
    required this.id, // Thêm ID vào constructor
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
      id: json['id'], // Thêm ID vào từ JSON
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