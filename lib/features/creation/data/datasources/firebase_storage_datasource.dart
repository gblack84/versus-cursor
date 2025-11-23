import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'interfaces/i_storage_datasource.dart';
import '/services/logging/logger_service.dart';

/// Firebase implementation of Storage DataSource
///
/// This is the ONLY place where Firebase Storage dependencies should exist
/// for the Creation feature, following Clean Architecture principles.
class FirebaseStorageDataSource implements IStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadImage(File file, String path) async {
    try {
      // Create a reference to the location you want to upload to
      final ref = _storage.ref().child(path);

      // Upload the file
      final uploadTask = await ref.putFile(file);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      Logger.error(
        'Error uploading image to Firebase Storage',
        error: e,
        tag: 'StorageDataSource',
      );
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<List<String>> uploadMultipleImages(
    List<File> files,
    String basePath,
  ) async {
    try {
      final uploadFutures = <Future<String>>[];

      for (int i = 0; i < files.length; i++) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '$basePath/image_${timestamp}_$i.jpg';
        uploadFutures.add(uploadImage(files[i], path));
      }

      // Upload all images in parallel
      final urls = await Future.wait(uploadFutures);
      return urls;
    } catch (e) {
      Logger.error(
        'Error uploading multiple images',
        error: e,
        tag: 'StorageDataSource',
      );
      throw Exception('Failed to upload multiple images: $e');
    }
  }

  @override
  Future<void> deleteImage(String url) async {
    try {
      // Get reference from URL
      final ref = _storage.refFromURL(url);

      // Delete the file
      await ref.delete();
    } catch (e) {
      Logger.error(
        'Error deleting image from Firebase Storage',
        error: e,
        tag: 'StorageDataSource',
      );
      // Don't throw error for delete operations - log and continue
      // This prevents issues when the file doesn't exist
    }
  }

  @override
  Future<void> deleteMultipleImages(List<String> urls) async {
    try {
      final deleteFutures = <Future<void>>[];

      for (final url in urls) {
        deleteFutures.add(deleteImage(url));
      }

      // Delete all images in parallel
      await Future.wait(deleteFutures);
    } catch (e) {
      Logger.error(
        'Error deleting multiple images',
        error: e,
        tag: 'StorageDataSource',
      );
      // Don't throw error for delete operations
    }
  }

  @override
  Future<String> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      Logger.error(
        'Error getting download URL',
        error: e,
        tag: 'StorageDataSource',
      );
      throw Exception('Failed to get download URL: $e');
    }
  }

  @override
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getMetadata(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final metadata = await ref.getMetadata();

      return {
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated?.toIso8601String(),
        'updated': metadata.updated?.toIso8601String(),
        'name': metadata.name,
        'fullPath': metadata.fullPath,
        'customMetadata': metadata.customMetadata,
      };
    } catch (e) {
      Logger.error(
        'Error getting metadata',
        error: e,
        tag: 'StorageDataSource',
      );
      throw Exception('Failed to get metadata: $e');
    }
  }
}
