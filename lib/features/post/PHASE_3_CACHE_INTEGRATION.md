# Post Feature - Phase 3: UnifiedCacheService Integration

> **마이그레이션 가이드**: 3-Layer 캐싱 시스템 통합 (Memory → Hive → Firestore)
> **난이도**: ⭐⭐⭐⭐⭐ (최고급)
> **예상 소요 시간**: 3일 (24시간)
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Post Feature에 UnifiedCacheService를 통합하여 3-Layer 캐싱 아키텍처를 구현:

1. **L1 Memory Cache**: SimpleMemoryCache (LRU, 100개 제한, <10ms 응답)
2. **L2 Local DB**: Hive 영구 저장소 (10-30ms 응답, 오프라인 지원)
3. **L3 Remote Cache**: Firestore 오프라인 캐시 (50-100ms 응답)
4. **성능 최적화**: 97% 응답 시간 단축 (600ms → <10ms)
5. **비용 절감**: Firestore 읽기 비용 60% 감소

### 영향 범위

| 레이어 | 파일 수 | Before (줄) | After (줄) | 증가/감소 |
|--------|---------|------------|-----------|----------|
| **Data (Repository)** | 1개 | 200줄 | 320줄 | +120줄 (+60%) |
| **Services** | 1개 (신규) | - | 180줄 | +180줄 |
| **Presentation (Providers)** | 1개 | 180줄 | 220줄 | +40줄 (+22%) |
| **DI** | 1개 | 60줄 | 80줄 | +20줄 (+33%) |
| **합계** | **4개** | **440줄** | **800줄** | **+360줄** |

### 주요 이점

| 항목 | Before (Direct Firestore) | After (3-Layer Cache) |
|------|---------------------------|----------------------|
| **응답 시간** | 300-600ms | <10ms (캐시 히트) |
| **Firestore 읽기** | 100% | 40% (60% ↓) |
| **오프라인 지원** | 제한적 | 완전 지원 |
| **메모리 효율** | 비효율적 | LRU 자동 관리 |
| **사용자 경험** | 느림 | 즉각 반응 |
| **비용** | 높음 | 60% 절감 |

---

## 🔍 현재 상태 분석

### 1. Repository 직접 Firestore 접근

**파일**: `data/repositories/post_display_repository_v2_impl.dart`

```dart
/// ❌ 현재: 캐시 없이 직접 Firestore 접근
class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;

  @override
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    // ❌ 매번 Firestore에서 데이터 가져옴 (300-600ms)
    return _dataSource.queryPosts(...).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Future<PostDisplay?> getPost(String postId) async {
    // ❌ 캐시 체크 없음
    final data = await _dataSource.getPost(postId);
    if (data == null) return null;

    final dto = PostDisplayDto.fromFirestore(data, postId);
    return PostDisplayMapper.toDomain(dto);
  }
}
```

**문제점**:
1. **캐시 부재**: 매 요청마다 Firestore 접근 (300-600ms)
2. **중복 읽기**: 같은 게시물을 여러 번 요청 시 중복 비용 발생
3. **오프라인 제한**: Firestore 오프라인 캐시만 의존 (용량 제한)
4. **메모리 낭비**: 동일 데이터를 여러 곳에서 중복 저장
5. **비용 증가**: 불필요한 Firestore 읽기 비용

### 2. Provider의 직접 Repository 호출

**파일**: `presentation/providers/post_providers.dart`

```dart
/// ❌ 현재: 캐시 없이 직접 Repository 호출
final feedStreamProvider =
    StreamProvider.autoDispose.family<List<PostDisplay>, FeedParams>(
  (ref, params) async* {
    yield [];

    // ❌ 캐시 체크 없이 바로 Repository 호출
    final getFeedUseCase = ref.watch(getFeedUseCaseProvider);

    final either = await getFeedUseCase.execute(
      limit: params.limit,
      sortBy: params.sortBy,
      filter: params.filter,
    );

    yield* either.fold(
      (failure) => Stream<List<PostDisplay>>.error(failure),
      (feedResult) async* { yield feedResult.posts; },
    );

    ref.keepAlive();
  },
);
```

**문제점**:
1. **캐시 우선 전략 부재**: Cache-First 패턴 미적용
2. **프리로딩 없음**: 앱 시작 시 인기 게시물 미리 로드 안 함
3. **낙관적 업데이트 부재**: UI 즉시 반영 없음
4. **백그라운드 동기화 없음**: 캐시 갱신 전략 부재

---

## 🎯 마이그레이션 목표

### 3-Layer 캐싱 아키텍처

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                          │
│            (AsyncValue.data/loading/error)          │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│              Riverpod Provider                       │
│      (feedStreamProvider, postDetailProvider)       │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│           PostCacheService (신규)                   │
│  ┌─────────────────────────────────────────────┐   │
│  │ L1: Memory Cache (SimpleMemoryCache)        │   │
│  │     - LRU 100개 제한                        │   │
│  │     - 5분 TTL                               │   │
│  │     - <10ms 응답                            │   │
│  └───────────────┬─────────────────────────────┘   │
│                  │ Miss                              │
│  ┌───────────────▼─────────────────────────────┐   │
│  │ L2: Local DB (Hive)                         │   │
│  │     - 영구 저장소                           │   │
│  │     - 10-30ms 응답                          │   │
│  │     - 오프라인 지원                         │   │
│  └───────────────┬─────────────────────────────┘   │
│                  │ Miss                              │
│  ┌───────────────▼─────────────────────────────┐   │
│  │ L3: Firestore Offline Cache                 │   │
│  │     - 50-100ms 응답                         │   │
│  │     - 제한된 용량                           │   │
│  └───────────────┬─────────────────────────────┘   │
│                  │ Miss                              │
└──────────────────┼─────────────────────────────────┘
                   │
┌──────────────────▼─────────────────────────────────┐
│              Repository Layer                       │
│        (PostDisplayRepositoryV2Impl)               │
└────────────────────┬───────────────────────────────┘
                     │
