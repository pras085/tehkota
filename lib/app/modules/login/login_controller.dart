import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/utils.dart';

class LoginController extends GetxController {
  var emailC = TextEditingController();
  var passC = TextEditingController();

  var dataAdmin = {}; 
  var listDataPresence = [
    {
      "id": "2",
      "name": "Rizka dfdsd",
      "tanggal": "04/05/2024",
      "presensi_masuk": "09.00",
      // "presensi_keluar": "",
      "lembur": "1.20",
      "status": "0",
    },
  ];

  @override
  void onInit() {
    getDataUserAdmin();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void getDataUserAdmin() async {
    try {
      await Utils.firestore?.collection("admin").get().then((event) {
        for (var doc in event.docs) {
          print("${doc.id} => ${doc.data()}");
          if (doc.id.contains("default")) {
            dataAdmin = doc.data();
          }
        }
      }, onError: (e) {
        throw (e);
      });
    } catch (e) {
      log("EROR: $e");
    }
  }

  void tapLoginButton() {
    if(emailC.text.isEmpty || passC.text.isEmpty){

    }
    if (emailC.text == dataAdmin["email"] && passC.text == dataAdmin["password"]){
      print("pass");
    }

  }
}
