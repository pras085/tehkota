import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:teh_kota/app/modules/home/home_view.dart';
import 'package:teh_kota/app/modules/login/login_view.dart';
import 'package:teh_kota/app/modules/presence/presence_view.dart';
import 'package:teh_kota/app/modules/profile/profile_view.dart';
import 'package:teh_kota/app/modules/register/register_view.dart';
import 'package:teh_kota/app/modules/rekap/rekap_view.dart';
import 'package:teh_kota/app/modules/riwayat/riwayat_view.dart';
import 'package:teh_kota/app/utils/utils.dart';
import 'package:teh_kota/app/widgets/custom_fab_button.dart';
import '../utils/app_colors.dart';

class PageViewUserController extends StatefulWidget {
  const PageViewUserController({super.key});

  @override
  State<PageViewUserController> createState() => _PageViewUserControllerState();
}

class _PageViewUserControllerState extends State<PageViewUserController> {
  var selectedIndex = 0.obs;
  PageController pageC = PageController();

  void pageChanged(int index) {
    if (index == 1) return;
    setState(() {
      selectedIndex.value = index;
    });
  }

  void bottomTapped(int index) {
    if (index == 1) {
      return;
    }
    if (index == 2 && Utils.isLoggedIn.value) {
      selectedIndex.value = index;
      Get.offAll(() => const PageViewAdminController());
      Utils.isAdmin.value = true;
      return;
    }
    setState(() {
      selectedIndex.value = index;
      pageC.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  Widget buildPageView() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: pageC,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: const <Widget>[
        HomeView(),
        LoginView(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPageView(),
      bottomNavigationBar: ConvexAppBar(
        cornerRadius: 22,
        backgroundColor: const Color(AppColor.colorWhite),
        activeColor: const Color(AppColor.colorGreen),
        color: const Color(AppColor.colorDarkGrey),
        style: TabStyle.fixed,
        elevation: 0,
        top: -15,
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
              icon: CustomFabButton(
            isGreenColor: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => const PresenceView()),
              );
            },
          )),
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

class PageViewAdminController extends StatefulWidget {
  const PageViewAdminController({super.key});

  @override
  State<PageViewAdminController> createState() => _PageViewAdminControllerState();
}

class _PageViewAdminControllerState extends State<PageViewAdminController> {
  var selectedIndex = 0.obs;
  PageController pageC = PageController();

  void pageChanged(int index) {
    setState(() {
      selectedIndex.value = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      selectedIndex.value = index;
      pageC.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
    });
  }

  Widget buildPageView() {
    return WillPopScope(
      onWillPop: () {
        Get.offAll(() => const PageViewUserController());
        Utils.isAdmin.value = false;
        return Future.value(true);
      },
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageC,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: const <Widget>[
          RegisterView(),
          RiwayatView(),
          RekapView(),
          ProfileView()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildPageView(),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/ic_employee.svg"),
            label: 'Karyawan',
            activeIcon: SvgPicture.asset("assets/ic_employee_active.svg"),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/ic_history.svg"),
            label: 'Riwayat',
            activeIcon: SvgPicture.asset("assets/ic_history_active.svg"),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/ic_recap_nav.svg"),
            label: 'Rekap',
            activeIcon: SvgPicture.asset("assets/ic_recap_active.svg"),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset("assets/ic_profile_nav.svg"),
            label: 'Profile',
            activeIcon: SvgPicture.asset("assets/ic_profile_nav_active.svg"),
          ),
        ],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showUnselectedLabels: true,
        currentIndex: selectedIndex.value,
        selectedItemColor: const Color(AppColor.colorGreen),
        unselectedItemColor: const Color(AppColor.colorDarkGrey),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: bottomTapped,
      ),
    );
  }
}
