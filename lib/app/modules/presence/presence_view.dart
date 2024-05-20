import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/camera_detection_preview.dart';
import 'package:teh_kota/app/widgets/custom_fab_button.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/single_picture.dart';

import '../../locator.dart';
import '../../models/user.model.dart';
import '../../services/camera.service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';
import '../../widgets/signin_form.dart';

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

  _onBackPressed() {
    Navigator.of(context).pop();
  }

  _reload() {
    if (mounted) setState(() => _isPictureTaken = false);
    _start();
  }

  Future<void> onTap() async {
    await takePicture();
    if (_faceDetectorService.faceDetected) {
      User? user = await _mlService.predict();
      var bottomSheetController = scaffoldKey.currentState!.showBottomSheet(
        (context) {
          return signInSheet(user: user);
        },
        backgroundColor: Colors.transparent,
        enableDrag: false,
      );
      bottomSheetController.closed.whenComplete(_reload);
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
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: SvgPicture.asset(
              "assets/ic_back_button.svg",
              color: Color(AppColor.colorWhite),
            ),
          ),
          const Expanded(
            child: CustomText(
              "Presensi Masuk",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  signInSheet({required User? user}) {
    if (user == null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: const Text(
          'User not found 😞',
          style: TextStyle(fontSize: 20),
        ),
      );
    } else {
      return SignInSheet(user: user);
    }
  }
}
