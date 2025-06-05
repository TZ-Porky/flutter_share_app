import 'package:flutter/material.dart';
import '/screens/receive_screen.dart';
import '/screens/send_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake File Transfer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SendScreen()),
                );
              },
              child: const Text('Envoyer un fichier'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReceiveScreen()),
                );
              },
              child: const Text('Recevoir un fichier'),
            ),
          ],
        ),
      ),
    );
  }
}