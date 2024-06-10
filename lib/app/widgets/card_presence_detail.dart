import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

class CardPresenceDetail extends StatelessWidget {
  final Map listPresence;

  const CardPresenceDetail(this.listPresence, {super.key});

  @override
  Widget build(BuildContext context) {
    var res = Utils.specifyTypeStatus(int.tryParse(listPresence["status"] ?? ""));
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      width: Get.width,
      height: 133,
      decoration: BoxDecoration(
        color: const Color(AppColor.colorWhite),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: res == TypeStatus.berlangsung ? const Color(AppColor.colorGreen) : Colors.transparent),
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
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: CustomText(
                  listPresence["userName"],
                  fontSize: 12,
                ),
              ),
              Utils.gapHorizontal(6),
              const Spacer(),
              if (listPresence["shift"] != null)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    border: Border.all(color: const Color(AppColor.colorDarkGrey), strokeAlign: BorderSide.strokeAlignOutside),
                    color: const Color(AppColor.colorLightGrey),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  child: CustomText(
                    Utils.typeShiftToString(Utils.specifyTypeShift(int.tryParse(listPresence["shift"]))),
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                const SizedBox(),
              Utils.gapHorizontal(6),
              _statusPresenceWidget(listPresence),
            ],
          ),
          Utils.gapVertical(12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Widget Calendar Greens
                Container(
                  decoration: const BoxDecoration(color: Color(AppColor.colorGreen), borderRadius: BorderRadius.all(Radius.circular(8))),
                  width: 60,
                  height: Get.height,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        Utils.formatTanggaLocal(listPresence["login_presence"], format: "d"),
                        color: const Color(AppColor.colorWhite),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                      CustomText(
                        Utils.formatTanggaLocal(listPresence["login_presence"], format: "MMMM"),
                        color: const Color(AppColor.colorWhite),
                        fontSize: 14,
                      ),
                    ],
                  ),
                ),
                Utils.gapHorizontal(12),
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
                                listPresence["login_presence"] != null ? Utils.formatTime(DateTime.tryParse(listPresence["login_presence"])) : "-",
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
                                listPresence["logout_presence"] != null ? Utils.formatTime(DateTime.tryParse(listPresence["logout_presence"])) : "-",
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
                                listPresence["login_presence"] != null && listPresence["logout_presence"] != null
                                    ? Utils.funcHourCalculateTotal(
                                        DateTime.tryParse((listPresence["login_presence"]))!,
                                        DateTime.tryParse((listPresence["logout_presence"]))!,
                                        jamLembur: listPresence["lembur_time"] != null ? Duration(minutes: int.parse(listPresence["lembur_time"])) : null,
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
                      Utils.gapVertical(6),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CustomText(
                              "Lembur : ",
                              color: Color(AppColor.colorDarkGrey),
                              fontSize: 10,
                            ),
                            CustomText(
                              listPresence["lembur_time"] != null ? "${listPresence["lembur_time"]} Menit" : "-",
                              color: const Color(AppColor.colorGreen),
                              fontSize: 10,
                            ),
                          ],
                        ),
                      )
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

  Widget _statusPresenceWidget(Map listPresence) {
    var res = Utils.specifyTypeStatus(int.tryParse(listPresence["status"] ?? "0"));
    if (res == TypeStatus.berlangsung) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: const Color(AppColor.colorOrange), strokeAlign: BorderSide.strokeAlignOutside),
          color: const Color(AppColor.colorOrange).withOpacity(0.15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: CustomText(
          Utils.typeStatusToString(res),
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: const Color(AppColor.colorOrange),
        ),
      );
    } else if (res == TypeStatus.tepatWaktu) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: const Color(AppColor.colorGreen), strokeAlign: BorderSide.strokeAlignOutside),
          color: const Color(AppColor.colorLightGreen),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: CustomText(
          Utils.typeStatusToString(res),
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: const Color(AppColor.colorGreen),
        ),
      );
    } else if (res == TypeStatus.terlambat) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(color: const Color(AppColor.colorRed), strokeAlign: BorderSide.strokeAlignOutside),
          color: const Color(AppColor.colorRed).withOpacity(0.15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: CustomText(
          Utils.typeStatusToString(res),
          fontSize: 8,
          fontWeight: FontWeight.w600,
          color: const Color(AppColor.colorRed),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
