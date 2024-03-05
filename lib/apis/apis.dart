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

      for (int i = 1; i < list.length; ++i) {
        if (list[i].length != header.length) {
          continue; // Skip rows with different lengths from the header
        }

        Map<String, dynamic> tempJson =
            Map.fromIterables(header.map((e) => e.toString()), list[i]);
        Vpn vpn = Vpn.fromJson(tempJson);

        var pingResult = await _performPingTest(vpn.ip);
        if (pingResult.status == PingStatus.success &&
            pingResult.pingTime <= 200) {
          vpnMap.putIfAbsent(vpn.countryLong, () => []).add(vpn);

          double progress = (i + 1) / list.length;

          progressCallback(progress);
        }
      }

      vpnMap.forEach((country, vpnServers) {
        if (vpnServers.isNotEmpty) {
          vpnServers.sort((a, b) => a.countryLong.compareTo(b.countryLong));
          vpnList.add(vpnServers.first);
        }
      });

      // Update Pref.vpnList
      Pref.vpnList = vpnList;
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
        return PingResult(PingStatus.failure);
      }
    } catch (e) {
      print('Ping test failed for IP: $ip, Error: $e');
      return PingResult(PingStatus.failure);
    }
  }
}
