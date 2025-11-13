import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/core/types/uploaded_file.dart';
import 'character_detail_page_state.dart';

part 'character_detail_page_provider.g.dart';

/// CharacterDetailPage Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class CharacterDetailPage extends _$CharacterDetailPage {
  @override
  CharacterDetailPageState build() {
    return CharacterDetailPageState.initial();
  }

  /// Update selected character ID
  void updateSelectedCharacterId(String? characterId) {
    state = state.copyWith(selectedCharacterId: characterId);
  }

  /// Update selected character profile image URL
  void updateSelectedCharacterUrl(String url) {
    state = state.copyWith(selectedCharacterUrl: url);
  }

  /// Update upload progress flag
  void updateUploadProgress(bool isUploading) {
    state = state.copyWith(isDataUploading: isUploading);
  }

  /// Update uploaded local file
  void updateUploadedLocalFile(AppUploadedFile file) {
    state = state.copyWith(uploadedLocalFile: file);
  }

  /// Update uploaded file URL
  void updateUploadedFileUrl(String url) {
    state = state.copyWith(uploadedFileUrl: url);
  }

  /// Reset upload state
  void resetUploadState() {
    state = state.copyWith(
      isDataUploading: false,
      uploadedLocalFile: null,
      uploadedFileUrl: '',
    );
  }
}
