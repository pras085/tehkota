import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

class CardRecapDetail extends StatelessWidget {
  final Map listDataPresence;
  final bool isAdmin;
  final VoidCallback? onTap;

  const CardRecapDetail(
    this.listDataPresence, {
    super.key,
    this.isAdmin = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Menghitung totalPresence dalam jam
    double totalPresenceInHours = listDataPresence["totalPresence"].toDouble();

    // Menghitung gaji berdasarkan aturan yang diberikan
    double gajiPerJam = 6600;
    double gajiHadir = 0;
    if (totalPresenceInHours >= 12) {
      gajiHadir = 80000;
    } else if (totalPresenceInHours >= 6) {
      gajiHadir = 40000;
    } else {
      gajiHadir = totalPresenceInHours * gajiPerJam;
    }

    // Menghitung potongan jika terlambat per 30 menit
    double gajiTerpotong = 0;
    if (listDataPresence["totalLate"] != 0) {
      int terlambatTime = listDataPresence["totalLate"]; // Kita anggap terlambatTime sudah dalam menit
      gajiTerpotong = (terlambatTime / 30).ceil() * 3300;
    }

    // Menghitung gaji lembur
    int gajiLembur = listDataPresence["totalOvertime"] * 20000;

    // Menghitung gaji total
    double gajiTotal = gajiHadir - gajiTerpotong + gajiLembur;

    return Container(
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
              CustomText(
                listDataPresence["userName"].toString(),
                fontSize: 12,
              ),
              const Spacer(),
              InkWell(
                onTap: onTap,
                child: const Icon(Icons.print),
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
                              "${listDataPresence["totalPresence"]} Jam",
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
                              '${listDataPresence["totalLate"]} Jam',
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
                              "${listDataPresence["totalOvertime"]} Jam",
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
                  gajiHadir != 0 ? "Rp. ${gajiHadir.toStringAsFixed(0)}" : "-",
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
                  gajiLembur != 0 ? "Rp. ${gajiLembur.toStringAsFixed(0)}" : "-",
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
                  gajiTerpotong != 0 ? "Rp. ${gajiTerpotong.toStringAsFixed(0)}" : "-",
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
                  gajiTotal != 0 ? "Rp. ${gajiTotal.toStringAsFixed(0)}" : "-",
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
