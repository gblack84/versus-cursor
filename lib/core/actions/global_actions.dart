import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';
import '/features/auth/presentation/providers/auth_provider.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  final userRepository = GetIt.instance<IUserRepository>();
  final authProvider = GetIt.instance<AuthProvider>();

  // Update user language preference through repository
  await userRepository.updateUser(
    authProvider.currentUserUid,
    {
      'language': valueOrDefault(authProvider.currentUserDocument?.language, ''),
    },
  );
}
