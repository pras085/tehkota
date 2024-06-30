import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/modules/recap_sallary/recap_sallary_controller.dart';
import 'package:teh_kota/app/modules/settings/settings_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/card_recap_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../../utils/utils.dart';
import 'package:printing/printing.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RekapController());
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(AppColor.colorBgGray),
        appBar: CustomAppBar(
          title: "Settings",
        ),
        body: controller.settings.value.isNotEmpty ? content() : const Center(child: CircularProgressIndicator()),
      );
    });
  }

  Widget content() {
    return Container(
      width: Get.width,
      height: Get.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const CustomText(
              "Perhitungan Gaji",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          CustomTextFormField(
            title: "Gaji per jam",
            controller: controller.textFieldC[0],
            hintText: "Contoh : 5000",
            isOnlyNumber: true,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomTextFormField(
                  title: "Gaji /6 jam",
                  controller: controller.textFieldC[1],
                  hintText: "Contoh : 5000",
                  isOnlyNumber: true,
                ),
                SizedBox(width: 100),
                CustomTextFormField(
                  title: "Gaji /12 jam",
                  controller: controller.textFieldC[2],
                  hintText: "Contoh : 5000",
                  isOnlyNumber: true,
                ),
              ],
            ),
          ),
          CustomTextFormField(
            title: "Lembur",
            controller: controller.textFieldC[3],
            hintText: "Contoh : 5000",
            isOnlyNumber: true,
          ),
          CustomTextFormField(
            title: "Potongan per 30 menit",
            controller: controller.textFieldC[4],
            hintText: "Contoh : 5000",
            isOnlyNumber: true,
          ),
          const Spacer(),
          if (controller.isEdit.value)
            InkWell(
              onTap: () {
                controller.updateOnLocal();
              },
              child: Container(
                width: Get.width,
                decoration: BoxDecoration(
                  color: const Color(AppColor.colorGreen),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: const CustomText(
                  "Simpan",
                  color: Colors.white,
                ),
              ),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
