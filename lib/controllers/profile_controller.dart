import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/video_controller.dart';
import '../models/notification.dart';
import '../service/NotificationService.dart';

import 'auth_controller.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> _user = Rx<Map<String, dynamic>>({});
  Map<String, dynamic> get user => _user.value;

  Rx<String> _uid = "".obs;
  final NotificationService notificationService;
  ProfileController(this.notificationService);

  // Khai báo biến để lưu danh sách followers và following
  final Rx<List<Map<String, dynamic>>> _followers = Rx<List<Map<String, dynamic>>>([]);
  final Rx<List<Map<String, dynamic>>> _following = Rx<List<Map<String, dynamic>>>([]);

  // Getter để truy cập danh sách followers và following
  List<Map<String, dynamic>> get followers => _followers.value;
  List<Map<String, dynamic>> get following => _following.value;

  final VideoController videoController = Get.put(VideoController(Get.find<NotificationService>()));//18/9

  void updateUserId(String uid) {
    _uid.value = uid;
    getUserData();
    getFollowers();
    getFollowing();
  }

  // Phương thức để lấy danh sách followers
  Future<void> getFollowers() async {
    try {
      var followerDocs = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .get();

      _followers.value = followerDocs.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
      update();
    } catch (e) {
      print("Error fetching followers: $e");
    }
  }

