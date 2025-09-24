import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

// Migrated from backend.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/profile/domain/models/user_profile.dart';
import 'package:stream_transform/stream_transform.dart';
import '/core/interfaces/i_base_auth_user.dart';
import '../../presentation/providers/auth_provider.dart' as app_auth;

export 'base_auth_user_provider.dart';
export 'firebase_user_provider.dart'
    show versusSpaceFirebaseUserStream, VersusSpaceFirebaseUser;

// Get the singleton AuthProvider instance
app_auth.AuthProvider get _authProvider => GetIt.instance<app_auth.AuthProvider>();

// Legacy global variables are now proxies to AuthProvider
BaseAuthUser? get currentUser => _authProvider.baseAuthUser;
bool get loggedIn => _authProvider.loggedIn;

String get currentUserEmail => _authProvider.currentUserEmail;

String get currentUserUid => _authProvider.currentUserUid;

String get currentUserDisplayName => _authProvider.currentUserDisplayName;

String get currentUserPhoto => _authProvider.currentUserPhoto;

String get currentPhoneNumber => _authProvider.currentPhoneNumber;

String get currentJwtToken => _authProvider.currentJwtToken;

bool get currentUserEmailVerified => _authProvider.currentUserEmailVerified;

DocumentReference? get currentUserReference => _authProvider.currentUserReference;

UserProfile? get currentUserDocument => _authProvider.currentUserDocument;

// Legacy streams - now managed by AuthProvider
final jwtTokenStream = FirebaseAuth.instance
    .idTokenChanges()
    .map((user) async => await user?.getIdToken())
    .asBroadcastStream();

final authenticatedUserStream = FirebaseAuth.instance
    .authStateChanges()
    .map<String>((user) => user?.uid ?? '')
    .switchMap(
      (uid) => uid.isEmpty
          ? Stream.value(null)
          : UserProfile.getDocument(UserProfile.collection.doc(uid))
              .handleError((_) {}),
    )
    .asBroadcastStream();

class AuthUserStreamWidget extends StatelessWidget {
  const AuthUserStreamWidget({Key? key, required this.builder})
      : super(key: key);

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => StreamBuilder(
        stream: authenticatedUserStream,
        builder: (context, _) => builder(context),
      );
}
