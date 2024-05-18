import 'package:get/get.dart';

class AdminController extends GetxController {
  var shiftToday = [
    {
      "name": "Shift Pagi",
      "presensi_masuk": "09:00",
      "presensi_keluar": "15:00",
    }
  ];

  var listDataPresence = [
    {
      "name": "Rizka dfdsd",
      "shift": "0",
      "tanggal": "04/05/2024",
      "presensi_masuk": "09:00",
      "presensi_keluar": "15:00",
      "lembur": "00:06",
      "status": "2",
    },
  ];

  @override
  void onInit() {
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
}
