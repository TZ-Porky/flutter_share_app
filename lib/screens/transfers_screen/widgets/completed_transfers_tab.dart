import 'package:flutter/material.dart';
import 'package:shareapp/models/transfer_item.dart';
import 'package:shareapp/screens/transfers_screen/widgets/transfer_item_card.dart';

class CompletedTransfersTab extends StatelessWidget {
  final List<TransferItem> completedTransfers;
  final Function(TransferItem)? onRemoveTransfer;

  const CompletedTransfersTab({
    super.key,
    required this.completedTransfers,
    this.onRemoveTransfer,
  });

  @override
  Widget build(BuildContext context) {
    if (completedTransfers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun transfert terminé.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: completedTransfers.length,
      itemBuilder: (context, index) {
        final transfer = completedTransfers[index];
        return TransferItemCard(
          transfer: transfer,
          onRemove: onRemoveTransfer != null ? () => onRemoveTransfer!(transfer) : null,
        );
      },
    );
  }
}