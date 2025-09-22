import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO for Firebase Authentication User
///
/// Firebase와 1:1 매칭되는 데이터 전송 객체
/// 모든 필드명은 Firebase 규칙을 따름 (camelCase)
class AuthUserDto {
  final String uid;
  final String? email;
  final String? displayName;  // Firebase 표준 필드명 (절대 변경 금지)
  final String? photoUrl;      // Firebase 표준 필드명 (절대 변경 금지)
  final bool? emailVerified;
  final String? phoneNumber;
  final String? providerId;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final Map<String, dynamic>? metadata;

  const AuthUserDto({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified,
    this.phoneNumber,
    this.providerId,
    this.createdAt,
    this.lastLoginAt,
    this.metadata,
  });

  /// Firebase User 객체로부터 생성
  factory AuthUserDto.fromFirebaseUser(dynamic firebaseUser) {
    return AuthUserDto(
      uid: firebaseUser.uid as String,
      email: firebaseUser.email as String?,
      displayName: firebaseUser.displayName as String?,
      photoUrl: firebaseUser.photoURL as String?,
      emailVerified: firebaseUser.emailVerified as bool?,
      phoneNumber: firebaseUser.phoneNumber as String?,
      providerId: firebaseUser.providerData?.isNotEmpty == true
          ? firebaseUser.providerData![0].providerId as String?
          : null,
      createdAt: firebaseUser.metadata?.creationTime,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
      metadata: {
        'creationTime': firebaseUser.metadata?.creationTime?.toIso8601String(),
        'lastSignInTime': firebaseUser.metadata?.lastSignInTime?.toIso8601String(),
      },
    );
  }

  /// Firestore 문서로부터 생성
  factory AuthUserDto.fromFirestore(Map<String, dynamic> json) {
    return AuthUserDto(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      phoneNumber: json['phoneNumber'] as String?,
      providerId: json['providerId'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? (json['lastLoginAt'] as Timestamp).toDate()
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// JSON으로부터 생성 (일반적인 직렬화)
  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      phoneNumber: json['phoneNumber'] as String?,
      providerId: json['providerId'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (emailVerified != null) 'emailVerified': emailVerified,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (providerId != null) 'providerId': providerId,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (emailVerified != null) 'emailVerified': emailVerified,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (providerId != null) 'providerId': providerId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (lastLoginAt != null) 'lastLoginAt': lastLoginAt!.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// 복사 메서드
  AuthUserDto copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    String? phoneNumber,
    String? providerId,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    Map<String, dynamic>? metadata,
  }) {
    return AuthUserDto(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'AuthUserDto(uid: $uid, email: $email, displayName: $displayName)';
  }
}