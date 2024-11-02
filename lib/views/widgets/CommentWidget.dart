import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as tago;
import '../../constants.dart';
import '../screens/profile_screen.dart';

class CommentWidget extends StatelessWidget {
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
    required this.authorId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar user
        InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfileScreen(uid: uid),
              ),
            );
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[850],
            backgroundImage: NetworkImage(profilePhoto),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 18.0),
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
                            builder: (context) => ProfileScreen(uid: uid),
                          ),
                        );
                      },
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // Hiển thị chữ creator nếu cmt la của tác giả video
                    if (uid == authorId) ...[
                      Text(
                        ' • Creator',
                        style: TextStyle(color: Colors.red[400],fontSize: 13),
                      ),
                    ],
                  ],
                ),

                Text(
                  comment,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          tago.format(datePublished),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Hiển thị nút reply chỉ khi không phải là bình luận trả lời
                        if (!isReply) ...[
                          Icon(Icons.quickreply, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: onReply,
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
        ),

        Column(
          children: [
            InkWell(
              onTap: onLike,
              child: Icon(
                Icons.favorite,
                size: 27,
                color: likes.contains(authController.user.uid)
                    ? Colors.redAccent
                    : Colors.white70,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${likes.length}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
