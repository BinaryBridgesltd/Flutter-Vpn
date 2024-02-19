import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/route_manager.dart';

import '../helpers/ad_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1500), () {
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      AdHelper.precacheInterstitialAd();
      AdHelper.precacheNativeAd();

      //navigate to home
      Get.off(() => HomeScreen());
      // Navigator.pushReplacement(
      //     context, MaterialPageRoute(builder: (_) => HomeScreen()));
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
              left: mq.width * .3,
              top: mq.height * .2,
              width: mq.width * .4,
              child: Image.asset('assets/icons/app_icon.png')),

          //label
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: Text(
                'Best VPN Provides Best Protection',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).lightText, letterSpacing: 1),
              ))
        ],
      ),
    );
  }
}
