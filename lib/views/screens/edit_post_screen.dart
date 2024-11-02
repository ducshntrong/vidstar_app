import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../controllers/video_controller.dart';
import '../../models/video.dart';

class EditPostScreen extends StatelessWidget {
  final Video video;
  final VideoController videoController;

  EditPostScreen({
    required this.video,
    required this.videoController,
  });

  @override
  Widget build(BuildContext context) {
    // Tạo các controller cho TextField
    final TextEditingController captionController = TextEditingController(text: video.caption);
    final TextEditingController songNameController = TextEditingController(text: video.songName);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          'Edit post',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Information
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TextField cho tiêu đề video
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter caption...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            fillColor: Colors.grey[900],
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                          controller: captionController,
                          maxLines: 5,
                          minLines: 3,
                        ),
                        SizedBox(height: 4),
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Enter Song Name',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[900],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(
                              Icons.music_note,
                              color: Colors.white,
                            ),
                          ),
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          controller: songNameController,
                        ),
                      ],
                    ),
                  ),
                ),
                // Thumbnail or Image Preview
                Container(
                  width: 120,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: video.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Hashtag and Mention
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.tag, color: Colors.grey),
                  label: Text(
                    'Hashtags',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.alternate_email, color: Colors.grey),
                  label: Text(
                    'Mention',
                    style: TextStyle(color: Colors.grey),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    side: BorderSide(color: Colors.grey),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Location
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.white),
              title: const Text(
                'Location',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Try searching for a location',
                style: TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.white),
              onTap: () {
                // Open location search
              },
            ),

            const Spacer(),

            // Save Button
            const Center(
              child: Text(
                'You can edit your post within 7 days after posting',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            SizedBox(height: 5),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Gọi hàm editVideoField khi nhấn nút Save
                  await videoController.editVideoField(
                    video.id, // ID video
                    captionController.text,
                    songNameController.text,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 150),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}