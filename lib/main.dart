import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/SentimentAnalysis.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/controllers/auth_controller.dart';
import 'package:vidstar_app/service/NotificationService.dart';
import 'package:vidstar_app/views/screens/auth/login_screen.dart';
import 'package:vidstar_app/views/screens/auth/signup_screen.dart';

import 'controllers/chat_controller.dart';
import 'controllers/video_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Đăng ký AuthController
  Get.put(AuthController());

  // Đăng ký NotificationService
  final notificationService = NotificationService(FirebaseFirestore.instance);
  Get.put(notificationService);

  // Đăng ký ChatController với NotificationService
  // Get.put(ChatController(notificationService));
  // final _messaging = FirebaseMessaging.instance;
  // await _messaging.requestPermission();
  // final token = await _messaging.getToken();
  // print('TokenFCM: $token');

  // final SentimentAnalysis commentApi = SentimentAnalysis('http://127.0.0.1:8000/predict_sentiment');
  // double sentiment = await commentApi.checkComment("bạn Đức đẹp trai quá");
  // print('Sentiment: $sentiment');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VidStar',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      home: LoginScreen(),
    );
  }
}
