# Post Feature - Domain Layer 문서

> **Version**: 1.0.0
> **Last Updated**: 2025-01-20
> **Clean Architecture**: v4.0
> **Layer**: Domain Layer (비즈니스 로직)

---

## 📊 개요

Post Feature의 Domain Layer는 **비즈니스 로직의 핵심**으로, 게시물 조회 및 표시에 대한 순수한 도메인 규칙을 정의합니다. Clean Architecture v4.0 원칙에 따라 **외부 의존성이 전혀 없는** 순수 Dart 코드로 구성되어 있습니다.

### 핵심 특징

- ✅ **완전한 의존성 독립**: Firebase, Flutter 등 외부 프레임워크 의존성 제로
- ✅ **비즈니스 로직 캡슐화**: 게시물 조회, 필터링, 정렬 규칙 정의
- ✅ **테스트 가능성**: 순수 Dart 코드로 100% 단위 테스트 가능
- ✅ **인터페이스 기반 설계**: Repository 계약으로 구현체와 분리
- ✅ **Result 패턴**: Success/Failure로 명확한 에러 처리
- ✅ **UseCase 패턴**: 단일 책임 원칙으로 각 기능 독립화

### Domain Layer의 역할

```
[Presentation Layer]
        ↓ 요청
   [UseCase] ← 비즈니스 로직 실행
        ↓ Repository 인터페이스 호출
[IPostDisplayRepositoryV2] ← Domain에서 정의
        ↓ 구현은 Data Layer에서
[PostDisplayRepositoryV2Impl]
        ↓
   [Firestore]
```

**Domain은 "무엇을 해야 하는가"를 정의하고, Data는 "어떻게 할 것인가"를 구현합니다.**

---

## 🏗️ 전체 구조도

```
lib/features/post/domain/
├── models/
│   └── post_display.dart                        # 순수 Domain 모델 (266줄)
│
├── repositories/
│   ├── i_post_display_repository_v2.dart        # Repository 계약 (15 메서드)
│   └── i_post_query_service.dart                # 복잡한 쿼리 서비스 계약
│
└── usecases/
    ├── get_feed_usecase.dart                    # 피드 조회 (270줄)
    ├── get_post_detail_usecase.dart             # 게시물 상세 (108줄)
    ├── get_trending_posts_usecase.dart          # 트렌딩 조회 (75줄)
    ├── get_popular_posts_usecase.dart           # 인기 게시물 조회
    └── get_user_posts_usecase.dart              # 사용자 게시물 조회
```

### 아키텍처 플로우

```
[Presentation: Provider]
        ↓ call
   [UseCase]
        ↓ execute
[Repository Interface] ← Domain Layer 경계
        ↓ implements (Data Layer)
[Repository Implementation]
        ↓
   [DataSource]
        ↓
   [Firestore]
```

---

## 📂 디렉토리별 상세 설명

### 1. `/models` - 도메인 모델

#### **`post_display.dart`** (266줄)

**책임**: 게시물 표시를 위한 순수 도메인 모델

**핵심 원칙**:
- ✅ **불변성(Immutability)**: 모든 필드 `final`
- ✅ **값 객체(Value Object)**: Equatable로 동등성 비교
- ✅ **순수 Dart**: 외부 의존성 완전 제거
- ✅ **UI 최적화**: 표시에 필요한 필드만 포함

**모델 구조**:

```dart
class PostDisplay extends Equatable {
  // 1. 식별 정보 (4 fields)
  final String id;
  final String userId;
  final String displayName;
  final String photoUrl;

  // 2. 콘텐츠 정보 (8 fields)
  final String questionTitle;
  final String? description;
  final String? optionAText;
  final String? optionBText;
  final String? optionAImageUrl;      // 단일 이미지 (레거시)
  final String? optionBImageUrl;
  final List<String>? optionAImages;  // 멀티 이미지
  final List<double>? optionAAspectRatios;
  final List<String>? optionBImages;
  final List<double>? optionBAspectRatios;
  final String layoutType;            // 'vertical' | 'horizontal'

  // 3. 투표 정보 (6 fields)
  final int votesA;
  final int votesB;
  final String voteStatus;            // 'pending' | 'in_progress' | 'completed'
  final bool voteCompleted;
  final DateTime? voteStartTime;
  final DateTime? voteEndTime;

  // 4. 참여 메트릭 (3 fields)
  final int commentCount;
  final int likeCount;
  final int shareCount;

  // 5. 메타데이터 (4 fields)
  final DateTime createdAt;
  final bool isAnonymous;
  final String status;                // 'published' | 'draft' | 'archived'
  final Map<String, dynamic>? targetAudience;
}
```

**계산된 속성 (Computed Properties)**:

```dart
// 투표 비율 계산
double get votePercentageA {
  final total = votesA + votesB;
  if (total == 0) return 50.0;
  return (votesA / total) * 100;
}

double get votePercentageB {
  final total = votesA + votesB;
  if (total == 0) return 50.0;
  return (votesB / total) * 100;
}

// 총 투표 수
int get totalVotes => votesA + votesB;

// 총 참여도 (댓글 + 좋아요 + 공유)
int get totalEngagement => commentCount + likeCount + shareCount;

// 이미지 유무 확인
bool get hasImages => optionAImageUrl != null || optionBImageUrl != null;
bool get isTextOnly => !hasImages;
```

**핵심 메서드**:

**1. copyWith() - 불변 객체 업데이트**:
```dart
PostDisplay copyWith({
  String? id,
  String? questionTitle,
  int? votesA,
  int? votesB,
  // ... 모든 필드
}) {
  return PostDisplay(
    id: id ?? this.id,
    questionTitle: questionTitle ?? this.questionTitle,
    votesA: votesA ?? this.votesA,
    votesB: votesB ?? this.votesB,
    // ...
  );
}
```

**사용 예시**:
```dart
// 투표 수 업데이트
final updatedPost = post.copyWith(
  votesA: post.votesA + 1,
  voteStatus: 'in_progress',
);

// 상태 변경
final completedPost = post.copyWith(
  voteStatus: 'completed',
  voteCompleted: true,
  voteEndTime: DateTime.now(),
);
```

