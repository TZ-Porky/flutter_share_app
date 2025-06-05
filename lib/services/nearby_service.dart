import 'package:nearby_connections/nearby_connections.dart';

class NearbyService {
  static const String serviceId = "com.example.shake_file_transfer";
  static const Strategy strategy = Strategy.P2P_STAR;

  final Nearby _nearby = Nearby();

  Future<bool> startAdvertising(String deviceName) async {
    return await _nearby.startAdvertising(
      deviceName,
      strategy,
      onConnectionInitiated: (id, info) {},
      onConnectionResult: (id, status) {},
      onDisconnected: (id) {},
    );
  }

  Future<bool> startDiscovering() async {
    return await _nearby.startDiscovery(
      serviceId,
      strategy,
      onEndpointFound: (id, name, serviceId) {},
      onEndpointLost: (id) {},
    );
  }

  Future<void> stopAdvertising() async {
    await _nearby.stopAdvertising();
  }

  Future<void> stopDiscovery() async {
    await _nearby.stopDiscovery();
  }

  Future<void> sendFile(String endpointId, String filePath) async {
    await _nearby.sendFilePayload(endpointId, filePath);
  }
}