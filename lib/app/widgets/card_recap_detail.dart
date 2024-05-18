import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

class CardRecapDetail extends StatelessWidget {
  final Map listPresence;

  const CardRecapDetail(this.listPresence, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      width: Get.width,
      height: 133,
      decoration: const BoxDecoration(
        color: Color(AppColor.colorWhite),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/ic_profile.svg",
                height: 24,
                width: 24,
              ),
              Utils.gapHorizontal(6),
              Expanded(
                child: CustomText(
                  listPresence["name"],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            width: Get.width,
            height: 1,
            color: const Color(AppColor.colorLightGrey),
            margin: const EdgeInsets.symmetric(vertical: 12),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomText(
                                listPresence["presensi_masuk"] ?? "-",
                                color: const Color(AppColor.colorGreen),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                              const CustomText(
                                "Hadir",
                                color: Color(AppColor.colorDarkGrey),
                                fontSize: 10,
                              ),
                            ],
                          ),
                          Container(
                            color: const Color(AppColor.colorLightGrey),
                            height: 44,
                            width: 1,
                          ),
                          Column(
                            children: [
                              CustomText(
                                listPresence["presensi_keluar"] ?? "-",
                                color: const Color(AppColor.colorRed),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                              const CustomText(
                                "Terlambat",
                                color: Color(AppColor.colorDarkGrey),
                                fontSize: 10,
                              ),
                            ],
                          ),
                          Container(
                            color: const Color(AppColor.colorLightGrey),
                            height: 44,
                            width: 1,
                          ),
                          Column(
                            children: [
                              CustomText(
                                listPresence["presensi_masuk"] ?? "-",
                                color: const Color(AppColor.colorBlue),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                              ),
                              const CustomText(
                                "Lembur",
                                color: Color(AppColor.colorDarkGrey),
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
