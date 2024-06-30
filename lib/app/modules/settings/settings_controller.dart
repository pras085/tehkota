import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/db/databse_helper.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/utils.dart';

import '../../widgets/page_controller.dart';

class SettingsController extends GetxController {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  var settings = <Map<String, dynamic>>[].obs;
  var textFieldC = <TextEditingController>[];
  var isEdit = false.obs;

  @override
  void onInit() {
    super.onInit();
    getSettingOnLocal();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
    for (var controller in textFieldC) {
      controller.dispose();
    }
  }

  void getSettingOnLocal() async {
    // Menampilkan semua baris dari tabel 'setting'
    settings.value = await dbHelper.queryAllRows('setting');
    if (settings.isNotEmpty) {
      textFieldC.clear(); // Bersihkan textFieldC sebelum mengisinya kembali
      print(settings.value);
      for (var setting in settings) {
        TextEditingController gajiController = TextEditingController(text: setting['gaji'].toString());
        TextEditingController gaji6JamController = TextEditingController(text: setting['gaji_6_jam'].toString());
        TextEditingController gaji12JamController = TextEditingController(text: setting['gaji_12_jam'].toString());
        TextEditingController lemburController = TextEditingController(text: setting['lembur'].toString());
        TextEditingController potonganController = TextEditingController(text: setting['potongan'].toString());

        // Tambahkan listener untuk setiap controller
        gajiController.addListener(() {
          // Handle perubahan teks pada gajiController
          print('Gaji: ${gajiController.text}');
          isEdit.value = true;
        });
        gaji6JamController.addListener(() {
          // Handle perubahan teks pada gajiController
          print('Gaji: ${gaji6JamController.text}');
          isEdit.value = true;
        });
        gaji12JamController.addListener(() {
          // Handle perubahan teks pada gajiController
          print('Gaji: ${gaji12JamController.text}');
          isEdit.value = true;
        });
        lemburController.addListener(() {
          // Handle perubahan teks pada lemburController
          print('Lembur: ${lemburController.text}');
          isEdit.value = true;
        });
        potonganController.addListener(() {
          // Handle perubahan teks pada potonganController
          print('Potongan: ${potonganController.text}');
          isEdit.value = true;
        });

        textFieldC.addAll([
          gajiController,
          gaji6JamController,
          gaji12JamController,
          lemburController,
          potonganController,
        ]);
      }
    } else {
      await dbHelper.createTable(
        'setting',
        {
          "settingID": "TEXT PRIMARY KEY",
          "gaji": "TEXT NOT NULL",
          "gaji_6_jam": "TEXT NOT NULL",
          "gaji_12_jam": "TEXT NOT NULL",
          "lembur": "TEXT NOT NULL",
          "potongan": "TEXT NOT NULL",
        },
      );
      await dbHelper.insertDynamic(
        'setting',
        {
          "settingID": "0",
          "gaji": "6600",
          "gaji_6_jam": "40000",
          "gaji_12_jam": "80000",
          "lembur": "2000",
          "potongan": "3300",
        },
      );
    }
  }

  void updateOnLocal() async {
    await dbHelper
        .updateDynamic(
            "setting",
            {
              "gaji": textFieldC[0].text,
              "gaji_6_jam": textFieldC[1].text,
              "gaji_12_jam": textFieldC[2].text,
              "lembur": textFieldC[3].text,
              "potongan": textFieldC[4].text,
            },
            "settingID = ?",
            ["0"])
        .then((value) {
      Get.offAll(() => const PageViewUserController());
      Utils.showToast(TypeToast.success, "Berhasil update setting!");
    }).onError((error, stackTrace) {
      Get.offAll(() => const PageViewUserController());
      Utils.showToast(TypeToast.error, "Terjadi kesalahan !");
    });
  }
}
