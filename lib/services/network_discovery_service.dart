import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../models/discovered_server.dart';
import '../models/server_info.dart' as models;
import 'file_transfer_client.dart';

class NetworkDiscoveryService {
  static const int DEFAULT_PORT = 8080;
  static const Duration PING_TIMEOUT = Duration(milliseconds: 1000);
  static const Duration SCAN_TIMEOUT = Duration(seconds: 30);

  /// Obtient l'adresse IP locale de l'appareil
  static Future<String?> getLocalIP() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiIP();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'IP locale: $e');
      return null;
    }
  }

  /// Obtient le nom du réseau WiFi
  static Future<String?> getWifiName() async {
    try {
      final info = NetworkInfo();
      return await info.getWifiName();
    } catch (e) {
      debugPrint('Erreur lors de la récupération du nom WiFi: $e');
      return null;
    }
  }

  /// Scanne le réseau local pour trouver des appareils
  static Future<List<DiscoveredServer>> scanNetwork({
    Function(int, int)? onProgress, // (current, total)
  }) async {
    List<DiscoveredServer> discoveredServers = [];
    
    try {
      String? localIP = await getLocalIP();
      if (localIP == null) {
        debugPrint('Impossible de récupérer l\'IP locale');
        return discoveredServers;
      }

      debugPrint('IP locale détectée: $localIP');

      // Extraire le sous-réseau (ex: 192.168.1.x)
      List<String> ipParts = localIP.split('.');
      if (ipParts.length != 4) {
        debugPrint('Format d\'IP invalide: $localIP');
        return discoveredServers;
      }

      String subnet = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      debugPrint('Scan du sous-réseau: $subnet.x');

      // Créer une liste de futures pour le scan parallèle
      List<Future<DiscoveredServer?>> futures = [];
      
      for (int i = 1; i <= 254; i++) {
        String targetIP = '$subnet.$i';
        if (targetIP != localIP) {
          futures.add(_checkHost(targetIP, i, onProgress));
        }
      }

      // Attendre tous les résultats avec timeout
      List<DiscoveredServer?> results = await Future.wait(futures)
          .timeout(SCAN_TIMEOUT, onTimeout: () {
        debugPrint('Timeout du scan réseau');
        return List.filled(futures.length, null);
      });

      // Filtrer les résultats valides
      for (DiscoveredServer? server in results) {
        if (server != null) {
          discoveredServers.add(server);
        }
      }

      debugPrint('Scan terminé: ${discoveredServers.length} serveur(s) trouvé(s)');

    } catch (e) {
      debugPrint('Erreur lors du scan réseau: $e');
    }

    return discoveredServers;
  }

  /// Vérifie un hôte spécifique
  static Future<DiscoveredServer?> _checkHost(
    String ip, 
    int index, 
    Function(int, int)? onProgress,
  ) async {
    try {
      // Callback de progression
      onProgress?.call(index, 254);

      // Ping basique pour vérifier la connectivité
      bool isReachable = await _pingHost(ip);
      if (!isReachable) {
        return null;
      }

      // Vérifier si c'est un serveur ShareApp
      models.ServerInfo? serverInfo = (await FileTransferClient.checkServer(ip)) as models.ServerInfo?;
      if (serverInfo != null) {
        return DiscoveredServer(
          ipAddress: ip,
          name: serverInfo.deviceName,
          status: 'active',
        );
      }

      // Si accessible mais pas ShareApp, l'ajouter quand même
      return DiscoveredServer(
        ipAddress: ip,
        name: 'Appareil $ip',
        status: 'unknown',
      );

    } catch (e) {
      // Ignorer les erreurs individuelles
      return null;
    }
  }

  /// Ping simple d'un hôte
  static Future<bool> _pingHost(String ip) async {
    try {
      // Utiliser Socket.connect pour un ping rapide
      Socket socket = await Socket.connect(ip, DEFAULT_PORT)
          .timeout(PING_TIMEOUT);
      socket.destroy();
      return true;
    } catch (e) {
      // Essayer un ping ICMP alternatif
      try {
        ProcessResult result = await Process.run(
          'ping',
          ['-c', '1', '-W', '1000', ip],
        ).timeout(PING_TIMEOUT, onTimeout: () {
          throw TimeoutException('Ping command timed out');
        });
        return result.exitCode == 0;
      } catch (e2) {
        return false;
      }
    }
  }

  /// Vérifie si un serveur spécifique est disponible
  static Future<bool> isServerAvailable(String ip, {int port = DEFAULT_PORT}) async {
    try {
      final socket = await Socket.connect(ip, port)
          .timeout(const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Scan rapide d'une liste d'IPs spécifiques
  static Future<List<DiscoveredServer>> quickScan(List<String> ips) async {
    List<DiscoveredServer> servers = [];
    
    List<Future<DiscoveredServer?>> futures = ips.map((ip) => 
        _checkHost(ip, 0, null)
    ).toList();

    List<DiscoveredServer?> results = await Future.wait(futures);
    
    for (DiscoveredServer? server in results) {
      if (server != null) {
        servers.add(server);
      }
    }

    return servers;
  }
}