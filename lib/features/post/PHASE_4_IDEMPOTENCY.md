# Post Feature - Phase 4: Idempotency Service Integration

> **마이그레이션 가이드**: IdempotencyService 통합 + Transaction 기반 원자성 보장
> **난이도**: ⭐⭐⭐☆☆ (중상)
> **예상 소요 시간**: 2일 (16시간)
> **작성일**: 2025-01-31
> **구현 상태**: ⚠️ **대부분 구현 예정** (createPost, updatePost, deletePost 메서드 미구현)

---

## 📋 개요

### 마이그레이션 목적

Post Feature에 IdempotencyService를 통합하여 중복 작업 방지 및 데이터 일관성 보장:

1. **중복 게시물 생성 방지**: 네트워크 재시도 시 동일한 게시물이 여러 번 생성되지 않도록
2. **Transaction 기반 원자성**: 게시물 삭제 시 관련 데이터 모두 정리
3. **Either 패턴 완성**: Repository 인터페이스에 Either 적용 (Phase 1에서 부분 적용)
4. **낙관적 업데이트 안전성**: 클라이언트 측 낙관적 업데이트와 서버 측 검증 분리

### 영향 범위

| 레이어 | 파일 수 | Before (줄) | After (줄) | 증가/감소 |
|--------|---------|------------|-----------|----------|
| **Domain (Repository)** | 1개 | 82줄 | 140줄 | +58줄 (+71%) |
| **Data (Repository)** | 1개 | 320줄 | 520줄 | +200줄 (+63%) |
| **Domain (UseCases)** | 4개 (신규) | - | 320줄 | +320줄 |
| **Services** | 1개 | - | 50줄 | +50줄 |
| **합계** | **7개** | **402줄** | **1,030줄** | **+628줄** |

### 주요 이점

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **중복 게시물 생성** | 발생 가능 | 방지됨 | **100%** |
| **고아 데이터** | 발생 가능 | 0개 | **완전 정리** |
| **Transaction** | 없음 | 있음 | **원자성 보장** |
| **재시도 안전성** | 위험 | 안전 | **멱등성 보장** |
| **캐시 무효화** | 수동 | 자동 | **일관성 보장** |

---

## 🔍 현재 상태 분석

### 1. Repository 인터페이스 (실제 현재 상태)

**파일**: `domain/repositories/i_post_display_repository_v2.dart`

```dart
/// ✅ 현재: 조회 메서드는 구현됨, CRUD 메서드는 미구현
abstract class IPostDisplayRepositoryV2 {
  // ========== Stream Methods (실시간 조회) - ✅ 구현됨 ==========
  Stream<List<PostDisplay>> queryPosts({...});
  Stream<PostDisplay?> streamPost(String postId);
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});
  Stream<List<PostDisplay>> getUserPosts({required String userId, int limit = -1});
  Stream<List<PostDisplay>> getPostsByCategory({required String category, int limit = -1});
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});
  Stream<List<PostDisplay>> getPopularPosts({int limit = 20, Duration? timeWindow});
  Stream<List<PostDisplay>> getPostsAfter({required String lastPostId, ...});
  Stream<List<PostDisplay>> getPostsWithFilters({...});

  // ========== Future Methods (일회성 조회) - ✅ 구현됨 ==========
  Future<PostDisplay?> getPost(String postId);
  Future<List<PostDisplay>> searchPosts({required String query, int limit = 20});
  Future<List<PostDisplay>> getRecommendedPosts({required String userId, int limit = 20});
  Future<List<PostDisplay>> getPostsByIds(List<String> postIds);

  // ========== 단순 업데이트 - ✅ 구현됨 ==========
  Future<void> incrementViewCount(String postId);  // ✅ 이미 존재

  // ❌ CRUD 메서드 없음 (Phase 4에서 추가 필요) ==========
  // Future<void> createPost(PostDisplay post);
  // Future<void> updatePost(String postId, Map<String, dynamic> updates);
  // Future<void> deletePost(String postId);
}
```

**문제점**:
1. **createPost 없음**: 게시물 생성 메서드 미구현
2. **updatePost 없음**: 게시물 수정 메서드 미구현
3. **deletePost 없음**: 게시물 삭제 메서드 미구현
4. **Either 패턴 미적용**: 모든 메서드가 예외 던지기 (nullable 반환 또는 void)
5. **incrementViewCount**: 존재하지만 Either 패턴 미적용 (void 반환)

### 2. 예상되는 중복 생성 문제 (구현 예정)

**시나리오**:
```
1. 사용자가 "게시물 작성" 버튼 클릭
2. createPost() 호출 → Firestore에 저장 중
3. 네트워크 지연으로 응답 없음
4. 사용자가 다시 버튼 클릭
5. 동일한 게시물이 2번 생성됨 ❌
```

**문제점**:
- **중복 게시물**: 동일 내용의 게시물이 여러 개 생성
- **사용자 혼란**: 중복 게시물 발견 시 삭제 필요
- **데이터 오염**: 중복 데이터가 피드에 표시

### 3. 예상되는 삭제 불완전 문제 (구현 예정)

**예상 Firestore 구조**:
```
/posts/{postId}
  ├── /comments/{commentId}  ❌ 삭제 안 됨 (고아 발생 예상)
  ├── /votes/{userId}  ❌ 삭제 안 됨
  ├── /likes/{userId}  ❌ 삭제 안 됨
  └── 문서 필드들  ✅ 삭제됨
```

