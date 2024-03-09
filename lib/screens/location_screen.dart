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

class LocationScreen extends StatefulWidget {
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _controller = LocationController();

  final _adController = NativeAdController();

  final _homeController = Get.put(HomeController());

  @override
  void dispose() {
    _controller.stopProcessMethod(); // Stop VPN fetching process
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    VpnEngine.vpnStageSnapshot().listen((event) {
      _homeController.vpnState.value = event;
    });

    // Fetch VPN data if the list is empty
    if (_controller.vpnList.isEmpty) {
      _controller.getVpnData().then((_) {
        // Ensure the UI updates after fetching VPN data
        if (!_controller.isLoading.value) {
          _updateVpnListUI();
        }
      });
    }

    _adController.ad = AdHelper.loadNativeAd(adController: _adController);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => {
            Get.back(),
            if (_controller.isLoading.isTrue) _controller.stopProcessMethod()
          },
          icon: Icon(CupertinoIcons.back),
        ),
        title: Obx(
          () => Text(
            'VPN Locations (${_controller.vpnList.length})',
          ),
        ),
        actions: [
          Obx(() => !_controller.isLoading.value
              ? IconButton(
                  onPressed: () {
                    // Refresh VPN data when the refresh button is pressed
                    if (_homeController.vpnState.replaceAll('_', ' ') !=
                        VpnEngine.vpnDisconnected) {
                      VpnEngine.stopVpn();
                    }

                    _controller.getVpnData().then((_) {
                      _updateVpnListUI();
                    });
                  },
                  icon: Icon(CupertinoIcons.refresh),
                )
              : IconButton(
                  onPressed: () {
                    _controller.stopProcessMethod();
                  },
                  icon: Icon(Icons.stop_outlined),
                )),
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
            _buildVpnList(),
            Obx(
              () => _controller.isLoading.value
                  ? _loadingWidget(context, 'Loading VPNS', _controller)
                  : SizedBox.shrink(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVpnList() {
    return Obx(() => _controller.vpnList.isEmpty
        ? Center(
            child: Text(
              "No VPN locations available.",
              style: TextStyle(color: Colors.white),
            ),
          )
        : IgnorePointer(
            ignoring: _controller.isLoading.value,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _controller.vpnList.length,
              physics: _controller.isLoading.value
                  ? NeverScrollableScrollPhysics() // Disable scrolling when loading
                  : ClampingScrollPhysics(),
              padding: EdgeInsets.all(16),
              itemBuilder: (context, i) => VpnCard(vpn: _controller.vpnList[i]),
            ),
          ));
  }

  Widget _loadingWidget(BuildContext context, String loadingText, _controller) {
    return Center(
      child: Card(
        elevation: 2,
        color: Theme.of(context).canvasColor.withOpacity(0.9),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/lottie/loading.json',
                width: MediaQuery.of(context).size.width * 0.32,
                height: MediaQuery.of(context).size.width * 0.32,
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
        ),
      ),
    );
  }

  void _updateVpnListUI() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure UI updates after VPN data is fetched
      _controller.update();
    });
  }
}
