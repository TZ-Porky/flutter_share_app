import 'package:flutter/material.dart';
import 'file_selection_page.dart';
import 'receive_page.dart';
import 'send_page.dart'; // Nous allons créer ce fichier

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Accueil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("📤 Envoyer un fichier"),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SendPage()),
                  ),
            ),
            ElevatedButton(
              child: const Text("📥 Recevoir un fichier"),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceivePage()),
                  ),
            ),
            ElevatedButton(
              child: const Text("🛰️ Shake to Send"),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FileSelectionPage(),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
