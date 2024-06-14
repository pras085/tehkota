import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/page_controller.dart';

class ProfileController extends GetxController {
  CloudFirestoreService firestore = CloudFirestoreService();

  @override
  void onInit() {
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

  Future onTapButton() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    Utils.isAdmin.value = false;
    Utils.isLoggedIn.value = false;
    Get.offAll(() => const PageViewUserController());
  }
}
