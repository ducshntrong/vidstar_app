import 'package:flutter/material.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/video_controller.dart';
import 'package:vidstar_app/views/screens/comment_screen.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';
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

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoController videoController = Get.put(VideoController(Get.find<NotificationService>()));

  void showCommentBottomSheet(BuildContext context, String id, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CommentBottomSheet(postId: id, uid: uid);
      },
    );
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
                colors: [
                  Colors.grey,
                  Colors.white,
                ],
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
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: Obx(() {
          // Lấy danh sách video từ controller
          final allVideos = videoController.videoList; // Ds all video
          final followingVideos = videoController.followingVideoList; // Ds video ng theo dõi

          return Stack(
            children: [
              PageView(
                controller: PageController(viewportFraction: 1),
                scrollDirection: Axis.horizontal,
                onPageChanged: (index) {
                  videoController.currentPage.value = index; // Cập nhật trang hiện tại
                },
                children: [
                  // Trang hiển thị tất cả video
                  buildVideoPage(allVideos, context, size),
                  // Trang hiển thị video ng theo dõi
                  buildVideoPage(followingVideos, context, size),
                ],
              ),
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "For you",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: videoController.currentPage.value == 0 ? Colors.white : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Following",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: videoController.currentPage.value == 1 ? Colors.white : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget buildVideoPage(List<Video> videos, BuildContext context, Size size) {
    return SafeArea(
      child: Stack(
        children: [
          PageView.builder(
            itemCount: videos.length,
            controller: PageController(initialPage: 0),
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              final data = videos[index];
              return buildVideoItem(context, data, size);
            },
          ),
        ],
      ),
    );
  }

  Widget buildVideoItem(BuildContext context, Video data, Size size) {
    return SafeArea(
      child: Stack(
        children: [
          VideoPlayerItem(
            videoUrl: data.videoUrl,
          ),
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
                        padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                        child: CaptionWidget(video: data),
                      ),
                    ),
                    Container(
                      width: 70,
                      margin: EdgeInsets.only(top: size.height / 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              // Điều hướng đến trang cá nhân của user
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(uid: data.uid),
                                ),
                              );
                            },
                            child: buildProfile(data.profilePhoto),
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  // Gọi hàm likeVideo
                                  videoController.likeVideo(data.id);

                                  // update trạng thái
                                  setState(() {
                                    // update likes nếu cần
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
                                      : 'assets/love.png',
                                  height: 36,
                                  width: 36,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                data.likes.length.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () => showCommentBottomSheet(context, data.id, data.uid),
                                child: Image.asset(
                                  'assets/comments.png',
                                  height: 32,
                                  width: 32,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                data.commentCount.toString(),
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) =>
                                        CustomBottomSheet(video: data),
                                  );
                                },
                                child: Image.asset(
                                  'assets/more.png',
                                  height: 32,
                                  width: 32,
                                ),
                              ),
                              const SizedBox(height: 1),
                            ],
                          ),
                          CircleAnimation(
                            child: buildMusicAlbum(data.thumbnail),
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
      ),
    );
  }
}

