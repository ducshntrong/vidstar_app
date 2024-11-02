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
  bool showSlider = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        videoPlayerController.play();
        videoPlayerController.setVolume(1);
        setState(() {});
      });

    videoPlayerController.addListener(() {
      // Nếu video đã đến cuối, tự động phát lại
      if (videoPlayerController.value.position == videoPlayerController.value.duration) {
        videoPlayerController.seekTo(Duration.zero);
        videoPlayerController.play();
      }
      setState(() {});
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
        showSlider = true; // Hiển thị slider khi video dừng
      } else {
        videoPlayerController.play();
        isPlaying = true;
        showSlider = false; // Ẩn slider khi video phát
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
            child: videoPlayerController.value.isInitialized
                ? FittedBox(
              fit: BoxFit.contain,
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
          if (showSlider) // Hiển thị slider chỉ khi showSlider là true
            Positioned(
              bottom: 0,
              left: 5,
              right: 5,
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.0, // Chiều cao của track
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: videoPlayerController.value.position.inSeconds.toDouble(),
                      min: 0.0,
                      max: videoPlayerController.value.duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                        });
                      },
                      onChangeEnd: (value) {
                        // Tự động phát video lại sau khi tua
                        videoPlayerController.play();
                        isPlaying = true; // Đặt trạng thái là đang phát
                        showSlider = false; // Ẩn slider
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}