┌────────────────────▼───────────────────────────────┐
│              Firestore (Network)                    │
│               300-600ms 응답                        │
└────────────────────────────────────────────────────┘
```

### Cache-First 플로우

```
1. UI → Provider 요청
2. Provider → PostCacheService.getFeedPosts()
3. PostCacheService:
   a. L1 Memory 체크 → Hit: 즉시 반환 (<10ms) ✅
   b. L1 Miss → L2 Hive 체크 → Hit: 반환 (10-30ms) ✅
   c. L2 Miss → L3 Firestore Offline → Hit: 반환 (50-100ms) ✅
   d. L3 Miss → Repository → Network (300-600ms)
4. 데이터 획득 후:
   - L1, L2, L3 모두 캐시 업데이트 (Waterfall)
   - UI에 데이터 반환
5. 백그라운드 동기화:
   - 5분마다 인기 게시물 프리로드
   - 사용자 스크롤 패턴 학습하여 선제 로드
```

### Before → After 비교

#### 1. Repository 캐시 통합

```dart
// ❌ Before: 직접 Firestore 접근
class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;

  @override
  Future<PostDisplay?> getPost(String postId) async {
    final data = await _dataSource.getPost(postId);  // 항상 300-600ms
    if (data == null) return null;

    final dto = PostDisplayDto.fromFirestore(data, postId);
    return PostDisplayMapper.toDomain(dto);
  }
}

// ✅ After: 3-Layer 캐시 우선
class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;
  final PostCacheService _cacheService;

  @override
  Future<PostDisplay?> getPost(String postId) async {
    // 1. 캐시 체크 (L1 → L2 → L3)
    final cachedPost = await _cacheService.getPost(postId);
    if (cachedPost != null) {
      return cachedPost;  // <10ms 반환 ✅
    }

    // 2. 캐시 미스 → Firestore 네트워크 요청
    final data = await _dataSource.getPost(postId);
    if (data == null) return null;

    final dto = PostDisplayDto.fromFirestore(data, postId);
    final post = PostDisplayMapper.toDomain(dto);

    // 3. 캐시 업데이트 (L1, L2, L3 모두)
    await _cacheService.setPost(postId, post);

    return post;
  }
}
```

#### 2. Provider 캐시 프리로딩

```dart
// ❌ Before: 캐시 없음
final feedStreamProvider = StreamProvider.autoDispose.family<...>(
  (ref, params) async* {
    yield [];
    final either = await getFeedUseCase.execute(...);
    yield* either.fold(...);
  },
);

// ✅ After: 캐시 우선 + 프리로딩
final feedStreamProvider = StreamProvider.autoDispose.family<...>(
  (ref, params) async* {
    // 1. 즉시 캐시 emit (L1/L2에서 <30ms)
    final cachedPosts = await ref.watch(postCacheServiceProvider).getFeedPosts(
      limit: params.limit,
      sortBy: params.sortBy,
    );
    if (cachedPosts.isNotEmpty) {
      yield cachedPosts;  // ✅ 즉각 UI 업데이트
    } else {
      yield [];  // 로딩 상태
    }

    // 2. 백그라운드에서 최신 데이터 가져오기
    final either = await getFeedUseCase.execute(...);
    yield* either.fold(
      (failure) => Stream.error(failure),
      (feedResult) async* {
        // 3. 캐시 업데이트
        await ref.watch(postCacheServiceProvider).setFeedPosts(feedResult.posts);
        yield feedResult.posts;
      },
    );

    ref.keepAlive();
  },
);
```

#### 3. 오프라인 지원

```dart
// ❌ Before: 오프라인 시 에러
try {
  final posts = await repository.getFeedPosts();
} catch (e) {
  // NetworkError: No internet connection
}

