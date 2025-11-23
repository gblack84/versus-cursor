import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/specialized/i_visibility_repository.dart';
import '../../domain/usecases/audience/manage_target_audience_usecase.dart';
import '../../domain/failures/creation_failure.dart';

/// Implementation of content visibility repository
/// Target Audience 시스템과 연동되는 접근 제어 구현체
class ContentVisibilityRepositoryImpl implements IContentVisibilityRepository {
  final FirebaseFirestore _firestore;
  final ManageTargetAudienceUseCase? _targetAudienceUseCase;
  static const String _collection = 'posts';

  ContentVisibilityRepositoryImpl({
    FirebaseFirestore? firestore,
    ManageTargetAudienceUseCase? targetAudienceUseCase,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _targetAudienceUseCase = targetAudienceUseCase;

  CollectionReference get _postsCollection =>
      _firestore.collection(_collection);

  @override
  Future<Either<CreationFailure, Unit>> setVisibility(
    String contentId,
    VisibilityLevel level,
  ) async {
    try {
      await _postsCollection.doc(contentId).update({
        'visibility': _visibilityLevelToInt(level),
        'visibilityUpdatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: level.name,
          // message:'Failed to set visibility: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: level.name,
          // message:'Unexpected error setting visibility: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> canUserView(
    String contentId,
    String userId,
  ) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'unknown',
            // message:'Content not found',
            // code:'content-not-found',
          ),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final visibility = _intToVisibilityLevel(data['visibility'] ?? 0);

      bool canView = false;
      switch (visibility) {
        case VisibilityLevel.public:
          canView = true;
          break;
        case VisibilityLevel.private:
          canView = data['creatorInfo']?['userid'] == userId;
          break;
        case VisibilityLevel.friends:
          // Check if user is a friend
          final creatorId = data['creatorInfo']?['userid'];
          if (creatorId == userId) {
            canView = true;
          } else {
            // TODO: Implement friend check
            canView = false;
          }
          break;
        case VisibilityLevel.custom:
          // Use target audience logic
          if (_targetAudienceUseCase != null) {
            final audienceResult = await getTargetAudience(contentId);
            canView = audienceResult.fold(
              (l) => false,
              (audience) => _checkTargetAudience(userId, audience),
            );
          } else {
            canView = false;
          }
          break;
        case VisibilityLevel.premium:
          // Check if user has premium
          final userDoc = await _firestore
              .collection('users')
              .doc(userId)
              .get();
          canView = userDoc.data()?['isPremium'] ?? false;
          break;
      }

      if (canView) {
        return right(unit);
      } else {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: visibility.name,
            // message:'User does not have permission to view this content',
            // code:'access-denied',
          ),
        );
      }
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'unknown',
          // message:'Failed to check user view permission: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'unknown',
          // message:'Unexpected error checking user view permission: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, TargetAudience>> getTargetAudience(
    String contentId,
  ) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'unknown',
            // message:'Content not found',
            // code:'content-not-found',
          ),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final targetAudienceData =
          data['targetAudience'] as Map<String, dynamic>?;

      if (targetAudienceData == null) {
        return right(TargetAudience(mode: 'public'));
      }

      final audience = TargetAudience(
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
      return right(audience);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'custom',
          // message:'Failed to get target audience: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'custom',
          // message:'Unexpected error getting target audience: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updateTargetAudience(
    String contentId,
    TargetAudience audience,
  ) async {
    try {
      // Phase 5 Restoration: Use _targetAudienceToMap()
      // Note: This TargetAudience type is from i_content_visibility_repository.dart
      // It's different from domain/entities/target_audience.dart
      // Validation is already done by ManageTargetAudienceUseCase in CreatePostUseCase
      await _postsCollection.doc(contentId).update({
        'targetAudience': _targetAudienceToMap(audience),
        'targetAudienceUpdatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'custom',
          // message:'Failed to update target audience: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'custom',
          // message:'Unexpected error updating target audience: $e',
        ),
      );
    }
  }

