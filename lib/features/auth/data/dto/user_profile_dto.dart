import 'package:cloud_firestore/cloud_firestore.dart';

/// DTO for Firestore User Profile Document
///
/// Firestore 'users' 컬렉션과 1:1 매칭되는 DTO
/// Versus Space 앱의 사용자 프로필 정보 포함
class UserProfileDto {
  final String? uid;
  final String? email;
  final String? displayName;
  final String? userName;      // 사용자 이름 (고유)
  final String? profilePic;    // 프로필 사진 URL
  final String? phoneNumber;   // 전화번호
  final String? bio;           // 자기소개
  final String? location;      // 위치 정보
  final int? age;
  final String? gender;
  final List<String>? interests;
  final List<String>? expertise;
  final List<String>? hobbies;
  final int? pointsA;          // A 타입 포인트
  final int? pointsQ;          // Q 타입 포인트
  final String? role;          // admin, tester, user
  final bool? isPremium;
  final DateTime? createdTime;
  final DateTime? lastActive;
  final Map<String, dynamic>? settings;

  const UserProfileDto({
    this.uid,
    this.email,
    this.displayName,
    this.userName,
    this.profilePic,
    this.phoneNumber,
    this.bio,
    this.location,
    this.age,
    this.gender,
    this.interests,
    this.expertise,
    this.hobbies,
    this.pointsA,
    this.pointsQ,
    this.role,
    this.isPremium,
    this.createdTime,
    this.lastActive,
    this.settings,
  });

  /// Firestore 문서로부터 생성
  factory UserProfileDto.fromFirestore(Map<String, dynamic> json, String documentId) {
    return UserProfileDto(
      uid: documentId,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      userName: json['userName'] as String?,
      profilePic: json['profilePic'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      expertise: (json['expertise'] as List<dynamic>?)?.cast<String>(),
      hobbies: (json['hobbies'] as List<dynamic>?)?.cast<String>(),
      pointsA: json['pointsA'] as int? ?? 0,
      pointsQ: json['pointsQ'] as int? ?? 0,
      role: json['role'] as String? ?? 'user',
      isPremium: json['isPremium'] as bool? ?? false,
      createdTime: json['createdTime'] != null
          ? (json['createdTime'] as Timestamp).toDate()
          : null,
      lastActive: json['lastActive'] != null
          ? (json['lastActive'] as Timestamp).toDate()
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  /// JSON으로부터 생성
  factory UserProfileDto.fromJson(Map<String, dynamic> json) {
    return UserProfileDto(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      userName: json['userName'] as String?,
      profilePic: json['profilePic'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>(),
      expertise: (json['expertise'] as List<dynamic>?)?.cast<String>(),
      hobbies: (json['hobbies'] as List<dynamic>?)?.cast<String>(),
      pointsA: json['pointsA'] as int? ?? 0,
      pointsQ: json['pointsQ'] as int? ?? 0,
      role: json['role'] as String? ?? 'user',
      isPremium: json['isPremium'] as bool? ?? false,
      createdTime: json['createdTime'] != null
          ? DateTime.parse(json['createdTime'] as String)
          : null,
      lastActive: json['lastActive'] != null
          ? DateTime.parse(json['lastActive'] as String)
          : null,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestore() {
    return {
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (userName != null) 'userName': userName,
      if (profilePic != null) 'profilePic': profilePic,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
      if (expertise != null) 'expertise': expertise,
      if (hobbies != null) 'hobbies': hobbies,
      'pointsA': pointsA ?? 0,
      'pointsQ': pointsQ ?? 0,
      'role': role ?? 'user',
      'isPremium': isPremium ?? false,
      if (createdTime != null) 'createdTime': Timestamp.fromDate(createdTime!),
      if (lastActive != null) 'lastActive': Timestamp.fromDate(lastActive!),
      if (settings != null) 'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      if (uid != null) 'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (userName != null) 'userName': userName,
      if (profilePic != null) 'profilePic': profilePic,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (interests != null) 'interests': interests,
      if (expertise != null) 'expertise': expertise,
      if (hobbies != null) 'hobbies': hobbies,
      'pointsA': pointsA ?? 0,
      'pointsQ': pointsQ ?? 0,
      'role': role ?? 'user',
      'isPremium': isPremium ?? false,
      if (createdTime != null) 'createdTime': createdTime!.toIso8601String(),
      if (lastActive != null) 'lastActive': lastActive!.toIso8601String(),
      if (settings != null) 'settings': settings,
    };
  }

  /// 복사 메서드
  UserProfileDto copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? userName,
    String? profilePic,
    String? phoneNumber,
    String? bio,
    String? location,
    int? age,
    String? gender,
    List<String>? interests,
    List<String>? expertise,
    List<String>? hobbies,
    int? pointsA,
    int? pointsQ,
    String? role,
    bool? isPremium,
    DateTime? createdTime,
    DateTime? lastActive,
    Map<String, dynamic>? settings,
  }) {
    return UserProfileDto(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      userName: userName ?? this.userName,
      profilePic: profilePic ?? this.profilePic,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      expertise: expertise ?? this.expertise,
      hobbies: hobbies ?? this.hobbies,
      pointsA: pointsA ?? this.pointsA,
      pointsQ: pointsQ ?? this.pointsQ,
      role: role ?? this.role,
      isPremium: isPremium ?? this.isPremium,
      createdTime: createdTime ?? this.createdTime,
      lastActive: lastActive ?? this.lastActive,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'UserProfileDto(uid: $uid, userName: $userName, displayName: $displayName)';
  }
}