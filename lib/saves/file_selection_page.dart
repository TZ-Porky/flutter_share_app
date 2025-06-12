import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'discovery_page.dart'; // Assure-toi que ce fichier existe et accepte un paramètre `file`

class FileSelectionPage extends StatefulWidget {
  const FileSelectionPage({Key? key}) : super(key: key);

  @override
  State<FileSelectionPage> createState() => _FileSelectionPageState();
}

class _FileSelectionPageState extends State<FileSelectionPage> {
  File? selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);

      setState(() {
        selectedFile = file;
      });

      // Navigue vers l'écran de découverte avec le fichier sélectionné
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiscoveryPage(file: file),
        ),
      );
    } else {
      // L'utilisateur a annulé la sélection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun fichier sélectionné.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sélectionner un fichier"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text("Choisir un fichier"),
          onPressed: _pickFile,
        ),
      ),
    );
  }
}
