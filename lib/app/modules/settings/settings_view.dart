import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/modules/recap_sallary/recap_sallary_controller.dart';
import 'package:teh_kota/app/modules/settings/settings_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/card_recap_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../../utils/utils.dart';
import 'package:printing/printing.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RekapController());
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(AppColor.colorBgGray),
        appBar: CustomAppBar(
          title: "Settings",
        ),
        body: (controller.dataAdmin.value.isEmpty && controller.valueDate.value.isEmpty)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : content(),
      );
    });
  }

  Widget tabBarJamKerja() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const CustomText(
              "Jam Kerja",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            width: Get.width / 9,
            alignment: Alignment.center,
            child: const CustomText(
              "Pagi",
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDate.value[0], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDate.value[0]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDate.value[0] = Utils.customDate(res.hour, res.minute);
                  controller.valueDate.refresh();
                  print(controller.valueDate.value[0]);
                  controller.updateOnFirestore();
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDate.value[1], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDate.value[1]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDate.value[1] = Utils.customDate(res.hour, res.minute);
                  controller.valueDate.refresh();
                  print(controller.valueDate.value[1]);
                  controller.updateOnFirestore();
                }
              }),
            ],
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            width: Get.width / 9,
            alignment: Alignment.center,
            child: const CustomText(
              "Sore",
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDate.value[2], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDate.value[2]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDate.value[2] = Utils.customDate(res.hour, res.minute);
                  controller.valueDate.refresh();
                  print(controller.valueDate.value[2]);
                  controller.updateOnFirestore();
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDate.value[3], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDate.value[3]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDate.value[3] = Utils.customDate(res.hour, res.minute);
                  controller.valueDate.refresh();
                  print(controller.valueDate.value[3]);
                  controller.updateOnFirestore();
                }
              })
            ],
          ),
        ],
      ),
    );
  }

  Widget tabBarJamLembur() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const CustomText(
              "Pagi",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorGreen), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.centerLeft,
            width: Get.width / 5.7,
            child: const CustomText(
              "Sebelum",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDateLembur.value["pagi"]["sebelum"]["jamMasuk"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur.value["pagi"]["sebelum"]["jamMasuk"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur.value["pagi"]["sebelum"]["jamMasuk"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur.value["pagi"]["sebelum"]["jamMasuk"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDateLembur.value["pagi"]["sebelum"]["jamKeluar"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur.value["pagi"]["sebelum"]["jamKeluar"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur.value["pagi"]["sebelum"]["jamKeluar"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur.value["pagi"]["sebelum"]["jamKeluar"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
            ],
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorGreen), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.centerLeft,
            width: Get.width / 5.7,
            child: const CustomText(
              "Sesudah",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDateLembur.value["pagi"]["sesudah"]["jamMasuk"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur.value["pagi"]["sesudah"]["jamMasuk"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur.value["pagi"]["sesudah"]["jamMasuk"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur.value["pagi"]["sesudah"]["jamMasuk"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDateLembur.value["pagi"]["sesudah"]["jamKeluar"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur.value["pagi"]["sesudah"]["jamKeluar"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur.value["pagi"]["sesudah"]["jamKeluar"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur.value["pagi"]["sesudah"]["jamKeluar"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
            ],
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.center,
            child: const CustomText(
              "Sore",
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Utils.gapVertical(16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorGreen), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.centerLeft,
            width: Get.width / 5.7,
            child: const CustomText(
              "Sebelum",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDateLembur["sore"]["sebelum"]["jamMasuk"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur["sore"]["sebelum"]["jamMasuk"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur["sore"]["sebelum"]["jamMasuk"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur["sore"]["sebelum"]["jamMasuk"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDateLembur["sore"]["sebelum"]["jamKeluar"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur["sore"]["sebelum"]["jamKeluar"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur["sore"]["sebelum"]["jamKeluar"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur["sore"]["sebelum"]["jamKeluar"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              })
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(AppColor.colorGreen), borderRadius: BorderRadius.circular(6)),
            alignment: Alignment.centerLeft,
            width: Get.width / 5.7,
            child: const CustomText(
              "Sesudah",
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Utils.gapVertical(16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              cardHours("Jam Masuk", controller.valueDateLembur["sore"]["sesudah"]["jamMasuk"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur["sore"]["sesudah"]["jamMasuk"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur["sore"]["sesudah"]["jamMasuk"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur["sore"]["sesudah"]["jamMasuk"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              }),
              Utils.gapHorizontal(24),
              cardHours("Jam Keluar", controller.valueDateLembur["sore"]["sesudah"]["jamKeluar"], () async {
                var res = await showTimePicker(
                  builder: (context, childWidget) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
                      child: childWidget!,
                    );
                  },
                  context: Get.context!,
                  initialTime: TimeOfDay.fromDateTime(controller.valueDateLembur["sore"]["sesudah"]["jamKeluar"]),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                );
                if (res != null) {
                  controller.valueDateLembur["sore"]["sesudah"]["jamKeluar"] = Utils.customDate(res.hour, res.minute);
                  controller.valueDateLembur.refresh();
                  print(controller.valueDateLembur["sore"]["sesudah"]["jamKeluar"]);
                  controller.firestore.updateOfficeHoursLembur(controller.valueDateLembur.value);
                }
              })
            ],
          ),
        ],
      ),
    );
  }

  Widget content() {
    return SingleChildScrollView(
      child: Container(
        width: Get.width,
        height: Get.height,
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: Get.width, minHeight: Get.height / 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: const Color(AppColor.colorLightGrey), borderRadius: BorderRadius.circular(6)),
                      alignment: Alignment.center,
                      child: const CustomText(
                        "Admin Account",
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Utils.gapVertical(16),
                    CustomTextFormField(
                      title: "Email",
                      controller: controller.emailC,
                      hintText: "Email",
                    ),
                    CustomTextFormField(
                      title: "Password",
                      controller: controller.passC,
                      hintText: "Password",
                      isPassword: true,
                    ),
                    if (!controller.isVerifMode.value) ...[
                      CustomTextFormField(
                        title: "Password Ulang",
                        controller: controller.passConfirmC,
                        hintText: "Password Ulang",
                        isPassword: true,
                      ),
                    ],
                    GestureDetector(
                      onTap: () => controller.tapLoginButton(),
                      child: Container(
                        width: Get.width,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(AppColor.colorGreen), borderRadius: BorderRadius.all(Radius.circular(12))),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: CustomText(
                          controller.isVerifMode.value ? "Verifikasi" : "Ubah",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(AppColor.colorWhite),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DefaultTabController(
                length: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: TabBar(
                        tabs: [
                          Tab(text: "Jam Kerja"),
                          Tab(text: "Jam Lembur"),
                        ],
                        indicatorColor: Color(AppColor.colorGreen),
                        labelColor: Color(AppColor.colorGreen),
                        unselectedLabelColor: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      height: 345,
                      child: TabBarView(
                        children: [
                          tabBarJamKerja(),
                          tabBarJamLembur(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget cardHours(String title, DateTime value, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(AppColor.colorWhite),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                title,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              Utils.gapHorizontal(4),
              CustomText(
                Utils.customShowJustTime(value),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          Utils.gapHorizontal(8),
          InkWell(
            onTap: onTap,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(AppColor.colorLightGrey),
                borderRadius: BorderRadiusDirectional.all(Radius.circular(4)),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.edit,
                size: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}
