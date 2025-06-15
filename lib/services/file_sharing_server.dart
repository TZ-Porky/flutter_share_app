import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/server_info.dart';

class FileSharingServer {
  HttpServer? _server;
  static const int DEFAULT_PORT = 8080;
  bool _isRunning = false;
  
  // Callbacks pour notifier l'UI
  Function(String fileName, int fileSize)? onFileReceived;
  Function(String error)? onError;

  bool get isRunning => _isRunning;
  int? get port => _server?.port;

  /// Démarre le serveur HTTP
  Future<bool> startServer({int port = DEFAULT_PORT, Function(String, int)? onFileReceived, Function(String)? onError,}) async {
    if (_isRunning) {
      print('Le serveur est déjà en cours d\'exécution');
      return true;
    }

    try {
      this.onFileReceived = onFileReceived;
      this.onError = onError;

      _server = await HttpServer.bind(InternetAddress.anyIPv4, port);
      _isRunning = true;
      
      print('Serveur démarré sur le port ${_server!.port}');

      _server!.listen((HttpRequest request) {
        _handleRequest(request);
      });

      return true;
    } catch (e) {
      String errorMsg = 'Erreur lors du démarrage du serveur: $e';
      print(errorMsg);
      this.onError?.call(errorMsg);
      return false;
    }
  }

  /// Arrête le serveur
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      _isRunning = false;
      print('Serveur arrêté');
    }
  }

  /// Gère les requêtes HTTP
  void _handleRequest(HttpRequest request) async {
    try {
      print('Requête reçue: ${request.method} ${request.uri.path}');

      // Activer CORS
      _addCorsHeaders(request.response);

      if (request.method == 'OPTIONS') {
        request.response.statusCode = 200;
        await request.response.close();
        return;
      }

      switch (request.uri.path) {
        case '/upload':
          await _handleFileUpload(request);
          break;
        case '/info':
          await _handleServerInfo(request);
          break;
        case '/ping':
          await _handlePing(request);
          break;
        case '/status':
          await _handleStatus(request);
          break;
        default:
          await _handleNotFound(request);
      }
    } catch (e) {
      String errorMsg = 'Erreur lors du traitement de la requête: $e';
      print(errorMsg);
      onError?.call(errorMsg);
      
      try {
        request.response.statusCode = 500;
        request.response.write('Erreur serveur interne');
        await request.response.close();
      } catch (e2) {
        print('Erreur lors de l\'envoi de la réponse d\'erreur: $e2');
      }
    }
  }

  /// Ajoute les headers CORS
  void _addCorsHeaders(HttpResponse response) {
    response.headers.add('Access-Control-Allow-Origin', '*');
    response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type, X-Filename, X-File-Size, X-File-Type');
  }

  /// Gère l'upload de fichiers
  Future<void> _handleFileUpload(HttpRequest request) async {
    if (request.method != 'POST') {
      await _sendErrorResponse(request, 405, 'Méthode non autorisée');
      return;
    }

    try {
      // Lire les données
      List<int> dataBytes = [];
      await for (List<int> chunk in request) {
        dataBytes.addAll(chunk);
      }

      if (dataBytes.isEmpty) {
        await _sendErrorResponse(request, 400, 'Aucune donnée reçue');
        return;
      }

      // Extraire les informations du fichier
      String? fileName = _extractFileName(request.headers);
      if (fileName == null || fileName.isEmpty) {
        fileName = 'fichier_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Créer le dossier de destination
      Directory appDir = await getApplicationDocumentsDirectory();
      String receivedDir = path.join(appDir.path, 'received_files');
      Directory(receivedDir).createSync(recursive: true);

      // Sauvegarder le fichier
      String filePath = path.join(receivedDir, fileName);
      File file = File(filePath);
      await file.writeAsBytes(dataBytes);

      print('Fichier reçu: $fileName (${dataBytes.length} bytes)');
      
      // Notifier l'UI
      onFileReceived?.call(fileName, dataBytes.length);

      // Réponse de succès
      await _sendJsonResponse(request, 200, {
        'success': true,
        'message': 'Fichier reçu avec succès',
        'fileName': fileName,
        'size': dataBytes.length,
        'path': filePath,
        'timestamp': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      String errorMsg = 'Erreur lors de la réception du fichier: $e';
      print(errorMsg);
      onError?.call(errorMsg);
      await _sendErrorResponse(request, 500, 'Erreur lors de la sauvegarde');
    }
  }

  /// Gère les informations du serveur
  Future<void> _handleServerInfo(HttpRequest request) async {
    ServerInfo serverInfo = ServerInfo(
      deviceName: Platform.localHostname,
      platform: Platform.operatingSystem,
      appName: 'ShareApp',
      version: '1.0.0',
      serverPort: DEFAULT_PORT
    );

    await _sendJsonResponse(request, 200, serverInfo.toJson());
  }

  /// Gère le ping
  Future<void> _handlePing(HttpRequest request) async {
    request.response.statusCode = 200;
    request.response.write('pong');
    await request.response.close();
  }

  /// Gère le status du serveur
  Future<void> _handleStatus(HttpRequest request) async {
    await _sendJsonResponse(request, 200, {
      'status': 'running',
      'port': _server?.port,
      'uptime': DateTime.now().toIso8601String(),
    });
  }

  /// Gère les endpoints non trouvés
  Future<void> _handleNotFound(HttpRequest request) async {
    await _sendErrorResponse(request, 404, 'Endpoint non trouvé');
  }

  /// Envoie une réponse JSON
  Future<void> _sendJsonResponse(HttpRequest request, int statusCode, Map<String, dynamic> data) async {
    request.response.statusCode = statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(data));
    await request.response.close();
  }

  /// Envoie une réponse d'erreur
  Future<void> _sendErrorResponse(HttpRequest request, int statusCode, String message) async {
    request.response.statusCode = statusCode;
    request.response.write(message);
    await request.response.close();
  }

  /// Extrait le nom du fichier des headers
  String? _extractFileName(HttpHeaders headers) {
    // Essayer le header personnalisé en premier
    String? customFileName = headers.value('x-filename');
    if (customFileName != null && customFileName.isNotEmpty) {
      return customFileName;
    }

    // Essayer Content-Disposition
    String? contentDisposition = headers.value('content-disposition');
    if (contentDisposition != null) {
      RegExp regExp = RegExp(r'filename[*]?=["]?([^";\r\n]+)["]?');
      Match? match = regExp.firstMatch(contentDisposition);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }
}

/// Gestionnaire singleton pour le serveur
class ServerManager {
  static final ServerManager _instance = ServerManager._private();
  factory ServerManager() => _instance;
  ServerManager._private();

  FileSharingServer? _server;

  FileSharingServer get server {
    _server ??= FileSharingServer();
    return _server!;
  }

  Future<bool> startServer({
    int port = FileSharingServer.DEFAULT_PORT,
    Function(String, int)? onFileReceived,
    Function(String)? onError,
  }) async {
    return await server.startServer(
      port: port,
      onFileReceived: onFileReceived,
      onError: onError,
    );
  }

  Future<void> stopServer() async {
    await server.stopServer();
  }

  bool get isRunning => server.isRunning;
  int? get port => server.port;
}