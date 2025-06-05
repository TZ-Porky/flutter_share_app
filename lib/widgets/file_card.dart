import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class FileCard extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const FileCard({
    super.key,
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              _getFileIcon(file.extension),
              size: 40,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.videocam;
      case 'mp3':
      case 'wav':
        return Icons.audiotrack;
      default:
        return Icons.insert_drive_file;
    }
  }
}