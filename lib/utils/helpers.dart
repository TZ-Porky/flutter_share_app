import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AppHelpers {
  static Future<bool> checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      if (Platform.isAndroid) ...[
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
      ],
      Permission.nearbyWifiDevices,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static String formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }
}