// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// UseCase Providers for Creation Feature (Riverpod 3.x)
/// Phase 2-11: CreatePostProviderV2 마이그레이션을 위한 UseCase Provider 노출
///
/// GetIt에 등록된 UseCase들을 Riverpod Provider로 노출합니다.
/// 이를 통해 CreatePostNotifier가 ref.read()로 UseCase를 사용할 수 있습니다.
/// Create Post UseCase Provider
///
/// **역할**: 포스트 생성 비즈니스 로직
/// **의존성**:
/// - IPostCreationRepositoryV2
/// - IMediaRepository
///
/// **사용처**: CreatePostNotifier.createPost()

@ProviderFor(createPostUseCase)
const createPostUseCaseProvider = CreatePostUseCaseProvider._();

/// UseCase Providers for Creation Feature (Riverpod 3.x)
/// Phase 2-11: CreatePostProviderV2 마이그레이션을 위한 UseCase Provider 노출
///
/// GetIt에 등록된 UseCase들을 Riverpod Provider로 노출합니다.
/// 이를 통해 CreatePostNotifier가 ref.read()로 UseCase를 사용할 수 있습니다.
/// Create Post UseCase Provider
///
/// **역할**: 포스트 생성 비즈니스 로직
/// **의존성**:
/// - IPostCreationRepositoryV2
/// - IMediaRepository
///
/// **사용처**: CreatePostNotifier.createPost()

final class CreatePostUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePostUseCase,
          CreatePostUseCase,
          CreatePostUseCase
        >
    with $Provider<CreatePostUseCase> {
  /// UseCase Providers for Creation Feature (Riverpod 3.x)
  /// Phase 2-11: CreatePostProviderV2 마이그레이션을 위한 UseCase Provider 노출
  ///
  /// GetIt에 등록된 UseCase들을 Riverpod Provider로 노출합니다.
  /// 이를 통해 CreatePostNotifier가 ref.read()로 UseCase를 사용할 수 있습니다.
  /// Create Post UseCase Provider
  ///
  /// **역할**: 포스트 생성 비즈니스 로직
  /// **의존성**:
  /// - IPostCreationRepositoryV2
  /// - IMediaRepository
  ///
  /// **사용처**: CreatePostNotifier.createPost()
  const CreatePostUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePostUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePostUseCase create(Ref ref) {
    return createPostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostUseCase>(value),
    );
  }
}

String _$createPostUseCaseHash() => r'6003df0a25bb06fcb0899bbc6e2fc57d1ed60241';

/// Moderate Content UseCase Provider
///
/// **역할**: AI 기반 콘텐츠 검열 (Perspective API + Gemini AI)
/// **의존성**: 없음 (직접 API 호출)
///
/// **사용처**: CreatePostNotifier.validateAndModerate()

@ProviderFor(moderateContentUseCase)
const moderateContentUseCaseProvider = ModerateContentUseCaseProvider._();

/// Moderate Content UseCase Provider
///
/// **역할**: AI 기반 콘텐츠 검열 (Perspective API + Gemini AI)
/// **의존성**: 없음 (직접 API 호출)
///
/// **사용처**: CreatePostNotifier.validateAndModerate()

final class ModerateContentUseCaseProvider
    extends
        $FunctionalProvider<
          ModerateContentUseCase,
          ModerateContentUseCase,
          ModerateContentUseCase
        >
    with $Provider<ModerateContentUseCase> {
  /// Moderate Content UseCase Provider
  ///
  /// **역할**: AI 기반 콘텐츠 검열 (Perspective API + Gemini AI)
  /// **의존성**: 없음 (직접 API 호출)
  ///
  /// **사용처**: CreatePostNotifier.validateAndModerate()
  const ModerateContentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderateContentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderateContentUseCaseHash();

  @$internal
  @override
  $ProviderElement<ModerateContentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ModerateContentUseCase create(Ref ref) {
    return moderateContentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerateContentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerateContentUseCase>(value),
    );
  }
}

String _$moderateContentUseCaseHash() =>
    r'8f9a22a9a7c82f56abf4e208f04295ec6b2c441d';

/// Validate Post UseCase Provider
///
/// **역할**: 폼 필드 검증 (제목, 설명, 텍스트 등)
/// **의존성**: 없음 (로컬 검증 로직)
///
/// **사용처**:
/// - CreatePostNotifier.validateFormFields()
/// - CreatePostNotifier.validateTitle()
/// - CreatePostNotifier.validateDescription()

@ProviderFor(validatePostUseCase)
const validatePostUseCaseProvider = ValidatePostUseCaseProvider._();

/// Validate Post UseCase Provider
///
/// **역할**: 폼 필드 검증 (제목, 설명, 텍스트 등)
/// **의존성**: 없음 (로컬 검증 로직)
///
/// **사용처**:
/// - CreatePostNotifier.validateFormFields()
/// - CreatePostNotifier.validateTitle()
/// - CreatePostNotifier.validateDescription()

final class ValidatePostUseCaseProvider
    extends
        $FunctionalProvider<
          ValidatePostUseCase,
          ValidatePostUseCase,
          ValidatePostUseCase
        >
    with $Provider<ValidatePostUseCase> {
  /// Validate Post UseCase Provider
  ///
  /// **역할**: 폼 필드 검증 (제목, 설명, 텍스트 등)
  /// **의존성**: 없음 (로컬 검증 로직)
  ///
  /// **사용처**:
  /// - CreatePostNotifier.validateFormFields()
  /// - CreatePostNotifier.validateTitle()
  /// - CreatePostNotifier.validateDescription()
  const ValidatePostUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validatePostUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validatePostUseCaseHash();

  @$internal
  @override
  $ProviderElement<ValidatePostUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ValidatePostUseCase create(Ref ref) {
    return validatePostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidatePostUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidatePostUseCase>(value),
    );
  }
}

String _$validatePostUseCaseHash() =>
    r'743b7f70ffa7c22a572d246762a2f8c79ff10a8a';