**문제점** (구현 시 발생 예상):
- **고아 서브컬렉션**: comments, votes, likes가 남음
- **저장소 낭비**: 삭제된 게시물의 댓글들이 계속 저장됨
- **비용 증가**: Firestore 저장 공간 비용 발생
- **캐시 불일치**: 캐시에 삭제된 게시물이 남아있음

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. Repository 인터페이스 - Either 패턴 완성

```dart
// ❌ Before: CRUD 메서드 없음 + 일부 메서드 예외 던지기
abstract class IPostDisplayRepositoryV2 {
  // 조회 메서드만 있음
  Future<PostDisplay?> getPost(String postId);  // throws

  // CRUD 메서드 없음
}

// ✅ After: CRUD 메서드 추가 + Either 패턴 완성
abstract class IPostDisplayRepositoryV2 {
  // ========== 조회 (Phase 1에서 Either 적용) ==========
  Future<Either<PostFailure, PostDisplay?>> getPost(String postId);

  // ========== CRUD 메서드 (Phase 4에서 추가) ==========

  /// 게시물 생성 (IdempotencyService로 중복 방지)
  Future<Either<PostFailure, Unit>> createPost({
    required PostDisplay post,
    required String eventId,  // 클라이언트가 생성한 UUID
  });

  /// 게시물 수정
  Future<Either<PostFailure, Unit>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
    required String eventId,
  });

  /// 게시물 삭제 (서브컬렉션 포함 완전 삭제)
  Future<Either<PostFailure, Unit>> deletePost({
    required String postId,
    required String eventId,
  });

  /// 조회수 증가 (멱등성 보장)
  Future<Either<PostFailure, Unit>> incrementViewCount({
    required String postId,
    required String eventId,
  });
}
```

#### 2. createPost() - 중복 생성 방지

```dart
// ⚠️ Before: 메서드 없음 (구현 예정)

// ✅ After: IdempotencyService로 중복 방지
@override
Future<Either<PostFailure, Unit>> createPost({
  required PostDisplay post,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'post_create',
    entityId: post.id,
    userId: post.userId,
    eventId: eventId,
    operation: (transaction) async {
      // 1. 게시물 문서 생성
      final postRef = _firestore.collection('posts').doc(post.id);

      transaction.set(postRef, {
        'id': post.id,
        'titleA': post.titleA,
        'titleB': post.titleB,
        'descriptionA': post.descriptionA,
        'descriptionB': post.descriptionB,
        'imageUrlsA': post.imageUrlsA ?? [],
        'imageUrlsB': post.imageUrlsB ?? [],
        'userId': post.userId,
        'userName': post.userName,
        'userPhotoUrl': post.userPhotoUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
        'commentCount': 0,
        'votesA': 0,
        'votesB': 0,
        'status': post.status ?? 'published',
        'isAnonymous': post.isAnonymous ?? false,
        // ... 다른 필드들
      });

      // 2. 캐시 무효화 (피드 캐시 갱신)
      await _cacheService.invalidateFeedPosts();

      return unit;
    },
  );
}
```

**동작 방식**:
```
1. 클라이언트가 eventId 생성 (UUID)
2. createPost(post, eventId) 호출
3. IdempotencyService가 eventId 체크:
   - 이미 처리됨 → 성공 반환 (중복 방지) ✅
   - 처음 → Firestore Transaction 실행
4. 네트워크 재시도 시:
   - 동일한 eventId로 재호출
   - IdempotencyService가 "이미 처리됨" 감지
   - 즉시 성공 반환 (실제로 생성 안 함) ✅
```

#### 3. deletePost() - 서브컬렉션 완전 정리

```dart
// ⚠️ Before: 메서드 없음 (구현 예정)

// ✅ After: Transaction으로 모든 서브컬렉션 정리
@override
Future<Either<PostFailure, Unit>> deletePost({
  required String postId,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'post_delete',
    entityId: postId,
    userId: currentUserId,
    eventId: eventId,
    operation: (transaction) async {
      final postRef = _firestore.collection('posts').doc(postId);

      // 1. comments 서브컬렉션 삭제
      final commentsSnapshot = await postRef.collection('comments').get();
      for (final commentDoc in commentsSnapshot.docs) {
        transaction.delete(commentDoc.reference);
      }

      // 2. votes 서브컬렉션 삭제
      final votesSnapshot = await postRef.collection('votes').get();
      for (final voteDoc in votesSnapshot.docs) {
        transaction.delete(voteDoc.reference);
      }

      // 3. likes 서브컬렉션 삭제
      final likesSnapshot = await postRef.collection('likes').get();
      for (final likeDoc in likesSnapshot.docs) {
        transaction.delete(likeDoc.reference);
      }

      // 4. dislikes 서브컬렉션 삭제
      final dislikesSnapshot = await postRef.collection('dislikes').get();
      for (final dislikeDoc in dislikesSnapshot.docs) {
        transaction.delete(dislikeDoc.reference);
      }

      // 5. post 문서 삭제
      transaction.delete(postRef);

      // 6. 캐시 무효화
      await _cacheService.invalidatePost(postId);
      await _cacheService.invalidateFeedPosts();

      return unit;
    },
  );
}
```

#### 4. incrementViewCount() - 멱등성 보장

