import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_content_visibility_repository.dart';
import '../../domain/usecases/audience/manage_target_audience_usecase.dart';

/// Implementation of content visibility repository
/// Target Audience 시스템과 연동되는 접근 제어 구현체
class ContentVisibilityRepositoryImpl implements IContentVisibilityRepository {
  final FirebaseFirestore _firestore;
  final ManageTargetAudienceUseCase? _targetAudienceUseCase;
  static const String _collection = 'posts';

  ContentVisibilityRepositoryImpl({
    FirebaseFirestore? firestore,
    ManageTargetAudienceUseCase? targetAudienceUseCase,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _targetAudienceUseCase = targetAudienceUseCase;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<void> setVisibility(String contentId, VisibilityLevel level) async {
    try {
      await _postsCollection.doc(contentId).update({
        'visibility': _visibilityLevelToInt(level),
        'visibilityUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set visibility: $e');
    }
  }

  @override
  Future<bool> canUserView(String contentId, String userId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final visibility = _intToVisibilityLevel(data['visibility'] ?? 0);

      switch (visibility) {
        case VisibilityLevel.public:
          return true;
        case VisibilityLevel.private:
          return data['creatorInfo']?['userid'] == userId;
        case VisibilityLevel.friends:
          // Check if user is a friend
          final creatorId = data['creatorInfo']?['userid'];
          if (creatorId == userId) return true;
          // TODO: Implement friend check
          return false;
        case VisibilityLevel.custom:
          // Use target audience logic
          if (_targetAudienceUseCase != null) {
            final targetAudience = await getTargetAudience(contentId);
            return _checkTargetAudience(userId, targetAudience);
          }
          return false;
        case VisibilityLevel.premium:
          // Check if user has premium
          final userDoc = await _firestore.collection('users').doc(userId).get();
          return userDoc.data()?['isPremium'] ?? false;
      }
    } catch (e) {
      throw Exception('Failed to check user view permission: $e');
    }
  }

  @override
  Future<TargetAudience> getTargetAudience(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        throw Exception('Content not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      final targetAudienceData = data['targetAudience'] as Map<String, dynamic>?;

      if (targetAudienceData == null) {
        return TargetAudience(mode: 'public');
      }

      return TargetAudience(
        mode: targetAudienceData['mode'] ?? 'public',
        interests: List<String>.from(targetAudienceData['interests'] ?? []),
        ageRange: targetAudienceData['ageRange'] != null
            ? AgeRange(
                min: targetAudienceData['ageRange']['min'] ?? 13,
                max: targetAudienceData['ageRange']['max'] ?? 99,
              )
            : null,
        gender: targetAudienceData['gender'],
        locations: List<String>.from(targetAudienceData['locations'] ?? []),
        customFilters: targetAudienceData['customFilters'],
      );
    } catch (e) {
      throw Exception('Failed to get target audience: $e');
    }
  }

  @override
  Future<void> updateTargetAudience(
    String contentId,
    TargetAudience audience,
  ) async {
    try {
      // Use existing ManageTargetAudienceUseCase if available
      if (_targetAudienceUseCase != null) {
        final result = await _targetAudienceUseCase.execute(
          postId: contentId,
          targetAudience: _targetAudienceToMap(audience),
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );
      } else {
        // Direct update
        await _postsCollection.doc(contentId).update({
          'targetAudience': _targetAudienceToMap(audience),
          'targetAudienceUpdatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update target audience: $e');
    }
  }

  @override
  Stream<List<String>> getContentByVisibility(VisibilityLevel level) {
    return _postsCollection
        .where('visibility', isEqualTo: _visibilityLevelToInt(level))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  @override
  Future<void> setAnonymous(String contentId, bool isAnonymous) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isAnonymous': isAnonymous,
        'anonymousUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set anonymous: $e');
    }
  }

  @override
  Future<bool> isPremiumRequired(String contentId) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      return data['premiumRequired'] ?? false;
    } catch (e) {
      throw Exception('Failed to check premium requirement: $e');
    }
  }

