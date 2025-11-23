import 'dart:io';

/// Interface for Storage operations
///
/// This interface defines the contract for storage operations,
/// allowing the domain layer to remain independent of Firebase Storage.
abstract class IStorageDataSource {
  /// Upload a single image to storage
  ///
  /// [file] The image file to upload
  /// [path] The storage path where the file will be stored
  /// Returns the download URL of the uploaded image
  Future<String> uploadImage(File file, String path);

  /// Upload multiple images to storage
  ///
  /// [files] List of image files to upload
  /// [basePath] The base storage path for all files
  /// Returns list of download URLs for the uploaded images
  Future<List<String>> uploadMultipleImages(List<File> files, String basePath);

  /// Delete an image from storage
  ///
  /// [url] The storage URL of the image to delete
  Future<void> deleteImage(String url);

  /// Delete multiple images from storage
  ///
  /// [urls] List of storage URLs to delete
  Future<void> deleteMultipleImages(List<String> urls);

  /// Get download URL for a storage path
  ///
  /// [path] The storage path
  /// Returns the download URL
  Future<String> getDownloadUrl(String path);

  /// Check if a file exists in storage
  ///
  /// [path] The storage path to check
  /// Returns true if the file exists
  Future<bool> fileExists(String path);

  /// Get file metadata
  ///
  /// [path] The storage path
  /// Returns metadata as a map
  Future<Map<String, dynamic>> getMetadata(String path);
}
