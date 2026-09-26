import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/more_services/bindings/more_services_binding.dart';
import '../modules/more_services/views/more_services_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/validate_receipt/bindings/validate_receipt_binding.dart';
import '../modules/validate_receipt/views/validate_receipt_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.VALIDATE_RECEIPT,
      page: () => const ValidateReceiptView(),
      binding: ValidateReceiptBinding(),
    ),
    GetPage(
      name: _Paths.MORE_SERVICES,
      page: () => const MoreServicesView(),
      binding: MoreServicesBinding(),
    ),
  ];
}
