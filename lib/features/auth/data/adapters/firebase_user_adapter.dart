import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

import '/core/interfaces/i_base_auth_user.dart';

/// Firebase Auth User implementation of BaseAuthUser
class VersusSpaceFirebaseUser extends BaseAuthUser {
  VersusSpaceFirebaseUser(this.user);
  final User? user;

  @override
  bool get loggedIn => user != null;

  @override
  bool get emailVerified => user?.emailVerified ?? false;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
        uid: user?.uid,
        email: user?.email,
        displayName: user?.displayName,
        photoUrl: user?.photoURL,
        phoneNumber: user?.phoneNumber,
      );

  @override
  Future? delete() => user?.delete();

  @override
  Future? updateEmail(String email) => user?.verifyBeforeUpdateEmail(email);

  @override
  Future? updatePassword(String newPassword) =>
      user?.updatePassword(newPassword);

  @override
  Future? sendEmailVerification() => user?.sendEmailVerification();

  @override
  Future refreshUser() async => await user?.reload();
}

/// Stream of Firebase Auth user state changes converted to BaseAuthUser
Stream<VersusSpaceFirebaseUser> versusSpaceFirebaseUserStream() =>
    FirebaseAuth.instance
        .authStateChanges()
        .debounce((user) => user == null
            ? TimerStream(true, const Duration(seconds: 1))
            : Stream.value(user))
        .map<VersusSpaceFirebaseUser>(
      (user) {
        return VersusSpaceFirebaseUser(user);
      },
    );