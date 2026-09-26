import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/core/auth/auth_service.dart';
import 'package:neumorophic/app/routes/app_pages.dart';


class AuthController extends GetxController with GetSingleTickerProviderStateMixin {
  static const int pinLength = 4;
  static const String validPin = '2580';
  final RxString pin = <String>[].join().obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxInt shakeToken = 0.obs;
  late final AnimationController shakeController;
  late final Animation<double> shakeAnimation;
  bool get isComplete => pin.value.length == pinLength;
  bool get canSubmit => isComplete && !isLoading.value;

  @override
  void onInit() {
    super.onInit();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );


    shakeAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 0, end: -16),
            weight: 1,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: -16, end: 14),
            weight: 2,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 14, end: -8),
            weight: 2,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: -8, end: 0),
            weight: 1,
          ),
        ]).animate(shakeController);
  }


  void inputNumber(int value) {
    if (isLoading.value) return;
    if (pin.value.length >= pinLength) return;

    _clearError();
    pin.value = '${pin.value}$value';

    if (isComplete) {
      unawaited(submitPin());
    }
  }

  void clearlastInput() {
    if (isLoading.value) return;
    if (pin.value.isEmpty) return;

    _clearError();
    pin.value = pin.value.substring(0, pin.value.length - 1);
  }

  void clearAll() {
    if (isLoading.value) return;

    _clearError();
    pin.value = '';
  }

  Future<void> submitPin() async {
    if (!canSubmit) return;

    isLoading.value = true;
    _clearError();

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (isClosed) return;

    if (_isCorrect(pin.value)) {
      isLoading.value = false;
      Get.find<AuthService>().login();
      Get.offAllNamed(Routes.SHELL);
      return;
    }

    await _rejectPin();
  }

  Future<void> _rejectPin() async {
    _clearError();
    shakeToken.value++;
    shakeController.forward(from: 0);

    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (isClosed) return;

    hasError.value = true;
    isLoading.value = false;
    pin.value = '';
  }

  void _clearError() {
    hasError.value = false;
  }

  bool _isCorrect(String candidate) =>
      candidate.length == pinLength && candidate == validPin;

  @override
  void onClose() {
    shakeController.dispose();
    super.onClose();
  }
}
