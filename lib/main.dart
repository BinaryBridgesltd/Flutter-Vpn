import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/home_screen.dart';
import 'screens/location_screen.dart';
import 'screens/network_location_screen.dart';
import 'screens/startup_screen.dart';

late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await Config.initConfig();
  await Pref.initializeHive();
  await AdHelper.initAds();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          Brightness.dark == true ? Colors.white12 : Colors.white,
      statusBarBrightness:
          Pref.isDarkMode ? Brightness.dark : Brightness.light));

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Sora')),
      debugShowCheckedModeBanner: false,
    );
  }
}
