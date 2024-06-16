import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:teh_kota/app/utils/app_colors.dart';

enum TypeToast { error, success }

enum TypeShift { shiftPagi, shiftSore, shiftFull }

enum TypeStatus { tepatWaktu, terlambat }

class Utils {
  static FirebaseFirestore? firestore;
  static PackageInfo? packageInfo;
  static String branchName = "Wungu, Kab. Madiun";
  static var isLoggedIn = false.obs;
  static var isAdmin = false.obs;

  static Future<PackageInfo> initPackageInfoPlus() async {
    return await PackageInfo.fromPlatform();
  }

  static String formatTanggaLocal(String tanggal, {String? format}) {
    DateTime dateTime = DateFormat("yyyy-MM-dd").parse(tanggal);

    var m = DateFormat('MM', "id_ID").format(dateTime);
    var d = DateFormat('dd', "id_ID").format(dateTime).toString();
    var Y = DateFormat('yyyy', "id_ID").format(dateTime).toString();
    var month = "";
    var day = DateFormat('EEEE').format(dateTime);
    var hari = "";
    switch (day) {
      case 'Sunday':
        {
          hari = "Minggu";
        }
        break;
      case 'Monday':
        {
          hari = "Senin";
        }
        break;
      case 'Tuesday':
        {
          hari = "Selasa";
        }
        break;
      case 'Wednesday':
        {
          hari = "Rabu";
        }
        break;
      case 'Thursday':
        {
          hari = "Kamis";
        }
        break;
      case 'Friday':
        {
          hari = "Jumat";
        }
        break;
      case 'Saturday':
        {
          hari = "Sabtu";
        }
        break;
    }
    switch (m) {
      case '01':
        {
          month = "Januari";
        }
        break;
      case '02':
        {
          month = "Februari";
        }
        break;
      case '03':
        {
          month = "Maret";
        }
        break;
      case '04':
        {
          month = "April";
        }
        break;
      case '05':
        {
          month = "Mei";
        }
        break;
      case '06':
        {
          month = "Juni";
        }
        break;
      case '07':
        {
          month = "Juli";
        }
        break;
      case '08':
        {
          month = "Agustus";
        }
        break;
      case '09':
        {
          month = "September";
        }
        break;
      case '10':
        {
          month = "Oktober";
        }
        break;
      case '11':
        {
          month = "November";
        }
        break;
      case '12':
        {
          month = "Desember";
        }
        break;
    }
    String formattedDate;
    if (format != null) {
      formattedDate = DateFormat(format, 'id_ID').format(dateTime);
    } else {
      formattedDate = "$hari, $d $month $Y";
    }
    return formattedDate;
  }

  static specifyTypeStatus(dynamic typeStatus, {bool fromInt = true}) {
    if (fromInt) {
      switch (typeStatus) {
        case 1:
          return TypeStatus.tepatWaktu;
        case 2:
          return TypeStatus.terlambat;
      }
    } else {
      switch (typeStatus) {
        case TypeStatus.tepatWaktu:
          return 1;
        case TypeStatus.terlambat:
          return 2;
      }
    }
  }

  static String typeStatusToString(TypeStatus typeStatus) {
    switch (typeStatus) {
      case TypeStatus.tepatWaktu:
        return "Tepat Waktu";
      case TypeStatus.terlambat:
        return "Terlambat";
    }
  }

  static specifyTypeShift(dynamic typeShift, {bool fromInt = true}) {
    if (fromInt) {
      switch (typeShift) {
        case 0:
          return TypeShift.shiftPagi;
        case 1:
          return TypeShift.shiftSore;
        case 2:
          return TypeShift.shiftFull;
      }
    } else {
      switch (typeShift) {
        case TypeShift.shiftPagi:
          return 0;
        case TypeShift.shiftSore:
          return 1;
        case TypeShift.shiftFull:
          return 2;
      }
    }
  }

  static String typeShiftToString(TypeShift typeShift) {
    switch (typeShift) {
      case TypeShift.shiftPagi:
        return "Shift Pagi";
      case TypeShift.shiftSore:
        return "Shift Sore";
      case TypeShift.shiftFull:
        return "Full Shift";
    }
  }

