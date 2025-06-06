import 'dart:async'; // Pour Timer
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart'; // Pour firstWhereOrNull si non déjà importé

import 'shake_to_send_page.dart'; // Assurez-vous que ce chemin est correct

class DiscoveryPage extends StatefulWidget {
  final File file; // Fichier à envoyer, reçu depuis FileSelectionPage

  const DiscoveryPage({super.key, required this.file});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  // Utilisez un Map pour stocker les appareils découverts avec un horodatage
  // Cela permet de nettoyer les anciens appareils si nécessaire.
  final Map<String, _DiscoveredDevice> _devices = {};
  RawDatagramSocket? _socket;
  Timer? _cleanupTimer; // Timer pour le nettoyage des anciens appareils

  @override
  void initState() {
    super.initState();
    _startListening();
    _startCleanupTimer(); // Démarre le nettoyage périodique
  }

  // Cette simulation est utile pour le développement, gardez-la si vous voulez.
  void _simulateDiscovery() {
    final simulated = _DiscoveredDevice(name: "Simulated Device", ip: "192.168.1.102");
    if (!_devices.containsKey(simulated.ip)) {
      setState(() {
        _devices[simulated.ip] = simulated;
      });
    } else {
      _devices[simulated.ip]!.updateLastSeen(); // Simule une mise à jour
    }
  }

  void _startListening() async {
    try {
      _socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4, // Écoute sur toutes les interfaces
        8889, // Port d'écoute pour les annonces de serveurs
        reuseAddress: true,
      );
      // Assurez-vous que le broadcast est activé pour pouvoir recevoir des paquets broadcastés
      _socket!.broadcastEnabled = true;

      debugPrint('DiscoveryPage: Démarrage de l\'écoute UDP sur ${_socket!.address.address}:${_socket!.port}');

      _socket!.listen((event) {
        if (event == RawSocketEvent.read) {
          final datagram = _socket!.receive();
          if (datagram == null) {
            debugPrint('DiscoveryPage: Datagramme reçu vide.');
            return;
          }

          final message = String.fromCharCodes(datagram.data);
          final senderIp = datagram.address.address;

          debugPrint('DiscoveryPage: Message UDP reçu: "$message" de $senderIp');

          // Le message attendu est "FILE_SERVER_HERE|IP_DU_SERVEUR"
          if (message.startsWith('FILE_SERVER_HERE|')) {
            final parts = message.split('|');
            if (parts.length == 2) {
              final serverIp = parts[1]; // C'est l'IP que le serveur annonçait
              // Si le message venait d'une autre IP que celle annoncée, utilisez senderIp ou serverIp selon votre besoin
              // Pour la détection, serverIp est l'IP que le récepteur a déclarée
              final String ipToUse = serverIp; 
              
              if (!_devices.containsKey(ipToUse)) {
                setState(() {
                  _devices[ipToUse] = _DiscoveredDevice(name: 'Serveur ${ipToUse.split('.').last}', ip: ipToUse);
                  debugPrint('DiscoveryPage: Nouveau serveur détecté: ${ipToUse}');
                });
              } else {
                _devices[ipToUse]!.updateLastSeen(); // Met à jour le timestamp pour garder l'appareil dans la liste
                debugPrint('DiscoveryPage: Serveur existant mis à jour: ${ipToUse}');
              }
            } else {
              debugPrint('DiscoveryPage: Message UDP reçu au format incorrect: "$message"');
            }
          }
        }
      }, onError: (e) {
        debugPrint('DiscoveryPage: Erreur lors de l\'écoute UDP: $e');
      }, onDone: () {
        debugPrint('DiscoveryPage: Écoute UDP terminée.');
      });
    } catch (e) {
      debugPrint('DiscoveryPage: Erreur au démarrage de l\'écoute UDP: $e');
      // Gérer l'erreur, par exemple afficher un message à l'utilisateur
    }
  }

  // Nettoie les appareils qui n'ont pas été vus depuis un certain temps
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final now = DateTime.now();
        final expiredKeys = _devices.entries
            .where((entry) => now.difference(entry.value.lastSeen) > const Duration(seconds: 15)) // 15 secondes d'inactivité
            .map((entry) => entry.key)
            .toList();

        for (var key in expiredKeys) {
          debugPrint('DiscoveryPage: Nettoyage du serveur expiré: ${key}');
          _devices.remove(key);
        }
      });
    });
  }

  @override
  void dispose() {
    _socket?.close();
    _cleanupTimer?.cancel(); // Annule le timer de nettoyage
    super.dispose();
  }

  void _selectDevice(_DiscoveredDevice selected) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShakeToSendPage(
          // Passe seulement l'IP de l'appareil sélectionné, pas tous les découverts
          discoveredServers: [selected.ip], 
          hasFileSelected: true,
          fileToSend: widget.file,
          onSendFile: (ip, file) {
            debugPrint("📤 Envoi du fichier ${file.path} à $ip");
            // Ici, vous appelez votre fonction sendFile, qui sera dans ShakeToSendPage
            // ou un service qu'elle utilise.
            // Le sendFile réel sera exécuté via le callback de ShakeToSendPage.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📡 Découverte d\'appareils')),
      body: _devices.isEmpty
          ? const Center(child: Text('Aucun appareil trouvé...'))
          : ListView.builder(
              itemCount: _devices.length,
              itemBuilder: (context, index) {
                // Affiche les appareils par ordre alphabétique des IPs
                final device = _devices.values.toList()..sort((a, b) => a.ip.compareTo(b.ip));
                final currentDevice = device[index];
                return Card( // Utilisation d'une Card pour un meilleur visuel
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(Icons.devices_other, color: Colors.blueAccent),
                    title: Text(currentDevice.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(currentDevice.ip),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () => _selectDevice(currentDevice),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _simulateDiscovery, // Bouton pour la simulation
        child: const Icon(Icons.bug_report),
      ),
    );
  }
}

// Nouvelle définition de _DiscoveredDevice pour inclure le timestamp
class _DiscoveredDevice {
  final String name;
  final String ip;
  DateTime lastSeen; // Ajout d'un timestamp

  _DiscoveredDevice({required this.name, required this.ip}) : lastSeen = DateTime.now();

  void updateLastSeen() {
    lastSeen = DateTime.now();
  }

  // Pour une meilleure comparaison dans un Map, bien que la clé IP soit déjà unique
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _DiscoveredDevice && runtimeType == other.runtimeType && ip == other.ip;

  @override
  int get hashCode => ip.hashCode;
}