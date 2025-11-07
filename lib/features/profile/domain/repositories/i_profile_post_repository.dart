import 'package:fpdart/fpdart.dart';
import '../entities/user_post_item.dart';
import '../failures/profile_failure.dart';

/// Profile Feature 전용 게시물 Repository 인터페이스
///
/// **Feature 독립성 원칙** (Phase 6.5):
/// - ✅ Profile Feature가 Post Feature에 의존하지 않음
/// - ✅ Firestore posts 컬렉션에 직접 접근 (Infrastructure 의존)
/// - ✅ "내 게시물" 관리 책임을 Profile Feature가 담당
///
/// **Clean Architecture 패턴**:
/// - Repository Interface는 Domain Layer에 위치
/// - Implementation은 Data Layer에서 구현
/// - Firestore는 Infrastructure로 간주 (Feature가 직접 접근 가능)
///
/// **용도**:
/// - 내 게시물 목록 실시간 조회
/// - 내 게시물 수정/삭제 (선택적, 나중에 추가 가능)
///
/// **vs Post Feature**:
/// - Profile Feature: "내 것"만 조회 (userId 필터)
/// - Post Feature: "모든 것" 조회 (소셜 피드)
abstract class IProfilePostRepository {
  /// 내 게시물 목록 실시간 조회
  ///
  /// **쿼리 조건**:
  /// ```dart
  /// posts.where('userId', isEqualTo: userId)
  ///      .orderBy('createdAt', descending: true)
  /// ```
  ///
  /// **반환값**:
  /// - Success: Stream<Either<ProfileFailure, List<UserPostItem>>>
  /// - Error: ProfileFailure (firestoreRead, permissionDenied, etc.)
  ///
  /// **캐싱**: 현재 미적용 (나중에 UnifiedCacheService 통합 가능)
  Stream<Either<ProfileFailure, List<UserPostItem>>> watchMyPosts(String userId);

  // TODO: 나중에 추가 가능한 메서드
  //
  // /// 내 게시물 수정
  // Future<Either<ProfileFailure, Unit>> updateMyPost({
  //   required String postId,
  //   required Map<String, dynamic> updates,
  // });
  //
  // /// 내 게시물 삭제
  // Future<Either<ProfileFailure, Unit>> deleteMyPost(String postId);
}
