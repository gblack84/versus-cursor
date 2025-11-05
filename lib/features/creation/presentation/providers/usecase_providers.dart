import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/usecases/validation/validate_post_usecase.dart';

part 'usecase_providers.g.dart';

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
@riverpod
CreatePostUseCase createPostUseCase(Ref ref) {
  return getIt<CreatePostUseCase>();
}

/// Moderate Content UseCase Provider
///
/// **역할**: AI 기반 콘텐츠 검열 (Perspective API + Gemini AI)
/// **의존성**: 없음 (직접 API 호출)
///
/// **사용처**: CreatePostNotifier.validateAndModerate()
@riverpod
ModerateContentUseCase moderateContentUseCase(Ref ref) {
  return getIt<ModerateContentUseCase>();
}

/// Validate Post UseCase Provider
///
/// **역할**: 폼 필드 검증 (제목, 설명, 텍스트 등)
/// **의존성**: 없음 (로컬 검증 로직)
///
/// **사용처**:
/// - CreatePostNotifier.validateFormFields()
/// - CreatePostNotifier.validateTitle()
/// - CreatePostNotifier.validateDescription()
@riverpod
ValidatePostUseCase validatePostUseCase(Ref ref) {
  return getIt<ValidatePostUseCase>();
}
