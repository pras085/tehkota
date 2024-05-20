import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/routes/app_pages.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/card_presence_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController(), permanent: true);
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        appBarSize: 68,
        customBody: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onDoubleTap: () => Get.toNamed(Routes.TESTING),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [Image.asset("assets/logo_splash.png"), const SizedBox(width: 12), _profileWidget()],
                ),
              ),
            ),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(Icons.people_alt),
              // child: SvgPicture.asset(
              //   "assets/ic_cs.svg",
              //   height: 20,
              //   width: 20,
              // ),
            ),
          ],
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
              _shiftTodayWidget(),
              _historyPresenceWidget(),
            ],
          ),
        ),
      ),
    );
  }

  _profileWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomText(
          "Teh Kota",
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        CustomText(
          Utils.branchName,
          fontWeight: FontWeight.w400,
          fontSize: 10,
        )
      ],
    );
  }

  _shiftTodayWidget() {
    return Column(
      children: [
        Row(
          children: [
            CustomText(
              Utils.formatTanggaLocal(DateTime.now().toString()),
              fontWeight: FontWeight.w500,
              color: const Color(AppColor.colorBlack),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(AppColor.colorGreen),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: CustomText(
                controller.shiftToday[0]["name"] ?? "",
                color: const Color(AppColor.colorWhite),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Utils.gapVertical(16),
        Row(
          children: [
            _cardShiftTodayWidget(
              "Presensi Masuk",
              controller.shiftToday[0]['name'] ?? "",
              controller.shiftToday[0]['presensi_masuk'] ?? "",
            ),
            Utils.gapHorizontal(16),
            _cardShiftTodayWidget(
              "Presensi Keluar",
              controller.shiftToday[0]['name'] ?? "",
              controller.shiftToday[0]['presensi_keluar'] ?? "",
            ),
          ],
        ),
        Utils.gapVertical(16),
      ],
    );
  }

  Widget _cardShiftTodayWidget(String title, String subTitle, String value) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(AppColor.colorWhite),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(AppColor.colorGreen),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  width: 28,
                  height: 28,
                  child: SvgPicture.asset(
                    "assets/ic_login.svg",
                    height: 20,
                    width: 20,
                  ),
                ),
                Utils.gapHorizontal(8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    CustomText(
                      subTitle,
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: const Color(AppColor.colorDarkGrey),
                    ),
                  ],
                ),
              ],
            ),
            Utils.gapVertical(10),
            Row(
              children: [
                CustomText(
                  value,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                Utils.gapHorizontal(4),
                const CustomText(
                  "WIB",
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColor.colorDarkGrey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _historyPresenceWidget() {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const CustomText(
                "Riwayat Presensi",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.RIWAYAT),
                child: const CustomText(
                  "Lihat Semua",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColor.colorGreen),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.listDataPresence.length,
              itemBuilder: (context, i) {
                return CardPresenceDetail(controller.listDataPresence[i]);
              },
            ),
          )
        ],
      ),
    );
  }
}
