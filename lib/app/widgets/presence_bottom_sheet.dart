import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/data/cloud_firestore_service.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../models/user.model.dart';

class PresenceBottomSheet extends StatefulWidget {
  const PresenceBottomSheet({
    Key? key,
    this.user,
    this.statusPresence = 1,
    this.listPresence,
    this.typePresence = 1,
  }) : super(key: key);
  final Map? listPresence;
  final User? user;
  final int statusPresence; // 1 : Berhasil, - : Gagal
  final int typePresence; // 1 : Masuk, - : Keluar

  @override
  State<PresenceBottomSheet> createState() => _PresenceBottomSheetState();
}

class _PresenceBottomSheetState extends State<PresenceBottomSheet> {
  // Status Presence
  @override
  Widget build(BuildContext context) {
    CloudFirestoreService firestore = CloudFirestoreService();
    final selectedTab = RxnInt(); // Variabel untuk menyimpan id tombol yang terpilih
    int? typePresence;
    setState(() {
      typePresence = widget.typePresence;
    });

    void setFieldShift() async {
      await firestore.getPresence(widget.listPresence?["docID"])?.then((value) async {
        // var idUser = value['userID'];
        if (value.data()?.containsKey(widget.listPresence?["userID"]) ?? false) {
          var resAdd = await firestore.addPresence(
            widget.listPresence?["docID"],
            {"shift": selectedTab.value.toString()},
            widget.listPresence?["userID"],
          );
          if (!resAdd) {
            return;
          } else {
            Get.back();
            Get.back();
          }
        }
      }).catchError((error) {
        print('Error getPresence: $error');
        return;
      });
    }

    Widget shiftButton(TypeShift typeShift) {
      return InkWell(
        onTap: () {
          selectedTab.value = Utils.specifyTypeShift(typeShift, fromInt: false);
          setFieldShift();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selectedTab.value == Utils.specifyTypeShift(typeShift, fromInt: false) ? const Color(AppColor.colorLightGreen) : Colors.transparent),
          ),
          child: CustomText(
            Utils.typeShiftToString(typeShift),
            fontSize: 14,
          ),
        ),
      );
    }

    Widget generateShiftButton() {
      var now = DateTime.now();
      if (now.isAfter(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!) && now.isBefore(Utils.officeHours(TypeShift.shiftPagi)["logout_presence"]!)) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            shiftButton(TypeShift.shiftPagi),
            shiftButton(TypeShift.shiftFull),
          ],
        );
      } else if (now.isAfter(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!) && now.isBefore(Utils.officeHours(TypeShift.shiftSore)["logout_presence"]!)) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            shiftButton(TypeShift.shiftSore),
            shiftButton(TypeShift.shiftFull),
          ],
        );
      }
      return const SizedBox();
    }

    if (widget.statusPresence == 1) {
      if (widget.listPresence != null && widget.listPresence!.containsKey("logout_presence")) {
        typePresence = 2;
      } // pengecekan untuk menampilkan tampilan presensi keluar
      return WillPopScope(
        onWillPop: () async {
          if (typePresence == 2) {
            // tidak perlu pengecekan karena keluar tidak perlu isi shift
            Get.back();
            return Future.value(true);
          }
          if (selectedTab.value == null) {
            Utils.showToast(TypeToast.error, "Pilih shift terlebih dahulu !");
            return Future.value(false);
          }
          if (typePresence == 1) {
            // TODO :
          }
          return Future.value(true);
        },
        child: Container(
          constraints: BoxConstraints(maxHeight: typePresence == 2 ? 350 : 470),
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
              if (typePresence == 1)
                Container(
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(AppColor.colorLightGrey),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const CustomText(
                        "Pilih shift anda",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      Utils.gapVertical(28),
                      Obx(() => generateShiftButton()),
                    ],
                  ),
                ),
              if (typePresence == 1) Utils.gapVertical(16),
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
                              widget.listPresence?["login_presence"] != null ? Utils.formatTime(DateTime.tryParse(widget.listPresence?["login_presence"])) : "-",
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
                              widget.listPresence?["logout_presence"] ?? "-",
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
                              widget.listPresence != null && widget.listPresence?["login_presence"] != null && widget.listPresence?["logout_presence"] != null
                                  ? Utils.funcHourCalculateTotal(
                                      widget.listPresence!["login_presence"].toString().isNotEmpty ? widget.listPresence!["login_presence"] : "0.0",
                                      widget.listPresence!["logout_presence"].toString().isNotEmpty ? widget.listPresence!["logout_presence"] : "0.0",
                                      // jamLembur: (widget.listPresence?["lembur_time"] ?? "0.0").toString().isNotEmpty ? widget.listPresence!["lembur_time"] : "0.0",
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
