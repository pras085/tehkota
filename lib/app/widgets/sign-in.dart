// ignore_for_file: file_names

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../locator.dart';
import '../models/user.model.dart';
import '../services/camera.service.dart';
import '../services/face_detector_service.dart';
import '../services/ml_service.dart';
import 'camera_detection_preview.dart';
import 'camera_header.dart';
import 'signin_form.dart';
import 'single_picture.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
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
    await _mlService.initialize();
    _faceDetectorService.initialize();
    await _cameraService.initialize();
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
        (context) => signInSheet(user: user),
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
    Widget header = CameraHeader(onBackPressed: _onBackPressed);
    Widget body = getBodyWidget();
    Widget? fab;
    if (!_isPictureTaken) {
      fab = InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xFF0F0BDB),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 1,
                offset: Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          width: MediaQuery.of(context).size.width * 0.8,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CAPTURE',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(Icons.camera_alt, color: Colors.white)
            ],
          ),
        ),
      );
    }

    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [body, header],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: fab,
    );
  }

  signInSheet({required User? user}) => user == null
      ? Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(20),
          child: const Text(
            'User not found 😞',
            style: TextStyle(fontSize: 20),
          ),
        )
      : SignInSheet(user: user);
}
