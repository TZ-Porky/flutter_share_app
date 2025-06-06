import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  ServerSocket? server;
  String status = "Initialisation...";
  String? localIP;
  bool isReceiving = false;
  RawDatagramSocket?
  udpBroadcastSocket; // Garder une référence pour la fermeture

  @override
  void initState() {
    super.initState();
    _initializeServer();
    _askPermissions();
    _startBroadcasting();
  }

  @override
  void dispose() {
    server?.close();
    udpBroadcastSocket?.close(); // Fermer le socket de diffusion UDP
    super.dispose();
  }

  // Ajoutez cette méthode à votre classe _ReceivePageState
  Future<void> _startBroadcasting() async {
    try {
      // Fermer le socket existant s'il y en a un
      udpBroadcastSocket?.close();

      // Créer un nouveau socket UDP
      udpBroadcastSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
      );

      // Activer le broadcast
      udpBroadcastSocket!.writeEventsEnabled = true;
      udpBroadcastSocket!.broadcastEnabled = true;

      // Log l'adresse IP à laquelle le socket de diffusion est bindé.
      // C'est souvent 0.0.0.0, mais c'est l'interface physique qui compte.
      debugPrint('ReceivePage: UDP Broadcast Socket bound to ${udpBroadcastSocket!.address.address}:${udpBroadcastSocket!.port}');

      // Envoyer des messages périodiques
      Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!isReceiving) {
          timer.cancel();
          udpBroadcastSocket?.close();
          return;
        }

        try {
          // Obtenir l'adresse de broadcast pour chaque interface
          final interfaces = await NetworkInterface.list();
          for (var interface in interfaces) {
            for (var addr in interface.addresses) {
              if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
                final broadcast = _getBroadcastAddress(addr, interface);
                if (broadcast != null) {
                  udpBroadcastSocket!.send(
                    utf8.encode('FILE_SERVER_HERE|${addr.address}'),
                    broadcast,
                    8889,
                  );
                  debugPrint('Broadcast envoyé à ${broadcast.address}:8889');
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Erreur de broadcast: $e');
        }
      });
    } catch (e) {
      debugPrint('Erreur initialisation socket UDP: $e');
    }
  }

  InternetAddress? _getBroadcastAddress(
    InternetAddress address,
    NetworkInterface interface,
  ) {
    try {
      final parts = address.address.split('.');
      if (parts.length != 4) return InternetAddress('255.255.255.255');

      if (address.address.startsWith('192.168.')) {
        return InternetAddress('192.168.255.255');
      } else if (address.address.startsWith('10.')) {
        return InternetAddress('10.255.255.255');
      } else if (address.address.startsWith('172.')) {
        final secondOctet = int.parse(parts[1]);
        if (secondOctet >= 16 && secondOctet <= 31) {
          return InternetAddress('172.${secondOctet}.255.255');
        }
      }

      // Fallback pour les autres réseaux
      if (interface.addresses.isNotEmpty) {
        final address = interface.addresses.first;
        final subnetMask = address.rawAddress;
        final ipAddress = address.rawAddress;

        if (subnetMask.length == 4 && ipAddress.length == 4) {
          final broadcastAddress = Uint8List(4);
          for (int i = 0; i < 4; i++) {
            broadcastAddress[i] = ipAddress[i] | ~subnetMask[i];
          }
          return InternetAddress.fromRawAddress(broadcastAddress);
        }
      }
      return InternetAddress('255.255.255.255');
    } catch (e) {
      debugPrint('Erreur calcul broadcast: $e');
      return null;
    }
  }

  /*
  // Méthode pour déterminer le chemin de stockage des fichiers reçues.
  String getDownloadPath(String filename) {
    if (Platform.isAndroid) {
      return '/storage/emulated/0/Download/$filename';
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      final home = Platform.environment['HOME'] ?? '/tmp';
      return '$home/Downloads/$filename';
    } else {
      return 'received_$filename';
    }
  }
*/

  // Méthode pour vérifier et demander les permissions de stockage (Android Uniquement)
  void _askPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  // Méthode pour initialiser le serveur de réception
  Future<void> _initializeServer() async {
    try {
      server = await ServerSocket.bind(InternetAddress.anyIPv4, 5000);
      // Obtenir l'adresse IP locale (Wi-Fi)
      final ip = await _getLocalIP();
      setState(() => localIP = ip ?? "IP non trouvée");

      // Lancer le serveur de réception
      _startFileServer((message) {
        if (mounted) {
          setState(() => status = message);
        }
      });
      setState(() => isReceiving = true);
    } catch (e) {
      setState(() {
        status = "❌ Échec du démarrage du serveur : $e";
        isReceiving = false;
      });
      print("Server initialization error: $e");
    }
  }

  // Méthode pour récupérer l'adresse IP locale
  Future<String?> _getLocalIP() async {
    try {
      for (var interface in await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal:
            false, // Exclure les adresses Link-Local (169.254.x.x)
      )) {
        for (var addr in interface.addresses) {
          // Filtrer les adresses de boucle locale et généralement celles de la forme 192.168.x.x
          // ou d'autres adresses IP privées (10.x.x.x, 172.16.x.x - 172.31.x.x)
          if (!addr.isLoopback &&
              (addr.address.startsWith('192.168.') ||
                  addr.address.startsWith('10.') ||
                  (addr.address.startsWith('172.') &&
                      int.parse(addr.address.split('.')[1]) >= 16 &&
                      int.parse(addr.address.split('.')[1]) <= 31))) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print("Error getting local IP: $e");
    }
    return null;
  }

  Future<void> _startFileServer(Function(String) onStatusUpdate) async {
    if (server == null) {
      onStatusUpdate("❌ Échec du démarrage du serveur.");
      return;
    }

    onStatusUpdate("✅ Serveur démarré. En attente d'un fichier...");

    server!.listen((Socket client) async {
      onStatusUpdate(
        "📥 Client connecté depuis ${client.remoteAddress.address}",
      );

      File? file;
      IOSink? sink;
      String fileName = "unknown_file";
      bool headerProcessed = false;
      BytesBuilder fileData = BytesBuilder();

      try {
        await for (var data in client) {
          if (!headerProcessed) {
            // Recherche du saut de ligne dans les données accumulées
            fileData.add(data);
            final allBytes = fileData.toBytes();
            final newlineIndex = allBytes.indexOf(10); // 10 = '\n'

            if (newlineIndex != -1) {
              // Extraire le nom de fichier
              fileName = utf8.decode(allBytes.sublist(0, newlineIndex));
              onStatusUpdate("Nom de fichier reçu: $fileName");

              // Créer le fichier de destination
              final downloadsDir = await _getDownloadDirectory();
              if (downloadsDir == null) {
                onStatusUpdate(
                  "❌ Impossible de trouver le répertoire de téléchargement.",
                );
                await client.close();
                return;
              }

              final fullPath = p.join(downloadsDir.path, fileName);
              file = File(fullPath);
              sink = file.openWrite(mode: FileMode.write);

              // Écrire les données restantes après le header
              if (newlineIndex + 1 < allBytes.length) {
                sink.add(allBytes.sublist(newlineIndex + 1));
              }

              headerProcessed = true;
              fileData.clear(); // Réinitialiser pour les données suivantes
            }
          } else {
            // Écrire les données normales après le header
            sink?.add(data);
          }
        }

        // Fermer proprement les ressources
        await sink?.flush();
        await sink?.close();

        if (file != null && file.existsSync()) {
          final fileSize = file.lengthSync();
          onStatusUpdate(
            "✅ Fichier reçu avec succès (${_getFileSize(fileSize)}): ${file.path}",
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '📁 Fichier enregistré (${_getFileSize(fileSize)}): ${file.path}',
                ),
              ),
            );
          }
        } else {
          onStatusUpdate("❌ Erreur: Fichier non créé ou vide");
        }
      } catch (e) {
        onStatusUpdate("❌ Erreur lors de la réception: $e");
        print("File reception error: $e");
        try {
          await sink?.flush();
          await sink?.close();
          if (file?.existsSync() ?? false) {
            file?.deleteSync(); // Supprimer les fichiers vides/corrompus
          }
        } catch (_) {}
      } finally {
        await client.close();
      }
    });
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return await getExternalStorageDirectory();
    } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      return await getDownloadsDirectory();
    }
    return await getApplicationDocumentsDirectory();
  }

  String _getFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recevoir un fichier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📡 Mon adresse IP : ${localIP ?? "Chargement..."}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Port d\'écoute : 5000 (transfert), 8889 (détection)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '🗂 Statut : $status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (!isReceiving)
                ElevatedButton.icon(
                  onPressed: () {
                    _initializeServer(); // Réinitialiser le serveur si arrêté
                    _startBroadcasting(); // Relancer la diffusion
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Redémarrer le serveur"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
