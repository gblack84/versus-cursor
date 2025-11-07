import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '../../domain/repositories/i_profile_post_repository.dart';
import '../../domain/entities/user_post_item.dart';
import '../../domain/failures/profile_failure.dart';

/// ProfilePostRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 6.5: Profile Feature 독립성 확보** (2025-01-07):
/// - Post Feature 의존성 완전 제거
/// - Firestore posts 컬렉션 직접 쿼리
/// - "내 게시물" 관리 책임을 Profile Feature로 이동
///
/// **Firebase-Centric v2.0 패턴**:
/// - FirebaseFirestore 직접 사용 (DataSource 제거)
/// - Extension 패턴으로 Entity 변환 (UserPostItem.fromFirestore)
/// - Either 패턴으로 에러 처리
///
/// **책임**:
/// - Firestore posts 컬렉션에서 내 게시물만 조회
/// - 실시간 스트림으로 변경사항 동기화
/// - Firebase Exception → ProfileFailure 매핑
///
/// **vs Post Feature**:
/// - Profile Feature: where('userId', '==', myId) - 내 것만
/// - Post Feature: 모든 게시물 조회 - 소셜 피드
class ProfilePostRepositoryImpl implements IProfilePostRepository {
  final FirebaseFirestore _firestore;

  ProfilePostRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<Either<ProfileFailure, List<UserPostItem>>> watchMyPosts(String userId) {
    try {
      debugPrint('[ProfilePostRepository] Watching my posts for user: $userId');

      return _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId) // 🎯 내 게시물만 필터링
          .orderBy('createdAt', descending: true) // 최신순 정렬
          .snapshots()
          .map((snapshot) {
        try {
          final posts = snapshot.docs
              .map((doc) => UserPostItem.fromFirestore(doc))
              .toList();

          debugPrint('[ProfilePostRepository] Loaded ${posts.length} posts');
          return right<ProfileFailure, List<UserPostItem>>(posts);
        } catch (e) {
          debugPrint('[ProfilePostRepository] Error parsing posts: $e');
          return left<ProfileFailure, List<UserPostItem>>(
            ProfileFailure.firestoreRead('Failed to parse posts: $e'),
          );
        }
      }).handleError((error) {
        debugPrint('[ProfilePostRepository] Stream error: $error');

        if (error is FirebaseException) {
          return left<ProfileFailure, List<UserPostItem>>(
            _mapFirebaseException(error),
          );
        }

        return left<ProfileFailure, List<UserPostItem>>(
          ProfileFailure.firestoreRead('Stream error: $error'),
        );
      });
    } catch (e) {
      debugPrint('[ProfilePostRepository] Unexpected error: $e');
      // 초기 에러는 단일 이벤트로 반환
      return Stream.value(
        left(ProfileFailure.firestoreRead('Failed to watch posts: $e')),
      );
    }
  }

  /// Firebase Exception → ProfileFailure 매핑
  ///
  /// **에러 타입**:
  /// - permission-denied: 권한 없음
  /// - not-found: 문서 없음
  /// - unavailable: 네트워크 에러
  /// - 기타: 일반 Firestore 에러
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    debugPrint('[ProfilePostRepository] Firebase error: ${e.code} - ${e.message}');

    switch (e.code) {
      case 'permission-denied':
        return ProfileFailure.permissionDenied('posts');
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');
      case 'unavailable':
        return ProfileFailure.firestoreRead('Network error: ${e.message}');
      default:
        return ProfileFailure.firestoreRead('${e.code}: ${e.message}');
    }
  }
}
