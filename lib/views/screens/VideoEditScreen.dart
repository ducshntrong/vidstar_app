// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:video_editor/video_editor.dart';
// import 'dart:io';
// import 'confirm_screen.dart';
// import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter/return_code.dart';
//
// class VideoEditScreen extends StatefulWidget {
//   final File videoFile;
//   final String videoPath;
//
//   const VideoEditScreen({
//     Key? key,
//     required this.videoFile,
//     required this.videoPath,
//   }) : super(key: key);
//
//   @override
//   _VideoEditScreenState createState() => _VideoEditScreenState();
// }
//
// class _VideoEditScreenState extends State<VideoEditScreen> {
//   late final VideoEditorController _controller;
//   final _isExporting = ValueNotifier<bool>(false);
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoEditorController.file(
//       widget.videoFile,
//       minDuration: const Duration(seconds: 1),
//       maxDuration: const Duration(seconds: 10),
//     );
//     _controller.initialize().then((_) {
//       setState(() {});
//     }).catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to initialize video editor.')),
//       );
//       Navigator.pop(context);
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _isExporting.dispose();
//     super.dispose();
//   }
//
//   void _exportTrimmedVideo() async {
//     _isExporting.value = true;
//     final config = VideoFFmpegVideoEditorConfig(_controller);
//
//     // Define a path for the output video (e.g., in the app's temporary directory)
//     final directory = await getTemporaryDirectory(); // Use path_provider package
//     final outputPath = '${directory.path}/output_video.mp4';
//
//     try {
//       // Create the execute command with a specific output path
//       final executeConfig = await config.getExecuteConfig();
//       String command = '$executeConfig -y $outputPath'; // Ensure the output path is included
//
//       FFmpegKit.executeAsync(
//         command,
//             (session) async {
//           final returnCode = await session.getReturnCode();
//           _isExporting.value = false;
//
//           if (ReturnCode.isSuccess(returnCode)) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Video exported successfully!')),
//             );
//
//             // Navigate to ConfirmScreen with the exported video
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => ConfirmScreen(
//                   videoFile: File(outputPath), // Use the known path
//                   videoPath: outputPath,
//                 ),
//               ),
//             );
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Export failed.')),
//             );
//           }
//         },
//       );
//     } catch (e) {
//       _isExporting.value = false;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error during export: $e')),
//       );
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Video'),
//         actions: [
//           ValueListenableBuilder<bool>(
//             valueListenable: _isExporting,
//             builder: (_, isExporting, __) {
//               return IconButton(
//                 icon: isExporting
//                     ? const CircularProgressIndicator()
//                     : const Icon(Icons.check),
//                 onPressed: !isExporting ? _exportTrimmedVideo : null,
//               );
//             },
//           ),
//         ],
//       ),
//       body: _controller.initialized
//           ? Column(
//         children: [
//           Expanded(
//             child: CropGridViewer.preview(controller: _controller),
//           ),
//           TrimSlider(
//             controller: _controller,
//             height: 60,
//             child: TrimTimeline(controller: _controller),
//           ),
//         ],
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }
