import 'package:flutter/foundation.dart'; // Pour @required ou @non_nullable

class DiscoveredServer {
  final String ipAddress;
  final String? name; // Le nom pourrait être optionnel ou générique
  final double? direction; // Angle de direction si implémenté (pour le ShakeScanSection)
  final String? status; // Statut du serveur (actif, inactif, etc.)

  DiscoveredServer({
    required this.ipAddress,
    this.name,
    this.direction,
    this.status,
  });

  // Méthode pour la comparaison si vous les stockez dans une liste ou un set
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveredServer && runtimeType == other.runtimeType && ipAddress == other.ipAddress;

  @override
  int get hashCode => ipAddress.hashCode;
}