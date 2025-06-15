class ServerInfo {
  final String deviceName;
  final String platform;
  final String appName;
  final int serverPort;
  final String version;

  ServerInfo({
    required this.deviceName,
    required this.platform,
    required this.appName,
    required this.serverPort,
    required this.version,
  });

  factory ServerInfo.fromJson(Map<String, dynamic> json) {
    return ServerInfo(
      deviceName: json['deviceName'] ?? 'Appareil inconnu',
      platform: json['platform'] ?? 'Inconnu',
      appName: json['appName'] ?? 'RapidBytes',
      version: json['version'] ?? '1.0.0',
      serverPort: json['serverPort'] ?? 8080,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'platform': platform,
      'appName': appName,
      'version': version,
      'serverPort': serverPort,
    };
  }

  @override
  String toString() {
    return 'ServerInfo(deviceName: $deviceName, platform: $platform, appName: $appName, version: $version)';
  }
}