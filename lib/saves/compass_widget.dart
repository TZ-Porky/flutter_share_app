import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class CompassWidget extends StatefulWidget {
  const CompassWidget({super.key});

  @override
  State<CompassWidget> createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  double angle = 0;

  @override
  void initState() {
    super.initState();
    accelerometerEvents.listen((AccelerometerEvent event) {
      final newAngle = atan2(event.y, event.x) * (180 / pi);
      setState(() {
        angle = (newAngle + 360) % 360;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.rotate(
          angle: angle * pi / 180,
          child: const Icon(Icons.navigation, size: 100, color: Colors.blue),
        ),
        Text("Angle : ${angle.toStringAsFixed(1)}°"),
      ],
    );
  }
}
