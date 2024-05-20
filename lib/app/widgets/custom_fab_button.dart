import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:teh_kota/app/utils/app_colors.dart';

class CustomFabButton extends StatelessWidget {
  final bool isGreenColor;
  final VoidCallback onTap;
  const CustomFabButton({
    super.key,
    this.isGreenColor = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: isGreenColor ? const EdgeInsets.only(bottom: 16) : EdgeInsets.zero,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF613EEA).withOpacity(0.5),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
          ],
          shape: BoxShape.circle,
          color: isGreenColor ? const Color(AppColor.colorWhite) : const Color(AppColor.colorGreen),
          border: Border.all(
            color: isGreenColor ? const Color(AppColor.colorGreen) : const Color(AppColor.colorWhite),
            width: 2,
          ),
        ),
        width: 55,
        height: 55,
        padding: EdgeInsets.zero,
        child: SvgPicture.asset(
          "assets/ic_face_scan.svg",
          color: isGreenColor ? const Color(AppColor.colorGreen) : const Color(AppColor.colorWhite),
          width: isGreenColor ? 32 : 24,
          height: isGreenColor ? 32 : 24,
        ),
      ),
    );
  }
}
