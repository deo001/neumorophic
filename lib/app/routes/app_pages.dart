import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/shell/bindings/shell_binding.dart';
import '../modules/shell/controllers/shell_controller.dart';
import '../modules/shell/views/shell_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  /// The shell owns the bottom navigation, so every tab is a path into it.
  ///
  /// No route middleware is attached: scanning a receipt, browsing services and
  /// finding a location are all reachable signed out, and the one slot that
  /// does need a session swaps between the login form and the account home
  /// inside the shell. Reintroduce a guard when a genuinely private screen
  /// exists, and apply it to that route only.
  static final routes = [
    GetPage(
      name: _Paths.SHELL,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const ShellView(),
      binding: ShellBinding(initialIndex: ShellController.overviewTab),
    ),
    GetPage(
      name: _Paths.VALIDATE_RECEIPT,
      page: () => const ShellView(),
      binding: ShellBinding(initialIndex: ShellController.receiptTab),
    ),
    GetPage(
      name: _Paths.MORE_SERVICES,
      page: () => const ShellView(),
      binding: ShellBinding(initialIndex: ShellController.servicesTab),
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
  ];
}
