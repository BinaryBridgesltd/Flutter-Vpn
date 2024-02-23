import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final controller = Get.put(PrivacyPolicyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Obx(() => Text.rich(
              TextSpan(
                text: controller.policyText.value,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white60
                        : Colors.black),
              ),
              softWrap: true,
              textWidthBasis: TextWidthBasis.longestLine,
              textAlign: TextAlign.start,
            )),
      ),
    );
  }
}
