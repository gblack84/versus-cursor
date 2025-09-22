// Send Email Verification UseCase
// Clean Architecture - Domain Layer

import '../repositories/i_auth_repository.dart';

/// SendEmailVerificationUseCase
///
/// 현재 로그인한 사용자에게 이메일 인증 메일을 발송하는 UseCase.
/// Firebase Auth의 sendEmailVerification 기능을 캡슐화.
class SendEmailVerificationUseCase {
  final IAuthRepository repository;

  SendEmailVerificationUseCase({required this.repository});

  /// 이메일 인증 메일 발송
  Future<bool> execute() async {
    try {
      return await repository.sendEmailVerification();
    } catch (e) {
      print('SendEmailVerificationUseCase Error: $e');
      return false;
    }
  }
}