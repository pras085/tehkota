import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/modules/home/home_view.dart';
import 'package:teh_kota/app/modules/login/login_view.dart';
import '../modules/presence/presence_view.dart';
import '../utils/app_colors.dart';

class PageViewController extends StatefulWidget {
  const PageViewController({super.key});

  @override
  State<PageViewController> createState() => _PageViewControllerState();
}

class _PageViewControllerState extends State<PageViewController> {
  var selectedIndex = 0.obs;
  PageController pageC = PageController();


  void pageChanged(int index) {
    setState(() {
      selectedIndex.value = index;
    });
  }

  void bottomTapped(int index) {
    // if (index == 1) {
    //   print("object");
    //   return;
    // }
    setState(() {
      selectedIndex.value = index;
      pageC.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  Widget buildPageView() {
    return PageView(
      controller: pageC,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: const <Widget>[
        HomeView(),
        PresenceView(),
        LoginView(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  buildPageView(),
      bottomNavigationBar: ConvexAppBar(
        cornerRadius: 22,
        backgroundColor: const Color(AppColor.colorWhite),
        activeColor: const Color(AppColor.colorGreen),
        color: const Color(AppColor.colorDarkGrey),
        style: TabStyle.fixed,
        elevation: 0,
        items: [
          TabItem(
            title: "Beranda",
            fontFamily: "poppins",
            icon: SvgPicture.asset(
              "assets/ic_nav_home.svg",
              color: const Color(AppColor.colorDarkGrey),
            ),
            activeIcon: SvgPicture.asset(
              "assets/ic_nav_home.svg",
              color: const Color(AppColor.colorGreen),
            ),
          ),
          TabItem(
            icon: CircleAvatar(
              backgroundColor: const Color(AppColor.colorGreen),
              child: ClipRect(
                child: SvgPicture.asset(
                  "assets/ic_face_scan.svg",
                ),
              ),
            ),
          ),
          TabItem(
            title: "Login",
            fontFamily: "poppins",
            icon: SvgPicture.asset(
              "assets/ic_nav_login.svg",
              color: const Color(AppColor.colorDarkGrey),
            ),
            activeIcon: SvgPicture.asset(
              "assets/ic_nav_login.svg",
              color: const Color(AppColor.colorGreen),
            ),
          ),
        ],
        initialActiveIndex: selectedIndex.value,
        onTap: (int i) {
          bottomTapped(i);
        },
      ),
    );
  }
}
