import 'file_sharing_server.dart';

/// Singleton pour gérer le serveur globalement dans l'app
class ServerManager {
  static final ServerManager _instance = ServerManager._internal();
  factory ServerManager() => _instance;
  ServerManager._internal();

  FileSharingServer? _server;
  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Démarre le serveur de réception de fichiers
  Future<bool> startServer() async {
    if (_isRunning) return true;

    try {
      _server = FileSharingServer();
      bool started = await _server!.startServer();
      _isRunning = started;
      return started;
    } catch (e) {
      print('Erreur ServerManager.startServer: $e');
      return false;
    }
  }

  /// Arrête le serveur
  Future<void> stopServer() async {
    if (_server != null) {
      await _server!.stopServer();
      _server = null;
      _isRunning = false;
    }
  }
}