import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/video_controller.dart';
import 'package:vidstar_app/models/user.dart' as model;
import 'package:vidstar_app/views/screens/auth/login_screen.dart';
import 'package:vidstar_app/views/screens/home_screen.dart';

import '../service/NotificationService.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  late Rx<User?> _user;
  final Rx<File?> _pickedImage = Rx<File?>(null);

  File? get profilePhoto => _pickedImage.value;
  User get user => _user.value!;

  @override
  void onReady() {
    super.onReady();
    _user = Rx<User?>(firebaseAuth.currentUser);
    _user.bindStream(firebaseAuth.authStateChanges());
    ever(_user, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(() => LoginScreen());
    } else {
      Get.offAll(() => const HomeScreen());
    }
  }

  void pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      Get.snackbar('Profile Picture', 'You have successfully selected your profile picture!');
      _pickedImage.value = File(pickedImage.path); // Cập nhật hình ảnh đã chọn
    }
  }

  // upload to firebase storage
  Future<String> _uploadToStorage(File image) async {
    Reference ref = firebaseStorage
        .ref()
        .child('profilePics')
        .child(firebaseAuth.currentUser!.uid);

    UploadTask uploadTask = ref.putFile(image);
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // registering the user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // save out user to our ath and firebase firestore
        UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        String downloadUrl = await _uploadToStorage(image);
        model.User user = model.User(
          name: username,
          email: email,
          uid: cred.user!.uid,
          profilePhoto: downloadUrl,
        );
        await firestore
            .collection('users')
            .doc(cred.user!.uid)
            .set(user.toJson());
      } else {
        Get.snackbar(
          'Error Creating Account',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Creating Account',
        e.toString(),
      );
    }
  }

  var isLoading = false.obs; // Biến trạng thái tải lên
  Future<void> updateUser({
    String? name,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    File? profilePhoto,
  }) async {
    try {
      isLoading.value = true; // Bắt đầu quá trình cập nhật
      String? downloadUrl;

      // Nếu có hình ảnh mới, tải lên và nhận URL
      if (profilePhoto != null) {
        downloadUrl = await _uploadToStorage(profilePhoto);
      }

      // Lấy thông tin người dùng hiện tại
      User currentFirebaseUser = firebaseAuth.currentUser!; // Lấy User từ Firebase

      // Lấy hình ảnh cũ từ Firestore
      DocumentSnapshot userDoc = await firestore.collection('users').doc(currentFirebaseUser.uid).get();
      String existingPhotoUrl = userDoc['profilePhoto'] ?? ''; // Lấy URL cũ

      // Cập nhật thông tin người dùng trong Firestore
      await firestore.collection('users').doc(currentFirebaseUser.uid).update({
        'name': name ?? '', // Cập nhật nếu có giá trị mới
        'phoneNumber': phoneNumber ?? '', // Cập nhật nếu có giá trị mới
        'birthDate': birthDate?.toIso8601String() ?? '', // Cập nhật nếu có giá trị mới
        'gender': gender ?? '', // Cập nhật nếu có giá trị mới
        'profilePhoto': downloadUrl ?? existingPhotoUrl, // Giữ nguyên ảnh cũ nếu không có URL mới
      });

      // Cập nhật tên người dùng trong tất cả video của người dùng
      if (name != null) {
        QuerySnapshot videoDocs = await firestore.collection('videos').where('uid', isEqualTo: currentFirebaseUser.uid).get();
        for (var doc in videoDocs.docs) {
          await firestore.collection('videos').doc(doc.id).update({
            'username': name, // Cập nhật tên người dùng trong video
          });
        }
      }
      // Cập nhật tên trong danh sách followers
      QuerySnapshot followersDocs = await firestore
          .collection('users')//lấy list những ng theo dõi người dùng hiện tại
          .doc(currentFirebaseUser.uid)
          .collection('followers')
          .get();
      for (var doc in followersDocs.docs) {
        //update tên của người dùng hiện tại trong danh sách following của từng follower
        await firestore.collection('users').doc(doc.id).collection('following').doc(currentFirebaseUser.uid).update({
          'name': name, // Cập nhật tên người dùng trong danh sách followers
        });
      }

      // Cập nhật tên trong danh sách following
      QuerySnapshot followingDocs = await firestore
          .collection('users')
          .doc(currentFirebaseUser.uid)
          .collection('following')
          .get();
      for (var doc in followingDocs.docs) {
        await firestore.collection('users').doc(doc.id).collection('followers').doc(currentFirebaseUser.uid).update({
          'name': name, // Cập nhật tên người dùng trong danh sách following
        });
      }

      // Cập nhật tên người dùng trong tất cả thông báo
      QuerySnapshot notificationDocs = await firestore.collection('notifications').where('senderId', isEqualTo: currentFirebaseUser.uid).get();
      for (var doc in notificationDocs.docs) {
        await firestore.collection('notifications').doc(doc.id).update({
          'username': name, // Cập nhật tên người dùng trong thông báo
        });
      }

      Get.snackbar('Success', 'User information updated successfully.');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user information: ${e.toString()}');
    } finally {
      isLoading.value = false; // Kết thúc quá trình cập nhật
    }
  }

  void loginUser(String email, String password) async {
    try {
      isLoading.value = true; // Bắt đầu quá trình đăng nhập
      if (email.isNotEmpty && password.isNotEmpty) {
        await firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
      } else {
        Get.snackbar(
          'Error Logging in',
          'Please enter all the fields',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error Logging in',
        e.toString(),
      );
    } finally {
      isLoading.value = false; // Kết thúc quá trình đăng nhập
    }
  }

  void signOut() async {
    await firebaseAuth.signOut();
  }

  void resetPassword(String email) async {
    try {
      if (email.isNotEmpty) {
        await firebaseAuth.sendPasswordResetEmail(email: email);
        Get.snackbar(
          'Successfully',
          'Password reset email has been sent! Please check your mailbox.',
        );
      } else {
        Get.snackbar(
          'Error!',
          'Please enter your email address.',
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error!',
        'Sending password reset email failed: ${e.toString()}',
      );
    }
  }
}
