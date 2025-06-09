import 'package:flutter/material.dart';
import 'package:shareapp/models/app_file.dart';
import 'package:shareapp/models/discovered_server.dart';
import 'package:shareapp/widgets/bottom_action_buttons_row.dart';
import 'package:shareapp/widgets/custom_tab_bar_secondary.dart'; // Importez le nouveau nom
import 'package:shareapp/screens/send_files_screen/widgets/file_selection_tab.dart';
import 'package:shareapp/screens/send_files_screen/widgets/ip_address_tab.dart';
import 'package:shareapp/screens/send_files_screen/widgets/scan_tab_content.dart';
import 'package:shareapp/screens/send_files_screen/widgets/perimeter_detection_content.dart';

class SendFilesScreen extends StatefulWidget {
  final List<AppFile>? initialFiles;

  const SendFilesScreen({super.key, this.initialFiles});

  @override
  State<SendFilesScreen> createState() => _SendFilesScreenState();
}

class _SendFilesScreenState extends State<SendFilesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['FICHIER', 'ADRESSE IP', 'SCAN'];

  // 0: Fichier, 1: Adresse IP, 2: Scan (Onglets)
  // 3: Détection Périmétrique (Vue séparée)
  int _currentContentIndex = 2; // Démarrage par défaut sur l'onglet SCAN (index 2)

  List<AppFile> _selectedFiles = [];
  final TextEditingController _ipController = TextEditingController();

  List<DiscoveredServer> _discoveredServers = [];
  List<DiscoveredServer> _perimeterServers = []; // Serveurs proches détectés
  DiscoveredServer? _closestPerimeterServer;
  double _currentDirectionAngle = 0.0;

  List<String> _favoriteIps = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    if (widget.initialFiles != null) {
      _selectedFiles = List.from(widget.initialFiles!);
    }

    // Données de test initiales
    _discoveredServers = [
      DiscoveredServer(ipAddress: '192.168.1.10', name: 'PC de Jean', status: 'active'),
      DiscoveredServer(ipAddress: '192.168.1.15', name: 'Tablet X', status: 'active'),
      DiscoveredServer(ipAddress: '192.168.1.25', name: 'Server Dev', status: 'favorite'),
    ];
    _perimeterServers = [
      DiscoveredServer(ipAddress: '192.168.1.10', name: 'PC de Jean', status: 'active'),
      // Ajoutez d'autres serveurs proches si nécessaire pour tester le count
      DiscoveredServer(ipAddress: '192.168.1.11', name: 'PC de Marie', status: 'active'),
      DiscoveredServer(ipAddress: '192.168.1.12', name: 'Téléphone', status: 'active'),
    ];
    _closestPerimeterServer = _perimeterServers.isNotEmpty ? _perimeterServers.first : null;
    _currentDirectionAngle = 45.0; // Angle initial pour l'exemple
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      // Met à jour l'index de contenu si on change d'onglet
      setState(() {
        _currentContentIndex = _tabController.index;
      });
    }
  }

  bool _isBottomButtonsVisible() {
    return _currentContentIndex == 2 || _currentContentIndex == 3; // SCAN (index 2) ou Détection Périmétrique (index 3)
  }

  // --- Fonctions de gestion des fichiers (pour l'onglet FICHIER) ---
  void _addFile() {
    setState(() {
      _selectedFiles.add(
        AppFile(
          name: 'Nouveau fichier ${(_selectedFiles.length + 1)}.zip',
          size: '1.2 Mo',
          path: '/temp/new_file.zip',
          extension: 'zip',
          type: 'FICHIERS', // Assurez-vous d'ajouter le type
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fichier ajouté (simulé)')),
    );
  }

  void _removeFile(AppFile file) {
    setState(() {
      _selectedFiles.remove(file);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${file.name} retiré')),
    );
  }

  // --- Fonctions de gestion de l'IP (pour l'onglet ADRESSE IP) ---
  void _sendFilesToIp(String ip) {
    if (ip.isEmpty || !RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(ip)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une adresse IP valide.')),
      );
      return;
    }
    if (_selectedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner des fichiers à envoyer.')),
      );
      return;
    }
    // TODO: Implémenter la logique d'envoi direct à l'IP spécifiée
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Envoi de ${_selectedFiles.length} fichiers à $ip (simulé)')),
    );
  }

  void _addIpToFavorites(String ip) {
    if (ip.isEmpty || _favoriteIps.contains(ip)) return;
    setState(() {
      _favoriteIps.add(ip);
      // Ajouter le serveur aux serveurs découverts pour qu'il apparaisse dans l'onglet SCAN
      if (!_discoveredServers.any((s) => s.ipAddress == ip)) {
        _discoveredServers.add(DiscoveredServer(ipAddress: ip, name: 'Favori $ip', status: 'favorite'));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$ip ajouté aux favoris')),
    );
  }

  // --- Fonctions des boutons d'action du bas ---

  // Action pour le bouton principal (Envoyer / Retour)
  void _onMainActionButtonPressed() {
    if (_currentContentIndex == 3) { // Si on est sur l'écran "Détection Périmétrique"
      setState(() {
        _currentContentIndex = 2; // Revenir à l'onglet SCAN
        _tabController.animateTo(2); // Animer la TabBar vers l'onglet SCAN
      });
    } else if (_currentContentIndex == 2) { // Si on est sur l'onglet "SCAN"
      if (_selectedFiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner des fichiers à envoyer.')),
        );
        return;
      }
      // TODO: Envoyer les fichiers au serveur sélectionné dans la liste des serveurs découverts
      // (Nécessite d'avoir un état pour le serveur sélectionné dans ScanTabContent)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Envoi de ${_selectedFiles.length} fichiers au serveur choisi (simulé)')),
      );
    }
  }

  // Action pour le bouton secondaire (Détection / Rafraîchir Proximité)
  void _onSecondaryActionButtonPressed() {
    if (_currentContentIndex == 2) { // Si on est sur l'onglet "SCAN"
      setState(() {
        _currentContentIndex = 3; // Passer à l'écran "Détection Périmétrique"
      });
      // TODO: Activer le capteur de mouvement ou le scan de proximité
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Détection périmétrique activée (simulée)')),
      );
    } else if (_currentContentIndex == 3) { // Si on est déjà sur l'écran "Détection Périmétrique"
      // TODO: Rafraîchir la détection périmétrique ou relancer le scan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recherche de serveurs proches (rafraîchissement simulé)')),
      );
      setState(() {
        _currentDirectionAngle = (_currentDirectionAngle + 30) % 360; // Simuler un changement d'angle
        // Simuler un changement du nombre de serveurs proches
        _perimeterServers = [
          DiscoveredServer(ipAddress: '192.168.1.10', name: 'PC de Jean', status: 'active'),
          DiscoveredServer(ipAddress: '192.168.1.11', name: 'PC de Marie', status: 'active'),
          DiscoveredServer(ipAddress: '192.168.1.13', name: 'Portable', status: 'active'), // Un de plus
        ];
        _closestPerimeterServer = _perimeterServers.isNotEmpty ? _perimeterServers.first : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENVOI DE FICHIERS'), // Le style est dans ThemeData
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour au lieu du menu
          onPressed: () {
            Navigator.of(context).pop(); // Retour à l'écran précédent
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Afficher un menu contextuel pour l'écran d'envoi
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings_ethernet),
                      title: const Text('Paramètres réseau'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Naviguer vers les paramètres réseau
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Historique des transferts'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Naviguer vers l'historique des transferts
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: _currentContentIndex != 3
            ? CustomTabBarSecondary(tabs: _tabs, tabController: _tabController)
            : null, // Masque la TabBar en mode Détection Périmétrique
      ),
      body: _currentContentIndex == 3
          ? PerimeterDetectionContent(
              activeServersCount: _perimeterServers.length,
              closestServer: _closestPerimeterServer,
              currentDirectionAngle: _currentDirectionAngle,
            )
          : TabBarView(
              controller: _tabController,
              // physics: const NeverScrollableScrollPhysics(), // Empêche le balayage entre les onglets
              children: [
                FileSelectionTab(
                  selectedFiles: _selectedFiles,
                  onAddFile: _addFile,
                  onRemoveFile: _removeFile,
                ),
                IpAddressTab(
                  ipController: _ipController,
                  onSendToIpPressed: _sendFilesToIp,
                  onAddToFavorites: _addIpToFavorites,
                ),
                ScanTabContent(
                  discoveredServers: _discoveredServers,
                  onSelectServer: (server) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${server.name} sélectionné pour l\'envoi.')),
                    );
                    // TODO: Gérer la sélection du serveur pour l'envoi
                  },
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AnimatedOpacity(
        opacity: _isBottomButtonsVisible() ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Visibility(
          visible: _isBottomButtonsVisible(),
          child: BottomActionButtonsRow(
            onMainActionPressed: _onMainActionButtonPressed,
            onSecondaryActionPressed: _onSecondaryActionButtonPressed,
            mainActionLabel: _currentContentIndex == 3 ? 'RETOUR' : 'ENVOYER',
            mainActionIcon: _currentContentIndex == 3 ? Icons.arrow_back : Icons.upload_rounded,
            secondaryActionLabel: _currentContentIndex == 3 ? 'RAFRAÎCHIR' : 'DÉTECTION',
            secondaryActionIcon: _currentContentIndex == 3 ? Icons.refresh : Icons.vibration,
          ),
        ),
      ),
    );
  }
}