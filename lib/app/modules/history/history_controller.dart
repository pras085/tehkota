import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';

class HistoryController extends GetxController {
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var listDataPresence = <Map<String, dynamic>>[].obs;
  var listDataPresenceBackup = <Map<String, dynamic>>[].obs;
  DateTime? selectedDate;
  var searchC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    selectedDate = DateTime.now();
    getDataFromApi(DateFormat("dd-MM-y").format(selectedDate!));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> getDataFromApi(String? docID, {String? searchName}) async {
    listDataPresence.clear();
    listDataPresenceBackup.clear();
    if (docID == null) return;
    List<Map<String, dynamic>>? resp =
        await firestore.getSpesificPresence(docID);
    if (resp != null) {
      listDataPresenceBackup.addAll(resp);
      listDataPresence.addAll(resp);
    }
    // Jika ada searchName yang diberikan, lakukan filtering berdasarkan userName
    if (searchName != null) {
      List<Map<String, dynamic>> filteredData = listDataPresence
          .where((entry) => entry['userName']
              .toString()
              .toLowerCase()
              .contains(searchName.toLowerCase()))
          .toList();
      listDataPresence
          .clear(); // Kosongkan listDataPresence sebelum menambahkan hasil filter
      listDataPresence
          .addAll(filteredData); // Tambahkan hasil filter ke listDataPresence
    }
    listDataPresence.refresh();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2024, 6), // Ganti dengan tanggal awal yang valid
      lastDate: DateTime(2025), // Ganti dengan tanggal akhir yang valid
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      searchC.clear();
      await getDataFromApi(DateFormat("dd-MM-y").format(selectedDate!));
    }
  }
}
