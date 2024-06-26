import 'package:get/get.dart';

import 'recap_sallary_controller.dart';

class RekapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RekapController>(
      () => RekapController(),
    );
  }
}
