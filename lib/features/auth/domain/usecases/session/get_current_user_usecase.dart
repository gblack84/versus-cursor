import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_auth_repository.dart';
import '../../entities/auth_user.dart';
import '../../failures/auth_failure.dart';

/// GetCurrentUserUseCase - 현재 인증된 사용자 조회
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
/// - Repository already handles all error cases
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final IAuthRepository _authRepository;

  /// 현재 인증된 사용자 조회
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> call() async {
    DevLogger.params({}, tag: 'GetCurrentUser');
    DevLogger.checkpoint('Retrieving current authenticated user', tag: 'GetCurrentUser');

    // Repository already returns Either - process with fold for logging
    DevLogger.checkpoint('Calling repository.getCurrentUser', tag: 'GetCurrentUser');
    final result = await _authRepository.getCurrentUser();

    return result.fold(
      (failure) {
        DevLogger.error('Failed to get current user', error: failure, tag: 'GetCurrentUser');
        return left(failure);
      },
      (user) {
        DevLogger.result(isSuccess: true, data: 'uid: ${user.uid}', tag: 'GetCurrentUser');
        return right(user);
      },
    );
  }
}
