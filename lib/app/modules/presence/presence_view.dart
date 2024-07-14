import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/modules/home/home_controller.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/camera_detection_preview.dart';
import 'package:teh_kota/app/widgets/custom_fab_button.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/lembur_bottom_sheet.dart';
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
  final FaceDetectorService _faceDetectorService = locator<FaceDetectorService>();
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
    _cameraService.cameraController!.startImageStream((CameraImage image) async {
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
    if (_faceDetectorService.faceDetected) {
      await _cameraService.takePicture();
      setState(() => _isPictureTaken = true);
    } else {
      showDialog(context: context, builder: (context) => const AlertDialog(content: Text('No face detected!')));
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
      Map<String, dynamic>? body;
      if (user != null) {
        try {
          // jika belum ada yang presensi di hari itu - create doc baru
          body = {
            "id": const Uuid().v4(),
            "userID": user.userID,
            "userName": user.userName,
          };
          var res = await firestore.addPresence(docID, body, user.userID ?? "");
          if (!res) {
            // jika terjadi error
            throw "ERROR addPresence";
          }

          await firestore.getPresence(docID)?.then((value) async {
            // todo sampai sini
            if (!value.exists) {
              throw "ERROR resGetPresence";
            }
            presenceData.value = value.data()?[user.userID];
            if (homeC.isLemburPresence.value) {
              // hitung lembur
              Map lemburTime = presenceData.value?["lemburan"] ?? {};
              var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
              if (!((presenceData.value ?? {}).containsKey("lemburan"))) {
                if (presenceData.value?["shift"] == "0") {
                  lemburTime.putIfAbsent("manual", () => {"lembur_masuk": now.toString()});
                  if (lemburTime.isNotEmpty) {
                    print("lembur : $lemburTime");
                    body?.putIfAbsent("lemburan", () => lemburTime);
                  }
                } else {
                  lemburTime.putIfAbsent("manual", () => {"lembur_masuk": now.toString()});
                  if (lemburTime.isNotEmpty) {
                    print("lembur : $lemburTime");
                    body?.putIfAbsent("lemburan", () => lemburTime);
                  }
                }
              } else if ((presenceData.value ?? {}).containsKey("lemburan") && ((presenceData.value ?? {})["lemburan"] as Map).containsKey("manual") && !((presenceData.value?["lemburan"]["manual"] as Map).containsKey("lembur_keluar"))) {
                if (presenceData.value?["shift"] == "0") {
                  (lemburTime["manual"] as Map).putIfAbsent("lembur_keluar", () => now.toString());
                  if (lemburTime.isNotEmpty) {
                    print("lembur : $lemburTime");
                    body?.putIfAbsent("lemburan", () => lemburTime);
                  }
                } else {
                  (lemburTime["manual"] as Map).putIfAbsent("lembur_keluar", () => now.toString());
                  if (lemburTime.isNotEmpty) {
                    print("lembur : $lemburTime");
                    body?.putIfAbsent("lemburan", () => lemburTime);
                  }
                }
              } else if (((presenceData.value?["lemburan"]["manual"] as Map).containsKey("lembur_keluar")) && ((presenceData.value?["lemburan"]["manual"] as Map).containsKey("lembur_masuk"))) {
                body = presenceData.value;
              }
              var resLogout = await firestore.addPresence(
                docID,
                body,
                body?["userID"],
              );
              if (resLogout) {
                if ((presenceData.value ?? {}).containsKey("status")) {
                  body?.putIfAbsent("status", () => presenceData.value?["status"]);
                }
              }
            } else if ((presenceData.value ?? {}).containsKey("login_presence") && (presenceData.value ?? {}).containsKey("logout_presence")) {
              body?.putIfAbsent("login_presence", () => presenceData.value?['login_presence']);
              body?.putIfAbsent("logout_presence", () => presenceData.value?['login_presence']);
            } else if (!((presenceData.value ?? {}).containsKey("login_presence"))) {
              // buat baru (presensi masuk)
              var resLogin = await firestore.addPresence(
                docID,
                {"login_presence": DateTime.now().toLocal().toString()},
                body?["userID"],
              );
              if (resLogin) {
                body?.putIfAbsent("login_presence", () => DateTime.now().toLocal().toString());
              }
            } else if (!((presenceData.value ?? {}).containsKey("logout_presence"))) {
              // (presensi keluar)
              body?.putIfAbsent("logout_presence", () => DateTime.now().toLocal().toString());
              if ((presenceData.value ?? {}).containsKey("shift")) {
                body?.putIfAbsent("shift", () => presenceData.value?["shift"]);
              }
              // hitung lembur
              Map lemburTime = {};
              var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
              if (body?["shift"] == "0") {
                // lembur by sistem ketika presence keluar
                if (now.isAfter(Utils.customDate(split(shiftPagi["jamKeluar"], true), split(shiftPagi["jamKeluar"], false)))) {
                  lemburTime.putIfAbsent("auto_keluar", () {
                    return {
                      "lembur_keluar": now.toString(),
                      "lembur_masuk": Utils.customDate(split(shiftPagi["jamKeluar"], true), split(shiftPagi["jamKeluar"], false)).toString(),
                    };
                  });
                }
                // lembur by sistem ketika presence masuk
                if (DateTime.parse(presenceData.value?['login_presence']).isBefore(Utils.customDate(split(shiftPagi["jamMasuk"], true), split(shiftPagi["jamMasuk"], false)))) {
                  lemburTime.putIfAbsent("auto_masuk", () {
                    return {
                      "lembur_masuk": presenceData.value?['login_presence'].toString(),
                      "lembur_keluar": Utils.customDate(split(shiftPagi["jamMasuk"], true), split(shiftPagi["jamMasuk"], false)).toString(),
                    };
                  });
                }
                if (lemburTime.isNotEmpty) {
                  print("lembur : $lemburTime");
                  body?.putIfAbsent("lemburan", () => lemburTime);
                }
              } else {
                // lembur by sistem ketika presence keluar
                if (now.isAfter(Utils.customDate(split(shiftSore["jamKeluar"], true), split(shiftSore["jamKeluar"], false)))) {
                  lemburTime.putIfAbsent("auto_keluar", () {
                    return {
                      "lembur_keluar": now.toString(),
                      "lembur_masuk": Utils.customDate(split(shiftSore["jamKeluar"], true), split(shiftSore["jamKeluar"], false)).toString(),
                    };
                  });
                }
                // lembur by sistem ketika presence masuk
                if (DateTime.parse(presenceData.value?['login_presence']).isBefore(Utils.customDate(split(shiftSore["jamMasuk"], true), split(shiftSore["jamMasuk"], false)))) {
                  lemburTime.putIfAbsent("auto_masuk", () {
                    return {
                      "lembur_masuk": presenceData.value?['login_presence'].toString(),
                      "lembur_keluar": Utils.customDate(split(shiftSore["jamMasuk"], true), split(shiftSore["jamMasuk"], false)).toString(),
                    };
                  });
                }

                if (lemburTime.isNotEmpty) {
                  print("lembur : $lemburTime");
                  body?.putIfAbsent("lemburan", () => lemburTime);
                }
              }
              var resLogout = await firestore.addPresence(
                docID,
                body,
                body?["userID"],
              );
              if (resLogout) {
                if ((presenceData.value ?? {}).containsKey("status")) {
                  body?.putIfAbsent("status", () => presenceData.value?["status"]);
                }
              }
            }
          }).catchError((error) {
            print('Error getPresence: $error');
          }).whenComplete(() async {
            bottomSheetController = scaffoldKey.currentState!.showBottomSheet(
              (context) {
                body?.putIfAbsent("docID", () => docID);
                return signInSheet(user: user, body: homeC.isLemburPresence.value ? presenceData.value : body);
              },
              backgroundColor: Colors.transparent,
              enableDrag: false,
            );
            await bottomSheetController?.closed.whenComplete(_reload);
          });
        } catch (e) {
          print('$e');
          Utils.showToast(TypeToast.error, "Terjadi Kesalahan!, Silakan Coba Lagi");
          return;
        }
      } else {
        _isInitializing = false;
        Utils.showToast(TypeToast.error, "Wajah tidak terdaftar, silahkan coba lagi !");
      }
    }
  }

  Widget getBodyWidget() {
    if (_isInitializing) return const Center(child: CircularProgressIndicator());
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

  Widget signInSheet({required User? user, Map<String, dynamic>? body}) {
    if (user == null) {
      return PresenceBottomSheet(
        user: user,
        statusPresence: 2,
      );
    } else {
      if (homeC.isLemburPresence.value) {
        return LemburBottomSheet(
          user: user,
          listPresence: body,
        );
      }
      return PresenceBottomSheet(
        user: user,
        listPresence: body,
      );
    }
  }
}
