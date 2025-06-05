import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeToSendPage extends StatefulWidget {
  final List<String> discoveredServers;
  final Function(String ip) onSendFile;
  final bool hasFileSelected;

  const ShakeToSendPage({
    super.key,
    required this.discoveredServers,
    required this.onSendFile,
    required this.hasFileSelected,
  });

  @override
  State<ShakeToSendPage> createState() => _ShakeToSendPageState();
}

class _ShakeToSendPageState extends State<ShakeToSendPage> {
  double angle = 0;
  StreamSubscription? accelSub;
  StreamSubscription? gyroSub;

  final Map<String, double> serverAngles = {}; // IP -> angle
  final List<double> predefinedAngles = List.generate(8, (i) => i * 45.0);
  String? focusedServer;
  Timer? focusTimer;
  bool isFocused = false;
  double lastMagnitude = 0;

  @override
  void initState() {
    super.initState();
    _assignAnglesToServers();
    _startSensors();
  }

  void _assignAnglesToServers() {
    for (int i = 0; i < widget.discoveredServers.length && i < predefinedAngles.length; i++) {
      serverAngles[widget.discoveredServers[i]] = predefinedAngles[i];
    }
  }

  void _startSensors() {
    accelSub = accelerometerEvents.listen((event) {
      final ax = event.x;
      final ay = event.y;
      final az = event.z;

      final currentAngle = (atan2(ay, ax) * 180 / pi + 360) % 360;
      setState(() => angle = currentAngle);

      final magnitude = sqrt(ax * ax + ay * ay + az * az);
      if (magnitude - lastMagnitude > 12) {
        _onShake();
      }
      lastMagnitude = magnitude;

      _handleFocus(currentAngle);
    });
  }

  void _handleFocus(double currentAngle) {
    String? nearest;
    double minDiff = 45;
    for (var entry in serverAngles.entries) {
      double diff = (entry.value - currentAngle).abs();
      diff = diff > 180 ? 360 - diff : diff;
      if (diff < minDiff) {
        nearest = entry.key;
        minDiff = diff;
      }
    }

    if (nearest != null && nearest != focusedServer) {
      focusTimer?.cancel();
      isFocused = false;
      focusTimer = Timer(const Duration(seconds: 2), () {
        setState(() {
          focusedServer = nearest;
          isFocused = true;
        });
      });
    }
  }

  void _onShake() {
    if (!widget.hasFileSelected || !isFocused || focusedServer == null) return;
    widget.onSendFile(focusedServer!);
    setState(() {
      isFocused = false;
      focusedServer = null;
    });
  }

  @override
  void dispose() {
    accelSub?.cancel();
    gyroSub?.cancel();
    focusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Shake to Send")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.rotate(
              angle: angle * pi / 180,
              child: const Icon(Icons.navigation, size: 100, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text("Direction : ${angle.toStringAsFixed(1)}°"),
            const SizedBox(height: 10),
            if (focusedServer != null)
              Column(
                children: [
                  Text("🎯 Ciblé : $focusedServer", style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (isFocused)
                    const Text("🔒 Verrouillé - prêt à envoyer", style: TextStyle(color: Colors.green)),
                ],
              )
            else
              const Text("🔍 Aucune cible verrouillée"),
          ],
        ),
      ),
    );
  }
}
