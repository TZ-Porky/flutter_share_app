class TransferResult {
  final bool success;
  final String message;
  final String? fileName;
  final int? fileSize;

  TransferResult({
    required this.success,
    required this.message,
    this.fileName,
    this.fileSize,
  });

  @override
  String toString() {
    return 'TransferResult(success: $success, message: $message, fileName: $fileName, fileSize: $fileSize)';
  }
}