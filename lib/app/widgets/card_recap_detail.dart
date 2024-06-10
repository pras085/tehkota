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
    var gajiHadir = int.parse(listPresence["totalPresence"].toString()) * 40;
    var gajiTerpotong = int.parse(listPresence["totalLate"].toString()) * 10;
    var gajiLembur = int.parse(listPresence["totalOvertime"].toString()) * 20;
    var gajiTotal = gajiHadir - gajiTerpotong + gajiLembur;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      width: Get.width,
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
                  listPresence["userName"].toString(),
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
          Row(
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
                              "${listPresence["totalPresence"]} Hadir",
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
                              '${listPresence["totalLate"]} Jam',
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
                              "${listPresence["totalOvertime"]} Jam",
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
          if (Utils.isAdmin.value) ...[
            Container(
              width: Get.width,
              height: 1,
              color: const Color(AppColor.colorLightGrey),
              margin: const EdgeInsets.symmetric(vertical: 12),
            ),
            Row(
              children: [
                const CustomText(
                  "Gaji Utama",
                  fontSize: 12,
                ),
                const Spacer(),
                CustomText(
                  gajiHadir != 0 ? "Rp. $gajiHadir" ".000" : "-",
                  fontSize: 12,
                )
              ],
            ),
            Utils.gapVertical(4),
            Row(
              children: [
                const CustomText(
                  "Lembur",
                  fontSize: 12,
                ),
                const Spacer(),
                CustomText(
                  gajiLembur != 0 ? "Rp. $gajiLembur" ".000" : "-",
                  fontSize: 12,
                )
              ],
            ),
            Utils.gapVertical(4),
            Row(
              children: [
                const CustomText(
                  "Potongan",
                  fontSize: 12,
                  color: Color(AppColor.colorRed),
                ),
                const Spacer(),
                CustomText(
                  gajiTerpotong != 0 ? "Rp. $gajiTerpotong" ".000" : "-",
                  fontSize: 12,
                  color: const Color(AppColor.colorRed),
                )
              ],
            ),
            Container(
              width: Get.width,
              height: 1,
              color: const Color(AppColor.colorLightGrey),
              margin: const EdgeInsets.symmetric(vertical: 12),
            ),
            Row(
              children: [
                const CustomText(
                  "Total Gaji",
                  fontSize: 12,
                ),
                const Spacer(),
                CustomText(
                  gajiTotal != 0 ? "Rp. $gajiTotal" ".000" : "-",
                  fontSize: 12,
                  color: const Color(AppColor.colorGreen),
                )
              ],
            ),
          ]
        ],
      ),
    );
  }
}
