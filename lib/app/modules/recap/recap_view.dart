import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/modules/recap/recap_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/card_recap_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../../utils/utils.dart';

class RekapView extends GetView<RekapController> {
  const RekapView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RekapController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        customBody: SizedBox(
          width: Get.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!Utils.isAdmin.value)
                InkWell(
                  onTap: () => Get.back(),
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: SvgPicture.asset(
                        "assets/ic_back_button.svg",
                      ),
                    ),
                  ),
                ),
              const CustomText(
                "Rekap Presensi",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              if (Utils.isAdmin.value)
                InkWell(
                  onTap: () {
                    // Get.toNamed(Routes.REKAP);
                  },
                  child: const Icon(Icons.print),
                )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: Get.width,
          height: Get.height,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    Utils.formatTanggaLocal(DateTime.now().toString(), format: "MMMM yyyy"),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  GestureDetector(
                      onTap: () {
                        print("decrement");
                      },
                      child: SvgPicture.asset("assets/ic_back_button.svg")),
                  Utils.gapHorizontal(12),
                  GestureDetector(
                      onTap: () {
                        print("icnrements");
                      },
                      child: SvgPicture.asset("assets/ic_forward_button.svg")),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: controller.listDataPresence.length,
                itemBuilder: (context, i) {
                  return CardRecapDetail(controller.listDataPresence[i]);
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}