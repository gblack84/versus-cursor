# Post Feature - Data Layer 문서

> **Version**: 1.0.0
> **Last Updated**: 2025-01-20
> **Clean Architecture**: v4.0
> **Layer**: Data Layer

---

## 📊 개요

Post Feature의 Data Layer는 **게시물 조회 및 표시**를 위한 데이터 접근 계층입니다. Clean Architecture v4.0 원칙에 따라 Firebase 의존성을 완전히 격리하고, Domain Layer에 순수한 데이터를 제공합니다.

### 핵심 특징

- ✅ **Firebase 의존성 완전 격리**: DataSource 인터페이스로 추상화
- ✅ **읽기 전용 최적화**: PostDisplay 모델로 UI 표시에 최적화
- ✅ **실시간 스트림 지원**: Firestore Stream을 통한 라이브 데이터 업데이트
- ✅ **복잡한 쿼리 처리**: PostQueryService로 Algolia 검색 통합
- ✅ **DTO 패턴**: 타입 안전한 데이터 전송 및 변환
- ✅ **Mapper 패턴**: DTO ↔ Domain 모델 변환 캡슐화

### Creation Feature와의 차이점

| 항목 | Post Feature | Creation Feature |
|------|-------------|-----------------|
| **목적** | 게시물 조회 (Read) | 게시물 생성 (Write) |
| **모델** | PostDisplay (UI 최적화) | PostCore/PostContent (생성 최적화) |
| **Repository** | 2개 | 8개 |
| **DataSource** | 1개 (Firebase) | 2개 (Firebase + Storage) |
| **기능** | 조회, 필터링, 검색 | 생성, 업로드, 검열 |

---

## 🏗️ 전체 구조도

```
lib/features/post/data/
├── datasources/
│   ├── interfaces/
│   │   └── i_post_display_datasource.dart      # DataSource 인터페이스 (계약)
│   └── firebase_post_display_datasource.dart    # Firebase 구현체
│
├── dto/
│   └── post_display_dto.dart                    # Data Transfer Object
│
├── mappers/
│   └── post_display_mapper.dart                 # DTO ↔ Domain 변환
│
└── repositories/
    ├── post_display_repository_v2_impl.dart     # 메인 Repository 구현
    └── post_query_service_impl.dart             # 복잡한 쿼리 전용 Service
```

### 아키텍처 플로우

```
[Presentation Layer]
        ↓
   [UseCase]
        ↓
[IPostDisplayRepositoryV2] ← Interface (Domain)
        ↓
[PostDisplayRepositoryV2Impl] ← Implementation (Data)
        ↓
[IPostDisplayDataSource] ← Interface (Data)
        ↓
[FirebasePostDisplayDataSource] ← Firebase Implementation
        ↓
   [Firestore]
```

---

## 📂 디렉토리별 상세 설명

### 1. `/datasources` - 데이터 소스 계층

#### **A. `interfaces/i_post_display_datasource.dart`**

**책임**: Firebase 추상화 계약 정의

**주요 메서드**:
```dart
abstract class IPostDisplayDataSource {
  // 쿼리 빌더 패턴으로 복잡한 조회 지원
  Stream<List<Map<String, dynamic>>> queryPosts({
    required Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder,
    int? limit,
  });

  // 단일 게시물 조회
  Future<Map<String, dynamic>?> getPost(String postId);

  // 여러 게시물 배치 조회
  Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds);

  // 메트릭 업데이트 (조회수 등)
  Future<void> updatePostMetrics(String postId, Map<String, dynamic> metrics);

  // 게시물 삭제
  Future<void> deletePost(String postId);
}
```

**설계 원칙**:
- 모든 메서드는 원시 데이터 타입(`Map<String, dynamic>`)만 반환
- Domain 모델에 대한 의존성 없음
- Firebase 특화 로직 숨김

#### **B. `firebase_post_display_datasource.dart`**

**책임**: Firestore 직접 통신 구현

**핵심 구현**:

**1. 동적 쿼리 빌더**:
```dart
Stream<List<Map<String, dynamic>>> queryPosts({...}) async* {
  Query query = _firestore.collection('posts');
  final queryParams = queryBuilder({});

  // orderBy 지원
  if (queryParams.containsKey('orderBy')) {
    query = query.orderBy(orderByField, descending: descending);
  }

  // where 조건 지원 (복잡한 연산자 포함)
  if (queryParams.containsKey('where')) {
    // isEqualTo, isGreaterThan, arrayContains 등
  }

  // 페이지네이션 커서
  if (queryParams.containsKey('startAfterId')) {
    final cursorDoc = await _firestore.collection('posts').doc(startAfterId).get();
    query = query.startAfterDocument(cursorDoc);
  }

  yield* query.snapshots().map((snapshot) => snapshot.docs.map(...).toList());
}
```

**2. 배치 조회 최적화**:
```dart
Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds) async {
  // Firebase whereIn 10개 제한 대응
  for (int i = 0; i < postIds.length; i += 10) {
    final batch = postIds.skip(i).take(10).toList();
    final querySnapshot = await _firestore
        .collection('posts')
        .where(FieldPath.documentId, whereIn: batch)
        .get();
    allPosts.addAll(querySnapshot.docs.map(...));
  }
}
```

**3. 메트릭 업데이트**:
```dart
Future<void> updatePostMetrics(String postId, Map<String, dynamic> metrics) async {
  final updateData = <String, dynamic>{};
  for (final entry in metrics.entries) {
    if (entry.value is Map && entry.value['increment'] != null) {
      updateData[entry.key] = FieldValue.increment(entry.value['increment']);
    } else {
      updateData[entry.key] = entry.value;
    }
  }
  await _firestore.collection('posts').doc(postId).update(updateData);
}
```

