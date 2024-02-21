import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vpn_basic_project/main.dart';
import '../controllers/drawer_controller.dart';
import '../helpers/ad_helper.dart';
import '../helpers/config.dart';
import '../helpers/pref.dart';
import '../widgets/watch_ad_dialog.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  final LeftDrawerController _drawerController =
      Get.put(LeftDrawerController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(context),
      drawer: _buildDrawer(context),
      body: GetBuilder<LeftDrawerController>(builder: (controller) {
        return controller.currentScreen;
      }),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(mq.width * 0.8, 64.0),
      child: AppBar(
        toolbarHeight: 60,
        leadingWidth: 80,
        automaticallyImplyLeading: false,
        leading: _buildLeadingIcon(context),
        title: Text(
          'Binary Bridges VPN',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.blue.shade400
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          _buildBrightnessIconButton(context),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.shade300,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                )
              ],
      ),
      child: IconButton(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        icon: Icon(CupertinoIcons.square_grid_2x2),
      ),
    );
  }

  Widget _buildBrightnessIconButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (Config.hideAds) {
          _toggleTheme();
          return;
        }
        Get.dialog(
          WatchAdDialog(
            onComplete: () {
              AdHelper.showRewardedAd(onComplete: _toggleTheme);
            },
          ),
        );
      },
      icon: Icon(
        Icons.brightness_medium,
        size: 24,
      ),
    );
  }

  void _toggleTheme() {
    Get.changeThemeMode(Pref.isDarkMode ? ThemeMode.light : ThemeMode.dark);
    Pref.isDarkMode = !Pref.isDarkMode;
  }

  Widget _buildDrawer(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    return Material(
      child: Drawer(
        clipBehavior: Clip.antiAlias,
        width: mq.width * 0.7,
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.white10
            : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              child: Icon(
                Icons.shield,
                size: 96.0,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _drawerController.drawerItems.length,
                itemBuilder: (context, index) {
                  return _buildDrawerItem(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, int index) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        minVerticalPadding: 4.0,
        dense: true,
        tileColor: _drawerController.selectedDrawerIndex.value == index
            ? Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.amber
            : Colors.transparent,
        contentPadding: EdgeInsets.only(left: 12.0, right: 12.0),
        leading: Icon(
          _drawerController.drawerItems[index].icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? _drawerController.selectedDrawerIndex.value == index
                  ? Colors.amber
                  : Colors.blue.shade400
              : Colors.black,
        ),
        title: Text(
          _drawerController.drawerItems[index].title,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? _drawerController.selectedDrawerIndex.value == index
                    ? Colors.amber
                    : Colors.blue.shade400
                : Colors.black,
          ),
        ),
        onTap: () => _drawerController.onDrawerItemSelected(index),
      ),
    );
  }
}
