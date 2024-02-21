import 'package:flutter/material.dart';

import '../main.dart';
import '../models/network_data.dart';

class NetworkCard extends StatelessWidget {
  final NetworkData data;

  const NetworkCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.white,
        margin: EdgeInsets.symmetric(vertical: mq.height * .01),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          dense: true,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          //flag
          leading: Icon(data.icon.icon,
              color: data.icon.color, size: data.icon.size ?? 28),

          //title
          title: Text(data.title),

          //subtitle
          subtitle: Text(data.subtitle),
        ));
  }
}
