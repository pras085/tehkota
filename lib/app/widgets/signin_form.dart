import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../models/user.model.dart';

class SignInSheet extends StatelessWidget {
  const SignInSheet({
    Key? key,
    required this.user,
    this.statusPresence = 1,
    this.listPresence,
    this.typePresence = 1,
  }) : super(key: key);
  final Map? listPresence;
  final User user;
  final int statusPresence;
  final int typePresence;
  // Status Presence
  // 1 : Presensi Berhasil
  // 2 : Presensi Gagal

  // Type Presence
  // 1 : Presensi Masuk
  // 2 : Presensi Keluar

  @override
  Widget build(BuildContext context) {
    if (statusPresence == 1) {
      return Container(
        height: 337,
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            SvgPicture.asset("assets/ic_berhasil.svg"),
            Utils.gapVertical(16),
            CustomText(
              "Presensi " "${typePresence == 1 ? "Masuk" : "Keluar"}" " Berhasil",
              fontSize: 20,
              color: const Color(AppColor.colorGreen),
              fontWeight: FontWeight.w600,
            ),
            Utils.gapVertical(4),
            Text.rich(
              TextSpan(
                text: "Selamat datang ",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(AppColor.colorBlack),
                  fontFamily: "poppins",
                ),
                children: <InlineSpan>[
                  TextSpan(
                    text: user.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(
                    text: ", Semangat kerjanya untuk hari ini!",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  )
                ],
              ),
              maxLines: 2,
            ),
            Utils.gapVertical(16),
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
                            listPresence?["presensi_masuk"] ?? "-",
                            color: const Color(AppColor.colorBlackNormal),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          const CustomText(
                            "Masuk",
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
                            listPresence?["presensi_keluar"] ?? "-",
                            color: const Color(AppColor.colorBlackNormal),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          const CustomText(
                            "Keluar",
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
                            listPresence != null && listPresence?["presensi_masuk"] != null && listPresence?["presensi_keluar"] != null
                                ? Utils.funcHourCalculate(
                                    listPresence!["presensi_masuk"].toString().isNotEmpty ? listPresence!["presensi_masuk"] : "0.0",
                                    listPresence!["presensi_keluar"].toString().isNotEmpty ? listPresence!["presensi_keluar"] : "0.0",
                                    jamLembur: (listPresence!["lembur"] ?? "0.0").toString().isNotEmpty ? listPresence!["lembur"] : "0.0",
                                  )
                                : "-",
                            color: const Color(AppColor.colorBlackNormal),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          const CustomText(
                            "Total",
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
      );
    }
    return Container(
      height: 337,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          SvgPicture.asset("assets/ic_gagal.svg"),
          Utils.gapVertical(16),
          const CustomText(
            "Presensi Masuk Gagal",
            fontSize: 20,
            color: Color(AppColor.colorRed),
            fontWeight: FontWeight.w600,
          ),
          // Text.rich(
          //   TextSpan(
          //     text: "Selamat datang ",
          //     style: const TextStyle(
          //       fontSize: 12,
          //       fontWeight: FontWeight.w400,
          //       color: Color(AppColor.colorBlack),
          //       fontFamily: "poppins",
          //     ),
          //     children: <InlineSpan>[
          //       TextSpan(
          //         text: user.user,
          //         style: const TextStyle(
          //           fontWeight: FontWeight.w600,
          //         ),
          //       ),
          //       const TextSpan(
          //         text: ", Semangat kerjanya untuk hari ini!",
          //         style: TextStyle(fontWeight: FontWeight.w400),
          //       )
          //     ],
          //   ),
          //   maxLines: 2,
          // ),
          Utils.gapVertical(16),
          appButton(
            text: 'Presensi Ulang',
            onPressed: () async {
              // _signIn(context, user); Implemntasi Presensi
            },
          )
        ],
      ),
    );
  }
}

appButton({required String text, required VoidCallback onPressed}) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: const Color(AppColor.colorGreen)),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 13.5),
      width: Get.width,
      height: 60,
      child: CustomText(
        text,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(AppColor.colorGreen),
      ),
    ),
  );
}
