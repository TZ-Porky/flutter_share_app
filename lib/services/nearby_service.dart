import 'dart:async';
import 'package:nearby_connections/nearby_connections.dart';

class NearbyService {
  static const String serviceId = "com.example.shake_file_transfer";
  static const Strategy strategy = Strategy.P2P_STAR;

  final Nearby _nearby = Nearby();

  // Streams pour notifier les changements dans les appareils découverts et les fichiers reçus
  final StreamController<Map<String, String>> _onDeviceDiscoveredController = StreamController.broadcast();
  Stream<Map<String, String>> get onDeviceDiscovered => _onDeviceDiscoveredController.stream;

  final StreamController<String> _onDeviceLostController = StreamController.broadcast();
  Stream<String> get onDeviceLost => _onDeviceLostController.stream;

  final StreamController<String> _onFileReceivedController = StreamController.broadcast();
  Stream<String> get onFileReceived => _onFileReceivedController.stream;

  final StreamController<String> _onConnectionInitiatedController = StreamController.broadcast();
  Stream<String> get onConnectionInitiated => _onConnectionInitiatedController.stream;

  final StreamController<Map<String, dynamic>> _onConnectionResultController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get onConnectionResult => _onConnectionResultController.stream;

  final StreamController<String> _onDisconnectedController = StreamController.broadcast();
  Stream<String> get onDisconnected => _onDisconnectedController.stream;

  Future<bool> startAdvertising(String deviceName) async {
    return await _nearby.startAdvertising(
      deviceName,
      strategy,
      onConnectionInitiated: (id, info) {
        _onConnectionInitiatedController.add(id);
        // Accepter automatiquement la connexion entrante
        _nearby.acceptConnection(
          id,
          onPayLoadRecieved: (endpointId, payload) async {
            if (payload.type == PayloadType.FILE) {
              // Correction ici: Accès direct au chemin du fichier via payload.filePath
              final filePath = payload.filePath; 
              if (filePath != null) {
                _onFileReceivedController.add(filePath);
              }
            }
          },
        );
      },
      onConnectionResult: (id, status) {
        _onConnectionResultController.add({'id': id, 'status': status.name});
      },
      onDisconnected: (id) {
        _onDisconnectedController.add(id);
      },
    );
  }

  Future<bool> startDiscovering() async {
    return await _nearby.startDiscovery(
      serviceId,
      strategy,
      onEndpointFound: (id, name, serviceId) {
        _onDeviceDiscoveredController.add({'id': id, 'name': name});
        // Tenter de se connecter à l'appareil trouvé
        _nearby.requestConnection(
          name, // Le nom de l'appareil
          id, // L'ID de l'appareil
          onConnectionInitiated: (id, info) {
            _onConnectionInitiatedController.add(id);
            // Accepter la connexion de l'autre côté (SendScreen n'aura pas à le faire si ReceiveScreen accepte auto)
          },
          onConnectionResult: (id, status) {
            _onConnectionResultController.add({'id': id, 'status': status.name});
          },
          onDisconnected: (id) {
            _onDisconnectedController.add(id);
          },
        );
      },
      onEndpointLost: (id) {
        _onDeviceLostController.add(id!);
      },
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

  void dispose() {
    _onDeviceDiscoveredController.close();
    _onDeviceLostController.close();
    _onFileReceivedController.close();
    _onConnectionInitiatedController.close();
    _onConnectionResultController.close();
    _onDisconnectedController.close();
  }
}