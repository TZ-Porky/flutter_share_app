import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  File? selectedFile;
  List<String> discoveredServers = [];
  RawDatagramSocket? udpSocket;

  @override
  void initState() {
    super.initState();
    _listenForServers();
  }

  @override
  void dispose() {
    udpSocket?.close();
    super.dispose();
  }

  Future<void> _listenForServers() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 5001);
    udpSocket?.listen((event) {
      if (event == RawSocketEvent.read) {
        final datagram = udpSocket?.receive();
        if (datagram != null) {
          final message = String.fromCharCodes(datagram.data);
          final ip = datagram.address.address;
          if (message == 'FILE_SERVER_HERE' &&
              !discoveredServers.contains(ip)) {
            setState(() => discoveredServers.add(ip));
          }
        }
      }
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _sendFile(String hostIP) async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez d’abord sélectionner un fichier'),
        ),
      );
      return;
    }

    try {
      final socket = await Socket.connect(hostIP, 5000);
      final stream = selectedFile!.openRead();
      await stream.pipe(socket);
      await socket.flush();
      await socket.close();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('✅ Fichier envoyé à $hostIP')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Erreur d\'envoi à $hostIP : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Envoyer un fichier")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("📂 Choisir un fichier"),
            ),
            if (selectedFile != null) ...[
              const SizedBox(height: 10),
              Text(
                "📄 Fichier sélectionné : ${selectedFile!.path.split('/').last}",
              ),
            ],
            const SizedBox(height: 30),
            const Text(
              "📡 Appareils disponibles :",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  discoveredServers.isEmpty
                      ? const Text(
                        "Aucun serveur détecté...",
                        textAlign: TextAlign.center,
                      )
                      : ListView.builder(
                        itemCount: discoveredServers.length,
                        itemBuilder: (context, index) {
                          final ip = discoveredServers[index];
                          return ListTile(
                            title: Text("📶 $ip"),
                            trailing: ElevatedButton(
                              onPressed: () => _sendFile(ip),
                              child: const Text("Envoyer"),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
