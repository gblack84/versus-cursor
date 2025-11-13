import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/uploaded_file.dart';

part 'editviedo_state.freezed.dart';

/// EditviedoWidget State
///
/// **Migration**: AppModel → Riverpod 3.x Notifier + Freezed (Phase 10)
@freezed
sealed class EditviedoState with _$EditviedoState {
  const EditviedoState._();

  const factory EditviedoState({
    /// Uploaded video file
    AppUploadedFile? uploadedVideo,

    /// Video start time in seconds
    @Default(0.0) double startSec,

    /// Video end time in seconds
    @Default(60.0) double endSec,

    /// Slider 1 value (start time slider)
    double? sliderValue1,

    /// Slider 2 value (end time slider)
    double? sliderValue2,
  }) = _EditviedoState;
}
