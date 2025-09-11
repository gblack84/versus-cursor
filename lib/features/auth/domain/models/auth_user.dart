// Auth User Domain Model
// Clean Architecture - Domain Layer Entity

class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isAnonymous = false,
    this.createdTime,
    this.lastActive,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isAnonymous;
  final DateTime? createdTime;
  final DateTime? lastActive;

  factory AuthUser.fromFirebaseUser(dynamic firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified ?? false,
      isAnonymous: firebaseUser.isAnonymous ?? false,
      createdTime: firebaseUser.metadata?.creationTime,
      lastActive: DateTime.now(), // Track last authentication activity
    );
  }

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isAnonymous,
    DateTime? createdTime,
    DateTime? lastActive,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdTime: createdTime ?? this.createdTime,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AuthUser(uid: $uid, email: $email, displayName: $displayName)';
  }
}
