import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String profilePhoto;
  String email;
  String uid;
  String? phoneNumber;
  DateTime? birthDate;
  String? gender;
  bool isOnline;
  DateTime? lastSeen;

  User({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.isOnline = false, // Mặc định là offline
    this.lastSeen,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "profilePhoto": profilePhoto,
    "email": email,
    "uid": uid,
    "phoneNumber": phoneNumber,
    "birthDate": birthDate?.toIso8601String(),
    "gender": gender,
    "isOnline": isOnline,
    "lastSeen": lastSeen?.toIso8601String(),
  };

  static User fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return User(
      email: snapshot['email'],
      profilePhoto: snapshot['profilePhoto'],
      uid: snapshot['uid'],
      name: snapshot['name'],
      phoneNumber: snapshot['phoneNumber'],
      birthDate: snapshot['birthDate'] != null ? DateTime.parse(snapshot['birthDate']) : null,
      gender: snapshot['gender'],
      isOnline: snapshot['isOnline'] ?? false,
      lastSeen: snapshot['lastSeen'] != null ? (snapshot['lastSeen'] as Timestamp).toDate() : null, // Chuyển đổi Timestamp sang DateTime
    );
  }

}

// class User {
//   String name;
//   String profilePhoto;
//   String email;
//   String uid;
//   String? phoneNumber; // Có thể null
//   DateTime? birthDate; // Có thể null
//   String? gender; // Có thể null
//   String? fcmToken; // Thêm trường fcmToken
//
//   User({
//     required this.name,
//     required this.email,
//     required this.uid,
//     required this.profilePhoto,
//     this.phoneNumber,
//     this.birthDate,
//     this.gender,
//     this.fcmToken,
//   });
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "profilePhoto": profilePhoto,
//     "email": email,
//     "uid": uid,
//     "phoneNumber": phoneNumber,
//     "birthDate": birthDate?.toIso8601String(),
//     "gender": gender,
//     "fcmToken": fcmToken,
//   };
//
//   static User fromSnap(DocumentSnapshot snap) {
//     var snapshot = snap.data() as Map<String, dynamic>;
//     return User(
//       email: snapshot['email'],
//       profilePhoto: snapshot['profilePhoto'],
//       uid: snapshot['uid'],
//       name: snapshot['name'],
//       phoneNumber: snapshot['phoneNumber'],
//       birthDate: snapshot['birthDate'] != null ? DateTime.parse(snapshot['birthDate']) : null,
//       gender: snapshot['gender'],
//       fcmToken: snapshot['fcmToken'], // Lấy fcmToken từ snapshot
//     );
//   }
// }