**2. toMap() - 직렬화**:
```dart
Map<String, dynamic> toMap() {
  return {
    'id': id,
    'questionTitle': questionTitle,
    'userid': userId,
    'optionA': {
      if (optionAText != null) 'text': optionAText,
      if (optionAImages != null) 'images': optionAImages!.map(...),
    },
    'optionB': {
      if (optionBText != null) 'text': optionBText,
      if (optionBImages != null) 'images': optionBImages!.map(...),
    },
    'votesA': votesA,
    'votesB': votesB,
    // ...
  };
}
```

**3. props - 동등성 비교 (Equatable)**:
```dart
@override
List<Object?> get props => [
  id,
  questionTitle,
  userId,
  votesA,
  votesB,
  // ... 모든 필드 (25개)
];
```

**장점**:
- 두 PostDisplay 객체를 `==`로 비교 가능
- Provider의 notifyListeners() 최적화
- 테스트 코드에서 `expect(post1, equals(post2))` 사용 가능

---

### 2. `/repositories` - Repository 인터페이스

#### **A. `i_post_display_repository_v2.dart`**

**책임**: 게시물 조회 작업의 계약 정의

**15개 메서드**:

**1. 기본 쿼리**:
```dart
abstract class IPostDisplayRepositoryV2 {
  // 범용 쿼리 (가장 유연함)
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // 단일 조회
  Future<PostDisplay?> getPost(String postId);

  // 실시간 스트림
  Stream<PostDisplay?> streamPost(String postId);
}
```

**queryBuilder 패턴 예시**:
```dart
// 최신순 정렬
final posts = await repository.queryPosts(
  queryBuilder: (params) => {
    ...params,
    'orderBy': 'createdAt',
    'descending': true,
  },
  limit: 20,
).first;

// 특정 사용자 필터링
final userPosts = await repository.queryPosts(
  queryBuilder: (params) => {
    ...params,
    'where': {'userid': 'user123'},
    'orderBy': 'createdAt',
  },
).first;
```

**2. 특수 쿼리**:
```dart
// 트렌딩 게시물 (참여도 기준 정렬)
Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});

// 사용자별 게시물
Stream<List<PostDisplay>> getUserPosts({
  required String userId,
  int limit = -1,
});

// 카테고리별 게시물
Stream<List<PostDisplay>> getPostsByCategory({
  required String category,
  int limit = -1,
});

// 진행중 투표
Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});

// 완료된 투표
Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});

// 인기 게시물 (좋아요 기준)
Stream<List<PostDisplay>> getPopularPosts({
  int limit = 20,
  Duration? timeWindow,  // 시간 범위 필터
});
```

**3. 검색 및 추천**:
```dart
// 키워드 검색
Future<List<PostDisplay>> searchPosts({
  required String query,
  int limit = 20,
});

// 추천 게시물
Future<List<PostDisplay>> getRecommendedPosts({
  required String userId,
  int limit = 20,
});
```

**4. 배치 작업**:
```dart
// 여러 게시물 한번에 조회
Future<List<PostDisplay>> getPostsByIds(List<String> postIds);
```

**5. 페이지네이션**:
```dart
// 커서 기반 페이지네이션
Stream<List<PostDisplay>> getPostsAfter({
  required String lastPostId,
  int limit = 20,
  Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
});
```

**6. 복합 필터**:
```dart
// 다중 조건 필터링
Stream<List<PostDisplay>> getPostsWithFilters({
  String? userId,
  String? status,
  bool? isAnonymous,
  DateTime? createdAfter,
  DateTime? createdBefore,
  int limit = 20,
});
```

**7. 메트릭 업데이트**:
```dart
// 조회수 증가
Future<void> incrementViewCount(String postId);
```

**인터페이스 특징**:
- ✅ **구현 독립성**: Data Layer가 자유롭게 구현 가능
- ✅ **테스트 용이성**: Mock 객체로 쉽게 대체
- ✅ **명확한 계약**: 입력/출력 타입이 명확함
- ✅ **비동기 지원**: Future/Stream으로 유연한 데이터 플로우

#### **B. `i_post_query_service.dart`**

**책임**: 복잡한 검색 및 쿼리 작업 계약

**⚠️ 주의**: 현재 **PostCreation** (Creation feature) 모델 사용 중 → 리팩토링 필요

**주요 메서드**:

**1. 검색 기능**:
```dart
// 조건 기반 검색
Future<List<PostCreation>> searchContent(SearchCriteria criteria);

// 전문 검색 (Algolia)
Future<List<PostCreation>> fullTextSearch(String query, {int limit = 50});

// 유사 콘텐츠 추천
Future<List<PostCreation>> getSimilarContent(String contentId, {int limit = 10});
```

**2. 페이지네이션**:
```dart
Future<PaginatedResult<PostCreation>> getContentPaginated({
  String? lastDocumentId,
  int pageSize = 10,
  SortOrder sortOrder = SortOrder.createdDesc,
});
```

**3. 통계 정보**:
```dart
Future<ContentStatistics> getContentStatistics();
```

**4. 스트림 지원**:
```dart
Stream<PostCreation?> getContentStream(String contentId);
Stream<List<PostCreation>> getAllContentStream();
Stream<List<PostCreation>> getContentByCategory(String category);
Stream<List<PostCreation>> getRecentContent({int limit = 20});
```

**보조 클래스**:

**SearchCriteria**:
```dart
class SearchCriteria {
  final String? query;
  final String? category;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minVotes;
  final bool? isCompleted;
  final SortOrder sortOrder;
}
```

**SortOrder enum**:
```dart
enum SortOrder {
  createdDesc,    // 최신순
  createdAsc,     // 오래된순
  popularDesc,    // 인기순
  popularAsc,     // 비인기순
  votesDesc,      // 투표 많은 순
  votesAsc,       // 투표 적은 순
  trendingDesc,   // 트렌딩
}
```

**PaginatedResult**:
```dart
class PaginatedResult<T> {
  final List<T> items;
  final String? nextPageToken;
  final bool hasMore;
  final int totalCount;
}
```

**ContentFilter**:
```dart
class ContentFilter {
  final bool? isAnonymous;
  final bool? isPremium;
  final int? visibility;
  final List<String>? categories;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? minParticipants;
}
```

