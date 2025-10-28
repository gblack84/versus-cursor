import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ⚠️ DEAD CODE: This function is not called anywhere in the codebase.
/// Kept for reference. Use ProfileProvider.updateCurrentUserLanguage() instead.
@Deprecated('Not used anywhere. Consider removing or migrating to Riverpod.')
Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  final userRepository = GetIt.instance<IUserRepository>();
  final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Update user language preference through repository
  await userRepository.updateUser(
    currentUserId,
    {
      'language': language ?? '',
    },
  );
}
