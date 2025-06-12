import 'package:flutter/material.dart';
import 'package:shareapp/models/app_file.dart';
import 'package:shareapp/screens/receive_screen/receive_screen.dart';
import 'package:shareapp/screens/send_files_screen/send_files_screen.dart';
import 'package:shareapp/widgets/action_buttons_fab.dart';
import 'package:shareapp/widgets/custom_tab_bar.dart';
import 'package:shareapp/widgets/file_item_card.dart';
import 'package:shareapp/widgets/search_input_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _tabs = [
    'HISTORIQUE',
    'FICHIERS',
    'IMAGES',
    'VIDEOS',
    'MUSIQUE',
    'APPS',
    'DOCS',
  ];

  final List<AppFile> _allFiles = [
    AppFile(name: 'Rapport Annuel 2024.pdf', size: '2.5 Mo', path: '/docs/rapport.pdf', extension: 'pdf', type: 'DOCS'),
    AppFile(name: 'Vacances Bali.jpg', size: '1.2 Mo', path: '/images/bali.jpg', extension: 'jpg', type: 'IMAGES'),
    AppFile(name: 'Musique Chill.mp3', size: '5.8 Mo', path: '/music/chill.mp3', extension: 'mp3', type: 'MUSIQUE'),
    AppFile(name: 'Installation App.apk', size: '45.0 Mo', path: '/apps/app.apk', extension: 'apk', type: 'APPS'),
    AppFile(name: 'Présentation Projet.pptx', size: '10.1 Mo', path: '/docs/projet.pptx', extension: 'pptx', type: 'DOCS'),
    AppFile(name: 'Archives Ancien Projet.zip', size: '300 Mo', path: '/archives/projet.zip', extension: 'zip', type: 'FICHIERS'),
    AppFile(name: 'Film d\'Action.mp4', size: '1.5 Go', path: '/videos/film.mp4', extension: 'mp4', type: 'VIDEOS'),
    AppFile(name: 'Document Word.docx', size: '800 Ko', path: '/docs/doc.docx', extension: 'docx', type: 'DOCS'),
  ];

  late List<AppFile> _filteredFiles;
  final TextEditingController _searchController = TextEditingController();
  bool _showActionButtons = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _filteredFiles = List.from(_allFiles);
    _searchController.addListener(_onSearchChanged);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _filterFiles();
    }
  }

  void _onSearchChanged() {
    _filterFiles();
  }

  void _filterFiles() {
    final query = _searchController.text.toLowerCase();
    final currentTab = _tabs[_tabController.index];

    setState(() {
      _filteredFiles = _allFiles.where((file) {
        final matchesSearch = query.isEmpty ||
            file.name.toLowerCase().contains(query) ||
            file.extension.toLowerCase().contains(query);
        
        final matchesTab = currentTab == 'HISTORIQUE' || 
            currentTab == 'FICHIERS' || // On affiche tout pour ces onglets génériques
            file.type == currentTab;
        
        return matchesSearch && matchesTab;
      }).toList();
    });
  }

  void _toggleActionButtons() {
    setState(() => _showActionButtons = !_showActionButtons);
  }

  void _handleFileOpen(AppFile file) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ouverture de ${file.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
            child: const Text(
              'RapidBytes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers le profil
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers les paramètres
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Stockage'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers le stockage
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Aide & Support'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Naviguer vers l'aide
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.lightBlue,
        title: const Text(
          'RapidBytes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(), // Modification ici
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('À propos'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Afficher about dialog
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.desktop_mac_outlined),
                      title: const Text('Se connecter à un PC'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Gérer la déconnexion
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.devices_other),
                      title: const Text('Se connecter à un autre appareil'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Gérer la déconnexion
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SearchInputField(
            hintText: 'Rechercher des fichiers locaux...',
            controller: _searchController,
          ),
          CustomTabBar(tabs: _tabs, tabController: _tabController),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                return _filteredFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.folder_open, size: 50, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun fichier trouvé',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredFiles.length,
                        itemBuilder: (context, index) {
                          final file = _filteredFiles[index];
                          return FileItemCard(
                            file: file,
                            onOpen: () => _handleFileOpen(file),
                          );
                        },
                      );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_showActionButtons) ...[
            ActionFabButton(
              icon: Icons.upload,
              label: 'ENVOYER',
              onPressed: () {
                _toggleActionButtons();
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendFilesScreen()),
                );
              },
            ),
            const SizedBox(height: 10.0),
            ActionFabButton(
              icon: Icons.download,
              label: 'RECEVOIR',
              onPressed: () {
                _toggleActionButtons();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReceiveScreen()),
                );
              },
            ),
            const SizedBox(height: 10.0),
          ],
          FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            heroTag: 'mainShareFab',
            onPressed: _toggleActionButtons,
            child: Icon(
              _showActionButtons ? Icons.close : Icons.offline_share_rounded,
              size: 30,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}