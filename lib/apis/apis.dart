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

class APIs {
  static Future<List<Vpn>> getVPNServers(
      {required Function(double) progressCallback}) async {
    final List<Vpn> vpnList = [];
    final Map<String, List<Vpn>> vpnMap = {};

    try {
      final res =
          await http.get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      final csvString = res.body.split("#")[1].replaceAll('*', '');

      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];
      final totalServers = list.length - 1; // Subtract header

      int processedCount = 0;

      await Future.wait(list.skip(1).map((row) async {
        if (row.length != header.length) {
          return; // Skip rows with different lengths from the header
        }

        Map<String, dynamic> tempJson =
            Map.fromIterables(header.map((e) => e.toString()), row);
        Vpn vpn = Vpn.fromJson(tempJson);

        var pingResult = await _performPingTest(vpn.ip);
        if (pingResult.status == PingStatus.success &&
            pingResult.pingTime <= 200) {
          if (Pref.vpnList.any((existingVpn) => existingVpn.ip == vpn.ip)) {
            // Update pingTime in existing VPN object
            var existingVpn = Pref.vpnList.firstWhere((v) => v.ip == vpn.ip);
            existingVpn.pingTime = pingResult.pingTime;
          } else {
            // Add new VPN server
            vpnMap.putIfAbsent(vpn.ip, () => []).add(vpn);
            vpn.pingTime = pingResult.pingTime;
            vpnList.add(vpn);
          }
        }

        // Increment processed count and calculate progress
        processedCount++;
        double progress = processedCount / totalServers;
        progressCallback(progress);
      }));

      // Add existing VPN servers from Pref.vpnList if not already added
      for (var existingVpn in Pref.vpnList) {
        if (!vpnList.any((vpn) => vpn.ip == existingVpn.ip)) {
          vpnList.add(existingVpn);
        }
      }

      // Sort and update Pref.vpnList
      vpnList.sort((a, b) => a.countryLong.compareTo(b.countryLong));
      Pref.vpnList = vpnList.map((vpn) => vpn.copyWith()).toList();
    } catch (e) {
      // Handle errors appropriately
      print('Error fetching VPN servers: $e');
      throw e; // Rethrow the exception or handle it gracefully
    }

    return vpnList;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json/'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        log(data.toString());
        ipData.value = IPDetails.fromJson(data);
      } else {
        throw Exception('Failed to load IP details: ${res.statusCode}');
      }
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetIPDetailsE: $e');
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
