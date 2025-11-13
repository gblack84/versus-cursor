import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pickle_mark_provider.g.dart';

/// PickleMarkWidget Riverpod Provider
///
/// **Migration**: AppModel → Riverpod 3.x Notifier (Phase 10)
/// - Empty model (no state)
/// - Used by: alertempty, phonemaximum, start_page, popup_timer_email
@riverpod
class PickleMark extends _$PickleMark {
  @override
  void build() {
    // Empty build - this widget has no state
    // Riverpod provider created for compatibility with parent models
  }
}
