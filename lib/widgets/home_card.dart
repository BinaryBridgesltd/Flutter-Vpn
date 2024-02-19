import 'package:flutter/material.dart';

import '../helpers/pref.dart';
import '../main.dart';

//card to represent status in home screen
class HomeCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;

  const HomeCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8.0),
        width: mq.width * .40,
        height: mq.height * .14,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                        color: Theme.of(context).lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  Spacer(),
                  Container(
                    width: 28.0,
                    height: 28.0,
                    decoration: BoxDecoration(
                        color: Pref.isDarkMode
                            ? Colors.white12
                            : Color(0xFFFEF1EB),
                        borderRadius: BorderRadius.circular(4.0)),
                    child: Icon(
                      icon,
                      size: 20.0,
                      color: Color(0xFFFF06A30),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 2.0),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Pref.isDarkMode
                        ? Colors.amber.shade400
                        : Colors.black)),
            SizedBox(height: 2.0),
          ],
        ));
  }
}
