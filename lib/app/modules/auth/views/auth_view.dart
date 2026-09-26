import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:neumorophic/app/core/colors.dart';
import 'package:neumorophic/app/widgets/numeric_keypad.dart';

import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.backgroundColor,
      appBar: AppBar(
        title: Text('AuthView'),
        backgroundColor: CustomColors.backgroundColor,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 40),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: controller.numberKey,
                  autofocus: true,
                  showCursor: true,
                  keyboardType: TextInputType.none,
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: NumericKeypad(
                onInputNumber: controller.inputNumber,
                onClearLastInput: controller.clearlastInput,
                onClearAll: controller.clearAll,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
