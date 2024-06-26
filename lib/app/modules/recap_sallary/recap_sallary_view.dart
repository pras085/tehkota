import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teh_kota/app/modules/recap_sallary/recap_sallary_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/card_recap_detail.dart';
import 'package:teh_kota/app/widgets/custom_appbar.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

import '../../utils/utils.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RekapView extends GetView<RekapController> {
  const RekapView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RekapController());
    return Scaffold(
      backgroundColor: const Color(AppColor.colorBgGray),
      appBar: CustomAppBar(
        appBarSize: 135,
        customBody: SizedBox(
          width: Get.width,
          child: Column(
            children: [
              Row(
                children: [
                  if (!Utils.isAdmin.value)
                    InkWell(
                      onTap: () => Get.back(),
                      child: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: SvgPicture.asset(
                            "assets/ic_back_button.svg",
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Align(
                      alignment: (!Utils.isAdmin.value) ? Alignment.center : Alignment.centerLeft,
                      child: const CustomText(
                        "Rekap Gaji",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Utils.gapVertical(16),
              Obx(() {
                return Expanded(
                  child: CustomSearchField(
                    controller: controller.searchC,
                    isDisable: controller.listDataPresence.isEmpty,
                    onSubmit: (value) {
                      print("TEST ");
                      controller.getDataFromApi();
                    },
                    onClearTap: () {
                      controller.getDataFromApi();
                    },
                  ),
                );
              })
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.scrollC,
        child: content(),
      ),
    );
  }

  Widget content() {
    return Container(
      width: Get.width,
      height: Get.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            return Row(
              children: [
                CustomText(
                  Utils.formatTanggaLocal(controller.selectedMonth.value.toString(), format: "MMMM yyyy"),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                GestureDetector(
                    onTap: () {
                      // controller.selectedMonth.value?.subtract(const Duration(days: 30));
                      if (controller.selectedMonth.value == null) return;
                      controller.selectedMonth.value = DateTime(controller.selectedMonth.value!.year - (controller.selectedMonth.value!.month == 1 ? 1 : 0), (controller.selectedMonth.value!.month == 1 ? 12 : controller.selectedMonth.value!.month - 1), controller.selectedMonth.value!.day);
                      print("${controller.selectedMonth.value?.month}");
                      controller.getDataFromApi();
                    },
                    child: SvgPicture.asset("assets/ic_back_button.svg")),
                Utils.gapHorizontal(12),
                GestureDetector(
                    onTap: () {
                      // controller.selectedMonth.value?.add(const Duration(days: 30));
                      if (controller.selectedMonth.value == null) return;
                      controller.selectedMonth.value = DateTime(controller.selectedMonth.value!.year + (controller.selectedMonth.value!.month == 12 ? 1 : 0), (controller.selectedMonth.value!.month % 12) + 1, controller.selectedMonth.value!.day);
                      print("${controller.selectedMonth.value?.month}");
                      controller.getDataFromApi();
                    },
                    child: SvgPicture.asset("assets/ic_forward_button.svg")),
              ],
            );
          }),
          Obx(() {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ListView.builder(
                  itemCount: controller.listDataPresence.length,
                  controller: controller.scrollC,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: (i + 1) == controller.listDataPresence.length ? 150 : 16),
                      child: CardRecapDetail(
                        controller.listDataPresence[i],
                        isAdmin: Utils.isAdmin.value,
                        onTap: () async {
                          final pdfDoc = pw.Document();
                          pdfDoc.addPage(pw.Page(
                            build: (context) {
                              double totalPresenceInHours = controller.listDataPresence[i]["totalPresence"].toDouble();

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
                              if (controller.listDataPresence[i]["totalLate"] != 0) {
                                int terlambatTime = controller.listDataPresence[i]["totalLate"]; // Kita anggap terlambatTime sudah dalam menit
                                gajiTerpotong = (terlambatTime / 30).ceil() * 3300;
                              }

                              // Menghitung gaji lembur
                              int gajiLembur = controller.listDataPresence[i]["totalOvertime"] * 2000;

                              // Menghitung gaji total
                              double gajiTotal = gajiHadir - gajiTerpotong + gajiLembur;

                              return pw.Container(
                                width: Get.width,
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy"),
                                      style: pw.TextStyle(
                                        fontSize: 16,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.Container(
                                      margin: const pw.EdgeInsets.only(top: 16),
                                      padding: const pw.EdgeInsets.all(12),
                                      width: Get.width,
                                      decoration: const pw.BoxDecoration(
                                        color: pdf.PdfColor.fromInt(AppColor.colorBgGray),
                                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
                                      ),
                                      child: pw.Column(
                                        children: [
                                          pw.Row(
                                            children: [
                                              // pw.SvgImage(
                                              //   svg: "assets/ic_profile.svg",
                                              //   height: 24,
                                              //   width: 24,
                                              // ),
                                              pw.SizedBox(height: 6),
                                              pw.Expanded(
                                                child: pw.Text(
                                                  controller.listDataPresence[i]["userName"].toString(),
                                                  style: const pw.TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.Container(
                                            width: Get.width,
                                            height: 1,
                                            color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                            margin: const pw.EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          pw.Row(
                                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Expanded(
                                                child: pw.Column(
                                                  children: [
                                                    pw.Row(
                                                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                                                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                                                      children: [
                                                        pw.Column(
                                                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                                                          mainAxisAlignment: pw.MainAxisAlignment.start,
                                                          children: [
                                                            pw.Text(
                                                              "${controller.listDataPresence[i]["totalPresence"]} Jam",
                                                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const pdf.PdfColor.fromInt(AppColor.colorGreen)),
                                                              textAlign: pw.TextAlign.center,
                                                            ),
                                                            pw.Text(
                                                              "Hadir",
                                                              style: const pw.TextStyle(fontSize: 10, color: pdf.PdfColor.fromInt(AppColor.colorDarkGrey)),
                                                              textAlign: pw.TextAlign.center,
                                                            )
                                                          ],
                                                        ),
                                                        pw.Container(
                                                          color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                          height: 44,
                                                          width: 1,
                                                        ),
                                                        pw.Column(
                                                          children: [
                                                            pw.Text(
                                                              "${controller.listDataPresence[i]["totalLate"]} Jam",
                                                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const pdf.PdfColor.fromInt(AppColor.colorRed)),
                                                              textAlign: pw.TextAlign.center,
                                                            ),
                                                            pw.Text(
                                                              "Terlambat",
                                                              style: const pw.TextStyle(fontSize: 10, color: pdf.PdfColor.fromInt(AppColor.colorDarkGrey)),
                                                              textAlign: pw.TextAlign.center,
                                                            )
                                                          ],
                                                        ),
                                                        pw.Container(
                                                          color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                          height: 44,
                                                          width: 1,
                                                        ),
                                                        pw.Column(
                                                          children: [
                                                            pw.Text(
                                                              "${controller.listDataPresence[i]["totalOvertime"]} Jam",
                                                              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: const pdf.PdfColor.fromInt(AppColor.colorBlue)),
                                                              textAlign: pw.TextAlign.center,
                                                            ),
                                                            pw.Text(
                                                              "Lembur",
                                                              style: const pw.TextStyle(fontSize: 10, color: pdf.PdfColor.fromInt(AppColor.colorDarkGrey)),
                                                              textAlign: pw.TextAlign.center,
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          pw.Container(
                                            width: Get.width,
                                            height: 1,
                                            color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                            margin: const pw.EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text(
                                                "Gaji Utama",
                                                style: const pw.TextStyle(fontSize: 12),
                                              ),
                                              pw.Spacer(),
                                              pw.Text(
                                                gajiHadir != 0 ? "Rp. ${gajiHadir.toStringAsFixed(0)}" : "-",
                                                style: const pw.TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Text(
                                                "Lembur",
                                                style: const pw.TextStyle(fontSize: 12),
                                              ),
                                              pw.Spacer(),
                                              pw.Text(
                                                gajiLembur != 0 ? "Rp. ${gajiLembur.toStringAsFixed(0)}" : "-",
                                                style: const pw.TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          pw.SizedBox(height: 4),
                                          pw.Row(
                                            children: [
                                              pw.Text(
                                                "Potongan",
                                                style: const pw.TextStyle(fontSize: 12, color: pdf.PdfColor.fromInt(AppColor.colorRed)),
                                              ),
                                              pw.Spacer(),
                                              pw.Text(
                                                gajiTerpotong != 0 ? "Rp. ${gajiTerpotong.toStringAsFixed(0)}" : "-",
                                                style: const pw.TextStyle(fontSize: 12, color: pdf.PdfColor.fromInt(AppColor.colorRed)),
                                              ),
                                            ],
                                          ),
                                          pw.Container(
                                            width: Get.width,
                                            height: 1,
                                            color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                            margin: const pw.EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          pw.Row(
                                            children: [
                                              pw.Text(
                                                "Total Gaji",
                                                style: const pw.TextStyle(fontSize: 12),
                                              ),
                                              pw.Spacer(),
                                              pw.Text(
                                                gajiTotal != 0 ? "Rp. ${gajiTotal.toStringAsFixed(0)}" : "-",
                                                style: const pw.TextStyle(fontSize: 12, color: pdf.PdfColor.fromInt(AppColor.colorGreen)),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ));
                          await Printing.sharePdf(
                            bytes: await pdfDoc.save(),
                            filename: 'Rekap - ${Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy")}.pdf',
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          })
        ],
      ),
    );
  }
}
