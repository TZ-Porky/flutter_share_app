import 'package:flutter/material.dart';
import 'package:shareapp/models/discovered_server.dart'; // Assurez-vous que le chemin est correct

class ScanTabContent extends StatelessWidget {
  final List<DiscoveredServer> discoveredServers;
  final Function(DiscoveredServer)? onSelectServer;

  const ScanTabContent({
    super.key,
    required this.discoveredServers,
    this.onSelectServer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Serveurs Découverts (${discoveredServers.length}/8)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: discoveredServers.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 80, color: Colors.grey[300]), // Loupe comme sur l'image
                    const SizedBox(height: 16),
                    Text(
                      'Aucun serveur découvert',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: discoveredServers.length,
                  itemBuilder: (context, index) {
                    final server = discoveredServers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      // CardTheme appliqué via ThemeData
                      child: ListTile(
                        leading: Icon(
                          server.status == 'favorite' ? Icons.star : Icons.devices, // Icône étoile pour favori
                          color: server.status == 'favorite' ? Colors.amber : Theme.of(context).primaryColor,
                        ),
                        title: Text(server.name ?? 'Serveur ${server.ipAddress.split('.').last}'),
                        subtitle: Text(server.ipAddress),
                        trailing: server.status == 'active'
                            ? Icon(Icons.check_circle_outline, color: Colors.green)
                            : null, // Exemple de statut actif
                        onTap: () => onSelectServer?.call(server),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 80), // Espace pour les boutons flottants
      ],
    );
  }
}