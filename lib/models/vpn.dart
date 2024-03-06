class Vpn {
  late final String hostname;
  late final String ip;
  late final dynamic ping;
  late final dynamic speed;
  late final String countryLong;
  late final String countryShort;
  late final int numVpnSessions;
  late final int totalUsers;
  late final int totalTraffic;
  late int pingTime;
  late final String openVPNConfigDataBase64;
  Vpn(
      {required this.hostname,
      required this.ip,
      required this.ping,
      required this.speed,
      required this.countryLong,
      required this.countryShort,
      required this.numVpnSessions,
      required this.totalUsers,
      required this.totalTraffic,
      required this.openVPNConfigDataBase64,
      required this.pingTime});
  Vpn.fromJson(Map<dynamic, dynamic> json) {
    hostname = json['HostName'] ?? '';
    ip = json['IP'] ?? '';
    ping = json['Ping'] is int ? json['Ping'] : 0;
    speed = json['Speed'] is int ? json['Speed'] : 0;
    countryLong = json['CountryLong'] ?? '';
    countryShort = json['CountryShort'] ?? '';
    numVpnSessions = json['NumVpnSessions'] ?? 0;
    totalUsers = json['TotalUsers'] ?? 0;
    totalTraffic = json['TotalTraffic'] ?? 0;
    openVPNConfigDataBase64 = json['OpenVPN_ConfigData_Base64'] ?? '';
    pingTime = json['PingTime'] ?? -1; // Initialize pingTime as -1 initially
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
    data['TotalUsers'] = totalUsers;
    data['TotalTraffic'] = totalTraffic;
    data['OpenVPN_ConfigData_Base64'] = openVPNConfigDataBase64;
    data['PingTime'] = pingTime;
    return data;
  }

  Vpn copyWith({int? pingTime}) {
    return Vpn(
      hostname: this.hostname,
      ip: this.ip,
      ping: this.ping,
      speed: this.speed,
      countryLong: this.countryLong,
      countryShort: this.countryShort,
      numVpnSessions: this.numVpnSessions,
      totalUsers: this.totalUsers,
      totalTraffic: this.totalTraffic,
      openVPNConfigDataBase64: this.openVPNConfigDataBase64,
      pingTime: pingTime ??
          this.pingTime, // Use the provided pingTime or keep the existing one
    );
  }

  equals(Vpn vpn) {}
}
