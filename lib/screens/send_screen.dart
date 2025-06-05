import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shareapp/services/file_service.dart';
import 'package:shareapp/services/nearby_service.dart';
import 'package:shareapp/services/shake_service.dart';
import 'package:shareapp/widgets/device_card.dart';

class SendScreen extends StatefulWidget {
  const SendScreen({super.key});

  @override
  _SendScreenState createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final NearbyService _nearbyService = NearbyService();
  final FileService _fileService = FileService();
  final ShakeService _shakeService = ShakeService();
  
  File? _selectedFile;
  List<Map<String, String>> _devices = [];
  String? _selectedDeviceId;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
    _shakeService.startListening(_onShake);
  }

  void _startDiscovery() async {
    await _nearbyService.startDiscovering();
    _nearbyService.onDeviceDiscovered.listen((device) {
      setState(() {
        if (!_devices.any((d) => d['id'] == device['id'])) {
          _devices.add(device);
        }
      });
    });
    _nearbyService.onDeviceLost.listen((deviceId) {
      setState(() {
        _devices.removeWhere((device) => device['id'] == deviceId);
        if (_selectedDeviceId == deviceId) {
          _selectedDeviceId = null;
        }
      });
    });
  }

  void _onShake() {
    if (_selectedFile != null && _selectedDeviceId != null) {
      _sendFile();
    }
  }

  Future<void> _pickFile() async {
    final file = await _fileService.pickFile();
    setState(() {
      _selectedFile = file;
    });
  }

  Future<void> _sendFile() async {
    if (_selectedFile == null || _selectedDeviceId == null) return;
    
    await _nearbyService.sendFile(_selectedDeviceId!, _selectedFile!.path);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fichier envoyé avec succès!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envoyer un fichier'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Sélectionner un fichier'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 20),
              Text('Fichier sélectionné: ${_selectedFile!.path.split('/').last}'),
              const SizedBox(height: 20),
              const Text('Appareils disponibles:'),
              ..._devices.map((device) => DeviceCard(
                deviceName: device['name']!,
                deviceId: device['id']!,
                isSelected: _selectedDeviceId == device['id'],
                onTap: () {
                  setState(() {
                    _selectedDeviceId = device['id'];
                  });
                },
              )),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendFile,
                child: const Text('Envoyer le fichier'),
              ),
              const SizedBox(height: 20),
              const Text('Ou secouez votre téléphone vers le destinataire pour envoyer'),
            ],
          ],
        ),
      ),
    );
  }
}