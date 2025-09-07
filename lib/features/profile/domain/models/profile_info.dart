import 'package:cloud_firestore/cloud_firestore.dart';

/// ProfileInfo Domain Model
/// Clean Architecture - Domain Layer Entity
/// 
/// This model contains user profile display information,
/// separated from authentication concerns (AuthUser) and 
/// statistics (UserStats) for better separation of concerns.
class ProfileInfo {
  const ProfileInfo({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.shortDescription,
    this.gender,
    this.dateOfBirth,
    this.language = 'en',
    this.interests = const [],
    this.expertise = const [],
    this.location,
  });

  // Core Fields
  final String userId; // Foreign key to AuthUser.uid
  final String displayName;
  final String? photoUrl;
  
  // Profile Details
  final String? shortDescription;
  final String? gender;
  final DateTime? dateOfBirth;
  final String language;
  
  // Lists
  final List<String> interests;
  final List<String> expertise;
  
  // Location
  final GeoPoint? location;

  /// Create ProfileInfo from Firestore document
  factory ProfileInfo.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfileInfo(
      userId: doc.id,
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      shortDescription: data['shortDescription'],
      gender: data['gender'],
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate()
          : null,
      language: data['language'] ?? 'en',
      interests: List<String>.from(data['interests'] ?? []),
      expertise: List<String>.from(data['expertise'] ?? []),
      location: data['location'] as GeoPoint?,
    );
  }

  /// Create ProfileInfo from JSON (for caching)
  factory ProfileInfo.fromJson(Map<String, dynamic> json) {
    return ProfileInfo(
      userId: json['userId'] ?? '',
      displayName: json['displayName'] ?? '',
      photoUrl: json['photoUrl'],
      shortDescription: json['shortDescription'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      language: json['language'] ?? 'en',
      interests: List<String>.from(json['interests'] ?? []),
      expertise: List<String>.from(json['expertise'] ?? []),
      location: json['location'] != null 
          ? GeoPoint(json['location']['latitude'], json['location']['longitude'])
          : null,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'language': language,
      'interests': interests,
      'expertise': expertise,
      if (location != null) 'location': location,
    };
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (gender != null) 'gender': gender,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      'language': language,
      'interests': interests,
      'expertise': expertise,
      if (location != null) 'location': {
        'latitude': location!.latitude,
        'longitude': location!.longitude,
      },
    };
  }

  /// Create a copy with updated fields
  ProfileInfo copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    String? language,
    List<String>? interests,
    List<String>? expertise,
    GeoPoint? location,
  }) {
    return ProfileInfo(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      shortDescription: shortDescription ?? this.shortDescription,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      language: language ?? this.language,
      interests: interests ?? this.interests,
      expertise: expertise ?? this.expertise,
      location: location ?? this.location,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProfileInfo && 
        other.userId == userId &&
        other.displayName == displayName;
  }

  @override
  int get hashCode => userId.hashCode ^ displayName.hashCode;

  @override
  String toString() {
    return 'ProfileInfo(userId: $userId, displayName: $displayName, interests: ${interests.length}, expertise: ${expertise.length})';
  }
}