import 'dart:convert';
import 'dart:developer';

import 'package:csv/csv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../helpers/my_dialogs.dart';
import '../helpers/pref.dart';
import '../models/ip_details.dart';
import '../models/vpn.dart';

class APIs {
  static Future<List<Vpn>> getVPNServers({int count = 10}) async {
    final Map<String, Vpn> countryToHighestSpeedVpn = {};

    try {
      final res =
          await http.get(Uri.parse('http://www.vpngate.net/api/iphone/'));
      final csvString = res.body.split("#")[1].replaceAll('*', '');

      List<List<dynamic>> list = const CsvToListConverter().convert(csvString);

      final header = list[0];

      for (int i = 1; i < list.length - 1; ++i) {
        Map<String, dynamic> tempJson = {};

        for (int j = 0; j < header.length; ++j) {
          tempJson.addAll({header[j].toString(): list[i][j]});
        }

        final vpn = Vpn.fromJson(tempJson);

        // Group VPNs by country and select the one with the highest speed
        if (!countryToHighestSpeedVpn.containsKey(vpn.countryLong)) {
          countryToHighestSpeedVpn[vpn.countryLong] = vpn;
        } else {
          if (vpn.speed > countryToHighestSpeedVpn[vpn.countryLong]!.speed) {
            countryToHighestSpeedVpn[vpn.countryLong] = vpn;
          }
        }
      }
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetVPNServersE: $e');
    }

    // Convert the map of country to highest speed VPN into a list
    final selectedVPNs = countryToHighestSpeedVpn.values.toList();

    // Sort selected VPNs by speed
    selectedVPNs.sort((a, b) => b.speed.compareTo(a.speed));

    // Take only the required number of VPNs with highest speed
    final topVPNs = selectedVPNs.take(count).toList();

    if (topVPNs.isNotEmpty) Pref.vpnList = topVPNs;

    return topVPNs;
  }

  static Future<void> getIPDetails({required Rx<IPDetails> ipData}) async {
    try {
      final res = await get(Uri.parse('http://ip-api.com/json/'));
      final data = jsonDecode(res.body);
      log(data.toString());
      ipData.value = IPDetails.fromJson(data);
    } catch (e) {
      MyDialogs.error(msg: e.toString());
      log('\ngetIPDetailsE: $e');
    }
  }
}

// Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36

// For Understanding Purpose

//*** CSV Data ***
// Name,    Country,  Ping
// Test1,   JP,       12
// Test2,   US,       112
// Test3,   IN,       7

//*** List Data ***
// [ [Name, Country, Ping], [Test1, JP, 12], [Test2, US, 112], [Test3, IN, 7] ]

//*** Json Data ***
// {"Name": "Test1", "Country": "JP", "Ping": 12}

