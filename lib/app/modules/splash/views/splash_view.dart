import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:neumorophic/app/core/colors.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      body: Column(
        children: [
          // Middle logo: scales from "far" (small) to "front" (full size)
          Expanded(
            child: Center(
              child: ScaleTransition(
                scale: controller.middleLogoScale,
                child: FadeTransition(
                  opacity: controller.middleLogoOpacity,
                  child: Image.asset(
                    'assets/images/crdb_logo.png',
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
          ),

          // Bottom logo: slides from below (bottom) to up
          SlideTransition(
            position: controller.bottomLogoOffset,
            child: FadeTransition(
              opacity: controller.bottomLogoOpacity,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/crdb_logo.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}