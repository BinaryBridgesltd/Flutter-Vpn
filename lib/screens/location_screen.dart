import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:vpn_basic_project/controllers/home_controller.dart';
import 'package:vpn_basic_project/helpers/config.dart';

import '../controllers/location_controller.dart';
import '../controllers/native_ad_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/pref.dart';

import '../services/vpn_engine.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({Key? key}) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _controller = LocationController();
  final _adController = NativeAdController();
  final _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _homeController.vpnState.value = event;
    });

    if (_controller.vpnList.isEmpty) {
      _controller.getVpnData();
    }

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(CupertinoIcons.back),
          ),
          title: Text(
            'VPN Locations (${_controller.vpnList.length})',
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (_homeController.vpnState.replaceAll('_', ' ') !=
                    VpnEngine.vpnDisconnected) {
                  VpnEngine.stopVpn();
                }
                _controller.getVpnData();
              },
              icon: Icon(CupertinoIcons.refresh),
            ),
          ],
        ),
        bottomNavigationBar: Config.hideAds
            ? null
            : _adController.ad != null && _adController.adLoaded.isTrue
                ? SafeArea(
                    child: SizedBox(
                      height: 85,
                      child: AdWidget(ad: _adController.ad!),
                    ),
                  )
                : null,
        body: _controller.isLoading.value
            ? _loadingWidget(context, "Loading Vpns")
            : _controller.vpnList.isEmpty
                ? _noVPNFound()
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: _controller.vpnList.length,
                          physics: ClampingScrollPhysics(),
                          padding: EdgeInsets.all(16),
                          itemBuilder: (context, i) =>
                              VpnCard(vpn: _controller.vpnList[i]),
                        ),
                        _controller.isDataFetching.value
                            ? Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: _loadingWidget(context, 'Loading More'),
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _loadingWidget(BuildContext context, String loadingText) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/loading.json',
              width: MediaQuery.of(context).size.width * 0.5,
              filterQuality: FilterQuality.high,
              frameRate: FrameRate.composition,
            ),
            SizedBox(height: 10),
            Obx(() => Text(
                  '$loadingText... ${(_controller.loadingProgress.value * 100).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade400
                        : Colors.black,
                  ),
                )),
          ],
        ),
      );

  Widget _noVPNFound() => Center(
        child: Text(
          'VPNs Not Found! 😔',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      );
}
