import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
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
    super.dispose();
  }

  Future _start() async {
    setState(() => _isInitializing = true);
    await _cameraService.initialize();
    await _mlService.initialize();
    _faceDetectorService.initialize();
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
            if ((presenceData.value ?? {}).containsKey("login_presence") && (presenceData.value ?? {}).containsKey("logout_presence")) {
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
              Duration lemburTime = const Duration();
              var now = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
              if (body?["shift"] == "0") {
                if (now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!)) {
                  lemburTime = lemburTime + now.difference(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!);
                }
                if (now.isAfter(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!)) {
                  lemburTime = lemburTime + now.difference(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!);
                }
                print("lembur : ${lemburTime.inMinutes}");
                body?.putIfAbsent("lembur_time", () => lemburTime.inMinutes.toString());
              } else {
                if (now.isBefore(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!)) {
                  lemburTime = now.difference(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!);
                }
                if (now.isAfter(Utils.officeHours(TypeShift.shiftSore)["logout_presence"]!)) {
                  lemburTime = lemburTime + now.difference(Utils.officeHours(TypeShift.shiftSore)["logout_presence"]!);
                }
                print("lembur : ${lemburTime.inMinutes}");
                body?.putIfAbsent("lembur_time", () => lemburTime.inMinutes.toString());
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
          }).whenComplete(() {
            bottomSheetController = scaffoldKey.currentState!.showBottomSheet(
              (context) {
                body?.putIfAbsent("docID", () => docID);
                return signInSheet(user: user, body: body);
              },
              backgroundColor: Colors.transparent,
              enableDrag: false,
            );
            bottomSheetController?.closed.whenComplete(_reload);
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
        children: const [
          Expanded(
            child: CustomText(
              "Presensi",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          ),
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
      return PresenceBottomSheet(
        user: user,
        listPresence: body,
      );
    }
  }
}
