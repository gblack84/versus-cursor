import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/features/profile/data/adapters/user_profile_adapter.dart';
import 'package:versus_space/features/profile/domain/models/user_profile.dart';
import 'package:versus_space/features/profile/domain/models/profile_info.dart';
import 'package:versus_space/features/profile/domain/models/user_settings.dart';
import 'package:versus_space/features/profile/domain/models/user_stats.dart';
import 'package:versus_space/features/auth/domain/models/auth_user.dart';

void main() {
  group('UserProfileAdapter', () {
    group('toDomainModels', () {
      test('should convert UserProfile to all 4 domain models correctly', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userProfile = UserProfile.getDocumentFromData(testData,
            FirebaseFirestore.instance.collection('users').doc('test-user-id'));

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert - AuthUser
        expect(result.auth.uid, equals('test-user-id'));
        expect(result.auth.email, equals('test@example.com'));
        expect(result.auth.displayName, equals('John Doe'));
        expect(result.auth.photoURL, equals('https://example.com/photo.jpg'));
        expect(result.auth.phoneNumber, equals('+1234567890'));
        expect(result.auth.isEmailVerified, isFalse); // Default value
        expect(result.auth.isAnonymous, isFalse); // Default value
        expect(result.auth.createdTime, isA<DateTime>());
        expect(result.auth.lastActive, isA<DateTime>());

        // Assert - ProfileInfo
        expect(result.profile.userId, equals('test-user-id'));
        expect(result.profile.displayName, equals('John Doe'));
        expect(
            result.profile.photoUrl, equals('https://example.com/photo.jpg'));
        expect(result.profile.shortDescription, equals('Software Developer'));
        expect(result.profile.gender, equals('Male'));
        expect(result.profile.dateOfBirth, isA<DateTime>());
        expect(result.profile.language, equals('en'));
        expect(result.profile.interests, equals(['coding', 'music']));
        expect(result.profile.expertise, equals(['flutter', 'dart']));
        expect(result.profile.location, isA<GeoPoint>());
        expect(result.profile.location!.latitude, closeTo(37.7749, 0.0001));
        expect(result.profile.location!.longitude, closeTo(-122.4194, 0.0001));

        // Assert - UserSettings
        expect(result.settings.userId, equals('test-user-id'));
        expect(result.settings.isPremiumUser, isTrue);
        expect(result.settings.receiveRankUpdateNotifications, isTrue);
        expect(result.settings.receiveTitleUpdateNotifications, isTrue);
        expect(result.settings.receiveVoteNotifications, isTrue); // Default
        expect(result.settings.receiveCommentNotifications, isTrue); // Default
        expect(result.settings.receiveFriendNotifications, isTrue); // Default
        expect(result.settings.subscription, isA<Map<String, dynamic>>());
        expect(result.settings.stats, isA<Map>());
        expect(result.settings.privacySettings, isEmpty); // Default

        // Assert - UserStats
        expect(result.stats.userId, equals('test-user-id'));
        expect(result.stats.pointsA, equals(1500));
        expect(result.stats.pointsQ, equals(2000));
        expect(result.stats.totalAPoints, equals(15000));
        expect(result.stats.totalQPoints, equals(20000));
        expect(result.stats.currentRank, equals(5));
        expect(result.stats.currentTitle, equals('Expert'));
        expect(result.stats.isRankEligible, isTrue);
        expect(result.stats.rankEvaluationCount, equals(10));
        expect(result.stats.friends, equals(['friend1', 'friend2']));
        expect(result.stats.activeChats, equals(['chat1', 'chat2']));
        expect(result.stats.anonymousPostsCount, equals(3));
        expect(result.stats.anonymousCommentsCount, equals(5));
      });

      test('should handle null and empty values correctly', () {
        // Arrange
        final minimalData = _createMinimalUserProfileData();
        final userProfile = UserProfile.getDocumentFromData(minimalData,
            FirebaseFirestore.instance.collection('users').doc('test-user-id'));

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert null handling
        expect(result.auth.photoURL, isNull);
        expect(result.auth.phoneNumber, isNull);
        expect(result.profile.photoUrl, isNull);
        expect(result.profile.shortDescription, isNull);
        expect(result.profile.gender, isNull);
        expect(result.profile.dateOfBirth, isNull);
        expect(result.profile.location, isNull);
        expect(result.profile.interests, isEmpty);
        expect(result.profile.expertise, isEmpty);
        expect(result.stats.friends, isEmpty);
        expect(result.stats.activeChats, isEmpty);
        expect(result.stats.rankHistory, isEmpty);
        expect(result.stats.titleHistory, isEmpty);
      });

      test('should set consistent userId across all domain models', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userProfile = UserProfile.getDocumentFromData(testData,
            FirebaseFirestore.instance.collection('users').doc('test-user-id'));

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert consistent userId
        const expectedUserId = 'test-user-id';
        expect(result.auth.uid, equals(expectedUserId));
        expect(result.profile.userId, equals(expectedUserId));
        expect(result.settings.userId, equals(expectedUserId));
        expect(result.stats.userId, equals(expectedUserId));
      });
    });

    group('fromDomainModels', () {
      test('should convert 4 domain models back to UserProfile correctly', () {
        // Arrange
        final domainModels = _createTestDomainModels();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');

        // Act
        final result = UserProfileAdapter.fromDomainModels(
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Assert core fields
        expect(result.uid, equals('test-user-id'));
        expect(result.email, equals('test@example.com'));
        expect(result.displayName, equals('John Doe'));
        expect(result.photoUrl, equals('https://example.com/photo.jpg'));
        expect(result.phoneNumber, equals('+1234567890'));
        expect(result.shortDescription, equals('Software Developer'));
        expect(result.gender, equals('Male'));
        expect(result.language, equals('en'));
        expect(result.interests, equals(['coding', 'music']));
        expect(result.expertise, equals(['flutter', 'dart']));
        expect(result.isPremiumUser, isTrue);
        expect(result.pointsA, equals(1500));
        expect(result.pointsQ, equals(2000));
        expect(result.currentRank, equals(5));
        expect(result.currentTitle, equals('Expert'));
        expect(result.friends, equals(['friend1', 'friend2']));
      });

      test(
          'should handle displayName preference from ProfileInfo over AuthUser',
          () {
        // Arrange
        final domainModels = _createTestDomainModels();
        final modifiedAuth =
            domainModels.auth.copyWith(displayName: 'Auth Name');
        final modifiedProfile =
            domainModels.profile.copyWith(displayName: 'Profile Name');
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');

        // Act
        final result = UserProfileAdapter.fromDomainModels(
          auth: modifiedAuth,
          profile: modifiedProfile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Assert Profile displayName takes precedence
        expect(result.displayName, equals('Profile Name'));
      });

      test('should handle GeoPoint location correctly', () {
        // Arrange
        final domainModels = _createTestDomainModels();
        final geoPoint = GeoPoint(40.7128, -74.0060); // New York
        final modifiedProfile =
            domainModels.profile.copyWith(location: geoPoint);
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');

        // Act
        final result = UserProfileAdapter.fromDomainModels(
          auth: domainModels.auth,
          profile: modifiedProfile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Assert location is preserved
        expect(result.location, equals(geoPoint));
      });
    });

    group('round-trip conversion (bidirectional)', () {
      test('should preserve all data through full conversion cycle', () {
        // Arrange
        final originalData = _createTestUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final originalUserProfile =
            UserProfile.getDocumentFromData(originalData, userReference);

        // Act - Convert to domain models and back
        final domainModels =
            UserProfileAdapter.toDomainModels(originalUserProfile);
        final reconstructed = UserProfileAdapter.fromDomainModels(
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Assert key fields are preserved
        expect(reconstructed.uid, equals(originalUserProfile.uid));
        expect(reconstructed.email, equals(originalUserProfile.email));
        expect(
            reconstructed.displayName, equals(originalUserProfile.displayName));
        expect(reconstructed.shortDescription,
            equals(originalUserProfile.shortDescription));
        expect(reconstructed.gender, equals(originalUserProfile.gender));
        expect(reconstructed.language, equals(originalUserProfile.language));
        expect(reconstructed.interests, equals(originalUserProfile.interests));
        expect(reconstructed.expertise, equals(originalUserProfile.expertise));
        expect(reconstructed.pointsA, equals(originalUserProfile.pointsA));
        expect(reconstructed.pointsQ, equals(originalUserProfile.pointsQ));
        expect(
            reconstructed.currentRank, equals(originalUserProfile.currentRank));
        expect(reconstructed.isPremiumUser,
            equals(originalUserProfile.isPremiumUser));
      });

      test('should handle minimal data through round-trip conversion', () {
        // Arrange
        final minimalData = _createMinimalUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final originalUserProfile =
            UserProfile.getDocumentFromData(minimalData, userReference);

        // Act - Convert to domain models and back
        final domainModels =
            UserProfileAdapter.toDomainModels(originalUserProfile);
        final reconstructed = UserProfileAdapter.fromDomainModels(
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Assert essential fields are preserved
        expect(reconstructed.uid, equals(originalUserProfile.uid));
        expect(reconstructed.email, equals(originalUserProfile.email));
        expect(
            reconstructed.displayName, equals(originalUserProfile.displayName));
      });
    });

    group('UserProfileBundle', () {
      test('should create bundle correctly', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile =
            UserProfile.getDocumentFromData(testData, userReference);

        // Act
        final bundle = UserProfileAdapter.createBundle(userProfile);

        // Assert
        expect(bundle.auth.uid, equals('test-user-id'));
        expect(bundle.profile.userId, equals('test-user-id'));
        expect(bundle.settings.userId, equals('test-user-id'));
        expect(bundle.stats.userId, equals('test-user-id'));
        expect(bundle.reference, equals(userReference));
      });

      test('should convert bundle back to legacy UserProfile', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final originalUserProfile =
            UserProfile.getDocumentFromData(testData, userReference);
        final bundle = UserProfileAdapter.createBundle(originalUserProfile);

        // Act
        final reconstructed = bundle.toLegacy();

        // Assert
        expect(reconstructed.uid, equals(originalUserProfile.uid));
        expect(
            reconstructed.displayName, equals(originalUserProfile.displayName));
        expect(reconstructed.email, equals(originalUserProfile.email));
      });

      test('should throw error when converting bundle without reference', () {
        // Arrange
        final domainModels = _createTestDomainModels();
        final bundle = UserProfileBundle(
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          // reference is null
        );

        // Act & Assert
        expect(() => bundle.toLegacy(), throwsArgumentError);
      });

      test('should create copy with updated fields', () {
        // Arrange
        final domainModels = _createTestDomainModels();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final originalBundle = UserProfileBundle(
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
          reference: userReference,
        );

        // Act
        final newAuth = domainModels.auth.copyWith(displayName: 'New Name');
        final updatedBundle = originalBundle.copyWith(auth: newAuth);

        // Assert
        expect(updatedBundle.auth.displayName, equals('New Name'));
        expect(
            updatedBundle.profile, same(originalBundle.profile)); // Unchanged
        expect(
            updatedBundle.settings, same(originalBundle.settings)); // Unchanged
        expect(updatedBundle.stats, same(originalBundle.stats)); // Unchanged
        expect(updatedBundle.reference,
            same(originalBundle.reference)); // Unchanged
      });
    });

    group('validateMapping', () {
      test('should validate correct field mapping', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile =
            UserProfile.getDocumentFromData(testData, userReference);
        final domainModels = UserProfileAdapter.toDomainModels(userProfile);

        // Act
        final isValid = UserProfileAdapter.validateMapping(
          legacy: userProfile,
          auth: domainModels.auth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
        );

        // Assert
        expect(isValid, isTrue);
      });

      test('should detect invalid field mapping', () {
        // Arrange
        final testData = _createTestUserProfileData();
        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile =
            UserProfile.getDocumentFromData(testData, userReference);
        final domainModels = UserProfileAdapter.toDomainModels(userProfile);

        // Create invalid auth with different uid
        final invalidAuth = domainModels.auth.copyWith(uid: 'different-uid');

        // Act
        final isValid = UserProfileAdapter.validateMapping(
          legacy: userProfile,
          auth: invalidAuth,
          profile: domainModels.profile,
          settings: domainModels.settings,
          stats: domainModels.stats,
        );

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('edge cases', () {
      test('should handle empty strings correctly', () {
        // Arrange
        final dataWithEmptyStrings = _createTestUserProfileData();
        dataWithEmptyStrings['displayName'] = '';
        dataWithEmptyStrings['email'] = '';
        dataWithEmptyStrings['shortDescription'] = '';

        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile = UserProfile.getDocumentFromData(
            dataWithEmptyStrings, userReference);

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert
        expect(result.auth.displayName, equals(''));
        expect(result.auth.email, equals(''));
        expect(result.profile.displayName, equals(''));
        expect(result.profile.shortDescription, equals(''));
      });

      test('should handle very large lists', () {
        // Arrange
        final largeListData = _createTestUserProfileData();
        largeListData['interests'] = List.generate(1000, (i) => 'interest$i');
        largeListData['expertise'] = List.generate(500, (i) => 'skill$i');
        largeListData['friends'] = List.generate(10000, (i) => 'friend$i');

        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile =
            UserProfile.getDocumentFromData(largeListData, userReference);

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert
        expect(result.profile.interests.length, equals(1000));
        expect(result.profile.expertise.length, equals(500));
        expect(result.stats.friends.length, equals(10000));
      });

      test('should handle extreme numeric values', () {
        // Arrange
        final extremeData = _createTestUserProfileData();
        extremeData['pointsA'] = 999999999;
        extremeData['pointsQ'] = -999999999;
        extremeData['currentRank'] = 0;
        extremeData['rankEvaluationCount'] = 999999;

        final userReference =
            FirebaseFirestore.instance.collection('users').doc('test-user-id');
        final userProfile =
            UserProfile.getDocumentFromData(extremeData, userReference);

        // Act
        final result = UserProfileAdapter.toDomainModels(userProfile);

        // Assert
        expect(result.stats.pointsA, equals(999999999));
        expect(result.stats.pointsQ, equals(-999999999));
        expect(result.stats.currentRank, equals(0));
        expect(result.stats.rankEvaluationCount, equals(999999));
      });
    });
  });
}

// Test Data Helper Methods

Map<String, dynamic> _createTestUserProfileData() {
  final now = DateTime.now();
  return {
    'uid': 'test-user-id',
    'email': 'test@example.com',
    'displayName': 'John Doe',
    'photoUrl': 'https://example.com/photo.jpg',
    'phoneNumber': '+1234567890',
    'createdTime': now,
    'lastActive': now.subtract(const Duration(hours: 1)),
    'shortDescription': 'Software Developer',
    'gender': 'Male',
    'dateOfBirth': now.subtract(const Duration(days: 365 * 30)), // 30 years ago
    'language': 'en',
    'interests': ['coding', 'music'],
    'expertise': ['flutter', 'dart'],
    'location': GeoPoint(37.7749, -122.4194), // San Francisco
    'isPremiumUser': true,
    'receiveRankUpdateNotifications': true,
    'receiveTitleUpdateNotifications': true,
    'subscription': 'premium',
    'stats': {
      'level': 5,
      'achievements': ['coder', 'expert']
    },
    'pointsA': 1500,
    'pointsQ': 2000,
    'totalAPoints': 15000,
    'totalQPoints': 20000,
    'currentRank': 5,
    'currentTitle': 'Expert',
    'rankChangeDate': now.subtract(const Duration(days: 30)),
    'titleChangeDate': now.subtract(const Duration(days: 15)),
    'isRankEligible': true,
    'rankEvaluationCount': 10,
    'friends': ['friend1', 'friend2'],
    'activeChats': ['chat1', 'chat2'],
    'rankHistory': ['1', '2', '3', '4', '5'],
    'titleHistory': ['Beginner', 'Intermediate', 'Advanced', 'Expert'],
    'anonymousPostsCount': 3,
    'anonymousCommentsCount': 5,
  };
}

Map<String, dynamic> _createMinimalUserProfileData() {
  return {
    'uid': 'test-user-id',
    'email': 'minimal@example.com',
    'displayName': 'Minimal User',
    'createdTime': DateTime.now(),
    'interests': [],
    'expertise': [],
    'friends': [],
    'activeChats': [],
    'rankHistory': [],
    'titleHistory': [],
    'pointsA': 0,
    'pointsQ': 0,
    'totalAPoints': 0,
    'totalQPoints': 0,
    'currentRank': 1,
    'currentTitle': '',
    'isRankEligible': false,
    'rankEvaluationCount': 0,
    'anonymousPostsCount': 0,
    'anonymousCommentsCount': 0,
    'isPremiumUser': false,
    'receiveRankUpdateNotifications': false,
    'receiveTitleUpdateNotifications': false,
    'language': 'en',
    'stats': {},
  };
}

({AuthUser auth, ProfileInfo profile, UserSettings settings, UserStats stats})
    _createTestDomainModels() {
  final now = DateTime.now();
  const userId = 'test-user-id';

  final auth = AuthUser(
    uid: userId,
    email: 'test@example.com',
    displayName: 'John Doe',
    photoURL: 'https://example.com/photo.jpg',
    phoneNumber: '+1234567890',
    isEmailVerified: true,
    isAnonymous: false,
    createdTime: now,
    lastActive: now.subtract(const Duration(hours: 1)),
  );

  final profile = ProfileInfo(
    userId: userId,
    displayName: 'John Doe',
    photoUrl: 'https://example.com/photo.jpg',
    shortDescription: 'Software Developer',
    gender: 'Male',
    dateOfBirth: now.subtract(const Duration(days: 365 * 30)),
    language: 'en',
    interests: ['coding', 'music'],
    expertise: ['flutter', 'dart'],
    location: GeoPoint(37.7749, -122.4194),
  );

  final settings = UserSettings(
    userId: userId,
    isPremiumUser: true,
    receiveRankUpdateNotifications: true,
    receiveTitleUpdateNotifications: true,
    receiveVoteNotifications: true,
    receiveCommentNotifications: true,
    receiveFriendNotifications: true,
    subscription: {'type': 'premium'},
    stats: {'level': 5},
    privacySettings: const {},
  );

  final stats = UserStats(
    userId: userId,
    pointsA: 1500,
    pointsQ: 2000,
    totalAPoints: 15000,
    totalQPoints: 20000,
    currentRank: '5',
    currentTitle: 'Expert',
    rankChangeDate: now.subtract(const Duration(days: 30)),
    titleChangeDate: now.subtract(const Duration(days: 15)),
    isRankEligible: true,
    rankEvaluationCount: 10,
    friends: ['friend1', 'friend2'],
    activeChats: ['chat1', 'chat2'],
    rankHistory: ['1', '2', '3', '4', '5'],
    titleHistory: ['Beginner', 'Expert'],
    anonymousPostsCount: 3,
    anonymousCommentsCount: 5,
  );

  return (auth: auth, profile: profile, settings: settings, stats: stats);
}
