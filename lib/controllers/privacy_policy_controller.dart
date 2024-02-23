import 'package:get/get.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class PrivacyPolicyController extends GetxController {
  var policyText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPolicyText();
  }

  Future<void> _loadPolicyText() async {
    try {
      var text = await rootBundle.loadString('assets/text/privacy_policy.txt');
      policyText.value = text;
    } catch (e) {
      print(e.toString());
      policyText.value = 'Failed to load privacy policy';
    }
  }
}
