import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

class ShakeService {
  static const double shakeThreshold = 2.7;
  static const int shakeSlopTimeMs = 500;
  static const int shakeCountResetTimeMs = 3000;

  DateTime _lastShakeTime = DateTime.now();
  int _shakeCount = 0;

  void startListening(Function onShake) {
    accelerometerEvents.listen((AccelerometerEvent event) {
      final double acceleration = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z);
      
      final DateTime now = DateTime.now();
      if (acceleration > shakeThreshold) {
        
        if (now.difference(_lastShakeTime).inMilliseconds > shakeSlopTimeMs) {
          _shakeCount++;
        }
        
        _lastShakeTime = now;
        
        if (_shakeCount >= 2) {
          _shakeCount = 0;
          onShake();
        }
      }
      
      // Reset shake count if no shakes detected for a while
      if (now.difference(_lastShakeTime).inMilliseconds > shakeCountResetTimeMs) {
        _shakeCount = 0;
      }
    });
  }
}