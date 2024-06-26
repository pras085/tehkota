import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/card_presence_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HistoryController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        appBarSize: 135,
        customBody: Obx(() {
          return SizedBox(
            width: Get.width,
            child: Column(
              children: [
                Row(
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
                      "Riwayat Presensi",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    if (!Utils.isAdmin.value)
                      InkWell(
                        onTap: () {
                          Get.toNamed(Routes.RECAP);
                        },
                        child: SvgPicture.asset(
                          "assets/ic_recap.svg",
                        ),
                      )
                  ],
                ),
                Utils.gapVertical(16),
                Expanded(
                  child: CustomSearchField(
                    controller: controller.searchC,
                    isDisable: controller.listDataPresence.isEmpty,
                    onSubmit: (value) {
                      print("TEST $value");
                      controller.getDataFromApi(
                        DateFormat("dd-MM-y").format(controller.selectedDate!),
                        searchName: value.isNotEmpty ? value : null,
                      );
                    },
                    onClearTap: () {
                      controller.getDataFromApi(
                        DateFormat("dd-MM-y").format(controller.selectedDate!),
                        searchName: null,
                      );
                    },
                  ),
                )
              ],
            ),
          );
        }),
      ),
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CustomText(
                    "Hari Ini",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      controller.selectDate(context);
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
            ),
            Obx(() {
              return Expanded(
                child: (controller.listDataPresence.isEmpty)
                    ? Container(
                        width: Get.width,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                      )
                    : ListView.builder(
                        itemCount: controller.listDataPresence.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: CardPresenceDetail(controller.listDataPresence[i]),
                          );
                        },
                      ),
              );
            })
          ],
        ),
      ),
    );
  }
}
