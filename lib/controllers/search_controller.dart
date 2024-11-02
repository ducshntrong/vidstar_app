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
    _searchedVideos.bindStream(
      firestore.collection('videos').snapshots().map((QuerySnapshot query) {
        List<Video> retVal = query.docs.map((elem) => Video.fromSnap(elem)).toList();
        retVal.sort((a, b) => b.likes.length.compareTo(a.likes.length)); // Sắp xếp video theo lượt like
        return retVal;
      }),
    );
  }

  void searchUser(String typedUser) async {
    if (typedUser.isEmpty) {
      _getAllVideos(); // Gọi lại hàm để lấy tất cả video
      _searchedUsers.value = []; // Reset danh sách user
      return;
    }

    String lowerCaseTypedUser = typedUser.toLowerCase();

    // Tìm kiếm user
    _searchedUsers.bindStream(
      firestore.collection('users').snapshots().map((QuerySnapshot query) {
        return query.docs
            .where((elem) => elem['name'].toLowerCase().contains(lowerCaseTypedUser))
            .map((elem) => User.fromSnap(elem))
            .toList();
      }),
    );

    // Tìm kiếm video dựa trên caption và username
    _searchedVideos.bindStream(
      firestore.collection('videos').snapshots().map((QuerySnapshot query) {
        return query.docs.where((elem) {
          return elem['caption'].toLowerCase().contains(lowerCaseTypedUser) ||
              elem['username'].toLowerCase().contains(lowerCaseTypedUser);
        }).map((elem) => Video.fromSnap(elem)).toList();
      }),
    );
  }

  void resetSearch() {
    // Xóa danh sách user và video đã tìm kiếm
    _searchedUsers.value = [];
    _searchedVideos.value = [];
    _getAllVideos();
  }
}
