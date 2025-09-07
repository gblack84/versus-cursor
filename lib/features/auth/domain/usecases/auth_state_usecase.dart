import '../repositories/i_auth_repository.dart';
import '../models/auth_user.dart';

/// AuthStateUseCase - 인증 상태 스트림 관리
/// 
/// 실시간 인증 상태 변화를 안전하게 처리
class AuthStateUseCase {
  const AuthStateUseCase(this._authRepository);
  
  final IAuthRepository _authRepository;
  
  /// 인증 상태 스트림 감시
  Stream<AuthUser?> call() {
    return _authRepository.authStateChanges;
  }
}