import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/card_presence_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import 'admin_controller.dart';

class AdminView extends GetView<AdminController> {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
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
              child: SvgPicture.asset(
                "assets/ic_cs.svg",
                height: 20,
                width: 20,
              ),
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
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _bottomNavBar() {
    return ConvexAppBar(
      cornerRadius: 22,
      backgroundColor: const Color(AppColor.colorWhite),
      activeColor: const Color(AppColor.colorGreen),
      color: const Color(AppColor.colorDarkGrey),
      style: TabStyle.fixed,
      elevation: 0,
      items: [
        TabItem(
          title: "Beranda",
          fontFamily: "poppins",
          icon: SvgPicture.asset(
            "assets/ic_nav_home.svg",
            color: const Color(AppColor.colorDarkGrey),
          ),
          activeIcon: SvgPicture.asset(
            "assets/ic_nav_home.svg",
            color: const Color(AppColor.colorGreen),
          ),
        ),
        TabItem(
          icon: Container(
            height: 80,
            width: 55,
            padding: const EdgeInsets.all(11),
            decoration: const BoxDecoration(
              color: Color(AppColor.colorGreen),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              "assets/ic_face_scan.svg",
            ),
          ),
        ),
        TabItem(
          title: "Login",
          fontFamily: "poppins",
          icon: SvgPicture.asset(
            "assets/ic_nav_login.svg",
            color: const Color(AppColor.colorDarkGrey),
          ),
          activeIcon: SvgPicture.asset(
            "assets/ic_nav_login.svg",
            color: const Color(AppColor.colorGreen),
          ),
        ),
      ],
      initialActiveIndex: 0,
      onTap: (int i) => print('click index=$i'),
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
            children: const [
              CustomText(
                "Riwayat Presensi",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              CustomText(
                "Lihat Semua",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(AppColor.colorGreen),
              ),
            ],
          ),
          CardPresenceDetail(controller.listDataPresence[0]),
          // ListView.builder(
          //   shrinkWrap: true,
          //   itemBuilder: (context, index) {
          //     return _cardHistoryPresenceWidget();
          //   },
          // )
        ],
      ),
    );
  }
}