  @override
  Stream<Either<CreationFailure, List<String>>> getContentByVisibility(
    VisibilityLevel level,
  ) {
    return _postsCollection
        .where('visibility', isEqualTo: _visibilityLevelToInt(level))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          try {
            final contentIds = snapshot.docs.map((doc) => doc.id).toList();
            return right<CreationFailure, List<String>>(contentIds);
          } catch (_) {
            return left<CreationFailure, List<String>>(
              CreationFailure.visibilityRepositoryFailed(
                visibility: level.name,
                // message:'Failed to get content by visibility: $e',
              ),
            );
          }
        })
        .handleError((error) {
          return left<CreationFailure, List<String>>(
            CreationFailure.visibilityRepositoryFailed(visibility: level.name),
          );
        });
  }

  @override
  Future<Either<CreationFailure, Unit>> setAnonymous(
    String contentId,
    bool isAnonymous,
  ) async {
    try {
      await _postsCollection.doc(contentId).update({
        'isAnonymous': isAnonymous,
        'anonymousUpdatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'anonymous',
          // message:'Failed to set anonymous: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'anonymous',
          // message:'Unexpected error setting anonymous: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> isPremiumRequired(
    String contentId,
  ) async {
    try {
      final doc = await _postsCollection.doc(contentId).get();
      if (!doc.exists) {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'premium',
            // message:'Content not found',
            // code:'content-not-found',
          ),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final isPremium = data['premiumRequired'] ?? false;

      if (isPremium) {
        return right(unit);
      } else {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'premium',
            // message:'Premium not required',
            // code:'premium-not-required',
          ),
        );
      }
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'premium',
          // message:'Failed to check premium requirement: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'premium',
          // message:'Unexpected error checking premium requirement: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> setPremiumRequired(
    String contentId,
    bool required,
  ) async {
    try {
      await _postsCollection.doc(contentId).update({
        'premiumRequired': required,
        'visibility': required
            ? _visibilityLevelToInt(VisibilityLevel.premium)
            : 0,
        'premiumUpdatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'premium',
          // message:'Failed to set premium requirement: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'premium',
          // message:'Unexpected error setting premium requirement: $e',
        ),
      );
    }
  }

  @override
  Stream<Either<CreationFailure, List<String>>> getUserAccessibleContent(
    String userId,
  ) {
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

          return query.snapshots().map((snapshot) {
            try {
              final contentIds = snapshot.docs.map((doc) => doc.id).toList();
              return right<CreationFailure, List<String>>(contentIds);
            } catch (_) {
              return left<CreationFailure, List<String>>(
                CreationFailure.visibilityRepositoryFailed(
                  visibility: 'user-accessible',
                  // message:'Failed to get user accessible content: $e',
                ),
              );
            }
          });
        })
        .handleError((error) {
          return left<CreationFailure, List<String>>(
            CreationFailure.visibilityRepositoryFailed(
              visibility: 'user-accessible',
            ),
          );
        });
  }

  @override
  Future<Either<CreationFailure, Unit>> grantAccess(
    String contentId,
    String userId,
  ) async {
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
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Failed to grant access: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Unexpected error granting access: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> revokeAccess(
    String contentId,
    String userId,
  ) async {
    try {
      await _postsCollection
          .doc(contentId)
          .collection('accessControl')
          .doc(userId)
          .delete();
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Failed to revoke access: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Unexpected error revoking access: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, List<AccessControl>>> getAccessControlList(
    String contentId,
  ) async {
    try {
      final snapshot = await _postsCollection
          .doc(contentId)
          .collection('accessControl')
          .get();

      final accessList = snapshot.docs.map((doc) {
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
      return right(accessList);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Failed to get access control list: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'access-control',
          // message:'Unexpected error getting access control list: $e',
        ),
      );
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
          ? {'min': audience.ageRange!.min, 'max': audience.ageRange!.max}
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
  Future<Either<CreationFailure, Unit>> sendNotifications(
    String contentId,
  ) async {
    try {
      // Get content details and target audience
      final contentDoc = await _firestore
          .collection('posts')
          .doc(contentId)
          .get();

      if (!contentDoc.exists) {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'notification',
            // message:'Content not found: $contentId',
            // code:'content-not-found',
          ),
        );
      }

      final contentData = contentDoc.data()!;
      final targetAudienceData =
          contentData['targetAudience'] as Map<String, dynamic>?;

      if (targetAudienceData == null) {
        return left(
          CreationFailure.visibilityRepositoryFailed(
            visibility: 'notification',
            // message:'No target audience defined for content: $contentId',
            // code:'no-target-audience',
          ),
        );
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

      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'notification',
          // message:'Failed to send notifications: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.visibilityRepositoryFailed(
          visibility: 'notification',
          // message:'Unexpected error sending notifications: $e',
        ),
      );
    }
  }
}