// ✅ After: 오프라인 시 캐시 제공
try {
  // 1. 캐시 우선 (오프라인에서도 작동)
  final cachedPosts = await cacheService.getFeedPosts();
  if (cachedPosts.isNotEmpty) {
    return cachedPosts;  // ✅ 오프라인에서도 데이터 제공
  }

  // 2. 네트워크 요청 (온라인 시)
  final posts = await repository.getFeedPosts();
  await cacheService.setFeedPosts(posts);
  return posts;
} catch (e) {
  // 3. 네트워크 실패 시에도 캐시 반환
  final fallbackPosts = await cacheService.getFeedPosts();
  if (fallbackPosts.isNotEmpty) {
    return fallbackPosts;  // ✅ Fallback
  }
  throw e;
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: PostCacheService 생성

**신규 파일**: `data/services/post_cache_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/cache/unified_cache_service.dart';
import '../../domain/models/post_display.dart';
import '../../domain/usecases/get_feed_usecase.dart';  // FeedSortBy import

/// Post Feature 전용 캐시 서비스
///
/// UnifiedCacheService를 활용하여 3-Layer 캐싱 구현:
/// - L1: Memory Cache (SimpleMemoryCache, LRU 100개, 5분 TTL)
/// - L2: Local DB (Hive, 영구 저장소)
/// - L3: Firestore Offline Cache
///
/// **성능 목표**:
/// - 캐시 히트 시: <10ms 응답
/// - Firestore 읽기: 60% 감소
/// - 오프라인 지원: 완전 지원
class PostCacheService {
  final UnifiedCacheService _cache;

  PostCacheService({required UnifiedCacheService cache}) : _cache = cache;

  // ========== Cache Keys ==========

  /// 피드 캐시 키 생성
  ///
  /// 정렬 방식별로 다른 캐시 키 사용
  static String _feedCacheKey({
    required FeedSortBy sortBy,
    int limit = 20,
  }) {
    return 'feed_${sortBy.name}_limit_$limit';
  }

  /// 게시물 상세 캐시 키
  static String _postCacheKey(String postId) => 'post_detail_$postId';

  /// 인기 게시물 캐시 키
  static const String _popularPostsKey = 'posts_popular';

  /// 트렌딩 게시물 캐시 키
  static const String _trendingPostsKey = 'posts_trending';

  /// 사용자별 게시물 캐시 키
  static String _userPostsKey(String userId) => 'posts_user_$userId';

  // ========== Feed Posts ==========

  /// 피드 게시물 가져오기 (L1 → L2 → L3)
  ///
  /// **성능**:
  /// - L1 Hit: <10ms
  /// - L2 Hit: 10-30ms
  /// - L3 Hit: 50-100ms
  Future<List<PostDisplay>> getFeedPosts({
    required FeedSortBy sortBy,
    int limit = 20,
  }) async {
    final cacheKey = _feedCacheKey(sortBy: sortBy, limit: limit);

    // L1/L2/L3 통합 조회
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      // JSON → PostDisplay 변환
      return cachedData
          .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 피드 게시물 저장 (L1, L2, L3 모두)
  Future<void> setFeedPosts({
    required List<PostDisplay> posts,
    required FeedSortBy sortBy,
    int limit = 20,
    Duration? ttl,
  }) async {
    final cacheKey = _feedCacheKey(sortBy: sortBy, limit: limit);

    // PostDisplay → JSON 변환
    final jsonData = posts.map((post) => post.toJson()).toList();

    // 모든 레이어에 저장 (기본 TTL: 5분)
    await _cache.set(
      cacheKey,
      jsonData,
      ttl: ttl ?? const Duration(minutes: 5),
    );
  }

  /// 피드 캐시 무효화
  Future<void> invalidateFeedPosts({FeedSortBy? sortBy}) async {
    if (sortBy != null) {
      final cacheKey = _feedCacheKey(sortBy: sortBy);
      await _cache.remove(cacheKey);
    } else {
      // 모든 피드 캐시 무효화
      await _cache.invalidate('feed_*');
    }
  }

  // ========== Post Detail ==========

  /// 게시물 상세 가져오기
  Future<PostDisplay?> getPost(String postId) async {
    final cacheKey = _postCacheKey(postId);
    final cachedData = await _cache.get<Map<String, dynamic>>(cacheKey);

    if (cachedData != null) {
      return PostDisplay.fromJson(cachedData);
    }

    return null;
  }

  /// 게시물 상세 저장
  Future<void> setPost(String postId, PostDisplay post, {Duration? ttl}) async {
    final cacheKey = _postCacheKey(postId);
    await _cache.set(
      cacheKey,
      post.toJson(),
      ttl: ttl ?? const Duration(minutes: 10),
    );
  }

  /// 게시물 캐시 무효화
  Future<void> invalidatePost(String postId) async {
    final cacheKey = _postCacheKey(postId);
    await _cache.remove(cacheKey);
  }

  // ========== Popular Posts ==========

  /// 인기 게시물 가져오기
  Future<List<PostDisplay>> getPopularPosts() async {
    final cachedData = await _cache.get<List<dynamic>>(_popularPostsKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData
          .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 인기 게시물 저장
  Future<void> setPopularPosts(List<PostDisplay> posts) async {
    final jsonData = posts.map((post) => post.toJson()).toList();
    await _cache.set(
      _popularPostsKey,
      jsonData,
      ttl: const Duration(minutes: 10),
    );
  }

  // ========== Trending Posts ==========

  /// 트렌딩 게시물 가져오기
  Future<List<PostDisplay>> getTrendingPosts() async {
    final cachedData = await _cache.get<List<dynamic>>(_trendingPostsKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData
          .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 트렌딩 게시물 저장
  Future<void> setTrendingPosts(List<PostDisplay> posts) async {
    final jsonData = posts.map((post) => post.toJson()).toList();
    await _cache.set(
      _trendingPostsKey,
      jsonData,
      ttl: const Duration(minutes: 5),
    );
  }

  // ========== User Posts ==========

  /// 사용자별 게시물 가져오기
  Future<List<PostDisplay>> getUserPosts(String userId) async {
    final cacheKey = _userPostsKey(userId);
    final cachedData = await _cache.get<List<dynamic>>(cacheKey);

    if (cachedData != null && cachedData.isNotEmpty) {
      return cachedData
          .map((json) => PostDisplay.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 사용자별 게시물 저장
  Future<void> setUserPosts(String userId, List<PostDisplay> posts) async {
    final cacheKey = _userPostsKey(userId);
    final jsonData = posts.map((post) => post.toJson()).toList();
    await _cache.set(
      cacheKey,
      jsonData,
      ttl: const Duration(minutes: 10),
    );
  }

  // ========== Preloading ==========

  /// 인기 게시물 프리로드
  ///
  /// **호출 시점**: 앱 시작 시 (main.dart)
  Future<void> preloadPopularPosts({
    required Future<List<PostDisplay>> Function() fetchPopularPosts,
  }) async {
    try {
      // 1. 캐시 체크
      final cachedPosts = await getPopularPosts();
      if (cachedPosts.isNotEmpty) {
        return;  // 이미 캐시됨
      }

      // 2. 네트워크에서 가져오기
      final posts = await fetchPopularPosts();

      // 3. 캐시 저장
      await setPopularPosts(posts);
    } catch (e) {
      // 프리로드 실패는 무시 (백그라운드 작업)
      print('Failed to preload popular posts: $e');
    }
  }

  /// 트렌딩 게시물 프리로드
  Future<void> preloadTrendingPosts({
    required Future<List<PostDisplay>> Function() fetchTrendingPosts,
  }) async {
    try {
      final cachedPosts = await getTrendingPosts();
      if (cachedPosts.isNotEmpty) {
        return;
      }

      final posts = await fetchTrendingPosts();
      await setTrendingPosts(posts);
    } catch (e) {
      print('Failed to preload trending posts: $e');
    }
  }

  // ========== Cache Management ==========

  /// 모든 게시물 캐시 무효화
  Future<void> clearAll() async {
    await _cache.invalidate('feed_*');
    await _cache.invalidate('post_*');
    await _cache.invalidate('posts_*');
  }

  /// 캐시 통계
  Map<String, dynamic> getStatistics() {
    return _cache.getStatistics();
  }
}
```

### Step 2: PostDisplay 모델에 JSON 직렬화 추가

**파일**: `domain/models/post_display.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'post_display.freezed.dart';
part 'post_display.g.dart';  // ✅ JSON 직렬화 생성

@freezed
class PostDisplay with _$PostDisplay {
  const factory PostDisplay({
    required String id,
    required String titleA,
    required String titleB,
    String? descriptionA,
    String? descriptionB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? videoUrlA,
    String? videoUrlB,
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(0) int votesA,
    @Default(0) int votesB,
    String? status,
    bool? isAnonymous,
    // ... 다른 필드들
  }) = _PostDisplay;

  // ✅ JSON 직렬화 메서드 추가
  factory PostDisplay.fromJson(Map<String, dynamic> json) =>
      _$PostDisplayFromJson(json);

  // ✅ DateTime 파싱 헬퍼 (Hive 캐시 호환성)
  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

// ✅ JSON 직렬화 커스텀 컨버터 (Timestamp → int)
class TimestampConverter implements JsonConverter<DateTime, int> {
  const TimestampConverter();

  @override
  DateTime fromJson(int json) {
    return DateTime.fromMillisecondsSinceEpoch(json);
  }

  @override
  int toJson(DateTime object) {
    return object.millisecondsSinceEpoch;
  }
}
```

**코드 생성**:

```bash
# freezed + json_serializable 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 3: Repository에 캐시 통합

**파일**: `data/repositories/post_display_repository_v2_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_post_display_repository_v2.dart';
import '../../domain/models/post_display.dart';
import '../../domain/failures/post_failure.dart';
import '../datasources/i_post_display_datasource.dart';
import '../services/post_cache_service.dart';
import '../../domain/usecases/get_feed_usecase.dart';  // FeedSortBy

class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;
  final PostCacheService _cacheService;  // ✅ 캐시 추가

  PostDisplayRepositoryV2Impl({
    required IPostDisplayDataSource dataSource,
    required PostCacheService cacheService,
  })  : _dataSource = dataSource,
        _cacheService = cacheService;

  // ========== Stream Methods (Firestore 실시간 업데이트) ==========

  @override
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    // ✅ Stream은 캐시 없이 실시간 업데이트 유지
    return _dataSource.queryPosts(...).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  @override
  Stream<PostDisplay?> streamPost(String postId) {
    // ✅ Stream은 실시간 업데이트
    return _dataSource.streamPost(postId).map((data) {
      if (data == null) return null;
      final dto = PostDisplayDto.fromFirestore(data, postId);
      return PostDisplayMapper.toDomain(dto);
    });
  }

  // ========== Future Methods (캐시 우선) ==========

  @override
  Future<Either<PostFailure, PostDisplay?>> getPost(String postId) async {
    try {
      // 1. 캐시 체크 (L1 → L2 → L3)
      final cachedPost = await _cacheService.getPost(postId);
      if (cachedPost != null) {
        return right(cachedPost);  // ✅ <10ms 반환
      }

      // 2. 캐시 미스 → Firestore 네트워크 요청
      final data = await _dataSource.getPost(postId);
      if (data == null) {
        return left(PostFailure.postNotFound(postId: postId));
      }

      final dto = PostDisplayDto.fromFirestore(data, postId);
      final post = PostDisplayMapper.toDomain(dto);

      // 3. 캐시 업데이트 (백그라운드)
      _cacheService.setPost(postId, post).ignore();

      return right(post);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to get post: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    try {
      // TODO: searchPosts 구현 필요 (현재 구현 예정 상태)
      throw UnimplementedError('searchPosts not implemented yet');

      // ✅ 구현 시 캐시 패턴:
      // 1. 캐시 체크 (검색어별 캐시)
      // final cachedResults = await _cacheService.getSearchResults(query);
      // if (cachedResults != null) return right(cachedResults);
      //
      // 2. Algolia 또는 Firestore 검색
      // final results = await _dataSource.searchPosts(query, limit);
      //
      // 3. 캐시 저장
      // await _cacheService.setSearchResults(query, results);
      // return right(results);
    } catch (e) {
      return left(PostFailure.searchFailed(query: query));
    }
  }

  // ========== Cache-Friendly Helper Methods ==========

  /// 피드 게시물 가져오기 (캐시 우선)
  ///
  /// **UseCase에서 호출**:
  /// - GetFeedUseCase.execute()
  Future<Either<PostFailure, List<PostDisplay>>> getFeedPosts({
    required FeedSortBy sortBy,
    int limit = 20,
  }) async {
    try {
      // 1. 캐시 체크
      final cachedPosts = await _cacheService.getFeedPosts(
        sortBy: sortBy,
        limit: limit,
      );
      if (cachedPosts.isNotEmpty) {
        return right(cachedPosts);  // ✅ <10ms 반환
      }

      // 2. 캐시 미스 → Firestore 쿼리
      final stream = queryPosts(
        queryBuilder: (params) => _buildSortQuery(params, sortBy),
        limit: limit,
      );

      final posts = await stream.first;

      // 3. 캐시 저장 (백그라운드)
      _cacheService.setFeedPosts(
        posts: posts,
        sortBy: sortBy,
        limit: limit,
      ).ignore();

      return right(posts);
    } catch (e, stackTrace) {
      return left(PostFailure.queryFailed(
        reason: 'Failed to get feed: ${e.toString()}',
      ));
    }
  }

  /// 정렬 쿼리 빌더
  Map<String, dynamic> _buildSortQuery(
    Map<String, dynamic> params,
    FeedSortBy sortBy,
  ) {
    switch (sortBy) {
      case FeedSortBy.latest:
        return {...params, 'orderBy': 'createdAt', 'descending': true};
      case FeedSortBy.popular:
        return {...params, 'orderBy': 'likeCount', 'descending': true};
      case FeedSortBy.mostVoted:
        return {...params, 'orderBy': 'votesA', 'descending': true};
      case FeedSortBy.trending:
        return {...params, 'orderBy': 'commentCount', 'descending': true};
    }
  }

  // ... Firebase Exception 매핑 메서드
  PostFailure _mapFirebaseException(FirebaseException e, {String? postId}) {
    // PHASE_1과 동일
  }
}
```

### Step 4: UseCase에 캐시 통합

**파일**: `domain/usecases/get_feed_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetFeedUseCase({required IPostDisplayRepositoryV2 postRepository})
      : _postRepository = postRepository;

  /// 피드 가져오기 (캐시 우선)
  ///
  /// **캐시 전략**:
  /// 1. Repository의 getFeedPosts() 호출
  /// 2. Repository가 캐시 우선 전략 적용
  /// 3. UseCase는 비즈니스 로직에만 집중
  Future<Either<PostFailure, FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      // ✅ Repository의 캐시 우선 메서드 호출
      final either = await _postRepository.getFeedPosts(
        sortBy: sortBy,
        limit: limit,
      );

      return either.fold(
        (failure) => left(failure),
        (posts) {
          // 페이지네이션 정보 생성
          String? nextLastDocId;
          if (posts.isNotEmpty) {
            nextLastDocId = posts.last.id;
          }

          return right(FeedResult(
            posts: posts,
            hasMore: posts.length >= limit,
            lastDocumentId: nextLastDocId,
            totalCount: posts.length,
          ));
        },
      );
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to load feed: ${e.toString()}',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 피드 스트림 (실시간 업데이트)
  ///
  /// **캐시 전략**:
  /// - Stream은 캐시 없이 실시간 업데이트 유지
  /// - Provider에서 캐시 우선 로드 후 Stream 구독
  Stream<Either<PostFailure, List<PostDisplay>>> getFeedStream({
    int limit = 20,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) {
    try {
      final stream = _postRepository.queryPosts(
        queryBuilder: (params) => _buildSortQuery(params, sortBy),
        limit: limit,
      );

      return stream.map((posts) => right<PostFailure, List<PostDisplay>>(posts));
    } catch (e) {
      return Stream.value(left(PostFailure.queryFailed(
        reason: 'Failed to create feed stream: ${e.toString()}',
      )));
    }
  }

  Map<String, dynamic> _buildSortQuery(
    Map<String, dynamic> params,
    FeedSortBy sortBy,
  ) {
    // Repository와 동일한 로직
  }
}
```

### Step 5: Provider에 캐시 프리로딩 추가

**파일**: `presentation/providers/post_providers.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '/features/post/di/post_di_module.dart';
import '/features/post/domain/models/post_display.dart';
import '/features/post/domain/usecases/get_feed_usecase.dart';
import '/features/post/domain/failures/post_failure.dart';
import '/features/post/data/services/post_cache_service.dart';
import 'post_params.dart';

// ========== Feed Stream Provider (캐시 우선 + 실시간 업데이트) ==========

/// 피드 실시간 스트림 Provider (캐시 우선 전략)
///
/// **캐시 전략**:
/// 1. 즉시 캐시 emit (L1/L2에서 <30ms)
/// 2. 백그라운드에서 최신 데이터 가져오기
/// 3. 캐시 업데이트 후 emit
///
/// **성능**:
/// - 초기 로드: <30ms (캐시 히트)
/// - 최신 데이터: 300-600ms (백그라운드)
final feedStreamProvider =
    StreamProvider.autoDispose.family<List<PostDisplay>, FeedParams>(
  (ref, params) async* {
    final cacheService = ref.watch(postCacheServiceProvider);
    final getFeedUseCase = ref.watch(getFeedUseCaseProvider);

    // 1. 즉시 캐시 emit (L1/L2에서 <30ms)
    final cachedPosts = await cacheService.getFeedPosts(
      sortBy: params.sortBy,
      limit: params.limit,
    );

    if (cachedPosts.isNotEmpty) {
      yield cachedPosts;  // ✅ 즉각 UI 업데이트
    } else {
      yield [];  // 로딩 상태
    }

    // 2. 백그라운드에서 최신 데이터 가져오기
    final either = await getFeedUseCase.execute(
      limit: params.limit,
      sortBy: params.sortBy,
      filter: params.filter,
    );

    yield* either.fold(
      (failure) => Stream<List<PostDisplay>>.error(failure),
      (feedResult) async* {
        // 3. 캐시 업데이트 (백그라운드)
        cacheService.setFeedPosts(
          posts: feedResult.posts,
          sortBy: params.sortBy,
          limit: params.limit,
        ).ignore();

        yield feedResult.posts;
      },
    );

    ref.keepAlive();
  },
);

// ========== Post Detail Stream Provider (캐시 우선) ==========

/// 게시물 상세 스트림 Provider (캐시 우선)
final postDetailStreamProvider = StreamProvider.autoDispose
    .family<PostDisplay?, PostDetailParams>(
  (ref, params) async* {
    final cacheService = ref.watch(postCacheServiceProvider);
    final repository = ref.watch(postDisplayRepositoryProvider);

    // 1. 캐시 체크
    final cachedPost = await cacheService.getPost(params.postId);
    if (cachedPost != null) {
      yield cachedPost;  // ✅ 즉시 emit
    } else {
      yield null;  // 로딩 상태
    }

    // 2. 실시간 Stream 구독
    await for (final post in repository.streamPost(params.postId)) {
      if (post != null) {
        // 3. 캐시 업데이트
        cacheService.setPost(params.postId, post).ignore();
      }
      yield post;
    }

    ref.keepAlive();
  },
);

// ... 다른 Providers
```

### Step 6: DI 모듈에 PostCacheService 등록

**파일**: `di/post_di_module.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/services/cache/unified_cache_service.dart';
import '../data/services/post_cache_service.dart';
import '../domain/usecases/get_feed_usecase.dart';
import '../domain/repositories/i_post_display_repository_v2.dart';
import '../data/repositories/post_display_repository_v2_impl.dart';

// ========== Cache Service Provider ==========

/// PostCacheService Provider
final postCacheServiceProvider = Provider<PostCacheService>((ref) {
  final unifiedCache = UnifiedCacheService.instance;
  return PostCacheService(cache: unifiedCache);
});

// ========== Repository Providers ==========

final postDisplayRepositoryProvider = Provider<IPostDisplayRepositoryV2>((ref) {
  final dataSource = ref.watch(postDisplayDataSourceProvider);
  final cacheService = ref.watch(postCacheServiceProvider);  // ✅ 캐시 주입

  return PostDisplayRepositoryV2Impl(
    dataSource: dataSource,
    cacheService: cacheService,
  );
});

// ========== UseCase Providers ==========

final getFeedUseCaseProvider = Provider<GetFeedUseCase>((ref) {
  final repository = ref.watch(postDisplayRepositoryProvider);
  return GetFeedUseCase(postRepository: repository);
});

// ... 다른 UseCase Providers
```

### Step 7: main.dart에 프리로딩 추가

**파일**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/services/cache/unified_cache_service.dart';
import '/services/cache/preload_strategy.dart';
import '/features/post/data/services/post_cache_service.dart';
import '/features/post/di/post_di_module.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. UnifiedCacheService 초기화
  await UnifiedCacheService.initialize();

  // 2. Riverpod Container 생성
  final container = ProviderContainer();

  // 3. 500ms 후 프리로드 시작 (UI 렌더링 완료 대기)
  Future.delayed(const Duration(milliseconds: 500), () async {
    // 채팅 프리로드 (기존)
    await PreloadStrategy.preloadRecentChats();

    // ✅ 게시물 프리로드 (신규)
    await _preloadPosts(container);
  });

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

/// 게시물 프리로드
Future<void> _preloadPosts(ProviderContainer container) async {
  try {
    final cacheService = container.read(postCacheServiceProvider);
    final repository = container.read(postDisplayRepositoryProvider);

    // 1. 인기 게시물 프리로드
    await cacheService.preloadPopularPosts(
      fetchPopularPosts: () async {
        final stream = repository.getPopularPosts(limit: 20);
        return await stream.first;
      },
    );

    // 2. 트렌딩 게시물 프리로드
    await cacheService.preloadTrendingPosts(
      fetchTrendingPosts: () async {
        final stream = repository.getTrendingPosts(limit: 20);
        return await stream.first;
      },
    );

    print('✅ Posts preloaded successfully');
  } catch (e) {
    print('Failed to preload posts: $e');
  }
}
```

### Step 8: 테스트 및 검증

```bash
# 1. 컴파일 에러 확인
flutter analyze lib/features/post

# 2. JSON 직렬화 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 빌드 테스트
flutter build apk --debug

# 4. 수동 테스트
# - 앱 시작 → 캐시 프리로드 확인
# - 피드 로드 (첫 로드: 캐시, 두 번째: 즉시 표시)
# - 오프라인 모드 → 캐시된 데이터 표시
# - 캐시 통계 확인 (getStatistics())
```

---

## 🧪 테스트 전략

### 1. 캐시 레이어 단위 테스트

**파일**: `test/unit/services/post_cache_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('PostCacheService', () {
    late PostCacheService cacheService;
    late MockUnifiedCacheService mockCache;

    setUp(() {
      mockCache = MockUnifiedCacheService();
      cacheService = PostCacheService(cache: mockCache);
    });

    test('getFeedPosts L1 캐시 히트', () async {
      // Arrange
      final mockPosts = [
        PostDisplay(id: '1', titleA: 'A', titleB: 'B'),
      ];
      final jsonData = mockPosts.map((p) => p.toJson()).toList();

      when(mockCache.get<List<dynamic>>('feed_latest_limit_20'))
          .thenAnswer((_) async => jsonData);

      // Act
      final result = await cacheService.getFeedPosts(
        sortBy: FeedSortBy.latest,
        limit: 20,
      );

      // Assert
      expect(result, mockPosts);
      verify(mockCache.get<List<dynamic>>('feed_latest_limit_20')).called(1);
    });

    test('setFeedPosts 캐시 저장', () async {
      // Arrange
      final mockPosts = [
        PostDisplay(id: '1', titleA: 'A', titleB: 'B'),
      ];

      // Act
      await cacheService.setFeedPosts(
        posts: mockPosts,
        sortBy: FeedSortBy.latest,
        limit: 20,
      );

      // Assert
      verify(mockCache.set(
        'feed_latest_limit_20',
        any,
        ttl: const Duration(minutes: 5),
      )).called(1);
    });

    test('invalidateFeedPosts 특정 정렬', () async {
      // Act
      await cacheService.invalidateFeedPosts(sortBy: FeedSortBy.latest);

      // Assert
      verify(mockCache.remove('feed_latest_limit_20')).called(1);
    });

    test('invalidateFeedPosts 전체', () async {
      // Act
      await cacheService.invalidateFeedPosts();

      // Assert
      verify(mockCache.invalidate('feed_*')).called(1);
    });
  });
}
```

### 2. Repository 캐시 통합 테스트

**파일**: `test/integration/repositories/post_repository_cache_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('PostDisplayRepositoryV2Impl 캐시 통합', () {
    late PostDisplayRepositoryV2Impl repository;
    late MockPostCacheService mockCacheService;
    late MockIPostDisplayDataSource mockDataSource;

    setUp(() {
      mockCacheService = MockPostCacheService();
      mockDataSource = MockIPostDisplayDataSource();
      repository = PostDisplayRepositoryV2Impl(
        dataSource: mockDataSource,
        cacheService: mockCacheService,
      );
    });

    test('getPost 캐시 히트 시나리오', () async {
      // Arrange
      final mockPost = PostDisplay(id: '1', titleA: 'A', titleB: 'B');
      when(mockCacheService.getPost('1'))
          .thenAnswer((_) async => mockPost);

      // Act
      final result = await repository.getPost('1');

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (post) => expect(post, mockPost),
      );

      // 캐시 히트로 DataSource 호출 안 함
      verifyNever(mockDataSource.getPost('1'));
    });

    test('getPost 캐시 미스 시나리오', () async {
      // Arrange
      when(mockCacheService.getPost('1'))
          .thenAnswer((_) async => null);  // 캐시 미스

      final mockData = {'id': '1', 'titleA': 'A', 'titleB': 'B'};
      when(mockDataSource.getPost('1'))
          .thenAnswer((_) async => mockData);

      // Act
      final result = await repository.getPost('1');

      // Assert
      expect(result.isRight(), isTrue);

      // DataSource 호출됨
      verify(mockDataSource.getPost('1')).called(1);

      // 캐시 업데이트됨
      verify(mockCacheService.setPost('1', any)).called(1);
    });

    test('getFeedPosts 캐시 우선 전략', () async {
      // Arrange
      final mockPosts = [
        PostDisplay(id: '1', titleA: 'A', titleB: 'B'),
      ];
      when(mockCacheService.getFeedPosts(
        sortBy: FeedSortBy.latest,
        limit: 20,
      )).thenAnswer((_) async => mockPosts);

      // Act
      final result = await repository.getFeedPosts(
        sortBy: FeedSortBy.latest,
        limit: 20,
      );

      // Assert
      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (posts) => expect(posts, mockPosts),
      );

      // 캐시 히트로 Stream 호출 안 함
      verifyNever(mockDataSource.queryPosts(
        queryBuilder: anyNamed('queryBuilder'),
        limit: anyNamed('limit'),
      ));
    });
  });
}
```

### 3. Provider 캐시 프리로딩 테스트

**파일**: `test/widget/providers/feed_provider_cache_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

void main() {
  testWidgets('feedStreamProvider 캐시 우선 emit', (tester) async {
    // Arrange
    final mockCachedPosts = [
      PostDisplay(id: '1', titleA: 'Cached', titleB: 'Cached'),
    ];
    final mockFreshPosts = [
      PostDisplay(id: '2', titleA: 'Fresh', titleB: 'Fresh'),
    ];

    final container = ProviderContainer(
      overrides: [
        postCacheServiceProvider.overrideWithValue(
          MockPostCacheService()
            ..getFeedPosts(sortBy: FeedSortBy.latest, limit: 20)
                .thenAnswer((_) async => mockCachedPosts),
        ),
        getFeedUseCaseProvider.overrideWithValue(
          MockGetFeedUseCase()
            ..execute(limit: 20, sortBy: FeedSortBy.latest)
                .thenAnswer((_) async => right(FeedResult(posts: mockFreshPosts))),
        ),
      ],
    );

    // Act
    final asyncValue = await container.read(
      feedStreamProvider(FeedParams()).future,
    );

    // Assert - 캐시 데이터가 먼저 emit됨
    // (실제로는 Stream.listen으로 순서 확인 필요)
    expect(asyncValue, isNotEmpty);
  });
}
```

### 4. E2E 캐시 플로우 테스트

```dart
void main() {
  testWidgets('캐시 우선 → 최신 데이터 업데이트 플로우', (tester) async {
    await tester.pumpWidget(
      ProviderScope(child: MyApp()),
    );

    // 1. 앱 시작 → 캐시된 데이터 즉시 표시 (<30ms)
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.byType(PostCard), findsWidgets);

    // 2. 백그라운드 로드 완료 → 최신 데이터 업데이트
    await tester.pumpAndSettle();
    expect(find.byType(PostCard), findsWidgets);

    // 3. 오프라인 모드 전환
    // (네트워크 차단 시뮬레이션)

    // 4. 피드 새로고침 → 캐시 데이터 표시
    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 30));
    expect(find.byType(PostCard), findsWidgets);  // 캐시 데이터 표시됨
  });
}
```

---

## 🔄 롤백 계획

### 롤백이 필요한 경우

1. **캐시 동기화 문제**: 캐시와 Firestore 데이터 불일치
2. **메모리 누수**: 캐시 크기 제어 실패
3. **성능 저하**: 캐시 오버헤드로 인한 성능 악화
4. **오프라인 버그**: 오프라인 모드에서 예상치 못한 동작

### 롤백 절차

#### Step 1: Git Revert

```bash
# Phase 3 커밋 찾기
git log --oneline --grep="Cache Integration"

# Revert
git revert <commit-hash>
```

#### Step 2: PostCacheService 제거

```bash
# 캐시 서비스 파일 삭제
rm lib/features/post/data/services/post_cache_service.dart

# DI 모듈에서 제거
# - postCacheServiceProvider 제거
# - Repository에서 cacheService 파라미터 제거
```

#### Step 3: Repository 복구

```dart
// After (롤백 후)
class PostDisplayRepositoryV2Impl {
  final IPostDisplayDataSource _dataSource;
  // cacheService 제거

  Future<PostDisplay?> getPost(String postId) async {
    final data = await _dataSource.getPost(postId);
    // 캐시 체크 제거
  }
}
```

#### Step 4: Provider 복구

```dart
// After (롤백 후)
final feedStreamProvider = StreamProvider.autoDispose.family(...) {
  (ref, params) async* {
    yield [];
    // 캐시 emit 제거

    final either = await getFeedUseCase.execute(...);
    yield* either.fold(...);
  }
};
```

#### Step 5: main.dart 프리로딩 제거

```dart
// After (롤백 후)
void main() async {
  // _preloadPosts() 호출 제거
  runApp(MyApp());
}
```

---

## ✅ 완료 체크리스트

### Phase 3 완료 기준

- [ ] **PostCacheService 구현**
  - [ ] post_cache_service.dart 생성
  - [ ] getFeedPosts, setFeedPosts 구현
  - [ ] getPost, setPost 구현
  - [ ] getPopularPosts, setPopularPosts 구현
  - [ ] getTrendingPosts, setTrendingPosts 구현
  - [ ] getUserPosts, setUserPosts 구현
  - [ ] invalidate, clear 메서드 구현
  - [ ] preloadPopularPosts, preloadTrendingPosts 구현

- [ ] **PostDisplay JSON 직렬화**
  - [ ] post_display.dart에 fromJson, toJson 추가
  - [ ] TimestampConverter 구현
  - [ ] build_runner 실행으로 코드 생성 완료

- [ ] **Repository 캐시 통합**
  - [ ] PostDisplayRepositoryV2Impl에 PostCacheService 주입
  - [ ] getPost 메서드 캐시 우선 전략 적용
  - [ ] getFeedPosts 헬퍼 메서드 추가
  - [ ] 캐시 업데이트 백그라운드 처리 (.ignore())

- [ ] **UseCase 캐시 지원**
  - [ ] GetFeedUseCase.execute 캐시 우선 전략
  - [ ] getFeedStream 실시간 업데이트 유지

- [ ] **Provider 캐시 프리로딩**
  - [ ] feedStreamProvider 캐시 즉시 emit 추가
  - [ ] postDetailStreamProvider 캐시 우선 적용
  - [ ] 백그라운드 캐시 업데이트 구현

- [ ] **DI 모듈 업데이트**
  - [ ] postCacheServiceProvider 등록
  - [ ] Repository에 cacheService 주입

- [ ] **main.dart 프리로딩**
  - [ ] _preloadPosts() 함수 추가
  - [ ] preloadPopularPosts 호출
  - [ ] preloadTrendingPosts 호출
  - [ ] 500ms 지연 후 실행

- [ ] **테스트**
  - [ ] PostCacheService 단위 테스트
  - [ ] Repository 캐시 통합 테스트
  - [ ] Provider 캐시 프리로딩 테스트
  - [ ] E2E 캐시 플로우 테스트

- [ ] **성능 검증**
  - [ ] 캐시 히트 시 <10ms 응답 확인
  - [ ] Firestore 읽기 60% 감소 확인
  - [ ] 오프라인 모드 데이터 표시 확인
  - [ ] 메모리 사용량 모니터링

- [ ] **컴파일 & 분석**
  - [ ] `flutter analyze lib/features/post` 에러 없음
  - [ ] `flutter test` 모든 테스트 통과
  - [ ] 수동 테스트: 캐시 히트, 오프라인, 프리로딩 정상

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] README.md에 캐시 전략 설명 추가
  - [ ] Phase 4 준비 (Idempotency Service)

