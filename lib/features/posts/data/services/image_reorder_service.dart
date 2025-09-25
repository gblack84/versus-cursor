import 'dart:io';

/// Pure image reorder service without UI dependencies
/// UI 의존성이 없는 순수한 이미지 재정렬 서비스
class ImageReorderService {
  /// Reorder images based on new ID order
  /// Returns reordered data as a result object
  static ReorderResult reorderImages({
    required List<File> files,
    required List<double> aspectRatios,
    required List<String> currentIds,
    required List<String> newOrder,
  }) {
    final reorderedFiles = <File>[];
    final reorderedRatios = <double>[];
    final reorderedIds = <String>[];

    // Reorder according to new order
    for (final newId in newOrder) {
      final oldIndex = currentIds.indexOf(newId);
      if (oldIndex != -1) {
        // Add file if exists
        if (oldIndex < files.length) {
          reorderedFiles.add(files[oldIndex]);
        }

        // Add aspect ratio if exists
        if (oldIndex < aspectRatios.length) {
          reorderedRatios.add(aspectRatios[oldIndex]);
        }

        // Add ID
        reorderedIds.add(newId);
      }
    }

    return ReorderResult(
      files: reorderedFiles,
      aspectRatios: reorderedRatios,
      ids: reorderedIds,
    );
  }

  /// Move image to a specific position
  static ReorderResult moveImageToPosition({
    required List<File> files,
    required List<double> aspectRatios,
    required List<String> ids,
    required int fromIndex,
    required int toIndex,
  }) {
    if (fromIndex < 0 || fromIndex >= files.length ||
        toIndex < 0 || toIndex >= files.length) {
      // Return unchanged if indices are invalid
      return ReorderResult(
        files: files,
        aspectRatios: aspectRatios,
        ids: ids,
      );
    }

    // Create mutable copies
    final newFiles = List<File>.from(files);
    final newRatios = List<double>.from(aspectRatios);
    final newIds = List<String>.from(ids);

    // Remove from original position
    final file = newFiles.removeAt(fromIndex);
    final ratio = fromIndex < newRatios.length
        ? newRatios.removeAt(fromIndex)
        : 1.0;
    final id = fromIndex < newIds.length
        ? newIds.removeAt(fromIndex)
        : '';

    // Insert at new position
    newFiles.insert(toIndex, file);
    if (fromIndex < aspectRatios.length) {
      newRatios.insert(toIndex, ratio);
    }
    if (fromIndex < ids.length && id.isNotEmpty) {
      newIds.insert(toIndex, id);
    }

    return ReorderResult(
      files: newFiles,
      aspectRatios: newRatios,
      ids: newIds,
    );
  }

  /// Remove image at specific index
  static ReorderResult removeImageAt({
    required List<File> files,
    required List<double> aspectRatios,
    required List<String> ids,
    required int index,
  }) {
    if (index < 0 || index >= files.length) {
      // Return unchanged if index is invalid
      return ReorderResult(
        files: files,
        aspectRatios: aspectRatios,
        ids: ids,
      );
    }

    // Create mutable copies
    final newFiles = List<File>.from(files)..removeAt(index);
    final newRatios = index < aspectRatios.length
        ? (List<double>.from(aspectRatios)..removeAt(index))
        : aspectRatios;
    final newIds = index < ids.length
        ? (List<String>.from(ids)..removeAt(index))
        : ids;

    return ReorderResult(
      files: newFiles,
      aspectRatios: newRatios,
      ids: newIds,
    );
  }
}

/// Result of image reordering operation
class ReorderResult {
  final List<File> files;
  final List<double> aspectRatios;
  final List<String> ids;

  const ReorderResult({
    required this.files,
    required this.aspectRatios,
    required this.ids,
  });

  /// Check if all lists have consistent length
  bool get isConsistent {
    return files.length == aspectRatios.length &&
           files.length == ids.length;
  }

  /// Get the count of items
  int get count => files.length;
}