import 'package:get/get.dart';

import '../../auth/bindings/auth_binding.dart';
import '../../more_services/controllers/more_services_controller.dart';
import '../../validate_receipt/controllers/validate_receipt_controller.dart';
import '../controllers/shell_controller.dart';

/// Registers the shell, the controllers of the tabs it hosts, and the login
/// form it shows while signed out.
///
/// The shell is the only place these tabs and the login form are mounted now, so
/// their controllers are registered here rather than in per-route bindings.
class ShellBinding extends Bindings {
  ShellBinding({this.initialIndex = ShellController.overviewTab});

  final int initialIndex;

  @override
  void dependencies() {
    Get.lazyPut<ShellController>(
      () => ShellController(initialIndex: initialIndex),
    );
    Get.lazyPut<ValidateReceiptController>(ValidateReceiptController.new);
    Get.lazyPut<MoreServicesController>(MoreServicesController.new);
    // AuthView is hosted by the shell, so its controller must exist even when
    // the login form is reached through the shell rather than its own route.
    AuthBinding().dependencies();
  }
}
