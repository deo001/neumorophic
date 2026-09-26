import 'package:get/get.dart';

import '../../../core/auth/auth_service.dart';

/// Owns the bottom navigation: which destination is showing, and whether the
/// signed-in or signed-out menu applies.
///
/// Each destination maps to a fixed content slot. The two menus list those
/// slots in different orders, so the slot index and the position in the bar are
/// deliberately kept separate.
class ShellController extends GetxController {
  /// Content slots. These never move, whatever the menu order is.
  ///
  /// The overview is the only slot that depends on the session; the rest are
  /// reachable signed out.
  static const int overviewTab = 0;
  static const int receiptTab = 1;
  static const int servicesTab = 2;
  static const int locationsTab = 3;
  static const int transferTab = 4;
  static const int profileTab = 5;

  static const int tabCount = 6;

  ShellController({int initialIndex = overviewTab}) : _initialIndex = initialIndex;

  final int _initialIndex;

  final RxInt currentIndex = overviewTab.obs;

  /// Whether the signed-in menu applies.
  bool get isSignedIn => Get.find<AuthService>().isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = _initialIndex;
  }

  /// Switches destination. Tapping the active one is a no-op so the scanner is
  /// not restarted by an accidental double tap.
  void selectTab(int index) {
    if (index < 0 || index >= tabCount) return;
    if (index == currentIndex.value) return;
    currentIndex.value = index;
  }
}
