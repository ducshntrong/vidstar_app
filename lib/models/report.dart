import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String id;
  String videoId;
  String videoUrl;
  String userId;
  String reason;
  DateTime date;

  Report({
    required this.id,
    required this.videoId,
    required this.videoUrl,
    required this.userId,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    "id": id, // Thêm id vào JSON
    "videoId": videoId,
    "videoUrl": videoUrl,
    "userId": userId,
    "reason": reason,
    "date": date.toIso8601String(), // Chuyển đổi DateTime thành chuỗi
  };

  static Report fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Report(
      id: snapshot['id'], // Lấy id từ snapshot
      videoId: snapshot['videoId'],
      videoUrl: snapshot['videoUrl'],
      userId: snapshot['userId'],
      reason: snapshot['reason'],
      date: DateTime.parse(snapshot['date']), // Chuyển đổi chuỗi thành DateTime
    );
  }
}