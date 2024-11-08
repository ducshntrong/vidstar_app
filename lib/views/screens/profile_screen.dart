import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/profile_controller.dart';
import 'package:vidstar_app/views/screens/inbox/chat_screen.dart';
import 'package:vidstar_app/views/screens/update_screen.dart';
import 'package:vidstar_app/views/screens/video_screen2.dart';
import '../../models/user.dart';
import '../../service/NotificationService.dart';
import 'follower_screen.dart';
import 'following_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NotificationService notificationService = Get.find<NotificationService>();
  // Khởi tạo ProfileController vs NotificationService
  late final ProfileController profileController;

  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round(); // Lấy chỉ số trang hiện tại
      });
    });
    profileController = ProfileController(notificationService);
    profileController.updateUserId(widget.uid);
    profileController.getUserFromUID(widget.uid);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
        init: profileController,
        builder: (controller) {
          if (controller.user.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final user = controller.user2.value;
          // Ktra xem user hiện tại có phải là chủ sở hữu k
          bool isCurrentUser = widget.uid == authController.user.uid;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black87,
              title: Text(
                controller.user['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(isCurrentUser ? Icons.menu : Icons.more_vert),
                  onPressed: () {
                    // Actions for current or other user
                  },
                ),
              ],
              centerTitle: true,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl: controller.user['profilePhoto'],
                                  height: 100,
                                  width: 100,
                                  placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                  const Icon(
                                    Icons.error,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Điều hướng đến FollowingScreen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowingScreen(),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      controller.user['following'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Following',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.black54,
                                width: 1,
                                height: 15,
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Điều hướng đến FollowerScreen
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => FollowerScreen(),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Text(
                                      controller.user['followers'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'Followers',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                color: Colors.black54,
                                width: 1,
                                height: 15,
                                margin: const EdgeInsets.symmetric(horizontal: 15),
                              ),
                              Column(
                                children: [
                                  Text(
                                    controller.user['likes'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Likes',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Container(
                            width: 440,
                            height: 47,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black12,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (widget.uid == authController.user.uid) {
                                      authController.signOut();
                                    } else {
                                      controller.followUser();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: widget.uid == authController.user.uid
                                        ? const Color(0xFF565454)
                                        : controller.user['isFollowing']
                                        ? const Color(0xFF565454)
                                        : primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    widget.uid == authController.user.uid
                                        ? 'Sign Out'
                                        : controller.user['isFollowing']
                                        ? 'Unfollow'
                                        : 'Follow',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (widget.uid == authController.user.uid) {
                                      // Nếu là user hiện tại, chuyển đến trang UpdateScreen
                                      Get.to(() => UpdateScreen());
                                    } else {
                                      // Nếu k phải, thực hiện chức năng gửi tin nhắn
                                      Get.to(() => ChatScreen(user: user));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: const Color(0xFF565454),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    widget.uid == authController.user.uid
                                        ? 'Edit Profile'
                                        : 'Message',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 700,
                            child: Column(
                              children: [
                                // Hiển thị chỉ số trang hiện tại
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildIcon(Icons.video_library, 0),
                                      const SizedBox(width: 16),
                                      _buildIcon(Icons.autorenew, 1),
                                      const SizedBox(width: 16),
                                      if (widget.uid == authController.user.uid)
                                        _buildIcon(Icons.favorite, 2),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: widget.uid == authController.user.uid ? 3 : 2,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index;
                                      });
                                    },
                                    itemBuilder: (context, pageIndex) {
                                      List<String> thumbnails;
                                      List<String> videoIds;
                                      List<int> likeCounts;

                                      if (pageIndex == 0) {
                                        thumbnails = controller.user['thumbnails'];
                                        videoIds = controller.user['videoIds'];
                                        likeCounts = controller.user['likesCounts'];
                                      } else if (pageIndex == 1) {
                                        thumbnails = controller.user['repostThumbnails'];
                                        videoIds = controller.user['repostVideoIds'];
                                        likeCounts = controller.user['repostLikesCounts'];
                                      } else {
                                        thumbnails = controller.user['likedThumbnails'];
                                        videoIds = controller.user['likedVideoIds'];
                                        likeCounts = controller.user['likedLikesCounts'];
                                      }

                                      if (thumbnails.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.only(bottom: 300.0),
                                          child: Center(
                                            child: Text(
                                              "No videos available.",
                                              style: TextStyle(fontSize: 18, color: Colors.grey),
                                            ),
                                          ),
                                        );
                                      }

                                      return GridView.builder(
                                        shrinkWrap: true,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: thumbnails.length,
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          childAspectRatio: 1,
                                        ),
                                        itemBuilder: (context, index) {
                                          String thumbnail = thumbnails[index];
                                          String videoId = videoIds[index];
                                          int likeCount = likeCounts[index];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => VideoScreen2(videoId: videoId),
                                                ),
                                              );
                                            },
                                            child: Card(
                                              elevation: 4,
                                              child: Stack(
                                                children: [
                                                  AspectRatio(
                                                    aspectRatio: 1 / 1,
                                                    child: ClipRRect(
                                                      child: CachedNetworkImage(
                                                        imageUrl: thumbnail,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 2,
                                                    left: 5,
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.favorite_border,
                                                          size: 25,
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          likeCount.toString(),
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  Widget _buildIcon(IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),

      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        size: 30,
        color: _currentPage == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