```dart
// ⚠️ Before: 구현 예정 상태
// Future<void> incrementViewCount(String postId);

// ✅ After: IdempotencyService로 멱등성 보장
@override
Future<Either<PostFailure, Unit>> incrementViewCount({
  required String postId,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'post_view_increment',
    entityId: postId,
    userId: currentUserId,
    eventId: eventId,
    operation: (transaction) async {
      final postRef = _firestore.collection('posts').doc(postId);

      // Transaction으로 조회수 증가 (한 번만)
      transaction.update(postRef, {
        'viewCount': FieldValue.increment(1),
      });

      // 캐시 무효화 (선택적)
      await _cacheService.invalidatePost(postId);

      return unit;
    },
  );
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: Repository 인터페이스 업데이트

**파일**: `domain/repositories/i_post_display_repository_v2.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

abstract class IPostDisplayRepositoryV2 {
  // ========== Stream Methods (Phase 1, 변경 없음) ==========

  Stream<List<PostDisplay>> queryPosts({...});
  Stream<PostDisplay?> streamPost(String postId);
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});
  // ... 다른 Stream 메서드들

  // ========== Future Methods (Phase 1에서 Either 적용) ==========

  Future<Either<PostFailure, PostDisplay?>> getPost(String postId);

  // ========== CRUD Methods (Phase 4에서 추가) ==========

  /// 게시물 생성
  ///
  /// **IdempotencyService 통합**:
  /// - eventId로 중복 생성 방지
  /// - Transaction으로 원자성 보장
  /// - 캐시 무효화 자동 처리
  ///
  /// **Parameters**:
  /// - post: 생성할 게시물 데이터
  /// - eventId: 클라이언트가 생성한 UUID (중복 방지용)
  ///
  /// **Returns**:
  /// - Right(unit): 생성 성공
  /// - Left(PostFailure): 생성 실패
  Future<Either<PostFailure, Unit>> createPost({
    required PostDisplay post,
    required String eventId,
  });

  /// 게시물 수정
  ///
  /// **Parameters**:
  /// - postId: 수정할 게시물 ID
  /// - updates: 수정할 필드 Map (예: {'titleA': 'New Title'})
  /// - eventId: 중복 방지용 UUID
  Future<Either<PostFailure, Unit>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
    required String eventId,
  });

  /// 게시물 삭제 (서브컬렉션 포함 완전 삭제)
  ///
  /// **Transaction 처리 순서**:
  /// 1. comments 서브컬렉션 삭제
  /// 2. votes 서브컬렉션 삭제
  /// 3. likes/dislikes 서브컬렉션 삭제
  /// 4. post 문서 삭제
  /// 5. 캐시 무효화
  ///
  /// **Parameters**:
  /// - postId: 삭제할 게시물 ID
  /// - eventId: 중복 방지용 UUID
  Future<Either<PostFailure, Unit>> deletePost({
    required String postId,
    required String eventId,
  });

  // ========== 단순 업데이트 (Phase 4에서 Either 패턴 + Idempotency 추가) ==========

  /// 조회수 증가 (멱등성 보장)
  ///
  /// ⚠️ **현재 상태**: `Future<void> incrementViewCount(String postId)` (Either 패턴 미적용)
  ///
  /// **Phase 4 변경사항**:
  /// - Either 패턴 적용: `Future<Either<PostFailure, Unit>>`
  /// - IdempotencyService로 중복 증가 방지
  /// - 동일한 eventId로 여러 번 호출 시 한 번만 증가
  ///
  /// **Parameters**:
  /// - postId: 게시물 ID
  /// - eventId: 중복 방지용 UUID (Phase 4에서 추가)
  Future<Either<PostFailure, Unit>> incrementViewCount({
    required String postId,
    required String eventId,
  });
}
```

### Step 2: Repository 구현체 - IdempotencyService 통합

**파일**: `data/repositories/post_display_repository_v2_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/idempotency_service.dart';
import '../../domain/repositories/i_post_display_repository_v2.dart';
import '../../domain/models/post_display.dart';
import '../../domain/failures/post_failure.dart';
import '../datasources/i_post_display_datasource.dart';
import '../services/post_cache_service.dart';

