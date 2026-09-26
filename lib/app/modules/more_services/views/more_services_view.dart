import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/more_services_controller.dart';

class MoreServicesView extends GetView<MoreServicesController> {
  const MoreServicesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MoreServicesView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'MoreServicesView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
