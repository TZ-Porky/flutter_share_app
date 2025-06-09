// lib/screens/send_files_screen/widgets/ip_address_tab.dart
import 'package:flutter/material.dart';

class IpAddressTab extends StatefulWidget {
  final TextEditingController ipController;
  final Function(String ip) onSendToIpPressed;
  final Function(String ip) onAddToFavorites;

  const IpAddressTab({
    super.key,
    required this.ipController,
    required this.onSendToIpPressed,
    required this.onAddToFavorites,
  });

  @override
  State<IpAddressTab> createState() => _IpAddressTabState();
}

class _IpAddressTabState extends State<IpAddressTab> {
  // L'état de favori devrait idéalement être géré par un modèle ou un service
  // mais pour l'UI, un état local suffit si ce n'est que visuel immédiat.
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Entrez l\'adresse IP du destinataire :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: widget.ipController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'ex: 192.168.1.100',
              prefixIcon: const Icon(Icons.network_check, color: Colors.grey),
              suffixIcon: IconButton(
                icon: Icon(
                  _isFavorite ? Icons.star : Icons.star_border,
                  color: _isFavorite ? Colors.amber : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                  if (widget.ipController.text.isNotEmpty) {
                    widget.onAddToFavorites(widget.ipController.text);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: () => widget.onSendToIpPressed(widget.ipController.text),
            icon: const Icon(Icons.send),
            label: const Text('Envoyer le fichier'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
          ),
          const SizedBox(height: 24.0),
          Divider(color: Colors.grey[300]),
          const SizedBox(height: 24.0),
          Center(
            child: Text(
              'Les IP ajoutées en favoris apparaîtront dans l\'onglet SCAN.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          )
        ],
      ),
    );
  }
}