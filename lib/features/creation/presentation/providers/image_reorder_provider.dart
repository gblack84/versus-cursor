import 'package:flutter/material.dart';
import '/app/state/app_state.dart';
import '../../data/services/image_reorder_service.dart';

/// Provider that bridges ImageReorderService with UI state
/// ImageReorderService와 UI 상태를 연결하는 프로바이더
class ImageReorderProvider extends ChangeNotifier {
  final AppState appState;

  ImageReorderProvider({required this.appState});

  /// Reorder images based on new ID order
  void reorderImages({
    required String box,
    required List<String> newOrder,
  }) {
    appState.update(() {
      if (box == 'A') {
        // Get current state
        final result = ImageReorderService.reorderImages(
          files: appState.tempImageFilesA,
          aspectRatios: appState.uploadImageAspectRatioA,
          currentIds: appState.assetEntityIdsA,
          newOrder: newOrder,
        );

        // Update AppState with reordered data
        appState.tempImageFilesA = result.files;
        appState.uploadImageAspectRatioA = result.aspectRatios;
        appState.assetEntityIdsA = result.ids;
      } else {
        // Get current state
        final result = ImageReorderService.reorderImages(
          files: appState.tempImageFilesB,
          aspectRatios: appState.uploadImageAspectRatioB,
          currentIds: appState.assetEntityIdsB,
          newOrder: newOrder,
        );

        // Update AppState with reordered data
        appState.tempImageFilesB = result.files;
        appState.uploadImageAspectRatioB = result.aspectRatios;
        appState.assetEntityIdsB = result.ids;
      }
    });

    notifyListeners();
  }

  /// Move image to a specific position
  void moveImageToPosition({
    required String box,
    required int fromIndex,
    required int toIndex,
  }) {
    appState.update(() {
      if (box == 'A') {
        final result = ImageReorderService.moveImageToPosition(
          files: appState.tempImageFilesA,
          aspectRatios: appState.uploadImageAspectRatioA,
          ids: appState.assetEntityIdsA,
          fromIndex: fromIndex,
          toIndex: toIndex,
        );

        appState.tempImageFilesA = result.files;
        appState.uploadImageAspectRatioA = result.aspectRatios;
        appState.assetEntityIdsA = result.ids;
      } else {
        final result = ImageReorderService.moveImageToPosition(
          files: appState.tempImageFilesB,
          aspectRatios: appState.uploadImageAspectRatioB,
          ids: appState.assetEntityIdsB,
          fromIndex: fromIndex,
          toIndex: toIndex,
        );

        appState.tempImageFilesB = result.files;
        appState.uploadImageAspectRatioB = result.aspectRatios;
        appState.assetEntityIdsB = result.ids;
      }
    });

    notifyListeners();
  }

  /// Remove image at specific index
  void removeImageAt({
    required String box,
    required int index,
  }) {
    appState.update(() {
      if (box == 'A') {
        final result = ImageReorderService.removeImageAt(
          files: appState.tempImageFilesA,
          aspectRatios: appState.uploadImageAspectRatioA,
          ids: appState.assetEntityIdsA,
          index: index,
        );

        appState.tempImageFilesA = result.files;
        appState.uploadImageAspectRatioA = result.aspectRatios;
        appState.assetEntityIdsA = result.ids;
      } else {
        final result = ImageReorderService.removeImageAt(
          files: appState.tempImageFilesB,
          aspectRatios: appState.uploadImageAspectRatioB,
          ids: appState.assetEntityIdsB,
          index: index,
        );

        appState.tempImageFilesB = result.files;
        appState.uploadImageAspectRatioB = result.aspectRatios;
        appState.assetEntityIdsB = result.ids;
      }
    });

    notifyListeners();
  }

  /// Move selected image to front (make it primary/thumbnail)
  void moveImageToFront({
    required String box,
    required int currentIndex,
  }) {
    moveImageToPosition(
      box: box,
      fromIndex: currentIndex,
      toIndex: 0,
    );
  }

  /// Get current image count for a box
  int getImageCount(String box) {
    if (box == 'A') {
      return appState.tempImageFilesA.length;
    } else {
      return appState.tempImageFilesB.length;
    }
  }

  /// Check if reordering is possible
  bool canReorder(String box) {
    return getImageCount(box) > 1;
  }

  /// Swap images between two positions
  void swapImages({
    required String box,
    required int index1,
    required int index2,
  }) {
    if (index1 == index2) return;

    // Move first to temp position beyond list
    final tempIndex = getImageCount(box);

    // First move index1 to end
    moveImageToPosition(
      box: box,
      fromIndex: index1,
      toIndex: tempIndex - 1,
    );

    // Then move index2 to index1's original position
    final newIndex2 = index1 < index2 ? index2 - 1 : index2;
    moveImageToPosition(
      box: box,
      fromIndex: newIndex2,
      toIndex: index1,
    );

    // Finally move the item from end to index2's original position
    moveImageToPosition(
      box: box,
      fromIndex: tempIndex - 1,
      toIndex: index2,
    );
  }
}