class Vpn {
  late final String hostname;
  late final String ip;
  late final dynamic ping;
  late final dynamic speed;
  late final String countryLong;
  late final String countryShort;
  late final int numVpnSessions;
  late final String openVPNConfigDataBase64;

  Vpn(
      {required this.hostname,
      required this.ip,
      required this.ping,
      required this.speed,
      required this.countryLong,
      required this.countryShort,
      required this.numVpnSessions,
      required this.openVPNConfigDataBase64});

  Vpn.fromJson(Map<String, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping'] is int ? json['Ping'] : int.parse(json['Ping'] ?? '0');
    speed =
        json['Speed'] is int ? json['Speed'] : int.parse(json['Speed'] ?? '0');
    countryLong = json['CountryLong'] ?? '';
    countryShort = json['CountryShort'] ?? '';
    numVpnSessions = json['NumVpnSessions'] ?? 0;

    openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['HostName'] = hostname;
    data['IP'] = ip;
    data['Ping'] = ping;
    data['Speed'] = speed;
    data['CountryLong'] = countryLong;
    data['CountryShort'] = countryShort;
    data['NumVpnSessions'] = numVpnSessions;
    data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
    return data;
  }
}
