import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final bool isOnlyNumber;

  final String? hintText;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.hintText,
    this.isPassword = false,
    this.title,
    this.isOnlyNumber = false,
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
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
                      isDense: true,
                      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorLightGrey), fontFamily: "poppins"),
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorBlack), fontFamily: "poppins"),
                    obscureText: _showPass,
                    keyboardType: widget.isOnlyNumber ? TextInputType.number : null,
                    inputFormatters: widget.isOnlyNumber ? [FilteringTextInputFormatter.digitsOnly] : [],
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
                      child: Icon(_showPass ? Icons.visibility_off : Icons.visibility),
                    ),
                  )
                else
                  const SizedBox()
              ],
            ),
          ),
          Utils.gapVertical(16),
        ],
      ),
    );
  }
}

class CustomSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onSubmit;
  final bool isDisable;
  final Function()? onClearTap;

  const CustomSearchField({
    super.key,
    this.controller,
    this.hintText,
    required this.onSubmit,
    this.isDisable = false,
    this.onClearTap,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  bool _isSeacrch = false;
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
        Container(
          width: Get.width,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: widget.isDisable ? Colors.grey.shade50 : Colors.white,
            border: Border.all(color: const Color(AppColor.colorLightGrey)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                    key: widget.key,
                    controller: widget.controller,
                    enabled: !widget.isDisable,
                    decoration: InputDecoration(
                      icon: const Icon(Icons.search),
                      iconColor: const Color(AppColor.colorGreen),
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      isDense: true,
                      hintText: widget.isDisable ? null : "Masukkan nama karyawan",
                      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorLightGrey), fontFamily: "poppins"),
                    ),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(AppColor.colorBlack), fontFamily: "poppins"),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _isSeacrch = true;
                        });
                      }
                    },
                    onSubmitted: widget.onSubmit),
              ),
              if (_isSeacrch)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.controller?.clear();
                      _isSeacrch = !_isSeacrch;
                      widget.onClearTap!();
                    });
                  },
                  child: const SizedBox(
                    height: 24,
                    width: 24,
                    child: Icon(Icons.close),
                  ),
                )
              else
                const SizedBox()
            ],
          ),
        ),
      ],
    );
  }
}
