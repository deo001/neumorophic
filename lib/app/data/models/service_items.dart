import 'package:flutter/material.dart';

class ServiceItem {
  const ServiceItem({
    required this.label,
    required this.icon,
    this.isNew = false,
  });

  final String label;
  final IconData icon;

  final bool isNew;
}
