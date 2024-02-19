import 'package:connectivity/connectivity.dart';
import 'package:get/get.dart';

class InternetStatus extends GetxController {
  var isInternetAvailable = false.obs;

  void checkInternetConnection() async {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        isInternetAvailable.value = false;
      } else {
        isInternetAvailable.value = true;
      }
    });
  }
}