  @override
  Future<void> setPremiumRequired(String contentId, bool required) async {
    try {
      await _postsCollection.doc(contentId).update({
        'premiumRequired': required,
        'visibility': required ? _visibilityLevelToInt(VisibilityLevel.premium) : 0,
        'premiumUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set premium requirement: $e');
    }
  }

  @override
  Stream<List<String>> getUserAccessibleContent(String userId) {
    // Get user data first to check premium status
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .asyncExpand((userDoc) {
      final isPremium = userDoc.data()?['isPremium'] ?? false;

      // Build query based on user status
      Query query = _postsCollection;

      if (isPremium) {
        // Premium users can see all content
        query = query.orderBy('createdAt', descending: true);
      } else {
        // Non-premium users can only see public content
        query = query
            .where('visibility', isEqualTo: 0)
            .where('premiumRequired', isEqualTo: false)
            .orderBy('createdAt', descending: true);
      }

      return query
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
    });
  }

  @override
  Future<void> grantAccess(String contentId, String userId) async {
    try {
      final accessRef = _postsCollection
          .doc(contentId)
          .collection('accessControl')
          .doc(userId);

      await accessRef.set({
        'userId': userId,
        'accessLevel': 'full',
        'grantedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to grant access: $e');
    }
  }

  @override
  Future<void> revokeAccess(String contentId, String userId) async {
    try {
      await _postsCollection
          .doc(contentId)
          .collection('accessControl')
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to revoke access: $e');
    }
  }

  @override
  Future<List<AccessControl>> getAccessControlList(String contentId) async {
    try {
      final snapshot = await _postsCollection
          .doc(contentId)
          .collection('accessControl')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AccessControl(
          userId: data['userId'],
          level: _parseAccessLevel(data['accessLevel']),
          grantedAt: (data['grantedAt'] as Timestamp).toDate(),
          expiresAt: data['expiresAt'] != null
              ? (data['expiresAt'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get access control list: $e');
    }
  }

  // Helper methods
  int _visibilityLevelToInt(VisibilityLevel level) {
    switch (level) {
      case VisibilityLevel.public:
        return 0;
      case VisibilityLevel.friends:
        return 1;
      case VisibilityLevel.private:
        return 2;
      case VisibilityLevel.custom:
        return 3;
      case VisibilityLevel.premium:
        return 4;
    }
  }

  VisibilityLevel _intToVisibilityLevel(int value) {
    switch (value) {
      case 1:
        return VisibilityLevel.friends;
      case 2:
        return VisibilityLevel.private;
      case 3:
        return VisibilityLevel.custom;
      case 4:
        return VisibilityLevel.premium;
      default:
        return VisibilityLevel.public;
    }
  }

  Map<String, dynamic> _targetAudienceToMap(TargetAudience audience) {
    return {
      'mode': audience.mode,
      'interests': audience.interests,
      'ageRange': audience.ageRange != null
          ? {
              'min': audience.ageRange!.min,
              'max': audience.ageRange!.max,
            }
          : null,
      'gender': audience.gender,
      'locations': audience.locations,
      'customFilters': audience.customFilters,
    };
  }

  bool _checkTargetAudience(String userId, TargetAudience audience) {
    // TODO: Implement actual target audience matching logic
    // For now, return true for public mode
    return audience.mode == 'public';
  }

  AccessLevel _parseAccessLevel(String levelStr) {
    switch (levelStr) {
      case 'comment':
        return AccessLevel.comment;
      case 'vote':
        return AccessLevel.vote;
      case 'full':
        return AccessLevel.full;
      default:
        return AccessLevel.view;
    }
  }

  @override
  Future<void> sendNotifications(String contentId) async {
    try {
      // Get content details and target audience
      final contentDoc = await _firestore
          .collection('posts')
          .doc(contentId)
          .get();

      if (!contentDoc.exists) {
        throw Exception('Content not found: $contentId');
      }

      final contentData = contentDoc.data()!;
      final targetAudienceData = contentData['targetAudience'] as Map<String, dynamic>?;

      if (targetAudienceData == null) {
        throw Exception('No target audience defined for content: $contentId');
      }

      // Create notification payload
      final notification = {
        'contentId': contentId,
        'type': 'voting_request',
        'title': contentData['questionTitle'] ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'targetAudience': targetAudienceData,
        'status': 'pending',
      };

      // Add to notifications collection
      await _firestore.collection('notifications').add(notification);

      // Update content to mark notifications as sent
      await _firestore.collection('posts').doc(contentId).update({
        'notificationsSent': true,
        'notificationsSentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send notifications: $e');
    }
  }
}