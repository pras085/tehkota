import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../models/user.model.dart';
import '../modules/home/home_controller.dart';

class LemburBottomSheet extends StatefulWidget {
  const LemburBottomSheet({
    Key? key,
    this.user,
    this.statusPresence = 1,
    this.listPresence,
  }) : super(key: key);
  final Map<String, dynamic>? listPresence;
  final User? user;
  final int statusPresence; // 1 : Berhasil, - : Gagal

  @override
  State<LemburBottomSheet> createState() => _LemburBottomSheetState();
}

class _LemburBottomSheetState extends State<LemburBottomSheet> {
  var homeC = Get.find<HomeController>();
  CloudFirestoreService firestore = CloudFirestoreService();
  var typePresence = RxInt(1);
  var body = Rxn<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();

    setState(() {
      body.value = widget.listPresence;
      body.refresh();
    });
    print("LIST PRESENCE : ${body.value}");
  }

  @override
  Widget build(BuildContext context) {
    var shiftPagi = homeC.officeHoursFromDb.value?["pagi"];
    var shiftSore = homeC.officeHoursFromDb.value?["sore"];

    int split(String val, bool pickFirst) {
      if (val.contains(":")) {
        var parts = val.split(":");
        return int.parse(pickFirst ? parts.first : parts.last);
      }
      return int.parse(val); // return the original value if there is no colon
    }

    var isCanPresensiLembur = false;
    if (widget.listPresence?["shift"] == "0") {
      // if ( DateTime.now().hour > split(shiftPagi["jamKeluar"], true)) {
      if (Utils.isTimeGreaterThan(Utils.customShowJustTime(DateTime.now()), Utils.customShowJustTime(Utils.customDate(split(shiftPagi["jamMasuk"], true), split(shiftPagi["jamMasuk"], false))).toString())) {
        isCanPresensiLembur = true;
      }
    } else {
      if (Utils.isTimeGreaterThan(Utils.customShowJustTime(DateTime.now()), Utils.customShowJustTime(Utils.customDate(split(shiftSore["jamMasuk"], true), split(shiftSore["jamMasuk"], false))).toString())) {
        isCanPresensiLembur = true;
      }
    }
    if (isCanPresensiLembur && widget.statusPresence == 1) {
      if (widget.listPresence != null) {
        if (!widget.listPresence!.containsKey("lemburan")) {
          typePresence.value = 1; // pengecekan untuk menampilkan tampilan presensi masuk
        } else if (widget.listPresence!.containsKey("lemburan") && widget.listPresence!['lemburan']["manual"]["lembur_keluar"] == null) {
          typePresence.value = 2; // pengecekan untuk menampilkan tampilan presensi keluar
        } else if (((widget.listPresence!["lemburan"]["manual"] as Map).containsKey("lembur_keluar")) && ((widget.listPresence!["lemburan"]["manual"] as Map).containsKey("lembur_masuk"))) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/ic_berhasil.svg"),
                Utils.gapVertical(24),
                const CustomText(
                  "Anda sudah melakukan presensi lembur hari ini !",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                Utils.gapVertical(24),
              ],
            ),
          );
        }
      }
      return WillPopScope(
        onWillPop: () async {
          if (typePresence.value == 2) {
            // tidak perlu pengecekan karena keluar tidak perlu isi shift
            Get.back();
            return Future.value(true);
          }
          if (typePresence.value == 1) {
            return Future.value(true);
          }
          return Future.value(true);
        },
        child: Obx(() {
          return Container(
            // constraints: BoxConstraints(maxHeight: body.value == null && typePresence.value == 1 ? 450 : 330),
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
            // margin: typePresence.value == 2 ? (selectedTab.value == null ? EdgeInsets.only(top: 550) : EdgeInsets.only(top: 350)) : EdgeInsets.only(top: 500),
            // margin: const EdgeInsets.only(top: 400),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/ic_berhasil.svg"),
                Utils.gapVertical(16),
                CustomText(
                  "Presensi Lembur " "${typePresence.value == 1 ? "Masuk" : "Keluar"}" " Berhasil",
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
                        text: widget.user?.userName,
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
                          Obx(() {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CustomText(
                                  typePresence.value == 1 ? "Jam Masuk" : "Jam Keluar",
                                  color: const Color(AppColor.colorDarkGrey),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                Utils.gapVertical(8),
                                CustomText(
                                  (body.value?["lemburan"]["manual"]["lembur_masuk"] != null && typePresence.value == 1)
                                      ? Utils.formatTime(DateTime.tryParse(body.value?["lemburan"]["manual"]["lembur_masuk"]))
                                      : (body.value?["lemburan"]["manual"]["lembur_keluar"] != null && typePresence.value == 2)
                                          ? Utils.formatTime(DateTime.tryParse(body.value?["lemburan"]["manual"]["lembur_keluar"]))
                                          : "-",
                                  color: const Color(AppColor.colorBlackNormal),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }),
                          Container(
                            color: const Color(AppColor.colorLightGrey),
                            height: 43,
                            width: 1,
                          ),
                          Column(
                            children: [
                              const CustomText(
                                "Shift",
                                color: Color(AppColor.colorDarkGrey),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              Utils.gapVertical(8),
                              Obx(() {
                                return CustomText(
                                  (body.value != null && body.value!["shift"] != null) ? Utils.typeShiftToString(Utils.specifyTypeShift(int.parse(body.value!["shift"]))) : "-",
                                  color: const Color(AppColor.colorBlackNormal),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                );
                              }),
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
        }),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset("assets/ic_gagal.svg"),
          Utils.gapVertical(16),
          CustomText(
            "Presensi ${typePresence.value == 1 ? "Masuk" : "Keluar"} Gagal",
            fontSize: 20,
            color: const Color(AppColor.colorRed),
            fontWeight: FontWeight.w600,
          ),
          Utils.gapVertical(16),
          appButton(
            text: 'Presensi Ulang',
            onPressed: () async {
              Get.back();
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
