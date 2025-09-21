import '/features/auth/data/adapters/auth_util.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';

class SignInWithEmailUseCase {
  SignInWithEmailUseCase();

  Future<BaseAuthUser?> execute({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // PrepareAuthEvent는 이미 호출된 것으로 가정
      final user = await authManager.signInWithEmail(
        context,
        email,
        password,
      );

      if (user == null) {
        return null;
      }

      // authenticatedUserStream이 currentUser를 설정할 때까지 대기
      await _waitForCurrentUserReference();

      // lastActive 업데이트
      await _updateLastActive(user.uid);

      return user;
    } catch (e) {
      debugPrint('SignInWithEmailUseCase error: $e');
      return null;
    }
  }

  Future<void> _waitForCurrentUserReference() async {
    int attempts = 0;
    while (currentUserReference == null && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
  }

  Future<void> _updateLastActive(String? uid) async {
    if (uid == null) return;

    if (currentUserReference == null) {
      debugPrint('경고: currentUserReference가 설정되지 않음');
      // 직접 DocumentReference 생성하여 업데이트
      final directRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);

      await directRef.update({
        ...mapToFirestore(
          {
            'lastActive': FieldValue.serverTimestamp(),
          },
        ),
      });
    } else {
      // 정상적으로 currentUserReference 사용
      await currentUserReference!.update({
        ...mapToFirestore(
          {
            'lastActive': FieldValue.serverTimestamp(),
          },
        ),
      });
    }
  }
}