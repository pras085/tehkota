import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RekapController extends GetxController {
  var selectedMonth = Rxn<DateTime>();
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var scrollC = ScrollController();

  var listDataPresence = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime.now();
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
    if (selectedMonth.value == null) return;
    List<Map<String, dynamic>>? resp = await firestore.getDataForMonth(selectedMonth.value!.year, selectedMonth.value!.month);
    if (resp != null && resp.isNotEmpty) {
      log("LIST : $resp");
      processData(resp);
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

      // Mengakumulasi jumlah terlambat_time
      if (entry.containsKey('terlambat_time')) {
        int terlambatTime = int.parse(entry['terlambat_time']);
        summary[userID]?['totalLate'] = (summary[userID]?['totalLate'] ?? 0) + terlambatTime;
      }

      // Menghitung lembur (jika ada)
      if (entry.containsKey('lembur_time')) {
        summary[userID]?['totalOvertime']++;
      }
    }

    return summary;
  }
}
