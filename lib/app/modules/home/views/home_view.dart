import 'package:flutter/material.dart';

import '../../../core/colors.dart';
import '../../../core/neumorphic.dart';

/// Signed-in landing screen.
///
/// Deliberately a placeholder: the account summary and quick actions are the
/// next piece of work, so this establishes the layout and the card style the
/// rest of the home screen will follow.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: <Widget>[
          Row(
            children: <Widget>[
              NeumorphicBox(
                shape: BoxShape.circle,
                depth: 5,
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 22,
                  color: CustomColors.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Good day',
                    style: TextStyle(
                      fontSize: 12,
                      color: CustomColors.secondaryTextColor,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Welcome back',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CustomColors.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          NeumorphicBox(
            radius: NeumorphicTokens.radiusLarge,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Total balance',
                  style: TextStyle(
                    fontSize: 13,
                    color: CustomColors.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '--',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: CustomColors.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Account summary coming next',
                  style: TextStyle(
                    fontSize: 12,
                    color: CustomColors.disabledTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          NeumorphicBox(
            variant: NeumorphicVariant.flat,
            radius: NeumorphicTokens.radiusMedium,
            padding: const EdgeInsets.all(18),
            child: const Row(
              children: <Widget>[
                Icon(
                  Icons.construction_outlined,
                  size: 20,
                  color: CustomColors.secondaryTextColor,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Home is a placeholder for now. Use the Receipt and Services tabs below.',
                    style: TextStyle(
                      fontSize: 12,
                      color: CustomColors.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
