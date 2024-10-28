import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatusService {
  final FirebaseFirestore firestore;
  final String userId;

  UserStatusService(this.firestore, this.userId);

  Future<void> setOnline() async {
    await firestore.collection('users').doc(userId).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setOffline() async {
    await firestore.collection('users').doc(userId).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}