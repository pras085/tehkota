import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';

import '../utils/utils.dart';

class CustomText extends StatelessWidget {
  final TextOverflow? overflow;
  final String stringText;
  final TextAlign textAlign;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final bool fromCenter;

  const CustomText(
    this.stringText, {
    super.key,
    this.textAlign = TextAlign.start,
    this.overflow,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w500,
    this.color = const Color(AppColor.colorBlack),
    this.maxLines,
    this.fromCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      stringText,
      textAlign: textAlign,
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color, fontFamily: "poppins"),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final bool isPassword;
  final String? title;

  final String? hintText;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.title,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _showPass = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null)
          CustomText(
            widget.title!,
            color: const Color(AppColor.colorDarkGrey),
            fontSize: 12,
          )
        else
          const SizedBox.shrink(),
        Utils.gapVertical(8),
        Container(
          width: Get.width,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(AppColor.colorLightGrey)), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  key: widget.key,
                  controller: widget.controller,
                  // focusNode: widget.focusNode,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorLightGrey), fontFamily: "poppins"),
                  ),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorBlack), fontFamily: "poppins"),
                  obscureText: _showPass,
                  // inputFormatters: widget.inputFormatters,
                  // onTap: widget.onTap,
                ),
              ),
              if (widget.isPassword)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showPass = !_showPass;
                    });
                  },
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: Icon(_showPass ? Icons.visibility : Icons.visibility_off),
                  ),
                )
              else
                const SizedBox()
            ],
          ),
        ),
        Utils.gapVertical(16),
      ],
    );
  }
}
