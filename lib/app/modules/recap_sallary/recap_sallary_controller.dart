import 'dart:developer';

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
  var isEditMode = <RxBool>[].obs; // Gunakan RxList<RxBool> untuk mengontrol edit mode tiap item
  var listAnggaranController = <Map<String, TextEditingController>>[].obs;
  var searchC = TextEditingController();
  // var settings = <Map<String, dynamic>>[].obs;
  DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = DateTime.now();
    getDataFromApi();
    // getDataFromLocal();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void toggleEditMode(int index) {
    // Matikan mode edit untuk semua item
    for (var i = 0; i < isEditMode.length; i++) {
      isEditMode[i].value = false;
    }
    // Nyalakan mode edit untuk item yang dipilih
    isEditMode[index].value = true;
    isEditMode.refresh();
  }

  Future<void> getDataFromApi() async {
    listDataPresence.clear();
    listAnggaranController.clear();
    if (selectedMonth.value == null) return;
    List<Map<String, dynamic>>? resp = await firestore.getDataForMonth(selectedMonth.value!.year, selectedMonth.value!.month);
    if (resp != null && resp.isNotEmpty) {
      await processData(resp);
    }
  }
  // Panggil fungsi summarizeData dengan daftar data presensi Anda

  Future<void> processData(List<Map<String, dynamic>> data) async {
    Map<String, Map<String, dynamic>>? summary = await summarizeData(data);

    if (summary != null) {
      var respUser = await firestore.getAllUser();
      if (respUser != null && respUser.isNotEmpty) {
        // Membuat map untuk mempermudah pencarian user berdasarkan userID
        Map<String, Map<String, dynamic>> userMap = {};
        for (var user in respUser) {
          userMap[user['userID']] = user;
        }

        summary.forEach((userID, userData) {
          // Mendapatkan data user dari map berdasarkan userID
          var user = userMap[userID];
          if (user != null && user.containsKey('gaji')) {
            // Menambahkan nilai gaji ke dalam data presence
            listDataPresence.add({
              'userID': userID,
              'userName': userData['userName'],
              'totalPresence': userData['totalPresence'],
              'totalLate': userData['totalLate'],
              'totalOvertime': userData['totalOvertime'],
              'gaji': user['gaji'], // Menambahkan nilai gaji
            });
          } else {
            // Jika data user tidak ditemukan atau tidak memiliki gaji, tambahkan dengan nilai default
            listDataPresence.add({
              'userID': userID,
              'userName': userData['userName'],
              'totalPresence': userData['totalPresence'],
              'totalLate': userData['totalLate'],
              'totalOvertime': userData['totalOvertime'],
              'gaji': {'lembur': "2000", 'potongan': "3300", 'gaji': "6600"}, // Nilai default jika tidak ada data gaji
              // 'gaji': {'lembur': "2222", 'potongan': "3333", 'gaji': "6666"}, // TEST aja
            });
          }
        });

        // Filter listDataPresence berdasarkan searchC.text
        listDataPresence.retainWhere((entry) => entry['userName'].toString().toLowerCase().contains(searchC.text));
        listDataPresence.refresh();
        isEditMode.value = List.generate(listDataPresence.length, (index) => false).map((e) => RxBool(false)).toList();
        // log("LIST : $listDataPresence");
      } else {
        print('Tidak ada data user.');
      }
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

  // Method to calculate gaji hadir
  String calculateGajiHadir(Map data) {
    int totalPresenceInHours = data["totalPresence"];
    int gajiPerJam = int.parse("${data['gaji']['gaji'] ?? 6600}");
    double gajiHadir = totalPresenceInHours * gajiPerJam.toDouble();
    gajiHadir = (gajiHadir / 1000).ceil() * 1000;
    return "Rp. ${gajiHadir.toInt().toStringAsFixed(0)}";
  }

  // Method to calculate gaji lembur
  String calculateGajiLembur(Map data) {
    int gajiPerJamLembur = int.parse("${data['gaji']['lembur'] ?? 2000}");
    int gajiLembur = data["totalOvertime"] * gajiPerJamLembur;
    return "Rp. ${gajiLembur.toStringAsFixed(0)}";
  }

  // Method to calculate gaji terpotong
  String calculateGajiTerpotong(Map data) {
    int gajiPotongan = int.parse("${data['gaji']['potongan'] ?? 3300}");
    int terlambatTime = data["totalLate"];
    double gajiTerpotong = 0;
    if (terlambatTime != 0) {
      terlambatTime *= 60;
      gajiTerpotong = (terlambatTime / 30).ceil() * gajiPotongan.toDouble();
    }
    return "Rp. ${gajiTerpotong.toStringAsFixed(0)}";
  }

  // Method to calculate total gaji
  String calculateGajiTotal(Map data) {
    int gajiHadir = int.parse(calculateGajiHadir(data).replaceAll("Rp. ", "").replaceAll(",", ""));
    int gajiLembur = int.parse(calculateGajiLembur(data).replaceAll("Rp. ", "").replaceAll(",", ""));
    int gajiTerpotong = int.parse(calculateGajiTerpotong(data).replaceAll("Rp. ", "").replaceAll(",", ""));
    int gajiTotal = gajiHadir - gajiTerpotong + gajiLembur;
    return "Rp. ${gajiTotal.toStringAsFixed(0)}";
  }

// Fungsi untuk menghitung total pengeluaran
  String calculateTotalPengeluaran(Map data, {bool isSingle = false}) {
    num totalPengeluaran = 0;
    if (isSingle) {
      totalPengeluaran = int.parse(calculateGajiTotal(data).replaceAll("Rp. ", "").replaceAll(",", ""));
    } else {
      for (var data in listDataPresence) {
        totalPengeluaran += int.parse(calculateGajiTotal(data).replaceAll("Rp. ", "").replaceAll(",", ""));
      }
    }
    return "Rp. ${totalPengeluaran.toStringAsFixed(0)}";
  }
}
