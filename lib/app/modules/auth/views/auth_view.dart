import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/colors.dart';
import '../../../core/neumorphic.dart';
import '../../../widgets/numeric_keypad.dart';
import '../controllers/auth_controller.dart';


class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeumorphicTokens.baseColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isShort = constraints.maxHeight < 640;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: isShort ? 16 : 24),
              child: Column(
                children: <Widget>[
                  _BrandHeader(compact: isShort),
                  SizedBox(height: isShort ? 14 : 24),
                  const _PinSlot(),
                  Obx(
                    () => SizedBox(
                      height: 24,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: controller.hasError.value ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Text(
                            'Incorrect PIN, please try again',
                            style: TextStyle(
                              color: CustomColors.errorColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isShort ? 4 : 10),
                  Expanded(
                    child: Obx(
                      () => NumericKeypad(
                        onInputNumber: controller.inputNumber,
                        onClearLastInput: controller.clearlastInput,
                        onClearAll: controller.clearAll,
                        enabled: !controller.isLoading.value,
                      ),
                    ),
                  ),
                  _FooterHint(compact: isShort),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final double logoSize = compact ? 72 : 92;

    return Padding(
      padding: EdgeInsets.only(top: compact ? 16 : 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          NeumorphicBox(
            shape: BoxShape.circle,
            depth: 8,
            width: logoSize,
            height: logoSize,
            padding: EdgeInsets.all(logoSize * 0.19),
            child: const Image(
              image: AssetImage('assets/images/crdb_logo.png'),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: compact ? 14 : 20),
          Text(
            'Welcome back',
            style: TextStyle(
              fontSize: compact ? 19 : 22,
              fontWeight: FontWeight.w700,
              color: CustomColors.primaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enter your 4-digit PIN to continue',
            style: TextStyle(
              fontSize: 13,
              color: CustomColors.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}


class _PinSlot extends StatelessWidget {
  const _PinSlot();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Obx(() {
      final int filled = controller.pin.value.length;
      final bool isLoading = controller.isLoading.value;
      final bool hasError = controller.hasError.value;

      return AnimatedBuilder(
        animation: controller.shakeController,
        builder: (BuildContext context, Widget? child) {
          return Transform.translate(
            offset: Offset(controller.shakeAnimation.value, 0),
            child: child,
          );
        },
        child: NeumorphicBox(
          variant: NeumorphicVariant.pressed,
          radius: NeumorphicTokens.radiusLarge,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 28),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                NeumorphicDots(
                  total: AuthController.pinLength,
                  filled: filled,
                ),
                if (isLoading) ...<Widget>[
                  const SizedBox(width: 14),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        hasError
                            ? CustomColors.errorColor
                            : CustomColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _FooterHint extends StatelessWidget {
  const _FooterHint({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: compact ? 6 : 14, bottom: compact ? 8 : 16),
      child: const Text(
        'Press and hold  ⌫  to clear',
        style: TextStyle(fontSize: 12, color: CustomColors.disabledTextColor),
      ),
    );
  }
}
