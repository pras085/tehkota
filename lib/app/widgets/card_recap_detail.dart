import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/modules/recap_sallary/recap_sallary_controller.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

class CardRecapDetail extends StatefulWidget {
  final Map data;
  final bool isAdmin;
  final int? index;
  final VoidCallback? onPrintTap;

  const CardRecapDetail({
    super.key,
    required this.index,
    required this.data,
    this.isAdmin = false,
    this.onPrintTap,
  });

  @override
  State<CardRecapDetail> createState() => _CardRecapDetailState();
}

class _CardRecapDetailState extends State<CardRecapDetail> {
  TextEditingController? gajiController;
  TextEditingController? lemburController;
  TextEditingController? potonganController;

  var controller = Get.find<RekapController>();

  @override
  void initState() {
    gajiController = TextEditingController(text: widget.data['gaji']['gaji']);
    lemburController = TextEditingController(text: widget.data['gaji']['lembur']);
    potonganController = TextEditingController(text: widget.data['gaji']['potongan']);
    super.initState();
  }

  @override
  void dispose() {
    gajiController?.dispose();
    lemburController?.dispose();
    potonganController?.dispose();
    super.dispose();
  }

  void updateDataInFirestore() async {
    String userID = widget.data['userID'];
    // Update data di widget.data setelah disimpan
    setState(() {
      widget.data['gaji']['gaji'] = gajiController?.text ?? '';
      widget.data['gaji']['lembur'] = lemburController?.text ?? '';
      widget.data['gaji']['potongan'] = potonganController?.text ?? '';
    });

    // Simpan data ke Firestore
    await controller.firestore.updateFieldGajiInUsersCollection(userID, widget.data['gaji']);
    // Matikan mode edit setelah simpan
    controller.isEditMode[widget.index ?? 0].value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      width: Get.width,
      decoration: const BoxDecoration(
        color: Color(AppColor.colorWhite),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Obx(() {
        bool isEdit = controller.isEditMode[widget.index ?? 0].value;
        return Column(
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/ic_profile.svg",
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 6),
                CustomText(
                  widget.data["userName"].toString(),
                  fontSize: 12,
                ),
                if (widget.isAdmin) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (isEdit) {
                        updateDataInFirestore();
                      } else {
                        controller.toggleEditMode(widget.index ?? 0);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isEdit ? const Color(AppColor.colorLightGreen) : const Color(AppColor.colorBlackNormal),
                      ),
                      child: CustomText(
                        isEdit ? "Simpan" : "Edit",
                        fontWeight: FontWeight.w500,
                        color: isEdit ? const Color(AppColor.colorBlackNormal) : const Color(AppColor.colorWhite),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: widget.onPrintTap,
                    child: const Icon(Icons.print),
                  ),
                ]
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
                                "${widget.data["totalPresence"]} Jam",
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
                                '${widget.data["totalLate"]} Jam',
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
                                "${(widget.data["totalOvertime"] ~/ 60)} Jam",
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
            if (widget.isAdmin) ...[
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
                  CustomText(
                    " ${widget.data["gaji"]["gaji"]}/jam",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  isEdit
                      ? CustomRecapField(controller: gajiController)
                      : CustomText(
                          controller.calculateGajiHadir(widget.data) == "Rp. 0" ? "-" : controller.calculateGajiHadir(widget.data),
                          fontSize: 12,
                        ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const CustomText(
                    "Lembur",
                    fontSize: 12,
                  ),
                  CustomText(
                    " ${widget.data["gaji"]["lembur"]}/jam",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  const Spacer(),
                  isEdit
                      ? CustomRecapField(controller: lemburController)
                      : CustomText(
                          controller.calculateGajiLembur(widget.data) == "Rp. 0" ? "-" : controller.calculateGajiLembur(widget.data),
                          fontSize: 12,
                        ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const CustomText(
                    "Potongan",
                    fontSize: 12,
                    color: Color(AppColor.colorRed),
                  ),
                  CustomText(
                    " ${widget.data["gaji"]["potongan"]} /0.5 jam",
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(AppColor.colorRed),
                  ),
                  const Spacer(),
                  isEdit
                      ? CustomRecapField(controller: potonganController)
                      : CustomText(
                          controller.calculateGajiTerpotong(widget.data) == "Rp. 0" ? "-" : controller.calculateGajiTerpotong(widget.data),
                          fontSize: 12,
                          color: const Color(AppColor.colorRed),
                        ),
                ],
              ),
              Container(
                width: Get.width,
                height: 1,
                color: const Color(AppColor.colorLightGrey),
                margin: const EdgeInsets.symmetric(vertical: 12),
              ),
              if (!isEdit)
                Row(
                  children: [
                    const CustomText(
                      "Total Gaji",
                      fontSize: 12,
                    ),
                    const Spacer(),
                    CustomText(
                      controller.calculateGajiTotal(widget.data) == "Rp. 0" ? "-" : controller.calculateGajiTotal(widget.data),
                      fontSize: 12,
                      color: const Color(AppColor.colorGreen),
                    ),
                  ],
                ),
            ],
          ],
        );
      }),
    );
  }
}

class CustomRecapField extends StatelessWidget {
  final TextEditingController? controller;

  const CustomRecapField({
    super.key,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width / 5,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(AppColor.colorLightGrey)),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(AppColor.colorLightGrey),
            fontFamily: "poppins",
          ),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(AppColor.colorBlack),
          fontFamily: "poppins",
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
      ),
    );
  }
}
