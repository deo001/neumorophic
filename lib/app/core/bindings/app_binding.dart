import 'package:get/get.dart';

import '../auth/auth_service.dart';

/// Application-wide dependencies, registered once before any route loads.
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Permanent: the session must not be garbage collected while routes churn.
    Get.put<AuthService>(AuthService(), permanent: true);
  }
}
