import 'package:get/get.dart';
import 'package:teh_kota/app/modules/register/register_binding.dart';
import 'package:teh_kota/app/modules/register/register_view.dart';
import 'package:teh_kota/app/modules/settings/settings_binding.dart';
import 'package:teh_kota/app/modules/settings/settings_view.dart';

import '../modules/profile/profile_binding.dart';
import '../modules/profile/profile_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/recap_sallary/recap_sallary_binding.dart';
import '../modules/recap_sallary/recap_sallary_view.dart';
import '../modules/history/history_binding.dart';
import '../modules/history/history_view.dart';
import '../modules/splash_screen/splash_binding.dart';
import '../modules/splash_screen/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
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
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.RECAP,
      page: () => const RekapView(),
      binding: RekapBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.SETTING,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
  ];
}