**에러 처리**:
- 모든 메서드에 try-catch 적용
- 에러 로깅 (print 사용, 추후 Logger 서비스로 교체 가능)
- null 반환 또는 Exception throw로 명확한 실패 표시

---

### 2. `/dto` - 데이터 전송 객체

#### **`post_display_dto.dart`**

**책임**: Firestore 원시 데이터 래핑 및 타입 안전 접근

**구조**:
```dart
class PostDisplayDto {
  final String id;
  final Map<String, dynamic> rawData;

  PostDisplayDto({required this.id, required this.rawData});

  factory PostDisplayDto.fromFirestore(Map<String, dynamic> data, String id) {
    return PostDisplayDto(id: id, rawData: data);
  }
}
```

**헬퍼 메서드** (87줄):
```dart
// 안전한 타입 변환
String? getString(String key);
int? getInt(String key);
bool? getBool(String key);
DateTime? getDateTime(String key);
List<String> getStringList(String key);
Map<String, dynamic> getMap(String key);

// 특수 필드 파싱
Map<String, dynamic> getOptionData(String optionKey);  // optionA/B 추출
List<String> getOptionImages(String optionKey);       // 이미지 URL 리스트
List<double> getOptionAspectRatios(String optionKey); // 종횡비 리스트
```

**장점**:
- Firestore 데이터 타입 불일치 방지
- null 안전성 보장
- 복잡한 중첩 구조 파싱 캡슐화

---

### 3. `/mappers` - 변환 계층

#### **`post_display_mapper.dart`**

**책임**: DTO ↔ Domain 모델 변환

**주요 메서드**:

**1. DTO → Domain 변환**:
```dart
static PostDisplay toDomain(PostDisplayDto dto) {
  // optionA/B 데이터 추출
  final optionA = dto.getOptionData('optionA');
  final optionAText = optionA['text'] as String?;
  final optionAImages = dto.getOptionImages('optionA');
  final optionAAspectRatios = dto.getOptionAspectRatios('optionA');

  // 레거시 필드명 처리
  final userId = dto.getString('userid') ?? dto.getString('uid') ?? '';
  final displayName = dto.getString('username') ?? dto.getString('userName') ?? '';

  // DateTime 파싱 (여러 형식 지원)
  final createdAt = dto.getDateTime('createdAt')
                 ?? dto.getDateTime('postCreatedDate')
                 ?? DateTime.now();

  return PostDisplay(...);
}
```

**2. Domain → DTO 변환**:
```dart
static PostDisplayDto fromDomain(PostDisplay post) {
  return PostDisplayDto(
    id: post.id,
    rawData: {
      'questionTitle': post.questionTitle,
      'userid': post.userId,
      'optionA': {
        'text': post.optionAText,
        'images': post.optionAImages,
        'aspectRatios': post.optionAAspectRatios,
      },
      // ...
    },
  );
}
```

**특징**:
- **레거시 호환성**: `userid` ↔ `uid`, `username` ↔ `userName` 모두 지원
- **기본값 처리**: null 필드에 적절한 기본값 제공
- **타입 변환**: Firestore 데이터 타입을 Domain 타입으로 안전하게 변환

---

### 4. `/repositories` - Repository 계층

#### **A. `post_display_repository_v2_impl.dart`**

**책임**: 메인 게시물 조회 로직 구현

**주요 메서드**:

**1. 기본 쿼리**:
```dart
@override
Stream<List<PostDisplay>> queryPosts({...}) {
  return _dataSource.queryPosts(
    queryBuilder: queryBuilder ?? (params) => params,
    limit: singleRecord ? 1 : limit > 0 ? limit : null,
  ).map((dataList) {
    return dataList.map((data) {
      final dto = PostDisplayDto.fromFirestore(data, data['id']);
      return PostDisplayMapper.toDomain(dto);
    }).toList();
  });
}
```

**2. 단일 게시물 조회**:
```dart
@override
Future<PostDisplay?> getPost(String postId) async {
  final data = await _dataSource.getPost(postId);
  if (data == null) return null;

  final dto = PostDisplayDto.fromFirestore(data, data['id']);
  return PostDisplayMapper.toDomain(dto);
}
```

**3. 실시간 스트림**:
```dart
@override
Stream<PostDisplay?> streamPost(String postId) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {...params, 'where': {'id': postId}},
    limit: 1,
  ).map((dataList) {
    if (dataList.isEmpty) return null;
    final dto = PostDisplayDto.fromFirestore(dataList.first, dataList.first['id']);
    return PostDisplayMapper.toDomain(dto);
  });
}
```

**4. 특수 쿼리 구현**:

**트렌딩 게시물** (인메모리 정렬):
```dart
@override
Stream<List<PostDisplay>> getTrendingPosts({int limit = 20}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {...params, 'orderBy': 'createdAt', 'descending': true},
    limit: 100, // 최근 100개 가져오기
  ).map((dataList) {
    final posts = dataList.map(...).toList();

    // 참여도 기준 정렬 (likes + comments + shares)
    posts.sort((a, b) => b.totalEngagement.compareTo(a.totalEngagement));

    return posts.take(limit).toList();
  });
}
```

