// Sign In with Google UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '/core/utils/idempotency_service.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithGoogleUseCase
///
/// Business logic for Google Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Phase 2**: IdempotencyService 통합
/// - 중복 계정 생성 방지
/// - 네트워크 재시도 시 안전성 보장
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  SignInWithGoogleUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  })  : _repository = repository,
        _idempotencyService = idempotencyService;

  /// Execute Google Sign In (Phase 2: eventId 추가)
  ///
  /// **Parameters**:
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  ///
  /// **IdempotencyService**:
  /// - entityType: 'auth_google_signin'
  /// - entityId: 'pending' (로그인 전 email 모름)
  /// - userId: 'pending'
  Future<Either<AuthFailure, AuthUser>> execute({
    required String eventId,
  }) async {
    debugPrint('Executing Google Sign In with eventId: $eventId');

    try {
      // IdempotencyService로 중복 작업 방지
      final user = await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_google_signin',
        entityId: 'pending', // Google 로그인 전 email 알 수 없음
        userId: 'pending',
        eventId: eventId,
        operation: (transaction) async {
          // Repository 호출
          final result = await _repository.signInWithGoogle();

          // Either를 throw/return으로 변환
          return result.fold(
            (failure) {
              debugPrint('Google Sign In failed: ${failure.message}');
              throw failure;
            },
            (user) {
              debugPrint('Google Sign In successful: ${user.email}');
              return user;
            },
          );
        },
      );

      return right(user);
    } on IdempotencyViolation {
      // 이미 로그인됨 → 현재 사용자 반환
      debugPrint('Google Sign In already completed (idempotency violation)');
      return await _repository.getCurrentUser();
    } on AuthFailure catch (e) {
      debugPrint('Google Sign In failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Google Sign In unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}