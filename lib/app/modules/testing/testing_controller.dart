import 'package:get/get.dart';

import '../../locator.dart';
import '../../services/camera.service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class TestingController extends GetxController {
  // Face Recognition
  final MLService _mlService = locator<MLService>();
  final FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  var loading = false.obs;

  @override
  void onInit() async {
    // faceDetector = FaceDetector(options: options);
    super.onInit();
    _initializeServices();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  _initializeServices() async {
    loading.value = true;
    await _cameraService.initialize();
    await _mlService.initialize();
    _mlKitService.initialize();
    loading.value = false;
  }
}
