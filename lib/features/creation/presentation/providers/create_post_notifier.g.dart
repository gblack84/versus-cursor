// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_post_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create Post Notifier - Riverpod 3.x (Phase 2-11)
///
/// **마이그레이션**: CreatePostProviderV2 (ChangeNotifier) → CreatePostNotifier (Riverpod)
///
/// **상태 관리**: CreatePostState (Freezed, immutable)
/// **비즈니스 로직**: UseCases를 통한 Clean Architecture 패턴
/// **미디어 처리**: MediaStateCoordinator → 직접 Notifier 접근으로 리팩토링
///
/// **주요 변경사항**:
/// - ChangeNotifier → Riverpod Notifier
/// - `notifyListeners()` → `state = state.copyWith(...)`
/// - GetIt dependency injection → `ref.read()` / `ref.watch()`
/// - MediaStateCoordinator → 개별 Media Notifier 직접 사용

@ProviderFor(CreatePost)
const createPostProvider = CreatePostProvider._();

/// Create Post Notifier - Riverpod 3.x (Phase 2-11)
///
/// **마이그레이션**: CreatePostProviderV2 (ChangeNotifier) → CreatePostNotifier (Riverpod)
///
/// **상태 관리**: CreatePostState (Freezed, immutable)
/// **비즈니스 로직**: UseCases를 통한 Clean Architecture 패턴
/// **미디어 처리**: MediaStateCoordinator → 직접 Notifier 접근으로 리팩토링
///
/// **주요 변경사항**:
/// - ChangeNotifier → Riverpod Notifier
/// - `notifyListeners()` → `state = state.copyWith(...)`
/// - GetIt dependency injection → `ref.read()` / `ref.watch()`
/// - MediaStateCoordinator → 개별 Media Notifier 직접 사용
final class CreatePostProvider
    extends $NotifierProvider<CreatePost, CreatePostState> {
  /// Create Post Notifier - Riverpod 3.x (Phase 2-11)
  ///
  /// **마이그레이션**: CreatePostProviderV2 (ChangeNotifier) → CreatePostNotifier (Riverpod)
  ///
  /// **상태 관리**: CreatePostState (Freezed, immutable)
  /// **비즈니스 로직**: UseCases를 통한 Clean Architecture 패턴
  /// **미디어 처리**: MediaStateCoordinator → 직접 Notifier 접근으로 리팩토링
  ///
  /// **주요 변경사항**:
  /// - ChangeNotifier → Riverpod Notifier
  /// - `notifyListeners()` → `state = state.copyWith(...)`
  /// - GetIt dependency injection → `ref.read()` / `ref.watch()`
  /// - MediaStateCoordinator → 개별 Media Notifier 직접 사용
  const CreatePostProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostHash();

  @$internal
  @override
  CreatePost create() => CreatePost();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostState>(value),
    );
  }
}

String _$createPostHash() => r'a32ad4dfe13afa491e36427e82a0c5a881bd8259';

/// Create Post Notifier - Riverpod 3.x (Phase 2-11)
///
/// **마이그레이션**: CreatePostProviderV2 (ChangeNotifier) → CreatePostNotifier (Riverpod)
///
/// **상태 관리**: CreatePostState (Freezed, immutable)
/// **비즈니스 로직**: UseCases를 통한 Clean Architecture 패턴
/// **미디어 처리**: MediaStateCoordinator → 직접 Notifier 접근으로 리팩토링
///
/// **주요 변경사항**:
/// - ChangeNotifier → Riverpod Notifier
/// - `notifyListeners()` → `state = state.copyWith(...)`
/// - GetIt dependency injection → `ref.read()` / `ref.watch()`
/// - MediaStateCoordinator → 개별 Media Notifier 직접 사용

abstract class _$CreatePost extends $Notifier<CreatePostState> {
  CreatePostState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CreatePostState, CreatePostState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreatePostState, CreatePostState>,
              CreatePostState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
