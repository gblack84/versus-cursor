// Delete User UseCase
// Clean Architecture - Domain Layer

import '../repositories/i_auth_repository.dart';

/// DeleteUserUseCase
///
/// 현재 로그인한 사용자 계정을 삭제하는 UseCase.
/// Firebase Auth와 Firestore에서 사용자 데이터를 모두 제거.
class DeleteUserUseCase {
  final IAuthRepository repository;

  DeleteUserUseCase({required this.repository});

  /// 사용자 계정 삭제
  Future<bool> execute() async {
    try {
      return await repository.deleteUser();
    } catch (e) {
      print('DeleteUserUseCase Error: $e');
      return false;
    }
  }
}