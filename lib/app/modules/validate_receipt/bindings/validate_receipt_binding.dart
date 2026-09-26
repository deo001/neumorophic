import 'package:get/get.dart';

import '../controllers/validate_receipt_controller.dart';

class ValidateReceiptBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ValidateReceiptController>(
      () => ValidateReceiptController(),
    );
  }
}
