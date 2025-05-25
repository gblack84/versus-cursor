import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

Future selectedLanguage(
  BuildContext context, {
  String? language,
}) async {
  await currentUserReference!.update(createUsersRecordData(
    language: valueOrDefault(currentUserDocument?.language, ''),
  ));
}