---

## 📊 마이그레이션 영향 분석

### 코드 증가량

| 파일 | Before (줄) | After (줄) | 증가율 |
|------|------------|-----------|--------|
| post_cache_service.dart | - | 180 | +180줄 |
| post_display.dart | 80 | 100 | +20줄 (+25%) |
| post_display_repository_v2_impl.dart | 200 | 320 | +120줄 (+60%) |
| get_feed_usecase.dart | 100 | 120 | +20줄 (+20%) |
| post_providers.dart | 180 | 220 | +40줄 (+22%) |
| post_di_module.dart | 60 | 80 | +20줄 (+33%) |
| main.dart | 50 | 80 | +30줄 (+60%) |
| **합계** | **670줄** | **1,100줄** | **+430줄 (+64%)** |

### 성능 비교

| 항목 | Before (Direct Firestore) | After (3-Layer Cache) | 개선율 |
|------|---------------------------|----------------------|--------|
| **응답 시간 (L1 Hit)** | 300-600ms | <10ms | **97% ↓** |
| **응답 시간 (L2 Hit)** | 300-600ms | 10-30ms | **95% ↓** |
| **응답 시간 (L3 Hit)** | 300-600ms | 50-100ms | **80% ↓** |
| **Firestore 읽기** | 100% | 40% | **60% ↓** |
| **오프라인 지원** | 제한적 | 완전 지원 | **100% ↑** |
| **메모리 사용** | 비효율적 | LRU 관리 | **30% ↓** |

