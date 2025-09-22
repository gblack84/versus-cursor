// Extended Auth User Domain Model for Versus Space
// Clean Architecture - Domain Layer Entity with full user profile

class AuthUser {
  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.userName,
    this.photoUrl,
    this.phoneNumber,
    this.isEmailVerified = false,
    this.isAnonymous = false,
    this.providerId,
    // Profile fields
    this.bio,
    this.age,
    this.gender,
    this.interests = const [],
    this.expertise = const [],
    this.hobbies = const [],
    this.pointsA = 0,
    this.pointsQ = 0,
    this.role = 'user',
    this.isPremium = false,
    // Timestamps
    this.createdAt,
    this.lastLoginAt,
    // Additional
    this.settings = const {},
  });

  // Authentication fields
  final String uid;
  final String? email;
  final String? displayName;
  final String? userName;
  final String? photoUrl;
  final String? phoneNumber;
  final bool isEmailVerified;
  final bool isAnonymous;
  final String? providerId;

  // Profile fields
  final String? bio;
  final int? age;
  final String? gender;
  final List<String> interests;
  final List<String> expertise;
  final List<String> hobbies;
  final int pointsA;
  final int pointsQ;
  final String role; // admin, tester, user
  final bool isPremium;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? lastLoginAt;

  // Additional data
  final Map<String, dynamic> settings;

  /// Check if user has completed profile setup
  bool get isProfileComplete {
    return userName != null &&
           displayName != null &&
           age != null &&
           interests.isNotEmpty;
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin';

  /// Check if user is tester
  bool get isTester => role == 'tester' || role == 'admin';

  /// Get total points
  int get totalPoints => pointsA + pointsQ;

  /// Copy with method
  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? userName,
    String? photoUrl,
    String? phoneNumber,
    bool? isEmailVerified,
    bool? isAnonymous,
    String? providerId,
    String? bio,
    int? age,
    String? gender,
    List<String>? interests,
    List<String>? expertise,
    List<String>? hobbies,
    int? pointsA,
    int? pointsQ,
    String? role,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? settings,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userName: userName ?? this.userName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      providerId: providerId ?? this.providerId,
      bio: bio ?? this.bio,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      expertise: expertise ?? this.expertise,
      hobbies: hobbies ?? this.hobbies,
      pointsA: pointsA ?? this.pointsA,
      pointsQ: pointsQ ?? this.pointsQ,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      settings: settings ?? this.settings,
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
    return 'AuthUser(uid: $uid, userName: $userName, displayName: $displayName, role: $role)';
  }
}