import 'package:get/get.dart';

import '../controllers/more_services_controller.dart';

class MoreServicesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MoreServicesController>(
      () => MoreServicesController(),
    );
  }
}
