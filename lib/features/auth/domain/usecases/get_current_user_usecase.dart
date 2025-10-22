import '../repositories/i_auth_repository.dart';
import '../entities/auth_user.dart';

/// GetCurrentUserUseCase - 현재 인증된 사용자 조회
///
/// Presentation 레이어가 Data 레이어에 직접 접근하지 않도록 하는
/// Clean Architecture 패턴의 핵심 구성요소
class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._authRepository);

  final IAuthRepository _authRepository;

  /// 현재 인증된 사용자 조회
  Future<AuthUser?> call() async {
    return await _authRepository.getCurrentUser();
  }
}
