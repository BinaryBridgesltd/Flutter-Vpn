import 'dart:math';

import 'package:csv/csv.dart';
import 'package:dart_ping/dart_ping.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../helpers/pref.dart';
import '../models/ping_model.dart';
import '../models/vpn.dart';

class LocationController extends GetxController {
  RxList<Vpn> vpnList = Pref.vpnList.obs;

  RxBool isLoading = false.obs;
  final RxDouble loadingProgress = 0.0.obs;

  Future<void> getVpnData() async {
    isLoading(true);
    loadingProgress.value = 0.0;

    try {
      await _getVPNServers();
    } catch (e) {
      // Handle errors appropriately
      print('Error fetching VPN servers: $e');
      // Handle the error and return or rethrow if needed
      return;
    } finally {
      // Set isLoading to false when loading is finished
      isLoading(false);
      // Ensure loadingProgress is 100% when loading is finished
      loadingProgress.value = 1.0;
    }
  }

  Future<void> _getVPNServers() async {
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

        // Check if the server's IP is already in Pref.vpnList
        if (Pref.vpnList.any((existingVpn) => existingVpn.ip == vpn.ip)) {
          return; // Skip this server if already exists in Pref.vpnList
        }

        var pingResult = await _performPingTest(vpn.ip);
        if (pingResult.status == PingStatus.success &&
            pingResult.pingTime <= 250 &&
            vpn.openVPNConfigDataBase64.isNotEmpty) {
          if (vpnMap.containsKey(vpn.ip)) {
            // Check if already added a VPN from this country
            var existingVPNs = vpnMap[vpn.ip]!;
            if (existingVPNs.length < 3) {
              vpnMap[vpn.ip]!.add(vpn);
              vpn.pingTime = pingResult.pingTime;
              vpnList.add(vpn);
            } else {
              // Replace the VPN with the lowest ping time if it's higher
              var minPingIndex = existingVPNs.indexWhere((v) =>
                  v.pingTime ==
                  existingVPNs.map((v) => v.pingTime).reduce(min));
              if (pingResult.pingTime < existingVPNs[minPingIndex].pingTime) {
                existingVPNs[minPingIndex] = vpn;
                vpn.pingTime = pingResult.pingTime;
                vpnList
                    .removeWhere((v) => v.ip == existingVPNs[minPingIndex].ip);
                vpnList.add(vpn);
              }
            }
          } else {
            // Add new country
            vpnMap.putIfAbsent(vpn.ip, () => [vpn]);
            vpn.pingTime = pingResult.pingTime;
            vpnList.add(vpn);
          }
        }

        // Increment processed count and calculate progress
        processedCount++;

        loadingProgress.value = processedCount / totalServers;

        print(
            "Progress: ${loadingProgress.value} :  ${pingResult.status.toString()}"); // Print progress for debugging
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
      final ping = Ping(ip.toString(), interval: 0.5);
      var stream = ping.stream;
      var pingValue = await stream.first;

      if (pingValue.summary == null && pingValue.error == null) {
        return PingResult(PingStatus.success,
            pingTime: pingValue.response!.time!.inMilliseconds);
      } else {
        return PingResult(PingStatus.failure);
      }
    } catch (e) {
      print('Ping test failed for IP: $ip, Error: $e');
      return PingResult(PingStatus.failure);
    }
  }
}
