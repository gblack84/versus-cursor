/// Image Upload Metadata Model
///
/// Simplified metadata for image upload operations.
/// Complements the comprehensive ImageMetadata entity.
///
/// Created: 2025-09-05
/// Author: CodeSurgeon

import 'package:flutter/foundation.dart';

/// Metadata associated with an image upload
@immutable
class ImageUploadMetadata {
  const ImageUploadMetadata({
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    this.uploadedBy,
    this.source,
    this.deviceInfo,
    this.additionalData,
  });

  /// Factory constructor with current timestamp
  factory ImageUploadMetadata.create({
    required String fileName,
    required int fileSize,
    required String mimeType,
    String? uploadedBy,
    String? source,
    String? deviceInfo,
    Map<String, dynamic>? additionalData,
  }) {
    return ImageUploadMetadata(
      fileName: fileName,
      fileSize: fileSize,
      mimeType: mimeType,
      uploadedAt: DateTime.now(),
      uploadedBy: uploadedBy,
      source: source,
      deviceInfo: deviceInfo,
      additionalData: additionalData,
    );
  }

  /// Create from map
  factory ImageUploadMetadata.fromMap(Map<String, dynamic> map) {
    return ImageUploadMetadata(
      fileName: map['fileName'] as String,
      fileSize: map['fileSize'] as int,
      mimeType: map['mimeType'] as String,
      uploadedAt: DateTime.parse(map['uploadedAt'] as String),
      uploadedBy: map['uploadedBy'] as String?,
      source: map['source'] as String?,
      deviceInfo: map['deviceInfo'] as String?,
      additionalData: map['additionalData'] as Map<String, dynamic>?,
    );
  }

  /// Original file name
  final String fileName;

  /// File size in bytes
  final int fileSize;

  /// MIME type (e.g., 'image/jpeg')
  final String mimeType;

  /// Upload timestamp
  final DateTime uploadedAt;

  /// User ID who uploaded the image
  final String? uploadedBy;

  /// Upload source (e.g., 'camera', 'gallery', 'web')
  final String? source;

  /// Device information
  final String? deviceInfo;

  /// Additional metadata
  final Map<String, dynamic>? additionalData;

  /// Get formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get file extension from name
  String? get fileExtension {
    final lastDot = fileName.lastIndexOf('.');
    if (lastDot != -1 && lastDot < fileName.length - 1) {
      return fileName.substring(lastDot + 1).toLowerCase();
    }
    return null;
  }

  /// Check if the file is an image based on MIME type
  bool get isImage => mimeType.startsWith('image/');

  /// Check if the file is a supported image format
  bool get isSupportedImageFormat {
    const supportedFormats = [
      'image/jpeg',
      'image/jpg',
      'image/png',
      'image/gif',
      'image/webp',
      'image/bmp',
    ];
    return supportedFormats.contains(mimeType.toLowerCase());
  }

  /// Copy with method
  ImageUploadMetadata copyWith({
    String? fileName,
    int? fileSize,
    String? mimeType,
    DateTime? uploadedAt,
    String? uploadedBy,
    String? source,
    String? deviceInfo,
    Map<String, dynamic>? additionalData,
  }) {
    return ImageUploadMetadata(
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      source: source ?? this.source,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  /// Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'uploadedAt': uploadedAt.toIso8601String(),
      if (uploadedBy != null) 'uploadedBy': uploadedBy,
      if (source != null) 'source': source,
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
      if (additionalData != null) 'additionalData': additionalData,
    };
  }

  @override
  String toString() {
    return 'ImageUploadMetadata('
        'fileName: $fileName, '
        'size: $formattedFileSize, '
        'type: $mimeType, '
        'uploaded: ${uploadedAt.toIso8601String()}'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ImageUploadMetadata &&
        other.fileName == fileName &&
        other.fileSize == fileSize &&
        other.mimeType == mimeType &&
        other.uploadedAt == uploadedAt;
  }

  @override
  int get hashCode {
    return fileName.hashCode ^
        fileSize.hashCode ^
        mimeType.hashCode ^
        uploadedAt.hashCode;
  }
}
