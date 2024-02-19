import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../helpers/ad_helper.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import '../models/vpn_config.dart';
import '../services/vpn_engine.dart';

class HomeController extends GetxController {
  final Rx<Vpn> vpn = Pref.vpn.obs;
  final vpnState = VpnEngine.vpnDisconnected.obs;

  void connectToVpn() async {
    if (vpn.value.openVPNConfigDataBase64.isEmpty) {
      MyDialogs.info(msg: 'Select a Location by clicking \'Select Location\'');
      return;
    }

    if (vpnState.value == VpnEngine.vpnDisconnected) {
      final data = Base64Decoder().convert(vpn.value.openVPNConfigDataBase64);
      final config = Utf8Decoder().convert(data);
      final vpnConfig = VpnConfig(
        country: vpn.value.countryLong,
        username: kVpnUsername,
        password: kVpnPassword,
        config: config,
      );

      AdHelper.showInterstitialAd(onComplete: () async {
        try {
          await VpnEngine.startVpn(vpnConfig);
        } catch (e) {
          MyDialogs.error(msg: 'Failed to start VPN: $e');
        }
      });
    } else {
      try {
        await VpnEngine.stopVpn();
      } catch (e) {
        MyDialogs.error(msg: 'Failed to stop VPN: $e');
      }
    }
  }

  Color get getButtonColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Pref.isDarkMode ? Colors.white24 : Colors.white;
      case VpnEngine.vpnConnected:
        return const Color(0xFFFF06A30);
      default:
        return Colors.orangeAccent;
    }
  }

  Color get getButtonTextIconColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Pref.isDarkMode ? Colors.white : const Color(0xFFFF06A30);
      case VpnEngine.vpnConnected:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  Color get getBorderColor {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Colors.grey.shade200;
      case VpnEngine.vpnConnected:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  IconData get getIcon {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return Icons.power_settings_new_rounded;
      case VpnEngine.vpnConnected:
        return Icons.stop_rounded;
      default:
        return Icons.private_connectivity_rounded;
    }
  }

  String get getButtonText {
    switch (vpnState.value) {
      case VpnEngine.vpnDisconnected:
        return 'Start';
      case VpnEngine.vpnConnected:
        return 'Stop';
      default:
        return '';
    }
  }
}

// Constants
const String kVpnUsername = 'vpn';
const String kVpnPassword = 'vpn';
