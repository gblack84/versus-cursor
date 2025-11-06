/// Voting Feature - UseCase Providers (Riverpod 3.x)
///
/// **Riverpod 3.x Pattern**:
/// - GetIt UseCase를 @riverpod getter로 래핑
/// - DI 컨테이너와 Riverpod 통합
///
/// **역할**:
/// - Domain Layer의 UseCase를 Presentation Layer에서 사용할 수 있도록 제공
/// - GetIt 컨테이너에서 UseCase 인스턴스 가져오기

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '/features/voting/domain/usecases/chat/submit_vote_use_case.dart';

part 'usecase_providers.g.dart';

// ============================================================================
// UseCase Providers
// ============================================================================

/// SubmitVoteUseCase Provider
///
/// **Pattern**: @riverpod getter function
/// - GetIt 컨테이너에서 SubmitVoteUseCase 인스턴스 반환
/// - AutoDispose로 자동 메모리 관리
///
/// **사용 예시**:
/// ```dart
/// final useCase = ref.read(submitVoteUseCaseProvider);
/// final result = await useCase(postId: postId, userId: userId, voteOption: 'A');
/// ```
@riverpod
SubmitVoteUseCase submitVoteUseCase(Ref ref) {
  return getIt<SubmitVoteUseCase>();
}
