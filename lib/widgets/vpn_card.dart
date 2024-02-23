import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../helpers/pref.dart';
import '../main.dart';
import '../models/vpn.dart';
import '../services/vpn_engine.dart';

class VpnCard extends StatelessWidget {
  final Vpn vpn;

  const VpnCard({super.key, required this.vpn});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Card(
        color: controller.vpn.value.ip == vpn.ip
            ? Color(0xFFF06A30)
            : Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.white,
        margin: EdgeInsets.symmetric(vertical: mq.height * .008),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () {
            controller.vpn.value = vpn;
            Pref.vpn = vpn;
            Get.back();

            // MyDialogs.success(msg: 'Connecting VPN Location...');

            if (controller.vpnState.value != VpnEngine.vpnConnected) {
              controller.connectToVpn();
            } else {
              VpnEngine.stopVpn();
              Future.delayed(
                  Duration(seconds: 1), () => controller.connectToVpn());
            }
          },
          borderRadius: BorderRadius.circular(15),
          child: ListTile(
            dense: true,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

            //flag
            leading: Container(
              padding: EdgeInsets.all(.6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black12),
              ),
              child: ClipOval(
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/flags/${vpn.countryShort.toLowerCase()}.png',
                  fit: BoxFit.fitHeight,
                  width: 32.0,
                  height: 32.0,
                ),
              ),
            ),

            //title
            title: Text(
              vpn.countryLong.toString(),
              style: TextStyle(
                  color: controller.vpn.value.ip == vpn.ip
                      ? Colors.white
                      : Theme.of(context).brightness == Brightness.dark
                          ? Colors.blue.shade400
                          : Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600),
            ),

            //trailing
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                    vpn.speed >= 9.99e+8
                        ? Icons.signal_cellular_alt_rounded
                        : vpn.speed <= 3.5e+8
                            ? Icons.signal_cellular_alt_1_bar_rounded
                            : Icons.signal_cellular_alt_2_bar_rounded,
                    color: controller.vpn.value.hostname != vpn.hostname
                        ? Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade400
                            : Colors.black
                        : Colors.white,
                    size: 24),
                VerticalDivider(
                  color: controller.vpn.value.ip != vpn.ip
                      ? Colors.grey.shade400
                      : Color(0xFFF38859),
                  endIndent: 4,
                  indent: 4,
                ),
                Icon(CupertinoIcons.forward,
                    color: controller.vpn.value.ip != vpn.ip
                        ? Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade400
                            : Colors.black
                        : Colors.white),
              ],
            ),
          ),
        ));
  }

  // String _formatBytes(int bytes, int decimals) {
  //   if (bytes <= 0) return "0 B";
  //   const suffixes = ['Bps', "Kbps", "Mbps", "Gbps", "Tbps"];
  //   var i = (log(bytes) / log(1024)).floor();
  //   return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  // }
}