**사용자별 게시물**:
```dart
@override
Stream<List<PostDisplay>> getUserPosts({required String userId, int limit = -1}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {
      ...params,
      'where': {'userid': userId},
      'orderBy': 'createdAt',
      'descending': true,
    },
    limit: limit > 0 ? limit : null,
  );
}
```

**투표 상태별 조회**:
```dart
// 진행중 투표
@override
Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {
      'where': {'voteStatus': 'in_progress'},
      'orderBy': 'voteStartTime',
    },
  );
}

// 완료된 투표
@override
Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {
      'where': {'voteStatus': 'completed'},
      'orderBy': 'voteEndTime',
    },
  );
}
```

**검색 기능** (클라이언트 측 필터링):
```dart
@override
Future<List<PostDisplay>> searchPosts({required String query, int limit = 20}) async {
  final dataList = await _dataSource.queryPosts(
    queryBuilder: (params) => {...params, 'orderBy': 'createdAt'},
    limit: 200,
  ).first;

  final posts = dataList.map(...).where((post) {
    final searchLower = query.toLowerCase();
    return post.questionTitle.toLowerCase().contains(searchLower) ||
           (post.description?.toLowerCase().contains(searchLower) ?? false);
  }).take(limit).toList();

  return posts;
}
```

**추천 게시물** (랜덤 셔플):
```dart
@override
Future<List<PostDisplay>> getRecommendedPosts({required String userId, int limit = 20}) async {
  final posts = await _dataSource.queryPosts(
    queryBuilder: (params) => {
      'where': {'userid': {'operator': 'isNotEqualTo', 'value': userId}},
    },
    limit: limit * 2,
  ).first;

  posts.shuffle(); // 랜덤 추천
  return posts.take(limit).toList();
}
```

**페이지네이션**:
```dart
@override
Stream<List<PostDisplay>> getPostsAfter({
  required String lastPostId,
  int limit = 20,
  Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) {
      final baseQuery = queryBuilder?.call(params) ?? params;
      return {...baseQuery, 'startAfterId': lastPostId};
    },
    limit: limit,
  );
}
```

**복합 필터링**:
```dart
@override
Stream<List<PostDisplay>> getPostsWithFilters({
  String? userId,
  String? status,
  bool? isAnonymous,
  DateTime? createdAfter,
  DateTime? createdBefore,
  int limit = 20,
}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) {
      final whereConditions = <String, dynamic>{};

      if (userId != null) whereConditions['userid'] = userId;
      if (status != null) whereConditions['status'] = status;
      if (isAnonymous != null) whereConditions['isAnonymous'] = isAnonymous;

      if (createdAfter != null) {
        whereConditions['createdAt'] = {
          'operator': 'isGreaterThan',
          'value': createdAfter,
        };
      }

      return {'where': whereConditions, 'orderBy': 'createdAt'};
    },
    limit: limit,
  );
}
```

**메트릭 업데이트**:
```dart
@override
Future<void> incrementViewCount(String postId) async {
  await _dataSource.updatePostMetrics(postId, {
    'viewCount': {'increment': 1}, // DataSource가 FieldValue.increment로 변환
  });
}
```

#### **B. `post_query_service_impl.dart`**

**책임**: 복잡한 검색 및 쿼리 처리 (Algolia 통합)

**주요 기능**:

**1. 전문 검색 (Algolia)**:
```dart
@override
Future<List<PostCreation>> fullTextSearch(String query, {int limit = 50}) async {
  final algoliaQuery = _algoliaIndex.query(query);
  algoliaQuery.setHitsPerPage(limit);

  final snapshot = await algoliaQuery.getObjects();

  return snapshot.hits.map((hit) {
    return PostCreation.fromJson({
      ...hit.data,
      'uid': hit.objectID,
    });
  }).toList();
}
```

**2. 검색 조건 빌더**:
```dart
@override
Future<List<PostCreation>> searchContent(SearchCriteria criteria) async {
  Query<Map<String, dynamic>> query = _firestore.collection('posts');

  // 키워드 검색
  if (criteria.keyword != null && criteria.keyword!.isNotEmpty) {
    // Algolia 사용 권장
    return fullTextSearch(criteria.keyword!);
  }

  // 카테고리 필터
  if (criteria.category != null) {
    query = query.where('category', isEqualTo: criteria.category);
  }

  // 날짜 범위
  if (criteria.startDate != null) {
    query = query.where('createdAt', isGreaterThanOrEqualTo: criteria.startDate);
  }

  // 정렬
  switch (criteria.sortBy) {
    case SortField.createdAt:
      query = query.orderBy('createdAt', descending: criteria.sortOrder == SortOrder.desc);
    case SortField.likes:
      query = query.orderBy('likecount', descending: true);
    // ...
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) => PostCreation.fromSnapshot(doc)).toList();
}
```

**3. 필터링**:
```dart
@override
Future<List<PostCreation>> getFilteredContent(ContentFilter filter) async {
  Query<Map<String, dynamic>> query = _firestore.collection('posts');

  if (filter.hasImages == true) {
    query = query.where('hasImages', isEqualTo: true);
  }

  if (filter.isAnonymous != null) {
    query = query.where('isAnonymous', isEqualTo: filter.isAnonymous);
  }

  if (filter.minVotes != null) {
    query = query.where('totalVotes', isGreaterThanOrEqualTo: filter.minVotes);
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) => PostCreation.fromSnapshot(doc)).toList();
}
```

