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
  static Future<List<Vpn>> getVPNServers() async {
    final List<Vpn> vpnList = Pref.vpnList;
    final Map<String, List<Vpn>> vpnMap = {};

    try {
      final res =
          await http.get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      final csvString = res.body.split("#")[1].replaceAll('*', '');

      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];

      final pingFutures = <Future>[];

      for (int i = 1; i < list.length - 1; ++i) {
        Map<String, dynamic> tempJson = {};

        for (int j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }

        Vpn vpn = Vpn.fromJson(tempJson);

        // Add ping test future to the list
        pingFutures.add(performPingTest(vpn.ip).then((pingResult) {
          // If ping successful, add VPN server to map
          if (pingResult.status == PingStatus.success &&
              pingResult.pingTime <= 200) {
            if (!vpnMap.containsKey(vpn.countryLong)) {
              vpnMap[vpn.countryLong] = [vpn];
            } else {
              vpnMap[vpn.countryLong]!.add(vpn);
            }
          }
        }));
      }

      // Wait for all ping tests to complete
      await Future.wait(pingFutures);

      // Update existing vpnList with new servers and replace existing ones if needed
      vpnMap.forEach((country, vpnServers) {
        if (vpnServers.isNotEmpty) {
          vpnServers.sort((a, b) => a.countryLong.compareTo(b.countryLong));
          final existingIndex =
              vpnList.indexWhere((element) => element.countryLong == country);
          if (existingIndex != -1) {
            vpnList[existingIndex] = vpnServers.first;
          } else {
            vpnList.add(vpnServers.first);
          }
        }
      });

      // Update Pref.vpnList
      Pref.vpnList = vpnList;
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetVPNServersE: $e');
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

  static Future<PingResult> performPingTest(String ip) async {
    try {
      final ping = Ping(ip.toString());
      var stream = ping.stream;

      var pingValue = await stream.first;

      if (pingValue.summary == null && pingValue.error == null) {
        // Ping was successful
        return PingResult(PingStatus.success,
            pingTime: pingValue.response!.time!.inMilliseconds);
      } else {
        // Ping failed
        return PingResult(PingStatus.failure);
      }
    } catch (e) {
      print('Ping test failed for IP: $ip, Error: $e');
      return PingResult(PingStatus.failure);
    }
  }
}
