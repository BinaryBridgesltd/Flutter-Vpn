import 'dart:convert';
import 'dart:developer';
import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/ip_details.dart';
import '../models/vpn.dart';

class APIs {
  static Future<List<Vpn>> getVPNServers() async {
    final Map<String, Vpn> vpnMapByCountry = {};
    try {
      final res = await get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      final csvString = res.body.split("#")[1].replaceAll('*', '');
      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);
      final header = list[0];
      for (int i = 1; i < list.length - 1; ++i) {
        Map<String, dynamic> tempJson = {};
        for (int j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }
        final vpn = Vpn.fromJson(tempJson);
        // Check if VPN connection is secure and stable
        if (vpn.speed >= 0.5e+8 &&
            vpn.totalUsers <= 5000 &&
            (vpn.ping <= 50 || vpn.ping != '-')) {
          // Check if VPN from this country already exists
          if (!vpnMapByCountry.containsKey(vpn.countryShort)) {
            vpnMapByCountry[vpn.countryShort] = vpn;
          } else {
            // If VPN from this country already exists, replace it only if current VPN is faster
            if (vpn.speed > vpnMapByCountry[vpn.countryShort]!.speed &&
                vpn.totalTraffic <
                    vpnMapByCountry[vpn.countryShort]!.totalTraffic) {
              vpnMapByCountry[vpn.countryShort] = vpn;
            }
          }
        }
      }
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetVPNServersE: $e');
    }
    // Convert the map values to a list
    List<Vpn> vpnList = vpnMapByCountry.values.toList();
    // Sort VPN servers by total users (descending order)
    vpnList.sort((a, b) => b.totalUsers.compareTo(a.totalUsers));
    // Optionally, you can save the sorted VPN list to preferences or state
    if (vpnList.isNotEmpty) Pref.vpnList = vpnList;
    return vpnList;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'));
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
}