**4. 페이지네이션**:
```dart
@override
Future<PaginatedResult<PostCreation>> getContentPaginated({
  String? lastDocumentId,
  int pageSize = 10,
  SortOrder sortOrder = SortOrder.createdDesc,
}) async {
  Query<Map<String, dynamic>> query = _firestore.collection('posts');

  // 정렬
  switch (sortOrder) {
    case SortOrder.createdDesc:
      query = query.orderBy('createdAt', descending: true);
    case SortOrder.likesDesc:
      query = query.orderBy('likecount', descending: true);
    // ...
  }

  // 커서 페이지네이션
  if (lastDocumentId != null) {
    final lastDoc = await _firestore.collection('posts').doc(lastDocumentId).get();
    if (lastDoc.exists) {
      query = query.startAfterDocument(lastDoc);
    }
  }

  query = query.limit(pageSize + 1); // +1로 hasMore 체크

  final snapshot = await query.get();
  final hasMore = snapshot.docs.length > pageSize;
  final items = snapshot.docs.take(pageSize).map(...).toList();

  return PaginatedResult(
    items: items,
    hasMore: hasMore,
    lastDocumentId: items.isNotEmpty ? items.last.uid : null,
  );
}
```

**5. 통계 정보**:
```dart
@override
Future<ContentStatistics> getContentStatistics() async {
  final snapshot = await _firestore.collection('posts').get();

  int totalPosts = snapshot.docs.length;
  int totalLikes = 0;
  int totalComments = 0;
  int anonymousPosts = 0;

  for (final doc in snapshot.docs) {
    final data = doc.data();
    totalLikes += (data['likecount'] as int?) ?? 0;
    totalComments += (data['commentcount'] as int?) ?? 0;
    if (data['isAnonymous'] == true) anonymousPosts++;
  }

  return ContentStatistics(
    totalPosts: totalPosts,
    totalLikes: totalLikes,
    totalComments: totalComments,
    anonymousPosts: anonymousPosts,
  );
}
```

**⚠️ 주의사항**:
- 현재 **PostCreation** (Creation feature) 모델을 import하고 있음
- **리팩토링 필요**: PostDisplay 모델 사용으로 전환 권장
- Algolia 통합은 선택적 기능 (Firebase만으로도 동작)

---

## 🔄 데이터 플로우

### 1. 게시물 목록 조회 플로우

```
[FeedProvider]
      ↓ call
[GetFeedUseCase]
      ↓ execute
[IPostDisplayRepositoryV2.queryPosts()]
      ↓ implements
[PostDisplayRepositoryV2Impl.queryPosts()]
      ↓ uses
[IPostDisplayDataSource.queryPosts()]
      ↓ implements
[FirebasePostDisplayDataSource.queryPosts()]
      ↓ query
   [Firestore]
      ↓ snapshots
[Stream<List<Map<String, dynamic>>>]
      ↓ map
[PostDisplayDto.fromFirestore()]
      ↓ map
[PostDisplayMapper.toDomain()]
      ↓ return
[Stream<List<PostDisplay>>]
      ↓ listen
[FeedProvider.setLoadingState()]
      ↓ notify
   [UI Update]
```

### 2. 실시간 스트림 플로우

```
[Firestore Collection]
      ↓ .snapshots()
[Stream<QuerySnapshot>]
      ↓ map
[Stream<List<Map<String, dynamic>>>]
      ↓ Repository
[Stream<List<PostDisplay>>]
      ↓ UseCase
[Stream<Result<List<PostDisplay>>>]
      ↓ Provider
[notifyListeners()]
      ↓
   [UI Auto-Update]
```

### 3. 페이지네이션 플로우

```
[사용자 스크롤 80% 지점]
      ↓
[FeedProvider.loadMore()]
      ↓
[GetFeedUseCase.loadMore(lastPostId)]
      ↓
[Repository.getPostsAfter(lastPostId)]
      ↓
[DataSource.queryPosts(startAfterId: lastPostId)]
      ↓
[Firestore.startAfterDocument()]
      ↓
[다음 20개 게시물]
      ↓
[기존 리스트에 추가]
      ↓
[UI 업데이트]
```

### 4. 검색 플로우 (Algolia)

```
[사용자 검색어 입력]
      ↓
[SearchProvider.search(query)]
      ↓
[GetSearchResultsUseCase.execute(query)]
      ↓
[PostQueryServiceImpl.fullTextSearch(query)]
      ↓
[Algolia Index.query()]
      ↓
[Algolia 서버 전문 검색]
      ↓
[검색 결과 PostDisplay 변환]
      ↓
[UI 결과 표시]
```

---

## 🛡️ 에러 처리

### 에러 처리 전략

Post Feature는 **Phase 3 Failures**를 사용하지 않고, **간소화된 에러 처리**를 사용합니다:

**1. DataSource 레벨**:
```dart
// firebase_post_display_datasource.dart
try {
  final doc = await _firestore.collection('posts').doc(postId).get();
  if (!doc.exists) return null; // 존재하지 않음
  return doc.data();
} catch (e) {
  print('Error getting post: $e'); // 로깅
  return null; // 또는 throw Exception
}
```

**2. Repository 레벨**:
```dart
// post_display_repository_v2_impl.dart
Future<PostDisplay?> getPost(String postId) async {
  final data = await _dataSource.getPost(postId);
  if (data == null) return null; // null 전파

  final dto = PostDisplayDto.fromFirestore(data, data['id']);
  return PostDisplayMapper.toDomain(dto);
}
```

