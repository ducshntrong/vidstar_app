import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/video.dart';
import '../screens/profile_screen.dart';

class CaptionWidget extends StatefulWidget {
  final Video video;

  const CaptionWidget({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  _CaptionWidgetState createState() => _CaptionWidgetState();
}

class _CaptionWidgetState extends State<CaptionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            InkWell(
              onTap: () {
                // Điều hướng đến trang cá nhân của người dùng
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(uid: widget.video.uid),
                  ),
                );
              },
              child: Text(
                widget.video.username,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Hiện caption
            Text(
              _isExpanded ? widget.video.caption :
              (widget.video.caption.length > 25 ?
              '${widget.video.caption.substring(0, 25)}...' : widget.video.caption),
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xf3f3f3f3),
              ),
            ),
            // Hiện nút "Xem thêm"
            if (widget.video.caption.length > 25)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded; // Chuyển đổi trạng thái
                  });
                },
                child: Text(
                  _isExpanded ? 'Hide' : 'See more',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Row(
              children: [
                const Icon(
                  Icons.music_note,
                  size: 15,
                  color: Colors.white,
                ),
                Text(
                  widget.video.songName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
