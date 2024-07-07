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
                  Expanded(
                    child: const Align(
                      alignment: Alignment.center,
                      child: CustomText(
                        "Rekap Gaji",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
    final pdfDoc = pw.Document();
    final ByteData image = await rootBundle.load('assets/logo_splash.png');
    Uint8List imageData = (image).buffer.asUint8List();

    pdfDoc.addPage(
      pw.Page(
        pageFormat: pdf.PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
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
                padding: const pw.EdgeInsets.all(12),
                width: Get.width,
                child: pw.Table(
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(
                      color: pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                      width: 1,
                    ),
                  ),
                  children: [
                    pw.TableRow(
                      repeat: true,
                      children: [
                        pw.Center(child: pw.Text('Nama Karyawan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(child: pw.Text('Gaji', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(child: pw.Text('Lembur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(child: pw.Text('Potongan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Center(child: pw.Text('Total Gaji', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...controller.listDataPresence.asMap().entries.map(
                      (data) {
                        return pw.TableRow(decoration: const pw.BoxDecoration(), children: [
                          pw.Center(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 20),
                              child: pw.Text(
                                data.value["userName"] ?? "",
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 20),
                              child: pw.Text(
                                controller.calculateGajiHadir(data.value),
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 20),
                              child: pw.Text(
                                controller.calculateGajiLembur(data.value),
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 20),
                              child: pw.Text(
                                controller.calculateGajiTerpotong(data.value),
                              ),
                            ),
                          ),
                          pw.Center(
                            child: pw.Padding(
                              padding: const pw.EdgeInsets.symmetric(vertical: 20),
                              child: pw.Text(
                                controller.calculateGajiTotal(data.value),
                              ),
                            ),
                          ),
                        ]);
                      },
                    ),
                    pw.TableRow(
                      children: [
                        pw.SizedBox(),
                        pw.SizedBox(),
                        pw.SizedBox(),
                        pw.Center(child: pw.Text('Total Pengeluaran : ')),
                        pw.Center(child: pw.Text(controller.calculateTotalPengeluaran(controller.listDataPresence[0]))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdfDoc.save(),
      filename: 'Rekap - ${Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy")}.pdf',
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
                                    final pdfDoc = pw.Document();
                                    final ByteData image = await rootBundle.load('assets/logo_splash.png');

                                    Uint8List imageData = (image).buffer.asUint8List();

                                    pdfDoc.addPage(
                                      pw.Page(
                                        pageFormat: pdf.PdfPageFormat.a4,
                                        build: (context) {
                                          return pw.Container(
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
                                                  padding: const pw.EdgeInsets.all(12),
                                                  width: Get.width,
                                                  child: pw.Table(
                                                    border: const pw.TableBorder(
                                                      horizontalInside: pw.BorderSide(
                                                        color: pdf.PdfColor.fromInt(AppColor.colorLightGrey),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    children: [
                                                      pw.TableRow(
                                                        repeat: true,
                                                        children: [
                                                          pw.Center(child: pw.Text('Nama Karyawan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                                          pw.Center(child: pw.Text('Gaji', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                                          pw.Center(child: pw.Text('Lembur', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                                          pw.Center(child: pw.Text('Potongan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                                          pw.Center(child: pw.Text('Total Gaji', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                                                        ],
                                                      ),
                                                      pw.TableRow(decoration: pw.BoxDecoration(), children: [
                                                        pw.Center(
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                            child: pw.Text(
                                                              controller.listDataPresence[i]["userName"] ?? "",
                                                            ),
                                                          ),
                                                        ),
                                                        pw.Center(
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                            child: pw.Text(
                                                              controller.calculateGajiHadir(controller.listDataPresence[i]),
                                                            ),
                                                          ),
                                                        ),
                                                        pw.Center(
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                            child: pw.Text(
                                                              controller.calculateGajiLembur(controller.listDataPresence[i]),
                                                            ),
                                                          ),
                                                        ),
                                                        pw.Center(
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                            child: pw.Text(
                                                              controller.calculateGajiTerpotong(controller.listDataPresence[i]),
                                                            ),
                                                          ),
                                                        ),
                                                        pw.Center(
                                                          child: pw.Padding(
                                                            padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                            child: pw.Text(
                                                              controller.calculateGajiTotal(controller.listDataPresence[i]),
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                      // ...controller.listDataPresence.asMap().entries.map(
                                                      //   (data) {
                                                      //     return pw.TableRow(decoration: pw.BoxDecoration(), children: [
                                                      //       pw.Center(
                                                      //         child: pw.Padding(
                                                      //           padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                      //           child: pw.Text(
                                                      //             data.value["userName"] ?? "",
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       pw.Center(
                                                      //         child: pw.Padding(
                                                      //           padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                      //           child: pw.Text(
                                                      //             controller.calculateGajiHadir(controller.listDataPresence[i]),
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       pw.Center(
                                                      //         child: pw.Padding(
                                                      //           padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                      //           child: pw.Text(
                                                      //             controller.calculateGajiLembur(controller.listDataPresence[i]),
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       pw.Center(
                                                      //         child: pw.Padding(
                                                      //           padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                      //           child: pw.Text(
                                                      //             controller.calculateGajiTerpotong(controller.listDataPresence[i]),
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       pw.Center(
                                                      //         child: pw.Padding(
                                                      //           padding: const pw.EdgeInsets.symmetric(vertical: 20),
                                                      //           child: pw.Text(
                                                      //             controller.calculateGajiTotal(controller.listDataPresence[i]),
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //     ]);
                                                      //   },
                                                      // ),
                                                      pw.TableRow(
                                                        children: [
                                                          pw.SizedBox(),
                                                          pw.SizedBox(),
                                                          pw.SizedBox(),
                                                          pw.Center(child: pw.Text('Total Pengeluaran : ')),
                                                          pw.Center(child: pw.Text(controller.calculateTotalPengeluaran(controller.listDataPresence[i], isSingle: true))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                    await Printing.sharePdf(
                                      bytes: await pdfDoc.save(),
                                      filename: 'Rekap - ${Utils.formatTanggaLocal(controller.selectedMonth.toString(), format: "MMMM yyyy")}.pdf',
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
}
