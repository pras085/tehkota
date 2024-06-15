// ignore_for_file: invalid_use_of_protected_member, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
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
    Get.put(HomeController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        appBarSize: 68,
        customBody: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [Image.asset("assets/logo_splash.png"), const SizedBox(width: 12), _profileWidget()],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => Get.toNamed(Routes.REGISTER),
                child: SvgPicture.asset(
                  "assets/ic_data_karyawan.svg",
                  height: 24,
                  width: 24,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SmartRefresher(
        controller: controller.refreshC,
        onRefresh: () async {
          await controller.getDataFromApi();
          await Future.delayed(const Duration(seconds: 1));
          controller.refreshC.refreshCompleted();
        },
        child: SingleChildScrollView(
          controller: controller.scrollC,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            width: Get.width,
            height: Get.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shiftTodayWidget(),
                _historyPresenceWidget(),
              ],
            ),
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
    DateTime now = DateTime.now();
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
                // (now.isAfter(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!) && now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!)) ? Utils.typeShiftToString(TypeShift.shiftPagi) : Utils.typeShiftToString(TypeShift.shiftSore),
                (now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!)) || (now.isAfter(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!) && now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!))
                    ? Utils.typeShiftToString(TypeShift.shiftPagi)
                    : Utils.typeShiftToString(TypeShift.shiftSore),
                color: const Color(AppColor.colorWhite),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Utils.gapVertical(16),
        Row(
          children: [
            if ((now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!)) || now.isAfter(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!) && now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!)) ...[
              _cardShiftTodayWidget(
                "Presensi Masuk",
                Utils.typeShiftToString(TypeShift.shiftPagi),
                Utils.customShowJustTime(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!),
              ),
              Utils.gapHorizontal(16),
              _cardShiftTodayWidget(
                "Presensi Keluar",
                Utils.typeShiftToString(TypeShift.shiftPagi),
                Utils.customShowJustTime(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!),
              ),
            ] else if (now.isAfter(Utils.pickOfficeHours(((Utils.officeHours(TypeShift.shiftSore)) as Map)["login_presence"])) && now.isBefore(((Utils.officeHours(TypeShift.shiftSore)) as Map)["logout_presence"])) ...[
              _cardShiftTodayWidget(
                "Presensi Masuk",
                Utils.typeShiftToString(TypeShift.shiftSore),
                Utils.customShowJustTime(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!),
              ),
              Utils.gapHorizontal(16),
              _cardShiftTodayWidget(
                "Presensi Keluar",
                Utils.typeShiftToString(TypeShift.shiftSore),
                Utils.customShowJustTime(Utils.officeHours(TypeShift.shiftSore)["logout_presence"]!),
              ),
            ]
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
                onTap: () => Get.toNamed(Routes.HISTORY),
                child: const CustomText(
                  "Lihat Semua",
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColor.colorGreen),
                ),
              ),
            ],
          ),
          Obx(() {
            return Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: controller.listDataPresence.value.length,
                controller: controller.scrollC,
                itemBuilder: (context, i) {
                  return CardPresenceDetail(controller.listDataPresence.value[i]);
                },
              ),
            );
          })
        ],
      ),
    );
  }
}
