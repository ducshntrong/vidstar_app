import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vidstar_app/views/screens/report_screen2.dart';

import '../../controllers/video_controller.dart';
import '../../models/video.dart';

class ReportScreen extends StatelessWidget {
  final Video video;

  ReportScreen({
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề với các nút
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const Text(
                'Report Video',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Why are you reporting this video?',
            style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Please select the most appropriate item.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          // Options
          Expanded(
            child: SingleChildScrollView( //SingleChildScrollView => cuộn
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildOption(context, 'Violence, abuse and exploitation to commit crimes'),
                  buildOption(context, 'Hate and harassment'),
                  buildOption(context, 'Suicide and self-harm'),
                  buildOption(context, 'Unhealthy eating and body image'),
                  buildOption(context, 'Dangerous activities and challenges'),
                  buildOption(context, 'Nudity or sexual content'),
                  buildOption(context, 'Shocking and offensive content'),
                  buildOption(context, 'Misinformation'),
                  buildOption(context, 'Spoofing and spamming'),
                  buildOption(context, 'Fraud and scams'),
                  buildOption(context, 'Sharing personal information'),
                  buildOption(context, 'Counterfeiting and intellectual property'),
                  buildOption(context, 'Undisclosed branded content'),
                  buildOption(context, 'Other'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method xây dựng từng tùy chọn và điều hướng đến ReportScreen2
  Widget buildOption(BuildContext context, String title) {
    return Column(
      children: [
        ListTile(
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReportScreen2(
                  video: video,
                  reason: title,
                  videoController: Get.find<VideoController>(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}