**ContentStatistics**:
```dart
class ContentStatistics {
  final int totalPosts;
  final int activePosts;
  final int completedVotes;
  final Map<String, int> postsByCategory;
  final double averageParticipation;
  final DateTime lastUpdated;
}
```

---

### 3. `/usecases` - 유스케이스 (비즈니스 로직)

#### **A. `get_feed_usecase.dart`** (270줄)

**책임**: 피드 조회 비즈니스 로직

**핵심 메서드**:

**1. execute() - 피드 조회**:
```dart
Future<Result<FeedResult>> execute({
  int limit = 20,
  String? lastDocumentId,        // 페이지네이션 커서
  FeedSortBy sortBy = FeedSortBy.latest,
  FeedFilter? filter,
}) async {
  try {
    Stream<List<PostDisplay>> stream;

    // 정렬 방식에 따른 분기
    switch (sortBy) {
      case FeedSortBy.latest:
        stream = _postRepository.queryPosts(
          queryBuilder: (params) => {
            'orderBy': 'createdAt',
            'descending': true,
          },
          limit: limit,
        );
        break;

      case FeedSortBy.popular:
        stream = _postRepository.getPopularPosts(limit: limit);
        break;

      case FeedSortBy.mostVoted:
        stream = _postRepository.queryPosts(
          queryBuilder: (params) => {
            'orderBy': 'votesA',
            'descending': true,
          },
          limit: limit,
        );
        break;

      case FeedSortBy.trending:
        stream = _postRepository.getTrendingPosts(limit: limit);
        break;
    }

    // 필터가 있으면 getPostsWithFilters 사용
    if (filter != null) {
      stream = _postRepository.getPostsWithFilters(
        userId: filter.userId,
        status: filter.status,
        isAnonymous: filter.isAnonymous,
        createdAfter: filter.startDate,
        createdBefore: filter.endDate,
        limit: limit,
      );
    }

    // 페이지네이션 처리
    if (lastDocumentId != null) {
      stream = _postRepository.getPostsAfter(
        lastPostId: lastDocumentId,
        limit: limit,
        queryBuilder: queryBuilder,
      );
    }

    // Stream → Future 변환
    final posts = await stream.first;

    return Success(
      FeedResult(
        posts: posts,
        hasMore: posts.length >= limit,
        lastDocumentId: posts.isNotEmpty ? posts.last.id : null,
        totalCount: posts.length,
      ),
    );
  } catch (error) {
    // 에러 처리
    if (error.toString().contains('permission-denied')) {
      return ResultFailure(
        ServerFailure(
          message: 'Permission denied to load feed',
          code: 'permission-denied',
        ),
      );
    }

    return ResultFailure(
      AppFailure(message: 'Failed to load feed: $error'),
    );
  }
}
```

**2. getFeedStream() - 실시간 피드**:
```dart
Stream<Result<List<PostDisplay>>> getFeedStream({
  int limit = 20,
  FeedSortBy sortBy = FeedSortBy.latest,
  FeedFilter? filter,
}) {
  try {
    // 쿼리 빌더 생성
    Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder = (params) {
      final queryParams = <String, dynamic>{...params};

      // 정렬 적용
      switch (sortBy) {
        case FeedSortBy.latest:
          queryParams['orderBy'] = 'createdAt';
          queryParams['descending'] = true;
          break;
        // ...
      }

      // 필터 적용
      if (filter != null) {
        if (filter.status != null) {
          queryParams['status'] = filter.status;
        }
        // ...
      }

      return queryParams;
    };

    // 스트림 가져오기
    final stream = _postRepository.queryPosts(
      queryBuilder: queryBuilder,
      limit: limit,
    );

    // Result로 래핑
    return stream.map((posts) => Success(posts));
  } catch (error) {
    return Stream.value(
      ResultFailure(
        AppFailure(message: 'Failed to create feed stream: $error'),
      ),
    );
  }
}
```

**보조 클래스**:

**FeedResult**:
```dart
class FeedResult {
  final List<PostDisplay> posts;
  final bool hasMore;            // 다음 페이지 존재 여부
  final String? lastDocumentId;  // 페이지네이션 커서
  final int totalCount;
}
```

**FeedSortBy enum**:
```dart
enum FeedSortBy {
  latest,     // 최신순
  popular,    // 인기순 (좋아요)
  mostVoted,  // 투표 많은 순
  trending,   // 트렌딩 (참여도)
}
```

**FeedFilter**:
```dart
class FeedFilter {
  final String? status;       // 'published', 'draft', 'archived'
  final String? userId;       // 특정 사용자
  final bool? hasImages;      // 이미지 포함 여부
  final bool? isAnonymous;    // 익명 게시물
  final DateTime? startDate;  // 날짜 범위 시작
  final DateTime? endDate;    // 날짜 범위 종료
}
```

**사용 예시**:

```dart
// Provider에서 사용
class FeedProvider extends ChangeNotifier {
  final GetFeedUseCase _getFeedUseCase;

  Future<void> initializeFeed() async {
    setLoadingState(FeedLoadingState.loading);

    final result = await _getFeedUseCase.execute(
      limit: 20,
      sortBy: FeedSortBy.latest,
    );

    result.fold(
      (failure) => handleError(failure, FeedLoadingState.error),
      (feedResult) {
        _posts = feedResult.posts;
        _hasMore = feedResult.hasMore;
        _lastDocumentId = feedResult.lastDocumentId;
        setLoadingState(FeedLoadingState.loaded);
      },
    );
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    setLoadingState(FeedLoadingState.loadingMore);

    final result = await _getFeedUseCase.execute(
      limit: 20,
      lastDocumentId: _lastDocumentId,
      sortBy: _currentSortBy,
    );

    result.fold(
      (failure) => handleError(failure, FeedLoadingState.error),
      (feedResult) {
        _posts.addAll(feedResult.posts);
        _hasMore = feedResult.hasMore;
        _lastDocumentId = feedResult.lastDocumentId;
        setLoadingState(FeedLoadingState.loaded);
      },
    );
  }
}
```

#### **B. `get_post_detail_usecase.dart`** (108줄)

**책임**: 단일 게시물 상세 조회

**핵심 메서드**:

