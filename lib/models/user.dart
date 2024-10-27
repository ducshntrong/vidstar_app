import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String name;
  String profilePhoto;
  String email;
  String uid;
  String? phoneNumber;
  DateTime? birthDate;
  String? gender;

  User({
    required this.name,
    required this.email,
    required this.uid,
    required this.profilePhoto,
    this.phoneNumber,
    this.birthDate,
    this.gender,
  });

  Map<String, dynamic> toJson() => {
    "name": name,
    "profilePhoto": profilePhoto,
    "email": email,
    "uid": uid,
    "phoneNumber": phoneNumber,
    "birthDate": birthDate?.toIso8601String(),
    "gender": gender,
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
//     this.fcmToken, // Thêm tham số fcmToken vào constructor
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
//     "fcmToken": fcmToken, // Thêm fcmToken vào JSON
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