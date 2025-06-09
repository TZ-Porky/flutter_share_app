// lib/screens/send_files_screen/widgets/perimeter_detection_content.dart
import 'package:flutter/material.dart';
import 'package:shareapp/models/discovered_server.dart'; // Assurez-vous que le chemin est correct

class PerimeterDetectionContent extends StatelessWidget {
  final int activeServersCount;
  final DiscoveredServer? closestServer;
  final double? currentDirectionAngle;

  const PerimeterDetectionContent({
    super.key,
    required this.activeServersCount,
    this.closestServer,
    this.currentDirectionAngle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Text(
              'Serveurs Actifs ($activeServersCount/8)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          const Spacer(),
          Text(
            closestServer != null ? 'Envoi possible' : 'Envoi impossible',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: closestServer != null ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 30),
          Transform.rotate(
            angle: (currentDirectionAngle ?? 0) * (3.1415926535 / 180),
            child: Icon(
              Icons.navigation,
              size: 150,
              color: Theme.of(context).primaryColor, // Utilise la couleur primaire du thème
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Direction: ${currentDirectionAngle?.toStringAsFixed(1) ?? '0.0'}°',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            closestServer != null
                ? 'Serveur le plus proche: ${closestServer!.ipAddress}'
                : 'Aucun serveur dans cette direction',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const Spacer(),
          const SizedBox(height: 80), // Espace pour les boutons flottants
        ],
      ),
    );
  }
}