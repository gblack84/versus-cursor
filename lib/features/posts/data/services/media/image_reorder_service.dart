import 'dart:io';
import '/app/state/app_state.dart';

/// 이미지 순서 재정렬 서비스
class ImageReorderService {
  /// 이미지 순서 재정렬
  static void reorderImages({
    required AppState appState,
    required String box,
    required List<String> newOrder,
  }) {
    appState.update(() {
      if (box == 'A') {
        final oldFiles = List<File>.from(appState.tempImageFilesA);
        final oldRatios = List<double>.from(appState.uploadImageAspectRatioA);
        final oldIds = List<String>.from(appState.assetEntityIdsA);
        
        // 새 순서대로 재배치
        appState.tempImageFilesA.clear();
        appState.uploadImageAspectRatioA.clear();
        appState.assetEntityIdsA.clear();
        
        for (final newId in newOrder) {
          final oldIndex = oldIds.indexOf(newId);
          if (oldIndex != -1 && oldIndex < oldFiles.length) {
            appState.tempImageFilesA.add(oldFiles[oldIndex]);
            if (oldIndex < oldRatios.length) {
              appState.uploadImageAspectRatioA.add(oldRatios[oldIndex]);
            }
            appState.assetEntityIdsA.add(newId);
          }
        }
      } else {
        final oldFiles = List<File>.from(appState.tempImageFilesB);
        final oldRatios = List<double>.from(appState.uploadImageAspectRatioB);
        final oldIds = List<String>.from(appState.assetEntityIdsB);
        
        appState.tempImageFilesB.clear();
        appState.uploadImageAspectRatioB.clear();
        appState.assetEntityIdsB.clear();
        
        for (final newId in newOrder) {
          final oldIndex = oldIds.indexOf(newId);
          if (oldIndex != -1 && oldIndex < oldFiles.length) {
            appState.tempImageFilesB.add(oldFiles[oldIndex]);
            if (oldIndex < oldRatios.length) {
              appState.uploadImageAspectRatioB.add(oldRatios[oldIndex]);
            }
            appState.assetEntityIdsB.add(newId);
          }
        }
      }
    });
  }
}