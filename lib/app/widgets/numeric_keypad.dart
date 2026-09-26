import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/neumorphic.dart';

/// The raised numeric keypad used to enter a PIN.
///
/// Reads 1-2-3 / 4-5-6 / 7-8-9, then spacer, 0 and backspace, matching the
/// layout of a physical PIN pad.
///
/// The grid is sized from the space available rather than a fixed height, so it
/// stays square — and its keys stay circular — on any screen from a small phone
/// to a tablet.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onInputNumber,
    required this.onClearLastInput,
    required this.onClearAll,
    this.enabled = true,
  });

  final ValueSetter<int> onInputNumber;
  final VoidCallback onClearLastInput;
  final VoidCallback onClearAll;
  final bool enabled;

  /// Space between keys, and between the keys and the grid edge.
  static const double _gutter = 12;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double widthLimit =
            (constraints.maxWidth - _gutter * 4) / 3;
        final double heightLimit =
            (constraints.maxHeight - _gutter * 5) / 4;
        // A keypad is never wider than it is tall, so the smaller limit wins
        // and every cell comes out square.
        final double cell = math.max(
          0,
          math.min(widthLimit, heightLimit),
        );

        return Center(
          child: SizedBox(
            width: cell * 3 + _gutter * 4,
            height: cell * 4 + _gutter * 5,
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: <Widget>[
                for (int i = 1; i <= 9; i++)
                  _NumeralKey(
                    number: i,
                    onPressed: () => onInputNumber(i),
                    enabled: enabled,
                  ),
                // Balances the 0 key against the backspace key.
                const SizedBox.shrink(),
                _NumeralKey(
                  number: 0,
                  onPressed: () => onInputNumber(0),
                  enabled: enabled,
                ),
                _BackspaceKey(
                  onClearLastInput: onClearLastInput,
                  onClearAll: onClearAll,
                  enabled: enabled,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NumeralKey extends StatelessWidget {
  const _NumeralKey({
    required this.number,
    required this.onPressed,
    required this.enabled,
  });

  final int number;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NumericKeypad._gutter / 2),
      child: NeumorphicButton(
        onPressed: onPressed,
        enabled: enabled,
        shape: BoxShape.circle,
        depth: 5,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(4),
        child: Center(
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? CustomColors.primaryTextColor
                  : CustomColors.disabledTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Backspace key: tap removes the last digit, long press clears the whole PIN.
class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({
    required this.onClearLastInput,
    required this.onClearAll,
    required this.enabled,
  });

  final VoidCallback onClearLastInput;
  final VoidCallback onClearAll;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(NumericKeypad._gutter / 2),
      child: GestureDetector(
        onLongPress: enabled ? onClearAll : null,
        child: NeumorphicButton(
          onPressed: enabled ? onClearLastInput : null,
          enabled: enabled,
          shape: BoxShape.circle,
          depth: 5,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.all(4),
          child: Icon(
            Icons.backspace_outlined,
            size: 22,
            color: enabled
                ? CustomColors.secondaryTextColor
                : CustomColors.disabledTextColor,
          ),
        ),
      ),
    );
  }
}