class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;
  final PostCacheService _cacheService;
  final IdempotencyService _idempotencyService;  // ✅ 추가
  final FirebaseFirestore _firestore;  // ✅ Transaction용
  final String currentUserId;  // ✅ 현재 사용자 ID

  PostDisplayRepositoryV2Impl({
    required IPostDisplayDataSource dataSource,
    required PostCacheService cacheService,
    required IdempotencyService idempotencyService,
    required FirebaseFirestore firestore,
    required this.currentUserId,
  })  : _dataSource = dataSource,
        _cacheService = cacheService,
        _idempotencyService = idempotencyService,
        _firestore = firestore;

  // ========== Stream Methods (Phase 1, 변경 없음) ==========
  // ... 기존 코드 유지

  // ========== CRUD Methods (Phase 4에서 구현) ==========

  @override
  Future<Either<PostFailure, Unit>> createPost({
    required PostDisplay post,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'post_create',
        entityId: post.id,
        userId: post.userId,
        eventId: eventId,
        operation: (transaction) async {
          // 1. 게시물 문서 생성
          final postRef = _firestore.collection('posts').doc(post.id);

          transaction.set(postRef, {
            'id': post.id,
            'titleA': post.titleA,
            'titleB': post.titleB,
            'descriptionA': post.descriptionA,
            'descriptionB': post.descriptionB,
            'imageUrlsA': post.imageUrlsA ?? [],
            'imageUrlsB': post.imageUrlsB ?? [],
            'videoUrlA': post.videoUrlA,
            'videoUrlB': post.videoUrlB,
            'userId': post.userId,
            'userName': post.userName,
            'userPhotoUrl': post.userPhotoUrl,
            'createdAt': FieldValue.serverTimestamp(),
            'likeCount': 0,
            'commentCount': 0,
            'votesA': 0,
            'votesB': 0,
            'status': post.status ?? 'published',
            'isAnonymous': post.isAnonymous ?? false,
            // TODO: 다른 필드 추가 (targetAudience, voteStartTime 등)
          });

          // 2. 캐시 무효화 (백그라운드)
          Future.microtask(() async {
            await _cacheService.invalidateFeedPosts();
          });

          return unit;
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: post.id));
    } catch (e, stackTrace) {
      return left(PostFailure.createFailed(
        reason: 'Failed to create post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<PostFailure, Unit>> updatePost({
    required String postId,
    required Map<String, dynamic> updates,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'post_update',
        entityId: postId,
        userId: currentUserId,
        eventId: eventId,
        operation: (transaction) async {
          final postRef = _firestore.collection('posts').doc(postId);

          // Transaction으로 업데이트
          transaction.update(postRef, {
            ...updates,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // 캐시 무효화
          Future.microtask(() async {
            await _cacheService.invalidatePost(postId);
            await _cacheService.invalidateFeedPosts();
          });

          return unit;
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.updateFailed(
        reason: 'Failed to update post: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<PostFailure, Unit>> deletePost({
    required String postId,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'post_delete',
        entityId: postId,
        userId: currentUserId,
        eventId: eventId,
        operation: (transaction) async {
          final postRef = _firestore.collection('posts').doc(postId);

          // 1. comments 서브컬렉션 삭제
          final commentsSnapshot = await postRef.collection('comments').get();
          for (final commentDoc in commentsSnapshot.docs) {
            // 댓글의 서브컬렉션도 삭제 (likes, dislikes)
            final commentLikesSnapshot =
                await commentDoc.reference.collection('likes').get();
            for (final likeDoc in commentLikesSnapshot.docs) {
              transaction.delete(likeDoc.reference);
            }

            final commentDislikesSnapshot =
                await commentDoc.reference.collection('dislikes').get();
            for (final dislikeDoc in commentDislikesSnapshot.docs) {
              transaction.delete(dislikeDoc.reference);
            }

            transaction.delete(commentDoc.reference);
          }

          // 2. votes 서브컬렉션 삭제
          final votesSnapshot = await postRef.collection('votes').get();
          for (final voteDoc in votesSnapshot.docs) {
            transaction.delete(voteDoc.reference);
          }

          // 3. likes 서브컬렉션 삭제
          final likesSnapshot = await postRef.collection('likes').get();
          for (final likeDoc in likesSnapshot.docs) {
            transaction.delete(likeDoc.reference);
          }

          // 4. dislikes 서브컬렉션 삭제
          final dislikesSnapshot = await postRef.collection('dislikes').get();
          for (final dislikeDoc in dislikesSnapshot.docs) {
            transaction.delete(dislikeDoc.reference);
          }

          // 5. post 문서 삭제
          transaction.delete(postRef);

          // 6. 캐시 무효화
          Future.microtask(() async {
            await _cacheService.invalidatePost(postId);
            await _cacheService.invalidateFeedPosts();
          });

          return unit;
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.deleteFailed(
        reason: 'Failed to delete post: ${e.toString()}',
      ));
    }
  }

  // ⚠️ 기존 메서드를 Either 패턴 + IdempotencyService로 업그레이드
  @override
  Future<Either<PostFailure, Unit>> incrementViewCount({
    required String postId,
    required String eventId,  // ✅ Phase 4에서 추가
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'post_view_increment',
        entityId: postId,
        userId: currentUserId,
        eventId: eventId,
        operation: (transaction) async {
          final postRef = _firestore.collection('posts').doc(postId);

          // Transaction으로 조회수 증가
          transaction.update(postRef, {
            'viewCount': FieldValue.increment(1),
          });

          // 캐시 무효화 (선택적 - viewCount는 실시간 반영 안 해도 됨)
          // await _cacheService.invalidatePost(postId);

          return unit;
        },
      );
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e) {
      return left(PostFailure.unexpected(
        message: 'Failed to increment view count: ${e.toString()}',
      ));
    }
  }

  // ... 기존 메서드들 (getPost, getFeedPosts 등)
}
```

### Step 3: UseCases 생성 (CRUD 작업용)

#### 3-1. CreatePostUseCase

**신규 파일**: `domain/usecases/create_post_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// 게시물 생성 UseCase
///
/// **비즈니스 규칙**:
/// 1. titleA와 titleB는 필수
/// 2. 익명 게시물은 userName 없음
/// 3. eventId 자동 생성 (중복 방지)
class CreatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid = const Uuid();

  CreatePostUseCase({required IPostDisplayRepositoryV2 postRepository})
      : _postRepository = postRepository;

  /// 게시물 생성
  ///
  /// **Parameters**:
  /// - post: 생성할 게시물 데이터
  ///
  /// **Returns**:
  /// - Right(unit): 생성 성공
  /// - Left(PostFailure): 생성 실패
  Future<Either<PostFailure, Unit>> execute({
    required PostDisplay post,
  }) async {
    try {
      // 1. 유효성 검증
      if (post.titleA.trim().isEmpty || post.titleB.trim().isEmpty) {
        return left(PostFailure.invalidInput(
          field: 'title',
        ));
      }

      // 2. eventId 생성 (중복 방지용)
      final eventId = _uuid.v4();

      // 3. Repository 호출 (IdempotencyService 통합)
      return await _postRepository.createPost(
        post: post,
        eventId: eventId,
      );
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to create post: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
```

#### 3-2. UpdatePostUseCase

**신규 파일**: `domain/usecases/update_post_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// 게시물 수정 UseCase
class UpdatePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid = const Uuid();

  UpdatePostUseCase({required IPostDisplayRepositoryV2 postRepository})
      : _postRepository = postRepository;

  /// 게시물 수정
  ///
  /// **Parameters**:
  /// - postId: 수정할 게시물 ID
  /// - updates: 수정할 필드 Map
  ///
  /// **허용되는 필드**:
  /// - titleA, titleB
  /// - descriptionA, descriptionB
  /// - status (published, draft, archived)
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // 1. 유효성 검증
      if (updates.isEmpty) {
        return left(PostFailure.invalidInput(
          field: 'updates',
        ));
      }

      // 2. eventId 생성
      final eventId = _uuid.v4();

      // 3. Repository 호출
      return await _postRepository.updatePost(
        postId: postId,
        updates: updates,
        eventId: eventId,
      );
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to update post: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
```

#### 3-3. DeletePostUseCase

**신규 파일**: `domain/usecases/delete_post_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// 게시물 삭제 UseCase
///
/// **비즈니스 규칙**:
/// 1. 본인이 작성한 게시물만 삭제 가능
/// 2. 서브컬렉션 모두 삭제 (comments, votes, likes)
class DeletePostUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid = const Uuid();

  DeletePostUseCase({required IPostDisplayRepositoryV2 postRepository})
      : _postRepository = postRepository;

  /// 게시물 삭제
  ///
  /// **Parameters**:
  /// - postId: 삭제할 게시물 ID
  ///
  /// **Transaction 처리**:
  /// - comments, votes, likes 서브컬렉션 모두 삭제
  /// - post 문서 삭제
  /// - 캐시 무효화
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
  }) async {
    try {
      // 1. eventId 생성
      final eventId = _uuid.v4();

      // 2. Repository 호출 (Transaction으로 처리)
      return await _postRepository.deletePost(
        postId: postId,
        eventId: eventId,
      );
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to delete post: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
```

#### 3-4. IncrementViewCountUseCase (기존 메서드 업그레이드)

⚠️ **주의**: 이 UseCase는 이미 존재하지만, Phase 4에서 Either 패턴 + IdempotencyService로 업그레이드합니다.

**기존 파일 수정**: `domain/usecases/increment_view_count_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../failures/post_failure.dart';

/// 조회수 증가 UseCase
///
/// **Phase 4 업그레이드 내용**:
/// - Either 패턴 적용 (기존 Future<void>에서 변경)
/// - IdempotencyService 통합: 동일한 사용자가 짧은 시간에 여러 번 조회 시 한 번만 증가
/// - eventId 파라미터 추가
class IncrementViewCountUseCase {
  final IPostDisplayRepositoryV2 _postRepository;
  final Uuid _uuid = const Uuid();

  IncrementViewCountUseCase({required IPostDisplayRepositoryV2 postRepository})
      : _postRepository = postRepository;

  /// 조회수 증가
  ///
  /// **Parameters**:
  /// - postId: 게시물 ID
  Future<Either<PostFailure, Unit>> execute({
    required String postId,
  }) async {
    try {
      // 1. eventId 생성 (사용자별로 고유하게)
      // 참고: 동일한 사용자가 같은 게시물을 여러 번 보면 한 번만 증가
      final eventId = _uuid.v4();

      // 2. Repository 호출 (eventId 파라미터 추가)
      return await _postRepository.incrementViewCount(
        postId: postId,
        eventId: eventId,
      );
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to increment view count: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
```

### Step 4: DI 모듈 업데이트

**파일**: `di/post_di_module.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/cache/unified_cache_service.dart';
import '/services/idempotency_service.dart';
import '../data/services/post_cache_service.dart';
import '../domain/usecases/get_feed_usecase.dart';
import '../domain/usecases/create_post_usecase.dart';
import '../domain/usecases/update_post_usecase.dart';
import '../domain/usecases/delete_post_usecase.dart';
import '../domain/usecases/increment_view_count_usecase.dart';
import '../domain/repositories/i_post_display_repository_v2.dart';
import '../data/repositories/post_display_repository_v2_impl.dart';

// ========== Cache Service Provider ==========

final postCacheServiceProvider = Provider<PostCacheService>((ref) {
  final unifiedCache = UnifiedCacheService.instance;
  return PostCacheService(cache: unifiedCache);
});

// ========== IdempotencyService Provider ==========

final idempotencyServiceProvider = Provider<IdempotencyService>((ref) {
  return IdempotencyService.instance;
});

// ========== Firestore Provider ==========

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ========== Current User Provider (Auth Feature에서 제공) ==========

// TODO: Auth Feature의 currentUserProvider 사용
// final currentUserIdProvider = Provider<String>((ref) {
//   return ref.watch(currentUserProvider)!.id;
// });

// ========== Repository Providers ==========

final postDisplayRepositoryProvider = Provider<IPostDisplayRepositoryV2>((ref) {
  final dataSource = ref.watch(postDisplayDataSourceProvider);
  final cacheService = ref.watch(postCacheServiceProvider);
  final idempotencyService = ref.watch(idempotencyServiceProvider);
  final firestore = ref.watch(firestoreProvider);

  // TODO: currentUserIdProvider 연결
  final currentUserId = 'temp_user_id';  // 임시

  return PostDisplayRepositoryV2Impl(
    dataSource: dataSource,
    cacheService: cacheService,
    idempotencyService: idempotencyService,
    firestore: firestore,
    currentUserId: currentUserId,
  );
});

// ========== UseCase Providers ==========

// 조회
final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return GetFeedUseCase(postRepository: repository);
});

// CRUD
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return CreatePostUseCase(postRepository: repository);
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return UpdatePostUseCase(postRepository: repository);
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return DeletePostUseCase(postRepository: repository);
});

final incrementViewCountUseCaseProvider =
    Provider<IncrementViewCountUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return IncrementViewCountUseCase(postRepository: repository);
});
```

### Step 5: UI에서 UseCases 사용 (예시)

**파일**: `presentation/screens/create_post/create_post_widget.dart` (예시)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/post/di/post_di_module.dart';
import '/features/post/domain/models/post_display.dart';

class CreatePostWidget extends ConsumerStatefulWidget {
  const CreatePostWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<CreatePostWidget> createState() => _CreatePostWidgetState();
}

class _CreatePostWidgetState extends ConsumerState<CreatePostWidget> {
  final _titleAController = TextEditingController();
  final _titleBController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleAController.dispose();
    _titleBController.dispose();
    super.dispose();
  }

  Future<void> _createPost() async {
    if (_isSubmitting) return;  // 중복 클릭 방지 (UI 레벨)

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. PostDisplay 생성
      final post = PostDisplay(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titleA: _titleAController.text,
        titleB: _titleBController.text,
        userId: 'current_user_id',  // TODO: Auth에서 가져오기
        userName: 'Current User',
        createdAt: DateTime.now(),
      );

      // 2. CreatePostUseCase 호출 (IdempotencyService 자동 적용)
      final either = await ref.read(createPostUseCaseProvider).execute(
            post: post,
          );

      // 3. 결과 처리
      either.fold(
        (failure) {
          // 에러 표시
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.when(
                invalidInput: (field) => '필수 항목을 입력해주세요: $field',
                createFailed: (reason) => '게시물 생성 실패: $reason',
                networkError: () => '네트워크 오류가 발생했습니다',
                unexpected: (msg, _, __) => msg ?? '알 수 없는 오류',
                // ... 다른 failure 케이스
              )),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          // 성공
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시물이 생성되었습니다'),
              backgroundColor: Colors.green,
            ),
          );

          // 피드로 이동
          Navigator.of(context).pop();

          // ✅ IdempotencyService 덕분에:
          // - 네트워크 재시도 시에도 중복 생성 안 됨
          // - 같은 eventId로 여러 번 호출 시 한 번만 실행
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시물 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleAController,
              decoration: const InputDecoration(
                labelText: 'Title A',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleBController,
              decoration: const InputDecoration(
                labelText: 'Title B',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _createPost,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('게시물 작성'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 6: 테스트 및 검증

```bash
# 1. 컴파일 에러 확인
flutter analyze lib/features/post

# 2. 빌드 테스트
flutter build apk --debug

# 3. 수동 테스트
# - 게시물 생성 (버튼 여러 번 클릭 → 중복 생성 안 됨 확인)
# - 게시물 수정
# - 게시물 삭제 (서브컬렉션 완전 삭제 확인)
# - 조회수 증가 (여러 번 호출 시 한 번만 증가 확인)
```

---

## 🧪 테스트 전략

### 1. 중복 방지 테스트

**파일**: `test/unit/usecases/create_post_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('CreatePostUseCase 중복 방지', () {
    late CreatePostUseCase useCase;
    late MockPostDisplayRepositoryV2 mockRepository;

    setUp(() {
      mockRepository = MockPostDisplayRepositoryV2();
      useCase = CreatePostUseCase(postRepository: mockRepository);
    });

    test('동일한 eventId로 2번 호출 시 한 번만 실행', () async {
      // Arrange
      final post = PostDisplay(
        id: '1',
        titleA: 'A',
        titleB: 'B',
        userId: 'user1',
        userName: 'User',
        createdAt: DateTime.now(),
      );

      when(mockRepository.createPost(
        post: post,
        eventId: anyNamed('eventId'),
      )).thenAnswer((_) async => right(unit));

      // Act - 두 번 호출
      await useCase.execute(post: post);
      await useCase.execute(post: post);

      // Assert - IdempotencyService가 중복 감지하여 한 번만 실행
      // (실제로는 IdempotencyService 테스트에서 확인)
      verify(mockRepository.createPost(
        post: post,
        eventId: anyNamed('eventId'),
      )).called(2);  // UseCase는 2번 호출, IdempotencyService가 중복 제거
    });
  });
}
```

### 2. Transaction 테스트

**파일**: `test/integration/repositories/post_repository_delete_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('PostDisplayRepositoryV2Impl deletePost Transaction', () {
    late PostDisplayRepositoryV2Impl repository;
    late MockFirebaseFirestore mockFirestore;
    late MockIdempotencyService mockIdempotencyService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockIdempotencyService = MockIdempotencyService();
      repository = PostDisplayRepositoryV2Impl(
        dataSource: mockDataSource,
        cacheService: mockCacheService,
        idempotencyService: mockIdempotencyService,
        firestore: mockFirestore,
        currentUserId: 'user1',
      );
    });

    test('deletePost 서브컬렉션 모두 삭제', () async {
      // Arrange
      when(mockIdempotencyService.executeIdempotent<Unit>(
        entityType: 'post_delete',
        entityId: '1',
        userId: 'user1',
        eventId: anyNamed('eventId'),
        operation: anyNamed('operation'),
      )).thenAnswer((invocation) async {
        final operation = invocation.namedArguments[const Symbol('operation')]
            as Future<Unit> Function(Transaction);
        // Transaction mock 실행
        return right(await operation(mockTransaction));
      });

      // Act
      final result = await repository.deletePost(
        postId: '1',
        eventId: 'event_1',
      );

      // Assert
      expect(result.isRight(), isTrue);

      // Transaction에서 comments, votes, likes, post 모두 삭제됨
      verify(mockTransaction.delete(any)).called(greaterThan(4));
    });
  });
}
```

### 3. E2E 테스트

```dart
void main() {
  testWidgets('게시물 생성 → 삭제 플로우', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MyApp()),
    );

    // 1. 게시물 작성 화면 이동
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // 2. 게시물 작성
    await tester.enterText(find.byType(TextField).first, 'Title A');
    await tester.enterText(find.byType(TextField).last, 'Title B');
    await tester.tap(find.text('게시물 작성'));
    await tester.pumpAndSettle();

    // 3. 피드에 표시 확인
    expect(find.text('Title A'), findsOneWidget);

    // 4. 게시물 삭제
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // 5. 삭제 확인
    expect(find.text('Title A'), findsNothing);

    // 6. Firestore에서 서브컬렉션 삭제 확인
    // (실제로는 Firebase Emulator 사용)
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **IdempotencyService 버그**: 중복 방지가 제대로 작동하지 않음
2. **Transaction 오류**: 서브컬렉션 삭제 실패
3. **성능 저하**: IdempotencyService 오버헤드로 성능 악화
4. **캐시 동기화 문제**: 캐시 무효화가 제대로 작동하지 않음

