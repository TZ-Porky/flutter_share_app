import 'dart:io';
import 'package:flutter/material.dart';
import 'shake_to_send_page.dart'; // adapte le chemin selon l’emplacement réel du fichier

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  final List<_DiscoveredDevice> _devices = [];
  RawDatagramSocket? _socket;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _simulateDiscovery() {
    final simulated = _DiscoveredDevice(name: "TestDevice", ip: "192.168.1.99");
    final alreadyAdded = _devices.any((d) => d.ip == simulated.ip);
    if (!alreadyAdded) {
      setState(() => _devices.add(simulated));
    }
  }

  void _startListening() async {
    _socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      5001,
      reuseAddress: true,
    );

    _socket!.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket!.receive();
        if (datagram == null) return;

        final message = String.fromCharCodes(datagram.data);
        if (message.startsWith('SneakyFileServer|')) {
          final name = message.split('|')[1];
          final ip = datagram.address.address;

          final alreadyAdded = _devices.any((d) => d.ip == ip);
          if (!alreadyAdded) {
            setState(() {
              _devices.add(_DiscoveredDevice(name: name, ip: ip));
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _socket?.close();
    super.dispose();
  }

  void _selectDevice(_DiscoveredDevice selected) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ShakeToSendPage(
              discoveredServers: _devices.map((d) => d.ip).toList(),
              hasFileSelected: true, // à adapter dynamiquement si tu veux
              onSendFile: (ip) {
                // Appelle ton service d'envoi ici
                print("📤 Envoi du fichier à $ip");
                // sendFile(ip, selectedFile); <-- Quand tu l’auras
              },
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📡 Découverte d\'appareils')),
      body:
          _devices.isEmpty
              ? const Center(child: Text('Aucun appareil trouvé...'))
              : ListView.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];
                  return ListTile( // Suppression du Column car le FAB n'est plus ici
                    leading: const Icon(Icons.devices),
                    title: Text(device.name),
                    subtitle: Text(device.ip),
                    onTap: () => _selectDevice(device),
                  );
                },
              ),
      // Voici où le FloatingActionButton doit être placé : directement dans le Scaffold
      floatingActionButton: FloatingActionButton(
        onPressed: _simulateDiscovery,
        child: const Icon(Icons.bug_report),
      ),
      // Vous pouvez également spécifier sa position si vous le souhaitez
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _DiscoveredDevice {
  final String name;
  final String ip;

  _DiscoveredDevice({required this.name, required this.ip});
}