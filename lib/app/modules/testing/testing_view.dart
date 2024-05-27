import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';
import 'package:teh_kota/app/widgets/sign-up.dart';

import '../../widgets/sign-in.dart';
import 'testing_controller.dart';

class TestingView extends GetView<TestingController> {
  const TestingView({super.key});
  @override
  Widget build(BuildContext context) {
    Get.put(TestingController());
    return Obx(() {
      return WillPopScope(
        onWillPop: () {
          if (controller.viewType.value == ViewType.create) {
            controller.viewType.value = ViewType.list;
            return Future.value(false);
          } else {
            Get.back();
            return Future.value(false);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SizedBox(
            width: Get.width,
            height: Get.height,
            child: !controller.loading.value
                ? controller.viewType.value == ViewType.create
                    ? createWidget(context)
                    : listWidget()
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ),
      );
    });
  }

  Widget listWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CustomAppBar(
          title: "Data Karyawan",
          prefixIcon: [
            GestureDetector(
                onTap: () {
                  controller.viewType.value = ViewType.create;
                },
                child: SvgPicture.asset("assets/ic_add_karyawan.svg"))
          ],
        ),
        if (controller.listKaryawan.isNotEmpty)
          Container(
          )
        else
          Container(
            width: Get.width,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/ic_no_data.svg",
                ),
                SizedBox(height: 12),
                CustomText(
                  "Tidak ada data",
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget createWidget(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const SignIn(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(AppColor.colorGreen),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'LOGIN',
                  style: TextStyle(color: Color(0xFF0F0BDB)),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.login, color: Color(0xFF0F0BDB))
              ],
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (BuildContext context) => const SignUp()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF0F0BDB),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
                  blurRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'SIGN UP',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 10,
                ),
                Icon(Icons.person_add, color: Colors.white)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
