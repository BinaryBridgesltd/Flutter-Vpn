import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';
import 'package:vpn_basic_project/screens/main_screen.dart';

import '../helpers/ad_helper.dart';
import '../main.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2500), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();

      //navigate to home
      Get.off(() => MainScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          //app logo
          Positioned(
              top: mq.height * 0.20,
              width: mq.width,
              child: Column(
                children: [
                  Image.asset('assets/icons/app_icon.png'),
                  SizedBox(
                    height: 28.0,
                  ),
                  Text(
                    'Binary Bridges VPN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.blue.shade400
                            : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 24.0,
                        letterSpacing: 1),
                  )
                ],
              )),

          //label
          Positioned(
              bottom: mq.height * 0.3,
              width: mq.width,
              child: Text(
                'Best VPN Provides Best Protection',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.blue.shade400
                        : Colors.black,
                    letterSpacing: 1),
              )),

          Positioned(
              bottom: mq.height * 0.15,
              width: mq.width,
              child: Center(
                  child: CircularProgressIndicator(
                strokeWidth: 8.0,
              ))),
        ],
      ),
    );
  }
}
