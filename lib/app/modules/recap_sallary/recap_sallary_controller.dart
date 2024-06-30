import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/db/databse_helper.dart';

class RekapController extends GetxController {
  var selectedMonth = Rxn<DateTime>();
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var scrollC = ScrollController();
  var listDataPresence = <Map<String, dynamic>>[].obs;
  var searchC = TextEditingController();
  var settings = <Map<String, dynamic>>[].obs;
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime.now();
    getDataFromApi();
    getDataFromLocal();
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
    if (selectedMonth.value == null) return;
    List<Map<String, dynamic>>? resp = await firestore.getDataForMonth(selectedMonth.value!.year, selectedMonth.value!.month);
    if (resp != null && resp.isNotEmpty) {
      // log("LIST : $resp");
      await processData(resp);
    }
  }
  // Panggil fungsi summarizeData dengan daftar data presensi Anda

  Future<void> processData(List<Map<String, dynamic>> data) async {
    Map<String, Map<String, dynamic>>? summary = await summarizeData(data);

    if (summary != null) {
      // Lakukan sesuatu dengan ringkasan data, misalnya, tampilkan atau simpan ke database.
      summary.forEach((userID, userData) {
        listDataPresence.add({
          'userID': userID,
          'userName': userData['userName'],
          'totalPresence': userData['totalPresence'],
          'totalLate': userData['totalLate'],
          'totalOvertime': userData['totalOvertime'],
        });
      });
      listDataPresence.retainWhere((entry) => entry['userName'].toString().toLowerCase().contains(searchC.text));
      listDataPresence.refresh();
      // print("LIST : $listDataPresence");
    } else {
      print('Tidak ada data presensi.');
    }
  }

  Future<Map<String, Map<String, dynamic>>?> summarizeData(List<Map<String, dynamic>>? data) async {
    if (data == null || data.isEmpty) {
      return null;
    }

    Map<String, Map<String, dynamic>> summary = {};

    for (var entry in data) {
      String userID = entry['userID'];
      if (!summary.containsKey(userID)) {
        // Inisialisasi ringkasan data untuk pengguna baru
        summary[userID] = {
          'userName': entry["userName"],
          'totalPresence': 0,
          'totalLate': 0,
          'totalOvertime': 0,
        };
      }

      // Menghitung jumlah presensi
      if (entry.containsKey("logout_presence") && entry.containsKey("login_presence")) {
        DateTime logoutPresence = DateTime.parse(entry["logout_presence"]);
        DateTime loginPresence = DateTime.parse(entry["login_presence"]);
        Duration difference = logoutPresence.difference(loginPresence);
        summary[userID]?['totalPresence'] += difference.inHours;
      }

      // Mengakumulasi jumlah terlambat_time dalam jam
      if (entry.containsKey('terlambat_time')) {
        int terlambatTimeInMinutes = int.parse(entry['terlambat_time']);
        int terlambatTimeInHours = terlambatTimeInMinutes ~/ 60; // konversi ke jam sebagai int
        summary[userID]?['totalLate'] = (summary[userID]?['totalLate'] ?? 0) + terlambatTimeInHours; // Pastikan menggunakan 0 untuk int
      }

      // Menghitung lembur (jika ada)
      if (entry.containsKey('lembur_time')) {
        int lemburTimeInMinutes = int.parse(entry['lembur_time']);
        int lemburTimeInHours = lemburTimeInMinutes ~/ 60; // konversi ke jam sebagai int
        summary[userID]?['totalOvertime'] = (summary[userID]?['totalOvertime'] ?? 0) + lemburTimeInHours; // Pastikan menggunakan 0 untuk int
      }
    }

    return summary;
  }

  void getDataFromLocal() async {
    settings.value = await dbHelper.queryAllRows('setting');
    if (settings.isNotEmpty) {
      print(settings.value);
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
      listDataPresence.refresh();
    }
  }
}