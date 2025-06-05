import 'dart:async';
import 'dart:io';
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

  @override
  void initState() {
    super.initState();
    _initializeServer();
    //_askPermissions();
    _broadcastPresence();
  }

  void _broadcastPresence() async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    Timer.periodic(const Duration(seconds: 2), (_) {
      socket.send(
        'FILE_SERVER_HERE'.codeUnits,
        InternetAddress('255.255.255.255'),
        5001,
      );
    });
  }

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

  void _askPermissions() async {
    await Permission.storage.request();
  }

  Future<void> _initializeServer() async {
    server = await ServerSocket.bind(InternetAddress.anyIPv4, 5000);
    // Obtenir l'adresse IP locale (Wi-Fi)
    final ip = await _getLocalIP();
    setState(() => localIP = ip ?? "IP non trouvée");

    // Lancer le serveur de réception
    _startFileServer((message) {
      setState(() => status = message);
    });
  }

  Future<String?> _getLocalIP() async {
    for (var interface in await NetworkInterface.list(
      type: InternetAddressType.IPv4,
    )) {
      for (var addr in interface.addresses) {
        if (!addr.isLoopback && addr.address.startsWith('192.168')) {
          return addr.address;
        }
      }
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

      try {
        final downloadsDir = await getExternalStorageDirectory();
        final filename =
            "fichier_recu_${DateTime.now().millisecondsSinceEpoch}.jpg";
        final file = File(p.join(downloadsDir!.path, filename));
        final sink = file.openWrite();

        client.listen(
          (data) => sink.add(data),
          onDone: () async {
            await sink.flush();
            await sink.close();
            onStatusUpdate("✅ Fichier reçu avec succès : ${file.path}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('📁 Fichier enregistré : ${file.path}')),
            );
          },
          onError: (e) {
            onStatusUpdate("❌ Erreur de réception : $e");
          },
          cancelOnError: true,
        );
      } catch (e) {
        onStatusUpdate("❌ Erreur de création de fichier : $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recevoir un fichier')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '📡 Mon adresse IP : ${localIP ?? "Chargement..."}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text('🗂 Statut : $status', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
