import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore firestore;
  final String userId;

  UserService(this.firestore, this.userId);

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


  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot = await firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }
}