**3. UseCase 레벨** (Domain Layer):
```dart
// get_post_detail_usecase.dart
Future<Result<PostDisplay?>> execute({required String postId}) async {
  try {
    final post = await _repository.getPost(postId);

    if (post == null) {
      return Failure(NotFoundFailure(message: '게시물을 찾을 수 없습니다'));
    }

    return Success(post);
  } catch (e) {
    return Failure(AppFailure(message: '게시물 조회 중 오류 발생: $e'));
  }
}
```

**4. Provider 레벨** (Presentation Layer):
```dart
// post_detail_provider.dart
Future<void> loadPost(String postId) async {
  setLoadingState(PostDetailLoadingState.loading);

  final result = await _getPostDetailUseCase.execute(postId: postId);

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
```

### 에러 타입 (Core Layer)

```dart
// /lib/core/errors/failures.dart
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});

  String getUserMessage(); // 사용자 친화적 메시지
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '요청한 게시물을 찾을 수 없습니다';
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '네트워크 연결을 확인해주세요';
}

class AppFailure extends Failure {
  const AppFailure({required String message}) : super(message: message);

  @override
  String getUserMessage() => '일시적인 오류가 발생했습니다';
}
```

### 에러 로깅

현재는 `print()`를 사용하지만, 향후 개선 사항:

```dart
// 추천 패턴 (향후)
import 'package:logger/logger.dart';

class FirebasePostDisplayDataSource {
  final Logger _logger = Logger();

  Future<Map<String, dynamic>?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();
      return doc.data();
    } on FirebaseException catch (e) {
      _logger.e('Firebase error getting post', error: e, stackTrace: e.stackTrace);
      throw NetworkFailure(message: 'Firebase error: ${e.code}');
    } catch (e, stackTrace) {
      _logger.e('Unexpected error getting post', error: e, stackTrace: stackTrace);
      throw AppFailure(message: 'Unexpected error: $e');
    }
  }
}
```

---

## 🧪 테스트 전략

### 1. DataSource 테스트

**firebase_post_display_datasource_test.dart**:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebasePostDisplayDataSource dataSource;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirebasePostDisplayDataSource(firestore: fakeFirestore);
  });

  group('FirebasePostDisplayDataSource', () {
    test('getPost returns null when post does not exist', () async {
      final result = await dataSource.getPost('non-existent-id');
      expect(result, isNull);
    });

    test('getPost returns post data when post exists', () async {
      // Arrange
      await fakeFirestore.collection('posts').doc('test-id').set({
        'questionTitle': 'Test Question',
        'userid': 'user123',
      });

      // Act
      final result = await dataSource.getPost('test-id');

      // Assert
      expect(result, isNotNull);
      expect(result!['id'], 'test-id');
      expect(result['questionTitle'], 'Test Question');
    });

    test('queryPosts applies where conditions correctly', () async {
      // Arrange
      await fakeFirestore.collection('posts').doc('post1').set({
        'userid': 'user123',
        'questionTitle': 'Post 1',
      });
      await fakeFirestore.collection('posts').doc('post2').set({
        'userid': 'user456',
        'questionTitle': 'Post 2',
      });

      // Act
      final stream = dataSource.queryPosts(
        queryBuilder: (params) => {'where': {'userid': 'user123'}},
      );

      final result = await stream.first;

      // Assert
      expect(result.length, 1);
      expect(result.first['userid'], 'user123');
    });

    test('getPostsByIds handles batching correctly', () async {
      // Arrange: 15개 게시물 생성 (10개 초과)
      final postIds = <String>[];
      for (int i = 0; i < 15; i++) {
        final id = 'post$i';
        postIds.add(id);
        await fakeFirestore.collection('posts').doc(id).set({
          'questionTitle': 'Post $i',
        });
      }

      // Act
      final result = await dataSource.getPostsByIds(postIds);

      // Assert
      expect(result.length, 15);
    });

    test('updatePostMetrics increments view count', () async {
      // Arrange
      await fakeFirestore.collection('posts').doc('post1').set({
        'viewCount': 10,
      });

      // Act
      await dataSource.updatePostMetrics('post1', {
        'viewCount': {'increment': 1},
      });

      // Assert
      final doc = await fakeFirestore.collection('posts').doc('post1').get();
      expect(doc.data()!['viewCount'], 11);
    });
  });
}
```

### 2. Mapper 테스트

**post_display_mapper_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PostDisplayMapper', () {
    test('toDomain converts DTO to Domain model correctly', () {
      // Arrange
      final dto = PostDisplayDto(
        id: 'post123',
        rawData: {
          'questionTitle': 'A vs B',
          'userid': 'user123',
          'username': 'John Doe',
          'optionA': {
            'text': 'Option A',
            'images': ['url1.jpg'],
            'aspectRatios': [1.5],
          },
          'optionB': {
            'text': 'Option B',
            'images': ['url2.jpg'],
            'aspectRatios': [0.75],
          },
          'createdAt': DateTime(2025, 1, 20),
          'likecount': 50,
          'votesA': 30,
          'votesB': 20,
        },
      );

      // Act
      final result = PostDisplayMapper.toDomain(dto);

      // Assert
      expect(result.id, 'post123');
      expect(result.questionTitle, 'A vs B');
      expect(result.userId, 'user123');
      expect(result.displayName, 'John Doe');
      expect(result.optionAText, 'Option A');
      expect(result.optionAImages, ['url1.jpg']);
      expect(result.optionAAspectRatios, [1.5]);
      expect(result.votesA, 30);
      expect(result.votesB, 20);
      expect(result.totalVotes, 50);
    });

    test('toDomain handles legacy field names', () {
      // Arrange
      final dto = PostDisplayDto(
        id: 'post123',
        rawData: {
          'questionTitle': 'Test',
          'uid': 'user123',        // 레거시 필드
          'userName': 'John Doe',  // 레거시 필드
        },
      );

      // Act
      final result = PostDisplayMapper.toDomain(dto);

      // Assert
      expect(result.userId, 'user123');
      expect(result.displayName, 'John Doe');
    });

    test('fromDomain converts Domain model to DTO correctly', () {
      // Arrange
      final post = PostDisplay(
        id: 'post123',
        questionTitle: 'A vs B',
        userId: 'user123',
        displayName: 'John Doe',
        optionAText: 'Option A',
        optionAImages: ['url1.jpg'],
        createdAt: DateTime(2025, 1, 20),
      );

      // Act
      final result = PostDisplayMapper.fromDomain(post);

      // Assert
      expect(result.id, 'post123');
      expect(result.rawData['questionTitle'], 'A vs B');
      expect(result.rawData['userid'], 'user123');
      expect(result.rawData['optionA']['text'], 'Option A');
    });
  });
}
```

