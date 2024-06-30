import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/db/databse_helper.dart';

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
    // await dbHelper.deleteAllRows('setting');
    // await dbHelper.createTable(
    //   'setting',
    //   {
    //     "settingID" : "TEXT PRIMARY KEY",
    //     "gaji": "TEXT NOT NULL",
    //     "gaji_6_jam": "TEXT NOT NULL",
    //     "gaji_12_jam": "TEXT NOT NULL",
    //     "lembur": "TEXT NOT NULL",
    //     "potongan": "TEXT NOT NULL",
    //   },
    // );
    // await dbHelper.insertDynamic(
    //   'setting',
    //   {
    //     "settingID" : "0",
    //     "gaji": "6600",
    //     "gaji_6_jam": "40000",
    //     "gaji_12_jam": "80000",
    //     "lembur": "2000",
    //     "potongan": "3300",
    //   },
    // );
    // Menampilkan semua baris dari tabel 'setting'
    settings.value = await dbHelper.queryAllRows('setting');
    textFieldC.clear(); // Bersihkan textFieldC sebelum mengisinya kembali
    if (settings.isNotEmpty) {
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
    }
  }

  void updateOnLocal() async {
    await dbHelper.insertDynamic("setting", {
      "gaji_6_jam": textFieldC[1].text.toString(),
      "gaji_12_jam": textFieldC[2].text.toString()
    });
  }
}
