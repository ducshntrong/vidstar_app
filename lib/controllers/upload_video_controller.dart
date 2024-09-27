import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/models/video.dart';
import 'package:video_compress/video_compress.dart';

class UploadVideoController extends GetxController {
  _compressVideo(String videoPath) async {
    final compressedVideo = await VideoCompress.compressVideo(
      videoPath,
      quality: VideoQuality.MediumQuality,
    );
    return compressedVideo!.file;
  }

  // Future<String> _uploadVideoToStorage(String id, String videoPath) async {
  //   Reference ref = firebaseStorage.ref().child('videos').child(id);
  //
  //   UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));
  //   TaskSnapshot snap = await uploadTask;
  //   String downloadUrl = await snap.ref.getDownloadURL();
  //   return downloadUrl;
  // }
  Future<String> _uploadVideoToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('videos').child(id);
    UploadTask uploadTask = ref.putFile(await _compressVideo(videoPath));

    // Theo dõi tiến độ tải lên
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      uploadProgress.value = snapshot.bytesTransferred / snapshot.totalBytes; // Cập nhật tiến độ
    });

    TaskSnapshot snap = await uploadTask;
    return await snap.ref.getDownloadURL();
  }

  _getThumbnail(String videoPath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videoPath);
    return thumbnail;
  }

  Future<String> _uploadImageToStorage(String id, String videoPath) async {
    Reference ref = firebaseStorage.ref().child('thumbnails').child(id);
    UploadTask uploadTask = ref.putFile(await _getThumbnail(videoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }

  // upload video
  var uploadProgress = 0.0.obs; // Biến theo dõi tiến độ tải lên
  var isUploading = false.obs; // Biến trạng thái tải lên

  // uploadVideo(String songName, String caption, String videoPath) async {
  //   try {
  //     isUploading.value = true; // Bắt đầu tải lên
  //     String uid = firebaseAuth.currentUser!.uid;
  //     DocumentSnapshot userDoc =
  //     await firestore.collection('users').doc(uid).get();
  //     var allDocs = await firestore.collection('videos').get();
  //     int len = allDocs.docs.length;
  //     String videoId = FirebaseFirestore.instance.collection('videos').doc().id;
  //     String videoUrl = await _uploadVideoToStorage(videoId, videoPath);
  //     String thumbnail = await _uploadImageToStorage(videoId, videoPath);
  //
  //     Video video = Video(
  //       username: (userDoc.data()! as Map<String, dynamic>)['name'],
  //       uid: uid,
  //       id: videoId,
  //       likes: [],
  //       reposts: [],
  //       commentCount: 0,
  //       shareCount: 0,
  //       songName: songName,
  //       caption: caption,
  //       videoUrl: videoUrl,
  //       profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
  //       thumbnail: thumbnail,
  //       date: DateTime.now(),
  //     );
  //
  //     await firestore.collection('videos').doc(videoId).set(video.toJson());
  //     Get.back();
  //   } catch (e) {
  //     Get.snackbar('Error Uploading Video', e.toString());
  //   } finally {
  //     isUploading.value = false; // Kết thúc tải lên
  //   }
  // }
  Future<void> uploadVideo(String songName, String caption, String videoPath, BuildContext context) async {
    try {
      isUploading.value = true; // Bắt đầu tải lên
      uploadProgress.value = 0.0; // Đặt lại tiến độ

      String uid = firebaseAuth.currentUser!.uid;
      DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
      String videoId = FirebaseFirestore.instance.collection('videos').doc().id;

      // Hiển thị dialog cho tiến độ
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Uploading Video"),
            content: Obx(() {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: uploadProgress.value),
                  const SizedBox(height: 10),
                  Text("${(uploadProgress.value * 100).toStringAsFixed(0)}%"),
                ],
              );
            }),
          );
        },
      );

      // Tải video lên
      String videoUrl = await _uploadVideoToStorage(videoId, videoPath);
      String thumbnail = await _uploadImageToStorage(videoId, videoPath);

      // Lưu thông tin video vào Firestore
      Video video = Video(
        username: (userDoc.data()! as Map<String, dynamic>)['name'],
        uid: uid,
        id: videoId,
        likes: [],
        reposts: [],
        commentCount: 0,
        shareCount: 0,
        songName: songName,
        caption: caption,
        videoUrl: videoUrl,
        profilePhoto: (userDoc.data()! as Map<String, dynamic>)['profilePhoto'],
        thumbnail: thumbnail,
        date: DateTime.now(),
      );

      await firestore.collection('videos').doc(videoId).set(video.toJson());

      // Đóng dialog khi hoàn tất
      Navigator.of(context).pop();
      Get.back();
    } catch (e) {
      Get.snackbar('Error Uploading Video', e.toString());
      Navigator.of(context).pop(); // Đóng dialog khi có lỗi
    } finally {
      isUploading.value = false; // Kết thúc tải lên
    }
  }
}
