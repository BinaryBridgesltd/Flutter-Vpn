import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vpn_basic_project/controllers/internet_status_controller.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';

import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/startup_screen.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  //firebase initialization
  await Firebase.initializeApp();

  //initializing remote config
  await Config.initConfig();

  //initializing hive
  await Pref.initializeHive();

  //initializing ads
  await AdHelper.initAds();

  //for setting orientation to portrait only
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final InternetStatus internetStatusController = InternetStatus();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Binary Bridges VPN',
      home: GetBuilder<InternetStatus>(
        init: internetStatusController,
        builder: (context) {
          return StartupScreen();
        },
      ),
      getPages: [
        GetPage(name: '/splash', page: () => StartupScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],

      //theme
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.grey.shade100),
        scaffoldBackgroundColor: Colors.grey.shade100,
        textTheme: Theme.of(context)
            .textTheme
            .apply(fontFamily: 'Sora', fontSizeFactor: 0.9),
      ),

      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      //dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: Theme.of(context)
            .textTheme
            .apply(fontFamily: 'Sora', fontSizeFactor: 0.9),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 2.0,
        ),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText =>
      Pref.isDarkMode ? Colors.blue.shade400 : Colors.black87;
  Color get bottomNav => Pref.isDarkMode ? Colors.white12 : Colors.white;
  Color get containerColor => Pref.isDarkMode ? Colors.white12 : Colors.white;

  get containerShadow => Pref.isDarkMode
      ? null
      : [
          BoxShadow(
              spreadRadius: 0.5,
              offset: Offset(1, 1),
              blurRadius: 4,
              color: Colors.grey.shade300)
        ];
}
