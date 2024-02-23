import 'package:flutter/material.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final String? routes;

  DrawerItem(this.title, this.icon, [this.routes]);
}