### 비용 분석 (월간)

**가정**:
- MAU (Monthly Active Users): 10,000명
- 사용자당 평균 피드 조회: 20회/일
- Firestore 읽기 비용: $0.06/100,000 reads

| 항목 | Before | After | 절감액 |
|------|--------|-------|--------|
| **월간 피드 조회** | 6,000,000회 | 6,000,000회 | - |
| **Firestore 읽기** | 6,000,000회 | 2,400,000회 | -3,600,000회 |
| **비용** | $3.60 | $1.44 | **$2.16 (60%)** |

### 사용자 경험

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **첫 로드 속도** | ⭐⭐☆☆☆ | ⭐⭐⭐⭐⭐ | 즉각 반응 |
| **오프라인 경험** | ⭐⭐☆☆☆ | ⭐⭐⭐⭐⭐ | 완전 지원 |
| **스크롤 부드러움** | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | 버터처럼 |
| **데이터 신선도** | ⭐⭐⭐⭐☆ | ⭐⭐⭐⭐⭐ | 백그라운드 동기화 |
| **전체 만족도** | ⭐⭐⭐☆☆ | ⭐⭐⭐⭐⭐ | 크게 향상 |

---

## 🎓 추가 학습 자료

### 3-Layer 캐싱 전략

#### 1. Cache-First vs Network-First

