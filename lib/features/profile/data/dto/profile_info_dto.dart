import 'package:cloud_firestore/cloud_firestore.dart';

/// ProfileInfo DTO
///
/// **책임**: Firestore 문서 구조와 Dart 객체 간 변환
class ProfileInfoDto {
  final String? userId;
  final String? displayName;
  final String? photoUrl;
  final String? shortDescription;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? language;
  final List<String>? interests;
  final List<String>? expertise;
  final GeoPoint? location;

  const ProfileInfoDto({
    this.userId,
    this.displayName,
    this.photoUrl,
    this.shortDescription,
    this.gender,
    this.dateOfBirth,
    this.language,
    this.interests,
    this.expertise,
    this.location,
  });

  /// Firestore → DTO
  factory ProfileInfoDto.fromFirestore(Map<String, dynamic> data) {
    return ProfileInfoDto(
      userId: data['userId'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      shortDescription: data['shortDescription'] as String?,
      gender: data['gender'] as String?,
      dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
      language: data['language'] as String?,
      interests: (data['interests'] as List<dynamic>?)?.cast<String>(),
      expertise: (data['expertise'] as List<dynamic>?)?.cast<String>(),
      location: data['location'] as GeoPoint?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (userId != null) 'userId': userId,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null)
        'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (language != null) 'language': language,
      if (interests != null) 'interests': interests,
      if (expertise != null) 'expertise': expertise,
      if (location != null) 'location': location,
    };
  }
}
