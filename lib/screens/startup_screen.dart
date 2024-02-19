import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/internet_status_controller.dart';
import '../helpers/ad_helper.dart';
import '../main.dart';
import 'home_screen.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  final InternetStatus _internetStatusController = Get.find<InternetStatus>();

  @override
  Widget build(BuildContext context) {
    //initializing media query (for getting device screen size)
    mq = MediaQuery.of(context).size;

    _internetStatusController.checkInternetConnection();

    return Scaffold(
      body: Obx(() {
        if (_internetStatusController.isInternetAvailable.value) {
          // If internet available, navigate to main screen

          Future.delayed(Duration(seconds: 2), () {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            AdHelper.precacheInterstitialAd();
            AdHelper.precacheNativeAd();

            Get.off(() => HomeScreen());
          });
          return Center(
            child: Stack(
              children: [
                //app logo
                Positioned(
                    left: mq.width * .3,
                    top: mq.height * .1,
                    width: mq.width * .4,
                    child: Image.asset('assets/icons/app_icon.png')),

                Center(child: CircularProgressIndicator()),

                //label
                Positioned(
                    bottom: mq.height * .16,
                    width: mq.width,
                    child: Text(
                      'Cross Safely with Binary Bridges',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).lightText,
                          letterSpacing: 1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ))
              ],
            ),
          );
        } else {
          // If internet not available, show message
          return Text("Internet not available");
        }
      }),
    );
  }
}
