import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
  final Map<String, dynamic>? listPresence;
  final User? user;
  final int statusPresence; // 1 : Berhasil, - : Gagal
  final int typePresence; // 1 : Masuk, - : Keluar

  @override
  State<PresenceBottomSheet> createState() => _PresenceBottomSheetState();
}

class _PresenceBottomSheetState extends State<PresenceBottomSheet> {
  CloudFirestoreService firestore = CloudFirestoreService();
  final selectedTab = RxnInt(); // Variabel untuk menyimpan id tombol yang terpilih
  var typePresence = RxInt(1);
  var body = Rxn<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();

    setState(() {
      typePresence.value = widget.typePresence;
      body.value = widget.listPresence;
      body.refresh();
      if (body.value?.containsKey("shift") ?? false) {
        selectedTab.value = int.parse(body.value?["shift"]);
      }
    });
    print("LIST PRESENCE : ${body.value}");
  }

  Future<void> setFieldShift() async {
    await firestore.getPresence(body.value?["docID"])?.then((value) async {
      // var idUser = value['userID'];
      if (value.data()?.containsKey(body.value?["userID"]) ?? false) {
        Map<String, dynamic> dataPresenceSelected = value.data()?['${body.value?["userID"]}'];
        var typeShift = Utils.specifyTypeShift(selectedTab.value);
        body.value?.putIfAbsent("shift", () => selectedTab.value.toString());
        body.value?.putIfAbsent("status", () => "");

        if (typePresence.value == 1) {
          if (typeShift == TypeShift.shiftSore) {
            if (DateTime.parse(dataPresenceSelected["login_presence"]).isAfter(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!)) {
              body.value?["status"] = Utils.specifyTypeStatus(TypeStatus.terlambat, fromInt: false).toString();
            } else {
              body.value?["status"] = Utils.specifyTypeStatus(TypeStatus.tepatWaktu, fromInt: false).toString();
            }
          } else {
            if (DateTime.parse(dataPresenceSelected["login_presence"]).isAfter(Utils.officeHours(TypeShift.shiftPagi)["login_presence"]!)) {
              body.value?["status"] = Utils.specifyTypeStatus(TypeStatus.terlambat, fromInt: false).toString();
            } else {
              body.value?["status"] = Utils.specifyTypeStatus(TypeStatus.tepatWaktu, fromInt: false).toString();
            }
          }
        }
        var resAdd = await firestore.addPresence(
          body.value?["docID"],
          body.value!,
          body.value?["userID"],
        );
        if (!resAdd) {
          throw "";
        }
        body.refresh();
      }
    }).catchError((error) {
      print('Error getPresence: $error');
      Utils.showToast(TypeToast.error, "Terjadi Kesalahan Sistem");
      return;
    });
  }

  Widget shiftButton(TypeShift typeShift) {
    return InkWell(
      onTap: () async {
        selectedTab.value = Utils.specifyTypeShift(typeShift, fromInt: false);
        await setFieldShift();
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

  @override
  Widget build(BuildContext context) {
    if (widget.statusPresence == 1) {
      if (widget.listPresence != null) {
        if (widget.listPresence!.containsKey("login_presence") && widget.listPresence!.containsKey("logout_presence")) {
          return Container(
            constraints: BoxConstraints(maxHeight: 250, minWidth: Get.width),
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
              children: [
                SvgPicture.asset("assets/ic_berhasil.svg"),
                Utils.gapVertical(24),
                const CustomText(
                  "Anda sudah melakukan presensi hari ini !",
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ],
            ),
          );
        } else if ((widget.listPresence!.containsKey("logout_presence"))) {
          typePresence.value = 2; // pengecekan untuk menampilkan tampilan presensi keluar
        }
      }
      return WillPopScope(
        onWillPop: () async {
          if (typePresence.value == 2) {
            // tidak perlu pengecekan karena keluar tidak perlu isi shift
            Get.back();
            return Future.value(true);
          }
          if (selectedTab.value == null) {
            Utils.showToast(TypeToast.error, "Pilih shift terlebih dahulu !");
            return Future.value(false);
          }
          if (typePresence.value == 1) {
            return Future.value(true);
          }
          return Future.value(true);
        },
        child: Obx(() {
          return Container(
            // constraints: BoxConstraints(maxHeight: body.value == null && typePresence.value == 1 ? 450 : 330),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
            // margin: typePresence.value == 2 ? (selectedTab.value == null ? EdgeInsets.only(top: 550) : EdgeInsets.only(top: 350)) : EdgeInsets.only(top: 500),
            margin: EdgeInsets.only(top: 400),
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
                  "Presensi " "${typePresence.value == 1 ? "Masuk" : "Keluar"}" " Berhasil",
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
                Obx(() {
                  return Column(
                    children: [
                      if (selectedTab.value == null && typePresence.value == 1)
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
                              Obx(() => Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      // if (DateTime.now().hour > 2 || DateTime.now().isAfter(Utils.officeHours(TypeShift.shiftSore)["login_presence"]!)) ...[
                                      //   shiftButton(TypeShift.shiftSore),
                                      //   shiftButton(TypeShift.shiftFull),
                                      // ] else ...[
                                      //   shiftButton(TypeShift.shiftPagi),
                                      //   shiftButton(TypeShift.shiftFull),
                                      // ]
                                        shiftButton(TypeShift.shiftPagi),
                                        shiftButton(TypeShift.shiftSore),
                                        shiftButton(TypeShift.shiftFull),
                                    ],
                                  )),
                            ],
                          ),
                        )
                      else
                        const SizedBox(),
                      if (selectedTab.value == null && typePresence.value == 1) Utils.gapVertical(16) else const SizedBox(),
                    ],
                  );
                }),
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
                                  (body.value?["login_presence"] != null && typePresence.value == 1)
                                      ? Utils.formatTime(DateTime.tryParse(body.value?["login_presence"]))
                                      : (body.value?["logout_presence"] != null && typePresence.value == 2)
                                          ? Utils.formatTime(DateTime.tryParse(body.value?["logout_presence"]))
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
                          Container(
                            color: const Color(AppColor.colorLightGrey),
                            height: 43,
                            width: 1,
                          ),
                          Obx(() {
                            return Column(
                              children: [
                                const CustomText(
                                  "Status",
                                  color: Color(AppColor.colorDarkGrey),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                                Utils.gapVertical(8),
                                CustomText(
                                  (body.value != null && body.value!["status"] != null) ? Utils.typeStatusToString(Utils.specifyTypeStatus(int.parse(body.value!["status"].toString()))) : "-",
                                  color: const Color(AppColor.colorBlackNormal),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            );
                          }),
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
          CustomText(
            "Presensi ${typePresence.value == 1 ? "Masuk" : "Berhasil"} Gagal",
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
