import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/models/post_display_extensions.dart';

part 'profile_post_providers.g.dart';

/// Profile Feature 전용: 사용자 게시물 스트림 Provider
///
/// **Architecture**: Feature-First - Profile Feature 자체 Provider
/// - ✅ Post Feature 의존성 제거 (Firebase 직접 쿼리)
/// - ✅ Riverpod 2.x StreamProvider.autoDispose.family
/// - ✅ 실시간 동기화 (Firestore Stream)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// @param userId - 조회할 사용자 ID
/// @param limit - 조회할 게시물 최대 개수 (default: 5)
/// @returns Stream<List<PostDisplay>> - 실시간 게시물 목록
@riverpod
Stream<List<PostDisplay>> profileUserPostsStream(
  Ref ref,
  String userId, {
  int limit = 5,
}) async* {
  final firestore = FirebaseFirestore.instance;

  // Firestore Query: userId로 필터링, 최신순 정렬, 최대 limit개
  final snapshot = firestore
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots();

  // Stream 변환: QuerySnapshot → List<PostDisplay>
  await for (final data in snapshot) {
    final posts = data.docs
        .map((doc) => PostDisplayFirestore.fromFirestore(doc))
        .toList();
    yield posts;
  }
}

/// Profile Feature 전용: 사용자 게시물 개수 조회
///
/// **사용처**:
/// - 프로필 통계 표시
///
/// @param userId - 조회할 사용자 ID
/// @returns Future<int> - 사용자 게시물 총 개수
@riverpod
Future<int> profileUserPostsCount(
  Ref ref,
  String userId,
) async {
  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore
      .collection('posts')
      .where('userId', isEqualTo: userId)
      .count()
      .get();

  return snapshot.count ?? 0;
}
