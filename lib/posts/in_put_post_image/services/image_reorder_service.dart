import '/app_state.dart';

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
        final oldUrls = List<String>.from(appState.uploadImageA);
        final oldRatios = List<double>.from(appState.uploadImageAspectRatioA);
        final oldIds = List<String>.from(appState.assetEntityIdsA);
        
        // 새 순서대로 재배치
        appState.uploadImageA.clear();
        appState.uploadImageAspectRatioA.clear();
        appState.assetEntityIdsA.clear();
        
        for (final newId in newOrder) {
          final oldIndex = oldIds.indexOf(newId);
          if (oldIndex != -1) {
            appState.uploadImageA.add(oldUrls[oldIndex]);
            appState.uploadImageAspectRatioA.add(oldRatios[oldIndex]);
            appState.assetEntityIdsA.add(newId);
          }
        }
      } else {
        final oldUrls = List<String>.from(appState.uploadImageB);
        final oldRatios = List<double>.from(appState.uploadImageAspectRatioB);
        final oldIds = List<String>.from(appState.assetEntityIdsB);
        
        appState.uploadImageB.clear();
        appState.uploadImageAspectRatioB.clear();
        appState.assetEntityIdsB.clear();
        
        for (final newId in newOrder) {
          final oldIndex = oldIds.indexOf(newId);
          if (oldIndex != -1) {
            appState.uploadImageB.add(oldUrls[oldIndex]);
            appState.uploadImageAspectRatioB.add(oldRatios[oldIndex]);
            appState.assetEntityIdsB.add(newId);
          }
        }
      }
    });
  }
}