import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';

class HistoryController extends GetxController {
  CloudFirestoreService firestore = CloudFirestoreService();
  RefreshController refreshC = RefreshController();
  var listDataPresence = <Map<String, dynamic>>[].obs;
  DateTime? selectedDate;

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

  Future<void> getDataFromApi(String? docID) async {
    listDataPresence.clear();
    if (docID == null) return;
    List<Map<String, dynamic>>? resp = await firestore.getSpesificPresence(docID);
    if (resp != null) {
      listDataPresence.addAll(resp);
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
    if (picked != null && picked != selectedDate) selectedDate = picked;
    getDataFromApi(DateFormat("dd-MM-y").format(selectedDate!));
  }
}
