// Firestore User Mapper
// Clean Architecture - Data Layer

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/auth_user.dart';
import '../dto/user_profile_dto.dart';

/// FirestoreUserMapper
///
/// Maps between Firestore documents and user models.
/// Handles conversion between Firestore data format and domain models.
class FirestoreUserMapper {
  /// Convert Firestore document to UserProfileDto
  static UserProfileDto? fromDocument(DocumentSnapshot doc) {
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) return null;

    return UserProfileDto(
      uid: doc.id,
      email: data['email'],
      displayName: data['displayName'],
      profilePic: data['profilePic'],
      phoneNumber: data['phoneNumber'],
      createdTime: _parseTimestamp(data['createdTime']),
      lastActive: _parseTimestamp(data['lastActive']),
      role: data['role'] ?? 'user',
      isPremium: data['isPremium'] ?? false,
      pointsA: data['pointsA'] ?? 0,
      pointsQ: data['pointsQ'] ?? 0,
      interests: _parseStringList(data['interests']),
      expertise: _parseStringList(data['expertise']),
      hobbies: _parseStringList(data['hobbies']),
      location: data['location'],
      bio: data['bio'],
    );
  }

  /// Convert UserProfileDto to Firestore document data
  static Map<String, dynamic> toDocument(UserProfileDto profile) {
    return {
      'uid': profile.uid,
      'email': profile.email,
      'displayName': profile.displayName,
      'profilePic': profile.profilePic,
      'phoneNumber': profile.phoneNumber,
      'createdTime': profile.createdTime != null
          ? Timestamp.fromDate(profile.createdTime!)
          : FieldValue.serverTimestamp(),
      'lastActive': profile.lastActive != null
          ? Timestamp.fromDate(profile.lastActive!)
          : FieldValue.serverTimestamp(),
      'role': profile.role,
      'isPremium': profile.isPremium,
      'pointsA': profile.pointsA,
      'pointsQ': profile.pointsQ,
      'interests': profile.interests,
      'expertise': profile.expertise,
      'hobbies': profile.hobbies,
      'location': profile.location,
      'bio': profile.bio,
    };
  }

  /// Convert AuthUser to Firestore document data
  static Map<String, dynamic> fromAuthUser(AuthUser user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'profilePic': user.photoUrl,
      'phoneNumber': user.phoneNumber,
      'createdTime': user.createdAt != null
          ? Timestamp.fromDate(user.createdAt!)
          : FieldValue.serverTimestamp(),
      'lastActive': user.lastLoginAt != null
          ? Timestamp.fromDate(user.lastLoginAt!)
          : FieldValue.serverTimestamp(),
      'role': user.role,
      'isPremium': user.isPremium,
      'emailVerified': user.isEmailVerified,
      'isAnonymous': user.isAnonymous,
      'providerId': user.providerId,
      'metadata': user.settings,
    };
  }

  /// Create update data for partial profile updates
  static Map<String, dynamic> createUpdateData({
    String? displayName,
    String? profilePic,
    String? bio,
    String? location,
    List<String>? interests,
    List<String>? expertise,
    List<String>? hobbies,
    bool? updateLastActive = true,
  }) {
    final updateData = <String, dynamic>{};

    if (displayName != null) updateData['displayName'] = displayName;
    if (profilePic != null) updateData['profilePic'] = profilePic;
    if (bio != null) updateData['bio'] = bio;
    if (location != null) updateData['location'] = location;
    if (interests != null) updateData['interests'] = interests;
    if (expertise != null) updateData['expertise'] = expertise;
    if (hobbies != null) updateData['hobbies'] = hobbies;

    if (updateLastActive == true) {
      updateData['lastActive'] = FieldValue.serverTimestamp();
    }

    return updateData;
  }

  /// Parse Firestore timestamp to DateTime
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }

    return DateTime.now();
  }

  /// Parse dynamic list to List<String>
  static List<String> _parseStringList(dynamic list) {
    if (list == null) return [];

    if (list is List) {
      return list.whereType<String>().toList();
    }

    return [];
  }

  /// Convert list of documents to list of UserProfileDto
  static List<UserProfileDto> fromDocuments(List<DocumentSnapshot> docs) {
    return docs
      .map((doc) => fromDocument(doc))
      .where((profile) => profile != null)
      .cast<UserProfileDto>()
      .toList();
  }

  /// Check if document has required fields for profile
  static bool hasRequiredFields(Map<String, dynamic> data) {
    return data.containsKey('uid') &&
      data.containsKey('createdTime') &&
      data.containsKey('lastActive');
  }

  /// Merge Firestore data with existing profile
  static UserProfileDto mergeWithExisting(
    UserProfileDto existing,
    Map<String, dynamic> updates,
  ) {
    return UserProfileDto(
      uid: existing.uid,
      email: updates['email'] ?? existing.email,
      displayName: updates['displayName'] ?? existing.displayName,
      profilePic: updates['profilePic'] ?? existing.profilePic,
      phoneNumber: updates['phoneNumber'] ?? existing.phoneNumber,
      createdTime: existing.createdTime,
      lastActive: _parseTimestamp(updates['lastActive']) ?? existing.lastActive,
      role: updates['role'] ?? existing.role,
      isPremium: updates['isPremium'] ?? existing.isPremium,
      pointsA: updates['pointsA'] ?? existing.pointsA,
      pointsQ: updates['pointsQ'] ?? existing.pointsQ,
      interests: _parseStringList(updates['interests']) ?? existing.interests,
      expertise: _parseStringList(updates['expertise']) ?? existing.expertise,
      hobbies: _parseStringList(updates['hobbies']) ?? existing.hobbies,
      location: updates['location'] ?? existing.location,
      bio: updates['bio'] ?? existing.bio,
    );
  }
}