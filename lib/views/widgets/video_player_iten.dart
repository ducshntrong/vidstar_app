import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController videoPlayerController;
  bool isPlaying = true; // Biến để theo dõi trạng thái phát

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        videoPlayerController.play();
        videoPlayerController.setVolume(1);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
        isPlaying = false; // Cập nhật trạng thái phát
      } else {
        videoPlayerController.play();
        isPlaying = true; // Cập nhật trạng thái phát
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _togglePlayPause, // Gọi hàm để dừng hoặc phát video khi nhấn vào màn hình
      child: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: VideoPlayer(videoPlayerController),
          ),
          // Hiển thị icon play/pause ở giữa màn hình chỉ khi video không đang phát
          if (!isPlaying) // Kiểm tra trạng thái phát
            const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white70,
                size: 64.0, // Kích thước biểu tượng
              ),
            ),
        ],
      ),
    );
  }
}