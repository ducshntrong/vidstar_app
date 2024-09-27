import 'package:flutter/material.dart';
import 'package:vidstar_app/controllers/search_controller.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/models/user.dart';
import 'package:vidstar_app/views/screens/profile_screen.dart';
import 'package:vidstar_app/views/screens/video_screen2.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({Key? key}) : super(key: key);

  final SearchControler searchController = Get.put(SearchControler());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.white10,
        appBar: AppBar(
          elevation: 0,
          title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25), // Bo góc cho TextFormField
              child: TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: 'Search...',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white.withOpacity(0.6),
                  ),
                  border: InputBorder.none, // Không có đường viền
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                onFieldSubmitted: (value) => searchController.searchUser(value),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.mic, color: Colors.white),
              onPressed: () {
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
              },
            ),
          ],
        ),

        body: Column(
          children: [
            if (searchController.searchedUsers.isNotEmpty) ...[
              ...searchController.searchedUsers.map((user) {
                return InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(uid: user.uid),
                    ),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.profilePhoto),
                    ),
                    title: Text(user.name),
                  ),
                );
              }).toList(),
            ],
            if (searchController.searchedVideos.isNotEmpty) ...[
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Hiển thị 2 cột
                    childAspectRatio: 0.58, // Tỉ lệ chiều rộng / chiều cao của các ô
                  ),
                  itemCount: searchController.searchedVideos.length,
                  itemBuilder: (context, index) {
                    final video = searchController.searchedVideos[index];
                    return GestureDetector(
                      onTap: () {
                        // Chuyển đến VideoScreen2 với videoId tương ứng
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoScreen2(videoId: video.id),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Hình ảnh thumbnail
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                video.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 250, // Chiều cao cho thumbnail
                              ),
                            ),
                          ),
                          // Thông tin video
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Caption
                                Text(
                                  video.caption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                // Hình ảnh profile và thông tin người dùng
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundImage: NetworkImage(video.profilePhoto),
                                    ),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Username
                                          Text(
                                            video.username,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Icon và số lượt thích
                                    Row(
                                      children: [
                                        Icon(Icons.favorite_border, color: Colors.white70, size: 20),
                                        const SizedBox(width: 5),
                                        Text(
                                          video.likes.length.toString(),
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            if (searchController.searchedUsers.isEmpty &&
                searchController.searchedVideos.isEmpty) ...[
              const Center(
                child: Text(
                  'No results found!',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}
