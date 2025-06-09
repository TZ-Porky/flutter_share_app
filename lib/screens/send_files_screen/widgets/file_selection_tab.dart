// lib/screens/send_files_screen/widgets/file_selection_tab.dart
import 'package:flutter/material.dart';
import 'package:shareapp/models/app_file.dart'; // Assurez-vous que le chemin est correct
import 'package:shareapp/utils/file_icons.dart'; // Assurez-vous que le chemin est correct

class FileSelectionTab extends StatefulWidget {
  final List<AppFile> selectedFiles;
  final Function(AppFile) onRemoveFile;
  final VoidCallback onAddFile;

  const FileSelectionTab({
    super.key,
    required this.selectedFiles,
    required this.onRemoveFile,
    required this.onAddFile,
  });

  @override
  State<FileSelectionTab> createState() => _FileSelectionTabState();
}

class _FileSelectionTabState extends State<FileSelectionTab> {
  String _getTotalSize() {
    int totalBytes = 0;
    for (var file in widget.selectedFiles) {
      // Pour une application réelle, assurez-vous que AppFile stocke la taille en octets (int)
      // Ceci est une conversion simplifiée pour l'exemple.
      if (file.size.contains('Mo')) {
        totalBytes += (double.parse(file.size.replaceAll(' Mo', '')) * 1024 * 1024).round();
      } else if (file.size.contains('Go')) {
        totalBytes += (double.parse(file.size.replaceAll(' Go', '')) * 1024 * 1024 * 1024).round();
      } else if (file.size.contains('Ko')) {
        totalBytes += (double.parse(file.size.replaceAll(' Ko', '')) * 1024).round();
      }
    }

    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} Ko';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} Go';
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = _getTotalSize();
    final currentUsage = widget.selectedFiles.isEmpty ? '0 Mo' : totalSize;
    // Supposons une capacité de 1 Go pour l'exemple.
    final maxCapacity = '1 Go'; // Cette valeur devrait être dynamique si elle dépend du stockage disponible.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: widget.onAddFile,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un fichier'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50), // Bouton pleine largeur
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Fichiers à envoyer ($currentUsage / $maxCapacity) :',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: widget.selectedFiles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun fichier sélectionné.',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.selectedFiles.length,
                  itemBuilder: (context, index) {
                    final file = widget.selectedFiles[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                      // CardTheme appliqué via ThemeData
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Utilise l'icône via getFileIcon
                            Icon(getFileIcon(file.extension), size: 36, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 12.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    file.size,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onRemoveFile(file),
                              child: const Text('Retirer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}