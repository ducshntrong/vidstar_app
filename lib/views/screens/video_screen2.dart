import 'package:flutter/material.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/video_controller.dart';
import 'package:vidstar_app/views/screens/comment_screen.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';
import 'package:vidstar_app/views/screens/video_screen.dart';
import 'package:vidstar_app/views/widgets/circle_animation.dart';
import 'package:vidstar_app/views/widgets/video_player_iten.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as tago;

import '../../controllers/comment_controller.dart';
import '../../models/video.dart';
import '../../service/NotificationService.dart';
import '../widgets/CustomBottomSheet.dart';
import '../widgets/info_video.dart';

class VideoScreen2 extends StatefulWidget {
  final String videoId; // Tham số để nhận videoId
  VideoScreen2({Key? key, required this.videoId}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen2> {
  // Lấy thể hiện của NotificationService
  final NotificationService notificationService = Get.find<NotificationService>();

  // Khởi tạo VideoController với NotificationService
  late final VideoController videoController;

  @override
  void initState() {
    super.initState();
    videoController = VideoController(notificationService); // Khởi tạo ở đây
    videoController.fetchVideoData(widget.videoId); // Gọi hàm để lấy dữ liệu video
  }

  buildProfile(String profilePhoto) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(children: [
        Positioned(
          left: 5,
          child: Container(
            width: 50,
            height: 50,
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        )
      ]),
    );
  }

  buildMusicAlbum(String profilePhoto) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.grey, Colors.white],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image(
                image: NetworkImage(profilePhoto),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Obx(() {
        // Kiểm tra xem video hiện tại có tồn tại không
        if (videoController.currentVideo.value == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = videoController.currentVideo.value!;

        return PageView.builder(
          controller: PageController(initialPage: 0, viewportFraction: 1),
          scrollDirection: Axis.vertical,
          physics: const NeverScrollableScrollPhysics(), // Ngăn chặn cuộn
          itemBuilder: (context, index) {
            return Stack(
              children: [
                VideoPlayerItem(videoUrl: data.videoUrl),
                Column(
                  children: [
                    const SizedBox(height: 250),
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: CaptionWidget(video: data),
                            ),
                          ),
                          Container(
                            width: 70,
                            margin: EdgeInsets.only(top: size.height / 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Điều hướng đến trang cá nhân của người dùng
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(uid: data.uid),
                                      ),
                                    );
                                  },
                                  child: buildProfile(data.profilePhoto),
                                ),
                                _buildLikeButton(data),
                                _buildCommentButton(data),
                                _buildShareButton(data),
                                CircleAnimation(
                                  child: buildMusicAlbum(data.profilePhoto),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      }),
    );
  }

  // Phương thức xây dựng nút thích
  Widget _buildLikeButton(Video data) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            // Gọi hàm likeVideo
            videoController.likeVideo(data.id);

            // Cập nhật trạng thái
            setState(() {
              // Cập nhật likes nếu cần
              if (data.likes.contains(authController.user.uid)) {
                data.likes.remove(authController.user.uid);
              } else {
                data.likes.add(authController.user.uid);
              }
            });
          },
          child: Image.asset(
            data.likes.contains(authController.user.uid)
                ? 'assets/love2.png'
                : 'assets/love.png', // Đường dẫn đến hình ảnh
            height: 36,
            width: 36,
          ),
        ),
        Text(
          data.likes.length.toString(),
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
          ),
        )
      ],
    );
  }

  // Phương thức xây dựng nút bình luận
  Widget _buildCommentButton(Video data) {
    return Column(
      children: [
        InkWell(
          onTap: () => showCommentBottomSheet(context, data.id, data.uid), // Gọi hàm hiển thị BottomSheet
          child: Image.asset(
            'assets/comments.png',
            height: 32,
            width: 32,
          ),
        ),
        Text(
          data.commentCount.toString(),
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ],
    );
  }

  // Phương thức xây dựng nút chia sẻ
  Widget _buildShareButton(Video data) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context, // Đảm bảo context được truyền vào
              builder: (context) =>
                  CustomBottomSheet(video: data)
            );
          },
          child: Image.asset(
            'assets/more.png',
            height: 32,
            width: 32,
          ),
        ),
        // Text(
        //   data.shareCount.toString(),
        //   style: const TextStyle(fontSize: 15, color: Colors.white),
        // ),
      ],
    );
  }

  void showCommentBottomSheet(BuildContext context, String id, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CommentBottomSheet(postId: id, uid: uid);
      },
    );
  }
}