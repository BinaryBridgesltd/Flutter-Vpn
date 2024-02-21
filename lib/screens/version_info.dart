import 'package:flutter/material.dart';

class VersionInfoScreen extends StatelessWidget {
  final String appName;
  final String version;
  final String buildNumber;
  final String releaseDate;
  final String description;

  VersionInfoScreen({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.releaseDate,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Version Information'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Expanded(
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
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          SizedBox(height: 4.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
            ),
            padding: EdgeInsets.all(12.0),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
