import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/app/di.dart';
import '../../domain/repositories/i_profile_post_repository.dart';
import '../../domain/entities/user_post_item.dart';

part 'profile_post_providers.g.dart';

// ========================================
// Profile Post Providers (Phase 6.5)
// ========================================
//
// **Feature 독립성 원칙** (2025-01-07 업데이트):
// - ✅ Post Feature 의존성 완전 제거 (PostDisplay → UserPostItem)
// - ✅ Repository 패턴 도입 (직접 Firestore 쿼리 → Repository)
// - ✅ Clean Architecture 준수 (Domain → Data → Infrastructure)
// - ✅ "내 게시물" 관리 책임을 Profile Feature가 담당
//
// **Riverpod 3.x 패턴**:
// - @riverpod 코드 생성
// - StreamProvider.autoDispose.family 자동 생성
// - GetIt DI 연동

/// ProfilePostRepository Provider (GetIt Wrapper)
///
/// **DI 패턴**:
/// - GetIt에 등록된 IProfilePostRepository 인스턴스 반환
/// - Singleton으로 관리
@riverpod
IProfilePostRepository profilePostRepository(Ref ref) {
  return getIt<IProfilePostRepository>();
}

/// 내 게시물 목록 Stream Provider
///
/// **사용법**:
/// ```dart
/// final postsAsync = ref.watch(myPostsStreamProvider(userId));
///
/// postsAsync.when(
///   data: (posts) => ListView.builder(...),
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
/// );
/// ```
///
/// **특징**:
/// - StreamProvider.autoDispose.family 자동 생성
/// - userId 파라미터로 사용자별 게시물 조회
/// - Either → List 변환으로 UI 친화적
/// - 에러 시 빈 리스트 반환 (UI에서 AsyncValue.error로 처리)
///
/// **실시간 동기화**:
/// - Firestore snapshots() 사용
/// - 게시물 생성/수정/삭제 시 자동 업데이트
///
/// **자동 dispose**:
/// - Widget이 unmount되면 자동으로 구독 해제
/// - 메모리 누수 방지
///
/// **vs 이전 구현**:
/// - Before: PostDisplay (20+ fields) + Post Feature 의존
/// - After: UserPostItem (5 fields) + Repository 패턴
@riverpod
Stream<List<UserPostItem>> myPostsStream(
  Ref ref,
  String userId,
) {
  final repository = ref.watch(profilePostRepositoryProvider);

  return repository.watchMyPosts(userId).map(
        (either) => either.fold(
          (failure) {
            // 에러 발생 시 빈 리스트 반환
            // UI에서는 AsyncValue.error로 처리됨
            return <UserPostItem>[];
          },
          (posts) => posts,
        ),
      );
}

/// Profile Feature 전용: 프로필 페이지 최근 게시물 (제한된 개수)
///
/// **사용처**:
/// - ProfilePageWidget: 프로필 페이지에서 최근 게시물 5개 표시
///
/// **특징**:
/// - myPostsStream의 결과를 limit 개수만큼 제한
/// - UI 최적화를 위한 Provider
@riverpod
Stream<List<UserPostItem>> profileUserPostsStream(
  Ref ref,
  String userId, {
  int limit = 5,
}) {
  // myPostsStreamProvider로부터 Stream을 받아서 limit 적용
  return myPostsStream(ref, userId).map(
    (posts) => posts.take(limit).toList(),
  );
}
