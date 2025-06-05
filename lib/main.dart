import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_page.dart';
import 'receive_page.dart';
import 'send_page.dart'; // Nous allons créer ce fichier


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Xender',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/send': (context) => const SendPage(),
        '/receive': (context) => const ReceivePage(),
      },
    );
  }
}