### 3. Repository 테스트

**post_display_repository_v2_impl_test.dart**:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([IPostDisplayDataSource])
void main() {
  late PostDisplayRepositoryV2Impl repository;
  late MockIPostDisplayDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIPostDisplayDataSource();
    repository = PostDisplayRepositoryV2Impl(dataSource: mockDataSource);
  });

  group('PostDisplayRepositoryV2Impl', () {
    test('getPost returns PostDisplay when data exists', () async {
      // Arrange
      final testData = {
        'id': 'post123',
        'questionTitle': 'Test Post',
        'userid': 'user123',
      };

      when(mockDataSource.getPost('post123'))
          .thenAnswer((_) async => testData);

      // Act
      final result = await repository.getPost('post123');

      // Assert
      expect(result, isNotNull);
      expect(result!.id, 'post123');
      expect(result.questionTitle, 'Test Post');
      verify(mockDataSource.getPost('post123')).called(1);
    });

    test('getPost returns null when data does not exist', () async {
      // Arrange
      when(mockDataSource.getPost('non-existent'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getPost('non-existent');

      // Assert
      expect(result, isNull);
    });

    test('getTrendingPosts sorts by engagement', () async {
      // Arrange
      final testDataStream = Stream.value([
        {
          'id': 'post1',
          'questionTitle': 'Post 1',
          'likecount': 10,
          'commentcount': 5,
          'sharecount': 2,
        },
        {
          'id': 'post2',
          'questionTitle': 'Post 2',
          'likecount': 50,
          'commentcount': 20,
          'sharecount': 10,
        },
      ]);

      when(mockDataSource.queryPosts(
        queryBuilder: anyNamed('queryBuilder'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) => testDataStream);

      // Act
      final result = await repository.getTrendingPosts(limit: 2).first;

      // Assert
      expect(result.length, 2);
      expect(result.first.id, 'post2'); // 더 높은 engagement
      expect(result.last.id, 'post1');
    });

    test('incrementViewCount calls updatePostMetrics', () async {
      // Arrange
      when(mockDataSource.updatePostMetrics(any, any))
          .thenAnswer((_) async => {});

      // Act
      await repository.incrementViewCount('post123');

      // Assert
      verify(mockDataSource.updatePostMetrics('post123', {
        'viewCount': {'increment': 1},
      })).called(1);
    });
  });
}
```

### 4. 통합 테스트

**post_data_integration_test.dart**:

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirebasePostDisplayDataSource dataSource;
  late PostDisplayRepositoryV2Impl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = FirebasePostDisplayDataSource(firestore: fakeFirestore);
    repository = PostDisplayRepositoryV2Impl(dataSource: dataSource);
  });

  test('Full flow: create post → query → get → update', () async {
    // 1. Create test post
    await fakeFirestore.collection('posts').doc('post1').set({
      'questionTitle': 'Test Post',
      'userid': 'user123',
      'likecount': 10,
      'viewCount': 0,
    });

    // 2. Query posts
    final queryResult = await repository.queryPosts().first;
    expect(queryResult.length, 1);
    expect(queryResult.first.questionTitle, 'Test Post');

    // 3. Get single post
    final post = await repository.getPost('post1');
    expect(post, isNotNull);
    expect(post!.likeCount, 10);

    // 4. Increment view count
    await repository.incrementViewCount('post1');

    // 5. Verify update
    final updatedPost = await repository.getPost('post1');
    expect(updatedPost!.viewCount, 1);
  });
}
```

### 테스트 커버리지 목표

| 레이어 | 커버리지 목표 | 우선순위 |
|--------|--------------|----------|
| DataSource | 80%+ | High |
| Mapper | 90%+ | High |
| Repository | 85%+ | High |
| DTO | 70%+ | Medium |

---

## 🔐 보안 고려사항

### 1. Firestore Security Rules

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Posts 컬렉션 보안
    match /posts/{postId} {
      // 읽기: 모든 인증된 사용자 허용
      allow read: if request.auth != null;

      // 쓰기: 작성자만 허용
      allow create: if request.auth != null
                    && request.resource.data.userid == request.auth.uid;

      allow update: if request.auth != null
                    && resource.data.userid == request.auth.uid
                    // 또는 메트릭 업데이트만 허용
                    || (request.resource.data.diff(resource.data).affectedKeys()
                        .hasOnly(['viewCount', 'likecount', 'commentcount']));

      allow delete: if request.auth != null
                    && resource.data.userid == request.auth.uid;
    }
  }
}
```

### 2. 데이터 검증

**Repository 레벨**:
```dart
@override
Stream<List<PostDisplay>> getPostsWithFilters({
  String? userId,
  // ...
}) {
  // 입력 검증
  if (userId != null && userId.isEmpty) {
    throw ArgumentError('userId cannot be empty');
  }

  if (limit < 0 || limit > 100) {
    throw ArgumentError('limit must be between 0 and 100');
  }

  return _dataSource.queryPosts(...);
}
```

### 3. 민감 데이터 처리

```dart
class PostDisplayMapper {
  static PostDisplay toDomain(PostDisplayDto dto) {
    return PostDisplay(
      // ❌ 민감 데이터 제외
      // email, phoneNumber, privateData 등은 PostDisplay에 포함하지 않음

      // ✅ 공개 데이터만 매핑
      displayName: dto.getString('username'),
      photoUrl: dto.getString('userPhotoUrl'),
    );
  }
}
```

### 4. 익명 게시물 처리

```dart
@override
Stream<List<PostDisplay>> getUserPosts({required String userId}) {
  return _dataSource.queryPosts(
    queryBuilder: (params) => {
      ...params,
      'where': {
        'userid': userId,
        'isAnonymous': false, // ✅ 익명 게시물 제외
      },
    },
  );
}
```

---

## 🚀 확장 가능성

### 1. 새로운 DataSource 추가

**예: GraphQL DataSource**

```dart
// graphql_post_display_datasource.dart
class GraphQLPostDisplayDataSource implements IPostDisplayDataSource {
  final GraphQLClient _client;

