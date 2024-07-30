import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Obx(() {
                    return Expanded(
                      child: Align(
                        alignment: Utils.isAdmin.value ? Alignment.centerLeft : Alignment.center,
                        child: CustomText(
                          "Rekap ${Utils.isAdmin.value ? "Gaji" : "Presensi"}",
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }),
                  if (Utils.isAdmin.value)
                    InkWell(
                      onTap: () async {
                        await printAllData();
                      },
                      child: const Icon(Icons.print),
                    )
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

  Future<void> printAllData() async {
    // final pdfDoc = pw.Document();
    // final ByteData image = await rootBundle.load('assets/logo_splash.png');
    // Uint8List imageData = (image).buffer.asUint8List();
    Printing.layoutPdf(
      format: pdf.PdfPageFormat.legal,
      name: 'Rekap - ${Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy")}.pdf',
      onLayout: (format) async {
        final pdfDoc = pw.Document();
        final ByteData image = await rootBundle.load('assets/logo_splash.png');

        Uint8List imageData = (image).buffer.asUint8List();
        pdfDoc.addPage(
          pw.Page(
            margin: const pw.EdgeInsets.all(6),
            build: (context) {
              return pw.ConstrainedBox(
                constraints: const pw.BoxConstraints.expand(),
                child: pw.FittedBox(
                  fit: pw.BoxFit.contain,
                  alignment: pw.Alignment.topCenter,
                  child: pw.Container(
                    width: Get.width,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: Get.width,
                          color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 80,
                                height: 80,
                                margin: const pw.EdgeInsets.only(right: 8),
                                child: pw.Image(pw.MemoryImage(imageData)),
                              ),
                              pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    "Teh Kota",
                                    style: pw.TextStyle(
                                      fontSize: 14,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Text(
                                    Utils.branchName,
                                    style: const pw.TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              pw.Spacer(),
                              pw.Text(
                                Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy"),
                                style: pw.TextStyle(
                                  fontSize: 16,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.Container(
                          margin: const pw.EdgeInsets.only(top: 16),
                          child: pw.Table(
                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                            tableWidth: pw.TableWidth.min,
                            border: const pw.TableBorder(
                              horizontalInside: pw.BorderSide(
                                color: pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                width: 1,
                              ),
                            ),
                            children: [
                              pw.TableRow(
                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                repeat: true,
                                children: [
                                  headTitleColumn("Nama\nKaryawan"),
                                  headTitleColumn("Gaji"),
                                  headTitleColumn("Lembur"),
                                  headTitleColumn("Potongan"),
                                  headTitleColumn("Total Gaji"),
                                ],
                              ),
                              ...controller.listDataPresence.asMap().entries.map(
                                (data) {
                                  return pw.TableRow(children: [
                                    contentColumn(data.value["userName"] ?? ""),
                                    contentColumn("${data.value["totalPresence"]} Jam\n${controller.calculateGajiHadir(data.value)}"),
                                    contentColumn("${data.value["totalOvertime"] ~/ 60} Jam\n${controller.calculateGajiLembur(data.value)}"),
                                    contentColumn("${data.value["totalLate"]} Jam\n ${controller.calculateGajiTerpotong(data.value)}"),
                                    contentColumn(controller.calculateGajiTotal(data.value)),
                                  ]);
                                },
                              ),
                              pw.TableRow(
                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                children: [
                                  pw.SizedBox(),
                                  pw.SizedBox(),
                                  pw.SizedBox(),
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                                    child: pw.Text(
                                      'Total Pengeluaran : ',
                                      textAlign: pw.TextAlign.center,
                                      maxLines: 1,
                                    ),
                                  ),
                                  pw.Center(child: pw.Text(controller.calculateTotalPengeluaran(controller.listDataPresence[0]))),
                                ],
                              ),
                            ],
                          ),
                        ),
                        pw.Align(
                          alignment: pw.Alignment.centerRight,
                          child: pw.Container(
                            margin: const pw.EdgeInsets.only(top: 20),
                            width: Get.width / 3,
                            child: pw.Column(children: [
                              contentColumn("Madiun, ${DateFormat.yMd("ID_id").format(DateTime.now())}"),
                              headTitleColumn("Owner Teh Kota"),
                              pw.SizedBox(height: 40),
                              headTitleColumn("Andika Dwi Cahyanto"),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        return await pdfDoc.save();
      },
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
                child: (controller.listDataPresence.isEmpty)
                    ? SizedBox(
                        width: Get.width,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/ic_no_data.svg",
                            ),
                            const SizedBox(height: 12),
                            const CustomText(
                              "Tidak ada data",
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.listDataPresence.length,
                        controller: controller.scrollC,
                        shrinkWrap: true,
                        itemBuilder: (context, i) {
                          return Padding(
                              padding: EdgeInsets.only(bottom: (i + 1) == controller.listDataPresence.length ? 250 : 16),
                              child: Obx(() {
                                return CardRecapDetail(
                                  data: controller.listDataPresence[i],
                                  index: i,
                                  isAdmin: Utils.isAdmin.value,
                                  onPrintTap: () async {
                                    Printing.layoutPdf(
                                      format: pdf.PdfPageFormat.legal,
                                      name: 'Rekap - ${Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy")}.pdf',
                                      onLayout: (format) async {
                                        final pdfDoc = pw.Document();
                                        final ByteData image = await rootBundle.load('assets/logo_splash.png');

                                        Uint8List imageData = (image).buffer.asUint8List();

                                        pdfDoc.addPage(
                                          pw.Page(
                                            margin: const pw.EdgeInsets.all(6),
                                            build: (context) {
                                              return pw.ConstrainedBox(
                                                constraints: const pw.BoxConstraints.expand(),
                                                child: pw.FittedBox(
                                                  fit: pw.BoxFit.contain,
                                                  alignment: pw.Alignment.topCenter,
                                                  child: pw.Container(
                                                    width: Get.width,
                                                    child: pw.Column(
                                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                      children: [
                                                        pw.Container(
                                                          width: Get.width,
                                                          color: const pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                          child: pw.Row(
                                                            children: [
                                                              pw.Container(
                                                                width: 80,
                                                                height: 80,
                                                                margin: const pw.EdgeInsets.only(right: 8),
                                                                child: pw.Image(pw.MemoryImage(imageData)),
                                                              ),
                                                              pw.Column(
                                                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                                                children: [
                                                                  pw.Text(
                                                                    "Teh Kota",
                                                                    style: pw.TextStyle(
                                                                      fontSize: 14,
                                                                      fontWeight: pw.FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  pw.SizedBox(height: 4),
                                                                  pw.Text(
                                                                    Utils.branchName,
                                                                    style: const pw.TextStyle(fontSize: 12),
                                                                  ),
                                                                ],
                                                              ),
                                                              pw.Spacer(),
                                                              pw.Text(
                                                                Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy"),
                                                                style: pw.TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: pw.FontWeight.bold,
                                                                ),
                                                              ),
                                                              pw.SizedBox(width: 16)
                                                            ],
                                                          ),
                                                        ),
                                                        pw.Container(
                                                          margin: const pw.EdgeInsets.only(top: 16),
                                                          child: pw.Table(
                                                            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                                                            border: const pw.TableBorder(
                                                              // verticalInside: pw.BorderSide(
                                                              //   color: pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                              //   width: 1,
                                                              // ),
                                                              horizontalInside: pw.BorderSide(
                                                                color: pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            children: [
                                                              pw.TableRow(
                                                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                                                repeat: true,
                                                                children: [
                                                                  headTitleColumn("Nama\nKaryawan"),
                                                                  headTitleColumn("Gaji"),
                                                                  headTitleColumn("Lembur"),
                                                                  headTitleColumn("Potongan"),
                                                                  headTitleColumn("Total Gaji"),
                                                                ],
                                                              ),
                                                              pw.TableRow(
                                                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                                                children: [
                                                                  contentColumn(controller.listDataPresence[i]["userName"] ?? ""),
                                                                  contentColumn("${controller.listDataPresence[i]["totalPresence"]} Jam\n${controller.calculateGajiHadir(controller.listDataPresence[i])}"),
                                                                  contentColumn("${controller.listDataPresence[i]["totalOvertime"] ~/ 60} Jam\n${controller.calculateGajiLembur(controller.listDataPresence[i])}"),
                                                                  contentColumn("${controller.listDataPresence[i]["totalLate"]} Jam\n ${controller.calculateGajiTerpotong(controller.listDataPresence[i])}"),
                                                                  contentColumn(controller.calculateGajiTotal(controller.listDataPresence[i])),
                                                                ],
                                                              ),
                                                              pw.TableRow(
                                                                verticalAlignment: pw.TableCellVerticalAlignment.middle,
                                                                children: [
                                                                  pw.SizedBox(),
                                                                  pw.SizedBox(),
                                                                  pw.SizedBox(),
                                                                  pw.Container(
                                                                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                                                                    child: pw.Text(
                                                                      'Total Pengeluaran : ',
                                                                      textAlign: pw.TextAlign.center,
                                                                      maxLines: 1,
                                                                    ),
                                                                  ),
                                                                  pw.Container(
                                                                    padding: const pw.EdgeInsets.symmetric(vertical: 6),
                                                                    child: pw.Text(
                                                                      controller.calculateTotalPengeluaran(controller.listDataPresence[i], isSingle: true),
                                                                      textAlign: pw.TextAlign.center,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        pw.Align(
                                                          alignment: pw.Alignment.centerRight,
                                                          child: pw.Container(
                                                            margin: const pw.EdgeInsets.only(top: 20),
                                                            width: Get.width / 3,
                                                            child: pw.Column(children: [
                                                              contentColumn("Madiun, ${DateFormat.yMd("ID_id").format(DateTime.now())}"),
                                                              headTitleColumn("Owner Teh Kota"),
                                                              pw.SizedBox(height: 40),
                                                              headTitleColumn("Andika Dwi Cahyanto"),
                                                            ]),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                        return await pdfDoc.save();
                                      },
                                    );
                                  },
                                );
                              }));
                        },
                      ),
              ),
            );
          })
        ],
      ),
    );
  }

  pw.Widget headTitleColumn(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        textAlign: pw.TextAlign.center,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }

  pw.Widget contentColumn(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
        textAlign: pw.TextAlign.center,
        maxLines: 2,
        softWrap: true,
      ),
    );
  }
}
