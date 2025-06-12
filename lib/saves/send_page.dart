import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as p;

// Définir un enum pour les modes d'envoi
enum SendMode { ipAddress, serverDetection }

class SendPage extends StatefulWidget {
  const SendPage({super.key});

  @override
  State<SendPage> createState() => _SendPageState();
}

class _SendPageState extends State<SendPage> {
  File? selectedFile; // Fichier sélectionné par l'utilisateur
  List<String> discoveredServers =
      []; // Liste des serveurs sur écoute rescencés
  RawDatagramSocket? udpSocket; // Socket UDP pour le broadcast
  final TextEditingController _ipController =
      TextEditingController(); // Contenu du champ d'adresse IP
  SendMode _currentSendMode =
      SendMode.serverDetection; // Mode d'envoi de fichier
  String?
  _videoThumbnailPath; // Chemin pour stocker le chemin de la maniature générée pour la vidéo

  @override
  void initState() {
    super.initState();
    _listenForServers();
    _startServerCleanupTimer();
  }

  @override
  void dispose() {
    udpSocket?.close();
    _ipController.dispose();
    // Supprimer la miniature vidéo temporaire si elle existe
    if (_videoThumbnailPath != null &&
        File(_videoThumbnailPath!).existsSync()) {
      File(_videoThumbnailPath!).deleteSync();
    }
    super.dispose();
  }

  // Méthode pour écouter les serveurs disponibles sur le réseau
  Future<void> _listenForServers() async {
    try {
      udpSocket?.close();

      // Binding spécifique pour Linux
      udpSocket = await RawDatagramSocket.bind(
        Platform.isLinux ? InternetAddress.anyIPv4 : InternetAddress.anyIPv4,
        8889,
        reuseAddress: true,
        reusePort: Platform.isLinux, // Crucial pour Linux
      );
      udpSocket!.broadcastEnabled = true;

      debugPrint('Mode écoute UDP activé sur ${udpSocket!.address.address}');

      udpSocket!.listen(
        (RawSocketEvent event) {
          if (event == RawSocketEvent.read) {
            final datagram = udpSocket!.receive();
            if (datagram != null) {
              final message = String.fromCharCodes(datagram.data);
              debugPrint('Message reçu: $message');

              final parts = message.split('|');
              if (parts.length == 2 && parts[0] == 'FILE_SERVER_HERE') {
                final serverIp = parts[1];
                if (!discoveredServers.contains(serverIp)) {
                  setState(() {
                    discoveredServers.add(serverIp);
                    discoveredServers = List.from(
                      discoveredServers,
                    ); // Force refresh
                  });
                  _showSnackBar('Serveur détecté: $serverIp', Colors.green);
                }
              }
            }
          }
        },
        onError: (error) {
          debugPrint('Erreur socket UDP: $error');
        },
      );
    } catch (e) {
      debugPrint('Erreur initialisation écoute UDP: $e');
    }
  }

