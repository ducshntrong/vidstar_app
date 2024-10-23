import 'package:cloud_firestore/cloud_firestore.dart';

class Video {
  String username;
  String uid;
  String id;
  List likes;
  List reposts;
  int commentCount;
  int shareCount;
  String songName;
  String caption;
  String videoUrl;
  String thumbnail;
  String profilePhoto;
  DateTime date;

  Video({
    required this.username,
    required this.uid,
    required this.id,
    required this.likes,
    required this.reposts,
    required this.commentCount,
    required this.shareCount,
    required this.songName,
    required this.caption,
    required this.videoUrl,
    required this.profilePhoto,
    required this.thumbnail,
    required this.date, // Thêm trường date vào constructor
  });

  Map<String, dynamic> toJson() => {
    "username": username,
    "uid": uid,
    "profilePhoto": profilePhoto,
    "id": id,
    "likes": likes,
    "reposts": reposts,
    "commentCount": commentCount,
    "shareCount": shareCount,
    "songName": songName,
    "caption": caption,
    "videoUrl": videoUrl,
    "thumbnail": thumbnail,
    "date": date.toIso8601String(), // Chuyển đổi DateTime thành chuỗi
  };

  static Video fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Video(
      username: snapshot['username'],
      uid: snapshot['uid'],
      id: snapshot['id'],
      likes: snapshot['likes'] ?? [], // Giá trị mặc định nếu không có
      reposts: snapshot['reposts'] ?? [], // Giá trị mặc định nếu không có
      commentCount: snapshot['commentCount'] ?? 0, // Giá trị mặc định nếu không có
      shareCount: snapshot['shareCount'] ?? 0, // Giá trị mặc định nếu không có
      songName: snapshot['songName'] ?? '',
      caption: snapshot['caption'] ?? '',
      videoUrl: snapshot['videoUrl'] ?? '',
      profilePhoto: snapshot['profilePhoto'] ?? '',
      thumbnail: snapshot['thumbnail'] ?? '',
      date: DateTime.parse(snapshot['date']), // Giả định trường này luôn tồn tại
    );
  }
}