**1. execute() - 게시물 상세 조회**:
```dart
Future<Result<PostDisplay>> execute({
  required String postId,
  bool incrementViewCount = true,  // 조회수 증가 여부
}) async {
  try {
    // 입력 검증
    if (postId.isEmpty) {
      return ResultFailure(
        ValidationFailure(message: 'Post ID cannot be empty'),
      );
    }

    // Repository에서 게시물 조회
    final post = await _postRepository.getPost(postId);

    // null 체크
    if (post == null) {
      return ResultFailure(
        NotFoundFailure(message: 'Post not found with ID: $postId'),
      );
    }

    // 조회수 증가 (Fire and Forget)
    if (incrementViewCount) {
      _postRepository.incrementViewCount(postId).catchError((error) {
        print('Failed to increment view count: $error');
      });
    }

    return Success(post);
  } catch (error) {
    // 에러 처리
    if (error.toString().contains('permission-denied')) {
      return ResultFailure(
        ServerFailure(
          message: 'Permission denied to load post',
          code: 'permission-denied',
        ),
      );
    }

    return ResultFailure(
      AppFailure(message: 'Failed to load post: $error'),
    );
  }
}
```

**2. getPostStream() - 실시간 스트림**:
```dart
Stream<Result<PostDisplay>> getPostStream({
  required String postId,
}) {
  try {
    // 입력 검증
    if (postId.isEmpty) {
      return Stream.value(
        ResultFailure(
          ValidationFailure(message: 'Post ID cannot be empty'),
        ),
      );
    }

    // Repository 스트림 구독
    final stream = _postRepository.streamPost(postId);

    // Result로 래핑
    return stream.map((post) {
      if (post == null) {
        return ResultFailure<PostDisplay>(
          NotFoundFailure(message: 'Post not found with ID: $postId'),
        );
      }
      return Success(post);
    });
  } catch (error) {
    return Stream.value(
      ResultFailure(
        AppFailure(message: 'Failed to create post stream: $error'),
      ),
    );
  }
}
```

**특징**:
- ✅ **조회수 자동 증가**: Fire-and-forget 패턴으로 UI 블로킹 없음
- ✅ **입력 검증**: 빈 postId 사전 차단
- ✅ **명확한 에러**: NotFoundFailure vs AppFailure 구분
- ✅ **실시간 업데이트**: Stream으로 투표 결과 자동 반영

**사용 예시**:

```dart
// Provider에서 사용
class PostDetailProvider extends ChangeNotifier {
  final GetPostDetailUseCase _getPostDetailUseCase;

  Future<void> loadPost(String postId) async {
    setLoadingState(PostDetailLoadingState.loading);

    final result = await _getPostDetailUseCase.execute(
      postId: postId,
      incrementViewCount: true,
    );

    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          handleError(failure, PostDetailLoadingState.notFound);
        } else {
          handleError(failure, PostDetailLoadingState.error);
        }
      },
      (post) {
        _post = post;
        setLoadingState(PostDetailLoadingState.loaded);
      },
    );
  }

  void startPostStream(String postId) {
    _subscription = _getPostDetailUseCase.getPostStream(
      postId: postId,
    ).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (post) => _updatePost(post),
        );
      },
    );
  }
}
```

#### **C. `get_trending_posts_usecase.dart`** (75줄)

**책임**: 트렌딩 게시물 조회

**핵심 메서드**:

**1. execute() - 트렌딩 조회**:
```dart
Future<Result<List<PostDisplay>>> execute({
  int limit = 20,
}) async {
  try {
    final stream = _postRepository.getTrendingPosts(limit: limit);
    final posts = await stream.first;

    return Success(posts);
  } catch (error) {
    if (error.toString().contains('permission-denied')) {
      return ResultFailure(
        ServerFailure(
          message: 'Permission denied to load trending posts',
          code: 'permission-denied',
        ),
      );
    }

    return ResultFailure(
      AppFailure(message: 'Failed to load trending posts: $error'),
    );
  }
}
```

**2. getTrendingStream() - 실시간 트렌딩**:
```dart
Stream<Result<List<PostDisplay>>> getTrendingStream({
  int limit = 20,
}) {
  try {
    final stream = _postRepository.getTrendingPosts(limit: limit);

    return stream.map((posts) => Success(posts));
  } catch (error) {
    return Stream.value(
      ResultFailure(
        AppFailure(message: 'Failed to create trending stream: $error'),
      ),
    );
  }
}
```

**트렌딩 알고리즘** (Data Layer에서 구현):
```
트렌딩 점수 = (좋아요 * 1) + (댓글 * 2) + (공유 * 3)
정렬: 최근 24시간 게시물을 트렌딩 점수 내림차순
```

**특징**:
- ✅ **간단한 인터페이스**: limit만 받음
- ✅ **실시간 업데이트**: Stream 지원
- ✅ **자동 정렬**: Repository가 알고리즘 처리

#### **D. `get_popular_posts_usecase.dart`**

**책임**: 인기 게시물 조회 (좋아요 기준)

**핵심 메서드**:
```dart
Future<Result<List<PostDisplay>>> execute({
  int limit = 20,
  Duration? timeWindow,  // 시간 범위 (예: Duration(days: 7))
}) async {
  try {
    final stream = _postRepository.getPopularPosts(
      limit: limit,
      timeWindow: timeWindow,
    );
    final posts = await stream.first;

    return Success(posts);
  } catch (error) {
    return ResultFailure(
      AppFailure(message: 'Failed to load popular posts: $error'),
    );
  }
}
```

**timeWindow 활용**:
```dart
// 오늘의 인기 게시물
final todayPopular = await useCase.execute(
  timeWindow: Duration(days: 1),
);

// 이번 주 인기 게시물
final weeklyPopular = await useCase.execute(
  timeWindow: Duration(days: 7),
);

// 전체 인기 게시물
final allTimePopular = await useCase.execute();
```

#### **E. `get_user_posts_usecase.dart`**

**책임**: 특정 사용자의 게시물 조회

