import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import '../../../controllers/chat_controller.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';

// class ChatScreen extends StatefulWidget {
//   final User user; // Thêm biến để nhận người dùng
//
//   ChatScreen({required this.user}); // Constructor nhận người dùng
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController(); // Bộ điều khiển cho ô nhập tin nhắn
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF222222), // Màu nền tối
//       appBar: AppBar(
//         backgroundColor: Color(0xFF222222),
//         elevation: 0,
//         leadingWidth: 250, // Tăng giá trị leadingWidth để tránh tràn
//         leading: Row(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: CircleAvatar(
//                 backgroundImage: NetworkImage(widget.user.profilePhoto), // Hiển thị ảnh đại diện người dùng
//               ),
//             ),
//             Expanded(
//               child: Text(
//                 widget.user.name, // Hiển thị tên người dùng
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search, color: Colors.white),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.all(16.0),
//               children: [
//                 Center(
//                   child: Text(
//                     '3 FEB 12:00',
//                     style: TextStyle(color: Colors.grey, fontSize: 12),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 _buildChatBubble(
//                   'I commented on Figma, I want to add some fancy icons. Do you have any icon set?',
//                   true,
//                   '00:12',
//                 ),
//                 _buildChatBubble(
//                   'I am in a process of designing some. When do you need them?',
//                   false,
//                   '00:12',
//                 ),
//                 _buildChatBubble(
//                   'Next month?',
//                   true,
//                   '00:13',
//                 ),
//                 _buildChatBubble(
//                   'I am almost finished. Please give me your email, I will ZIP them and send you as soon as I’m finished.',
//                   false,
//                   '00:45',
//                 ),
//                 _buildChatBubble(
//                   'Hello',
//                   true,
//                   '00:45',
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController, // Gán bộ điều khiển cho ô nhập tin nhắn
//                     decoration: InputDecoration(
//                       hintText: 'Message',
//                       hintStyle: TextStyle(color: Colors.white70),
//                       filled: true,
//                       fillColor: Color(0xFF2C3342),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 CircleAvatar(
//                   backgroundColor: Colors.red[400],
//                   child: IconButton(
//                     icon: Icon(Icons.send, color: Colors.white),
//                     onPressed: () {
//                       // Xử lý gửi tin nhắn
//                       String message = _messageController.text;
//                       if (message.isNotEmpty) {
//                         // Gửi tin nhắn và làm sạch ô nhập
//                         print("Sent: $message");
//                         _messageController.clear();
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildChatBubble(String text, bool isSender, String time, {bool isEmail = false}) {
//     return Align(
//       alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
//       child: Column(
//         crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsets.all(12),
//             margin: EdgeInsets.symmetric(vertical: 5),
//             decoration: BoxDecoration(
//               color: isSender ? Color(0xFF7A8194) : Color(0xFF2C3342),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//                 bottomLeft: isSender ? Radius.circular(15) : Radius.circular(0),
//                 bottomRight: isSender ? Radius.circular(0) : Radius.circular(15),
//               ),
//             ),
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: isEmail ? Colors.blueAccent : Colors.white,
//                 decoration: isEmail ? TextDecoration.underline : TextDecoration.none,
//               ),
//             ),
//           ),
//           SizedBox(height: 5),
//           Text(
//             time,
//             style: TextStyle(color: Colors.grey, fontSize: 10),
//           ),
//         ],
//       ),
//     );
//   }
// }
class ChatScreen extends StatefulWidget {
  final User user; // Người dùng nhận tin

  ChatScreen({required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController _messageController = TextEditingController();

  late String chatId; // ID của cuộc trò chuyện

  @override
  void initState() {
    super.initState();
    chatId = widget.user.uid.compareTo(authController.user.uid) < 0
        ? '${widget.user.uid}_${authController.user.uid}'
        : '${authController.user.uid}_${widget.user.uid}';

    chatController.fetchMessages(chatId); // Tải tin nhắn của cuộc trò chuyện
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      appBar: AppBar(
        backgroundColor: Color(0xFF222222),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Quay lại màn hình trước
          },
        ),
        leadingWidth: 20, // Chiều rộng của leading
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.user.profilePhoto),
              ),
            ),
            Expanded(
              child: Text(
                widget.user.name,
                style: TextStyle(color: Colors.white, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: chatController.fetchMessages(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages yet', style: TextStyle(color: Colors.white70)));
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final Message message = messages[index];
                    return _buildChatBubble(
                      message.message,
                      message.senderId == authController.user.uid,
                      DateFormat.jm().format(message.timestamp),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Color(0xFF2C3342),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.multiline, // Cho phép nhập nhiều dòng
                    maxLines: null, // Cho phép không giới hạn dòng
                    minLines: 1, // Số dòng tối thiểu
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.red[400],
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      String message = _messageController.text;
                      if (message.isNotEmpty) {
                        chatController.sendMessage(
                          chatId,
                          message,
                          authController.user.uid, // ID người gửi
                          widget.user.uid, // ID người nhận
                        );
                        _messageController.clear(); // Xóa nội dung ô nhập
                      }
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

  Widget _buildChatBubble(String text, bool isSender, String time) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: isSender ? Color(0xFF7A8194) : Color(0xFF2C3342),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: isSender ? Radius.circular(15) : Radius.circular(0),
                bottomRight: isSender ? Radius.circular(0) : Radius.circular(15),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(height: 5),
          Text(
            time,
            style: TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
