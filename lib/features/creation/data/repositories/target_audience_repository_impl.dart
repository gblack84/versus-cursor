import '/features/creation/domain/models/value_objects/target_audience.dart';
import '/features/creation/domain/services/i_target_audience_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/failures/creation_failures.dart';

/// Implementation of ITargetAudienceService
///
/// Clean Architecture implementation - Domain service interface implemented in Data layer
///
/// Responsibilities:
/// - TargetAudience를 Firebase Functions가 기대하는 형식으로 변환
/// - 투표 생성 시 타겟 오디언스 정보를 저장
/// - Firestore를 통한 게시물 생성 및 알림 관리
class TargetAudienceRepositoryImpl implements ITargetAudienceService {
  TargetAudienceRepositoryImpl();

  /// TargetAudience를 Firestore 저장용 Map으로 변환
  ///
  /// Firebase Functions의 targetMatcher.js가 기대하는 형식으로 변환합니다.
  Map<String, dynamic> convertModelToFirestore(TargetAudience model) {
    // TargetAudience already has a toMap() method that's Firebase-compatible
    final Map<String, dynamic> firestoreData = model.toMap();

    // Override createdAt with server timestamp for consistency
    firestoreData['createdAt'] = FieldValue.serverTimestamp();

    return firestoreData;
  }

  // Age group conversion is now handled in TargetAudience domain model

  /// 타겟 오디언스 유효성 검사
  ///
  /// 투표 생성 전에 타겟 오디언스 설정이 유효한지 확인합니다.
  @override
  ValidationResult validateTargetAudience(TargetAudience model) {
    // 기본 검증
    if (model.targetCount <= 0) {
      return ValidationResult(
        isValid: false,
        error: '목표 응답 수는 1명 이상이어야 합니다.',
      );
    }

    if (model.targetCount > 1000 && !model.isPremium) {
      return ValidationResult(
        isValid: false,
        error: '무료 사용자는 최대 1000명까지만 선택할 수 있습니다.',
      );
    }

    // Custom 타입 검증 - Use domain model's validation
    if (model.collectionType == 'custom' && !model.isCustomCriteriaValid) {
      return ValidationResult(
        isValid: false,
        error: '맞춤 설정에서는 최소 하나의 조건을 선택해야 합니다.',
      );
    }

    return ValidationResult(isValid: true);
  }

  /// 투표와 타겟 오디언스 정보를 함께 저장
  ///
  /// posts_record에 투표를 생성할 때 targetAudience 필드를 추가합니다.
  Future<Either<TargetAudienceFailure, String>> createPostWithTargetAudience({
    required Map<String, dynamic> postData,
    required TargetAudience targetAudience,
  }) async {
    try {
      // 1. 타겟 오디언스 유효성 검사
      final validation = validateTargetAudience(targetAudience);
      if (!validation.isValid) {
        return left(TargetAudienceFailure(
          validation.error ?? 'Invalid target audience',
          'VALIDATION_FAILED',
        ));
      }

      // 2. 타겟 오디언스 데이터 변환
      final targetAudienceData = convertModelToFirestore(targetAudience);

      // 3. 투표 데이터에 타겟 오디언스 추가
      final completePostData = {
        ...postData,
        'targetAudience': targetAudienceData,
        'notificationStatus': {
          'sent': false,
          'sentAt': null,
          'sentCount': 0,
          'targetCount': targetAudience.targetCount,
          'completedCount': 0,
        },
      };

      // 4. Firestore에 직접 저장
      final docRef = await FirebaseFirestore.instance
          .collection('posts')
          .add(completePostData);

      final postId = docRef.id;

      print('[TargetAudienceService] 투표 생성 완료: $postId');
      print(
          '[TargetAudienceService] 타겟 오디언스: ${targetAudience.collectionType}, ${targetAudience.targetCount}명');

      return right(postId);
    } on FirebaseException catch (e) {
      print('[TargetAudienceService] Firebase 오류: ${e.code} - ${e.message}');
      return left(TargetAudienceFailure(
        'Failed to create post with target audience: ${e.message}',
        e.code,
      ));
    } catch (e) {
      print('[TargetAudienceService] 투표 생성 오류: $e');
      return left(TargetAudienceFailure(
        'Unexpected error creating post: $e',
        'UNKNOWN_ERROR',
      ));
    }
  }

