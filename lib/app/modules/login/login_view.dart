import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../../utils/utils.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut<LoginController>(() => LoginController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: Get.width,
            height: Get.height,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset("assets/logo_splash.png"),
                ),
                Utils.gapVertical(16),
                const CustomText(
                  "Masuk Admin",
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                Utils.gapVertical(16),
                CustomTextFormField(
                  title: "Email",
                  controller: controller.emailC,
                  hintText: "Email",
                ),
                CustomTextFormField(
                  title: "Password",
                  controller: controller.passC,
                  hintText: "Password",
                  isPassword: true,
                ),
                Utils.gapVertical(17),
                GestureDetector(
                  onTap: () => controller.tapLoginButton(),
                  child: Container(
                    width: Get.width,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Color(AppColor.colorGreen), borderRadius: BorderRadius.all(Radius.circular(12))),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: const CustomText(
                      "Masuk",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColor.colorWhite),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