  GraphQLPostDisplayDataSource({required GraphQLClient client})
      : _client = client;

  @override
  Stream<List<Map<String, dynamic>>> queryPosts({...}) async* {
    const query = r'''
      query GetPosts($limit: Int) {
        posts(limit: $limit) {
          id
          questionTitle
          userId
          createdAt
        }
      }
    ''';

    final result = await _client.query(QueryOptions(
      document: gql(query),
      variables: {'limit': limit},
    ));

    yield result.data!['posts'] as List<Map<String, dynamic>>;
  }
}
```

**DI 설정** (`lib/app/di.dart`):
```dart
void setupDataLayer() {
  // 기존 Firebase DataSource
  getIt.registerLazySingleton<IPostDisplayDataSource>(
    () => FirebasePostDisplayDataSource(),
    instanceName: 'firebase',
  );

  // 새로운 GraphQL DataSource
  getIt.registerLazySingleton<IPostDisplayDataSource>(
    () => GraphQLPostDisplayDataSource(client: getIt()),
    instanceName: 'graphql',
  );

  // Repository는 어떤 DataSource든 사용 가능
  getIt.registerLazySingleton<IPostDisplayRepositoryV2>(
    () => PostDisplayRepositoryV2Impl(
      dataSource: getIt(instanceName: 'firebase'), // 또는 'graphql'
    ),
  );
}
```

### 2. 캐싱 레이어 추가

**예: Hive 로컬 캐시**

```dart
// cached_post_display_datasource.dart
class CachedPostDisplayDataSource implements IPostDisplayDataSource {
  final IPostDisplayDataSource _remoteDataSource;
  final Box<Map<String, dynamic>> _cacheBox;

  CachedPostDisplayDataSource({
    required IPostDisplayDataSource remoteDataSource,
    required Box cacheBox,
  })  : _remoteDataSource = remoteDataSource,
        _cacheBox = cacheBox;

  @override
  Future<Map<String, dynamic>?> getPost(String postId) async {
    // 1. 캐시 확인
    if (_cacheBox.containsKey(postId)) {
      final cached = _cacheBox.get(postId);
      final cacheTime = cached!['_cachedAt'] as DateTime;

      // 5분 이내 캐시는 바로 반환
      if (DateTime.now().difference(cacheTime).inMinutes < 5) {
        return cached;
      }
    }

    // 2. 원격 조회
    final data = await _remoteDataSource.getPost(postId);

    // 3. 캐시 저장
    if (data != null) {
      await _cacheBox.put(postId, {
        ...data,
        '_cachedAt': DateTime.now(),
      });
    }

    return data;
  }

  @override
  Stream<List<Map<String, dynamic>>> queryPosts({...}) async* {
    // 캐시는 단일 조회만, 목록은 항상 원격
    yield* _remoteDataSource.queryPosts(queryBuilder: queryBuilder, limit: limit);
  }
}
```

### 3. 복합 Repository 패턴

**예: 읽기/쓰기 분리 (CQRS)**

```dart
// read_optimized_post_repository.dart
class ReadOptimizedPostRepository implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _readDataSource;
  final IPostWriteDataSource _writeDataSource; // 별도 쓰기 DataSource

  // 읽기 메서드는 읽기 전용 DataSource 사용
  @override
  Future<PostDisplay?> getPost(String postId) async {
    final data = await _readDataSource.getPost(postId);
    // ...
  }

  // 쓰기 메서드는 쓰기 DataSource 사용
  @override
  Future<void> incrementViewCount(String postId) async {
    await _writeDataSource.updateMetrics(postId, {'viewCount': 1});
  }
}
```

### 4. Algolia 검색 강화

**PostQueryServiceImpl 개선**:

```dart
class PostQueryServiceImpl implements IPostQueryService {
  final AlgoliaIndex _algoliaIndex;
  final IPostDisplayDataSource _dataSource;

