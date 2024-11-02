import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/models/video.dart';

import '../models/notification.dart';
import '../models/report.dart';
import '../service/NotificationService.dart';
import 'auth_controller.dart';

class VideoController extends GetxController {
  final Rx<List<Video>> _videoList = Rx<List<Video>>([]);
  final Rx<List<Video>> _followingVideoList = Rx<List<Video>>([]); // Ds video người theo dõi
  var currentVideo = Rx<Video?>(null); // Biến để lưu video hiện tại
  var currentPage = 0.obs; // Biến trạng thái cho trang hiện tại

  List<Video> get videoList => _videoList.value;
  List<Video> get followingVideoList => _followingVideoList.value; // Getter cho ds video người theo dõi
  final NotificationService notificationService;

  VideoController(this.notificationService);

  @override
  void onInit() {
    super.onInit();

    // Lấy tất cả video
    _videoList.bindStream(
      firestore.collection('videos').snapshots().map((QuerySnapshot query) {
        List<Video> retVal = [];
        for (var element in query.docs) {
          retVal.add(Video.fromSnap(element));
        }
        // Sắp xếp ds video theo trường date (giảm dần)
        retVal.sort((a, b) => b.date.compareTo(a.date));

        return retVal;
      }),
    );

    // Lấy video của những ng theo dõi
    getFollowingVideos();
  }

  Future<void> getFollowingVideos() async {
    var uid = authController.user.uid;

    // Lấy ds UID của ng theo dõi
    var followingCollection = await firestore
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();

    List<String> followingUserIds = followingCollection.docs.map((doc) => doc.id).toList();

    if (followingUserIds.isNotEmpty) {
      // Lấy video của những ng theo dõi
      _followingVideoList.bindStream(
        firestore.collection('videos')
            .where('uid', whereIn: followingUserIds)
            .snapshots()
            .map((QuerySnapshot query) {
          List<Video> retVal = [];
          for (var element in query.docs) {
            retVal.add(Video.fromSnap(element));
          }
          retVal.sort((a, b) => b.date.compareTo(a.date));

          return retVal;
        }),
      );
    }
  }

  void fetchVideoData(String videoId) async {
    currentVideo.value = null;
    DocumentSnapshot videoDoc = await firestore.collection('videos').doc(videoId).get();
    if (videoDoc.exists) {
      currentVideo.value = Video.fromSnap(videoDoc); // Lưu video hiện tại
    }
  }

  Future<void> deleteVideo(String videoId, String thumbnailUrl) async {
    try {
      // Xoá video từ Firestore
      await firestore.collection('videos').doc(videoId).delete();

      // Lấy đường dẫn video và thumbnail để xoá từ Storage
      Reference videoRef = firebaseStorage.ref().child('videos').child(videoId);
      Reference thumbnailRef = firebaseStorage.ref().child('thumbnails').child(videoId);

      // Xoá video và thumbnail khỏi Storage
      await videoRef.delete();
      await thumbnailRef.delete();

      Get.snackbar('Success', 'Video deleted successfully!');
    } catch (e) {
      Get.snackbar('Error Deleting Video', e.toString());
    }
  }

  void likeVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    var userDoc = await firestore.collection('users').doc(uid).get();
    String username = userDoc.data()!['name'];

    bool isLiked = (doc.data()! as Map<String, dynamic>)['likes'].contains(uid);
    String videoOwnerId = (doc.data()! as Map<String, dynamic>)['uid'];

