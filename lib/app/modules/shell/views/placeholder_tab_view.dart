import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/neumorphic.dart';


class PlaceholderTabView extends StatelessWidget {
  const PlaceholderTabView({
    super.key,
    required this.title,
    required this.icon,
  });

  /// Name of the destination, as the navigation bar labels it.
  final String title;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              NeumorphicBox(
                shape: BoxShape.circle,
                depth: 8,
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(28),
                child: Icon(icon, size: 38, color: CustomColors.primaryColor),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: CustomColors.primaryTextColor,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Coming soon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: CustomColors.primaryColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This screen has not been built yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: CustomColors.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
