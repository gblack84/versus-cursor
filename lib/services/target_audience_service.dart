import 'package:cloud_firestore/cloud_firestore.dart';
import '/posts/in_put_post_image/models/target_audience_model.dart';

/// 타겟 오디언스 관련 서비스
/// 
/// TargetAudienceModel을 Firebase Functions가 기대하는 형식으로 변환하고,
/// 투표 생성 시 타겟 오디언스 정보를 저장합니다.
class TargetAudienceService {
  // 싱글톤 인스턴스
  static final TargetAudienceService _instance = TargetAudienceService._internal();
  static TargetAudienceService get instance => _instance;
  
  TargetAudienceService._internal();

  /// TargetAudienceModel을 Firestore 저장용 Map으로 변환
  /// 
  /// Firebase Functions의 targetMatcher.js가 기대하는 형식으로 변환합니다.
  Map<String, dynamic> convertModelToFirestore(TargetAudienceModel model) {
    final Map<String, dynamic> firestoreData = {
      'type': model.collectionType, // quick, public, custom
      'targetCount': model.targetCount,
      'isPremium': model.isPremium,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending', // pending -> processing -> completed
    };

    // custom 타입일 때만 criteria 추가
    if (model.collectionType == 'custom') {
      final Map<String, dynamic> criteria = {};
      
      // 관심사 (interest_record의 document IDs)
      if (model.selectedInterests.isNotEmpty) {
        criteria['interests'] = model.selectedInterests;
      }
      
      // 연령대
      if (model.selectedAgeGroup != '전체') {
        criteria['ageGroup'] = _convertAgeGroupToFirestore(model.selectedAgeGroup);
      }
      
      // 성별
      if (model.selectedGender != 'all') {
        criteria['gender'] = model.selectedGender;
      }
      
      // 활성 사용자 필터
      criteria['activeUserOnly'] = model.activeUserOnly;
      
      firestoreData['criteria'] = criteria;
    }

    return firestoreData;
  }

  /// 한국어 연령대를 Firestore 형식으로 변환
  String _convertAgeGroupToFirestore(String koreanAgeGroup) {
    final Map<String, String> ageMapping = {
      '10대': '10s',
      '20대': '20s',
      '30대': '30s',
      '40대': '40s',
      '50대 이상': '50s+',
      '전체': 'all',
    };
    
    return ageMapping[koreanAgeGroup] ?? 'all';
  }

  /// 타겟 오디언스 유효성 검사
  /// 
  /// 투표 생성 전에 타겟 오디언스 설정이 유효한지 확인합니다.
  ValidationResult validateTargetAudience(TargetAudienceModel model) {
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

    // Custom 타입 검증
    if (model.collectionType == 'custom') {
      // 최소 하나의 조건은 설정되어야 함
      final hasInterests = model.selectedInterests.isNotEmpty;
      final hasAgeGroup = model.selectedAgeGroup != '전체';
      final hasGender = model.selectedGender != 'all';
      
      if (!hasInterests && !hasAgeGroup && !hasGender) {
        return ValidationResult(
          isValid: false,
          error: '맞춤 설정에서는 최소 하나의 조건을 선택해야 합니다.',
        );
      }
    }

    return ValidationResult(isValid: true);
  }

  /// 투표와 타겟 오디언스 정보를 함께 저장
  /// 
  /// posts_record에 투표를 생성할 때 targetAudience 필드를 추가합니다.
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> postData,
    required TargetAudienceModel targetAudience,
  }) async {
    try {
      // 1. 타겟 오디언스 유효성 검사
      final validation = validateTargetAudience(targetAudience);
      if (!validation.isValid) {
        throw Exception(validation.error);
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

      // 4. Firestore에 저장
      final docRef = await FirebaseFirestore.instance
          .collection('posts')
          .add(completePostData);

      print('[TargetAudienceService] 투표 생성 완료: ${docRef.id}');
      print('[TargetAudienceService] 타겟 오디언스: ${targetAudience.collectionType}, ${targetAudience.targetCount}명');

      return docRef.id;

    } catch (e) {
      print('[TargetAudienceService] 투표 생성 오류: $e');
      rethrow;
    }
  }

  /// 알림 발송 상태 업데이트
  /// 
  /// Cloud Functions에서 알림을 발송한 후 상태를 업데이트할 때 사용합니다.
  Future<void> updateNotificationStatus(
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

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update(updateData);

      print('[TargetAudienceService] 알림 상태 업데이트: $postId, 발송: $sentCount명');

    } catch (e) {
      print('[TargetAudienceService] 알림 상태 업데이트 오류: $e');
    }
  }

  /// 타겟 오디언스 통계 조회
  /// 
  /// 현재 사용자의 타겟 오디언스 사용 통계를 조회합니다.
  Future<TargetAudienceStats> getUserStats(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('user', isEqualTo: userId)
          .where('targetAudience', isNotEqualTo: null)
          .orderBy('targetAudience')
          .orderBy('createdTime', descending: true)
          .limit(100)
          .get();

      int totalSent = 0;
      int totalCompleted = 0;
      final Map<String, int> typeCount = {
        'quick': 0,
        'public': 0,
        'custom': 0,
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final targetAudience = data['targetAudience'] as Map<String, dynamic>?;
        final notificationStatus = data['notificationStatus'] as Map<String, dynamic>?;

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

      return TargetAudienceStats(
        totalPosts: querySnapshot.size,
        totalSent: totalSent,
        totalCompleted: totalCompleted,
        typeCount: typeCount,
        averageCompletionRate: totalSent > 0 ? (totalCompleted / totalSent) : 0.0,
      );

    } catch (e) {
      print('[TargetAudienceService] 통계 조회 오류: $e');
      return TargetAudienceStats.empty();
    }
  }
}

/// 유효성 검사 결과
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult({
    required this.isValid,
    this.error,
  });
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