import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/utils/app_colors.dart';
import 'package:teh_kota/app/widgets/custom_text.dart';

class CustomAppBar extends PreferredSize {
  final String title;
  final Widget? customBody;
  final List<Widget>? prefixIcon;
  final VoidCallback? onClickBack;
  final Widget? titleWidget;
  final double appBarSize;
  CustomAppBar({
    super.key,
    this.title = '',
    this.customBody,
    this.prefixIcon,
    this.onClickBack,
    this.titleWidget,
    this.appBarSize = 56,
    Widget? child,
  }) : super(
          preferredSize: Size.fromHeight(appBarSize),
          child: child ?? const SizedBox.shrink(),
        );

  @override
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Container(
      decoration: const BoxDecoration(
        color: Color(AppColor.colorWhite),
      ),
      child: SafeArea(
        child: Container(
          height: appBarSize,
          padding: const EdgeInsets.all(16),
          color: const Color(AppColor.colorWhite),
          child: Stack(
            children: [
              Container(
                // padding: const EdgeInsets.all(16),
                child: customBody ??
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _backButtonWidget(context),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: _titleProfileWidget(),
                        ),
                        if (prefixIcon != null)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ...?prefixIcon,
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink()
                      ],
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _titleProfileWidget() {
    return titleWidget ??
        CustomText(
          title,
          color: const Color(AppColor.colorBlackNormal),
          fontWeight: FontWeight.w600,
          fontSize: 16,
          textAlign: TextAlign.center,
        );
  }

  Widget _backButtonWidget(context) {
    return InkWell(
      onTap: () => onClickBack ?? Get.back(),
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: 24,
          width: 24,
          // alignment: Alignment.center,
          child: SvgPicture.asset("assets/ic_back_button.svg",),
        ),
      ),
    );
  }
}
