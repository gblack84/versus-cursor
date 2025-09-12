import '/core/domain/ports/i_user_service.dart';
import 'base/use_case.dart';

/// 현재 로그인한 사용자 정보를 조회하는 UseCase
/// Clean Architecture - 사용자 정보 비즈니스 로직
class GetCurrentUserUseCase implements UseCase<void, String> {
  final IUserService _userService;

  GetCurrentUserUseCase(this._userService);

  @override
  Future<Result<String>> call(void params) async {
    try {
      // 현재 사용자 ID 조회
      final userId = _userService.currentUserId;
      
      // 사용자 ID 검증
      if (userId.isEmpty) {
        return const Result.failure('No user is currently logged in');
      }

      return Result.success(userId);
    } catch (e) {
      return Result.failure('Failed to get current user: ${e.toString()}');
    }
  }

  /// 현재 사용자의 상세 정보 조회
  Future<Result<Map<String, dynamic>>> getCurrentUserDetails() async {
    try {
      final userId = _userService.currentUserId;
      
      if (userId.isEmpty) {
        return const Result.failure('No user is currently logged in');
      }

      // 사용자 상세 정보 구성
      final userDetails = {
        'userId': userId,
        'isAuthenticated': userId.isNotEmpty,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 추가 정보가 필요한 경우 여기서 조회
      // 예: 프로필, 권한, 설정 등

      return Result.success(userDetails);
    } catch (e) {
      return Result.failure(
        'Failed to get user details: ${e.toString()}',
      );
    }
  }

  /// 사용자 인증 상태 확인
  bool get isAuthenticated => _userService.currentUserId.isNotEmpty;

  /// 사용자 ID 동기 조회 (빠른 접근용)
  String get currentUserId => _userService.currentUserId;
}