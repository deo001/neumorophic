import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/neumorphic.dart';

/// One destination in a [NeumorphicBottomNav].
class NeumorphicNavItem {
  const NeumorphicNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;

  /// Icon shown while this destination is selected.
  final IconData activeIcon;

  final String label;
}


class NeumorphicBottomNav extends StatelessWidget {
  const NeumorphicBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NeumorphicNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NeumorphicBox(
      depth: 10,
      // Only the top corners are rounded, so the bar sits flush with the
      // bottom edge of the screen.
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              Expanded(
                child: _NavDestination(
                  item: items[i],
                  isSelected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final NeumorphicNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSelected
        ? CustomColors.primaryColor
        : CustomColors.secondaryTextColor;

    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                width: 46,
                height: 38,
                decoration: BoxDecoration(
                  color: NeumorphicTokens.baseColor,
                  // Selected destination is recessed; the others are flat.
                  gradient: isSelected
                      ? NeumorphicTokens.pressedGradient
                      : null,
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: isSelected
                      ? const <BoxShadow>[]
                      : NeumorphicTokens.raisedShadows(3),
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: 22,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: iconColor,
                ),
                child: Text(item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
