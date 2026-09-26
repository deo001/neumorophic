import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';

/// A single banking service offered on the More Services screen.
class ServiceItem {
  const ServiceItem({
    required this.label,
    required this.icon,
    this.isNew = false,
  });

  final String label;
  final IconData icon;

  /// Marks a recently added service with an accent dot.
  final bool isNew;
}

/// The services catalogue.
///
/// Kept as data so the screen is a list to render, not a hard-coded grid.
class MoreServicesController extends GetxController {
  static const List<ServiceItem> services = <ServiceItem>[
    ServiceItem(label: 'Transfer', icon: Icons.send_rounded),
    ServiceItem(label: 'Deposit', icon: Icons.add_card_rounded),
    ServiceItem(label: 'Withdraw', icon: Icons.payments_rounded),
    ServiceItem(label: 'Balance', icon: Icons.account_balance_wallet_rounded),
    ServiceItem(label: 'Statement', icon: Icons.receipt_long_rounded),
    ServiceItem(label: 'Cards', icon: Icons.credit_card_rounded),
    ServiceItem(label: 'Loans', icon: Icons.request_quote_rounded),
    ServiceItem(label: 'Pay Bill', icon: Icons.receipt_rounded, isNew: true),
    ServiceItem(label: 'Utilities', icon: Icons.bolt_rounded),
    ServiceItem(label: 'Settings', icon: Icons.settings_rounded),
    ServiceItem(label: 'Support', icon: Icons.support_agent_rounded),
    ServiceItem(label: 'Locations', icon: Icons.location_on_rounded),
  ];

  /// Opens a service.
  ///
  /// None of these destinations exist yet, so the tap is acknowledged instead
  /// of silently doing nothing.
  void onServiceTap(ServiceItem service) {
    Get.snackbar(
      service.label,
      '${service.label} is coming soon',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 20,
      backgroundColor: CustomColors.backgroundColor,
      colorText: CustomColors.primaryTextColor,
      icon: Icon(service.icon, color: CustomColors.primaryColor),
      duration: const Duration(seconds: 2),
    );
  }
}
