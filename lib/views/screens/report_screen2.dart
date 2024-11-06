import 'package:flutter/material.dart';
import 'package:vidstar_app/models/video.dart';

import '../../controllers/video_controller.dart';

class ReportScreen2 extends StatelessWidget {
  final Video video;
  final String reason;
  final VideoController videoController;

  ReportScreen2({
    required this.video,
    required this.reason,
    required this.videoController,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report content that violates our Community Standards',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our standards explain what we allow and what we don\'t allow on VidStar. '
                  'With the help of experts, we regularly review and update our standards.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you sure you want to send this report?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Gọi hàm reportVideo từ VideoController
                  await videoController.reportVideo(video.id, video.videoUrl, video.uid, reason);
                  // Hiển thị SnackBar thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully!'),
                      duration: Duration(seconds: 2), // Thời gian hiển thị
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Send'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Color(0xFF3366FF),
                  padding: const EdgeInsets.symmetric(horizontal: 150, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}