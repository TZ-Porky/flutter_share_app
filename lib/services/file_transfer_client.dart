import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/app_file.dart';
import '../models/transfer_result.dart';
import '../models/server_info.dart';

class FileTransferClient {
  static const int DEFAULT_PORT = 8080;
  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 30);
  static const Duration PING_TIMEOUT = Duration(seconds: 5);

  /// Envoie un fichier à un serveur distant
  static Future<TransferResult> sendFile(
    String targetIP,
    AppFile file, {
    int port = DEFAULT_PORT,
    Duration? timeout,
    Function(double)? onProgress,
  }) async {
    timeout ??= DEFAULT_TIMEOUT;

    try {
      print('Envoi du fichier ${file.name} vers $targetIP:$port');

      // Vérifier que le fichier existe
      File fileToSend = File(file.path);
      if (!await fileToSend.exists()) {
        return TransferResult(
          success: false,
          message: 'Fichier non trouvé: ${file.path}',
        );
      }

      // Lire le fichier
      List<int> fileBytes = await fileToSend.readAsBytes();
      print('Taille du fichier: ${fileBytes.length} bytes');

      // Préparer l'URL
      String url = 'http://$targetIP:$port/upload';

      // Créer la requête
      var request = http.Request('POST', Uri.parse(url));
      
      // Ajouter les headers
      request.headers.addAll({
        'Content-Type': 'application/octet-stream',
        'X-Filename': file.name,
        'X-File-Size': fileBytes.length.toString(),
        'X-File-Type': file.type,
        'Content-Length': fileBytes.length.toString(),
      });

      // Ajouter les données du fichier
      request.bodyBytes = fileBytes;

      // Envoyer la requête
      http.StreamedResponse response = await request.send().timeout(timeout);

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        
        try {
          Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
          return TransferResult(
            success: true,
            message: jsonResponse['message'] ?? 'Fichier envoyé avec succès',
            fileName: file.name,
            fileSize: fileBytes.length,
          );
        } catch (e) {
          // Si la réponse n'est pas du JSON, c'est probablement un succès quand même
          return TransferResult(
            success: true,
            message: 'Fichier envoyé avec succès',
            fileName: file.name,
            fileSize: fileBytes.length,
          );
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        return TransferResult(
          success: false,
          message: 'Erreur serveur (${response.statusCode}): $errorBody',
        );
      }

    } catch (e) {
      String errorMsg = 'Erreur lors de l\'envoi: $e';
      print(errorMsg);
      return TransferResult(
        success: false,
        message: errorMsg,
      );
    }
  }

  /// Envoie plusieurs fichiers à un serveur
  static Future<List<TransferResult>> sendMultipleFiles(
    String targetIP,
    List<AppFile> files, {
    int port = DEFAULT_PORT,
    Duration? timeout,
    Function(int completed, int total, String? currentFile)? onProgress,
  }) async {
    List<TransferResult> results = [];

    print('Envoi de ${files.length} fichiers vers $targetIP:$port');

    for (int i = 0; i < files.length; i++) {
      AppFile file = files[i];
      
      // Notifier le début de l'envoi du fichier
      onProgress?.call(i, files.length, file.name);

      TransferResult result = await sendFile(
        targetIP, 
        file, 
        port: port,
        timeout: timeout,
      );
      
      results.add(result);
      
      // Notifier la fin de l'envoi du fichier
      onProgress?.call(i + 1, files.length, null);
      
      // Petite pause entre les fichiers
      if (i < files.length - 1) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    int successCount = results.where((r) => r.success).length;
    print('Envoi terminé: $successCount/${files.length} fichiers envoyés avec succès');

    return results;
  }

  /// Vérifie si un serveur est disponible et récupère ses informations
  static Future<ServerInfo?> checkServer(
    String targetIP, {
    int port = DEFAULT_PORT,
    Duration? timeout,
  }) async {
    timeout ??= PING_TIMEOUT;

    try {
      String url = 'http://$targetIP:$port/info';
      
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        try {
          Map<String, dynamic> data = jsonDecode(response.body);
          return ServerInfo.fromJson(data);
        } catch (e) {
          print('Erreur lors du parsing JSON: $e');
          // Retourner des infos par défaut si le JSON est invalide
          return ServerInfo(
            deviceName: 'Appareil $targetIP',
            platform: 'Inconnu',
            appName: 'ShareApp',
            version: '1.0.0',
            serverPort: DEFAULT_PORT
          );
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification du serveur $targetIP: $e');
    }
    return null;
  }

  /// Ping simple d'un serveur
  static Future<bool> pingServer(
    String targetIP, {
    int port = DEFAULT_PORT,
    Duration? timeout,
  }) async {
    timeout ??= PING_TIMEOUT;

    try {
      String url = 'http://$targetIP:$port/ping';
      
      http.Response response = await http.get(
        Uri.parse(url),
      ).timeout(timeout);

      return response.statusCode == 200 && response.body.trim() == 'pong';
    } catch (e) {
      return false;
    }
  }

  /// Vérifie le statut d'un serveur
  static Future<Map<String, dynamic>?> getServerStatus(
    String targetIP, {
    int port = DEFAULT_PORT,
    Duration? timeout,
  }) async {
    timeout ??= PING_TIMEOUT;

    try {
      String url = 'http://$targetIP:$port/status';
      
      http.Response response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Erreur lors de la récupération du statut: $e');
    }
    return null;
  }

  /// Test de connectivité basique (sans HTTP)
  static Future<bool> testConnectivity(
    String targetIP, {
    int port = DEFAULT_PORT,
    Duration? timeout,
  }) async {
    timeout ??= const Duration(seconds: 3);

    try {
      Socket socket = await Socket.connect(targetIP, port).timeout(timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Batch ping de plusieurs serveurs
  static Future<Map<String, bool>> pingMultipleServers(
    List<String> ips, {
    int port = DEFAULT_PORT,
    Duration? timeout,
  }) async {
    Map<String, bool> results = {};
    
    List<Future<MapEntry<String, bool>>> futures = ips.map((ip) async {
      bool isAlive = await pingServer(ip, port: port, timeout: timeout);
      return MapEntry(ip, isAlive);
    }).toList();

    List<MapEntry<String, bool>> completed = await Future.wait(futures);
    
    for (MapEntry<String, bool> entry in completed) {
      results[entry.key] = entry.value;
    }

    return results;
  }
}