    if (isLiked) {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayRemove([uid]),
      });

      // Cập nhật ds video đã thích
      await firestore.collection('users').doc(uid).update({
        'likedVideos': FieldValue.arrayRemove([id]),
      });

      await notificationService.deleteNotification(videoOwnerId, uid, "like", " like your video.");
    } else {
      await firestore.collection('videos').doc(id).update({
        'likes': FieldValue.arrayUnion([uid]),
      });

      // Cập nhật ds video đã thích
      await firestore.collection('users').doc(uid).update({
        'likedVideos': FieldValue.arrayUnion([id]),
      });

      if (uid != videoOwnerId) {
        await notificationService.createNotification(
          Notifications(
            id: 'Notification_${DateTime.now().millisecondsSinceEpoch}',
            profileImage: userDoc.data()!['profilePhoto'],
            username: username,
            content: " like your video.",
            date: DateTime.now(),
            recipientId: videoOwnerId,
            videoId: id,
            isRead: false,
            type: "like",
            senderId: uid,
          ),
        );

        // // Gửi thông báo FCM
        // DocumentSnapshot videoOwnerDoc = await firestore.collection('users').doc(videoOwnerId).get();
        // String? videoOwnerFcmToken = (videoOwnerDoc.data() as Map<String, dynamic>)['fcmToken']; // Lấy FCM token của người nhận
        //
        // if (videoOwnerFcmToken != null) {
        //   await notificationService.sendNotification(videoOwnerFcmToken, "$username liked your video.", username);
        // }
      }
    }
  }

  Future<void> reportVideo(String videoId, String videoUrl, String userId, String reason) async {
    try {
      // Tạo ID cho report
      String reportId = FirebaseFirestore.instance.collection('reports').doc().id;

      // Tạo đối tượng Report
      Report report = Report(
        id: reportId,
        videoId: videoId,
        videoUrl: videoUrl,
        userId: userId,
        reason: reason,
        date: DateTime.now(),
      );

      // Gửi báo cáo lên Firestore
      await FirebaseFirestore.instance.collection('reports').doc(reportId).set(report.toJson());

      print("Report submitted successfully with ID: $reportId");
    } catch (e) {
      print("Failed to submit report: $e");
    }
  }

  Future<void> repostVideo(String id) async {
    DocumentSnapshot doc = await firestore.collection('videos').doc(id).get();
    var uid = authController.user.uid;
    var userDoc = await firestore.collection('users').doc(uid).get();
    String username = userDoc.data()!['name'];

    // Ktr video đã được repost chưa
    bool isReposted = (doc.data()! as Map<String, dynamic>)['reposts'].contains(uid);
    String videoOwnerId = (doc.data()! as Map<String, dynamic>)['uid'];

    if (isReposted) {
      // Nếu đã repost, hủy repost
      await firestore.collection('videos').doc(id).update({
        'reposts': FieldValue.arrayRemove([uid]), // Xóa UID khỏi ds reposts
      });

      // Cập nhật ds video đã repost của user
      await firestore.collection('users').doc(uid).update({
        'repostedVideos': FieldValue.arrayRemove([id]), // Xóa ID video khỏi ds repost
      });

      await notificationService.deleteNotification(videoOwnerId, uid, "repost", " reposted your video.");
    } else {
      // Nếu chưa repost, thực hiện repost
      await firestore.collection('videos').doc(id).update({
        'reposts': FieldValue.arrayUnion([uid]), // Thêm UID vào ds reposts
      });

      // Cập nhật ds video đã repost của user
      await firestore.collection('users').doc(uid).update({
        'repostedVideos': FieldValue.arrayUnion([id]), // Thêm ID video vào ds repost
      });

      if (uid != videoOwnerId) {
        await notificationService.createNotification(
          Notifications(
            id: 'Notification_${DateTime.now().millisecondsSinceEpoch}',
            profileImage: userDoc.data()!['profilePhoto'],
            username: username,
            content: " reposted your video.",
            date: DateTime.now(),
            recipientId: videoOwnerId,
            videoId: id,
            isRead: false,
            type: "repost",
            senderId: uid,
          ),
        );

        // Gửi thông báo FCM
        // DocumentSnapshot videoOwnerDoc = await firestore.collection('users').doc(videoOwnerId).get();
        // String? videoOwnerFcmToken = (videoOwnerDoc.data() as Map<String, dynamic>)['fcmToken']; // Ép kiểu
        //
        // if (videoOwnerFcmToken != null) {
        //   await notificationService.sendNotification(videoOwnerFcmToken, "$username reposted your video.", username);
        // }
      }
    }
  }

  Future<void> editVideoField(String videoId, String newCaption, String newSongName) async {
    try {
      await firestore.collection('videos').doc(videoId).update({
        'caption': newCaption,
        'songName': newSongName
      });
      Get.snackbar('Success', 'Updated successfully!');
    } catch (e) {
      Get.snackbar('Error Updating', e.toString());
    }
  }
}