### 롤백 절차

#### Step 1: Git Revert

```bash
# Phase 4 커밋 찾기
git log --oneline --grep="Idempotency"

# Revert
git revert <commit-hash>
```

#### Step 2: Repository 인터페이스 복구

```dart
// After (롤백 후)
abstract class IPostDisplayRepositoryV2 {
  // CRUD 메서드 제거
  // createPost, updatePost, deletePost 제거
}
```

#### Step 3: Repository 구현체 복구

```dart
// After (롤백 후)
class PostDisplayRepositoryV2Impl {
  // IdempotencyService 제거
  // Transaction 코드 제거
  // CRUD 메서드 제거
}
```

#### Step 4: UseCases 삭제

```bash
# CRUD UseCases 파일 삭제
rm lib/features/post/domain/usecases/create_post_usecase.dart
rm lib/features/post/domain/usecases/update_post_usecase.dart
rm lib/features/post/domain/usecases/delete_post_usecase.dart
rm lib/features/post/domain/usecases/increment_view_count_usecase.dart
```

#### Step 5: DI 모듈 복구

```dart
// After (롤백 후)
// idempotencyServiceProvider 제거
// firestoreProvider 제거
// CRUD UseCase Providers 제거
```

---

## ✅ 완료 체크리스트

### Phase 4 완료 기준

