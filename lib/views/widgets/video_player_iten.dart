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
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        videoPlayerController.play();
        videoPlayerController.setVolume(1);
        setState(() {}); // Cập nhật để hiển thị video
      });

    videoPlayerController.addListener(() {
      if (videoPlayerController.value.position == videoPlayerController.value.duration) {
        videoPlayerController.seekTo(Duration.zero);
        videoPlayerController.play();
      }
    });
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (videoPlayerController.value.isPlaying) {
        videoPlayerController.pause();
        isPlaying = false;
      } else {
        videoPlayerController.play();
        isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: videoPlayerController.value.isInitialized ? FittedBox(
              fit: BoxFit.contain, // Hoặc BoxFit.cover
              child: SizedBox(
                width: videoPlayerController.value.size.width,
                height: videoPlayerController.value.size.height,
                child: VideoPlayer(videoPlayerController),
              ),
            )
                : const Center(child: SizedBox()),
          ),
          if (!isPlaying)
            const Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white70,
                size: 64.0,
              ),
            ),
        ],
      ),
    );
  }
}