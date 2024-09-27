import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/profile_controller.dart';
import 'package:vidstar_app/views/screens/update_screen.dart';
import 'package:vidstar_app/views/screens/video_screen2.dart';
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

  // Khởi tạo ProfileController với NotificationService
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
          // Kiểm tra xem người dùng hiện tại có phải là chủ sở hữu không
          bool isCurrentUser = widget.uid == authController.user.uid;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black12,
              actions: [
                if (isCurrentUser) // Nếu là người dùng hiện tại, hiển thị biểu tượng chỉnh sửa
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {},
                  ) // Nếu không phải, hiển thị biểu tượng khác
              ],
              title: Center(
                child: Text(
                  controller.user['name'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
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
                              mainAxisAlignment: MainAxisAlignment.center, // Căn giữa các nút
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
                                        ? const Color(0xFF565454) // Màu cho Sign Out
                                        : controller.user['isFollowing']
                                        ? const Color(0xFF565454) // Màu cho UnFollow
                                        : const Color(0xFFEE104C), // Màu cho Follow
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10), // Bo góc
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
                                // Kiểm tra điều kiện trước khi thêm nút thứ hai
                                if (widget.uid == authController.user.uid) ...[
                                  SizedBox(width: 10), // Khoảng cách giữa hai nút
                                  ElevatedButton(
                                    onPressed: () {
                                      Get.to(() => UpdateScreen()); // Chuyển đến trang UpdateScreen
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color(0xFF565454), // Màu cho nút thứ hai
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10), // Bo góc
                                      ),
                                    ),
                                    child: const Text(
                                      'Edit Profile', // Text cho nút thứ hai
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // video list
                          // PageView để lướt qua video của người dùng và video đã thích
                          // PageView để lướt qua video của người dùng và video đã thích
                          // SizedBox(
                          //   height: 450,
                          //   child: Column(
                          //     children: [
                          //       // Hiển thị chỉ số trang hiện tại
                          //       Padding(
                          //         padding: const EdgeInsets.all(8.0),
                          //         child: Row(
                          //           mainAxisAlignment: MainAxisAlignment.center,
                          //           children: [
                          //             Icon(
                          //               Icons.video_library,
                          //               size: 30, // Kích thước biểu tượng
                          //               color: _currentPage == 0 ? Colors.red : Colors.grey, // Thay đổi màu sắc
                          //             ),
                          //             const SizedBox(width: 8), // Khoảng cách giữa biểu tượng
                          //             // Kiểm tra xem người dùng hiện tại có phải là chủ sở hữu không
                          //             if (widget.uid == authController.user.uid) ...[
                          //               Icon(
                          //                 Icons.favorite,
                          //                 size: 30, // Kích thước biểu tượng
                          //                 color: _currentPage == 1 ? Colors.red : Colors.grey, // Thay đổi màu sắc
                          //               ),
                          //             ],
                          //           ],
                          //         ),
                          //       ),
                          //       Expanded(
                          //         child: PageView.builder(
                          //           controller: _pageController,
                          //           itemCount: widget.uid == authController.user.uid ? 2 : 1,
                          //           onPageChanged: (index) {
                          //             setState(() {
                          //               _currentPage = index; // Cập nhật trang hiện tại
                          //             });
                          //           },
                          //           itemBuilder: (context, pageIndex) {
                          //             List<String> thumbnails = pageIndex == 0
                          //                 ? controller.user['thumbnails']
                          //                 : controller.user['likedThumbnails'];
                          //
                          //             // Kiểm tra nếu thumbnails rỗng
                          //             if (thumbnails == null || thumbnails.isEmpty) {
                          //               return const Center(
                          //                 child: Text(
                          //                   "No videos available.",
                          //                   style: TextStyle(fontSize: 18, color: Colors.grey),
                          //                 ),
                          //               );
                          //             }
                          //
                          //             return GridView.builder(
                          //               shrinkWrap: true,
                          //               physics: const AlwaysScrollableScrollPhysics(),
                          //               itemCount: thumbnails.length,
                          //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          //                 crossAxisCount: 2,
                          //                 childAspectRatio: 1,
                          //                 crossAxisSpacing: 5,
                          //               ),
                          //               itemBuilder: (context, index) {
                          //                 String thumbnail = thumbnails[index];
                          //                 String videoId = pageIndex == 0
                          //                     ? controller.user['videoIds'][index]
                          //                     : controller.user['likedVideoIds'][index];
                          //
                          //                 return GestureDetector(
                          //                   onTap: () {
                          //                     Navigator.of(context).push(
                          //                       MaterialPageRoute(
                          //                         builder: (context) => VideoScreen2(videoId: videoId),
                          //                       ),
                          //                     );
                          //                   },
                          //                   child: CachedNetworkImage(
                          //                     imageUrl: thumbnail,
                          //                     fit: BoxFit.cover,
                          //                     placeholder: (context, url) => const CircularProgressIndicator(),
                          //                     errorWidget: (context, url, error) => const Icon(Icons.error),
                          //                   ),
                          //                 );
                          //               },
                          //             );
                          //           },
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 450,
                            child: Column(
                              children: [
                                // Hiển thị chỉ số trang hiện tại
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.video_library,
                                        size: 27, // Kích thước biểu tượng
                                        color: _currentPage == 0 ? Colors.white : Colors.grey, // Thay đổi màu sắc cho video
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.autorenew, // Biểu tượng cho video repost
                                        size: 27,
                                        color: _currentPage == 1 ? Colors.white : Colors.grey, // Thay đổi màu sắc cho video repost
                                      ),
                                      const SizedBox(width: 8),
                                      // Kiểm tra xem người dùng hiện tại có phải là chủ sở hữu không
                                      if (widget.uid == authController.user.uid) ...[
                                        Icon(
                                          Icons.favorite,
                                          size: 27, // Kích thước biểu tượng
                                          color: _currentPage == 2 ? Colors.white : Colors.grey, // Thay đổi màu sắc cho video yêu thích
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: widget.uid == authController.user.uid ? 3 : 2, // Cập nhật số trang
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentPage = index; // Cập nhật trang hiện tại
                                      });
                                    },
                                    itemBuilder: (context, pageIndex) {
                                      List<String> thumbnails;
                                      List<String> videoIds;

                                      if (pageIndex == 0) {
                                        thumbnails = controller.user['thumbnails'];
                                        videoIds = controller.user['videoIds'];
                                      } else if (pageIndex == 1) {
                                        thumbnails = controller.user['repostThumbnails'];
                                        videoIds = controller.user['repostVideoIds'];
                                      } else { // Trang video repost
                                        thumbnails = controller.user['likedThumbnails'];
                                        videoIds = controller.user['likedVideoIds'];
                                      }

                                      // Kiểm tra nếu thumbnails rỗng
                                      if (thumbnails == null || thumbnails.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            "No videos available.",
                                            style: TextStyle(fontSize: 18, color: Colors.grey),
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
                                          crossAxisSpacing: 5,
                                        ),
                                        itemBuilder: (context, index) {
                                          String thumbnail = thumbnails[index];
                                          String videoId = videoIds[index];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => VideoScreen2(videoId: videoId),
                                                ),
                                              );
                                            },
                                            child: CachedNetworkImage(
                                              imageUrl: thumbnail,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) => const CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => const Icon(Icons.error),
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
}
