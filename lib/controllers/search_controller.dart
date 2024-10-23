import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:vidstar_app/constants.dart';
import 'package:vidstar_app/models/user.dart';

import '../models/video.dart';

class SearchControler extends GetxController {
  final Rx<List<User>> _searchedUsers = Rx<List<User>>([]);
  final Rx<List<Video>> _searchedVideos = Rx<List<Video>>([]);

  List<User> get searchedUsers => _searchedUsers.value;
  List<Video> get searchedVideos => _searchedVideos.value;

  @override
  void onInit() {
    super.onInit();
    _getAllVideos(); // Lấy tất cả video khi khởi tạo
  }

  void _getAllVideos() async {
    // Lấy tất cả video từ Firestore
    _searchedVideos.bindStream(
      firestore.collection('videos').snapshots().map((QuerySnapshot query) {
        List<Video> retVal = [];
        for (var elem in query.docs) {
          retVal.add(Video.fromSnap(elem));
        }
        // Sắp xếp video theo lượt like từ cao đến thấp
        retVal.sort((a, b) => b.likes.length.compareTo(a.likes.length));

        return retVal;
      }),
    );
  }

  searchUser(String typedUser) async {
    if (typedUser.isEmpty) {
      // Nếu không có gì được nhập, gọi lại hàm để lấy tất cả video
      _getAllVideos();
      _searchedUsers.value = []; // Reset danh sách người dùng
      return;
    }

    // Chuyển đổi typedUser thành chữ thường để tìm kiếm không phân biệt
    String lowerCaseTypedUser = typedUser.toLowerCase();

    // Tìm kiếm người dùng
    _searchedUsers.bindStream(
      firestore.collection('users')
          .snapshots()
          .map((QuerySnapshot query) {
        List<User> retVal = [];
        for (var elem in query.docs) {
          if (elem['name'].toLowerCase().contains(lowerCaseTypedUser)) {
            retVal.add(User.fromSnap(elem));
          }
        }
        return retVal;
      }),
    );

    // Tìm kiếm video dựa trên caption và username
    _searchedVideos.bindStream(
      firestore.collection('videos')
          .snapshots()
          .map((QuerySnapshot query) {
        List<Video> retVal = [];
        for (var elem in query.docs) {
          // Kiểm tra cả caption và username
          if (elem['caption'].toLowerCase().contains(lowerCaseTypedUser) ||
              elem['username'].toLowerCase().contains(lowerCaseTypedUser)) {
            retVal.add(Video.fromSnap(elem));
          }
        }
        return retVal;
      }),
    );
  }
}
