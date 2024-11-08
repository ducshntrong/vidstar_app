import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/views/widgets/custom_icon.dart';

import '../../controllers/auth_controller.dart';
import '../../service/NotificationService.dart';
import '../../service/UserStatusService.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  int pageIdx = 0;
  int newNotificationCount = 0; // Biến để lưu số lượng thông báo mới
  late UserStatusService userStatusService;


  @override
  void initState() {
    super.initState();
    userStatusService = UserStatusService(firestore, Get.find<AuthController>().user.uid);
    WidgetsBinding.instance.addObserver(this);
    userStatusService.setOnline();
    // Lấy token FCM và thêm vào Firestore
    _addFcmToken();
    _listenForNotifications();
  }

  Future<void> _addFcmToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    String uid = authController.user.uid;

    // Lấy token FCM
    String? token = await messaging.getToken();
    DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

    if (!userDoc.exists) {
      // Tài liệu chưa tồn tại, tạo mới
      await firestore.collection('users').doc(uid).set({
        'fcmToken': token,
      });
      print('Tài liệu người dùng đã được tạo và token FCM đã được thêm: $token');
    } else {
      // Nếu tài liệu tồn tại, kiểm tra trường fcmToken
      var data = userDoc.data() as Map<String, dynamic>?; // Ép kiểu về Map<String, dynamic>
      if (data != null && data['fcmToken'] != null) {
        print('Token FCM đã tồn tại: ${data['fcmToken']}');
      } else {
        // Nếu fcmToken không tồn tại, thêm nó
        await firestore.collection('users').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        print('Token FCM đã được thêm thành công: $token');
      }
    }
  }

  @override
  void dispose() {
    userStatusService.setOffline(); // Đặt trạng thái là offline khi thoát
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      userStatusService.setOffline(); // Cập nhật trạng thái offline khi app bị tạm dừng
    } else if (state == AppLifecycleState.resumed) {
      userStatusService.setOnline(); // Cập nhật trạng thái online khi app được mở lại
    }
  }

  void _listenForNotifications() {
    final notificationService = Get.find<NotificationService>();
    final recipientId = Get.find<AuthController>().user.uid;

    notificationService.getNotificationsStream(recipientId).listen((notifications) {
      setState(() {
        // Ktra số lượng thông báo mới
        newNotificationCount = notifications.where((notification) => !notification.isRead).length;
      });
    });
  }

  void _onInboxTapped() {
    setState(() {
      // Khi click vào tab Inbox, đặt số lượng thông báo mới về 0
      newNotificationCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIdx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8.0,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          onTap: (idx) {
            setState(() {
              pageIdx = idx;

              // Khi click vào tab Inbox, gọi hàm xử lý
              if (idx == 3) {
                _onInboxTapped();
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: buttonColor,
          unselectedItemColor: Colors.white70,
          currentIndex: pageIdx,
          items: [
            BottomNavigationBarItem(
              icon: Icon(pageIdx == 0 ? Icons.home : Icons.home_outlined, size: 25),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(pageIdx == 1 ? Icons.search : Icons.search_outlined, size: 25),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: CustomIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(
                    pageIdx == 3 ? Icons.indeterminate_check_box : Icons.indeterminate_check_box_outlined,
                    size: 25,
                  ),
                  if (newNotificationCount > 0)
                    Positioned(
                      right: newNotificationCount > 9 ? 0 : 0,
                      top: newNotificationCount > 9 ? -1 : -4, // Điều chỉnh vị trí
                      child: Container(
                        padding: newNotificationCount > 9
                            ? EdgeInsets.all(1)
                            : EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            newNotificationCount > 99 ? '99+' : newNotificationCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: newNotificationCount > 9 ? 8 : 9,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(pageIdx == 4 ? Icons.person : Icons.person_outline, size: 25),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}