import 'package:flutter/material.dart';
import 'package:shareapp/services/file_service.dart';
import 'package:shareapp/services/nearby_service.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  _ReceiveScreenState createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final NearbyService _nearbyService = NearbyService();
  final FileService _fileService = FileService();
  
  String? _receivedFilePath;

  @override
  void initState() {
    super.initState();
    _startAdvertising();
    _setupFileReceiver();
  }

  void _startAdvertising() async {
    await _nearbyService.startAdvertising('Receveur');
  }

  void _setupFileReceiver() {
    _nearbyService.onFileReceived.listen((filePath) {
      setState(() {
        _receivedFilePath = filePath;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fichier reçu: ${filePath.split('/').last}')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recevoir un fichier'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('En attente de fichiers...'),
            if (_receivedFilePath != null) ...[
              const SizedBox(height: 20),
              Text('Fichier reçu: ${_receivedFilePath!.split('/').last}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Ouvrir le fichier
                },
                child: const Text('Ouvrir le fichier'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}