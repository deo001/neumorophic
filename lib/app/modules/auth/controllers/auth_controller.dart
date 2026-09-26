import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  //TODO: Implement AuthController

  late final TextEditingController numberKey;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    numberKey = TextEditingController();
  }

  @override
  void onReady() {
    super.onReady();
  }

 @override 
void dispose(){
  numberKey.dispose();
  super.dispose();
}

void inputNumber(int value){
  numberKey.text +=value.toString();
}

void clearlastInput(){
  if (numberKey.text.isNotEmpty) {
    numberKey.text = numberKey.text.substring(0,
    numberKey.text.length - 1);
  }
}

void clearAll(){
  numberKey.clear();
}


  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}
