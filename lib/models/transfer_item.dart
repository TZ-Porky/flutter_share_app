import 'package:flutter/material.dart'; // Pour les icônes si nécessaire

enum TransferStatus { completed, inProgress, pending, cancelled, failed }

class TransferItem {
  final String id; // ID unique du transfert
  final String fileName; // Nom du fichier transféré
  final String fileSize; // Taille du fichier (ex: "300 Mo")
  final double progress; // Pourcentage de progression (0.0 à 1.0)
  final TransferStatus status; // Statut du transfert
  final DateTime timestamp; // Date et heure du transfert

  TransferItem({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.progress = 0.0,
    required this.status,
    required this.timestamp,
  });

  // Méthode pour obtenir l'icône de statut
  IconData get statusIcon {
    switch (status) {
      case TransferStatus.completed:
        return Icons.check_circle_outline;
      case TransferStatus.inProgress:
        return Icons.upload_file; // Ou un icône de téléchargement/upload
      case TransferStatus.pending:
        return Icons.access_time;
      case TransferStatus.cancelled:
        return Icons.cancel_outlined;
      case TransferStatus.failed:
        return Icons.error_outline;
    }
  }

  Color get statusColor {
    switch (status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.inProgress:
        return Colors.blue;
      case TransferStatus.pending:
        return Colors.orange;
      case TransferStatus.cancelled:
        return Colors.grey;
      case TransferStatus.failed:
        return Colors.red;
    }
  }
}