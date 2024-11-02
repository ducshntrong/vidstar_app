import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tago;
import 'package:vidstar_app/views/screens/profile_screen.dart';

import '../../models/comment.dart';
import '../../service/NotificationService.dart';
import '../widgets/CommentWidget.dart';

class CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String uid;

  const CommentBottomSheet({Key? key, required this.postId,required this.uid}) : super(key: key);

  @override
  _CommentBottomSheetState createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final NotificationService notificationService = Get.find<NotificationService>();
  late final CommentController commentController;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? replyingToCommentId;

  @override
  void initState() {
    super.initState();
    commentController = Get.put(CommentController(notificationService));
    commentController.updatePostId(widget.postId);

    // Lắng nghe sự kiện focus
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          replyingToCommentId = null; // Đặt lại trạng thái khi bàn phím bị đóng
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Hàm để hiển thị hộp thoại tùy chọn
  void showCommentOptions(BuildContext context, Comment comment) {
    final isMyComment = comment.uid == authController.user.uid; // Kiểm tra uid của cmt

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  // Sao chép nội dung bình luận vào clipboard
                  Clipboard.setData(ClipboardData(text: comment.comment));
                  Get.snackbar('Copied', 'Comment copied to clipboard');
                  Navigator.pop(context);
                },
              ),
              // Hiển thị tùy chọn "Edit" và "Delete" nếu đó là bình luận của user
              if (isMyComment) ...[
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _showEditDialog(context, comment);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete'),
                  onTap: () {
                    commentController.deleteComment(comment.id);
                    Navigator.pop(context);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.report),
                  title: const Text('Report'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
  void _showEditDialog(BuildContext context, Comment comment) {
    final TextEditingController _editController = TextEditingController(text: comment.comment);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Edit Comment',
            style: TextStyle(color: Colors.white),
          ),
          content: Container(
            width: double.maxFinite, // Chiều rộng tối đa
            child: TextField(
              controller: _editController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your comment',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16.0),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                final updatedComment = _editController.text.trim();
                if (updatedComment.isNotEmpty) {
                  commentController.editComment(comment.id, updatedComment);
                } else {
                  Get.snackbar('Error', 'Comment cannot be empty');
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.blueAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.grey),

          Expanded(
            child: Obx(() {
              if (commentController.comments.isEmpty) {
                return const Center(
                  child: Text(
                    'There are currently no comments',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentController.comments[index];

                  if (comment.parentId == null || comment.parentId!.isEmpty) {
                    return GestureDetector(
                      onLongPress: () {
                        HapticFeedback.mediumImpact();
                        showCommentOptions(context, comment);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommentWidget(
                              username: comment.username,
                              profilePhoto: comment.profilePhoto,
                              comment: comment.comment,
                              datePublished: comment.datePublished.toDate(),
                              onReply: () {
                                setState(() {
                                  replyingToCommentId = comment.id;
                                  _commentController.clear();
                                });
                                _focusNode.requestFocus();
                                Future.delayed(Duration(milliseconds: 100), () {
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });
                              },
                              onLike: () => commentController.likeComment(comment.id),
                              uid: comment.uid,
                              likes: List<String>.from(comment.likes),
                              authorId: widget.uid,
                            ),
                            buildReplies(comment.id), // Hiển thị bình luận con
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox.shrink(); // k hiển thị nếu k phải bình luận cha
                },
              );
            }),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0).copyWith(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: replyingToCommentId != null ? 'Replying to comment...' : 'Write a comment...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      if (_commentController.text.isNotEmpty) {
                        if (replyingToCommentId != null) {
                          commentController.postComment(_commentController.text, parentId: replyingToCommentId);
                          setState(() {
                            replyingToCommentId = null; // Reset ID sau khi gửi
                          });
                        } else {
                          commentController.postComment(_commentController.text);
                        }
                        _commentController.clear();
                      }
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chỉ hiển thị nút "Cancel" khi đang trả lời cmt
                  if (replyingToCommentId != null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          replyingToCommentId = null; // Hủy trả lời
                          _commentController.clear(); // Xóa nội dung
                        });
                        _focusNode.unfocus(); // Bỏ focus khỏi TextField
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget buildReplies(String commentId) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('videos')
          .doc(widget.postId)
          .collection('comments')
          .where('parentId', isEqualTo: commentId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SizedBox.shrink();
        }
        List<Comment> replies = snapshot.data!.docs.map((doc) => Comment.fromSnap(doc)).toList();
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: replies.length,
          itemBuilder: (context, index) {
            Comment reply = replies[index];
            return GestureDetector(
              onLongPress: () {
                HapticFeedback.mediumImpact();
                showCommentOptions(context, reply); // Truyền bình luận con
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: CommentWidget(
                  username: reply.username,
                  profilePhoto: reply.profilePhoto,
                  comment: reply.comment,
                  datePublished: reply.datePublished.toDate(),
                  onReply: () {
                    replyingToCommentId = reply.id;
                    _focusNode.requestFocus();
                    Future.delayed(Duration(milliseconds: 100), () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    });
                  },
                  onLike: () => commentController.likeComment(reply.id),
                  uid: reply.uid,
                  likes: List<String>.from(reply.likes),
                  isReply: true,
                  authorId: widget.uid,
                ),
              ),
            );
          },
        );
      },
    );
  }

}
