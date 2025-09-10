import '/features/notifications/domain/services/i_user_service.dart';

/// 현재 로그인한 사용자 ID를 가져오는 UseCase
class GetCurrentUserIdUseCase {
  final IUserService _userService;

  GetCurrentUserIdUseCase(this._userService);

  String? execute() {
    if (_userService.isAuthenticated) {
      return _userService.currentUserId;
    }
    return null;
  }
}