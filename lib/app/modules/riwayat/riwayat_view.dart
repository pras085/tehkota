import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/card_presence_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'riwayat_controller.dart';

class RiwayatView extends GetView<RiwayatController> {
  const RiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        appBarSize: 56,
        title: "Riwayat Presensi",
        prefixIcon: [
          InkWell(
            onTap: () {
              Get.toNamed(Routes.REKAP);
            },
            child: SvgPicture.asset(
              "assets/ic_recap.svg",
            ),
          )
        ],
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
                  const CustomText(
                    "Hari Ini",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().month - 1),
                        lastDate: DateTime(DateTime.now().month + 6),
                      );
                    },
                    child: const CustomText(
                      "Pilih Tanggal",
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(AppColor.colorGreen),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: ListView.builder(
                itemCount: controller.listDataPresence.length,
                itemBuilder: (context, i) {
                  return CardPresenceDetail(controller.listDataPresence[i]);
                },
              ))
            ],
          ),
        ),
      ),
    );
  }
}
