import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/db/databse_helper.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/utils.dart';

import '../../widgets/page_controller.dart';

class SettingsController extends GetxController {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  var valueDate = <DateTime>[].obs;
  var valueDateLembur = <String, dynamic>{}.obs;
  var isEdit = false.obs;
  var firestore = CloudFirestoreService();

  var emailC = TextEditingController();
  var passC = TextEditingController();
  var passConfirmC = TextEditingController();
  var dataAdmin = {}.obs;
  var isVerifMode = true.obs;

  @override
  void onInit() async {
    super.onInit();
    getSettingOnFirestore();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    emailC.clear();
    passC.clear();
    passConfirmC.clear();
    super.onClose();
  }

  void updateOnFirestore() async {
    var body = {
      "pagi": {
        "jamMasuk": Utils.customShowJustTime(valueDate.value[0]),
        "jamKeluar": Utils.customShowJustTime(valueDate.value[1]),
      },
      "sore": {
        "jamMasuk": Utils.customShowJustTime(valueDate.value[2]),
        "jamKeluar": Utils.customShowJustTime(valueDate.value[3]),
      },
    };
    await firestore.updateOfficeHours(body);
  }

  void remappingData(Map<String, dynamic> input) {
    input.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        remappingData(value);
      } else if (value is Timestamp) {
        input[key] = Utils.customDate(value.toDate().hour, value.toDate().minute);
      }
    });
  }

  void getSettingOnFirestore() async {
    try {
      await Utils.firestore?.collection("admin").get().then((event) {
        for (var doc in event.docs) {
          if (doc.id.contains("default")) {
            dataAdmin.value = doc.data();
          }
          if (doc.id.contains("lembur")) {
            var data = doc.data();
            remappingData(data);
            valueDateLembur.value.addAll(data);
            valueDateLembur.refresh();
            print("$valueDateLembur");
          }
          if (doc.id.contains("jam")) {
            var data = doc.data();

            // Shift Pagi
            valueDate.value.add(Utils.customDate(int.parse((data['pagi']['jamMasuk'] ?? "").toString().split(":").first), int.parse((data['pagi']['jamMasuk'] ?? "").toString().split(":").last))); // Jam Masuk
            valueDate.value.add(Utils.customDate(int.parse((data['pagi']['jamKeluar'] ?? "").toString().split(":").first), int.parse((data['pagi']['jamKeluar'] ?? "").toString().split(":").last))); // Jam Masuk

            // Shift Siang
            valueDate.value.add(Utils.customDate(int.parse((data['sore']['jamMasuk'] ?? "").toString().split(":").first), int.parse((data['sore']['jamMasuk'] ?? "").toString().split(":").last))); // Jam Masuk
            valueDate.value.add(Utils.customDate(int.parse((data['sore']['jamKeluar'] ?? "").toString().split(":").first), int.parse((data['sore']['jamKeluar'] ?? "").toString().split(":").last))); // Jam Masuk
          }
        }
      }, onError: (e) {
        throw (e);
      });
    } catch (e) {}
    dataAdmin.refresh();
    valueDate.refresh();
    // print(dataAdmin.value);
    // print(valueDate.value);
  }

  tapLoginButton() async {
    String messageError = "";
    if (isVerifMode.value) {
      if (emailC.text != dataAdmin.value["email"]) {
        messageError = "Email tidak ditemukan";
      } else if (passC.text != dataAdmin.value["password"]) {
        messageError = "Password salah";
      } else {
        isVerifMode.value = false;
        emailC.clear();
        passC.clear();
        passConfirmC.clear();
      }
    } else {
      if (emailC.text.isEmpty) {
        messageError = "Email harus diisi";
      } else if (passC.text.isEmpty) {
        messageError = "Password harus diisi";
      } else if (passConfirmC.text.isEmpty) {
        messageError = "Password Ulang harus diisi";
      } else if (passC.text != passConfirmC.text) {
        messageError = "Password tidak sama";
      } else {
        var res = await Utils.showAlertDialog(Get.context!, "Yakin ingin mengubah akun admin ? ");
        if (res) {
          Get.back();
          firestore.updateAdmin(emailC.text, passC.text);
          Utils.showToast(TypeToast.success, "Berhasil update admin");
        }
      }
    }
    if (messageError.isNotEmpty) {
      return Utils.showToast(TypeToast.error, messageError);
    }
  }
}
