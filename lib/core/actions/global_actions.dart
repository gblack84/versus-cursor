import '/features/auth/data/services/auth_util.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/features/profile/domain/repositories/i_user_repository.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  final userRepository = GetIt.instance<IUserRepository>();
  
  // Update user language preference through repository
  await userRepository.updateUser(
    currentUserReference!.id,
    {
      'language': valueOrDefault(currentUserDocument?.language, ''),
    },
  );
}
