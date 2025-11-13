/// Dependency Injection 설정
///
/// Clean Architecture 원칙을 따르는 애플리케이션 의존성 주입 설정

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 핵심 서비스
import '/services/idempotency/idempotency_service.dart';
import '/services/batch/batch_service.dart';
import '/services/sharding/shard_utils.dart';
import '/services/storage/file_size_utils.dart';

// 서비스 DI 모듈
import '/services/moderation/di/moderation_di_module.dart';

// Feature DI 모듈
import '/features/post/di/post_di_module.dart';
import '/features/voting/di/voting_di_module.dart';
import '/features/profile/di/profile_di_module.dart';
import '/features/auth/di/auth_di_module.dart';
import '/features/notifications/di/notification_di_module.dart';
import '/features/chat/di/chat_di_module.dart';
import '/features/creation/di/creation_di_module.dart';
import '/features/search/di/search_di_module.dart';

// ===== Post Feature DI Module =====
// Handled by /features/post/di/post_di_module.dart

// ===== Creation Feature DI Module =====
// Handled by /features/creation/di/creation_di_module.dart

// ===== Profile Feature DI Module =====
// Handled by /features/profile/di/profile_di_module.dart

// ===== Chat Feature DI Module =====
// Handled by /features/chat/di/chat_di_module.dart

// ===== Search Feature DI Module =====
// Handled by /features/search/di/search_di_module.dart


final getIt = GetIt.instance;

/// Dependency Injection 초기화
Future<void> setupDependencyInjection() async {
  // ===== 핵심 의존성 =====

  // SharedPreferences 인스턴스 초기화
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // IdempotencyService (Auth, Voting 등에서 사용)
  getIt.registerSingleton<IdempotencyService>(
    IdempotencyService(),
  );

  // BatchService (모든 Feature의 원자적 Firestore 작업용)
  getIt.registerSingleton<BatchService>(
    BatchService(),
  );

  // ShardUtils (Voting, Post 등의 고빈도 카운터 샤딩용)
  getIt.registerSingleton<ShardUtils>(
    ShardUtils(),
  );

  // FileSizeUtils (Firebase Storage 파일 크기 계산)
  getIt.registerSingleton<FileSizeUtils>(
    FileSizeUtils(),
  );

  // ===== Moderation Services DI =====
  // 참고: 여러 Feature에서 사용하는 전역 서비스이므로 먼저 등록 (Creation, Post)
  // 제공: PerspectiveApiService, GeminiModerationService, CloudImageModerationService, AIModerationService
  registerModerationModule(getIt);

  // ===== Auth Feature DI =====
  // 참고: Profile Feature 이후에 등록
  // 이유: Auth가 IUserRepository를 사용 (Profile Feature 제공)

  // ===== Creation Feature DI =====
  // 참고: Creation Feature 내부에서 Repository 등록
  registerCreationModule(getIt);

  // ===== Post Feature DI (Voting보다 먼저 등록 필요) =====
  // 참고: Voting Feature가 사용하는 VoteTimerService 제공
  registerPostModule(getIt);

  // ===== Voting Feature DI =====
  // 참고: Post 이후에 등록 (VoteTimerService 사용)
  registerVotingModule(getIt);

  // ===== Notifications Feature DI =====
  // 참고: Voting 이후에 등록 (SubmitVoteUseCase 의존)
  registerNotificationModule(getIt);

  // ===== Profile Feature DI =====
  // 참고: Auth보다 먼저 등록 (IUserRepository 제공)
  registerProfileModule(getIt);

  // ===== Auth Feature DI =====
  // 참고: Profile 이후에 등록 (IUserRepository 사용)
  registerAuthModule(getIt);

  // ===== Chat Feature DI =====
  registerChatModule(getIt);

  // ===== Search Feature DI =====
  registerSearchModule(getIt);

  // 필요에 따라 추가 의존성 등록
}
