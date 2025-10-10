# Post Feature - API Reference

> **Version**: 1.0.0
> **Last Updated**: 2025-01-20
> **Clean Architecture**: v4.0

## 목차
- [핵심 인터페이스](#-핵심-인터페이스)
- [UseCases](#-usecases)
- [Provider API](#-provider-api)
- [Model Classes](#-model-classes)
- [Dependency Injection](#-dependency-injection)
- [에러 처리](#-에러-처리)
- [스트림 처리](#-스트림-처리)

---

## 🎯 핵심 인터페이스

### IPostDisplayRepositoryV2

**위치**: `lib/features/post/domain/repositories/i_post_display_repository_v2.dart`

**역할**: Post 조회 및 표시를 위한 Repository 인터페이스 (Firebase 의존성 완전 제거)

#### 메서드 목록

##### 1. queryPosts
범용 게시물 쿼리 메서드

```dart
Stream<List<PostDisplay>> queryPosts({
  Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
});
```

**파라미터**:
- `queryBuilder`: 쿼리 조건 빌더 함수 (선택)
- `limit`: 최대 결과 수 (-1 = 무제한)
- `singleRecord`: 단일 레코드만 조회 여부

**반환**: `Stream<List<PostDisplay>>` - 실시간 게시물 스트림

**사용 예**:
```dart
final stream = repository.queryPosts(
  queryBuilder: (query) => query
    ..where('status', isEqualTo: 'published')
    ..orderBy('createdAt', descending: true),
  limit: 20,
);
```

---

##### 2. getPost
단일 게시물 조회 (Future)

```dart
Future<PostDisplay?> getPost(String postId);
```

**파라미터**:
- `postId`: 게시물 ID

**반환**: `Future<PostDisplay?>` - 게시물 객체 (없으면 null)

**사용 예**:
```dart
final post = await repository.getPost('post123');
if (post != null) {
  print('Title: ${post.questionTitle}');
}
```

---

##### 3. streamPost
단일 게시물 스트림 조회

```dart
Stream<PostDisplay?> streamPost(String postId);
```

**파라미터**:
- `postId`: 게시물 ID

**반환**: `Stream<PostDisplay?>` - 실시간 게시물 스트림

**사용 예**:
```dart
repository.streamPost('post123').listen((post) {
  if (post != null) {
    updateUI(post);
  }
});
```

---

##### 4. getTrendingPosts
트렌딩 게시물 조회

```dart
Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});
```

**파라미터**:
- `limit`: 최대 결과 수 (기본값 20)

**반환**: `Stream<List<PostDisplay>>` - 트렌딩 게시물 스트림

**정렬 기준**: 댓글 수 + (좋아요×2) 점수

**사용 예**:
```dart
final trendingStream = repository.getTrendingPosts(limit: 10);
```

---

##### 5. getUserPosts
특정 사용자의 게시물 조회

```dart
Stream<List<PostDisplay>> getUserPosts({
  required String userId,
  int limit = -1,
});
```

**파라미터**:
- `userId`: 사용자 ID (필수)
- `limit`: 최대 결과 수 (-1 = 무제한)

**반환**: `Stream<List<PostDisplay>>` - 사용자 게시물 스트림

**사용 예**:
```dart
final userPosts = repository.getUserPosts(
  userId: 'user123',
  limit: 50,
);
```

---

##### 6. getPostsByCategory
카테고리별 게시물 조회

```dart
Stream<List<PostDisplay>> getPostsByCategory({
  required String category,
  int limit = -1,
});
```

**파라미터**:
- `category`: 카테고리명 (필수)
- `limit`: 최대 결과 수

**반환**: `Stream<List<PostDisplay>>` - 카테고리 게시물 스트림

---

##### 7. getActiveVotingPosts
진행 중인 투표 게시물 조회

```dart
Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});
```

**파라미터**:
- `limit`: 최대 결과 수

**반환**: `Stream<List<PostDisplay>>` - 투표 진행중 게시물

**필터 조건**: `voteStatus == 'active'` && `voteCompleted == false`

---

##### 8. searchPosts
게시물 검색

```dart
Future<List<PostDisplay>> searchPosts({
  required String query,
  int limit = 20,
});
```

**파라미터**:
- `query`: 검색 쿼리 (필수)
- `limit`: 최대 결과 수

**반환**: `Future<List<PostDisplay>>` - 검색 결과 목록

**사용 예**:
```dart
final results = await repository.searchPosts(
  query: 'technology',
  limit: 30,
);
```

---

##### 9. incrementViewCount
게시물 조회수 증가

```dart
Future<void> incrementViewCount(String postId);
```

**파라미터**:
- `postId`: 게시물 ID

**반환**: `Future<void>`

**사용 예**:
```dart
await repository.incrementViewCount('post123');
```

---

##### 10. getRecommendedPosts
추천 게시물 조회 (AI 기반)

```dart
Future<List<PostDisplay>> getRecommendedPosts({
  required String userId,
  int limit = 20,
});
```

**파라미터**:
- `userId`: 사용자 ID (필수)
- `limit`: 최대 결과 수

**반환**: `Future<List<PostDisplay>>` - 추천 게시물 목록

---

##### 11. getPostsByIds
여러 게시물 일괄 조회 (Batch)

```dart
Future<List<PostDisplay>> getPostsByIds(List<String> postIds);
```

**파라미터**:
- `postIds`: 게시물 ID 목록

**반환**: `Future<List<PostDisplay>>` - 게시물 목록

**사용 예**:
```dart
final posts = await repository.getPostsByIds([
  'post1', 'post2', 'post3',
]);
```

---

##### 12. getCompletedVotingPosts
완료된 투표 게시물 조회

```dart
Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});
```

**파라미터**:
- `limit`: 최대 결과 수

**반환**: `Stream<List<PostDisplay>>` - 투표 완료 게시물

**필터 조건**: `voteCompleted == true`

---

##### 13. getPopularPosts
인기 게시물 조회

```dart
Stream<List<PostDisplay>> getPopularPosts({
  int limit = 20,
  Duration? timeWindow,
});
```

**파라미터**:
- `limit`: 최대 결과 수
- `timeWindow`: 시간 창 (선택) - 예: Duration(days: 7)

**반환**: `Stream<List<PostDisplay>>` - 인기 게시물 스트림

**정렬 기준**: 좋아요 + 댓글 + 공유 종합 점수

**사용 예**:
```dart
// 최근 7일 인기 게시물
final popular = repository.getPopularPosts(
  limit: 10,
  timeWindow: Duration(days: 7),
);
```

---

##### 14. getPostsAfter
페이지네이션 (커서 기반)

```dart
Stream<List<PostDisplay>> getPostsAfter({
  required String lastPostId,
  int limit = 20,
  Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
});
```

**파라미터**:
- `lastPostId`: 마지막 게시물 ID (커서)
- `limit`: 다음 페이지 크기
- `queryBuilder`: 추가 쿼리 조건 (선택)

**반환**: `Stream<List<PostDisplay>>` - 다음 페이지 게시물

**사용 예**:
```dart
final nextPage = repository.getPostsAfter(
  lastPostId: 'post123',
  limit: 20,
);
```

---

##### 15. getPostsWithFilters
복합 필터 조회

```dart
Stream<List<PostDisplay>> getPostsWithFilters({
  String? userId,
  String? status,
  bool? isAnonymous,
  DateTime? createdAfter,
  DateTime? createdBefore,
  int limit = 20,
});
```

**파라미터**:
- `userId`: 사용자 ID 필터 (선택)
- `status`: 상태 필터 (선택)
- `isAnonymous`: 익명 여부 필터 (선택)
- `createdAfter`: 시작 날짜 (선택)
- `createdBefore`: 종료 날짜 (선택)
- `limit`: 최대 결과 수

**반환**: `Stream<List<PostDisplay>>` - 필터링된 게시물

**사용 예**:
```dart
final filtered = repository.getPostsWithFilters(
  status: 'published',
  isAnonymous: false,
  createdAfter: DateTime.now().subtract(Duration(days: 30)),
  limit: 50,
);
```

---

### IPostQueryService

**위치**: `lib/features/post/domain/repositories/i_post_query_service.dart`

**역할**: 복잡한 쿼리 전략을 캡슐화하는 서비스 인터페이스

_(현재는 IPostDisplayRepositoryV2에 기능이 통합되어 있음)_

---

### IPostDisplayDataSource

**위치**: `lib/features/post/data/datasources/interfaces/i_post_display_datasource.dart`

**역할**: 데이터 소스 추상화 (Firebase 구현 세부사항 숨김)

#### 메서드 목록

##### queryPosts (DataSource 레벨)
```dart
Stream<List<Map<String, dynamic>>> queryPosts({
  required Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder,
  int? limit,
});
```

**반환**: Raw Map 데이터 스트림 (DTO 변환 전)

---

##### getPost (DataSource 레벨)
```dart
Future<Map<String, dynamic>?> getPost(String postId);
```

**반환**: Raw Map 데이터 (단일 게시물)

---

##### getPostsByIds (DataSource 레벨)
```dart
Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds);
```

**반환**: Raw Map 데이터 목록 (배치 조회)

---

##### updatePostMetrics
```dart
Future<void> updatePostMetrics(String postId, Map<String, dynamic> metrics);
```

**파라미터**:
- `postId`: 게시물 ID
- `metrics`: 업데이트할 메트릭 맵

**사용 예**:
```dart
await dataSource.updatePostMetrics('post123', {
  'viewCount': FieldValue.increment(1),
});
```

---

##### deletePost
```dart
Future<void> deletePost(String postId);
```

**파라미터**:
- `postId`: 삭제할 게시물 ID

---

## 🔧 UseCases

### GetFeedUseCase

**위치**: `lib/features/post/domain/usecases/get_feed_usecase.dart`

**역할**: 피드 조회 비즈니스 로직

#### execute
```dart
Future<Result<FeedResult>> execute({
  int limit = 20,
  String? lastDocumentId,
  FeedSortBy sortBy = FeedSortBy.latest,
  FeedFilter? filter,
});
```

**파라미터**:
- `limit`: 페이지 크기
- `lastDocumentId`: 페이지네이션 커서
- `sortBy`: 정렬 옵션 (latest, popular, mostVoted, trending)
- `filter`: 필터 조건

**반환**: `Result<FeedResult>` - FeedResult 또는 Failure

**FeedResult 구조**:
```dart
class FeedResult {
  final List<PostDisplay> posts;
  final bool hasMore;
  final String? lastDocumentId;
}
```

**사용 예**:
```dart
final result = await getFeedUseCase.execute(
  limit: 20,
  sortBy: FeedSortBy.trending,
  filter: FeedFilter(
    status: 'published',
    hasImages: true,
  ),
);

result.fold(
  (failure) => showError(failure.message),
  (feedResult) {
    displayPosts(feedResult.posts);
    if (feedResult.hasMore) {
      enableLoadMore(feedResult.lastDocumentId);
    }
  },
);
```

---

#### getFeedStream
```dart
Stream<Result<List<PostDisplay>>> getFeedStream({
  int limit = 20,
  FeedSortBy sortBy = FeedSortBy.latest,
  FeedFilter? filter,
});
```

**파라미터**: execute와 동일 (lastDocumentId 제외)

**반환**: `Stream<Result<List<PostDisplay>>>` - 실시간 피드 스트림

**사용 예**:
```dart
getFeedUseCase.getFeedStream(
  limit: 20,
  sortBy: FeedSortBy.latest,
).listen((result) {
  result.fold(
    (failure) => handleStreamError(failure),
    (posts) => updateFeed(posts),
  );
});
```

---

### GetPostDetailUseCase

**위치**: `lib/features/post/domain/usecases/get_post_detail_usecase.dart`

**역할**: 게시물 상세 조회

#### execute
```dart
Future<Result<PostDisplay>> execute({required String postId});
```

**파라미터**:
- `postId`: 조회할 게시물 ID (필수)

**반환**: `Result<PostDisplay>` - 게시물 또는 Failure

**에러 타입**:
- `NotFoundFailure`: 게시물이 존재하지 않음
- `ServerFailure`: 서버 에러
- `AppFailure`: 일반 에러

**사용 예**:
```dart
final result = await getPostDetailUseCase.execute(
  postId: 'post123',
);

result.fold(
  (failure) {
    if (failure is NotFoundFailure) {
      showNotFoundError();
    } else {
      showGenericError(failure.message);
    }
  },
  (post) => displayPostDetail(post),
);
```

---

#### getPostStream
```dart
Stream<Result<PostDisplay>> getPostStream({required String postId});
```

**파라미터**:
- `postId`: 조회할 게시물 ID

**반환**: `Stream<Result<PostDisplay>>` - 실시간 게시물 스트림

**사용 예**:
```dart
getPostDetailUseCase.getPostStream(
  postId: 'post123',
).listen((result) {
  result.fold(
    (failure) => handleError(failure),
    (post) => updatePostDisplay(post),
  );
});
```

---

### GetTrendingPostsUseCase

**위치**: `lib/features/post/domain/usecases/get_trending_posts_usecase.dart`

**역할**: 트렌딩 게시물 조회

#### execute
```dart
Future<Result<List<PostDisplay>>> execute({int limit = 20});
```

**파라미터**:
- `limit`: 최대 결과 수 (기본값 20)

**반환**: `Result<List<PostDisplay>>` - 트렌딩 게시물 목록

---

#### getTrendingStream
```dart
Stream<Result<List<PostDisplay>>> getTrendingStream({int limit = 20});
```

**반환**: `Stream<Result<List<PostDisplay>>>` - 실시간 트렌딩 스트림

---

### GetPopularPostsUseCase

**위치**: `lib/features/post/domain/usecases/get_popular_posts_usecase.dart`

**역할**: 인기 게시물 조회

#### execute
```dart
Future<Result<List<PostDisplay>>> execute({
  int limit = 20,
  Duration? timeWindow,
});
```

**파라미터**:
- `limit`: 최대 결과 수
- `timeWindow`: 시간 창 (선택) - 예: Duration(days: 7)

**반환**: `Result<List<PostDisplay>>` - 인기 게시물 목록

---

#### getPopularStream
```dart
Stream<Result<List<PostDisplay>>> getPopularStream({
  int limit = 20,
  Duration? timeWindow,
});
```

**반환**: `Stream<Result<List<PostDisplay>>>` - 실시간 인기 게시물 스트림

---

### GetUserPostsUseCase

**위치**: `lib/features/post/domain/usecases/get_user_posts_usecase.dart`

**역할**: 사용자 게시물 조회

#### execute
```dart
Future<Result<List<PostDisplay>>> execute({
  required String userId,
  int limit = -1,
});
```

**파라미터**:
- `userId`: 사용자 ID (필수)
- `limit`: 최대 결과 수 (-1 = 무제한)

**반환**: `Result<List<PostDisplay>>` - 사용자 게시물 목록

---

#### getUserPostsStream
```dart
Stream<Result<List<PostDisplay>>> getUserPostsStream({
  required String userId,
  int limit = -1,
});
```

**반환**: `Stream<Result<List<PostDisplay>>>` - 실시간 사용자 게시물

---

## 📦 Provider API

### BaseListProvider (Mixin)

**위치**: `lib/features/post/presentation/providers/base_list_provider.dart`

**역할**: 5개 Provider의 공통 기능 제공 (150+ 줄 중복 제거)

#### 제네릭 타입
```dart
mixin BaseListProvider<TState extends Enum, TModel> on ChangeNotifier {
  // ...
}
```

**타입 파라미터**:
- `TState`: 로딩 상태 Enum (각 Provider별 고유)
- `TModel`: 모델 타입 (PostDisplay 등)

---

#### errorMessage (Getter)
```dart
String? get errorMessage;
```

**반환**: 현재 에러 메시지 (없으면 null)

**사용 예**:
```dart
if (provider.errorMessage != null) {
  showSnackBar(provider.errorMessage!);
}
```

---

#### loadingState (Abstract Getter)
```dart
TState get loadingState;
```

**역할**: 현재 로딩 상태 반환 (각 Provider에서 구현)

---

#### setLoadingState (Abstract Method)
```dart
void setLoadingState(TState state);
```

**역할**: 로딩 상태 변경 (각 Provider에서 구현)

**구현 예**:
```dart
@override
void setLoadingState(FeedLoadingState state) {
  _loadingState = state;
  notifyListeners();
}
```

---

#### handleError
```dart
void handleError(Failure failure, TState errorState);
```

**파라미터**:
- `failure`: Failure 객체
- `errorState`: 설정할 에러 상태

**역할**: Failure를 사용자 친화적 메시지로 변환 후 에러 상태 설정

**사용 예**:
```dart
result.fold(
  (failure) => handleError(failure, FeedLoadingState.error),
  (data) => processSuccess(data),
);
```

---

#### handleStreamError
```dart
void handleStreamError(Failure failure, {TState? errorState});
```

**파라미터**:
- `failure`: Failure 객체
- `errorState`: 설정할 에러 상태 (선택)

**역할**: 스트림 에러 처리 (에러 상태 변경 없이 메시지만 설정 가능)

---

#### getFailureMessage
```dart
String getFailureMessage(Failure failure);
```

**파라미터**:
- `failure`: Failure 객체

**반환**: 사용자 친화적 에러 메시지

**매핑 로직**:
```dart
// ServerFailure → "서버 오류가 발생했습니다"
// NotFoundFailure → "요청한 데이터를 찾을 수 없습니다"
// NetworkFailure → "네트워크 연결을 확인해주세요"
// AppFailure → failure.message (직접 메시지)
```

---

#### clearError
```dart
void clearError();
```

**역할**: 에러 메시지 초기화

**사용 예**:
```dart
void refresh() {
  clearError();
  loadData();
}
```

---

### FeedProvider

**위치**: `lib/features/post/presentation/providers/feed_provider.dart`

**상속**: `ChangeNotifier` with `BaseListProvider<FeedLoadingState, PostDisplay>`

#### 생성자
```dart
FeedProvider({
  required GetFeedUseCase getFeedUseCase,
});
```

---

#### posts (Getter)
```dart
List<PostDisplay> get posts;
```

**반환**: 현재 피드 게시물 목록

---

#### hasMore (Getter)
```dart
bool get hasMore;
```

**반환**: 다음 페이지 존재 여부

---

#### sortBy (Getter)
```dart
FeedSortBy get sortBy;
```

**반환**: 현재 정렬 옵션

---

#### filter (Getter)
```dart
FeedFilterModel get filter;
```

**반환**: 현재 필터 설정

---

#### currentPage (Getter)
```dart
int get currentPage;
```

**반환**: 현재 페이지 번호 (0부터 시작)

---

#### isLoading (Getter)
```dart
bool get isLoading;
```

**반환**: 초기 로딩 중 여부

---

#### isLoadingMore (Getter)
```dart
bool get isLoadingMore;
```

**반환**: 추가 페이지 로딩 중 여부

---

#### isEmpty (Getter)
```dart
bool get isEmpty;
```

**반환**: 게시물 목록이 비어있고 로딩 완료 여부

---

#### initializeFeed
```dart
Future<void> initializeFeed();
```

**역할**: 피드 초기화 (첫 페이지 로드)

**사용 예**:
```dart
@override
void initState() {
  super.initState();
  Provider.of<FeedProvider>(context, listen: false).initializeFeed();
}
```

---

#### loadMore
```dart
Future<void> loadMore();
```

**역할**: 다음 페이지 로드 (무한 스크롤)

**조건**:
- `hasMore == true`
- `isLoadingMore == false`
- `isLoading == false`

**사용 예**:
```dart
ScrollController controller;

controller.addListener(() {
  if (controller.position.pixels >= controller.position.maxScrollExtent * 0.8) {
    provider.loadMore();
  }
});
```

---

#### changeSortOrder
```dart
Future<void> changeSortOrder(FeedSortBy newSortBy);
```

**파라미터**:
- `newSortBy`: 새로운 정렬 옵션

**역할**: 정렬 변경 후 피드 재로드

**사용 예**:
```dart
DropdownButton<FeedSortBy>(
  value: provider.sortBy,
  onChanged: (value) => provider.changeSortOrder(value!),
  items: [
    DropdownMenuItem(value: FeedSortBy.latest, child: Text('최신순')),
    DropdownMenuItem(value: FeedSortBy.popular, child: Text('인기순')),
    // ...
  ],
);
```

---

#### applyFilter
```dart
Future<void> applyFilter(FeedFilterModel newFilter);
```

**파라미터**:
- `newFilter`: 새로운 필터 설정

**역할**: 필터 적용 후 피드 재로드

---

#### clearFilters
```dart
Future<void> clearFilters();
```

**역할**: 모든 필터 제거 후 피드 재로드

---

#### refresh
```dart
Future<void> refresh();
```

**역할**: 피드 새로고침 (Pull-to-refresh)

---

#### addPostOptimistically
```dart
void addPostOptimistically(PostDisplay post);
```

**파라미터**:
- `post`: 추가할 게시물

**역할**: 낙관적 UI 업데이트 (새 게시물 즉시 표시)

---

#### removePost
```dart
void removePost(String postId);
```

**파라미터**:
- `postId`: 제거할 게시물 ID

**역할**: 게시물 제거 (삭제 시)

---

#### updatePost
```dart
void updatePost(PostDisplay updatedPost);
```

**파라미터**:
- `updatedPost`: 업데이트된 게시물

**역할**: 특정 게시물 업데이트 (좋아요, 댓글 수 변경 등)

---

#### startFeedStream
```dart
void startFeedStream();
```

**역할**: 실시간 피드 스트림 시작

---

#### stopFeedStream
```dart
void stopFeedStream();
```

**역할**: 실시간 피드 스트림 중지

---

### PostDetailProvider

**위치**: `lib/features/post/presentation/providers/post_detail_provider.dart`

**상속**: `ChangeNotifier` with `BaseListProvider<PostDetailLoadingState, PostDisplay>`

#### post (Getter)
```dart
PostDisplay? get post;
```

**반환**: 현재 게시물 (없으면 null)

---

#### isLoading (Getter)
```dart
bool get isLoading;
```

**반환**: 로딩 중 여부

---

#### hasPost (Getter)
```dart
bool get hasPost;
```

**반환**: 게시물 존재 및 로딩 완료 여부

---

#### loadPost
```dart
Future<void> loadPost(String postId);
```

**파라미터**:
- `postId`: 로드할 게시물 ID

**역할**: 게시물 상세 정보 로드

---

#### startPostStream
```dart
void startPostStream(String postId);
```

**파라미터**:
- `postId`: 구독할 게시물 ID

**역할**: 실시간 게시물 스트림 시작

---

#### stopPostStream
```dart
void stopPostStream();
```

**역할**: 실시간 스트림 중지

---

#### refresh
```dart
Future<void> refresh(String postId);
```

**파라미터**:
- `postId`: 새로고침할 게시물 ID

**역할**: 게시물 새로고침

---

#### updatePostLocally
```dart
void updatePostLocally(PostDisplay updatedPost);
```

**파라미터**:
- `updatedPost`: 업데이트된 게시물

**역할**: 로컬 게시물 업데이트 (낙관적 업데이트)

---

### UserPostsProvider

**위치**: `lib/features/post/presentation/providers/user_posts_provider.dart`

**상속**: `ChangeNotifier` with `BaseListProvider<UserPostsLoadingState, PostDisplay>`

#### posts (Getter)
```dart
List<PostDisplay> get posts;
```

**반환**: 사용자 게시물 목록

---

#### isLoading (Getter)
```dart
bool get isLoading;
```

**반환**: 로딩 중 여부

---

#### hasPosts (Getter)
```dart
bool get hasPosts;
```

**반환**: 게시물 존재 및 로딩 완료 여부

---

#### loadUserPosts
```dart
Future<void> loadUserPosts({
  required String userId,
  int limit = -1,
});
```

**파라미터**:
- `userId`: 사용자 ID (필수)
- `limit`: 최대 결과 수 (-1 = 무제한)

**역할**: 사용자 게시물 로드

---

#### startUserPostsStream
```dart
void startUserPostsStream({
  required String userId,
  int limit = -1,
});
```

**역할**: 실시간 사용자 게시물 스트림 시작

---

#### stopUserPostsStream
```dart
void stopUserPostsStream();
```

**역할**: 실시간 스트림 중지

---

#### refresh
```dart
Future<void> refresh({
  required String userId,
  int limit = -1,
});
```

**역할**: 사용자 게시물 새로고침

---

### TrendingPostsProvider

**위치**: `lib/features/post/presentation/providers/trending_posts_provider.dart`

**상속**: `ChangeNotifier` with `BaseListProvider<TrendingLoadingState, PostDisplay>`

#### posts (Getter)
```dart
List<PostDisplay> get posts;
```

**반환**: 트렌딩 게시물 목록

---

#### loadTrendingPosts
```dart
Future<void> loadTrendingPosts({int limit = 20});
```

**파라미터**:
- `limit`: 최대 결과 수 (기본값 20)

**역할**: 트렌딩 게시물 로드

---

#### startTrendingStream
```dart
void startTrendingStream({int limit = 20});
```

**역할**: 실시간 트렌딩 스트림 시작

---

#### stopTrendingStream
```dart
void stopTrendingStream();
```

**역할**: 실시간 스트림 중지

---

#### refresh
```dart
Future<void> refresh({int limit = 20});
```

**역할**: 트렌딩 게시물 새로고침

---

### PopularPostsProvider

**위치**: `lib/features/post/presentation/providers/popular_posts_provider.dart`

**상속**: `ChangeNotifier` with `BaseListProvider<PopularLoadingState, PostDisplay>`

#### posts (Getter)
```dart
List<PostDisplay> get posts;
```

**반환**: 인기 게시물 목록

---

#### loadPopularPosts
```dart
Future<void> loadPopularPosts({
  int limit = 20,
  Duration? timeWindow,
});
```

**파라미터**:
- `limit`: 최대 결과 수
- `timeWindow`: 시간 창 (선택)

**역할**: 인기 게시물 로드

---

#### startPopularStream
```dart
void startPopularStream({
  int limit = 20,
  Duration? timeWindow,
});
```

**역할**: 실시간 인기 게시물 스트림 시작

---

#### stopPopularStream
```dart
void stopPopularStream();
```

**역할**: 실시간 스트림 중지

---

#### refresh
```dart
Future<void> refresh({
  int limit = 20,
  Duration? timeWindow,
});
```

**역할**: 인기 게시물 새로고침

---

## 🔗 Model Classes

### PostDisplay (Domain Model)

**위치**: `lib/features/post/domain/models/post_display.dart`

**역할**: UI 표시를 위한 순수 Dart 도메인 모델 (Firebase 의존성 0)

#### 필드 목록

##### 식별 정보
```dart
final String id;              // 게시물 ID
final String userId;          // 작성자 ID
final String displayName;     // 작성자 표시명
final String photoUrl;        // 작성자 프로필 사진
```

---

##### 콘텐츠
```dart
final String questionTitle;   // 질문 제목 (필수)
final String? description;    // 설명 (선택)
final String? optionAText;    // A 옵션 텍스트
final String? optionBText;    // B 옵션 텍스트
```

---

##### 이미지 (단일 & 멀티)
```dart
// 단일 이미지 (하위 호환성)
final String? optionAImageUrl;
final String? optionBImageUrl;

// 멀티 이미지
final List<String>? optionAImages;
final List<double>? optionAAspectRatios;
final List<String>? optionBImages;
final List<double>? optionBAspectRatios;
```

---

##### 레이아웃
```dart
final String layoutType;      // 'vertical' | 'horizontal'
```

---

##### 투표
```dart
final int votesA;             // A 투표 수
final int votesB;             // B 투표 수
final String voteStatus;      // 'pending' | 'active' | 'completed'
final bool voteCompleted;     // 투표 완료 여부
final DateTime? voteStartTime;  // 투표 시작 시간
final DateTime? voteEndTime;    // 투표 종료 시간
```

---

##### 메트릭
```dart
final int commentCount;       // 댓글 수
final int likeCount;          // 좋아요 수
final int shareCount;         // 공유 수
```

---

##### 메타데이터
```dart
final DateTime createdAt;           // 생성 시간
final bool isAnonymous;             // 익명 여부
final String status;                // 'published' | 'draft' | 'archived'
final Map<String, dynamic>? targetAudience;  // 타겟 오디언스
```

---

#### 계산 속성 (Getters)

##### votePercentageA
```dart
double get votePercentageA;
```

**반환**: A 옵션 투표 비율 (0-100)

**계산 로직**:
```dart
final total = votesA + votesB;
if (total == 0) return 50.0;
return (votesA / total) * 100;
```

---

##### votePercentageB
```dart
double get votePercentageB;
```

**반환**: B 옵션 투표 비율 (0-100)

---

##### hasImages
```dart
bool get hasImages;
```

**반환**: 이미지 포함 여부

**로직**: `optionAImageUrl != null || optionBImageUrl != null`

---

##### isTextOnly
```dart
bool get isTextOnly;
```

**반환**: 텍스트만 포함 여부

**로직**: `!hasImages`

---

##### totalVotes
```dart
int get totalVotes;
```

**반환**: 총 투표 수

**계산**: `votesA + votesB`

---

##### totalEngagement
```dart
int get totalEngagement;
```

**반환**: 총 참여도

**계산**: `commentCount + likeCount + shareCount`

---

#### toMap
```dart
Map<String, dynamic> toMap();
```

**반환**: Firestore 저장용 Map

**사용 예**:
```dart
final map = post.toMap();
await FirebaseFirestore.instance.collection('posts').doc(post.id).set(map);
```

---

#### copyWith
```dart
PostDisplay copyWith({
  String? id,
  String? questionTitle,
  // ... 모든 필드
});
```

**역할**: 일부 필드만 변경한 새 인스턴스 생성

**사용 예**:
```dart
final updatedPost = post.copyWith(
  likeCount: post.likeCount + 1,
);
```

---

#### Equatable
```dart
@override
List<Object?> get props => [id, questionTitle, ...];
```

**역할**: 값 기반 동등성 비교

**사용 예**:
```dart
if (post1 == post2) {
  // 모든 필드 값이 동일함
}
```

---

### PostDisplayDto (Data Transfer Object)

**위치**: `lib/features/post/data/dto/post_display_dto.dart`

**역할**: Firestore Raw 데이터를 담는 DTO

#### 필드
```dart
final String id;
final Map<String, dynamic> rawData;
```

---

#### fromFirestore
```dart
factory PostDisplayDto.fromFirestore(Map<String, dynamic> data, String id);
```

**파라미터**:
- `data`: Firestore document data
- `id`: Document ID

**반환**: DTO 인스턴스

---

#### 편의 Getters

##### getString
```dart
String? getString(String key);
```

**사용 예**: `dto.getString('questionTitle')`

---

##### getInt
```dart
int? getInt(String key);
```

**사용 예**: `dto.getInt('likeCount')`

---

##### getBool
```dart
bool? getBool(String key);
```

**사용 예**: `dto.getBool('isAnonymous')`

---

##### getList
```dart
List<dynamic>? getList(String key);
```

**사용 예**: `dto.getList('tags')`

---

##### getMap
```dart
Map<String, dynamic>? getMap(String key);
```

**사용 예**: `dto.getMap('targetAudience')`

---

##### getDateTime
```dart
DateTime? getDateTime(String key);
```

**역할**: 다양한 Firestore 날짜 형식 파싱

**지원 형식**:
- `DateTime`
- `Timestamp`
- `int` (milliseconds)
- `String` (ISO 8601)

**사용 예**: `dto.getDateTime('createdAt')`

---

##### getOptionData
```dart
Map<String, dynamic> getOptionData(String optionKey);
```

**파라미터**:
- `optionKey`: 'optionA' 또는 'optionB'

**반환**: 옵션 데이터 맵

**사용 예**: `dto.getOptionData('optionA')`

---

##### getOptionImages
```dart
List<String> getOptionImages(String optionKey);
```

**역할**: 옵션의 이미지 URL 목록 추출

**반환**: 빈 문자열 제외한 URL 목록

---

##### getOptionAspectRatios
```dart
List<double> getOptionAspectRatios(String optionKey);
```

**역할**: 옵션의 이미지 비율 목록 추출

**반환**: double 배열 (기본값 1.0)

---

### PostDisplayMapper

**위치**: `lib/features/post/data/mappers/post_display_mapper.dart`

**역할**: DTO ↔ Domain 모델 변환

#### toDomain
```dart
static PostDisplay toDomain(PostDisplayDto dto);
```

**파라미터**:
- `dto`: PostDisplayDto 인스턴스

**반환**: `PostDisplay` 도메인 모델

**변환 로직**:
```dart
// DTO 필드 → Domain 필드 매핑
questionTitle: dto.getString('questionTitle') ?? '',
userid: dto.getString('userid') ?? dto.getString('uid') ?? '',
username: dto.getString('username') ?? dto.getString('userName') ?? '',
likeCount: dto.getInt('likecount') ?? 0,
// ...
```

**사용 예**:
```dart
final dto = PostDisplayDto.fromFirestore(data, id);
final post = PostDisplayMapper.toDomain(dto);
```

---

#### fromDomain
```dart
static PostDisplayDto fromDomain(PostDisplay post);
```

**파라미터**:
- `post`: PostDisplay 도메인 모델

**반환**: `PostDisplayDto` DTO

**사용 예**:
```dart
final dto = PostDisplayMapper.fromDomain(post);
final rawData = dto.rawData;
```

---

## 🔌 Dependency Injection

### PostsModule 등록 구조

**위치**: `lib/app/di/posts_module.dart`

#### DataSource 등록
```dart
// Interface
getIt.registerLazySingleton<IPostDisplayDataSource>(
  () => FirebasePostDisplayDataSource(
    firestore: FirebaseFirestore.instance,
  ),
);
```

---

#### Repository 등록
```dart
// Interface → Implementation
getIt.registerLazySingleton<IPostDisplayRepositoryV2>(
  () => PostDisplayRepositoryV2Impl(
    dataSource: getIt<IPostDisplayDataSource>(),
  ),
);
```

---

#### UseCase 등록
```dart
// Feed UseCase
getIt.registerFactory<GetFeedUseCase>(
  () => GetFeedUseCase(
    postRepository: getIt<IPostDisplayRepositoryV2>(),
  ),
);

// PostDetail UseCase
getIt.registerFactory<GetPostDetailUseCase>(
  () => GetPostDetailUseCase(
    postRepository: getIt<IPostDisplayRepositoryV2>(),
  ),
);

// Trending UseCase
getIt.registerFactory<GetTrendingPostsUseCase>(
  () => GetTrendingPostsUseCase(
    postRepository: getIt<IPostDisplayRepositoryV2>(),
  ),
);

// Popular UseCase
getIt.registerFactory<GetPopularPostsUseCase>(
  () => GetPopularPostsUseCase(
    postRepository: getIt<IPostDisplayRepositoryV2>(),
  ),
);

// UserPosts UseCase
getIt.registerFactory<GetUserPostsUseCase>(
  () => GetUserPostsUseCase(
    postRepository: getIt<IPostDisplayRepositoryV2>(),
  ),
);
```

---

#### Provider 등록
```dart
// FeedProvider (Singleton)
getIt.registerLazySingleton<FeedProvider>(
  () => FeedProvider(
    getFeedUseCase: getIt<GetFeedUseCase>(),
  ),
);

// PostDetailProvider (Factory - 화면마다 새 인스턴스)
getIt.registerFactory<PostDetailProvider>(
  () => PostDetailProvider(
    getPostDetailUseCase: getIt<GetPostDetailUseCase>(),
  ),
);

// UserPostsProvider (Factory)
getIt.registerFactory<UserPostsProvider>(
  () => UserPostsProvider(
    getUserPostsUseCase: getIt<GetUserPostsUseCase>(),
  ),
);

// TrendingPostsProvider (Singleton)
getIt.registerLazySingleton<TrendingPostsProvider>(
  () => TrendingPostsProvider(
    getTrendingPostsUseCase: getIt<GetTrendingPostsUseCase>(),
  ),
);

// PopularPostsProvider (Singleton)
getIt.registerLazySingleton<PopularPostsProvider>(
  () => PopularPostsProvider(
    getPopularPostsUseCase: getIt<GetPopularPostsUseCase>(),
  ),
);
```

---

### 사용 예시

#### Provider 가져오기
```dart
// Singleton Provider
final feedProvider = getIt<FeedProvider>();

// Factory Provider (매번 새 인스턴스)
final detailProvider = getIt<PostDetailProvider>();
```

---

#### UseCase 직접 사용
```dart
final getFeedUseCase = getIt<GetFeedUseCase>();

final result = await getFeedUseCase.execute(
  limit: 20,
  sortBy: FeedSortBy.latest,
);
```

---

## 📝 에러 처리

### Result Pattern

**위치**: `/core/types/result.dart`

#### Result Type
```dart
sealed class Result<T> {
  const Result();

  R fold<R>(
    R Function(Failure) onFailure,
    R Function(T) onSuccess,
  );
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class ResultFailure<T> extends Result<T> {
  final Failure failure;
  const ResultFailure(this.failure);
}
```

---

### Failure 계층

**위치**: `/core/errors/failures.dart`

#### 기본 Failure 클래스
```dart
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});
}
```

---

#### Failure 타입

##### ServerFailure
```dart
class ServerFailure extends Failure {
  const ServerFailure({required String message, String? code})
    : super(message: message, code: code);
}
```

**사용 시점**: Firebase/API 서버 에러

**예**: permission-denied, unavailable

---

##### NetworkFailure
```dart
class NetworkFailure extends Failure {
  const NetworkFailure({String? message})
    : super(message: message ?? '네트워크 연결을 확인해주세요');
}
```

**사용 시점**: 네트워크 연결 끊김

---

##### NotFoundFailure
```dart
class NotFoundFailure extends Failure {
  const NotFoundFailure({String? message})
    : super(message: message ?? '요청한 데이터를 찾을 수 없습니다');
}
```

**사용 시점**: 게시물/사용자 존재하지 않음

---

##### AppFailure
```dart
class AppFailure extends Failure {
  const AppFailure({required String message})
    : super(message: message);
}
```

**사용 시점**: 일반 앱 에러

---

### 에러 처리 패턴

#### UseCase 레벨
```dart
Future<Result<List<PostDisplay>>> execute({...}) async {
  try {
    final stream = _postRepository.getTrendingPosts(...);
    final posts = await stream.first;

    return Success(posts);
  } catch (error) {
    print('GetTrendingPostsUseCase Error: $error');

    // Firebase 에러 파싱
    if (error.toString().contains('permission-denied')) {
      return ResultFailure(
        ServerFailure(
          message: 'Permission denied to load trending posts',
          code: 'permission-denied',
        ),
      );
    }

    // 일반 에러
    return ResultFailure(
      AppFailure(message: 'Failed to load trending posts: $error'),
    );
  }
}
```

---

#### Provider 레벨
```dart
Future<void> loadTrendingPosts({int limit = 20}) async {
  if (_loadingState == TrendingLoadingState.loading) return;

  setLoadingState(TrendingLoadingState.loading);
  clearError();

  try {
    final result = await _getTrendingPostsUseCase.execute(limit: limit);

    result.fold(
      (failure) {
        // BaseListProvider의 handleError 사용
        handleError(failure, TrendingLoadingState.error);
      },
      (posts) {
        _posts = posts;
        if (posts.isEmpty) {
          setLoadingState(TrendingLoadingState.empty);
        } else {
          setLoadingState(TrendingLoadingState.loaded);
        }
      },
    );
  } catch (e) {
    // 예외 캐치 후 AppFailure로 변환
    handleError(
      AppFailure(message: '트렌딩 게시물을 불러오는 중 오류가 발생했습니다: $e'),
      TrendingLoadingState.error,
    );
  }
}
```

---

#### UI 레벨
```dart
Consumer<TrendingPostsProvider>(
  builder: (context, provider, child) {
    // 에러 상태 확인
    if (provider.loadingState == TrendingLoadingState.error) {
      return ErrorWidget(
        message: provider.errorMessage ?? '알 수 없는 오류',
        onRetry: () => provider.refresh(),
      );
    }

    // 로딩 상태
    if (provider.isLoading) {
      return LoadingWidget();
    }

    // 빈 상태
    if (provider.loadingState == TrendingLoadingState.empty) {
      return EmptyWidget(message: '트렌딩 게시물이 없습니다');
    }

    // 성공 상태
    return PostListWidget(posts: provider.posts);
  },
);
```

---

## 🔄 스트림 처리

### 실시간 스트림 관리

#### 스트림 구독
```dart
StreamSubscription<Result<List<PostDisplay>>>? _postsStreamSubscription;

void startTrendingStream({int limit = 20}) {
  // 기존 구독 취소
  _postsStreamSubscription?.cancel();

  // 새 스트림 구독
  _postsStreamSubscription = _getTrendingPostsUseCase.getTrendingStream(
    limit: limit,
  ).listen(
    (result) {
      result.fold(
        (failure) => handleStreamError(failure),
        (posts) => _updatePostsFromStream(posts),
      );
    },
    onError: (error) {
      debugPrint('Trending posts stream error: $error');
      handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
    },
  );
}
```

---

#### 스트림 해제
```dart
void stopTrendingStream() {
  _postsStreamSubscription?.cancel();
  _postsStreamSubscription = null;
}

@override
void dispose() {
  stopTrendingStream();
  super.dispose();
}
```

---

#### 스트림 데이터 처리
```dart
void _updatePostsFromStream(List<PostDisplay> streamPosts) {
  _posts = streamPosts;

  // 상태 업데이트
  if (streamPosts.isEmpty) {
    setLoadingState(TrendingLoadingState.empty);
  } else if (_loadingState != TrendingLoadingState.loaded) {
    setLoadingState(TrendingLoadingState.loaded);
  }

  notifyListeners();
}
```

---

### Feed Provider의 고급 스트림 처리

#### 스트림 + 페이지네이션
```dart
void _updatePostsFromStream(List<PostDisplay> streamPosts) {
  // 스트림 업데이트와 기존 게시물 병합
  final updatedPostIds = streamPosts.map((p) => p.id).toSet();

  // 업데이트되지 않은 게시물 유지
  final unchangedPosts = _posts.where((p) => !updatedPostIds.contains(p.id)).toList();

  // 병합 및 정렬
  _posts = [...streamPosts, ...unchangedPosts];
  _sortPosts();

  notifyListeners();
}
```

---

#### 정렬 로직
```dart
void _sortPosts() {
  switch (_sortBy) {
    case FeedSortBy.latest:
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case FeedSortBy.popular:
      _posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      break;
    case FeedSortBy.mostVoted:
      _posts.sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
      break;
    case FeedSortBy.trending:
      // 트렌딩: 댓글 수 + (좋아요 × 2)
      _posts.sort((a, b) {
        final scoreA = a.commentCount + (a.likeCount * 2);
        final scoreB = b.commentCount + (b.likeCount * 2);
        return scoreB.compareTo(scoreA);
      });
      break;
  }
}
```

---

### 스트림 에러 처리

#### handleStreamError (BaseListProvider)
```dart
void handleStreamError(Failure failure, {TState? errorState}) {
  _errorMessage = getFailureMessage(failure);

  // 선택적으로 에러 상태 설정
  if (errorState != null) {
    setLoadingState(errorState);
  }

  // UI 업데이트만 (에러 상태는 변경하지 않음)
  notifyListeners();
}
```

**사용 예**:
```dart
_postsStreamSubscription = stream.listen(
  (result) {
    result.fold(
      (failure) => handleStreamError(failure), // 상태 변경 없이 에러 메시지만 설정
      (posts) => updatePosts(posts),
  );
  },
);
```

---

## 🚀 성능 최적화 팁

### 1. 스트림 구독 관리
```dart
// ✅ Good: dispose에서 구독 해제
@override
void dispose() {
  _feedStreamSubscription?.cancel();
  super.dispose();
}

// ❌ Bad: 메모리 누수
@override
void dispose() {
  super.dispose();
  // 스트림 구독 해제 누락
}
```

---

### 2. 중복 로딩 방지
```dart
Future<void> loadTrendingPosts({int limit = 20}) async {
  // ✅ Good: 이미 로딩 중이면 스킵
  if (_loadingState == TrendingLoadingState.loading) return;

  setLoadingState(TrendingLoadingState.loading);
  // ...
}
```

---

### 3. 효율적인 쿼리
```dart
// ✅ Good: 필요한 만큼만 조회
final stream = repository.queryPosts(limit: 20);

// ❌ Bad: 무제한 조회
final stream = repository.queryPosts(limit: -1);
```

---

### 4. BaseListProvider 활용
```dart
// ✅ Good: 공통 로직 재사용
class TrendingPostsProvider extends ChangeNotifier
    with BaseListProvider<TrendingLoadingState, PostDisplay> {
  // handleError, clearError 등 150+ 줄 코드 재사용
}

// ❌ Bad: 중복 코드 작성
class TrendingPostsProvider extends ChangeNotifier {
  String? _errorMessage;

  void handleError(Failure failure) {
    // 중복 코드 150+ 줄...
  }
}
```

---

### 5. Result 패턴 일관성
```dart
// ✅ Good: 모든 UseCase에서 Result 반환
Future<Result<List<PostDisplay>>> execute({...}) async {
  try {
    // ...
    return Success(posts);
  } catch (error) {
    return ResultFailure(AppFailure(message: ...));
  }
}

// ❌ Bad: 예외 던지기
Future<List<PostDisplay>> execute({...}) async {
  // throw Exception(...); // 에러 처리 불일치
}
```

---

## 📚 관련 문서

- [Feature Overview](./FEATURE_OVERVIEW.md) - 기능 개요
- [Usage Guide](./USAGE_GUIDE.md) - 사용 가이드
- [Migration Guide](../../docs/migration/POST_FEATURE_MIGRATION.md) - 마이그레이션 가이드

---

**작성자**: Claude Code Assistant
**마지막 업데이트**: 2025-01-20
**Clean Architecture**: v4.0
