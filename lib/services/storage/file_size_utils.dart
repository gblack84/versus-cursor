import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Utilities for calculating and formatting file sizes
class FileSizeUtils {
  static final FileSizeUtils _instance = FileSizeUtils._internal();
  factory FileSizeUtils() => _instance;
  FileSizeUtils._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get file size from local file path
  Future<int> getLocalFileSize(String localPath) async {
    try {
      final file = File(localPath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      // Error getting local file size - return 0
      return 0;
    }
  }

  /// Check if file size is within acceptable limits (default: 10MB)
  Future<bool> checkFileSize(File file, {int maxSizeInBytes = 10485760}) async {
    try {
      if (await file.exists()) {
        final size = await file.length();
        return size <= maxSizeInBytes;
      }
      return false;
    } catch (e) {
      // Error checking file size - return false
      return false;
    }
  }

  /// Get file size from Firebase Storage URL
  Future<int> getStorageFileSize(String url) async {
    try {
      // Extract storage path from URL
      final storagePath = extractStoragePathFromUrl(url);
      if (storagePath.isEmpty) {
        return 0;
      }

      // Get metadata from Firebase Storage
      final ref = _storage.ref(storagePath);
      final metadata = await ref.getMetadata();
      return metadata.size ?? 0;
    } catch (e) {
      // Error getting storage file size - return 0
      return 0;
    }
  }

  /// Extract Firebase Storage path from URL
  /// Handles both gs:// URLs and https:// URLs
  String extractStoragePathFromUrl(String url) {
    try {
      // Handle gs:// URLs
      if (url.startsWith('gs://')) {
        final uri = Uri.parse(url);
        return uri.path.substring(1); // Remove leading slash
      }

      // Handle Firebase Storage HTTPS URLs
      if (url.contains('firebasestorage.googleapis.com')) {
        final uri = Uri.parse(url);
        final pathSegments = uri.pathSegments;

        // Find 'o' segment which indicates the start of the encoded path
        final oIndex = pathSegments.indexOf('o');
        if (oIndex != -1 && oIndex < pathSegments.length - 1) {
          // Get the encoded path and decode it
          final encodedPath = pathSegments[oIndex + 1];
          return Uri.decodeComponent(encodedPath);
        }
      }

      // Handle Firestore Storage download URLs with path in query params
      if (url.contains('storage.googleapis.com')) {
        // Extract path from the URL structure
        final match = RegExp(r'/b/[^/]+/o/(.+)\?').firstMatch(url);
        if (match != null) {
          return Uri.decodeComponent(match.group(1)!);
        }
      }

      return '';
    } catch (e) {
      // Error extracting storage path from URL - return empty string
      return '';
    }
  }

  /// Calculate size for a media message
  /// Tries to get size from Storage if URL is provided
  /// Falls back to 0 if size cannot be determined
  Future<int> calculateMediaSize(String? mediaUrl) async {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return 0;
    }

    // If it's a local file path
    if (!mediaUrl.startsWith('http') && !mediaUrl.startsWith('gs://')) {
      return await getLocalFileSize(mediaUrl);
    }

    // If it's a remote URL
    return await getStorageFileSize(mediaUrl);
  }

  /// Get human-readable file size
  String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }
}
