import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

import '../../../constants.dart';
import '../../../controllers/chat_controller.dart';
import '../../../models/message.dart';
import '../../../models/user.dart';

class ChatScreen extends StatefulWidget {
  final User user;

  ChatScreen({required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String chatId;
  bool _isSendButtonEnabled = false; // Biến trạng thái để ktra nút gửi

  @override
  void initState() {
    super.initState();
    chatId = widget.user.uid.compareTo(authController.user.uid) < 0
        ? '${widget.user.uid}_${authController.user.uid}'
        : '${authController.user.uid}_${widget.user.uid}';

    chatController.fetchMessages(chatId);
    markMessagesAsSeen();

    // Lắng nghe sự thay đổi trong ô nhập tin nhắn
    _messageController.addListener(() {
      setState(() {
        _isSendButtonEnabled = _messageController.text.isNotEmpty;
      });
    });
  }

  void markMessagesAsSeen() async {
    await chatController.markMessagesAsSeen(chatId, authController.user.uid);
  }

  @override
  void dispose() {
    // Hủy lắng nghe khi k còn dùng
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222222),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.profilePhoto),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.user.name,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                      StreamBuilder<User>(
                        stream: chatController.getUserStream(widget.user.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final user = snapshot.data!;
                            return Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: user.isOnline ? Colors.green : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  user.isOnline
                                      ? 'Online'
                                      : 'Offline for ${_getOfflineDuration(user.lastSeen)}',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            );
                          }
                          return Text('Status unavailable', style: TextStyle(color: Colors.white, fontSize: 12));
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: chatController.fetchMessages(chatId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No messages yet', style: TextStyle(color: Colors.white70)));
                  }
                  final messages = snapshot.data!;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(5.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final Message message = messages[index];
                      return _buildChatBubble(
                        message.message,
                        message.senderId == authController.user.uid,
                        DateFormat.jm().format(message.timestamp),
                        message.seen,
                        widget.user.profilePhoto
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
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      minLines: 1,
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: _isSendButtonEnabled ? Colors.red[400] : Colors.grey,
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: _isSendButtonEnabled
                          ? () {
                        String message = _messageController.text;
                        if (message.isNotEmpty) {
                          chatController.sendMessage(
                            chatId,
                            message,
                            authController.user.uid,
                            widget.user.uid,
                          );
                          _messageController.clear();
                        }
                      }
                          : null, // Vô hiệu hóa nút khi không có nội dung
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isSender, String time, bool isSeen, String? avatarUrl) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender && avatarUrl != null) // Hiển thị avatar nếu là người nhận
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 29),
              child: CircleAvatar(
                radius: 15, // Kích thước của avatar
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
          Column(
            crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 250),
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
                  softWrap: true, // Cho phép xuống dòng
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
                  SizedBox(width: 5),
                  if (isSender && isSeen)
                    const Icon(
                      Icons.check,
                      size: 12,
                      color: Colors.green,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hàm tính toán thời gian offline
  String _getOfflineDuration(DateTime? lastSeen) {
    if (lastSeen == null) {
      return 'unknown';
    }

    final duration = DateTime.now().difference(lastSeen);
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} seconds ago';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes ago';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours ago';
    } else {
      return '${(duration.inDays)} days ago';
    }
  }
}



