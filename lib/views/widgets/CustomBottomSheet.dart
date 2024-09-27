import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vidstar_app/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/video_controller.dart';
import '../../models/video.dart';
import '../../service/NotificationService.dart';
import '../screens/edit_post_screen.dart';
import '../screens/report_screen.dart';

class CustomBottomSheet extends StatefulWidget {
  final Video video;

  CustomBottomSheet({required this.video});

  @override
  _CustomBottomSheetState createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  final VideoController videoController = Get.put(VideoController(Get.find<NotificationService>()));
  RxBool isReposted = false.obs; // Trạng thái repost
  late DateTime postTime;

  @override
  void initState() {
    super.initState();
    postTime = widget.video.date;
    _checkIfReposted(); // Gọi hàm kiểm tra trạng thái repost
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 180,
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (widget.video.uid != authController.user.uid)
                  Obx(() => _buildIcon(
                      Icons.autorenew,
                      isReposted.value ? "Unrepost" : "Repost",
                      onTap: () {
                        _repostVideo(context); // Gọi hàm repost video
                      })),
                if (widget.video.uid == authController.user.uid) ...[
                  _buildIcon(Icons.edit, "Edit post", onTap: _canEdit() ? () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          EditPostScreen(
                              video: widget.video,
                              videoController: Get.find<VideoController>())),
                    );
                  } : () {
                    Navigator.of(context).pop();
                    _showEditExpiredMessage(); // Hiển thị thông báo quá hạn
                  }), // Bấm vào nếu không thể chỉnh sửa
                  const SizedBox(width: 16),
                  _buildIcon(Icons.delete, "Remove", onTap: () {
                    _confirmDelete(context, widget.video.id, widget.video.thumbnail);
                  }),
                ],
                const SizedBox(width: 16),
                _buildIcon(Icons.link, "Copy link", onTap: () {
                  Navigator.of(context).pop();
                  _copyLink(context, widget.video.videoUrl); // Pass context here
                }),
                const SizedBox(width: 16),
                _buildIcon(Icons.download, "Save video", onTap: () {
                  Navigator.of(context).pop();
                  _downloadVideo(context, widget.video.videoUrl);
                }),
                if (widget.video.uid != authController.user.uid) ...[
                  const SizedBox(width: 16),
                  _buildIcon(Icons.report, "Report", onTap: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.95,
                          child: ReportScreen(video: widget.video),
                        );
                      },
                    );
                  }),
                ],
                const SizedBox(width: 16),
                _buildIcon(Icons.heart_broken, "Not interested"),
                const SizedBox(width: 16),
                _buildIcon(Icons.share, "Share", onTap: () {
                  _shareVideo(widget.video.videoUrl); // Chia sẻ video
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canEdit() {
    final currentTime = DateTime.now();
    return currentTime.difference(postTime).inDays < 7; // Cho phép chỉnh sửa trong 7 ngày
  }

  void _showEditExpiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This video cannot be edited because it has been more than 7 days since you posted it')),
    );
  }

  Widget _buildIcon(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        child: Column(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white12,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 25,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _checkIfReposted() async {
    var videoDoc = await firestore.collection('videos').doc(widget.video.id).get();
    if (videoDoc.exists) {
      var reposts = videoDoc.data()?['reposts'] as List;
      isReposted.value = reposts.contains(authController.user.uid);
      print("Reposted status: $isReposted"); // Thêm log để kiểm tra
    }
  }

  void _repostVideo(BuildContext context) async {
    await videoController.repostVideo(widget.video.id); // Gọi phương thức repost
    Navigator.of(context).pop();
    setState(() {
      isReposted.value = !isReposted.value; // Đảo ngược trạng thái repost
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isReposted.value ? 'Video reposted!' : 'Repost canceled!')),
    );
  }

  void _copyLink(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied!')),
    );
  }

  void _downloadVideo(BuildContext context, String videoUrl) async {
    // Kiểm tra quyền truy cập
    var status = await Permission.storage.request();
    if (status.isGranted) {
      try {
        // Lấy đường dẫn lưu video
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/video.mp4'; // Đặt tên file tùy ý

        // Tải video xuống
        await Dio().download(videoUrl, filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Video saved to $filePath')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Download failed!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied!')),
      );
    }
  }

  void _shareVideo(String videoUrl) {
    Share.share('Check out this video: $videoUrl'); // Chia sẻ video
  }

  void _confirmDelete(BuildContext context, String videoId, String thumbnail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('Confirm Deletion'),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this video?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                await videoController.deleteVideo(videoId, thumbnail); // Gọi hàm xoá video
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video deleted successfully!')),
                );
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}