```dart
// ❌ Network-First (느림)
final posts = await repository.getFeedPosts();
await cacheService.setFeedPosts(posts);
return posts;

// ✅ Cache-First (빠름)
final cachedPosts = await cacheService.getFeedPosts();
if (cachedPosts.isNotEmpty) {
  return cachedPosts;  // <10ms
}
final posts = await repository.getFeedPosts();
await cacheService.setFeedPosts(posts);
return posts;
```

#### 2. Stale-While-Revalidate 패턴

```dart
// ✅ 캐시 즉시 반환 + 백그라운드 갱신
final cachedPosts = await cacheService.getFeedPosts();
if (cachedPosts.isNotEmpty) {
  yield cachedPosts;  // 즉시 UI 업데이트
}

// 백그라운드에서 최신 데이터 가져오기
final freshPosts = await repository.getFeedPosts();
await cacheService.setFeedPosts(freshPosts);
yield freshPosts;  // 최신 데이터로 업데이트
```

#### 3. TTL (Time To Live) 전략

```dart
// 짧은 TTL: 자주 변하는 데이터
await cacheService.setFeedPosts(
  posts,
  ttl: Duration(minutes: 5),  // 5분
);

// 긴 TTL: 정적 데이터
await cacheService.setPost(
  postId,
  post,
  ttl: Duration(hours: 1),  // 1시간
);
```

