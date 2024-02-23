import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vpn_basic_project/firebase_options.dart';
import 'package:vpn_basic_project/screens/home_screen.dart';
import 'package:vpn_basic_project/screens/location_screen.dart';
import 'package:vpn_basic_project/screens/network_location_screen.dart';

import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/startup_screen.dart';
import 'services/vpn_engine.dart';

//global object for accessing device screen size
late Size mq;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  //firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  };

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    FirebaseCrashlytics.instance
        .recordError(exception, stackTrace, fatal: true);

    return true;
  };
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Check if the app is moved to the background or terminated
    if (state == AppLifecycleState.detached) {
      // Stop the VPN when the app is moved to the background or terminated
      VpnEngine.stopVpn();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Binary Bridges VPN',
      home: StartupScreen(),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/home', page: () => HomeScreen()),
        GetPage(name: '/locationScreen', page: () => LocationScreen()),
        GetPage(
            name: '/networklocationScreen',
            page: () => NetworkLocationScreen()),
      ],

      themeMode: ThemeMode.system,
      darkTheme: ThemeData.dark().copyWith(
          appBarTheme: AppBarTheme(centerTitle: true),
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Sora')),
      theme: ThemeData.light().copyWith(
          appBarTheme: AppBarTheme(centerTitle: true),
          textTheme:
              Theme.of(context).textTheme.apply(fontFamily: 'Sora')), //theme

      debugShowCheckedModeBanner: false,
    );
  }
}
