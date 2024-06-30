import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        customBody: const CustomText(
          "Profile",
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        width: Get.width,
        height: Get.height,
        child: FutureBuilder(
          future: controller.firestore.getAdmin(),
          builder: (context, snapshot) {
            // check our connection (loading|error)
            if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error fetching data: ${snapshot.data}');
            } else if (snapshot.hasData && !snapshot.data!.exists) {
              return Container(
                width: Get.width,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/ic_no_data.svg",
                    ),
                    const SizedBox(height: 12),
                    const CustomText(
                      "Tidak ada data",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ],
                ),
              );
            }
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CustomText(
                            "Admin",
                            color: Color(AppColor.colorBlack),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          CustomText(
                            data["email"],
                            color: const Color(AppColor.colorDarkGrey),
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SvgPicture.asset("assets/ic_profile.svg"),
                    ),
                  ],
                ),
                Utils.gapVertical(16),
                // Row(x
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(
                //       margin: const EdgeInsets.only(right: 12),
                //       padding: const EdgeInsets.all(16),
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(12),
                //       ),
                //       child: const Icon(
                //         Icons.lock,
                //         color: Color(0xFFA0AABF),
                //       ),
                //     ),
                //     const CustomText(
                //       "Ubah Password",
                //       fontWeight: FontWeight.w600,
                //       fontSize: 12,
                //     ),
                //     Spacer(),
                //     RotatedBox(quarterTurns: 90, child: SvgPicture.asset("assets/ic_back_button.svg")),
                //   ],
                // ),
                // Utils.gapVertical(16),
                InkWell(
                  onTap: () => Get.toNamed(Routes.SETTING),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings,color: Colors.green),
                      ),
                      const CustomText(
                        "Setting",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      const Spacer(),
                      RotatedBox(quarterTurns: 90, child: SvgPicture.asset("assets/ic_back_button.svg")),
                    ],
                  ),
                ),
                Utils.gapVertical(16),
                InkWell(
                  onTap: () => controller.onTapButton(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SvgPicture.asset("assets/ic_logout.svg"),
                      ),
                      const CustomText(
                        "Logout",
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      const Spacer(),
                      RotatedBox(quarterTurns: 90, child: SvgPicture.asset("assets/ic_back_button.svg")),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
