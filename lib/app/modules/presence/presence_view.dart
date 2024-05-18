import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'presence_controller.dart';

class PresenceView extends GetView<PresenceController> {
  const PresenceView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(PresenceController());
    return Obx(() {
      return Scaffold(
        body: Container(
          color: Colors.white,
          width: Get.width,
          height: Get.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo_splash.png",
                height: 171,
                width: 171,
              ),
              // SvgPicture.asset(
              //   "assets/logo_splash.svg",
              //   width: 100,
              //   height: 100,
              // ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          width: Get.width,
          height: 50,
          child: const CustomText(
            "",
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
        ),
      );
    });
  }
}
