import 'package:flutter/foundation.dart';
import '/core/errors/failures.dart';

/// Base mixin for List-based Providers with common functionality
///
/// Provides shared utilities for:
/// - Loading state management
/// - Error handling
/// - Failure message mapping
///
/// Usage:
/// ```dart
/// class MyProvider extends ChangeNotifier with BaseListMixin<MyLoadingState, PostDisplay> {
///   MyLoadingState _loadingState = MyLoadingState.initial;
///
///   @override
///   MyLoadingState get loadingState => _loadingState;
///
///   @override
///   void setLoadingState(MyLoadingState state) {
///     _loadingState = state;
///     notifyListeners();
///   }
/// }
/// ```
mixin BaseListMixin<TState extends Enum, TModel> on ChangeNotifier {
  String? _errorMessage;

  /// Current error message (if any)
  String? get errorMessage => _errorMessage;

  /// Current loading state (must be implemented by concrete class)
  TState get loadingState;

  /// Set loading state and notify listeners
  void setLoadingState(TState state);

  /// Handle error from UseCase Result
  void handleError(Failure failure, TState errorState) {
    _errorMessage = getFailureMessage(failure);
    setLoadingState(errorState);
  }

  /// Handle stream error
  void handleStreamError(Failure failure, {bool updateState = false, TState? errorState}) {
    debugPrint('Stream error: ${failure.message}');
    _errorMessage = '실시간 업데이트 오류: ${failure.message}';

    if (updateState && errorState != null) {
      setLoadingState(errorState);
    } else {
      notifyListeners();
    }
  }

  /// Map Failure to user-friendly message
  String getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return '서버 오류: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return '네트워크 연결을 확인해주세요.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return failure.message;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
