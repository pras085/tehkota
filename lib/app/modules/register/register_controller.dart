import 'package:get/get.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';

import '../../db/databse_helper.dart';
import '../../locator.dart';
import '../../services/camera.service.dart';
import '../../services/face_detector_service.dart';
import '../../services/ml_service.dart';

enum ViewType {
  list,
  create,
}

class RegisterController extends GetxController {
  var viewType = ViewType.list.obs;
  // Face Recognition
  final MLService _mlService = locator<MLService>();
  final FaceDetectorService _mlKitService = locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();
  var loading = false.obs;
  DatabaseHelper dbHelper = DatabaseHelper.instance;
  CloudFirestoreService firestore = CloudFirestoreService();

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
