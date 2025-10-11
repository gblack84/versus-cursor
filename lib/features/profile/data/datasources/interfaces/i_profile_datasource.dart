import 'package:cloud_firestore/cloud_firestore.dart';

/// 프로필 DataSource 인터페이스
///
/// **책임**: Firestore 'users' 컬렉션과의 직접 통신
abstract class IProfileDataSource {
  // ============= 기본 CRUD =============

  /// 프로필 조회
  Future<Map<String, dynamic>?> getProfile(String userId);

  /// 프로필 생성
  Future<void> createProfile(String userId, Map<String, dynamic> data);

  /// 프로필 업데이트
  Future<void> updateProfile(String userId, Map<String, dynamic> data);

  /// 프로필 삭제
  Future<void> deleteProfile(String userId);

  /// 프로필 실시간 감시
  Stream<Map<String, dynamic>?> watchProfile(String userId);

  // ============= 필드 업데이트 =============

  /// 특정 필드 업데이트
  Future<void> updateField(String userId, String field, dynamic value);

  /// 여러 필드 업데이트
  Future<void> updateFields(String userId, Map<String, dynamic> fields);

  /// 배열에 값 추가 (FieldValue.arrayUnion)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 370-380
  /// - hobbies_select_widget.dart: line 130-140
  Future<void> arrayUnion(String userId, String field, List<dynamic> values);

  /// 배열에서 값 제거 (FieldValue.arrayRemove)
  ///
  /// **레거시 패턴 지원**:
  /// - expertise_select_widget.dart: line 559-569
  /// - hobbies_select_widget.dart: line 319-329
  Future<void> arrayRemove(String userId, String field, List<dynamic> values);

  // ============= 검색 및 쿼리 =============

  /// 프로필 검색 (이름, 관심사, 위치 등)
  Future<List<Map<String, dynamic>>> searchProfiles({
    String? query,
    List<String>? interests,
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    GeoPoint? userLocation,
    int limit = 20,
  });

  /// 추천 프로필 조회 (AI 기반)
  Future<List<Map<String, dynamic>>> getSuggestedProfiles(
    String userId, {
    int limit = 10,
  });

  // ============= 소셜 기능 =============

  /// 사용자 차단
  Future<void> blockUser(String userId, String blockedUserId);

  /// 사용자 차단 해제
  Future<void> unblockUser(String userId, String blockedUserId);

  /// 차단된 사용자 목록 조회
  Future<List<String>> getBlockedUsers(String userId);

  /// 사용자 신고
  Future<void> reportUser(
    String userId,
    String reportedUserId,
    String reason,
  );

  // ============= 프로필 완성도 =============

  /// 프로필 완성도 확인
  Future<bool> isProfileComplete(String userId);

  /// 프로필 완성도 퍼센트 계산
  Future<double> getProfileCompletionPercentage(String userId);
}
