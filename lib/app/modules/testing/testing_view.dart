import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
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
      return Scaffold(backgroundColor: Colors.white,
        body: SizedBox(
          width: Get.width,
          height: Get.height,
          child: controller.loading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                ),
        ),
      );
    });
  }
}
