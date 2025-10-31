// Sign In with Apple UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '/core/utils/idempotency_service.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithAppleUseCase
///
/// Business logic for Apple Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Phase 2**: IdempotencyService 통합
/// - 중복 계정 생성 방지
/// - 네트워크 재시도 시 안전성 보장
class SignInWithAppleUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  SignInWithAppleUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  })  : _repository = repository,
        _idempotencyService = idempotencyService;

  /// Execute Apple Sign In (Phase 2: eventId 추가)
  ///
  /// **Parameters**:
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  ///
  /// **IdempotencyService**:
  /// - entityType: 'auth_apple_signin'
  /// - entityId: 'pending' (로그인 전 email 모름)
  /// - userId: 'pending'
  Future<Either<AuthFailure, AuthUser>> execute({
    required String eventId,
  }) async {
    debugPrint('Executing Apple Sign In with eventId: $eventId');

    try {
      // IdempotencyService로 중복 작업 방지
      final user = await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_apple_signin',
        entityId: 'pending', // Apple 로그인 전 email 알 수 없음
        userId: 'pending',
        eventId: eventId,
        operation: (transaction) async {
          // Repository 호출
          final result = await _repository.signInWithApple();

          // Either를 throw/return으로 변환
          return result.fold(
            (failure) {
              debugPrint('Apple Sign In failed: ${failure.message}');
              throw failure;
            },
            (user) {
              // Apple specific business logic
              // Apple might not provide email on subsequent logins
              if (user.email == null || user.email!.isEmpty) {
                debugPrint('Warning: Apple Sign In returned no email address');
              }
              debugPrint('Apple Sign In successful: ${user.uid}');
              return user;
            },
          );
        },
      );

      return right(user);
    } on IdempotencyViolation {
      // 이미 로그인됨 → 현재 사용자 반환
      debugPrint('Apple Sign In already completed (idempotency violation)');
      return await _repository.getCurrentUser();
    } on AuthFailure catch (e) {
      debugPrint('Apple Sign In failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Apple Sign In unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}