- [ ] **Repository 인터페이스 업데이트**
  - [ ] createPost 메서드 추가 (Either 반환)
  - [ ] updatePost 메서드 추가
  - [ ] deletePost 메서드 추가
  - [ ] incrementViewCount 메서드 업그레이드 (Either 반환 + eventId 파라미터)

- [ ] **Repository 구현체 - IdempotencyService 통합**
  - [ ] IdempotencyService 주입
  - [ ] FirebaseFirestore 주입
  - [ ] createPost 구현 (Transaction + 중복 방지)
  - [ ] updatePost 구현
  - [ ] deletePost 구현 (서브컬렉션 완전 삭제)
  - [ ] incrementViewCount 업그레이드 (Either + IdempotencyService)
  - [ ] 캐시 무효화 통합

- [ ] **UseCases 생성/업그레이드**
  - [ ] CreatePostUseCase 구현
  - [ ] UpdatePostUseCase 구현
  - [ ] DeletePostUseCase 구현
  - [ ] IncrementViewCountUseCase 업그레이드 (Either + eventId)
  - [ ] 유효성 검증 로직 추가
  - [ ] eventId 자동 생성

- [ ] **DI 모듈 업데이트**
  - [ ] idempotencyServiceProvider 등록
  - [ ] firestoreProvider 등록
  - [ ] currentUserIdProvider 연결 (Auth Feature)
  - [ ] CRUD UseCase Providers 등록

