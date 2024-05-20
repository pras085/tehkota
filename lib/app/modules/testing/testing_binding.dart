import 'package:get/get.dart';

import 'testing_controller.dart';

class TestingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestingController>(
      () => TestingController(),
    );
  }
}
