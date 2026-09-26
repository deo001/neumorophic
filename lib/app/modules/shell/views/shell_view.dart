import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/neumorphic.dart';
import '../../../widgets/neumorphic_bottom_nav.dart';
import '../../auth/views/auth_view.dart';
import '../../home/views/home_view.dart';
import '../../more_services/views/more_services_view.dart';
import '../../validate_receipt/views/validate_receipt_view.dart';
import '../controllers/shell_controller.dart';
import 'placeholder_tab_view.dart';

/// The app container: one bottom navigation bar, with the menu changing once the
/// user signs in.
///
/// Signed out the bar reads Home, Receipt, Locations, Services. Signed in it
/// reads Home, Transfer, Services, Profile.
///
/// Receipt, Locations and Services are deliberately reachable without a session:
/// scanning a receipt and browsing the service catalogue are things a customer
/// should be able to do before committing to a login. Only the overview slot
/// depends on the session — it shows the login form signed out and the account
/// home signed in.
///
/// Tabs live in an [IndexedStack] so switching preserves each one's scroll
/// position and state.
class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  /// Menu shown before the user signs in.
  static const List<NeumorphicNavItem> _signedOutItems = <NeumorphicNavItem>[
    NeumorphicNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NeumorphicNavItem(
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner_rounded,
      label: 'Receipt',
    ),
    NeumorphicNavItem(
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on_rounded,
      label: 'Locations',
    ),
    NeumorphicNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Services',
    ),
  ];

  /// Menu shown after the user signs in.
  static const List<NeumorphicNavItem> _signedInItems = <NeumorphicNavItem>[
    NeumorphicNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    NeumorphicNavItem(
      icon: Icons.swap_horiz_rounded,
      activeIcon: Icons.swap_horiz_rounded,
      label: 'Transfer',
    ),
    NeumorphicNavItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'Services',
    ),
    NeumorphicNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  /// Content slot shown at each bar position, signed out.
  static const List<int> _signedOutSlots = <int>[
    ShellController.overviewTab,
    ShellController.receiptTab,
    ShellController.locationsTab,
    ShellController.servicesTab,
  ];

  /// Content slot shown at each bar position, signed in.
  static const List<int> _signedInSlots = <int>[
    ShellController.overviewTab,
    ShellController.transferTab,
    ShellController.servicesTab,
    ShellController.profileTab,
  ];

  /// Slot index backing each bar position, for the current auth state.
  static List<int> slotsFor({required bool isSignedIn}) =>
      isSignedIn ? _signedInSlots : _signedOutSlots;

  /// The nav items for the current auth state.
  static List<NeumorphicNavItem> itemsFor({required bool isSignedIn}) =>
      isSignedIn ? _signedInItems : _signedOutItems;

  /// The name of the destination a slot shows, so an unbuilt screen can title
  /// itself with whatever the bar currently calls it.
  static String labelForSlot(int slot, {required bool isSignedIn}) {
    final List<int> slots = slotsFor(isSignedIn: isSignedIn);
    final int position = slots.indexOf(slot);
    if (position == -1) return 'Coming soon';
    return itemsFor(isSignedIn: isSignedIn)[position].label;
  }

  /// Builds the tab stack for the current auth state.
  ///
  /// Not a const list because the overview slot swaps between the login form and
  /// the account home, and the unbuilt screens are titled from the bar.
  static List<Widget> buildTabs({required bool isSignedIn}) => <Widget>[
    // Signed out, the overview is the login form. This is the only slot that
    // cares about the session.
    isSignedIn ? const HomeView() : const AuthView(),
    const ValidateReceiptView(),
    const MoreServicesView(),
    PlaceholderTabView(
      title: labelForSlot(ShellController.locationsTab, isSignedIn: isSignedIn),
      icon: Icons.location_on_outlined,
    ),
    PlaceholderTabView(
      title: labelForSlot(ShellController.transferTab, isSignedIn: isSignedIn),
      icon: Icons.swap_horiz_rounded,
    ),
    PlaceholderTabView(
      title: labelForSlot(ShellController.profileTab, isSignedIn: isSignedIn),
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isSignedIn = controller.isSignedIn;
      final List<int> slots = slotsFor(isSignedIn: isSignedIn);

      // A slot can be absent from the menu currently on screen: Receipt is only
      // offered before signing in, so a deep link to the scanner afterwards
      // lands on Home rather than showing a screen the bar cannot represent.
      final int activeSlot = slots.contains(controller.currentIndex.value)
          ? controller.currentIndex.value
          : ShellController.overviewTab;
      final int activePosition = slots.indexOf(activeSlot);

      return Scaffold(
        backgroundColor: NeumorphicTokens.baseColor,
        body: IndexedStack(
          index: activeSlot,
          children: buildTabs(isSignedIn: isSignedIn),
        ),
        bottomNavigationBar: NeumorphicBottomNav(
          items: itemsFor(isSignedIn: isSignedIn),
          currentIndex: activePosition,
          onTap: (int position) => controller.selectTab(slots[position]),
        ),
      );
    });
  }
}
