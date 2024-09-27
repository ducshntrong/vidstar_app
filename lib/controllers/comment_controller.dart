import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/models/comment.dart';

import '../models/notification.dart';
import '../service/NotificationService.dart';
import 'auth_controller.dart';

class CommentController extends GetxController {
  final Rx<List<Comment>> _comments = Rx<List<Comment>>([]);
  List<Comment> get comments => _comments.value;

  String _postId = "";
  final NotificationService notificationService;

  CommentController(this.notificationService);

  updatePostId(String id) {
    _postId = id;
    getComment();
  }

  getComment() async {
    _comments.bindStream(
      firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .snapshots()
          .map(
            (QuerySnapshot query) {
          List<Comment> retValue = [];
          for (var element in query.docs) {
            retValue.add(Comment.fromSnap(element));
          }
          return retValue;
        },
      ),
    );
  }

  postComment(String commentText) async {
    try {
      if (commentText.isNotEmpty) {
        // Lấy tài liệu người dùng và ép kiểu
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.user.uid)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        var allDocs = await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .get();
        int len = allDocs.docs.length;

        Comment comment = Comment(
          username: userData['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          likes: [],
          profilePhoto: userData['profilePhoto'],
          uid: authController.user.uid,
          id: 'Comment $len',
        );
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc('Comment $len')
            .set(comment.toJson());

        // Lấy ID của chủ video
        String videoOwnerId = (await firestore.collection('videos').doc(_postId).get()).data()!['uid'];

        // Tạo thông báo khi bình luận nếu không phải bình luận của chính mình
        if (authController.user.uid != videoOwnerId) {
          await notificationService.createNotification(
            Notifications(
              id: 'Notification_${DateTime.now().millisecondsSinceEpoch}', // Tạo ID duy nhất
              profileImage: userData['profilePhoto'],
              username: userData['name'],
              content: " commented your video.",
              date: DateTime.now(),
              recipientId: videoOwnerId, // ID của chủ video
              videoId: _postId, // ID video liên quan
              isRead: false, // Mặc định là chưa đọc
              type: "comment",
              senderId: authController.user.uid, // ID của người gửi thông báo
            ),
          );
        }

        DocumentSnapshot doc = await firestore.collection('videos').doc(_postId).get();
        await firestore.collection('videos').doc(_postId).update({
          'commentCount': (doc.data()! as Map<String, dynamic>)['commentCount'] + 1,
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error While Commenting',
        e.toString(),
      );
    }
  }

  likeComment(String id) async {
    var uid = authController.user.uid;
    DocumentSnapshot doc = await firestore
        .collection('videos')
        .doc(_postId)
        .collection('comments')
        .doc(id)
        .get();

    // Ép kiểu cho dữ liệu của bình luận
    Map<String, dynamic> commentData = doc.data() as Map<String, dynamic>;
    String commentOwnerId = commentData['uid']; // ID của người sở hữu bình luận

    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    String username = userData['name'];

    if (commentData['likes'].contains(uid)) {
      // Nếu đã thích, bỏ thích
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayRemove([uid]),
      });
      // Xóa thông báo khi bỏ thích
      await notificationService.deleteNotification(
          commentOwnerId, // ID của người sở hữu bình luận
          uid, // ID của người bỏ thích
          "likeComment", // Loại thông báo
          " liked your comment." // Nội dung thông báo
      );
    } else {
      // Nếu chưa thích, thêm vào
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(id)
          .update({
        'likes': FieldValue.arrayUnion([uid]),
      });

      // Kiểm tra xem người dùng có phải là chủ bình luận không
      if (uid != commentOwnerId) {
        // Tạo thông báo khi thích bình luận nếu không phải bình luận của chính mình
        await notificationService.createNotification(
          Notifications(
            id: 'Notification_${DateTime.now().millisecondsSinceEpoch}', // Tạo ID duy nhất
            profileImage: userData['profilePhoto'],
            username: username,
            content: " liked your comment.",
            date: DateTime.now(),
            recipientId: commentOwnerId, // ID của chủ bình luận
            videoId: _postId, // ID video liên quan
            isRead: false, // Mặc định là chưa đọc
            type: "likeComment",
            senderId: uid, // ID của người gửi thông báo
          ),
        );
      }
    }
  }
}
