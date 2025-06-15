import 'package:flutter/material.dart';
import 'package:shareapp/saves/home_page.dart';
import 'package:shareapp/screens/home_screen.dart'; // Assurez-vous que le chemin est correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      showSemanticsDebugger: false,
      title: 'RapidBytes', // Nom de votre application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Définir un primarySwatch
        primaryColor: Colors.lightBlue, // Couleur primaire exacte de l'AppBar de HomeScreen
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.lightBlue, // AppBar de couleur bleue claire
          elevation: 0, // Pas d'ombre
          foregroundColor: Colors.white, // Texte et icônes de l'AppBar en blanc
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightBlue, // Couleur des FABs
          foregroundColor: Colors.white, // Couleur de l'icône sur les FABs
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Pour les FABs ronds ou pill-shaped
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlue, // Fond bleu clair pour les ElevatedButton
            foregroundColor: Colors.white, // Texte blanc pour les ElevatedButton
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rayon des coins
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red, // Pour le bouton "Retirer"
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Coins arrondis pour les Card
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[200], // Couleur de fond pour TextField
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Coins arrondis pour TextField
            borderSide: BorderSide.none, // Pas de bordure visible
          ),
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white, // Couleur du label de l'onglet sélectionné
          unselectedLabelColor: Colors.white.withOpacity(0.7), // Couleur des labels non sélectionnés
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 3.0), // Indicateur blanc et plus épais
          ),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
        ),
        // Ajoutez d'autres styles comme TextStyle, IconThemeData, etc. si nécessaire
      ),
      home: const HomePage(),
    );
  }
}