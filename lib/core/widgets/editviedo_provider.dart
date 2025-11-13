import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/core_exports.dart';
import 'editviedo_state.dart';

part 'editviedo_provider.g.dart';

/// EditviedoWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
@riverpod
class Editviedo extends _$Editviedo {
  @override
  EditviedoState build() {
    return const EditviedoState();
  }

  /// Update uploaded video
  void updateVideo(AppUploadedFile? video) {
    state = state.copyWith(uploadedVideo: video);
  }

  /// Update start time
  void updateStartSec(double value) {
    state = state.copyWith(startSec: value);
  }

  /// Update end time
  void updateEndSec(double value) {
    state = state.copyWith(endSec: value);
  }

  /// Update slider 1 value
  void updateSlider1(double? value) {
    state = state.copyWith(sliderValue1: value);
  }

  /// Update slider 2 value
  void updateSlider2(double? value) {
    state = state.copyWith(sliderValue2: value);
  }
}
