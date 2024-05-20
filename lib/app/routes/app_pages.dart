import 'package:get/get.dart';
import 'package:teh_kota/app/modules/testing/testing_binding.dart';
import 'package:teh_kota/app/modules/testing/testing_view.dart';

import '../modules/admin/admin_binding.dart';
import '../modules/admin/admin_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/rekap/rekap_binding.dart';
import '../modules/rekap/rekap_view.dart';
import '../modules/riwayat/riwayat_binding.dart';
import '../modules/riwayat/riwayat_view.dart';
import '../modules/splash_screen/splash_binding.dart';
import '../modules/splash_screen/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.TESTING,
      page: () => const TestingView(),
      binding: TestingBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: Routes.RIWAYAT,
      page: () => const RiwayatView(),
      binding: RiwayatBinding(),
    ),
    GetPage(
      name: Routes.REKAP,
      page: () => const RekapView(),
      binding: RekapBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
  ];
}
