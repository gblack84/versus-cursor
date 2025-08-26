import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core_exports.dart';
import 'package:flutter/material.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  await currentUserReference!.update(createUsersModelData(
    language: valueOrDefault(currentUserDocument?.language, ''),
  ));
}