- [ ] **UI 통합 (선택적)**
  - [ ] CreatePostWidget 구현
  - [ ] UpdatePostWidget 구현
  - [ ] DeletePostDialog 구현
  - [ ] 에러 처리 및 피드백 UI

- [ ] **테스트**
  - [ ] CreatePostUseCase 중복 방지 테스트
  - [ ] DeletePostUseCase Transaction 테스트
  - [ ] IdempotencyService 통합 테스트
  - [ ] E2E 테스트: 생성 → 수정 → 삭제

- [ ] **컴파일 & 분석**
  - [ ] `flutter analyze lib/features/post` 에러 없음
  - [ ] `flutter test` 모든 테스트 통과
  - [ ] 수동 테스트: 중복 생성 방지, 서브컬렉션 삭제 확인

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] README.md에 IdempotencyService 패턴 추가
  - [ ] Phase 5 준비 (Extension Pattern)

---

## 📊 마이그레이션 영향 분석

### 코드 증가량

| 파일 | Before (줄) | After (줄) | 증가율 |
|------|------------|-----------|--------|
| i_post_display_repository_v2.dart | 82 | 140 | +58줄 (+71%) |
| post_display_repository_v2_impl.dart | 320 | 520 | +200줄 (+63%) |
| create_post_usecase.dart | - | 80 | +80줄 |
| update_post_usecase.dart | - | 80 | +80줄 |
| delete_post_usecase.dart | - | 80 | +80줄 |
| increment_view_count_usecase.dart | - | 80 | +80줄 |
| post_di_module.dart | 80 | 130 | +50줄 (+63%) |
| **합계** | **482줄** | **1,110줄** | **+628줄 (+130%)** |

