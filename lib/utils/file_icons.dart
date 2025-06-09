// lib/utils/file_icons.dart
import 'package:flutter/material.dart';

IconData getFileIcon(String extension) {
  switch (extension.toLowerCase()) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
      return Icons.image;
    case 'mp3':
    case 'wav':
    case 'aac':
      return Icons.music_note;
    case 'mp4':
    case 'avi':
    case 'mkv':
      return Icons.movie;
    case 'zip':
    case 'rar':
    case '7z':
      return Icons.folder_zip;
    case 'apk':
      return Icons.android;
    default:
      return Icons.insert_drive_file; // Icône par défaut pour les fichiers inconnus
  }
}