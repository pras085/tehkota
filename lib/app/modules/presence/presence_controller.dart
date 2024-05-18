import 'package:get/get.dart';
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class PresenceController extends GetxController {
  @override
  void onInit() async {
    // faceDetector = FaceDetector(options: options);
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

// final List<Face> faces = await faceDetector.processImage(inputImage);

// for (Face face in faces) {
//   final Rect boundingBox = face.boundingBox;

//   final double? rotX = face.headEulerAngleX; // Head is tilted up and down rotX degrees
//   final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
//   final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees

//   // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
//   // eyes, cheeks, and nose available):
//   final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
//   if (leftEar != null) {
//     final Point<int> leftEarPos = leftEar.position;
//   }

//   // If classification was enabled with FaceDetectorOptions:
//   if (face.smilingProbability != null) {
//     final double? smileProb = face.smilingProbability;
//   }

//   // If face tracking was enabled with FaceDetectorOptions:
//   if (face.trackingId != null) {
//     final int? id = face.trackingId;
//   }
// }
}