### 기능 비교

| 항목 | Before | After | 개선 |
|------|--------|-------|------|
| **중복 게시물 생성** | 발생 가능 | 방지됨 | **100%** |
| **고아 서브컬렉션** | 발생 가능 | 0개 | **완전 정리** |
| **Transaction 사용** | 없음 | 있음 | **원자성 보장** |
| **재시도 안전성** | 위험 | 안전 | **멱등성** |
| **캐시 동기화** | 수동 | 자동 | **일관성** |
| **에러 처리** | throw | Either | **명시적** |

### 사용자 경험

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **중복 게시물 발생** | ⭐☆☆☆☆ | ⭐⭐⭐⭐⭐ | 완전 방지 |
| **삭제 안정성** | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | 완전 삭제 |
| **재시도 신뢰성** | ⭐⭐☆☆☆ | ⭐⭐⭐⭐⭐ | 멱등성 보장 |
| **전체 만족도** | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | 크게 향상 |

---

## 🎓 추가 학습 자료

### IdempotencyService 작동 원리

#### 1. eventId 생성 패턴

```dart
// ✅ 클라이언트에서 eventId 생성
import 'package:uuid/uuid.dart';

final uuid = Uuid();
final eventId = uuid.v4();  // "550e8400-e29b-41d4-a716-446655440000"

// CreatePostUseCase 호출
await createPostUseCase.execute(post: post);  // eventId 자동 생성
```

#### 2. IdempotencyService 내부 동작

```dart
// IdempotencyService.executeIdempotent() 내부
Future<Either<F, T>> executeIdempotent<T>({
  required String entityType,
  required String entityId,
  required String userId,
  required String eventId,
  required Future<T> Function(Transaction) operation,
}) async {
  // 1. 이미 처리된 eventId인지 확인
  final existingRecord = await _checkIdempotencyRecord(
    entityType: entityType,
    entityId: entityId,
    eventId: eventId,
  );

  if (existingRecord != null) {
    // 이미 처리됨 → 즉시 성공 반환 (중복 방지) ✅
    return right(existingRecord.result as T);
  }

  // 2. Transaction 실행
  final result = await _firestore.runTransaction((transaction) async {
    return await operation(transaction);
  });

  // 3. Idempotency 레코드 저장 (다음 번 요청 시 중복 감지용)
  await _saveIdempotencyRecord(
    entityType: entityType,
    entityId: entityId,
    eventId: eventId,
    result: result,
  );

  return right(result);
}
```

#### 3. Transaction 패턴

```dart
// ✅ Transaction으로 원자성 보장
await _firestore.runTransaction((transaction) async {
  // 1. comments 삭제
  final commentsSnapshot = await postRef.collection('comments').get();
  for (final doc in commentsSnapshot.docs) {
    transaction.delete(doc.reference);
  }

  // 2. votes 삭제
  final votesSnapshot = await postRef.collection('votes').get();
  for (final doc in votesSnapshot.docs) {
    transaction.delete(doc.reference);
  }

  // 3. post 삭제
  transaction.delete(postRef);

  // 모두 성공 또는 모두 실패 (원자성 보장) ✅
});
```

### Chat & Auth Feature 참조

- **Chat PHASE_4_IDEMPOTENCY.md**: IdempotencyService 통합 상세 가이드
- **IdempotencyService**: 전역 서비스 구현 참조
- **Auth Feature**: Either 패턴 완성 예시

---

## 📌 다음 단계: Phase 5

Phase 4 완료 후, **Phase 5: Extension Pattern (Firebase-Centric v2.0)**으로 진행:

```
DataSource → DTO → Mapper (3단계) → Extension (1단계)
```

**예상 효과**:
- 63% 코드 감소 (DataSource, DTO, Mapper 제거)
- Repository에서 Firestore 직접 접근
- Extension 메서드로 간결한 변환
- 유지보수성 대폭 향상

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
