class AppFile {
  final String name;
  final String size;
  final String path; // Chemin complet du fichier
  final String extension; // Extension du fichier pour l'icône
  final String type;
  // Vous pouvez ajouter d'autres propriétés comme la date, le type, etc.

  AppFile({
    required this.name,
    required this.size,
    required this.path,
    required this.extension, 
    required this.type,
  });
}