#### 4. 프리로딩 전략

```dart
// ✅ 앱 시작 시 프리로드
Future<void> main() async {
  await UnifiedCacheService.initialize();

  // 500ms 후 프리로드 (UI 렌더링 완료 대기)
  Future.delayed(Duration(milliseconds: 500), () {
    preloadPopularPosts();
    preloadTrendingPosts();
  });

  runApp(MyApp());
}

// ✅ 사용자 스크롤 패턴 학습
// - 사용자가 자주 보는 카테고리 프리로드
// - 스크롤 방향 예측하여 다음 페이지 프리로드
```

### Chat & Auth Feature 참조

- **Chat PHASE_3_CACHE_INTEGRATION.md**: 3-Layer 캐싱 상세 가이드
- **UnifiedCacheService**: 캐시 서비스 구현 참조
- **PreloadStrategy**: 프리로딩 전략 패턴

---

## 📌 다음 단계: Phase 4

Phase 3 완료 후, **Phase 4: IdempotencyService Integration**으로 진행:

```
중복 작업 방지 + Transaction 기반 원자성 보장
```

**예상 효과**:
- 중복 게시물 생성 방지
- 네트워크 재시도 안전성
- Transaction 기반 일관성
- 사용자 경험 개선

---

**작성자**: AI Assistant
**리뷰어**: [Your Name]
**승인일**: [YYYY-MM-DD]
