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
    // Đặt lại trạng thái search khi màn hình được hiển thị
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchController.resetSearch(); // Gọi hàm reset
    });

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
              borderRadius: BorderRadius.circular(25),
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
                  border: InputBorder.none,
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
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
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
                    crossAxisCount: 2,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: searchController.searchedVideos.length,
                  itemBuilder: (context, index) {
                    final video = searchController.searchedVideos[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VideoScreen2(videoId: video.id),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.network(
                                video.thumbnail,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 250,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  video.caption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
