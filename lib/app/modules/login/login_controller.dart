import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teh_kota/app/widgets/page_controller.dart';

import '../../utils/utils.dart';

class LoginController extends GetxController {
  var emailC = TextEditingController();
  var passC = TextEditingController();

  var dataAdmin = {}.obs;
  @override
  void onInit() {
    super.onInit();
    getDataUserAdmin();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    emailC.clear();
    passC.clear();
  }

  void getDataUserAdmin() async {
    try {
      await Utils.firestore?.collection("admin").get().then((event) {
        for (var doc in event.docs) {
          print("${doc.id} => ${doc.data()}");
          if (doc.id.contains("default")) {
            dataAdmin.value = doc.data();
          }
        }
      }, onError: (e) {
        throw (e);
      });
    } catch (e) {
      log("EROR: $e");
      dataAdmin.value = {};
    }
  }

  void tapLoginButton() async {
    if (emailC.text.isEmpty || passC.text.isEmpty) {}
    if (emailC.text == dataAdmin["email"] && passC.text == dataAdmin["password"]) {
      print("pass");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isLoggedIn', true);
      Utils.isAdmin.value = true;
      Utils.isLoggedIn.value = true;
      Get.offAll(() => const PageViewAdminController());
    }
  }
}
