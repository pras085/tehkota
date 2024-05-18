import 'package:get/get.dart';

import 'presence_controller.dart';

class PresenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresenceController>(
      () => PresenceController(),
    );
  }
}
