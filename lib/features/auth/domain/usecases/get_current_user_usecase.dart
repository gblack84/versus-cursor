import 'package:dartz/dartz.dart';
import '../repositories/i_auth_repository.dart';
import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';

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
    // Repository already returns Either - direct pass-through
    return await _authRepository.getCurrentUser();
  }
}
