import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/screens/network_location_screen.dart';
import 'package:vpn_basic_project/screens/privacy_policy_screen.dart';

import '../models/drawer_item.dart';
import '../screens/home_screen.dart';
import '../screens/app_info.dart';

class LeftDrawerController extends GetxController {
  late Widget currentScreen = HomeScreen();

  final List<DrawerItem> drawerItems = [
    DrawerItem('Home', Icons.home),
    DrawerItem('Network Info', Icons.pageview),
    DrawerItem('Privacy Policy', Icons.policy_rounded),
    DrawerItem('About', CupertinoIcons.info_circle),
  ];

  final selectedDrawerIndex = 0.obs;

  void onDrawerItemSelected(int index) {
    selectedDrawerIndex.value = index;
    changeCurrentScreen(selectedDrawerIndex.value);
    Get.back();
    // Close the drawer after selection
  }

  void changeCurrentScreen(int index) {
    switch (index) {
      case 0:
        {
          currentScreen = HomeScreen();
        }
        break;

      case 1:
        {
          currentScreen = NetworkLocationScreen();
        }
        break;

      case 2:
        {
          currentScreen = PrivacyPolicyScreen();
        }
        break;

      case 3:
        {
          currentScreen = AppInfoScreen(
            appName: 'Your VPN App',
            version: '1.0.0',
            buildNumber: '1000',
            releaseDate: 'February 20, 2024',
            description:
                'Your VPN App is a secure and reliable tool for protecting your online privacy and security.',
          );
        }
        break;

      default:
        {
          currentScreen = HomeScreen();
        }
        break;
    }

    // Notify GetX about the change in _currentScreen
    update();
  }
}
