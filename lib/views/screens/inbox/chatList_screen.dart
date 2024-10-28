import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vidstar_app/controllers/chat_controller.dart';
import 'package:vidstar_app/models/user.dart';
import '../../../constants.dart';
import '../../../models/chat.dart';
import '../../../models/message.dart';
import '../../../service/NotificationService.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final NotificationService notificationService = Get.find<NotificationService>();
  late final ChatController chatController;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    chatController = ChatController(notificationService);
    chatController.fetchUsers();
    chatController.fetchUserChats();
    chatController.listenForChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                chatController.searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                contentPadding: EdgeInsets.symmetric(vertical: 15),
                filled: true,
                fillColor: Colors.black38,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            child: Obx(() {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chatController.users.length,
                itemBuilder: (context, index) {
                  final User user = chatController.users[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(user: user),
                        ),
                      );
                    },
                    child: _buildStoryAvatar(user.name, user.profilePhoto, user.isOnline),
                  );
                },
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              if (chatController.chats.isEmpty) {
                return Center(child: Text("No chats available."));
              }
              return ListView.builder(
                itemCount: chatController.chats.length,
                itemBuilder: (context, index) {
                  final Chat chat = chatController.chats[index];
                  //sd firstWhere để tìm kiếm trong ds chatController.users
                  final userId = chat.users.firstWhere((id) => id != authController.user.uid, orElse: () => '');

                  if (userId.isNotEmpty) {
                    return StreamBuilder<User?>(
                      stream: chatController.getUserStream(userId), // Lấy stream của user
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }
                        if (!snapshot.hasData) {
                          return SizedBox.shrink();
                        }

                        final user = snapshot.data!;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(user: user),
                              ),
                            );
                          },
                          child: _buildChatTile(
                            user.name,
                            chat.lastMessage,
                            user.profilePhoto,
                            DateFormat.jm().format(chat.lastTimestamp.toDate()),
                            chat.lastMessageSenderId,
                            chat.isRead,
                            user.isOnline,
                          ),
                        );
                      },
                    );
                  }
                  return SizedBox.shrink();
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryAvatar(String name, String profilePhoto, bool isOnline) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(profilePhoto),
              ),
              if (isOnline)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8),
          Text(name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatTile(
      String name,
      String message,
      String profilePhoto,
      String time,
      String lastMessageSenderId,
      bool isRead,
      bool isOnline) {
    // Kiểm tra xem tin nhắn là của người gửi hay người nhận
    String displayMessage = lastMessageSenderId == authController.user.uid
        ? 'You: $message'
        : message;

    // Xác định màu sắc cho subtitle dựa trên trạng thái isRead và người gửi
    Color subtitleColor = (lastMessageSenderId != authController.user.uid && !isRead)
        ? Colors.white
        : Colors.grey;

    // Xác định kiểu chữ cho subtitle
    FontWeight subtitleFontWeight = lastMessageSenderId == authController.user.uid
        ? FontWeight.normal
        : (isRead ? FontWeight.normal : FontWeight.bold);

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profilePhoto),
          ),
          if (isOnline)
            const Positioned(
              bottom: 2,
              right: 5,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        _truncateMessage(displayMessage, 20),
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: subtitleFontWeight,
          fontSize: 14,
          color: subtitleColor,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
          // Hiển thị dấu chấm đỏ nếu tin nhắn chưa đọc
          if (lastMessageSenderId != authController.user.uid && !isRead)
            Container(
              margin: const EdgeInsets.only(top: 4), // Khoảng cách giữa thời gian và dấu chấm
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          // Chỉ hiển thị biểu tượng hoặc ảnh đại diện nếu tin nhắn là của mình
          if (lastMessageSenderId != authController.user.uid) ...[
            SizedBox.shrink(),
          ] else ...[
            if (isRead) ...[
              SizedBox(height: 4),
              CircleAvatar(
                radius: 8,
                backgroundImage: NetworkImage(profilePhoto),
              ),
            ] else ...[
              SizedBox(height: 4),
              Icon(Icons.check_circle_outline, size: 15),
            ],
          ],
        ],
      ),
    );
  }

// Hàm để cắt ngắn tin nhắn
  String _truncateMessage(String message, int maxLength) {
    if (message.length > maxLength) {
      return '${message.substring(0, maxLength)}...';
    }
    return message;
  }
}
