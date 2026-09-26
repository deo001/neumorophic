import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/core/bindings/app_binding.dart';
import 'app/routes/app_pages.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",
      initialBinding: AppBinding(),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
