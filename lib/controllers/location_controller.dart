import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/ip_details.dart';
import '../models/ping_model.dart';
import '../models/vpn.dart';

class LocationController extends GetxController {
  RxList<Vpn> vpnList = Pref.vpnList.obs;

  RxBool isLoading = false.obs;
  RxBool isDataFetching = false.obs;

  final RxDouble loadingProgress = 0.0.obs;

  Future<void> getVpnData() async {
    isDataFetching(true);
    loadingProgress.value = 0.0;
    isLoading(true);
    vpnList.clear();
    loadingProgress.value = 0.0;
    getVPNServers();
    isDataFetching(false);

    // isLoading(false);
    // Update your vpnList here
  }

  Future<void> getVPNServers() async {
    final Map<String, List<Vpn>> vpnMap = {};

    try {
      final res =
          await http.get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      final csvString = res.body.split("#")[1].replaceAll('*', '');

      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];
      final totalServers = list.length - 1; // Subtract header

      int processedCount = 0;

      await Future.forEach(list.skip(1), (row) async {
        if (row.length != header.length) {
          return; // Skip rows with different lengths from the header
        }

        Map<String, dynamic> tempJson =
            Map.fromIterables(header.map((e) => e.toString()), row);
        Vpn vpn = Vpn.fromJson(tempJson);

        var pingResult = await _performPingTest(vpn.ip);
        if (pingResult.status == PingStatus.success &&
            pingResult.pingTime <= 200) {
          if (!Pref.vpnList.any((existingVpn) => existingVpn.ip == vpn.ip)) {
            // Add new VPN server
            vpnMap.putIfAbsent(vpn.ip, () => []).add(vpn);
            vpn.pingTime = pingResult.pingTime;
            vpnList.add(vpn);
            isLoading.value = false;
          }
        }

        // Increment processed count and calculate progress
        processedCount++;
        if (loadingProgress.value > .90) {
          isDataFetching(false);
          print(isDataFetching.value);
        } else {
          isDataFetching(true);
          print(true);
        }

        loadingProgress.value = processedCount / totalServers;

        print(
            "Progress: ${loadingProgress.value}"); // Print progress for debugging
      });

      // Sort and update Pref.vpnList
      vpnList.sort((a, b) => a.countryLong.compareTo(b.countryLong));
      Pref.vpnList = vpnList.map((vpn) => vpn.copyWith()).toList();
    } catch (e) {
      // Handle errors appropriately
      print('Error fetching VPN servers: $e');
      throw e; // Rethrow the exception or handle it gracefully
    }
  }

  static Future<PingResult> _performPingTest(String ip) async {
    try {
      final ping = Ping(ip.toString());
      var stream = ping.stream;
      var pingValue = await stream.first;

      if (pingValue.summary == null && pingValue.error == null) {
        return PingResult(PingStatus.success,
            pingTime: pingValue.response!.time!.inMilliseconds);
      } else {
        return PingResult(
          PingStatus.failure,
        );
      }
    } catch (e) {
      print('Ping test failed for IP: $ip, Error: $e');
      return PingResult(PingStatus.failure);
    }
  }
}
