import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../helpers/pref.dart';
import '../main.dart';

import '../models/vpn_status.dart';
import '../services/vpn_engine.dart';
import '../widgets/count_down_timer.dart';
import '../widgets/home_card.dart';
import '../widgets/watch_ad_dialog.dart';
import 'location_screen.dart';
import 'network_test_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    // Add listener to update vpn state
    VpnEngine.vpnStageSnapshot().listen((event) {
      _controller.vpnState.value = event;
    });

    return Scaffold(
      appBar: _buildAppBar(context),
      bottomNavigationBar: Obx(() => _changeLocation(context)),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            StreamBuilder<VpnStatus?>(
              initialData: VpnStatus(),
              stream: VpnEngine.vpnStatusSnapshot(),
              builder: (context, snapshot) =>
                  _buildStatusContainer(context, snapshot.data),
            ),
            SizedBox(height: 144.0),
            Obx(() => _vpnButton(context)),
          ],
        ),
      ),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(64),
      child: AppBar(
        toolbarHeight: 60,
        leadingWidth: 80,
        leading: _buildLeadingIcon(context),
        title: Text(
          'Binary Bridges VPN',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).lightText, fontWeight: FontWeight.w600),
        ),
        actions: [
          _buildBrightnessIconButton(context),
          _buildInfoIconButton(),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).containerColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: Theme.of(context).containerShadow,
      ),
      child: IconButton(
        onPressed: () => {},
        icon: Icon(CupertinoIcons.square_grid_2x2),
      ),
    );
  }

  Widget _buildBrightnessIconButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (Config.hideAds) {
          Get.changeThemeMode(
              Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
          Pref.isDarkMode = !Pref.isDarkMode;
          return;
        }
        Get.dialog(WatchAdDialog(
          onComplete: () {
            AdHelper.showRewardedAd(onComplete: () {
              Get.changeThemeMode(
                  Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              Pref.isDarkMode = !Pref.isDarkMode;
            });
          },
        ));
      },
      icon: Icon(
        Icons.brightness_medium,
        size: 24,
      ),
    );
  }

  Widget _buildInfoIconButton() {
    return IconButton(
      padding: EdgeInsets.only(right: 8),
      onPressed: () => Get.to(() => NetworkTestScreen()),
      icon: Icon(
        CupertinoIcons.info,
        size: 24,
      ),
    );
  }

  Widget _buildStatusContainer(BuildContext context, VpnStatus? data) {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).containerColor,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: Theme.of(context).containerShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HomeCard(
            subtitle: _controller.vpnState.value == VpnEngine.vpnConnected
                ? '${data?.byteIn != null ? data!.byteIn : '0.00 kbps'}'
                : '0.00 kbps',
            title: 'DOWNLOAD',
            icon: Icons.arrow_downward_rounded,
          ),
          VerticalDivider(
            color: Colors.grey,
            thickness: 1.5,
          ),
          HomeCard(
            subtitle: _controller.vpnState.value == VpnEngine.vpnConnected
                ? '${data?.byteOut != null ? data!.byteOut : '0.00 kbps'}'
                : '0.00 kbps',
            title: 'UPLOAD',
            icon: Icons.arrow_upward_rounded,
          ),
        ],
      ),
    );
  }

  Widget _vpnButton(BuildContext context) {
    return Column(
      children: [
        Semantics(
          button: true,
          child: InkWell(
            onTap: () {
              _controller.connectToVpn();
            },
            borderRadius: BorderRadius.circular(360),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _controller.getButtonColor,
                boxShadow: Theme.of(context).containerShadow,
              ),
              child: Container(
                width: mq.height * .14,
                height: mq.height * .14,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _controller.getBorderColor,
                  ),
                  shape: BoxShape.circle,
                  color: _controller.getButtonColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _controller.getIcon,
                      size: 28,
                      color: _controller.getButtonTextIconColor,
                    ),
                    SizedBox(height: 4),
                    Text(
                      _controller.getButtonText,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: _controller.getButtonTextIconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin:
              EdgeInsets.only(top: mq.height * .016, bottom: mq.height * .005),
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            _controller.vpnState.value == VpnEngine.vpnDisconnected
                ? 'Not Connected'
                : _controller.vpnState.replaceAll('_', ' ').toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).lightText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Obx(() => CountDownTimer(
            startTimer: _controller.vpnState.value == VpnEngine.vpnConnected)),
      ],
    );
  }

  Widget _changeLocation(BuildContext context) {
    return SafeArea(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: () async {
            final result = await Get.to(() => LocationScreen());
            if (result != null && result is String) {
              // If a location is selected, update the UI
              _controller.vpn.update((val) {
                val!.countryShort = result.split(':')[0];
                val.countryLong = result.split(':')[1];
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              boxShadow: Theme.of(context).containerShadow,
              borderRadius: BorderRadius.circular(16.0),
              color: Theme.of(context).containerColor,
            ),
            margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            padding: EdgeInsets.symmetric(horizontal: mq.width * .04),
            height: 56,
            child: Row(
              children: [
                _controller.vpn.value.countryLong.isEmpty
                    ? Icon(CupertinoIcons.globe,
                        color: Theme.of(context).lightText, size: 28)
                    : Image.asset(
                        'assets/flags/${_controller.vpn.value.countryShort.toLowerCase()}.png',
                        height: 28,
                        width: 28,
                      ),
                SizedBox(width: 10),
                Text(
                  _controller.vpn.value.countryLong.isEmpty
                      ? 'Select Location'
                      : _controller.vpn.value.countryLong,
                  style: TextStyle(
                    color: Theme.of(context).lightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                Icon(Icons.keyboard_arrow_up_rounded,
                    color: Theme.of(context).lightText, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
