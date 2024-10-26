import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/views/widgets/custom_icon.dart';

import '../../controllers/auth_controller.dart';
import '../../service/NotificationService.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   int pageIdx = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: pages[pageIdx],
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           color: backgroundColor,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8.0,
//               offset: Offset(0, -2),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           onTap: (idx) {
//             setState(() {
//               pageIdx = idx;
//             });
//           },
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.red,
//           unselectedItemColor: Colors.white70,
//           currentIndex: pageIdx,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home, size: 30),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.search, size: 30),
//               label: 'Search',
//             ),
//             BottomNavigationBarItem(
//               icon: CustomIcon(),
//               label: '',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.indeterminate_check_box, size: 30),
//               label: 'Inbox',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person, size: 30),
//               label: 'Profile',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int pageIdx = 0;
  int newNotificationCount = 0; // Biến để lưu số lượng thông báo mới

  @override
  void initState() {
    super.initState();
    _listenForNotifications();
  }

  void _listenForNotifications() {
    final notificationService = Get.find<NotificationService>();
    final recipientId = Get.find<AuthController>().user.uid;

    notificationService.getNotificationsStream(recipientId).listen((notifications) {
      setState(() {
        // Kiểm tra số lượng thông báo mới
        newNotificationCount = notifications.where((notification) => !notification.isRead).length;
      });
    });
  }

  void _onInboxTapped() {
    setState(() {
      // Khi nhấn vào tab Inbox, đặt số lượng thông báo mới về 0
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

              // Khi nhấn vào tab Inbox, gọi hàm xử lý
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
                            ? EdgeInsets.all(1) // Padding nhỏ hơn
                            : EdgeInsets.all(2.5), // Padding lớn hơn cho số nhỏ
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            newNotificationCount > 99 ? '99+' : newNotificationCount.toString(), // Hiện số lượng
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: newNotificationCount > 9 ? 8 : 9, // Thay đổi kích thước chữ
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