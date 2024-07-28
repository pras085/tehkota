// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/modules/home/home_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/camera_detection_preview.dart';
import 'package:teh_kota/app/widgets/custom_fab_button.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/single_picture.dart';
import 'package:uuid/uuid.dart';

import '../../locator.dart';
import '../../models/user.model.dart';
import '../../services/camera.service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';
import '../../widgets/presence_bottom_sheet.dart';

class PresenceView extends StatefulWidget {
  const PresenceView({super.key});

  @override
  State<PresenceView> createState() => _PresenceViewState();
}

class _PresenceViewState extends State<PresenceView> {
  var homeC = Get.find<HomeController>();
  final CameraService _cameraService = locator<CameraService>();
  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final MLService _mlService = locator<MLService>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isPictureTaken = false;
  bool _isInitializing = false;

  CloudFirestoreService firestore = CloudFirestoreService();

  PersistentBottomSheetController? bottomSheetController;
  var presenceData = Rxn<Map<String, dynamic>>();
  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _mlService.dispose();
    _faceDetectorService.dispose();
    homeC.isLemburPresence.value = false;
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    await _faceDetectorService.initialize();
    setState(() => _isInitializing = false);
    _frameFaces();
  }

  _frameFaces() async {
    bool processing = false;
    _cameraService.cameraController!
        .startImageStream((CameraImage image) async {
      if (processing) return; // prevents unnecessary overprocessing.
      processing = true;
      await _predictFacesFromImage(image: image);
      processing = false;
    });
  }

  Future<void> _predictFacesFromImage({required CameraImage? image}) async {
    assert(image != null, 'Image is null');
    await _faceDetectorService.detectFacesFromImage(image!);
    if (_faceDetectorService.faceDetected) {
      _mlService.setCurrentPrediction(image, _faceDetectorService.faces[0]);
    }
    if (mounted) setState(() {});
  }

  Future<void> takePicture() async {
    // await _cameraService.takePicture();
    // setState(() => _isPictureTaken = true);
    if (_faceDetectorService.faceDetected) {
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
              const AlertDialog(content: Text('No face detected!')));
    }
  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  Future<void> onTap() async {
    var shiftPagi = homeC.officeHoursFromDb.value?["pagi"];
    var shiftSore = homeC.officeHoursFromDb.value?["sore"];
    int split(String val, bool pickFirst) {
      if (val.contains(":")) {
        var parts = val.split(":");
        return int.parse(pickFirst ? parts.first : parts.last);
      }
      return int.parse(val); // return the original value if there is no colon
    }

    await takePicture();
    var docID = DateFormat("dd-MM-y").format(DateTime.now());
    if (_faceDetectorService.faceDetected) {
      _isInitializing = true;
      User? user = await _mlService.predict();
      // User? user = User(userName: "Aisyah", userID: "EMP-f30f4");
      Map<String, dynamic>? body;
      if (user != null) {
        try {
          // jika belum ada yang presensi di hari itu - create doc baru
          body = {
            "id": const Uuid().v4(),
            "userID": user.userID,
            "userName": user.userName,
            "docID": docID,
          };
          var res = await firestore.addPresence(docID, body, user.userID ?? "");
          if (!res) {
            // jika terjadi error
            throw "ERROR addPresence";
          }

          await firestore.getPresence(docID)?.then((value) async {
            int typePresence = 1;
            // todo sampai sini
            if (!value.exists) {
              throw "ERROR resGetPresence";
            }
            presenceData.value = value.data()?[user.userID];

            if (!(presenceData.value ?? {}).containsKey("login_presence")) {
              typePresence = 1;
            } else if (!(presenceData.value ?? {})
                .containsKey("logout_presence")) {
              typePresence = 2;
            } else if ((presenceData.value ?? {}).containsKey("lemburan")) {
              if (((presenceData.value?["lemburan"] as Map)
                  .containsKey("manual"))) {
                if (!((presenceData.value?["lemburan"]["manual"] as Map)
                    .containsKey("lembur_masuk"))) {
                  typePresence = 3;
                } else if (!((presenceData.value?["lemburan"]["manual"] as Map)
                    .containsKey("lembur_keluar"))) {
                  typePresence = 4;
                } else {
                  typePresence = 6;
                }
              } else {
                typePresence = 3;
              }
            } else {
              typePresence = 3;
            }
            showBottomSheetPresence(
                user: user,
                body: presenceData.value,
                typePresence: typePresence);
          }).catchError((error) {
            print('Error getPresence: $error');
          });
        } catch (e) {
          print('$e');
          Utils.showToast(
              TypeToast.error, "Terjadi Kesalahan!, Silakan Coba Lagi");
          return;
        }
      } else {
        _isInitializing = false;
        Utils.showToast(
            TypeToast.error, "Wajah tidak terdaftar, silahkan coba lagi !");
      }
    }
  }

  Widget getBodyWidget() {
    if (_isInitializing)
      return const Center(child: CircularProgressIndicator());
    if (_isPictureTaken) {
      return SinglePicture(imagePath: _cameraService.imagePath!);
    }
    return CameraDetectionPreview();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) {
      fab = CustomFabButton(onTap: onTap);
    }
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Stack(
          children: [
            body,
            _appBar(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: fab,
    );
  }

  Widget _appBar() {
    return Container(
      width: Get.width,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Obx(() {
            return Expanded(
              child: CustomText(
                homeC.isLemburPresence.value ? "Presensi Lembur" : "Presensi",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                color: Colors.white,
              ),
            );
          }),
        ],
      ),
    );
  }

  void showBottomSheetPresence(
      {required User? user,
      Map<String, dynamic>? body,
      required int typePresence}) {
    var shiftPagi = homeC.officeHoursFromDb.value?["pagi"];
    var shiftSore = homeC.officeHoursFromDb.value?["sore"];
    int split(String val, bool pickFirst) {
      if (val.contains(":")) {
        var parts = val.split(":");
        return int.parse(pickFirst ? parts.first : parts.last);
      }
      return int.parse(val); // return the original value if there is no colon
    }

    var selectedShift = Rxn<int>();
    var selectedJenisKerja = 0.obs;

    var rxBody = body.obs;
    print("TYPE PRESENCE ${typePresence}");

    if (typePresence == 1) {
      rxBody.value?['login_presence'] = DateTime.now().toLocal().toString();
    } else if (typePresence == 2) {
      rxBody.value?['logout_presence'] = DateTime.now().toLocal().toString();
    } else if (typePresence == 3) {
      rxBody.value?['lemburan'] = {
        "manual": {
          "lembur_masuk": DateTime.now().toLocal().toString(),
        }
      };
    } else if (typePresence == 4) {
      rxBody.value?['lemburan']['manual'] = {
        "lembur_keluar": DateTime.now().toLocal().toString(),
      };
    }

    Get.bottomSheet(
      WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset("assets/ic_berhasil.svg"),
              Utils.gapVertical(16),
              typePresence != 6
                  ? CustomText(
                      "Presensi "
                      "${typePresence == 1 ? "Masuk" : typePresence == 2 ? "Keluar" : ""}"
                      " Berhasil",
                      fontSize: 20,
                      color: const Color(AppColor.colorGreen),
                      fontWeight: FontWeight.w600,
                    )
                  : CustomText(
                      "Sudah tidak ada presensi untuk hari ini",
                      fontSize: 16,
                      maxLines: 3,
                      color: const Color(AppColor.colorBlack),
                      fontWeight: FontWeight.w600,
                    ),
              if (typePresence != 6) Utils.gapVertical(4),
              if (typePresence != 6)
                Text.rich(
                  TextSpan(
                    text:
                        "${typePresence == 1 ? "Selamat datang" : "Terimasih untuk hari ini"} ",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(AppColor.colorBlack),
                      fontFamily: "poppins",
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: user?.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            ", ${typePresence == 1 ? "Semangat kerjanya untuk hari ini!" : typePresence == 2 ? "Jangan lupa istirahat yaa" : typePresence == 3 ? "Namun jam kerja mu sudah selesai, mau lembur?" : "Terimakasih juga untuk lemburannya, jangan lupa istirahat"}",
                        style: TextStyle(fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              if (typePresence == 1) Utils.gapVertical(16),
              if (typePresence == 1)
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(AppColor.colorLightGrey),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CustomText(
                        "Pilih Shift Anda",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      Utils.gapVertical(12),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectedShift.value = 0;
                                rxBody.update((val) {
                                  val?['shift'] = "0";
                                  val?['status'] = (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isAfter(Utils.customDate(
                                              split(
                                                  shiftPagi["jamMasuk"], true),
                                              split(shiftPagi["jamMasuk"],
                                                  false))))
                                      ? "2"
                                      : "1";
                                  if (val?['status'] == "2") {
                                    val?['terlambat_time'] = DateTime.parse(
                                            rxBody.value?["login_presence"])
                                        .difference(Utils.customDate(
                                            split(shiftPagi["jamMasuk"], true),
                                            split(
                                                shiftPagi["jamMasuk"], false)))
                                        .inMinutes
                                        .toString();
                                  } else {
                                    val?.remove('terlambat_time');
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selectedShift.value == 0
                                        ? Color(AppColor.colorWhite)
                                        : Color(AppColor.colorBlue),
                                  ),
                                  color: selectedShift.value == 0
                                      ? Color(AppColor.colorBlue)
                                      : Color(AppColor.colorWhite),
                                ),
                                child: CustomText(
                                  "Shift Pagi",
                                  fontSize: 14,
                                  color: selectedShift.value == 0
                                      ? Color(AppColor.colorWhite)
                                      : Color(AppColor.colorBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                selectedShift.value = 1;
                                rxBody.update((val) {
                                  val?['shift'] = "1";
                                  val?['status'] = (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isAfter(Utils.customDate(
                                              split(
                                                  shiftSore["jamMasuk"], true),
                                              split(shiftSore["jamMasuk"],
                                                  false))))
                                      ? "2"
                                      : "1";
                                  if (val?['status'] == "2") {
                                    val?['terlambat_time'] = DateTime.parse(
                                            rxBody.value?["login_presence"])
                                        .difference(Utils.customDate(
                                            split(shiftSore["jamMasuk"], true),
                                            split(
                                                shiftSore["jamMasuk"], false)))
                                        .inMinutes
                                        .toString();
                                  } else {
                                    val?.remove('terlambat_time');
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selectedShift.value == 1
                                        ? Color(AppColor.colorWhite)
                                        : Color(AppColor.colorBlue),
                                  ),
                                  color: selectedShift.value == 1
                                      ? Color(AppColor.colorBlue)
                                      : Color(AppColor.colorWhite),
                                ),
                                child: CustomText(
                                  "Shift Sore",
                                  fontSize: 14,
                                  color: selectedShift.value == 1
                                      ? Color(AppColor.colorWhite)
                                      : Color(AppColor.colorBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                selectedShift.value = 2;
                                rxBody.update((val) {
                                  val?['shift'] = "2";
                                  val?['status'] = (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isAfter(Utils.customDate(
                                              split(
                                                  shiftPagi["jamMasuk"], true),
                                              split(shiftPagi["jamMasuk"],
                                                  false))))
                                      ? "2"
                                      : "1";
                                  if (val?['status'] == "2") {
                                    val?['terlambat_time'] = DateTime.parse(
                                            rxBody.value?["login_presence"])
                                        .difference(Utils.customDate(
                                            split(shiftPagi["jamMasuk"], true),
                                            split(
                                                shiftPagi["jamMasuk"], false)))
                                        .inMinutes
                                        .toString();
                                  } else {
                                    val?.remove('terlambat_time');
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selectedShift.value == 2
                                        ? Color(AppColor.colorWhite)
                                        : Color(AppColor.colorBlue),
                                  ),
                                  color: selectedShift.value == 2
                                      ? Color(AppColor.colorBlue)
                                      : Color(AppColor.colorWhite),
                                ),
                                child: CustomText(
                                  "Full Shift",
                                  fontSize: 14,
                                  color: selectedShift.value == 2
                                      ? Color(AppColor.colorWhite)
                                      : Color(AppColor.colorBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (typePresence == 1) Utils.gapVertical(16),
              if (typePresence == 1)
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(AppColor.colorLightGrey),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CustomText(
                        "Pilih Jenis Kerja",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      Utils.gapVertical(12),
                      Obx(
                        () => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                selectedJenisKerja.value = 0;
                                rxBody.update((val) {
                                  val?.remove("lemburan");
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selectedJenisKerja.value == 0
                                        ? Color(AppColor.colorWhite)
                                        : Color(AppColor.colorBlue),
                                  ),
                                  color: selectedJenisKerja.value == 0
                                      ? Color(AppColor.colorBlue)
                                      : Color(AppColor.colorWhite),
                                ),
                                child: CustomText(
                                  "Normal",
                                  fontSize: 14,
                                  color: selectedJenisKerja.value == 0
                                      ? Color(AppColor.colorWhite)
                                      : Color(AppColor.colorBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                selectedJenisKerja.value = 1;
                                rxBody.update((val) {
                                  switch (selectedShift.value) {
                                    case 0:
                                      if (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isBefore(Utils.customDate(
                                              split(
                                                  shiftPagi["jamMasuk"], true),
                                              split(shiftPagi["jamMasuk"],
                                                  false)))) {
                                        val?['lemburan'] = {
                                          "auto_masuk": {
                                            "lembur_masuk":
                                                rxBody.value?['login_presence'],
                                            "lembur_keluar": Utils.customDate(
                                                    split(shiftPagi["jamMasuk"],
                                                        true),
                                                    split(shiftPagi["jamMasuk"],
                                                        false))
                                                .toLocal()
                                                .toString(),
                                          }
                                        };
                                      }
                                      break;
                                    case 1:
                                      if (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isBefore(Utils.customDate(
                                              split(
                                                  shiftSore["jamMasuk"], true),
                                              split(shiftSore["jamMasuk"],
                                                  false)))) {
                                        val?['lemburan'] = {
                                          "auto_masuk": {
                                            "lembur_masuk":
                                                rxBody.value?['login_presence'],
                                            "lembur_keluar": Utils.customDate(
                                                    split(shiftSore["jamMasuk"],
                                                        true),
                                                    split(shiftSore["jamMasuk"],
                                                        false))
                                                .toLocal()
                                                .toString(),
                                          }
                                        };
                                      }
                                      break;
                                    case 2:
                                      if (DateTime.parse(
                                              rxBody.value?['login_presence'])
                                          .isBefore(Utils.customDate(
                                              split(
                                                  shiftPagi["jamMasuk"], true),
                                              split(shiftPagi["jamMasuk"],
                                                  false)))) {
                                        val?['lemburan'] = {
                                          "auto_masuk": {
                                            "lembur_masuk":
                                                rxBody.value?['login_presence'],
                                            "lembur_keluar": Utils.customDate(
                                                    split(shiftPagi["jamMasuk"],
                                                        true),
                                                    split(shiftPagi["jamMasuk"],
                                                        false))
                                                .toLocal()
                                                .toString(),
                                          }
                                        };
                                      }
                                      break;
                                    default:
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: selectedJenisKerja.value == 1
                                        ? Color(AppColor.colorWhite)
                                        : Color(AppColor.colorBlue),
                                  ),
                                  color: selectedJenisKerja.value == 1
                                      ? Color(AppColor.colorBlue)
                                      : Color(AppColor.colorWhite),
                                ),
                                child: CustomText(
                                  "Lembur",
                                  fontSize: 14,
                                  color: selectedJenisKerja.value == 1
                                      ? Color(AppColor.colorWhite)
                                      : Color(AppColor.colorBlack),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (typePresence == 1 || typePresence == 2) Utils.gapVertical(16),
              if (typePresence == 1 || typePresence == 2)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomText(
                              typePresence == 1 ? "Jam Masuk" : "Jam Keluar",
                              color: const Color(AppColor.colorDarkGrey),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            Utils.gapVertical(8),
                            CustomText(
                              (body?["login_presence"] != null &&
                                      typePresence == 1)
                                  ? Utils.formatTime(DateTime.tryParse(
                                      body?["login_presence"]))
                                  : (body?["logout_presence"] != null &&
                                          typePresence == 2)
                                      ? Utils.formatTime(DateTime.tryParse(
                                          body?["logout_presence"]))
                                      : "-",
                              color: const Color(AppColor.colorBlackNormal),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        Container(
                          color: const Color(AppColor.colorLightGrey),
                          height: 43,
                          width: 1,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomText(
                              "Shift",
                              color: Color(AppColor.colorDarkGrey),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            Utils.gapVertical(8),
                            Obx(
                              () => CustomText(
                                (rxBody.value?["shift"] != null)
                                    ? Utils.typeShiftToString(
                                        Utils.specifyTypeShift(
                                            int.parse(rxBody.value!["shift"])))
                                    : "-",
                                color: const Color(AppColor.colorBlackNormal),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                        Container(
                          color: const Color(AppColor.colorLightGrey),
                          height: 43,
                          width: 1,
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CustomText(
                              "Status",
                              color: Color(AppColor.colorDarkGrey),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            Utils.gapVertical(8),
                            Obx(
                              () => CustomText(
                                (rxBody.value != null &&
                                        rxBody.value!["status"] != null)
                                    ? Utils.typeStatusToString(
                                        Utils.specifyTypeStatus(int.parse(rxBody
                                            .value!["status"]
                                            .toString())))
                                    : "-",
                                color: const Color(AppColor.colorBlackNormal),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              if (typePresence != 6) Utils.gapVertical(24),
              if (typePresence != 6)
                appButton(
                  text: (typePresence == 1 || typePresence == 2)
                      ? 'Kirim'
                      : typePresence == 3
                          ? "Masuk Lembur"
                          : "Selesai Lembur",
                  onPressed: () async {
                    var resAdd = await firestore.addPresence(
                      rxBody.value?["docID"],
                      rxBody.value!,
                      rxBody.value?["userID"],
                    );
                    if (resAdd) {
                      Get.back();
                      Get.back();
                    }
                    print(rxBody.value);
                  },
                ),
              Utils.gapVertical(16),
              appButton(
                text: (typePresence == 1 || typePresence == 2)
                    ? 'Presensi Ulang'
                    : 'Kembali',
                onPressed: () async {
                  _reload();
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      enableDrag: false,
      isScrollControlled: true,
      isDismissible: false,
    );
  }
}

appButton({required String text, required VoidCallback onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(AppColor.colorGreen)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 13.5),
      width: Get.width,
      height: 60,
      child: CustomText(
        text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(AppColor.colorGreen),
      ),
    ),
  );
}