**핵심 메서드**:
```dart
Future<Result<List<PostDisplay>>> execute({
  required String userId,
  int limit = -1,  // -1 = 무제한
}) async {
  try {
    // 입력 검증
    if (userId.isEmpty) {
      return ResultFailure(
        ValidationFailure(message: 'User ID cannot be empty'),
      );
    }

    final stream = _postRepository.getUserPosts(
      userId: userId,
      limit: limit,
    );
    final posts = await stream.first;

    return Success(posts);
  } catch (error) {
    return ResultFailure(
      AppFailure(message: 'Failed to load user posts: $error'),
    );
  }
}
```

**특징**:
- ✅ **무제한 조회**: limit = -1로 모든 게시물 가져오기 가능
- ✅ **익명 게시물 제외**: Repository에서 자동 필터링
- ✅ **최신순 정렬**: createdAt 내림차순

---

## 🔄 데이터 플로우

### 1. 피드 조회 플로우

```
[HomePageWidget]
      ↓ onInit
[FeedProvider.initializeFeed()]
      ↓ call
[GetFeedUseCase.execute()]
      ↓ 비즈니스 로직
   [정렬 방식 선택]
   [필터 적용]
   [페이지네이션 처리]
      ↓ Repository 호출
[IPostDisplayRepositoryV2.queryPosts()]
      ↓ (Data Layer 구현)
[PostDisplayRepositoryV2Impl]
      ↓ DataSource
[FirebasePostDisplayDataSource]
      ↓ Firestore
[Stream<List<PostDisplay>>]
      ↓ first
[List<PostDisplay>]
      ↓ Result 래핑
[Success(FeedResult)]
      ↓ fold
[FeedProvider._posts 업데이트]
      ↓ notifyListeners
   [UI 리빌드]
```

### 2. 게시물 상세 조회 플로우

```
[PostDetailPage]
      ↓ onInit
[PostDetailProvider.loadPost(postId)]
      ↓ call
[GetPostDetailUseCase.execute(postId)]
      ↓ 비즈니스 로직
   [입력 검증]
   [조회수 증가 (Fire-and-Forget)]
      ↓ Repository 호출
[IPostDisplayRepositoryV2.getPost(postId)]
      ↓ (Data Layer 구현)
[PostDisplayRepositoryV2Impl.getPost()]
      ↓ DataSource
[FirebasePostDisplayDataSource.getPost()]
      ↓ Firestore
[Future<Map<String, dynamic>?>]
      ↓ Mapper
[PostDisplayDto → PostDisplay]
      ↓ null 체크
   [post == null → NotFoundFailure]
   [post != null → Success(post)]
      ↓ fold
[PostDetailProvider._post 업데이트]
      ↓ notifyListeners
   [UI 리빌드]
```

### 3. 실시간 스트림 플로우

```
[PostDetailProvider.startPostStream(postId)]
      ↓ call
[GetPostDetailUseCase.getPostStream(postId)]
      ↓ 비즈니스 로직
   [입력 검증]
      ↓ Repository 호출
[IPostDisplayRepositoryV2.streamPost(postId)]
      ↓ (Data Layer 구현)
[PostDisplayRepositoryV2Impl.streamPost()]
      ↓ DataSource
[FirebasePostDisplayDataSource.queryPosts()]
      ↓ Firestore
[Stream<QuerySnapshot>]
      ↓ map
[Stream<List<Map<String, dynamic>>>]
      ↓ Mapper
[Stream<PostDisplay?>]
      ↓ map (Result 래핑)
[Stream<Result<PostDisplay>>]
      ↓ listen
[PostDetailProvider._updatePost()]
      ↓ notifyListeners
   [UI 자동 업데이트]
```

### 4. 페이지네이션 플로우

```
[사용자 스크롤 80% 도달]
      ↓ 감지
[FeedProvider.loadMore()]
      ↓ call
[GetFeedUseCase.execute(lastDocumentId: _lastDocumentId)]
      ↓ 비즈니스 로직
   [lastDocumentId를 쿼리에 포함]
      ↓ Repository 호출
[IPostDisplayRepositoryV2.getPostsAfter(lastPostId)]
      ↓ (Data Layer 구현)
[FirebasePostDisplayDataSource.queryPosts()]
      ↓ Firestore
   [startAfterDocument(cursorDoc)]
      ↓
[다음 20개 게시물]
      ↓ Result 래핑
[Success(FeedResult)]
      ↓ fold
[_posts.addAll(newPosts)]
[_lastDocumentId = newPosts.last.id]
      ↓ notifyListeners
   [UI 업데이트 (스크롤 유지)]
```

---

## 🛡️ 에러 처리

### Result 패턴

Domain Layer는 **Result<T>** 패턴으로 모든 작업의 성공/실패를 명시적으로 표현합니다.

```dart
// /lib/core/types/result.dart
abstract class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  );
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  ) => onSuccess(value);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);

  @override
  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  ) => onFailure(failure);
}
```

### Failure 계층 구조

```dart
// /lib/core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  String getUserMessage(); // 사용자 친화적 메시지
}

// 서버 에러
class ServerFailure extends Failure {
  final String? code;
  const ServerFailure({required String message, this.code})
      : super(message: message);

  @override
  String getUserMessage() => '서버 오류가 발생했습니다';
}

// 찾을 수 없음
class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '요청한 항목을 찾을 수 없습니다';
}

// 입력 검증 실패
class ValidationFailure extends Failure {
  const ValidationFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '입력값이 올바르지 않습니다';
}

// 일반 앱 에러
class AppFailure extends Failure {
  const AppFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '일시적인 오류가 발생했습니다';
}

// 네트워크 에러
class NetworkFailure extends Failure {
  const NetworkFailure({required String message})
      : super(message: message);

  @override
  String getUserMessage() => '네트워크 연결을 확인해주세요';
}
```

### UseCase 에러 처리 패턴

```dart
Future<Result<PostDisplay>> execute({required String postId}) async {
  try {
    // 1. 입력 검증
    if (postId.isEmpty) {
      return ResultFailure(
        ValidationFailure(message: 'Post ID cannot be empty'),
      );
    }

    // 2. Repository 호출
    final post = await _postRepository.getPost(postId);

    // 3. null 체크
    if (post == null) {
      return ResultFailure(
        NotFoundFailure(message: 'Post not found with ID: $postId'),
      );
    }

    // 4. 성공
    return Success(post);
  } catch (error) {
    // 5. 에러 분류
    if (error.toString().contains('permission-denied')) {
      return ResultFailure(
        ServerFailure(
          message: 'Permission denied to load post',
          code: 'permission-denied',
        ),
      );
    }

    if (error.toString().contains('network')) {
      return ResultFailure(
        NetworkFailure(message: 'Network error: $error'),
      );
    }

    // 6. 기타 에러
    return ResultFailure(
      AppFailure(message: 'Failed to load post: $error'),
    );
  }
}
```

