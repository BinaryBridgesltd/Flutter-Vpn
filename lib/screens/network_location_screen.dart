import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../apis/apis.dart';
import '../models/ip_details.dart';
import '../models/network_data.dart';
import '../widgets/network_card.dart';

class NetworkLocationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ipData = IPDetails.fromJson({}).obs;

    void refreshData() {
      ipData.value = IPDetails.fromJson({});
      APIs.getIPDetails(ipData: ipData);
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      refreshData();
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text('Network Location'),
      ),
      body: Obx(
        () => SingleChildScrollView(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NetworkCard(
                data: NetworkData(
                  title: 'IP Address',
                  subtitle: ipData.value.query,
                  icon: Icon(
                    CupertinoIcons.globe,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
              NetworkCard(
                data: NetworkData(
                  title: 'Internet Provider',
                  subtitle: ipData.value.isp,
                  icon: Icon(
                    Icons.business,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
              ),
              NetworkCard(
                data: NetworkData(
                  title: 'Location',
                  subtitle: ipData.value.country.isEmpty
                      ? 'Fetching ...'
                      : '${ipData.value.city}, ${ipData.value.regionName}, ${ipData.value.country}',
                  icon: Icon(
                    CupertinoIcons.location,
                    color: Colors.pink,
                    size: 24,
                  ),
                ),
              ),
              NetworkCard(
                data: NetworkData(
                  title: 'Pin-code',
                  subtitle: ipData.value.zip,
                  icon: Icon(
                    CupertinoIcons.location_solid,
                    color: Colors.cyan,
                    size: 24,
                  ),
                ),
              ),
              NetworkCard(
                data: NetworkData(
                  title: 'Timezone',
                  subtitle: ipData.value.timezone,
                  icon: Icon(
                    CupertinoIcons.time,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: refreshData,
        tooltip: 'Refresh',
        child: Icon(CupertinoIcons.refresh),
      ),
    );
  }
}
