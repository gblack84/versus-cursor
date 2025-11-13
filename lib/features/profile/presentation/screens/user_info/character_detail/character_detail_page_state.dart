import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/uploaded_file.dart';
import 'package:flutter/foundation.dart';

part 'character_detail_page_state.freezed.dart';

/// CharacterDetailPageWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class CharacterDetailPageState with _$CharacterDetailPageState {
  const CharacterDetailPageState._();

  const factory CharacterDetailPageState({
    /// Selected character ID
    String? selectedCharacterId,

    /// Selected character profile image URL
    @Default('\" \"') String selectedCharacterUrl,

    /// Upload progress flag for profile image
    @Default(false) bool isDataUploading,

    /// Uploaded local file (profile image)
    AppUploadedFile? uploadedLocalFile,

    /// Uploaded file URL (Firebase Storage)
    @Default('') String uploadedFileUrl,
  }) = _CharacterDetailPageState;

  /// Initial state factory
  factory CharacterDetailPageState.initial() =>
      const CharacterDetailPageState();
}
