import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:teh_kota/app/modules/home/home_controller.dart';
import 'package:teh_kota/app/widgets/page_controller.dart';

class SplashController extends GetxController {
  var packageInfo = Rxn<PackageInfo>();
  @override
  void onInit() async {
    super.onInit();
    packageInfo.value = await PackageInfo.fromPlatform();
    await Future.delayed(const Duration(seconds: 1)).then((value) => Get.offAll(() => const PageViewController()));
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