### Provider에서의 에러 처리

```dart
class PostDetailProvider extends ChangeNotifier
    with BaseListProvider<PostDetailLoadingState, PostDisplay> {

  Future<void> loadPost(String postId) async {
    setLoadingState(PostDetailLoadingState.loading);

    final result = await _getPostDetailUseCase.execute(postId: postId);

    result.fold(
      // 실패 처리
      (failure) {
        if (failure is NotFoundFailure) {
          handleError(failure, PostDetailLoadingState.notFound);
        } else if (failure is ServerFailure) {
          handleError(failure, PostDetailLoadingState.error);
        } else if (failure is NetworkFailure) {
          handleError(failure, PostDetailLoadingState.error);
        } else {
          handleError(failure, PostDetailLoadingState.error);
        }
      },
      // 성공 처리
      (post) {
        _post = post;
        setLoadingState(PostDetailLoadingState.loaded);
      },
    );
  }
}
```

---

## 🧪 테스트 전략

### 1. 모델 테스트

**post_display_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostDisplay', () {
    test('votePercentageA calculates correctly', () {
      final post = PostDisplay(
        id: 'test',
        questionTitle: 'Test',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: DateTime.now(),
        votesA: 30,
        votesB: 70,
      );

      expect(post.votePercentageA, 30.0);
      expect(post.votePercentageB, 70.0);
      expect(post.totalVotes, 100);
    });

    test('votePercentageA returns 50% when no votes', () {
      final post = PostDisplay(
        id: 'test',
        questionTitle: 'Test',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: DateTime.now(),
        votesA: 0,
        votesB: 0,
      );

      expect(post.votePercentageA, 50.0);
      expect(post.votePercentageB, 50.0);
    });

    test('totalEngagement calculates correctly', () {
      final post = PostDisplay(
        id: 'test',
        questionTitle: 'Test',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: DateTime.now(),
        commentCount: 10,
        likeCount: 50,
        shareCount: 5,
      );

      expect(post.totalEngagement, 65);
    });

    test('copyWith creates new instance with updated fields', () {
      final post = PostDisplay(
        id: 'test',
        questionTitle: 'Original',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: DateTime.now(),
        votesA: 10,
      );

      final updated = post.copyWith(
        questionTitle: 'Updated',
        votesA: 20,
      );

      expect(updated.questionTitle, 'Updated');
      expect(updated.votesA, 20);
      expect(updated.id, 'test'); // 변경되지 않은 필드
    });

    test('Equatable works correctly', () {
      final now = DateTime.now();

      final post1 = PostDisplay(
        id: 'test',
        questionTitle: 'Test',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: now,
      );

      final post2 = PostDisplay(
        id: 'test',
        questionTitle: 'Test',
        userId: 'user1',
        displayName: 'User',
        photoUrl: '',
        createdAt: now,
      );

      expect(post1, equals(post2));
    });
  });
}
```

### 2. UseCase 테스트

**get_feed_usecase_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([IPostDisplayRepositoryV2])
void main() {
  late GetFeedUseCase useCase;
  late MockIPostDisplayRepositoryV2 mockRepository;

  setUp(() {
    mockRepository = MockIPostDisplayRepositoryV2();
    useCase = GetFeedUseCase(postRepository: mockRepository);
  });

  group('GetFeedUseCase', () {
    final testPosts = [
      PostDisplay(
        id: 'post1',
        questionTitle: 'Post 1',
        userId: 'user1',
        displayName: 'User 1',
        photoUrl: '',
        createdAt: DateTime.now(),
      ),
      PostDisplay(
        id: 'post2',
        questionTitle: 'Post 2',
        userId: 'user2',
        displayName: 'User 2',
        photoUrl: '',
        createdAt: DateTime.now(),
      ),
    ];

    test('execute returns Success with posts', () async {
      // Arrange
      when(mockRepository.queryPosts(
        queryBuilder: anyNamed('queryBuilder'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Stream.value(testPosts));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<Success<FeedResult>>());
      result.fold(
        (failure) => fail('Should not fail'),
        (feedResult) {
          expect(feedResult.posts.length, 2);
          expect(feedResult.hasMore, false);
        },
      );
    });

    test('execute returns Failure on error', () async {
      // Arrange
      when(mockRepository.queryPosts(
        queryBuilder: anyNamed('queryBuilder'),
        limit: anyNamed('limit'),
      )).thenThrow(Exception('Test error'));

      // Act
      final result = await useCase.execute();

      // Assert
      expect(result, isA<ResultFailure<FeedResult>>());
      result.fold(
        (failure) {
          expect(failure, isA<AppFailure>());
          expect(failure.message, contains('Failed to load feed'));
        },
        (feedResult) => fail('Should not succeed'),
      );
    });

    test('execute with pagination uses getPostsAfter', () async {
      // Arrange
      when(mockRepository.getPostsAfter(
        lastPostId: anyNamed('lastPostId'),
        limit: anyNamed('limit'),
        queryBuilder: anyNamed('queryBuilder'),
      )).thenAnswer((_) => Stream.value(testPosts));

      // Act
      await useCase.execute(lastDocumentId: 'post0');

      // Assert
      verify(mockRepository.getPostsAfter(
        lastPostId: 'post0',
        limit: 20,
        queryBuilder: anyNamed('queryBuilder'),
      )).called(1);
    });

    test('getFeedStream returns stream of posts', () async {
      // Arrange
      when(mockRepository.queryPosts(
        queryBuilder: anyNamed('queryBuilder'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => Stream.value(testPosts));

      // Act
      final stream = useCase.getFeedStream();

      // Assert
      await expectLater(
        stream,
        emits(isA<Success<List<PostDisplay>>>()),
      );
    });
  });
}
```

