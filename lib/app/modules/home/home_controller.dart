import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';

class HomeController extends GetxController {
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var listDataPresence = <Map<String, dynamic>>[].obs;
  PageController pageController =
      PageController(initialPage: 0, keepPage: true);
  var scrollC = ScrollController();
  Rxn<Map<String, dynamic>> officeHoursFromDb = Rxn<Map<String, dynamic>>();
  var isLemburPresence = false.obs;

  @override
  void onInit() async {
    super.onInit();
    await getDataFromApi();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    isLemburPresence.value = false;
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
    var res = await firestore.getOfficeHours();
    if (res.exists) {
      officeHoursFromDb.value = res.data();
      officeHoursFromDb.refresh();
    }

    var resp = await firestore.getAllPresence();
    if (resp != null) {
      listDataPresence.value = resp;
      // log("LIST PRESENCE : $resp");
    }

    listDataPresence.refresh();
    // print('PRESENCE : $listDataPresence');
  }
}
