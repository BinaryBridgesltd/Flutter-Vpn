import 'package:get/get.dart';

import '../apis/apis.dart';
import '../helpers/pref.dart';
import '../models/vpn.dart';

class LocationController extends GetxController {
  List<Vpn> vpnList = Pref.vpnList;

  final RxBool isLoading = false.obs;

  final RxDouble loadingProgress = 0.0.obs;

  Future<void> getVpnData() async {
    isLoading(true);
    vpnList.clear();
    loadingProgress.value = 0.0;
    vpnList = await APIs.getVPNServers(progressCallback: (progress) {
      loadingProgress.value = progress;
    });
    // Update your vpnList here
    isLoading(false);
  }
}
