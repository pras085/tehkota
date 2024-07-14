import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/db/databse_helper.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/utils.dart';

import '../../widgets/page_controller.dart';

class SettingsController extends GetxController {
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  var valueDate = <DateTime>[].obs;
  var isEdit = false.obs;
  var firestore = CloudFirestoreService();

  var emailC = TextEditingController();
  var passC = TextEditingController();
  var passConfirmC = TextEditingController();
  var dataAdmin = {}.obs;
  var isVerifMode = true.obs;

  @override
  void onInit() {
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

  Future<void> getDataUserAdmin() async {
    try {
      await Utils.firestore?.collection("admin").get().then((event) {
        for (var doc in event.docs) {
          if (doc.id.contains("default")) {
            dataAdmin.value = doc.data();
            print(dataAdmin.value);
          }
        }
      }, onError: (e) {
        throw (e);
      });
    } catch (e) {
      dataAdmin.value = {};
    }
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

  void getSettingOnFirestore() async {
    await getDataUserAdmin();
    var res = await firestore.getOfficeHours();
    if (res.exists) {
      print(res.data());
      var data = res.data();

      // Shift Pagi
      valueDate.value.add(Utils.customDate(int.parse((data?['pagi']['jamMasuk'] ?? "").toString().split(":").first), int.parse((data?['pagi']['jamMasuk'] ?? "").toString().split(":").last))); // Jam Masuk
      valueDate.value.add(Utils.customDate(int.parse((data?['pagi']['jamKeluar'] ?? "").toString().split(":").first), int.parse((data?['pagi']['jamKeluar'] ?? "").toString().split(":").last))); // Jam Masuk

      // Shift Siang
      valueDate.value.add(Utils.customDate(int.parse((data?['sore']['jamMasuk'] ?? "").toString().split(":").first), int.parse((data?['sore']['jamMasuk'] ?? "").toString().split(":").last))); // Jam Masuk
      valueDate.value.add(Utils.customDate(int.parse((data?['sore']['jamKeluar'] ?? "").toString().split(":").first), int.parse((data?['sore']['jamKeluar'] ?? "").toString().split(":").last))); // Jam Masuk
      valueDate.refresh();
    }
    print(valueDate.value);

    // Menampilkan semua baris dari tabel 'setting'
    // settings.value = await dbHelper.queryAllRows('setting');
    // if (settings.isNotEmpty) {
    //   textFieldC.clear(); // Bersihkan textFieldC sebelum mengisinya kembali
    //   print(settings.value);
    //   for (var setting in settings) {
    //     TextEditingController gajiController = TextEditingController(text: setting['gaji'].toString());
    //     TextEditingController gaji6JamController = TextEditingController(text: setting['gaji_6_jam'].toString());
    //     TextEditingController gaji12JamController = TextEditingController(text: setting['gaji_12_jam'].toString());
    //     TextEditingController lemburController = TextEditingController(text: setting['lembur'].toString());
    //     TextEditingController potonganController = TextEditingController(text: setting['potongan'].toString());

    //     // Tambahkan listener untuk setiap controller
    //     gajiController.addListener(() {
    //       // Handle perubahan teks pada gajiController
    //       print('Gaji: ${gajiController.text}');
    //       isEdit.value = true;
    //     });
    //     gaji6JamController.addListener(() {
    //       // Handle perubahan teks pada gajiController
    //       print('Gaji: ${gaji6JamController.text}');
    //       isEdit.value = true;
    //     });
    //     gaji12JamController.addListener(() {
    //       // Handle perubahan teks pada gajiController
    //       print('Gaji: ${gaji12JamController.text}');
    //       isEdit.value = true;
    //     });
    //     lemburController.addListener(() {
    //       // Handle perubahan teks pada lemburController
    //       print('Lembur: ${lemburController.text}');
    //       isEdit.value = true;
    //     });
    //     potonganController.addListener(() {
    //       // Handle perubahan teks pada potonganController
    //       print('Potongan: ${potonganController.text}');
    //       isEdit.value = true;
    //     });

    //     textFieldC.addAll([
    //       gajiController,
    //       gaji6JamController,
    //       gaji12JamController,
    //       lemburController,
    //       potonganController,
    //     ]);
    //   }
    // } else {
    //   await dbHelper.createTable(
    //     'setting',
    //     {
    //       "settingID": "TEXT PRIMARY KEY",
    //       "gaji": "TEXT NOT NULL",
    //       "gaji_6_jam": "TEXT NOT NULL",
    //       "gaji_12_jam": "TEXT NOT NULL",
    //       "lembur": "TEXT NOT NULL",
    //       "potongan": "TEXT NOT NULL",
    //     },
    //   );
    //   await dbHelper.insertDynamic(
    //     'setting',
    //     {
    //       "settingID": "0",
    //       "gaji": "6600",
    //       "gaji_6_jam": "40000",
    //       "gaji_12_jam": "80000",
    //       "lembur": "2000",
    //       "potongan": "3300",
    //     },
    //   );
    // }
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

  // void updateOnLocal() async {
  // await dbHelper
  //     .updateDynamic(
  //         "setting",
  //         {
  //           "gaji": textFieldC[0].text,
  //           "gaji_6_jam": textFieldC[1].text,
  //           "gaji_12_jam": textFieldC[2].text,
  //           "lembur": textFieldC[3].text,
  //           "potongan": textFieldC[4].text,
  //         },
  //         "settingID = ?",
  //         ["0"])
  //     .then((value) {
  //   Get.offAll(() => const PageViewUserController());
  //   Utils.showToast(TypeToast.success, "Berhasil update setting!");
  // }).onError((error, stackTrace) {
  //   Get.offAll(() => const PageViewUserController());
  //   Utils.showToast(TypeToast.error, "Terjadi kesalahan !");
  // });
  // }
}