  /// 알림 발송 상태 업데이트
  ///
  /// Cloud Functions에서 알림을 발송한 후 상태를 업데이트할 때 사용합니다.
  Future<Either<TargetAudienceFailure, Unit>> updateNotificationStatus(
    String postId, {
    required int sentCount,
    int? completedCount,
  }) async {
    try {
      final updateData = {
        'notificationStatus.sent': true,
        'notificationStatus.sentAt': FieldValue.serverTimestamp(),
        'notificationStatus.sentCount': sentCount,
      };

      if (completedCount != null) {
        updateData['notificationStatus.completedCount'] = completedCount;
      }

      // Firestore에 직접 업데이트
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update(updateData);

      print('[TargetAudienceService] 알림 상태 업데이트: $postId, 발송: $sentCount명');
      return right(unit);
    } on FirebaseException catch (e) {
      print('[TargetAudienceService] Firebase 오류: ${e.code} - ${e.message}');
      return left(TargetAudienceFailure(
        'Failed to update notification status: ${e.message}',
        e.code,
      ));
    } catch (e) {
      print('[TargetAudienceService] 알림 상태 업데이트 오류: $e');
      return left(TargetAudienceFailure(
        'Unexpected error updating notification status: $e',
        'UNKNOWN_ERROR',
      ));
    }
  }

  /// 타겟 오디언스 통계 조회
  ///
  /// 현재 사용자의 타겟 오디언스 사용 통계를 조회합니다.
  Future<Either<TargetAudienceFailure, TargetAudienceStats>> getUserStats(
      String userId) async {
    try {
      // Firestore에서 직접 조회
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .where('targetAudience', isNotEqualTo: null)
          .limit(100)
          .get();

      final posts = querySnapshot.docs
          .map((doc) => doc.data())
          .toList();

      int totalSent = 0;
      int totalCompleted = 0;
      final Map<String, int> typeCount = {
        'quick': 0,
        'public': 0,
        'custom': 0,
      };

      for (final data in posts) {
        final targetAudience = data['targetAudience'] as Map<String, dynamic>?;
        final notificationStatus =
            data['notificationStatus'] as Map<String, dynamic>?;

        if (targetAudience != null) {
          final type = targetAudience['type'] as String?;
          if (type != null && typeCount.containsKey(type)) {
            typeCount[type] = (typeCount[type] ?? 0) + 1;
          }
        }

        if (notificationStatus != null) {
          totalSent += (notificationStatus['sentCount'] as int? ?? 0);
          totalCompleted += (notificationStatus['completedCount'] as int? ?? 0);
        }
      }

      final stats = TargetAudienceStats(
        totalPosts: posts.length,
        totalSent: totalSent,
        totalCompleted: totalCompleted,
        typeCount: typeCount,
        averageCompletionRate:
            totalSent > 0 ? (totalCompleted / totalSent) : 0.0,
      );

      return right(stats);
    } on FirebaseException catch (e) {
      print('[TargetAudienceService] Firebase 오류: ${e.code} - ${e.message}');
      return left(TargetAudienceFailure(
        'Failed to get user stats: ${e.message}',
        e.code,
      ));
    } catch (e) {
      print('[TargetAudienceService] 통계 조회 오류: $e');
      return left(TargetAudienceFailure(
        'Unexpected error getting user stats: $e',
        'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<TargetAudienceFailure, TargetAudience>> createTargetAudience({
    required String mode,
    required int targetCount,
    List<String>? selectedUserIds,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // Create and return a new TargetAudience instance
      final targetAudience = TargetAudience(
        collectionType: mode,
        targetCount: targetCount,
        // Handle filters for custom mode
        selectedInterests: filters?['interests'] as List<String>? ?? [],
        selectedAgeGroup: filters?['ageGroup'] as String? ?? '전체',
        selectedGender: filters?['gender'] as String? ?? 'all',
        activeUserOnly: filters?['activeUserOnly'] as bool? ?? false,
        createdAt: DateTime.now(),
      );

      return right(targetAudience);
    } catch (e) {
      print('[TargetAudienceService] 타겟 오디언스 생성 오류: $e');
      return left(TargetAudienceFailure(
        'Unexpected error creating target audience: $e',
        'UNKNOWN_ERROR',
      ));
    }
  }

  @override
  Future<Either<TargetAudienceFailure, List<String>>> getRecommendedUsers({
    required String contentId,
    required int count,
  }) async {
    try {
      // This would typically call an AI service or recommendation engine
      // For now, return an empty list
      // TODO: Implement user recommendation logic
      return right([]);
    } catch (e) {
      print('[TargetAudienceService] 추천 사용자 조회 오류: $e');
      return left(TargetAudienceFailure(
        'Unexpected error getting recommended users: $e',
        'UNKNOWN_ERROR',
      ));
    }
  }
}

/// 타겟 오디언스 통계
class TargetAudienceStats {
  final int totalPosts;
  final int totalSent;
  final int totalCompleted;
  final Map<String, int> typeCount;
  final double averageCompletionRate;

  TargetAudienceStats({
    required this.totalPosts,
    required this.totalSent,
    required this.totalCompleted,
    required this.typeCount,
    required this.averageCompletionRate,
  });

  factory TargetAudienceStats.empty() => TargetAudienceStats(
        totalPosts: 0,
        totalSent: 0,
        totalCompleted: 0,
        typeCount: {'quick': 0, 'public': 0, 'custom': 0},
        averageCompletionRate: 0.0,
      );
}
