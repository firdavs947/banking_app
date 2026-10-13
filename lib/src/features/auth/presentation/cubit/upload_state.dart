import 'dart:io';

enum UploadStatus { initial, loading, error, success }

class UploadState {
  final UploadStatus status;
  final File? image;

  const UploadState({required this.status, this.image});
}