// lib/widgets/file_item_card.dart
import 'package:flutter/material.dart';
import 'package:shareapp/models/app_file.dart'; // Assurez-vous que le chemin est correct
import 'package:shareapp/utils/file_icons.dart'; // Assurez-vous que le chemin est correct

class FileItemCard extends StatelessWidget {
  final AppFile file;
  final VoidCallback? onOpen; // Callback pour l'action "Ouvrir"

  const FileItemCard({
    super.key,
    required this.file,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icône du fichier (dépend de l'extension)
            Icon(
              getFileIcon(file.extension),
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 16.0),
            // Nom et taille du fichier
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    overflow: TextOverflow.ellipsis, // Gère les noms de fichiers longs
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    file.size,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            // Bouton "Ouvrir"
            ElevatedButton(
              onPressed: onOpen,
              child: const Text('Ouvrir'),
            ),
          ],
        ),
      ),
    );
  }
}