import 'package:get_it/get_it.dart';
import '/features/auth/data/adapters/auth_util.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';

class CreateTestAccountUseCase {
  final IUserRepository _userRepository;

  CreateTestAccountUseCase({IUserRepository? userRepository})
      : _userRepository = userRepository ?? GetIt.instance<IUserRepository>();

  Future<BaseAuthUser?> execute({
    required BuildContext context,
    required String email,
    required String password,
    required String displayName,
    required String role,
    String? platform,
  }) async {
    try {
      // 먼저 로그인 시도
      var user = await authManager.signInWithEmail(
        context,
        email,
        password,
      );

      // 계정이 없으면 생성
      if (user == null) {
        user = await authManager.createAccountWithEmail(
          context,
          email,
          password,
        );

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$displayName 계정 생성 실패'),
            ),
          );
          return null;
        }

        // 사용자 문서 생성
        final usersCreateData = {
          'email': email,
          'displayName': displayName,
          'createdTime': FieldValue.serverTimestamp(),
          'role': role,
          'uid': user.uid,
        };

        if (platform != null) {
          usersCreateData['platform'] = platform;
        }

        // UserProfile 생성
        await UserProfile.collection
            .doc(user.uid)
            .set(usersCreateData);
      }

      // authenticatedUserStream이 currentUser를 설정할 때까지 대기
      await _waitForCurrentUserReference();

      // lastActive 및 role 정보 업데이트
      await _updateUserData(user.uid, role, platform);

      return user;
    } catch (e) {
      debugPrint('CreateTestAccountUseCase error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName 계정 처리 중 오류 발생'),
          ),
        );
      }
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

  Future<void> _updateUserData(String? uid, String role, String? platform) async {
    if (uid == null) return;

    final updateData = {
      'lastActive': FieldValue.serverTimestamp(),
      'role': role,
    };

    if (platform != null) {
      updateData['platform'] = platform;
    }

    if (currentUserReference == null) {
      debugPrint('경고: currentUserReference가 설정되지 않음');
      // Repository를 통해 업데이트
      final directRef = _userRepository.getUserReference(uid);
      await directRef.update({
        ...mapToFirestore(updateData),
      });
    } else {
      // 정상적으로 currentUserReference 사용
      await currentUserReference!.update({
        ...mapToFirestore(updateData),
      });
    }
  }
}