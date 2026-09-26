import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/validate_receipt_controller.dart';

class ValidateReceiptView extends GetView<ValidateReceiptController> {
  const ValidateReceiptView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ValidateReceiptView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ValidateReceiptView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
