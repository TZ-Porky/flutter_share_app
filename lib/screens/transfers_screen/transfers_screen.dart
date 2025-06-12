import 'package:flutter/material.dart';
import 'package:shareapp/models/transfer_item.dart';
import 'package:shareapp/widgets/custom_tab_bar_secondary.dart'; // Réutilise la TabBar de l'AppBar
import 'package:shareapp/screens/transfers_screen/widgets/completed_transfers_tab.dart';
import 'package:shareapp/screens/transfers_screen/widgets/in_progress_transfers_tab.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['TERMINÉS', 'EN COURS'];

  // Données de test pour les transferts
  final List<TransferItem> _allTransfers = [
    TransferItem(
      id: '1',
      fileName: 'Rapport_Final.pdf',
      fileSize: '5.2 Mo',
      progress: 1.0,
      status: TransferStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    TransferItem(
      id: '2',
      fileName: 'Backup_Photos.zip',
      fileSize: '1.2 Go',
      progress: 0.75,
      status: TransferStatus.inProgress,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    TransferItem(
      id: '3',
      fileName: 'Nouvelle_Musique.mp3',
      fileSize: '8.5 Mo',
      progress: 1.0,
      status: TransferStatus.completed,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    TransferItem(
      id: '4',
      fileName: 'Application_Beta.apk',
      fileSize: '25.0 Mo',
      progress: 0.0, // En attente
      status: TransferStatus.pending,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    TransferItem(
      id: '5',
      fileName: 'Video_Vacances.mp4',
      fileSize: '500 Mo',
      progress: 0.0,
      status: TransferStatus.cancelled,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<TransferItem> get _completedTransfers => _allTransfers.where((item) => item.status == TransferStatus.completed).toList();
  List<TransferItem> get _inProgressTransfers => _allTransfers.where((item) => item.status == TransferStatus.inProgress || item.status == TransferStatus.pending).toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _removeTransfer(TransferItem item) {
    setState(() {
      _allTransfers.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transfert de ${item.fileName} retiré.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRANSFERT DES FICHIERS'), // Le style est dans ThemeData
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Icône de retour
          onPressed: () {
            Navigator.of(context).pop(); // Retour à l'écran précédent
          },
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
                      leading: const Icon(Icons.delete_forever),
                      title: const Text('Vider l\'historique'),
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _allTransfers.clear();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Historique des transferts vidé.')),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.sort),
                      title: const Text('Trier par...'),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Implémenter le tri
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: CustomTabBarSecondary(tabs: _tabs, tabController: _tabController), // La TabBar personnalisée
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CompletedTransfersTab(
            completedTransfers: _completedTransfers,
            onRemoveTransfer: _removeTransfer,
          ),
          InProgressTransfersTab(
            inProgressTransfers: _inProgressTransfers,
          ),
        ],
      ),
    );
  }
}