**get_post_detail_usecase_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  late GetPostDetailUseCase useCase;
  late MockIPostDisplayRepositoryV2 mockRepository;

  setUp(() {
    mockRepository = MockIPostDisplayRepositoryV2();
    useCase = GetPostDetailUseCase(postRepository: mockRepository);
  });

  group('GetPostDetailUseCase', () {
    final testPost = PostDisplay(
      id: 'post1',
      questionTitle: 'Test Post',
      userId: 'user1',
      displayName: 'User',
      photoUrl: '',
      createdAt: DateTime.now(),
    );

    test('execute returns Success when post exists', () async {
      // Arrange
      when(mockRepository.getPost('post1'))
          .thenAnswer((_) async => testPost);
      when(mockRepository.incrementViewCount('post1'))
          .thenAnswer((_) async => {});

      // Act
      final result = await useCase.execute(postId: 'post1');

      // Assert
      expect(result, isA<Success<PostDisplay>>());
      result.fold(
        (failure) => fail('Should not fail'),
        (post) {
          expect(post.id, 'post1');
          expect(post.questionTitle, 'Test Post');
        },
      );

      // Verify view count was incremented
      verify(mockRepository.incrementViewCount('post1')).called(1);
    });

    test('execute returns NotFoundFailure when post does not exist', () async {
      // Arrange
      when(mockRepository.getPost('non-existent'))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.execute(postId: 'non-existent');

      // Assert
      expect(result, isA<ResultFailure<PostDisplay>>());
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, contains('Post not found'));
        },
        (post) => fail('Should not succeed'),
      );
    });

    test('execute returns ValidationFailure for empty postId', () async {
      // Act
      final result = await useCase.execute(postId: '');

      // Assert
      expect(result, isA<ResultFailure<PostDisplay>>());
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('cannot be empty'));
        },
        (post) => fail('Should not succeed'),
      );

      // Verify repository was not called
      verifyNever(mockRepository.getPost(any));
    });

    test('execute does not increment view count when flag is false', () async {
      // Arrange
      when(mockRepository.getPost('post1'))
          .thenAnswer((_) async => testPost);

      // Act
      await useCase.execute(
        postId: 'post1',
        incrementViewCount: false,
      );

      // Assert
      verifyNever(mockRepository.incrementViewCount(any));
    });

    test('getPostStream returns stream of post', () async {
      // Arrange
      when(mockRepository.streamPost('post1'))
          .thenAnswer((_) => Stream.value(testPost));

      // Act
      final stream = useCase.getPostStream(postId: 'post1');

      // Assert
      await expectLater(
        stream,
        emits(isA<Success<PostDisplay>>()),
      );
    });

    test('getPostStream returns NotFoundFailure for null post', () async {
      // Arrange
      when(mockRepository.streamPost('non-existent'))
          .thenAnswer((_) => Stream.value(null));

      // Act
      final stream = useCase.getPostStream(postId: 'non-existent');

      // Assert
      await expectLater(
        stream,
        emits(isA<ResultFailure<PostDisplay>>()),
      );
    });
  });
}
```

### 테스트 커버리지 목표

| 레이어 | 커버리지 목표 | 우선순위 |
|--------|--------------|----------|
| Models | 95%+ | High |
| UseCases | 90%+ | High |
| Repository Interface | 100% (Mocking) | High |

**커버리지 실행**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔐 보안 고려사항

### 1. 입력 검증

**모든 UseCase는 입력값 검증 필수**:

```dart
Future<Result<PostDisplay>> execute({required String postId}) async {
  // ✅ 빈 문자열 체크
  if (postId.isEmpty) {
    return ResultFailure(
      ValidationFailure(message: 'Post ID cannot be empty'),
    );
  }

  // ✅ 추가 검증 (선택)
  if (postId.length > 100) {
    return ResultFailure(
      ValidationFailure(message: 'Post ID too long'),
    );
  }

  // Repository 호출
  // ...
}
```

### 2. 민감 데이터 제외

**PostDisplay 모델은 공개 데이터만 포함**:

```dart
class PostDisplay {
  // ✅ 공개 정보만
  final String displayName;  // 사용자명
  final String photoUrl;     // 프로필 사진

  // ❌ 민감 정보 제외
  // final String? email;
  // final String? phoneNumber;
  // final String? privateNotes;
}
```

### 3. 익명 게시물 처리

```dart
// ✅ 익명 게시물 필터링
Stream<List<PostDisplay>> getUserPosts({required String userId}) {
  return _repository.queryPosts(
    queryBuilder: (params) => {
      'where': {
        'userid': userId,
        'isAnonymous': false,  // 익명 게시물 제외
      },
    },
  );
}
```

### 4. 권한 검증 (Presentation Layer에서)

Domain Layer는 권한 검증을 **하지 않습니다**. 이는 Presentation Layer의 책임입니다:

```dart
// ❌ Domain Layer에서 권한 검증 (잘못된 패턴)
Future<Result<PostDisplay>> execute({required String postId}) async {
  if (!_authService.isLoggedIn()) {  // ❌ 외부 의존성
    return ResultFailure(UnauthorizedFailure());
  }
  // ...
}

// ✅ Presentation Layer에서 권한 검증 (올바른 패턴)
class PostDetailProvider {
  Future<void> loadPost(String postId) async {
    // 1. 권한 확인
    if (!_authService.isLoggedIn()) {
      handleError(UnauthorizedFailure(), PostDetailLoadingState.error);
      return;
    }

    // 2. UseCase 호출
    final result = await _getPostDetailUseCase.execute(postId: postId);
    // ...
  }
}
```

---

## 🚀 확장 가능성

### 1. 새로운 UseCase 추가

**예: GetRecommendedPostsUseCase**

```dart
// lib/features/post/domain/usecases/get_recommended_posts_usecase.dart
class GetRecommendedPostsUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetRecommendedPostsUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  Future<Result<List<PostDisplay>>> execute({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'User ID cannot be empty'),
        );
      }

      // Repository 호출
      final posts = await _postRepository.getRecommendedPosts(
        userId: userId,
        limit: limit,
      );

      return Success(posts);
    } catch (error) {
      return ResultFailure(
        AppFailure(message: 'Failed to load recommended posts: $error'),
      );
    }
  }
}
```

**DI 등록** (`lib/app/di.dart`):
```dart
void setupDomainLayer() {
  // Repository는 이미 등록됨
  final repository = getIt<IPostDisplayRepositoryV2>();

  // 새로운 UseCase 등록
  getIt.registerFactory(
    () => GetRecommendedPostsUseCase(postRepository: repository),
  );
}
```

### 2. Repository 메서드 확장

**인터페이스에 메서드 추가**:

```dart
// lib/features/post/domain/repositories/i_post_display_repository_v2.dart
abstract class IPostDisplayRepositoryV2 {
  // 기존 메서드들...

