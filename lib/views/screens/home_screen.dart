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
    // Lắng nghe sự kiện khi token FCM thay đổi
    // FirebaseMessaging.onTokenRefresh.listen((newToken) async {
    //   // Cập nhật token mới vào Firestore
    //   String uid = authController.user.uid; // Lấy UID của người dùng
    //   await firestore.collection('users').doc(uid).update({
    //     'fcmToken': newToken,
    //   });
    // });

    userStatusService = UserStatusService(firestore, Get.find<AuthController>().user.uid);
    WidgetsBinding.instance.addObserver(this);
    userStatusService.setOnline();
    _listenForNotifications();
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
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.white70,
          currentIndex: pageIdx,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 25),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search, size: 25),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: CustomIcon(),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(Icons.indeterminate_check_box, size: 25),
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
              icon: Icon(Icons.person, size: 25),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}