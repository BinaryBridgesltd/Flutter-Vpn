import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/helpers/pref.dart';

class MyDialogs {
  static success({required String msg}) {
    Get.snackbar('Success', msg,
        colorText: Pref.isDarkMode ? Colors.blue.shade400 : Colors.black87,
        backgroundColor: Pref.isDarkMode ? Colors.white12 : Colors.white);
  }

  static error({required String msg}) {
    Get.snackbar('Error', msg,
        colorText: Colors.white,
        backgroundColor: Colors.redAccent.withOpacity(.8));
  }

  static info({required String msg}) {
    Get.snackbar('Info', msg,
        colorText: Colors.white, backgroundColor: Colors.blue.shade400);
  }

  static showProgress() {
    Get.dialog(Center(child: CircularProgressIndicator(strokeWidth: 2)));
  }
}
