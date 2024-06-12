import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';

class HomeController extends GetxController {
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var listDataPresence = <Map<String, dynamic>>[].obs;
  PageController pageController = PageController(initialPage: 0, keepPage: true);
  var scrollC = ScrollController();

  @override
  void onInit() {
    super.onInit();
    getDataFromApi();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getDataFromApi() async {
    listDataPresence.clear();
    // add dummy
    // listDataPresence.value.add(
    //   {
    //     "userName": "Rizka dfdsd",
    //     "shift": "0",
    //     "login_presence": "2024-05-07 16:18:36.968159",
    //     // "logout_presence": "",
    //     // "lembur": "1.20",
    //     // "status": "0",
    //   },
    // );
    List<Map<String, dynamic>>? listPresenceApi = await firestore.getAllPresence();
    if (listPresenceApi != null) {
      // List<Map<String, dynamic>> filteredData = listPresenceApi.where((map) => map.isNotEmpty && map.keys.first.startsWith("EMP")).toList();
      List<Map<String, dynamic>> filteredData = [];
      // Memeriksa setiap map untuk kunci yang memenuhi kondisi dan map tidak kosong
      for (var map in listPresenceApi) {
        map.forEach((key, value) {
          if (key.startsWith('EMP')) {
            filteredData.add(value);
          }
        });
      }
      listDataPresence.addAll(filteredData);
    }
    listDataPresence.refresh();
    // print('PRESENCE : $listDataPresence');
  }
}