  @override
  Future<List<PostDisplay>> advancedSearch({
    required String query,
    List<String>? filters,  // NEW: 패싯 필터
    GeoLocation? location,  // NEW: 위치 기반 검색
    int page = 0,
    int hitsPerPage = 20,
  }) async {
    final algoliaQuery = _algoliaIndex.query(query);

    // 필터 적용
    if (filters != null) {
      for (final filter in filters) {
        algoliaQuery.filters(filter);
      }
    }

    // 위치 기반 검색
    if (location != null) {
      algoliaQuery.aroundLatLng('${location.lat},${location.lng}');
      algoliaQuery.aroundRadius(10000); // 10km
    }

    algoliaQuery.setPage(page);
    algoliaQuery.setHitsPerPage(hitsPerPage);

    final snapshot = await algoliaQuery.getObjects();

    return snapshot.hits.map((hit) {
      final dto = PostDisplayDto.fromFirestore(hit.data, hit.objectID);
      return PostDisplayMapper.toDomain(dto);
    }).toList();
  }
}
```

---

## 📊 성능 최적화

### 1. 스트림 메모리 최적화

**문제**: 무한 스크롤 시 메모리 누수 가능성

**해결**:
```dart
class FeedProvider with ChangeNotifier {
  StreamSubscription<List<PostDisplay>>? _subscription;

  void initializeFeed() {
    // 기존 구독 해제
    _subscription?.cancel();

    _subscription = _getPostsUseCase.execute().listen(
      (posts) {
        _posts = posts;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel(); // ✅ 메모리 누수 방지
    super.dispose();
  }
}
```

### 2. 배치 조회 최적화

**FirebasePostDisplayDataSource**:
```dart
Future<List<Map<String, dynamic>>> getPostsByIds(List<String> postIds) async {
  // ✅ 10개씩 배치 처리 (Firebase whereIn 제한)
  final batches = <Future<List<Map<String, dynamic>>>>[];

  for (int i = 0; i < postIds.length; i += 10) {
    final batch = postIds.skip(i).take(10).toList();

    batches.add(
      _firestore
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batch)
          .get()
          .then((snapshot) => snapshot.docs.map(...).toList())
    );
  }

  // ✅ 병렬 실행으로 성능 향상
  final results = await Future.wait(batches);
  return results.expand((x) => x).toList();
}
```

### 3. 쿼리 인덱스 최적화

**Firestore Indexes** (`firestore.indexes.json`):
```json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "userid", "order": "ASCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "voteStatus", "order": "ASCENDING"},
        {"fieldPath": "voteStartTime", "order": "DESCENDING"}
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        {"fieldPath": "likecount", "order": "DESCENDING"},
        {"fieldPath": "createdAt", "order": "DESCENDING"}
      ]
    }
  ]
}
```

### 4. 페이지네이션 최적화

```dart
class FeedProvider {
  List<PostDisplay> _posts = [];
  String? _lastPostId;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    setLoadingState(FeedLoadingState.loadingMore);

    final result = await _getFeedUseCase.loadMore(
      lastPostId: _lastPostId,
      limit: 20,
    );

    result.fold(
      (failure) => handleError(failure, FeedLoadingState.error),
      (newPosts) {
        if (newPosts.length < 20) {
          _hasMore = false; // ✅ 더 이상 데이터 없음
        }

        _posts.addAll(newPosts);
        _lastPostId = newPosts.isNotEmpty ? newPosts.last.id : null;
        setLoadingState(FeedLoadingState.loaded);
      },
    );
  }
}
```

### 5. 클라이언트 측 캐싱

```dart
class PostCacheManager {
  final Map<String, PostDisplay> _cache = {};
  final Duration _ttl = Duration(minutes: 5);
  final Map<String, DateTime> _cacheTime = {};

  PostDisplay? get(String postId) {
    if (!_cache.containsKey(postId)) return null;

    final cacheTime = _cacheTime[postId]!;
    if (DateTime.now().difference(cacheTime) > _ttl) {
      // ✅ 만료된 캐시 제거
      _cache.remove(postId);
      _cacheTime.remove(postId);
      return null;
    }

    return _cache[postId];
  }

  void put(String postId, PostDisplay post) {
    _cache[postId] = post;
    _cacheTime[postId] = DateTime.now();
  }

  void clear() {
    _cache.clear();
    _cacheTime.clear();
  }
}
```

---

## 🔗 관련 문서

### Post Feature 문서
- [Feature Overview](/lib/features/post/docs/FEATURE_OVERVIEW.md) - 기능 개요
- [API Reference](/lib/features/post/docs/API_REFERENCE.md) - 상세 API 문서
- [Usage Guide](/lib/features/post/docs/USAGE_GUIDE.md) - 사용 가이드
- [Migration Guide](/specs/001-users-g-black/plan.md) - 마이그레이션 계획

### 다른 Feature 참조
- [Creation Data Layer](/lib/features/creation/data/README.md) - 쓰기 중심 구조 참조
- [Auth Feature](/lib/features/auth/) - 인증 Feature 구조

### Core 문서
- [Clean Architecture Guide](/docs/architecture/CLEAN_ARCHITECTURE.md) - 아키텍처 원칙
- [Error Handling](/lib/core/errors/README.md) - 에러 처리 가이드
- [Testing Strategy](/docs/testing/TESTING_STRATEGY.md) - 테스트 전략

---

**작성자**: Claude Code Assistant
**마지막 리뷰**: 2025-01-20
**버전**: 1.0.0
