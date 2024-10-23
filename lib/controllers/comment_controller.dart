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
          // Sắp xếp theo datePublished giảm dần
          retValue.sort((a, b) => b.datePublished.compareTo(a.datePublished));
          return retValue;
        },
      ),
    );
  }

  Future<void> postComment(String commentText, {String? parentId}) async {
    try {
      // Kiểm tra xem nội dung bình luận có rỗng không
      if (commentText.isNotEmpty) {
        // Lấy thông tin người dùng
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(authController.user.uid)
            .get();

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Tạo ID bình luận mới
        String commentId = firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc()
            .id;

        // Tạo một đối tượng Comment
        Comment comment = Comment(
          username: userData['name'],
          comment: commentText.trim(),
          datePublished: DateTime.now(),
          likes: [],
          profilePhoto: userData['profilePhoto'],
          uid: authController.user.uid,
          id: commentId,
          parentId: parentId,
        );

        // Lưu bình luận vào Firestore
        await firestore
            .collection('videos')
            .doc(_postId)
            .collection('comments')
            .doc(commentId)
            .set(comment.toJson());

        // Lấy ID của chủ video
        String videoOwnerId = (await firestore.collection('videos').doc(_postId).get()).data()!['uid'];

        // Tạo thông báo khi bình luận nếu không phải bình luận của chính mình
        if (authController.user.uid != videoOwnerId) {
          await notificationService.createNotification(
            Notifications(
              id: 'Notification_${DateTime.now().millisecondsSinceEpoch}',
              profileImage: userData['profilePhoto'],
              username: userData['name'],
              content: " commented on your video.",
              date: DateTime.now(),
              recipientId: videoOwnerId,
              videoId: _postId,
              isRead: false,
              type: "comment",
              senderId: authController.user.uid,
            ),
          );
        }

        // Nếu đây là bình luận trả lời, tạo thông báo cho người dùng của bình luận cha
        if (parentId != null) {
          DocumentSnapshot parentCommentDoc = await firestore
              .collection('videos')
              .doc(_postId)
              .collection('comments')
              .doc(parentId)
              .get();

          // Ép kiểu dữ liệu để tránh lỗi
          Map<String, dynamic> parentCommentData = parentCommentDoc.data() as Map<String, dynamic>;
          String parentUserId = parentCommentData['uid'];

          if (authController.user.uid != parentUserId) {
            await notificationService.createNotification(
              Notifications(
                id: 'Notification_${DateTime.now().millisecondsSinceEpoch}_reply',
                profileImage: userData['profilePhoto'],
                username: userData['name'],
                content: " replied to your comment.",
                date: DateTime.now(),
                recipientId: parentUserId,
                videoId: _postId,
                isRead: false,
                type: "reply",
                senderId: authController.user.uid,
              ),
            );
          }
        }

        // Cập nhật số lượng bình luận trong video
        DocumentSnapshot doc = await firestore.collection('videos').doc(_postId).get();
        int commentCount = (doc.data()! as Map<String, dynamic>)['commentCount'] ?? 0;
        await firestore.collection('videos').doc(_postId).update({
          'commentCount': commentCount + 1,
        });
      }
    } catch (e) {
      // Hiển thị thông báo lỗi nếu có
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

  // deleteComment(String commentId) async {
  //   try {
  //     // Lấy thông tin bình luận để xác định người sở hữu bình luận
  //     DocumentSnapshot commentDoc = await firestore
  //         .collection('videos')
  //         .doc(_postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .get();
  //
  //     if (!commentDoc.exists) {
  //       Get.snackbar('Error', 'Comment not found.');
  //       return;
  //     }
  //
  //     // Lấy ID của chủ video
  //     String videoOwnerId = (await firestore.collection('videos').doc(_postId).get()).data()!['uid'];
  //     String uid = authController.user.uid;
  //
  //     // Lấy tất cả bình luận con trước khi xóa bình luận cha
  //     QuerySnapshot childCommentsSnapshot = await firestore
  //         .collection('videos')
  //         .doc(_postId)
  //         .collection('comments')
  //         .where('parentId', isEqualTo: commentId)
  //         .get();
  //
  //     // Xóa tất cả bình luận con
  //     for (var doc in childCommentsSnapshot.docs) {
  //       await doc.reference.delete(); // Xóa bình luận con
  //     }
  //
  //     // Xóa bình luận cha khỏi Firestore
  //     await firestore
  //         .collection('videos')
  //         .doc(_postId)
  //         .collection('comments')
  //         .doc(commentId)
  //         .delete();
  //
  //     // Cập nhật số lượng bình luận trong video
  //     DocumentSnapshot videoDoc = await firestore.collection('videos').doc(_postId).get();
  //     int currentCommentCount = (videoDoc.data()! as Map<String, dynamic>)['commentCount'] ?? 0;
  //     await firestore.collection('videos').doc(_postId).update({
  //       'commentCount': currentCommentCount - 1 - childCommentsSnapshot.docs.length, // Cập nhật số lượng bình luận
  //     });
  //
  //     // Xóa thông báo liên quan
  //     await notificationService.deleteNotification(
  //         videoOwnerId, // ID của người sở hữu bình luận
  //         uid, // ID của người xóa bình luận
  //         "comment", // Loại thông báo
  //         " commented your video." // Nội dung thông báo
  //     );
  //
  //   } catch (e) {
  //     // Hiển thị thông báo lỗi nếu có
  //     Get.snackbar('Error While Deleting Comment', e.toString());
  //   }
  // }
  deleteComment(String commentId) async {
    try {
      // Lấy thông tin bình luận để xác định người sở hữu bình luận
      DocumentSnapshot commentDoc = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        Get.snackbar('Error', 'Comment not found.');
        return;
      }

      // Ép kiểu cho dữ liệu bình luận
      Map<String, dynamic> commentData = commentDoc.data() as Map<String, dynamic>;
      String commentOwnerId = commentData['uid']; // ID của người sở hữu bình luận

      // Lấy ID của chủ video
      String videoOwnerId = (await firestore.collection('videos').doc(_postId).get()).data()!['uid'];
      var uid = authController.user.uid;

      // Lấy tất cả bình luận con trước khi xóa bình luận cha
      QuerySnapshot childCommentsSnapshot = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .where('parentId', isEqualTo: commentId)
          .get();

      // Xóa tất cả bình luận con và thông báo liên quan
      for (var doc in childCommentsSnapshot.docs) {
        // Lấy thông tin bình luận con
        Map<String, dynamic> childCommentData = doc.data() as Map<String, dynamic>;
        String childCommentOwnerId = childCommentData['uid'];

        // Xóa thông báo liên quan đến bình luận con
        await notificationService.deleteNotification(
            childCommentOwnerId, // ID của người sở hữu bình luận con
            uid, // ID của người xóa bình luận
            "reply", // Loại thông báo
            " replied to your comment." // Nội dung thông báo
        );

        await doc.reference.delete(); // Xóa bình luận con
      }

      // Xóa bình luận cha khỏi Firestore
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Cập nhật số lượng bình luận trong video
      DocumentSnapshot videoDoc = await firestore.collection('videos').doc(_postId).get();
      int currentCommentCount = (videoDoc.data()! as Map<String, dynamic>)['commentCount'] ?? 0;
      await firestore.collection('videos').doc(_postId).update({
        'commentCount': currentCommentCount - 1 - childCommentsSnapshot.docs.length, // Cập nhật số lượng bình luận
      });

      // Xóa thông báo liên quan đến bình luận
      if (uid != commentOwnerId) { // Kiểm tra xem người xóa không phải là chủ bình luận
        await notificationService.deleteNotification(
            commentOwnerId, // ID của người sở hữu bình luận
            uid, // ID của người xóa bình luận
            "comment", // Loại thông báo
            " commented on your video." // Nội dung thông báo
        );
      }

    } catch (e) {
      // Hiển thị thông báo lỗi nếu có
      Get.snackbar('Error While Deleting Comment', e.toString());
    }
  }

  editComment(String commentId, String updatedCommentText) async {
    try {
      // Lấy thông tin bình luận từ Firestore
      DocumentSnapshot commentDoc = await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) {
        Get.snackbar('Error', 'Comment not found.');
        return;
      }

      // Cập nhật nội dung bình luận
      await firestore
          .collection('videos')
          .doc(_postId)
          .collection('comments')
          .doc(commentId)
          .update({
        'comment': updatedCommentText.trim(),
        'datePublished': DateTime.now(), // Cập nhật thời gian nếu cần
      });

    } catch (e) {
      Get.snackbar('Error While Editing Comment', e.toString());
    }
  }
}
