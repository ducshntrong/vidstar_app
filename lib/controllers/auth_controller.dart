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

  bool isPasswordValid(String password) {
    // Kiểm tra độ dài từ 8 đến 16 ký tự
    if (password.length < 8 || password.length > 16) {
      return false;
    }

    // Kiểm tra xem mật khẩu có chứa chữ cái, số và ký tự đặc biệt không
    bool hasLetter = password.contains(RegExp(r'[A-Za-z]')); // Có chứa chữ cái
    bool hasDigits = password.contains(RegExp(r'[0-9]'));    // Có chứa số
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')); // Có chứa ký tự đặc biệt

    // Trả về true nếu mật khẩu đáp ứng tất cả các điều kiện
    return hasLetter && hasDigits && hasSpecialCharacters;
  }

  // registering the user
  void registerUser(
      String username, String email, String password, File? image) async {
    try {
      isLoading.value = true;
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          image != null) {
        // Kiểm tra tính hợp lệ của mật khẩu
        if (!isPasswordValid(password)) {
          Get.snackbar(
            'Invalid Password',
            'Password must be at least 8-16 characters long, contain letters, numbers, and special characters.',
          );
          return;
        }

        // lưu user vao Firebase Auth và Firestore
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
    } finally {
      isLoading.value = false;
    }
  }

  // void registerUser(
  //     String username, String email, String password, File? image) async {
  //   try {
  //     isLoading.value = true; // Bắt đầu quá trình đăng ký
  //
  //     // Kiểm tra xem các trường có hợp lệ không
  //     if (username.isNotEmpty && email.isNotEmpty && password.isNotEmpty && image != null) {
  //       // Kiểm tra tính hợp lệ của mật khẩu
  //       if (!isPasswordValid(password)) {
  //         Get.snackbar(
  //           'Invalid Password',
  //           'Password must be at least 8-16 characters long, contain letters, numbers, and special characters.',
  //         );
  //         return;
  //       }
  //
  //       // Đăng ký người dùng với Firebase Auth
  //       UserCredential cred = await firebaseAuth.createUserWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );
  //
  //       // Lấy token FCM
  //       String? fcmToken = await FirebaseMessaging.instance.getToken();
  //       if (fcmToken == null) {
  //         Get.snackbar('Error', 'Failed to get FCM token.');
  //         return; // Dừng lại nếu không lấy được token
  //       }
  //
  //       // Tải ảnh lên và lấy URL
  //       String downloadUrl = await _uploadToStorage(image);
  //
  //       // Tạo đối tượng người dùng và thêm token FCM
  //       model.User user = model.User(
  //         name: username,
  //         email: email,
  //         uid: cred.user!.uid,
  //         profilePhoto: downloadUrl,
  //         fcmToken: fcmToken, // Lưu token FCM vào đối tượng người dùng
  //       );
  //
  //       // Lưu người dùng vào Firestore
  //       await firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
  //
  //       Get.snackbar('Success', 'User registered successfully!'); // Thông báo thành công
  //     } else {
  //       Get.snackbar('Error Creating Account', 'Please enter all the fields');
  //     }
  //   } catch (e) {
  //     Get.snackbar('Error Creating Account', e.toString());
  //   } finally {
  //     isLoading.value = false; // Kết thúc quá trình đăng ký
  //   }
  // }

  var isLoading = false.obs;
  Future<void> updateUser({
    String? name,
    String? phoneNumber,
    DateTime? birthDate,
    String? gender,
    File? profilePhoto,
  }) async {
    try {
      isLoading.value = true;
      String? downloadUrl;

      // Nếu có ảnh mới, tải và nhận URL
      if (profilePhoto != null) {
        downloadUrl = await _uploadToStorage(profilePhoto);
      }

      // Lấy thông tin người dùng hiện tại
      User currentFirebaseUser = firebaseAuth.currentUser!; // Lấy User từ Firebase

      // Cập nhật tên trong tất cả bình luận của người dùng
      if (name != null) {
        // Lấy tất cả video mà người dùng đã bình luận
        QuerySnapshot videoDocs = await firestore.collection('videos').get();
        for (var videoDoc in videoDocs.docs) {
          QuerySnapshot comments = await firestore
              .collection('videos')
              .doc(videoDoc.id)
              .collection('comments')
              .where('uid', isEqualTo: currentFirebaseUser
              .uid) // Tìm bình luận của người dùng hiện tại
              .get();

          for (var comment in comments.docs) {
            await firestore.collection('videos')
                .doc(videoDoc.id)
                .collection('comments')
                .doc(comment.id)
                .update({
              'username': name, // Cập nhật tên trong bình luận
            });
          }
        }
      }

      // Lấy hình ảnh cũ từ Firestore
      DocumentSnapshot userDoc = await firestore.collection('users').doc(currentFirebaseUser.uid).get();
      String existingPhotoUrl = userDoc['profilePhoto'] ?? ''; // Lấy URL cũ

      // Cập nhật thông tin người dùng trong Firestore
      await firestore.collection('users').doc(currentFirebaseUser.uid).update({
        'name': name ?? '',
        'phoneNumber': phoneNumber ?? '',
        'birthDate': birthDate?.toIso8601String() ?? '',
        'gender': gender ?? '',
        'profilePhoto': downloadUrl ?? existingPhotoUrl, // Giữ nguyên ảnh cũ nếu không có URL mới
      });

      // update tên người dùng trong all video của user
      if (name != null) {
        QuerySnapshot videoDocs = await firestore.collection('videos').where('uid', isEqualTo: currentFirebaseUser.uid).get();
        for (var doc in videoDocs.docs) {
          await firestore.collection('videos').doc(doc.id).update({
            'username': name, // Cập nhật tên user trong video
          });
        }
      }
      // Cập nhật tên trong danh sách followers
      QuerySnapshot followersDocs = await firestore
          .collection('users')//lấy list những ng theo dõi user hiện tại
          .doc(currentFirebaseUser.uid)
          .collection('followers')
          .get();
      for (var doc in followersDocs.docs) {
        //update tên của user hiện tại trong danh sách following của từng follower
        await firestore.collection('users').doc(doc.id).collection('following').doc(currentFirebaseUser.uid).update({
          'name': name, // Cập nhật tên user trong ds followers
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
          'name': name, // Cập nhật tên user trong danh sách following
        });
      }

      // Cập nhật tên user trong tất cả thông báo
      QuerySnapshot notificationDocs = await firestore.collection('notifications').where('senderId', isEqualTo: currentFirebaseUser.uid).get();
      for (var doc in notificationDocs.docs) {
        await firestore.collection('notifications').doc(doc.id).update({
          'username': name, // Cập nhật tên user trong thông báo
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