// Phương thức để lấy danh sách following
  Future<void> getFollowing() async {
    try {
      var followingDocs = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('following')
          .get();

      _following.value = followingDocs.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;
        return data;
      }).toList();
      update();
    } catch (e) {
      print("Error fetching following: $e");
    }
  }

  // Future<void> getUserData() async {
  //   try {
  //     List<String> thumbnails = [];
  //     List<String> videoIds = []; // Danh sách lưu trữ video ID
  //
  //     // Lấy video của người dùng
  //     var myVideos = await firestore
  //         .collection('videos')
  //         .where('uid', isEqualTo: _uid.value)
  //         .get();
  //
  //     for (var videoDoc in myVideos.docs) {
  //       thumbnails.add((videoDoc.data() as Map<String, dynamic>)['thumbnail']);
  //       videoIds.add(videoDoc.id); // Lưu video ID
  //     }
  //
  //     // Lấy thông tin người dùng
  //     DocumentSnapshot userDoc = await firestore.collection('users').doc(_uid.value).get();
  //     if (!userDoc.exists) {
  //       throw Exception("User does not exist");
  //     }
  //     final userData = userDoc.data()! as Map<String, dynamic>;
  //
  //     String name = userData['name'] ?? 'Unknown';
  //     String profilePhoto = userData['profilePhoto'] ?? '';
  //     int likes = 0;
  //
  //     // Tính tổng số lượt thích
  //     for (var item in myVideos.docs) {
  //       likes += (item.data()['likes'] as List).length;
  //     }
  //
  //     // Lấy số lượng người theo dõi và đang theo dõi
  //     var followerDoc = await firestore
  //         .collection('users')
  //         .doc(_uid.value)
  //         .collection('followers')
  //         .get();
  //     var followingDoc = await firestore
  //         .collection('users')
  //         .doc(_uid.value)
  //         .collection('following')
  //         .get();
  //
  //     // Cập nhật thông tin người dùng
  //     _user.value = {
  //       'followers': followerDoc.docs.length.toString(),
  //       'following': followingDoc.docs.length.toString(),
  //       'isFollowing': await _isFollowing(),
  //       'likes': likes.toString(),
  //       'profilePhoto': profilePhoto,
  //       'name': name,
  //       'thumbnails': thumbnails,
  //       'videoIds': videoIds, // Thêm videoIds vào user
  //       'likedThumbnails': [], // Khởi tạo giá trị mặc định
  //       'likedVideoIds': [], // Khởi tạo giá trị mặc định
  //     };
  //
  //     // Cập nhật likedThumbnails và likedVideoIds từ getLikedVideos
  //     if (_user.value['likedThumbnails'] != null) {
  //       _user.value['likedThumbnails'] = await _getLikedThumbnails(); // Lấy liked thumbnails
  //     }
  //     if (_user.value['likedVideoIds'] != null) {
  //       _user.value['likedVideoIds'] = await _getLikedVideoIds(); // Lấy liked video IDs
  //     }
  //
  //     update();
  //   } catch (e) {
  //     print("Error fetching user data: $e");
  //   }
  // }
  Future<void> getUserData() async {
    try {
      List<String> thumbnails = [];
      List<String> videoIds = []; // Danh sách video ID
      List<String> repostThumbnails = []; // Danh sách thumbnail video đã repost
      List<String> repostVideoIds = []; // Danh sách video ID đã repost

      // Lấy video của người dùng
      var myVideos = await firestore
          .collection('videos')
          .where('uid', isEqualTo: _uid.value)
          .get();

      for (var videoDoc in myVideos.docs) {
        thumbnails.add((videoDoc.data() as Map<String, dynamic>)['thumbnail']);
        videoIds.add(videoDoc.id); // Lưu video ID
      }

      // Lấy thông tin người dùng
      var userDoc = await firestore.collection('users').doc(_uid.value).get();
      if (!userDoc.exists) {
        throw Exception("User does not exist");
      }

      // Lấy danh sách video đã repost
      List<String> repostedVideoIds = List<String>.from(userDoc.data()?['repostedVideos'] ?? []);

      for (String id in repostedVideoIds) {
        DocumentSnapshot repostedVideoDoc = await firestore.collection('videos').doc(id).get();
        if (repostedVideoDoc.exists) {
          repostThumbnails.add((repostedVideoDoc.data() as Map<String, dynamic>)['thumbnail']);
          repostVideoIds.add(repostedVideoDoc.id); // Lưu video ID đã repost
        }
      }

      // Lấy thông tin người dùng
      String name = userDoc.data()?['name'] ?? 'Unknown';
      String profilePhoto = userDoc.data()?['profilePhoto'] ?? '';
      int likes = 0;

      // Tính tổng số lượt thích từ video của người dùng
      for (var item in myVideos.docs) {
        likes += (item.data()['likes'] as List).length;
      }

      // Lấy số lượng người theo dõi và đang theo dõi
      var followerDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .get();
      var followingDoc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('following')
          .get();

      // Cập nhật thông tin người dùng
      _user.value = {
        'followers': followerDoc.docs.length.toString(),
        'following': followingDoc.docs.length.toString(),
        'isFollowing': await _isFollowing(),
        'likes': likes.toString(),
        'profilePhoto': profilePhoto,
        'name': name,
        'thumbnails': thumbnails,
        'videoIds': videoIds, // Thêm videoIds vào user
        'likedThumbnails': await _getLikedThumbnails(), // Lấy liked thumbnails
        'likedVideoIds': await _getLikedVideoIds(), // Lấy liked video IDs
        'repostThumbnails': repostThumbnails, // Thêm thumbnail video đã repost
        'repostVideoIds': repostVideoIds, // Thêm video ID đã repost
      };

      update(); // Cập nhật UI
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  Future<List<String>> _getLikedThumbnails() async {
    var uid = authController.user.uid;
    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

    List<String> thumbnails = [];
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      List<String> likedVideoIds = List<String>.from(userData['likedVideos'] ?? []);

      for (String videoId in likedVideoIds) {
        DocumentSnapshot videoDoc = await firestore.collection('videos').doc(videoId).get();
        if (videoDoc.exists) {
          thumbnails.add((videoDoc.data() as Map<String, dynamic>)['thumbnail'] ?? '');
        }
      }
    }
    return thumbnails;
  }

  Future<List<String>> _getLikedVideoIds() async {
    var uid = authController.user.uid;
    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return List<String>.from(userData['likedVideos'] ?? []);
    }
    return [];
  }

  Future<bool> _isFollowing() async {
    var followerDoc = await firestore
        .collection('users')
        .doc(_uid.value)
        .collection('followers')
        .doc(authController.user.uid)
        .get();
    return followerDoc.exists;
  }

  Future<void> followUser() async {
    try {
      var doc = await firestore
          .collection('users')
          .doc(_uid.value)
          .collection('followers')
          .doc(authController.user.uid)
          .get();

      var userDoc = await firestore.collection('users').doc(authController.user.uid).get();
      String followerName = userDoc.data()!['name'];
      String profilePhoto = userDoc.data()!['profilePhoto'];

      if (!doc.exists) {
        // Nếu chưa theo dõi, thêm vào danh sách theo dõi
        await firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .doc(authController.user.uid)
            .set({
          'name': followerName,
          'profilePhoto': profilePhoto,
          'uid': authController.user.uid, // Lưu UID của người theo dõi
        });
        await firestore
            .collection('users')
            .doc(authController.user.uid)
            .collection('following')
            .doc(_uid.value)
            .set({
          'name': _user.value['name'], // Lưu tên của người dùng đang được theo dõi
          'profilePhoto': _user.value['profilePhoto'], // Lưu ảnh đại diện
          'uid': _uid.value, // Lưu UID của người được theo dõi
        });
        _user.value.update(
          'followers',
              (value) => (int.parse(value) + 1).toString(),
        );

        // Tạo thông báo khi theo dõi
        await notificationService.createNotification(
          Notifications(
            id: 'Notification_${DateTime.now().millisecondsSinceEpoch}', // Tạo ID duy nhất
            profileImage: profilePhoto,
            username: followerName,
            content: " started following you.",
            date: DateTime.now(),
            recipientId: _uid.value, // ID của người nhận thông báo
            videoId: '', // ID video có thể để trống nếu không áp dụng
            isRead: false, // Mặc định là chưa đọc
            type: "follow",
            senderId: Get.find<AuthController>().user.uid,
          ),
        );
      } else {
        // Nếu đã theo dõi, xóa khỏi danh sách theo dõi
        await firestore
            .collection('users')
            .doc(_uid.value)
            .collection('followers')
            .doc(authController.user.uid)
            .delete();
        await firestore
            .collection('users')
            .doc(authController.user.uid)
            .collection('following')
            .doc(_uid.value)
            .delete();
        _user.value.update(
          'followers',
              (value) => (int.parse(value) - 1).toString(),
        );

        // Xóa thông báo khi hủy theo dõi
        await notificationService.deleteNotification(
            _uid.value, // ID của người nhận thông báo
            authController.user.uid, // ID của người hủy theo dõi
            "follow", // Loại thông báo
            " started following you." // Nội dung thông báo
        );
      }
      _user.value.update('isFollowing', (value) => !value);

      // Gọi hàm getFollowingVideos để cập nhật danh sách video
      videoController.getFollowingVideos();//18/9
      update();
    } catch (e) {
      print("Error updating follow status: $e");
    }
  }
}
