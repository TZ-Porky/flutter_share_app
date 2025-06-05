class AppConstants {
  static const String appName = 'Shake File Transfer';
  static const String serviceId = 'com.example.shake_file_transfer';
  
  // Shake detection constants
  static const double shakeThreshold = 2.7;
  static const int shakeSlopTimeMs = 500;
  static const int shakeCountResetTimeMs = 3000;
  
  // Nearby connections strategy
  static const String nearbyStrategy = 'P2P_STAR';
  
  // File size limits (5MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;
  
  // Supported file extensions
  static const List<String> supportedFileExtensions = [
    'pdf', 'jpg', 'jpeg', 'png', 'gif',
    'mp4', 'mov', 'avi', 'mp3', 'wav',
    'txt', 'doc', 'docx', 'xls', 'xlsx'
  ];
}
