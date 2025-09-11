import '../../../../core/domain/ports/i_user_service.dart';
import 'auth_util.dart';

/// User service implementation for auth feature
///
/// This adapter wraps the auth utilities to provide
/// the IUserService interface implementation
class UserServiceImpl implements IUserService {
  @override
  String get currentUserId => currentUserUid;

  @override
  bool get isAuthenticated => currentUserUid.isNotEmpty;
}