  static DateTime customDate(int hours, int minute) {
    var customDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hours, minute);
    return customDate;
  }

  static String customShowJustTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static DateTime pickOfficeHours(DateTime officeHoursValue) {
    var officeHourPicked = officeHoursValue;
    return officeHourPicked;
  }

  static Map<String, DateTime> officeHours(TypeShift typeShift) {
    switch (typeShift) {
      case TypeShift.shiftPagi:
        return {
          "login_presence": customDate(9, 0),
          "logout_presence": customDate(15, 0),
        };
      case TypeShift.shiftSore:
        return {
          "login_presence": customDate(15, 0),
          "logout_presence": customDate(21, 0),
        };
      case TypeShift.shiftFull:
        return {
          "login_presence": customDate(9, 0),
          "logout_presence": customDate(21, 0),
        };
    }
  }

  static String formatTime(DateTime? dateTime) {
    if (dateTime == null) return "";
    return DateFormat('HH.mm').format(dateTime);
  }

  static String funcHourCalculateTotal(DateTime? jamMasuk, DateTime? jamKeluar) {
    if (jamMasuk == null || jamKeluar == null) return "";
    DateTime masukTanpaDetik = DateTime(jamMasuk.year, jamMasuk.month, jamMasuk.day, jamMasuk.hour, jamMasuk.minute);
    DateTime keluarTanpaDetik = DateTime(jamKeluar.year, jamKeluar.month, jamKeluar.day, jamKeluar.hour, jamKeluar.minute);

    // Hitung selisih waktu antara jam masuk dan jam keluar
    Duration selisihWaktu = keluarTanpaDetik.difference(masukTanpaDetik);

    // Hitung total jam dan menit dari selisih waktu
    int totalMenit = selisihWaktu.inMinutes;
    int totalJam = totalMenit ~/ 60;
    totalMenit %= 60;

    // Format hasil
    String hasilJam = totalJam.toString().padLeft(2, '0');
    String hasilMenit = totalMenit.toString().padLeft(2, '0');

    return '$hasilJam.$hasilMenit';
  }

  // static String funcHourCalculateTotal(String jamMasuk, String jamKeluar, {String jamLembur = "0.0"}) {
  //   List<String> jamMasukParts = jamMasuk.split('.');
  //   List<String> jamKeluarParts = jamKeluar.split('.');
  //   List<String> jamParts = jamLembur.split('.');

  //   int jamMasukJam = int.parse(jamMasukParts[0]);
  //   int jamMasukMenit = int.parse(jamMasukParts[1]);

  //   int jamKeluarJam = int.parse(jamKeluarParts[0]);
  //   int jamKeluarMenit = int.parse(jamKeluarParts[1]);

  //   int jamLemburJam = int.parse(jamParts[0]);
  //   int jamLemburMenit = int.parse(jamParts[1]);

  //   int totalMenitMasuk = (jamMasukJam * 60 + jamMasukMenit).toInt();
  //   int totalMenitKeluar = (jamKeluarJam * 60 + jamKeluarMenit).toInt();
  //   int totalMenitLembur = (jamLemburJam * 60 + jamLemburMenit).toInt();

  //   // Hitung selisih jam dan menit
  //   int selisihTotalMenit = totalMenitKeluar - totalMenitMasuk;
  //   // Tambahkan jam lembur jika ada
  //   selisihTotalMenit += totalMenitLembur;

  //   // Hitung jumlah total jam dan menit
  //   int totalJam = selisihTotalMenit ~/ 60;
  //   int totalMenit = selisihTotalMenit % 60;

  //   // Format hasil
  //   String hasilJam = totalJam.toString().padLeft(2, '0');
  //   String hasilMenit = totalMenit.toString().padLeft(2, '0');

  //   return '$hasilJam.$hasilMenit';
  // }

  static int? convertHoursToMinute(String? hoursVal) {
    if (hoursVal == null) return null;
    // Pisahkan jam menjadi jam dan menit
    List<String> jamParts = hoursVal.split('.');

    int jam = int.parse(jamParts[0]);
    double menit = double.parse(jamParts[1]);

    // Konversi jam ke menit dan tambahkan dengan menit
    int totalMenit = (jam * 60 + menit).toInt();

    return totalMenit;
  }

  static Widget gapVertical(double gap) {
    return SizedBox(height: gap);
  }

  static Widget gapHorizontal(double gap) {
    return SizedBox(width: gap);
  }

  static showToast(TypeToast typeToast, String message) {
    if (typeToast == TypeToast.success) {
      return Get.snackbar("Sukses", message, backgroundColor: const Color(AppColor.colorGreen));
    } else {
      return Get.snackbar("Gagal", message, backgroundColor: const Color(AppColor.colorRed));
    }
  }

  static Future<bool> showAlertDialog(BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          const Color(AppColor.colorRed),
        ),
      ),
      child: const Text("Batal"),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Iya"),
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Konfirmasi"),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }
}
