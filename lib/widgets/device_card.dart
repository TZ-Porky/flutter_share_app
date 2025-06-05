import 'package:flutter/material.dart';

class DeviceCard extends StatelessWidget {
  final String deviceName;
  final String deviceId;
  final bool isSelected;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.deviceName,
    required this.deviceId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue[100] : null,
      child: ListTile(
        title: Text(deviceName),
        subtitle: Text(deviceId),
        trailing: isSelected 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.radio_button_unchecked),
        onTap: onTap,
      ),
    );
  }
}