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
  String? fileName;
  int? fileSize;
  String? receiverIP;

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final file = File(path);
      final stat = await file.stat();

      setState(() {
        selectedFile = file;
        fileName = result.files.single.name;
        fileSize = stat.size;
      });
    }
  }

  Future<void> sendFile(String hostIP) async {
    if (selectedFile == null) return;

    try {
      final socket = await Socket.connect(hostIP, 5000);
      final stream = selectedFile!.openRead();
      await stream.pipe(socket);
      await socket.flush();
      await socket.close();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Fichier envoyé avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Erreur d\'envoi : $e')));
    }
  }

  Widget buildFilePreview() {
    if (selectedFile == null) return const SizedBox.shrink();

    final isImage =
        fileName!.toLowerCase().endsWith('.jpg') ||
        fileName!.toLowerCase().endsWith('.jpeg') ||
        fileName!.toLowerCase().endsWith('.png');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nom du fichier : $fileName'),
        Text('Taille : ${(fileSize! / 1024).toStringAsFixed(2)} KB'),
        const SizedBox(height: 10),
        if (isImage)
          Image.file(selectedFile!, width: 200, height: 200, fit: BoxFit.cover),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Envoyer un fichier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: pickFile,
              icon: const Icon(Icons.attach_file),
              label: const Text('Choisir un fichier'),
            ),
            const SizedBox(height: 20),
            buildFilePreview(),
            const SizedBox(height: 30),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Adresse IP du récepteur',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  receiverIP = value.trim();
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed:
                  receiverIP != null && selectedFile != null
                      ? () => sendFile(receiverIP!)
                      : null,
              icon: const Icon(Icons.send),
              label: const Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }
}
