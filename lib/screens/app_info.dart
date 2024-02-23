import 'package:flutter/material.dart';

class AppInfoScreen extends StatelessWidget {
  final String appName;
  final String version;
  final String buildNumber;
  final String releaseDate;
  final String description;

  AppInfoScreen({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoItem(context, 'App Name', appName),
            _buildInfoItem(context, 'Version', version),
            _buildInfoItem(context, 'Build Number', buildNumber),
            _buildInfoItem(context, 'Release Date', releaseDate),
            _buildInfoItem(context, 'Description', description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value,
      {TextAlign textAlign = TextAlign.start,
      TextDirection textDirection = TextDirection.ltr}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white12
            : Colors.grey[200],
      ),
      padding: EdgeInsets.all(4.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        minVerticalPadding: 10,
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            height: 2.0,
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        subtitle: Text(
          value,
          textAlign: textAlign,
          textDirection: textDirection,
          style: TextStyle(
            fontSize: 12.0,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[300]
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
