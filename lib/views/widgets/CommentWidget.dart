import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tago;
import '../../constants.dart';
import '../screens/profile_screen.dart';

class CommentWidget extends StatefulWidget {
  final String username;
  final String profilePhoto;
  final String comment;
  final DateTime datePublished;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final String uid;
  final List<String> likes; // Ds UID của những người thích
  final bool isReply; // Tham số để xác định cmt trả lời
  final String authorId; // Tham số mới để xác định cmt của tác giả video

  const CommentWidget({
    Key? key,
    required this.username,
    required this.profilePhoto,
    required this.comment,
    required this.datePublished,
    required this.onReply,
    required this.onLike,
    required this.uid,
    required this.likes,
    this.isReply = false, // Mặc định là false
    required this.authorId,
  }) : super(key: key);

  @override
  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  bool _isExpanded = false; // Trạng thái mở rộng của bình luận

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Khoảng cách giữa các bình luận
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Giữ cho avatar căn giữa với tên
        children: [
          // Avatar user
          InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: widget.uid),
                ),
              );
            },
            child: CircleAvatar(
              radius: 23,
              backgroundColor: Colors.grey[850],
              backgroundImage: NetworkImage(widget.profilePhoto),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên user
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(uid: widget.uid),
                          ),
                        );
                      },
                      child: Text(
                        widget.username,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Hiển thị chữ creator nếu cmt là của tác giả video
                    if (widget.uid == widget.authorId) ...[
                      const Text(
                        ' • Creator',
                        style: TextStyle(color: Color(0xFF00BFFF), fontSize: 13),
                      ),
                    ],
                  ],
                ),

                // Hiển thị nội dung bình luận
                Text(
                  _isExpanded || widget.comment.length <= 50
                      ? widget.comment
                      : '${widget.comment.substring(0, 50)}...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                ),

                // Hiện nút See more nếu bình luận dài hơn 25 ký tự
                if (widget.comment.length > 50) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded; // Chuyển đổi trạng thái
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Hide' : 'See more',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          tago.format(widget.datePublished),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Hiển thị nút reply chỉ khi không phải là bình luận trả lời
                        if (!widget.isReply) ...[
                          Icon(Icons.quickreply, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: widget.onReply,
                            child: const Text(
                              'Reply',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Column(
            children: [
              InkWell(
                onTap: widget.onLike,
                child: Icon(
                  Icons.favorite,
                  size: 27,
                  color: widget.likes.contains(authController.user.uid)
                      ? Colors.redAccent
                      : Colors.white70,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.likes.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
