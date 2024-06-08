import 'package:get/get.dart';

import 'recap_controller.dart';

class RekapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RekapController>(
      () => RekapController(),
    );
  }
}
