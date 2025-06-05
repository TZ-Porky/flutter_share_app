import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart'; // Importez le package open_filex

class FileService {
  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  Future<Directory> getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // getExternalStorageDirectory() est préféré pour les téléchargements sur Android
      return await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<File> saveReceivedFile(String filePath) async {
    final directory = await getDownloadDirectory();
    final fileName = filePath.split('/').last;
    final newPath = '${directory.path}/$fileName';
    
    return await File(filePath).copy(newPath);
  }

  // Nouvelle méthode pour ouvrir un fichier
  Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }
}