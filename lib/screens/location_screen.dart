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

import '../services/vpn_engine.dart';
import '../widgets/vpn_card.dart';

class LocationScreen extends StatelessWidget {
  final _controller = LocationController();
  final _adController = NativeAdController();
  final _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _homeController.vpnState.value = event;
    });

    // Fetch VPN data if the list is empty
    if (_controller.vpnList.isEmpty) {
      _controller.getVpnData();
    }

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(CupertinoIcons.back),
        ),
        title: Obx(
          () => Text(
            'VPN Locations (${_controller.vpnList.length})',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Refresh VPN data when the refresh button is pressed
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
      body: SafeArea(
        child: Stack(
          children: [
            // Show ModalBarrier to block interaction when loading
            ModalBarrier(
              color: Colors.transparent,
              dismissible: false,
            ),
            Column(
              children: [
                Expanded(
                  flex: 8,
                  child: Obx(() => ListView.builder(
                        shrinkWrap: true,
                        itemCount: _controller.vpnList.length,
                        physics: _controller.isLoading.value
                            ? NeverScrollableScrollPhysics() // Disable scrolling when loading
                            : ClampingScrollPhysics(),
                        padding: EdgeInsets.all(16),
                        itemBuilder: (context, i) =>
                            VpnCard(vpn: _controller.vpnList[i]),
                      )),
                ),
              ],
            ),
            Positioned.fill(
              child: Obx(() {
                // Check if isLoading is true to show the loading widget
                if (_controller.isLoading.value) {
                  return _loadingWidget(context, 'Loading VPNS', _controller);
                } else {
                  return SizedBox.shrink();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _loadingWidget(BuildContext context, String loadingText, _controller) {
  return Container(
    color: Theme.of(context).canvasColor.withOpacity(0.9),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lottie/loading.json',
          width: MediaQuery.of(context).size.width * 0.32,
          filterQuality: FilterQuality.high,
          frameRate: FrameRate.composition,
          fit: BoxFit.scaleDown,
        ),
        Obx(
          () => Text(
            '$loadingText... ${(_controller.loadingProgress.value * 100).toStringAsFixed(2)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.blue.shade400
                  : Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
