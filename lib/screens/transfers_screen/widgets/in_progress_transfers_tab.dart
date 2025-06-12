import 'package:flutter/material.dart';
import 'package:shareapp/models/transfer_item.dart';
import 'package:shareapp/screens/transfers_screen/widgets/transfer_item_card.dart';

class InProgressTransfersTab extends StatelessWidget {
  final List<TransferItem> inProgressTransfers;

  const InProgressTransfersTab({
    super.key,
    required this.inProgressTransfers,
  });

  @override
  Widget build(BuildContext context) {
    if (inProgressTransfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun transfert en cours.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: inProgressTransfers.length,
      itemBuilder: (context, index) {
        final transfer = inProgressTransfers[index];
        return TransferItemCard(
          transfer: transfer,
          // Pas de bouton "Retirer" pour les transferts en cours/en attente, juste l'icône close
        );
      },
    );
  }
}