  // Ajoutez cette méthode pour nettoyer périodiquement
  void _startServerCleanupTimer() {
    Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        // Supprime les serveurs qui n'ont pas été mis à jour récemment
        discoveredServers = discoveredServers;
      });
    });
  }

  // Méthode pour choisir un fichier
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        _videoThumbnailPath = null; // Réinitialiser l'aperçu vidéo précédent
      });
      _showSnackBar(
        'Fichier sélectionné: ${selectedFile!.path.split('/').last}',
        Colors.blue,
      );

      // Tenter de générer une miniature si c'est une vidéo
      if (selectedFile != null && _isVideoFile(selectedFile!.path)) {
        await _generateVideoThumbnail(selectedFile!.path);
      }
    }
  }

  // Helper pour vérifier si c'est un fichier vidéo
  bool _isVideoFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);
  }

  // Helper pour vérifier si c'est un fichier image
  bool _isImageFile(String path) {
    final extension = p.extension(path).toLowerCase();
    return [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
    ].contains(extension);
  }

  // Helper pour générer la miniature vidéo
  Future<void> _generateVideoThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoPath,
      thumbnailPath: (await getTemporaryDirectory()).path, // Chemin temporaire
      imageFormat: ImageFormat.JPEG,
      maxHeight: 128, // Taille de la miniature
      maxWidth: 128,
      quality: 75,
    );
    setState(() {
      _videoThumbnailPath = thumbnailPath;
    });
  }

  // Méthode pour envoyer le fichier à une adresse IP spécifique
  Future<void> _sendFile(String hostIP) async {
    if (selectedFile == null) {
      _showSnackBar('Veuillez d’abord sélectionner un fichier.', Colors.orange);
      return;
    }

    try {
      final socket = await Socket.connect(
        hostIP,
        5000,
        timeout: const Duration(seconds: 10),
      );

      final fileName = p.basename(
        selectedFile!.path,
      ); // Extrait le nom du fichier
      final fileNameBytes = utf8.encode(
        '$fileName\n',
      ); // Convertir le nom du fichier en octets avec un saut de ligne

      // Envoyer d'abord le nom du fichier
      socket.add(fileNameBytes); // Utilisez add() pour les octets bruts

      // Ensuite, envoyer les octets du fichier.
      // openRead() renvoie un Stream<List<int>>.
      // pipe() est la bonne méthode pour transférer ce Stream directement au socket.
      final fileStream = selectedFile!.openRead();
      await fileStream.pipe(
        socket,
      ); // Le flux du fichier sera maintenant envoyé après le nom

      // Assurez-vous que toutes les données sont envoyées et que le socket est fermé proprement.
      await socket.flush(); // Force l'envoi des données mises en tampon
      await socket.close(); // Ferme la connexion

      _showSnackBar('✅ Fichier "$fileName" envoyé à $hostIP', Colors.green);
    } catch (e) {
      print('Erreur d\'envoi à $hostIP : $e'); // Log pour le débogage
      _showSnackBar('❌ Erreur d\'envoi à $hostIP : $e', Colors.red);
    }
  }

  // Méthode pour afficher un snackbar ( A remplacer par une interface plus jolie )
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Widget pour afficher l'aperçu du fichier
  Widget _buildFilePreview() {
    if (selectedFile == null) {
      return const SizedBox.shrink();
    }

    final String fileName = p.basename(selectedFile!.path);

    Widget previewWidget;
    IconData fileIcon = Icons.insert_drive_file; // Icône par défaut

    if (_isImageFile(selectedFile!.path)) {
      fileIcon = Icons.image;
      previewWidget = Image.file(
        selectedFile!,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else if (_isVideoFile(selectedFile!.path)) {
      fileIcon = Icons.videocam;
      if (_videoThumbnailPath != null) {
        previewWidget = Image.file(
          File(_videoThumbnailPath!),
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        );
      } else {
        previewWidget = const SizedBox(
          height: 100,
          width: 100,
          child: Center(
            child: CircularProgressIndicator(),
          ), // Indicateur de chargement de miniature
        );
      }
    } else {
      // Pour les autres types de fichiers (documents, etc.)
      // Vous pouvez ajouter plus de logique ici pour des icônes spécifiques
      // ou utiliser des packages comme `file_icon` si vous voulez des icônes plus détaillées.
      fileIcon = _getFileIcon(
        fileName,
      ); // Utilise une fonction pour une icône plus spécifique
      previewWidget = Icon(fileIcon, size: 80, color: Colors.grey[600]);
    }

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Aperçu du fichier sélectionné :",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 184, 194, 216),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color.fromARGB(255, 107, 116, 138)),
          ),
          child: Row(
            children: [
              // Aperçu visuel
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: previewWidget,
              ),
              const SizedBox(width: 15),
              // Nom du fichier
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Taille: ${_getFileSize(selectedFile!.lengthSync())}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper pour déterminer l'icône en fonction de l'extension
  IconData _getFileIcon(String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.txt':
        return Icons.text_snippet;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      case '.apk':
        return Icons.android; // Icône spécifique pour les APK
      default:
        return Icons.insert_drive_file;
    }
  }

  // Helper pour formater la taille du fichier
  String _getFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];

    var i = (bytes > 0) ? (log(bytes) / log(2) / 10).floor() : 0;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Envoyer un fichier")),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text(
                'Choisir le mode d\'envoi',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dialpad),
              title: const Text('Envoyer par adresse IP'),
              onTap: () {
                setState(() {
                  _currentSendMode = SendMode.ipAddress;
                });
                Navigator.pop(context);
              },
              selected: _currentSendMode == SendMode.ipAddress,
              selectedTileColor: Colors.blue.withOpacity(0.1),
            ),
            ListTile(
              leading: const Icon(Icons.wifi_find),
              title: const Text('Détection de serveur'),
              onTap: () {
                setState(() {
                  _currentSendMode = SendMode.serverDetection;
                });
                Navigator.pop(context);
              },
              selected: _currentSendMode == SendMode.serverDetection,
              selectedTileColor: Colors.blue.withOpacity(0.1),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text("📂 Choisir un fichier"),
            ),
            // Utilise le nouveau widget pour l'aperçu
            _buildFilePreview(),
            const SizedBox(height: 30),
            // Affichage conditionnel basé sur le mode d'envoi
            if (_currentSendMode == SendMode.ipAddress) ...[
              const Text(
                "🔢 Entrez l'adresse IP du destinataire :",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ex: 192.168.1.10',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_ipController.text.isNotEmpty) {
                    _sendFile(_ipController.text);
                  } else {
                    _showSnackBar(
                      'Veuillez entrer une adresse IP.',
                      Colors.orange,
                    );
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text("Envoyer à cette IP"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ] else if (_currentSendMode == SendMode.serverDetection) ...[
              const Text(
                "📡 Appareils disponibles :",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    discoveredServers.isEmpty
                        ? const Center(
                          child: Text(
                            "Aucun serveur détecté...\nAssurez-vous qu'un serveur écoute sur le port 8889.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: discoveredServers.length,
                          itemBuilder: (context, index) {
                            final ip = discoveredServers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              elevation: 2,
                              child: ListTile(
                                title: Text("📶 Serveur sur $ip"),
                                trailing: ElevatedButton(
                                  onPressed: () => _sendFile(ip),
                                  child: const Text("Envoyer"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