  // 새로운 메서드 추가
  Future<List<PostDisplay>> getPostsByHashtag({
    required String hashtag,
    int limit = 20,
  });

  Stream<List<PostDisplay>> getPostsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 20,
  });
}
```

**Data Layer에서 구현**:
```dart
// lib/features/post/data/repositories/post_display_repository_v2_impl.dart
@override
Future<List<PostDisplay>> getPostsByHashtag({
  required String hashtag,
  int limit = 20,
}) async {
  final dataList = await _dataSource.queryPosts(
    queryBuilder: (params) => {
      'where': {
        'hashtags': {'operator': 'arrayContains', 'value': hashtag},
      },
      'orderBy': 'createdAt',
      'descending': true,
    },
    limit: limit,
  ).first;

  return dataList.map((data) {
    final dto = PostDisplayDto.fromFirestore(data, data['id']);
    return PostDisplayMapper.toDomain(dto);
  }).toList();
}
```

### 3. 새로운 모델 추가

**예: PostSummary (경량 모델)**

```dart
// lib/features/post/domain/models/post_summary.dart
class PostSummary extends Equatable {
  const PostSummary({
    required this.id,
    required this.questionTitle,
    required this.totalVotes,
    required this.createdAt,
  });

  final String id;
  final String questionTitle;
  final int totalVotes;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, questionTitle, totalVotes, createdAt];
}
```

**Repository 메서드**:
```dart
abstract class IPostDisplayRepositoryV2 {
  // 경량 조회 (성능 최적화)
  Future<List<PostSummary>> getPostSummaries({int limit = 100});
}
```

### 4. 복합 필터 확장

**FeedFilter 확장**:

```dart
class FeedFilter {
  final String? status;
  final String? userId;
  final bool? hasImages;
  final bool? isAnonymous;
  final DateTime? startDate;
  final DateTime? endDate;

  // 새로운 필터 추가
  final List<String>? hashtags;
  final String? category;
  final int? minVotes;
  final int? maxVotes;
  final bool? isCompleted;

  const FeedFilter({
    this.status,
    this.userId,
    this.hasImages,
    this.isAnonymous,
    this.startDate,
    this.endDate,
    this.hashtags,
    this.category,
    this.minVotes,
    this.maxVotes,
    this.isCompleted,
  });
}
```

---

## 📊 성능 최적화

### 1. Computed Properties 활용

**비용이 큰 계산은 캐싱**:

```dart
class PostDisplay {
  // ❌ 매번 계산
  int getTotalEngagement() {
    return commentCount + likeCount + shareCount;
  }

  // ✅ Getter로 즉시 계산 (간단한 연산)
  int get totalEngagement => commentCount + likeCount + shareCount;

  // ✅ 복잡한 계산은 캐싱
  Map<String, dynamic>? _cachedMap;
  Map<String, dynamic> toMap() {
    if (_cachedMap != null) return _cachedMap!;

    _cachedMap = {
      'id': id,
      'questionTitle': questionTitle,
      // ...
    };

    return _cachedMap!;
  }
}
```

### 2. Stream 메모리 최적화

**UseCase에서 Stream 구독 해제**:

```dart
class GetPostDetailUseCase {
  // ❌ Stream 누수 가능
  Stream<Result<PostDisplay>> getPostStream({required String postId}) {
    return _postRepository.streamPost(postId).map(...);
  }

  // ✅ Provider에서 구독 관리
  // Provider에서 StreamSubscription을 dispose()에서 cancel()
}
```

**Provider 패턴**:
```dart
class PostDetailProvider {
  StreamSubscription<Result<PostDisplay>>? _subscription;

  void startPostStream(String postId) {
    _subscription?.cancel();  // 기존 구독 해제

    _subscription = _getPostDetailUseCase.getPostStream(postId).listen(...);
  }

  @override
  void dispose() {
    _subscription?.cancel();  // ✅ 메모리 누수 방지
    super.dispose();
  }
}
```

### 3. Equatable 최적화

**불필요한 notifyListeners 방지**:

```dart
class FeedProvider extends ChangeNotifier {
  List<PostDisplay> _posts = [];

  void updatePosts(List<PostDisplay> newPosts) {
    // ✅ Equatable로 자동 비교
    if (_posts == newPosts) return;  // 동일하면 스킵

    _posts = newPosts;
    notifyListeners();  // 변경된 경우만 알림
  }
}
```

---

## 🔗 관련 문서

### Post Feature 문서
- [Feature Overview](/lib/features/post/docs/FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](/lib/features/post/docs/API_REFERENCE.md) - 상세 API 문서
- [Usage Guide](/lib/features/post/docs/USAGE_GUIDE.md) - 사용 가이드
- [Data Layer](/lib/features/post/data/README.md) - Data Layer 문서

### 다른 Feature 참조
- [Creation Domain Layer](/lib/features/creation/domain/README.md) - 쓰기 중심 도메인 참조
- [Auth Feature](/lib/features/auth/domain/) - 인증 Feature 도메인

### Core 문서
- [Clean Architecture Guide](/docs/architecture/CLEAN_ARCHITECTURE.md) - 아키텍처 원칙
- [Result Pattern](/lib/core/types/README.md) - Result 패턴 가이드
- [Error Handling](/lib/core/errors/README.md) - 에러 처리 가이드
- [Testing Strategy](/docs/testing/TESTING_STRATEGY.md) - 테스트 전략

---

**작성자**: Claude Code Assistant
**마지막 리뷰**: 2025-01-20
**버전**: 1.0.0
