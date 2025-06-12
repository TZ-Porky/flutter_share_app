import 'package:flutter/material.dart';
import 'package:shareapp/models/transfer_item.dart'; // Assurez-vous du chemin
import 'package:shareapp/utils/file_icons.dart'; // Pour l'icône du fichier

class TransferItemCard extends StatelessWidget {
  final TransferItem transfer;
  final VoidCallback? onRemove; // Pour le bouton "Retirer"

  const TransferItemCard({
    super.key,
    required this.transfer,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Extraire l'extension du nom de fichier pour obtenir l'icône
    final fileExtension = transfer.fileName.split('.').last;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: Theme.of(context).cardTheme.elevation, // Utilise l'élévation du thème
      shape: Theme.of(context).cardTheme.shape, // Utilise la forme du thème
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(getFileIcon(fileExtension), size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transfer.fileName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    transfer.fileSize,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  if (transfer.status == TransferStatus.inProgress)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        LinearProgressIndicator(
                          value: transfer.progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${(transfer.progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(color: Colors.grey[700], fontSize: 12),
                        ),
                      ],
                    )
                  else // Pour les autres statuts (terminé, en attente, etc.)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _getStatusText(transfer.status),
                        style: TextStyle(color: transfer.statusColor, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            if (onRemove != null && (transfer.status == TransferStatus.completed || transfer.status == TransferStatus.failed || transfer.status == TransferStatus.cancelled))
              TextButton(
                onPressed: onRemove,
                child: const Text('Retirer'),
              ),
            if (transfer.status == TransferStatus.inProgress || transfer.status == TransferStatus.pending)
              IconButton(
                icon: const Icon(Icons.close), // Ou une icône de pause/annulation
                color: Colors.grey[600],
                onPressed: () {
                  // TODO: Gérer l'annulation ou la pause du transfert
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Action sur le transfert de ${transfer.fileName}')),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return 'Terminé';
      case TransferStatus.inProgress:
        return 'En cours';
      case TransferStatus.pending:
        return 'En attente';
      case TransferStatus.cancelled:
        return 'Annulé';
      case TransferStatus.failed:
        return 'Échec';
    }
  }
}