import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

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
}