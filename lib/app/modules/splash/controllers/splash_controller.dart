import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/routes/app_pages.dart';

class SplashController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late final AnimationController _animController;

  late final Animation<double> middleLogoScale;
  late final Animation<double> middleLogoOpacity;

  late final Animation<Offset> bottomLogoOffset;
  late final Animation<double> bottomLogoOpacity;

  @override
  void onInit() {
    super.onInit();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Middle logo — scale from 0.6 (far) to 1.0 (front). 40% growth.
    middleLogoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );
    middleLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // Bottom logo — slide from 60% below up to its place.
    bottomLogoOffset =
        Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    bottomLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await _animController.forward();
    await Future.delayed(const Duration(seconds: 2));
    if (isClosed) return;
    Get.offAllNamed(Routes.SHELL);
  }

  @override
  void onClose() {
    _animController.dispose();
    super.onClose();
  }
}
