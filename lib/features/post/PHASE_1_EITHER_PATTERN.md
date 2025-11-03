# Post Feature - Phase 1: Either Pattern Migration

> **마이그레이션 가이드**: Result<T> → Either<PostFailure, T> 전환
> **난이도**: ⭐⭐⭐☆☆ (중상)
> **예상 소요 시간**: 2-3일 (16-24시간)
> **작성일**: 2025-01-31

---

## 📋 개요

### 마이그레이션 목적

Post Feature의 에러 처리 패턴을 **Result<T>**에서 **Either<L, R>** (fpdart)로 전환하여 Auth/Profile/Voting/Chat Features와 일관성을 확보합니다.

### 핵심 변경사항

```
Before: Result<Success, Failure> (커스텀 타입)
After:  Either<PostFailure, T> (fpdart 라이브러리)
```

**주요 변경**:
- ✅ **PostFailure**: Freezed를 사용한 sealed class 생성
- ✅ **Repository 인터페이스**: Stream 기반은 유지, Future는 Either 래핑
- ✅ **UseCases**: Result → Either 전환
- ✅ **Provider**: fold() 패턴으로 에러 처리

### 영향 범위

| 레이어 | 파일 수 | 변경 줄 수 | 주요 변경 사항 |
|--------|---------|-----------|---------------|
| **Domain (Failures)** | 1개 (신규) | +150줄 | PostFailure sealed class 생성 |
| **Domain (Repository)** | 1개 | +30줄 | Future → Either 래핑 |
| **Domain (UseCases)** | 8개 | ~200줄 | Result → Either 전환 |
| **Presentation (Providers)** | 3개 | ~100줄 | fold() 에러 처리 |
| **합계** | **13개** | **+480줄** | - |

### 주요 이점

| 항목 | Before (Result<T>) | After (Either<L, R>) | 변화 |
|------|-------------------|---------------------|------|
| **타입 안전성** | ⚠️ 런타임 체크 | ✅ 컴파일 타임 체크 | **대폭 개선** |
| **에러 종류** | Generic Failure | 15개 구체적 실패 타입 | **15배 ↑** |
| **함수형 패턴** | isSuccess 체크 | fold() 패턴 | **표준화** |
| **일관성** | ❌ 독자적 패턴 | ✅ Auth/Chat과 동일 | **100%** |

---

## 🔍 현재 상태 분석

### 1. 현재 Result<T> 사용 (core/types/result.dart)

**파일**: `lib/core/types/result.dart`

```dart
/// ❌ 현재: 커스텀 Result 타입
class Result<T> {
  final T? data;
  final Failure? error;
  final bool isSuccess;

  Result.success(this.data)
      : error = null,
        isSuccess = true;

  Result.failure(this.error)
      : data = null,
        isSuccess = false;
}

/// Generic Failure 클래스 (구체적이지 않음)
class Failure {
  final String message;
  final dynamic error;

  Failure({required this.message, this.error});
}
```

**문제점**:
1. **런타임 타입 체크**: `result.isSuccess` 체크로 null 여부 확인
2. **Generic Failure**: 어떤 종류의 에러인지 알 수 없음
3. **패턴 불일치**: Auth/Chat Features는 Either 사용

### 2. UseCase 현재 구현

**파일**: `lib/features/post/domain/usecases/get_feed_usecase.dart:16-117`

```dart
/// ❌ 현재: Result<T> 패턴
class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  Future<Result<FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      Stream<List<PostDisplay>> stream;

      // Repository 메서드 호출
      switch (sortBy) {
        case FeedSortBy.latest:
          stream = _postRepository.queryPosts(
            queryBuilder: (params) => {
              ...params,
              'orderBy': 'createdAt',
              'descending': true,
            },
            limit: limit,
          );
          break;
        // ... 기타 케이스
      }

      // Stream을 List로 변환
      final posts = await stream.first;

      // Success 반환
      return Result.success(FeedResult(
        posts: posts,
        hasMore: posts.length == limit,
        lastDocumentId: posts.isNotEmpty ? posts.last.id : null,
      ));
    } catch (e, stackTrace) {
      // Generic Failure 반환
      return Result.failure(Failure(
        message: 'Failed to load feed: ${e.toString()}',
        error: e,
      ));
    }
  }
}
```

**문제점**:
1. **try-catch 필수**: 모든 예외를 수동으로 캐치
2. **에러 타입 불명확**: "Failed to load feed"만으로는 원인 파악 어려움
3. **중복 에러 처리**: 모든 UseCase가 동일한 try-catch 패턴

### 3. Provider 현재 구현

**파일**: `lib/features/post/presentation/providers/feed_provider.dart` (추정)

```dart
/// ❌ 현재: Result.isSuccess 체크
class FeedProvider extends ChangeNotifier {
  List<PostDisplay> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> loadFeed() async {
    _isLoading = true;
    notifyListeners();

    final result = await _getFeedUseCase.execute(limit: 20);

    if (result.isSuccess) {
      _posts = result.data!.posts;  // null 체크 필요
      _errorMessage = null;
    } else {
      _errorMessage = result.error!.message;  // null 체크 필요
    }

    _isLoading = false;
    notifyListeners();
  }
}
```

**문제점**:
1. **null 체크 필요**: `result.data!`, `result.error!` 강제 언래핑
2. **에러 타입 구분 불가**: 네트워크 에러인지 권한 에러인지 알 수 없음
3. **에러 복구 어려움**: Generic 에러 메시지만 표시

---

## 🎯 마이그레이션 목표

### Before → After 비교

#### 1. Failure 정의

```dart
// ❌ Before: Generic Failure
class Failure {
  final String message;
  final dynamic error;
}

// ✅ After: Sealed Class (15개 구체적 타입)
@freezed
sealed class PostFailure with _$PostFailure {
  // Network & Server Errors
  const factory PostFailure.networkError() = NetworkError;
  const factory PostFailure.serverError({String? message}) = ServerError;
  const factory PostFailure.timeout() = TimeoutError;

  // Permission & Auth Errors
  const factory PostFailure.insufficientPermissions() = InsufficientPermissions;
  const factory PostFailure.unauthorized() = Unauthorized;

  // Resource Errors
  const factory PostFailure.postNotFound({required String postId}) = PostNotFound;
  const factory PostFailure.userNotFound({required String userId}) = UserNotFound;

  // Validation Errors
  const factory PostFailure.invalidInput({required String field}) = InvalidInput;
  const factory PostFailure.contentTooLong({required int maxLength}) = ContentTooLong;

  // Operation Errors
  const factory PostFailure.createFailed({String? reason}) = CreateFailed;
  const factory PostFailure.updateFailed({String? reason}) = UpdateFailed;
  const factory PostFailure.deleteFailed({String? reason}) = DeleteFailed;

  // Search & Query Errors
  const factory PostFailure.searchFailed({String? query}) = SearchFailed;
  const factory PostFailure.queryFailed({String? reason}) = QueryFailed;

  // Unexpected
  const factory PostFailure.unexpected({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) = Unexpected;
}
```

#### 2. Repository 인터페이스 (Future만 Either 래핑)

```dart
// ❌ Before: Stream<T>, Future<T?> (에러 throw)
abstract class IPostDisplayRepositoryV2 {
  Stream<List<PostDisplay>> queryPosts({...});
  Future<PostDisplay?> getPost(String postId);  // throw Exception
  Future<void> incrementViewCount(String postId);  // throw Exception
  Future<List<PostDisplay>> searchPosts({required String query});  // throw Exception
}

// ✅ After: Stream<T> 유지, Future는 Either 래핑
abstract class IPostDisplayRepositoryV2 {
  // Stream은 그대로 유지 (Stream.error() 사용)
  Stream<List<PostDisplay>> queryPosts({...});
  Stream<PostDisplay?> streamPost(String postId);

  // Future는 Either로 래핑
  Future<Either<PostFailure, PostDisplay>> getPost(String postId);
  Future<Either<PostFailure, Unit>> incrementViewCount(String postId);
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  });
  Future<Either<PostFailure, List<PostDisplay>>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  });
  Future<Either<PostFailure, List<PostDisplay>>> getPostsByIds(
    List<String> postIds,
  );
}
```

**설계 원칙**:
- **Stream**: 실시간 업데이트가 필요한 쿼리 (피드, 단일 포스트 스트림)
- **Future + Either**: 단발성 작업 (검색, 추천, 조회수 증가)

#### 3. UseCase 전환

```dart
// ❌ Before: Result<T>
Future<Result<FeedResult>> execute({...}) async {
  try {
    final stream = _postRepository.queryPosts(...);
    final posts = await stream.first;

    return Result.success(FeedResult(
      posts: posts,
      hasMore: posts.length == limit,
    ));
  } catch (e) {
    return Result.failure(Failure(
      message: 'Failed to load feed: ${e.toString()}',
    ));
  }
}

// ✅ After: Either<PostFailure, T>
Future<Either<PostFailure, FeedResult>> execute({...}) async {
  try {
    final stream = _postRepository.queryPosts(...);
    final posts = await stream.first;

    return right(FeedResult(
      posts: posts,
      hasMore: posts.length == limit,
      lastDocumentId: posts.isNotEmpty ? posts.last.id : null,
    ));
  } on FirebaseException catch (e) {
    // Firebase 에러를 PostFailure로 변환
    return left(_mapFirebaseException(e));
  } on TimeoutException {
    return left(const PostFailure.timeout());
  } catch (e, stackTrace) {
    return left(PostFailure.unexpected(
      message: 'Failed to load feed',
      error: e,
      stackTrace: stackTrace,
    ));
  }
}

// Helper: Firebase Exception 매핑
PostFailure _mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return const PostFailure.insufficientPermissions();
    case 'not-found':
      return PostFailure.postNotFound(postId: e.message ?? 'unknown');
    case 'unavailable':
      return const PostFailure.networkError();
    default:
      return PostFailure.serverError(message: e.message);
  }
}
```

#### 4. Provider 에러 처리

```dart
// ❌ Before: isSuccess 체크
Future<void> loadFeed() async {
  final result = await _getFeedUseCase.execute(limit: 20);

  if (result.isSuccess) {
    _posts = result.data!.posts;  // null 체크 필요
    _errorMessage = null;
  } else {
    _errorMessage = result.error!.message;
  }

  notifyListeners();
}

// ✅ After: fold() 패턴
Future<void> loadFeed() async {
  final result = await _getFeedUseCase.execute(limit: 20);

  result.fold(
    (failure) {
      // 구체적인 에러 타입으로 처리
      _errorMessage = failure.when(
        networkError: () => '네트워크 연결을 확인해주세요',
        timeout: () => '요청 시간이 초과되었습니다',
        insufficientPermissions: () => '권한이 부족합니다',
        postNotFound: (postId) => '게시물을 찾을 수 없습니다',
        unexpected: (message, _, __) => message ?? '알 수 없는 오류',
        // ... 기타 failure 타입
      );
    },
    (feedResult) {
      _posts = feedResult.posts;  // null 걱정 없음
      _hasMore = feedResult.hasMore;
      _errorMessage = null;
    },
  );

  notifyListeners();
}
```

---

## 📝 단계별 마이그레이션 가이드

### Step 1: PostFailure 생성

**파일 경로**: `lib/features/post/domain/failures/post_failure.dart` (신규)

**작업 내용**:
1. `post_failure.dart` 파일 생성
2. Freezed sealed class 정의 (15개 failure 타입)
3. `build_runner` 실행

**작업 시간**: 1-2시간

**체크리스트**:
- [ ] Freezed 의존성 확인 (`pubspec.yaml`)
- [ ] `post_failure.dart` 생성
- [ ] 15개 failure 타입 정의
  - [ ] Network & Server Errors (3개)
  - [ ] Permission & Auth Errors (2개)
  - [ ] Resource Errors (2개)
  - [ ] Validation Errors (2개)
  - [ ] Operation Errors (3개)
  - [ ] Search & Query Errors (2개)
  - [ ] Unexpected (1개)
- [ ] `build_runner` 실행: `flutter pub run build_runner build`
- [ ] Generated 파일 확인: `post_failure.freezed.dart`

**전체 코드**:

```dart
// lib/features/post/domain/failures/post_failure.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_failure.freezed.dart';

/// Post Feature의 모든 실패 타입을 정의하는 Sealed Class
///
/// **Either Pattern과 함께 사용**:
/// ```dart
/// final result = await getPostUseCase.execute(postId);
/// result.fold(
///   (failure) {
///     failure.when(
///       postNotFound: (postId) => print('Post $postId not found'),
///       networkError: () => print('Network error'),
///       ...
///     );
///   },
///   (post) => print('Success: ${post.id}'),
/// );
/// ```
@freezed
sealed class PostFailure with _$PostFailure {
  // ========== Network & Server Errors ==========

  /// 네트워크 연결 실패
  ///
  /// **발생 시나리오**:
  /// - 인터넷 연결 없음
  /// - Firestore 서버 접근 불가
  const factory PostFailure.networkError() = NetworkError;

  /// 서버 에러 (Firebase 서버 문제)
  ///
  /// **발생 시나리오**:
  /// - Firestore 내부 오류
  /// - Cloud Functions 실행 실패
  const factory PostFailure.serverError({String? message}) = ServerError;

  /// 요청 시간 초과
  ///
  /// **발생 시나리오**:
  /// - Firestore 쿼리가 10초 이상 소요
  /// - 네트워크 지연
  const factory PostFailure.timeout() = TimeoutError;

  // ========== Permission & Auth Errors ==========

  /// 권한 부족 (Firestore Security Rules 거부)
  ///
  /// **발생 시나리오**:
  /// - 로그인하지 않은 사용자가 게시물 작성 시도
  /// - 다른 사용자의 게시물 수정/삭제 시도
  const factory PostFailure.insufficientPermissions() = InsufficientPermissions;

  /// 인증되지 않은 사용자
  ///
  /// **발생 시나리오**:
  /// - Firebase Auth 토큰 만료
  /// - 로그아웃 상태에서 작업 시도
  const factory PostFailure.unauthorized() = Unauthorized;

  // ========== Resource Errors ==========

  /// 게시물을 찾을 수 없음
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 postId로 조회
  /// - 삭제된 게시물 접근
  const factory PostFailure.postNotFound({required String postId}) = PostNotFound;

  /// 사용자를 찾을 수 없음
  ///
  /// **발생 시나리오**:
  /// - 존재하지 않는 userId로 게시물 조회
  /// - 탈퇴한 사용자의 게시물 조회
  const factory PostFailure.userNotFound({required String userId}) = UserNotFound;

  // ========== Validation Errors ==========

  /// 입력값이 유효하지 않음
  ///
  /// **발생 시나리오**:
  /// - 빈 제목 또는 내용
  /// - 잘못된 형식의 데이터
  const factory PostFailure.invalidInput({required String field}) = InvalidInput;

  /// 내용이 너무 긺
  ///
  /// **발생 시나리오**:
  /// - 제목/내용이 최대 길이 초과
  const factory PostFailure.contentTooLong({required int maxLength}) = ContentTooLong;

  // ========== Operation Errors ==========

  /// 게시물 생성 실패
  ///
  /// **발생 시나리오**:
  /// - Firestore 쓰기 작업 실패
  /// - 이미지 업로드 실패
  const factory PostFailure.createFailed({String? reason}) = CreateFailed;

  /// 게시물 업데이트 실패
  ///
  /// **발생 시나리오**:
  /// - 동시 수정 충돌
  /// - 권한 변경으로 인한 실패
  const factory PostFailure.updateFailed({String? reason}) = UpdateFailed;

  /// 게시물 삭제 실패
  ///
  /// **발생 시나리오**:
  /// - 이미 삭제된 게시물
  /// - 권한 부족
  const factory PostFailure.deleteFailed({String? reason}) = DeleteFailed;

  // ========== Search & Query Errors ==========

  /// 검색 실패
  ///
  /// **발생 시나리오**:
  /// - Algolia 검색 서비스 오류
  /// - 잘못된 검색 쿼리
  const factory PostFailure.searchFailed({String? query}) = SearchFailed;

  /// 쿼리 실패
  ///
  /// **발생 시나리오**:
  /// - Firestore 인덱스 누락
  /// - 복잡한 쿼리 실행 실패
  const factory PostFailure.queryFailed({String? reason}) = QueryFailed;

  // ========== Unexpected ==========

  /// 예상하지 못한 에러
  ///
  /// **발생 시나리오**:
  /// - 위 카테고리에 속하지 않는 모든 에러
  const factory PostFailure.unexpected({
    String? message,
    Object? error,
    StackTrace? stackTrace,
  }) = Unexpected;
}
```

**build_runner 실행**:
```bash
# Freezed 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 생성된 파일 확인
ls lib/features/post/domain/failures/post_failure.freezed.dart
```

---

### Step 2: Repository 인터페이스 업데이트

**파일 경로**: `lib/features/post/domain/repositories/i_post_display_repository_v2.dart`

**작업 내용**:
1. `fpdart` import 추가
2. `PostFailure` import 추가
3. Future 메서드만 Either 래핑 (Stream은 유지)

**작업 시간**: 30분

**체크리스트**:
- [ ] import 추가 (`package:fpdart/fpdart.dart`)
- [ ] import 추가 (`../failures/post_failure.dart`)
- [ ] Future 메서드 5개 Either 래핑
  - [ ] `getPost()`: `Future<PostDisplay?>` → `Future<Either<PostFailure, PostDisplay>>`
  - [ ] `incrementViewCount()`: `Future<void>` → `Future<Either<PostFailure, Unit>>`
  - [ ] `searchPosts()`: `Future<List<PostDisplay>>` → `Future<Either<PostFailure, List<PostDisplay>>>`
  - [ ] `getRecommendedPosts()`: Either 래핑
  - [ ] `getPostsByIds()`: Either 래핑
- [ ] Stream 메서드는 변경 없음 확인
- [ ] 주석 업데이트 (Either 패턴 설명)

**Before (현재)**:
```dart
// lib/features/post/domain/repositories/i_post_display_repository_v2.dart

abstract class IPostDisplayRepositoryV2 {
  // Streams (변경 없음)
  Stream<List<PostDisplay>> queryPosts({...});
  Stream<PostDisplay?> streamPost(String postId);

  // ❌ Future (throw Exception)
  Future<PostDisplay?> getPost(String postId);
  Future<void> incrementViewCount(String postId);
  Future<List<PostDisplay>> searchPosts({
    required String query,
    int limit = 20,
  });
  Future<List<PostDisplay>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  });
  Future<List<PostDisplay>> getPostsByIds(List<String> postIds);
}
```

**After (목표)**:
```dart
// lib/features/post/domain/repositories/i_post_display_repository_v2.dart

import 'package:fpdart/fpdart.dart';

import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// Repository interface for Post display operations (V2 - Clean Architecture)
///
/// **Error Handling Pattern**:
/// - Stream methods: 에러는 Stream.error()로 전달
/// - Future methods: Either<PostFailure, T> 반환
abstract class IPostDisplayRepositoryV2 {
  // ========== Streams (변경 없음) ==========

  /// 게시물 목록 스트림
  ///
  /// **에러 처리**: Stream.error()로 에러 emit
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// 단일 게시물 스트림
  ///
  /// **에러 처리**: Stream.error()로 에러 emit
  Stream<PostDisplay?> streamPost(String postId);

  /// 트렌딩 게시물 스트림
  Stream<List<PostDisplay>> getTrendingPosts({int limit = 20});

  /// 사용자 게시물 스트림
  Stream<List<PostDisplay>> getUserPosts({
    required String userId,
    int limit = -1,
  });

  /// 카테고리별 게시물 스트림
  Stream<List<PostDisplay>> getPostsByCategory({
    required String category,
    int limit = -1,
  });

  /// 활성 투표 게시물 스트림
  Stream<List<PostDisplay>> getActiveVotingPosts({int limit = -1});

  /// 완료된 투표 게시물 스트림
  Stream<List<PostDisplay>> getCompletedVotingPosts({int limit = -1});

  /// 인기 게시물 스트림
  Stream<List<PostDisplay>> getPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  });

  /// 페이지네이션 지원 - 특정 문서 이후 게시물
  Stream<List<PostDisplay>> getPostsAfter({
    required String lastPostId,
    int limit = 20,
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
  });

  /// 복잡한 필터로 게시물 조회
  Stream<List<PostDisplay>> getPostsWithFilters({
    String? userId,
    String? status,
    bool? isAnonymous,
    DateTime? createdAfter,
    DateTime? createdBefore,
    int limit = 20,
  });

  // ========== Futures (Either 래핑) ==========

  /// 단일 게시물 조회
  ///
  /// **성공**: PostDisplay 반환
  /// **실패**:
  /// - PostFailure.postNotFound: 게시물 없음
  /// - PostFailure.networkError: 네트워크 오류
  /// - PostFailure.unexpected: 기타 오류
  Future<Either<PostFailure, PostDisplay>> getPost(String postId);

  /// 조회수 증가
  ///
  /// **성공**: Unit 반환
  /// **실패**:
  /// - PostFailure.postNotFound: 게시물 없음
  /// - PostFailure.updateFailed: 업데이트 실패
  Future<Either<PostFailure, Unit>> incrementViewCount(String postId);

  /// 게시물 검색
  ///
  /// **성공**: 검색 결과 List 반환
  /// **실패**:
  /// - PostFailure.searchFailed: 검색 오류 (Algolia)
  /// - PostFailure.networkError: 네트워크 오류
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  });

  /// 추천 게시물 조회
  ///
  /// **성공**: 추천 게시물 List 반환
  /// **실패**:
  /// - PostFailure.userNotFound: 사용자 없음
  /// - PostFailure.queryFailed: 쿼리 실패
  Future<Either<PostFailure, List<PostDisplay>>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  });

  /// 여러 게시물 일괄 조회
  ///
  /// **성공**: PostDisplay List 반환
  /// **실패**:
  /// - PostFailure.queryFailed: 일부 게시물 조회 실패
  /// - PostFailure.networkError: 네트워크 오류
  Future<Either<PostFailure, List<PostDisplay>>> getPostsByIds(
    List<String> postIds,
  );
}
```

**변경 요약**:
- ✅ Stream 메서드: 변경 없음 (9개)
- ✅ Future 메서드: Either 래핑 (5개)
- ✅ 주석: 성공/실패 케이스 명시

---

### Step 3: Repository 구현체 업데이트

**파일 경로**: `lib/features/post/data/repositories/post_display_repository_v2_impl.dart`

**작업 내용**:
1. Either 래핑 로직 추가 (Future 메서드만)
2. Firebase Exception 매핑 Helper 생성
3. try-catch 블록 추가

**작업 시간**: 2-3시간

**체크리스트**:
- [ ] `_mapFirebaseException()` Helper 메서드 추가
- [ ] `getPost()` Either 래핑
- [ ] `incrementViewCount()` Either 래핑 (TODO 구현 필요 확인)
- [ ] `searchPosts()` Either 래핑 (TODO 구현 필요 확인)
- [ ] `getRecommendedPosts()` Either 래핑 (TODO 구현 필요 확인)
- [ ] `getPostsByIds()` Either 래핑 (TODO 구현 필요 확인)
- [ ] Stream 메서드는 변경 없음 확인

**Before (현재 - 일부만 표시)**:
```dart
// lib/features/post/data/repositories/post_display_repository_v2_impl.dart

class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;

  // ❌ throw Exception
  @override
  Future<PostDisplay?> getPost(String postId) async {
    final data = await _dataSource.getPost(postId);
    if (data == null) return null;

    final id = data['id'] as String;
    final dto = PostDisplayDto.fromFirestore(data, id);
    return PostDisplayMapper.toDomain(dto);
  }

  // ❌ TODO: 구현 필요
  @override
  Future<void> incrementViewCount(String postId) async {
    throw UnimplementedError('incrementViewCount not implemented');
  }

  // ❌ TODO: 구현 필요
  @override
  Future<List<PostDisplay>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    throw UnimplementedError('searchPosts not implemented');
  }
}
```

**After (목표)**:
```dart
// lib/features/post/data/repositories/post_display_repository_v2_impl.dart

import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/post_display.dart';
import '../../domain/repositories/i_post_display_repository_v2.dart';
import '../../domain/failures/post_failure.dart';
import '../datasources/interfaces/i_post_display_datasource.dart';
import '../dto/post_display_dto.dart';
import '../mappers/post_display_mapper.dart';

class PostDisplayRepositoryV2Impl implements IPostDisplayRepositoryV2 {
  final IPostDisplayDataSource _dataSource;

  PostDisplayRepositoryV2Impl({
    required IPostDisplayDataSource dataSource,
  }) : _dataSource = dataSource;

  // ========== Streams (변경 없음) ==========

  @override
  Stream<List<PostDisplay>> queryPosts({
    Map<String, dynamic> Function(Map<String, dynamic>)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _dataSource.queryPosts(
      queryBuilder: queryBuilder ?? (params) => params,
      limit: singleRecord ? 1 : limit > 0 ? limit : null,
    ).map((dataList) {
      return dataList.map((data) {
        final id = data['id'] as String;
        final dto = PostDisplayDto.fromFirestore(data, id);
        return PostDisplayMapper.toDomain(dto);
      }).toList();
    });
  }

  // ... 기타 Stream 메서드들 (변경 없음)

  // ========== Futures (Either 래핑) ==========

  /// 단일 게시물 조회 (Either 패턴)
  @override
  Future<Either<PostFailure, PostDisplay>> getPost(String postId) async {
    try {
      final data = await _dataSource.getPost(postId);

      if (data == null) {
        return left(PostFailure.postNotFound(postId: postId));
      }

      final id = data['id'] as String;
      final dto = PostDisplayDto.fromFirestore(data, id);
      final post = PostDisplayMapper.toDomain(dto);

      return right(post);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to get post: $postId',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 조회수 증가 (Either 패턴)
  ///
  /// **TODO**: Firestore 업데이트 로직 구현 필요
  @override
  Future<Either<PostFailure, Unit>> incrementViewCount(String postId) async {
    try {
      // TODO: Firestore에 조회수 증가 구현
      // await FirebaseFirestore.instance
      //     .collection('posts')
      //     .doc(postId)
      //     .update({'viewCount': FieldValue.increment(1)});

      throw UnimplementedError('incrementViewCount not implemented');

      // return right(unit);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e, postId: postId));
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to increment view count: $postId',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 게시물 검색 (Either 패턴)
  ///
  /// **TODO**: Algolia 검색 로직 구현 필요
  @override
  Future<Either<PostFailure, List<PostDisplay>>> searchPosts({
    required String query,
    int limit = 20,
  }) async {
    try {
      // TODO: Algolia 검색 구현
      // final hits = await algoliaIndex.search(query, limit: limit);
      // final posts = hits.map((hit) => PostDisplay.fromAlgolia(hit)).toList();

      throw UnimplementedError('searchPosts not implemented');

      // return right(posts);
    } on AlgoliaException catch (e) {
      return left(PostFailure.searchFailed(query: query));
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to search posts: $query',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 추천 게시물 조회 (Either 패턴)
  ///
  /// **TODO**: 추천 알고리즘 구현 필요
  @override
  Future<Either<PostFailure, List<PostDisplay>>> getRecommendedPosts({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // TODO: 추천 알고리즘 구현 (사용자 관심사, 최근 활동 기반)
      throw UnimplementedError('getRecommendedPosts not implemented');

      // return right(recommendedPosts);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to get recommended posts for user: $userId',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  /// 여러 게시물 일괄 조회 (Either 패턴)
  ///
  /// **TODO**: 배치 조회 구현 필요
  @override
  Future<Either<PostFailure, List<PostDisplay>>> getPostsByIds(
    List<String> postIds,
  ) async {
    try {
      // TODO: Firestore 배치 조회 구현 (최대 10개씩)
      // final posts = <PostDisplay>[];
      // for (final chunk in _chunk(postIds, 10)) {
      //   final snapshot = await FirebaseFirestore.instance
      //       .collection('posts')
      //       .where(FieldPath.documentId, whereIn: chunk)
      //       .get();
      //   posts.addAll(snapshot.docs.map(...));
      // }

      throw UnimplementedError('getPostsByIds not implemented');

      // return right(posts);
    } on FirebaseException catch (e) {
      return left(_mapFirebaseException(e));
    } catch (e, stackTrace) {
      return left(PostFailure.unexpected(
        message: 'Failed to get posts by IDs',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // ========== Helper Methods ==========

  /// Firebase Exception을 PostFailure로 매핑
  ///
  /// **지원하는 Firebase 에러 코드**:
  /// - permission-denied → insufficientPermissions
  /// - not-found → postNotFound
  /// - unavailable → networkError
  /// - unauthenticated → unauthorized
  /// - 기타 → serverError
  PostFailure _mapFirebaseException(
    FirebaseException e, {
    String? postId,
  }) {
    switch (e.code) {
      case 'permission-denied':
        return const PostFailure.insufficientPermissions();
      case 'not-found':
        return PostFailure.postNotFound(postId: postId ?? 'unknown');
      case 'unavailable':
        return const PostFailure.networkError();
      case 'unauthenticated':
        return const PostFailure.unauthorized();
      default:
        return PostFailure.serverError(message: e.message);
    }
  }
}
```

**변경 요약**:
- ✅ `getPost()`: Either 래핑 완료
- ⚠️ `incrementViewCount()`: Either 래핑 + TODO 마커
- ⚠️ `searchPosts()`: Either 래핑 + TODO 마커
- ⚠️ `getRecommendedPosts()`: Either 래핑 + TODO 마커
- ⚠️ `getPostsByIds()`: Either 래핑 + TODO 마커
- ✅ `_mapFirebaseException()`: Firebase 에러 매핑 Helper

---

### Step 4: UseCases 업데이트 (8개)

**파일 경로**: `lib/features/post/domain/usecases/` (8개 파일)

**작업 내용**:
1. `Result<T>` → `Either<PostFailure, T>` 전환
2. `Result.success()` → `right()`
3. `Result.failure()` → `left()`
4. try-catch → fold() 패턴

**작업 시간**: 3-4시간

**UseCase 목록** (추정):
1. `get_feed_usecase.dart` - 피드 조회
2. `get_post_usecase.dart` - 단일 게시물 조회
3. `search_posts_usecase.dart` - 게시물 검색
4. `get_trending_posts_usecase.dart` - 트렌딩 게시물
5. `get_user_posts_usecase.dart` - 사용자 게시물
6. `get_recommended_posts_usecase.dart` - 추천 게시물
7. `increment_view_count_usecase.dart` - 조회수 증가
8. `get_posts_by_category_usecase.dart` - 카테고리별 조회

**Before (GetFeedUseCase 예시)**:
```dart
// lib/features/post/domain/usecases/get_feed_usecase.dart

import '/core/types/result.dart';
import '/core/errors/failures.dart';

class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetFeedUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// ❌ Before: Result<T>
  Future<Result<FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      Stream<List<PostDisplay>> stream;

      switch (sortBy) {
        case FeedSortBy.latest:
          stream = _postRepository.queryPosts(
            queryBuilder: (params) => {
              ...params,
              'orderBy': 'createdAt',
              'descending': true,
            },
            limit: limit,
          );
          break;
        case FeedSortBy.popular:
          stream = _postRepository.getPopularPosts(limit: limit);
          break;
        // ... 기타 케이스
      }

      final posts = await stream.first;

      return Result.success(FeedResult(
        posts: posts,
        hasMore: posts.length == limit,
        lastDocumentId: posts.isNotEmpty ? posts.last.id : null,
      ));
    } catch (e, stackTrace) {
      return Result.failure(Failure(
        message: 'Failed to load feed: ${e.toString()}',
        error: e,
      ));
    }
  }
}
```

**After (GetFeedUseCase 예시)**:
```dart
// lib/features/post/domain/usecases/get_feed_usecase.dart

import 'package:fpdart/fpdart.dart';

import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for getting feed posts
/// 피드 게시물을 가져오기 위한 UseCase
class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetFeedUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// ✅ After: Either<PostFailure, T>
  ///
  /// **성공**: FeedResult 반환
  /// **실패**:
  /// - PostFailure.networkError: 네트워크 오류
  /// - PostFailure.timeout: 요청 시간 초과
  /// - PostFailure.queryFailed: 쿼리 실행 실패
  /// - PostFailure.unexpected: 기타 오류
  Future<Either<PostFailure, FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      Stream<List<PostDisplay>> stream;

      // Repository 메서드 호출 (Stream 기반)
      if (lastDocumentId == null && filter == null) {
        switch (sortBy) {
          case FeedSortBy.latest:
            stream = _postRepository.queryPosts(
              queryBuilder: (params) => {
                ...params,
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
                ...params,
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
      } else {
        // 페이지네이션 또는 필터 적용
        if (filter != null) {
          stream = _postRepository.getPostsWithFilters(
            userId: filter.userId,
            status: filter.status,
            isAnonymous: filter.isAnonymous,
            createdAfter: filter.startDate,
            createdBefore: filter.endDate,
            limit: limit,
          );
        } else if (lastDocumentId != null) {
          // QueryBuilder 생성
          Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder = (params) {
            final queryParams = <String, dynamic>{...params};

            switch (sortBy) {
              case FeedSortBy.latest:
                queryParams['orderBy'] = 'createdAt';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.popular:
                queryParams['orderBy'] = 'likecount';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.mostVoted:
                queryParams['orderBy'] = 'votesA';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.trending:
                queryParams['orderBy'] = 'commentcount';
                queryParams['descending'] = true;
                break;
            }

            return queryParams;
          };

          stream = _postRepository.getPostsAfter(
            lastPostId: lastDocumentId,
            limit: limit,
            queryBuilder: queryBuilder,
          );
        } else {
          // Fallback
          stream = _postRepository.queryPosts(limit: limit);
        }
      }

      // Stream을 List로 변환
      final posts = await stream.first;

      // ✅ Success: right()로 래핑
      return right(FeedResult(
        posts: posts,
        hasMore: posts.length == limit,
        lastDocumentId: posts.isNotEmpty ? posts.last.id : null,
      ));
    } on FirebaseException catch (e) {
      // Firebase 에러를 PostFailure로 변환
      return left(_mapFirebaseException(e));
    } on TimeoutException {
      return left(const PostFailure.timeout());
    } catch (e, stackTrace) {
      // ✅ Failure: left()로 래핑
      return left(PostFailure.unexpected(
        message: 'Failed to load feed',
        error: e,
        stackTrace: stackTrace,
      ));
    }
  }

  // ========== Helper Methods ==========

  PostFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const PostFailure.insufficientPermissions();
      case 'unavailable':
        return const PostFailure.networkError();
      case 'unauthenticated':
        return const PostFailure.unauthorized();
      default:
        return PostFailure.queryFailed(reason: e.message);
    }
  }
}

/// Feed 정렬 옵션
enum FeedSortBy {
  latest,    // 최신순
  popular,   // 인기순 (좋아요)
  mostVoted, // 투표 많은 순
  trending,  // 트렌딩 (댓글+좋아요)
}

/// Feed 필터
class FeedFilter {
  final String? userId;
  final String? status;
  final bool? isAnonymous;
  final DateTime? startDate;
  final DateTime? endDate;

  FeedFilter({
    this.userId,
    this.status,
    this.isAnonymous,
    this.startDate,
    this.endDate,
  });
}

/// Feed 결과
class FeedResult {
  final List<PostDisplay> posts;
  final bool hasMore;
  final String? lastDocumentId;

  FeedResult({
    required this.posts,
    required this.hasMore,
    this.lastDocumentId,
  });
}
```

**변경 요약** (GetFeedUseCase):
- ✅ `Result<FeedResult>` → `Either<PostFailure, FeedResult>`
- ✅ `Result.success()` → `right()`
- ✅ `Result.failure()` → `left()`
- ✅ Firebase Exception 매핑 추가
- ✅ 구체적인 PostFailure 타입 사용

**나머지 7개 UseCases도 동일한 패턴 적용**

---

### Step 5: Providers 업데이트

**파일 경로**: `lib/features/post/presentation/providers/` (3개 파일 추정)

**작업 내용**:
1. `result.isSuccess` → `result.fold()` 패턴
2. `result.data!` → fold의 right 파라미터 (null-safe)
3. `result.error!.message` → fold의 left 파라미터 (타입 안전)

**작업 시간**: 2-3시간

**Provider 목록** (추정):
1. `feed_provider.dart` - 피드 상태 관리
2. `post_detail_provider.dart` - 게시물 상세 상태
3. `search_provider.dart` - 검색 상태

**Before (FeedProvider 예시)**:
```dart
// lib/features/post/presentation/providers/feed_provider.dart

import 'package:flutter/foundation.dart';

import '/core/types/result.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/models/post_display.dart';

class FeedProvider extends ChangeNotifier {
  final GetFeedUseCase _getFeedUseCase;

  FeedProvider({required GetFeedUseCase getFeedUseCase})
      : _getFeedUseCase = getFeedUseCase;

  List<PostDisplay> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  String? _lastDocumentId;

  List<PostDisplay> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// ❌ Before: isSuccess 체크
  Future<void> loadFeed({
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getFeedUseCase.execute(
      limit: 20,
      sortBy: sortBy,
      filter: filter,
    );

    if (result.isSuccess) {
      _posts = result.data!.posts;  // ❌ null 체크 필요
      _hasMore = result.data!.hasMore;
      _lastDocumentId = result.data!.lastDocumentId;
      _errorMessage = null;
    } else {
      _errorMessage = result.error!.message;  // ❌ Generic 메시지
    }

    _isLoading = false;
    notifyListeners();
  }

  /// ❌ Before: isSuccess 체크 (페이지네이션)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _getFeedUseCase.execute(
      limit: 20,
      lastDocumentId: _lastDocumentId,
    );

    if (result.isSuccess) {
      _posts.addAll(result.data!.posts);
      _hasMore = result.data!.hasMore;
      _lastDocumentId = result.data!.lastDocumentId;
    } else {
      _errorMessage = result.error!.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

**After (FeedProvider 예시)**:
```dart
// lib/features/post/presentation/providers/feed_provider.dart

import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/models/post_display.dart';
import '../../domain/failures/post_failure.dart';

class FeedProvider extends ChangeNotifier {
  final GetFeedUseCase _getFeedUseCase;

  FeedProvider({required GetFeedUseCase getFeedUseCase})
      : _getFeedUseCase = getFeedUseCase;

  List<PostDisplay> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  String? _lastDocumentId;

  List<PostDisplay> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// ✅ After: fold() 패턴
  ///
  /// **에러 처리**: PostFailure.when()으로 구체적인 메시지 생성
  Future<void> loadFeed({
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getFeedUseCase.execute(
      limit: 20,
      sortBy: sortBy,
      filter: filter,
    );

    // ✅ fold() 패턴 사용
    result.fold(
      (failure) {
        // Left: 실패 처리 (타입 안전)
        _errorMessage = _mapFailureToMessage(failure);

        // 에러 로깅 (개발 모드)
        if (kDebugMode) {
          print('Feed load failed: ${failure.toString()}');
        }
      },
      (feedResult) {
        // Right: 성공 처리 (null-safe)
        _posts = feedResult.posts;
        _hasMore = feedResult.hasMore;
        _lastDocumentId = feedResult.lastDocumentId;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// ✅ After: fold() 패턴 (페이지네이션)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    final result = await _getFeedUseCase.execute(
      limit: 20,
      lastDocumentId: _lastDocumentId,
    );

    result.fold(
      (failure) {
        _errorMessage = _mapFailureToMessage(failure);
      },
      (feedResult) {
        _posts.addAll(feedResult.posts);
        _hasMore = feedResult.hasMore;
        _lastDocumentId = feedResult.lastDocumentId;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ========== Helper Methods ==========

  /// PostFailure를 사용자 친화적 메시지로 변환
  ///
  /// **패턴**: PostFailure.when()으로 각 타입별 메시지 생성
  String _mapFailureToMessage(PostFailure failure) {
    return failure.when(
      // Network & Server Errors
      networkError: () => '네트워크 연결을 확인해주세요',
      serverError: (message) => '서버 오류가 발생했습니다${message != null ? ': $message' : ''}',
      timeout: () => '요청 시간이 초과되었습니다\n다시 시도해주세요',

      // Permission & Auth Errors
      insufficientPermissions: () => '접근 권한이 부족합니다',
      unauthorized: () => '로그인이 필요합니다',

      // Resource Errors
      postNotFound: (postId) => '게시물을 찾을 수 없습니다',
      userNotFound: (userId) => '사용자를 찾을 수 없습니다',

      // Validation Errors
      invalidInput: (field) => '$field 입력값이 유효하지 않습니다',
      contentTooLong: (maxLength) => '내용이 너무 깁니다 (최대 $maxLength자)',

      // Operation Errors
      createFailed: (reason) => '게시물 작성 실패${reason != null ? ': $reason' : ''}',
      updateFailed: (reason) => '게시물 수정 실패${reason != null ? ': $reason' : ''}',
      deleteFailed: (reason) => '게시물 삭제 실패${reason != null ? ': $reason' : ''}',

      // Search & Query Errors
      searchFailed: (query) => '검색 실패${query != null ? ': $query' : ''}',
      queryFailed: (reason) => '게시물 조회 실패${reason != null ? ': $reason' : ''}',

      // Unexpected
      unexpected: (message, error, stackTrace) => message ?? '알 수 없는 오류가 발생했습니다',
    );
  }
}
```

**변경 요약** (FeedProvider):
- ✅ `result.isSuccess` → `result.fold()`
- ✅ `result.data!` → fold의 right 파라미터 (null-safe)
- ✅ `result.error!.message` → `_mapFailureToMessage()` (타입 안전)
- ✅ PostFailure.when()으로 15가지 에러 타입별 메시지

**나머지 2개 Providers도 동일한 패턴 적용**

---

## 🧪 테스트 전략

### 1. Unit Tests (PostFailure)

**파일**: `test/unit/failures/post_failure_test.dart` (신규)

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:versus_space/features/post/domain/failures/post_failure.dart';

void main() {
  group('PostFailure', () {
    test('should create NetworkError', () {
      const failure = PostFailure.networkError();
      expect(failure, isA<NetworkError>());
    });

    test('should create PostNotFound with postId', () {
      const failure = PostFailure.postNotFound(postId: 'post123');

      failure.when(
        postNotFound: (postId) {
          expect(postId, 'post123');
        },
        orElse: () => fail('Wrong failure type'),
      );
    });

    test('should create Unexpected with all fields', () {
      final failure = PostFailure.unexpected(
        message: 'Test error',
        error: Exception('Test'),
        stackTrace: StackTrace.current,
      );

      failure.when(
        unexpected: (message, error, stackTrace) {
          expect(message, 'Test error');
          expect(error, isA<Exception>());
          expect(stackTrace, isNotNull);
        },
        orElse: () => fail('Wrong failure type'),
      );
    });
  });
}
```

### 2. Unit Tests (UseCases)

**파일**: `test/unit/usecases/get_feed_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:versus_space/features/post/domain/usecases/get_feed_usecase.dart';
import 'package:versus_space/features/post/domain/repositories/i_post_display_repository_v2.dart';
import 'package:versus_space/features/post/domain/models/post_display.dart';
import 'package:versus_space/features/post/domain/failures/post_failure.dart';

class MockPostRepository extends Mock implements IPostDisplayRepositoryV2 {}

void main() {
  late GetFeedUseCase useCase;
  late MockPostRepository mockRepository;

  setUp(() {
    mockRepository = MockPostRepository();
    useCase = GetFeedUseCase(postRepository: mockRepository);
  });

  group('execute', () {
    final mockPosts = [
      PostDisplay(id: '1', createdAt: DateTime.now()),
      PostDisplay(id: '2', createdAt: DateTime.now()),
    ];

    test('should return FeedResult on success', () async {
      // Arrange
      when(() => mockRepository.queryPosts(
        queryBuilder: any(named: 'queryBuilder'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) => Stream.value(mockPosts));

      // Act
      final result = await useCase.execute(limit: 20);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should be success'),
        (feedResult) {
          expect(feedResult.posts, mockPosts);
          expect(feedResult.hasMore, false); // 2 < 20
          expect(feedResult.lastDocumentId, '2');
        },
      );
    });

    test('should return PostFailure.timeout on TimeoutException', () async {
      // Arrange
      when(() => mockRepository.queryPosts(
        queryBuilder: any(named: 'queryBuilder'),
        limit: any(named: 'limit'),
      )).thenAnswer((_) => Stream.error(TimeoutException('Timeout')));

      // Act
      final result = await useCase.execute(limit: 20);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<TimeoutError>());
        },
        (_) => fail('Should be failure'),
      );
    });
  });
}
```

### 3. Integration Tests (Repository)

**파일**: `test/integration/post_repository_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';

import 'package:versus_space/features/post/data/repositories/post_display_repository_v2_impl.dart';
import 'package:versus_space/features/post/domain/failures/post_failure.dart';

void main() {
  late PostDisplayRepositoryV2Impl repository;

  setUp(() {
    // Mock DataSource 주입
    repository = PostDisplayRepositoryV2Impl(dataSource: mockDataSource);
  });

  group('getPost', () {
    test('should return Right(PostDisplay) on success', () async {
      // Arrange
      when(() => mockDataSource.getPost('post123'))
          .thenAnswer((_) async => {'id': 'post123', ...});

      // Act
      final result = await repository.getPost('post123');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should be success'),
        (post) {
          expect(post.id, 'post123');
        },
      );
    });

    test('should return Left(PostNotFound) when post does not exist', () async {
      // Arrange
      when(() => mockDataSource.getPost('nonexistent'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getPost('nonexistent');

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<PostNotFound>());
        },
        (_) => fail('Should be failure'),
      );
    });
  });
}
```

---

## 🔄 롤백 계획

### 롤백 시나리오

**시나리오 1**: PostFailure 생성 중 문제 발견 (Step 1)
- **Action**: `post_failure.dart` 삭제
- **시간**: 5분
- **영향**: 없음

**시나리오 2**: Repository 전환 중 에러 (Step 2-3)
- **Action**: Git revert to Step 1 commit
- **시간**: 10-15분
- **영향**: PostFailure는 유지 (재시도 가능)

**시나리오 3**: 프로덕션 배포 후 치명적 버그 (Step 6 후)
- **Action**: Git revert to "Before Phase 1" commit
- **시간**: 30분-1시간
- **영향**: 전체 Phase 1 롤백

### 롤백 절차

#### Step 1-2 롤백 (PostFailure만 삭제):
```bash
# PostFailure 파일 삭제
rm lib/features/post/domain/failures/post_failure.dart
rm lib/features/post/domain/failures/post_failure.freezed.dart

# 빌드 확인
flutter analyze lib/features/post
```

#### Step 3-5 롤백 (Git revert):
```bash
# 마지막 정상 커밋 찾기
git log --oneline --grep="Phase 1" -10

# Phase 1 이전 커밋으로 revert
git revert <commit-hash>

# 빌드 확인
flutter pub get
flutter analyze lib/features/post
flutter test lib/features/post
```

#### Step 6 롤백 (전체 Phase 1 롤백):
```bash
# "Before Phase 1" 커밋으로 hard reset
git reset --hard <before-phase1-commit>

# 강제 푸시 (프로덕션에서만)
git push --force origin main

# 빌드 및 배포
flutter build apk --release
```

---

## ✅ 완료 체크리스트

### Phase 1 완료 기준

- [ ] **PostFailure 생성**
  - [ ] `post_failure.dart` 생성 (15개 타입)
  - [ ] Freezed 코드 생성 완료
  - [ ] `flutter analyze` 에러 0개

- [ ] **Repository 인터페이스 업데이트**
  - [ ] `fpdart` import 추가
  - [ ] Future 메서드 5개 Either 래핑
  - [ ] Stream 메서드 변경 없음 확인
  - [ ] 주석 업데이트 (성공/실패 케이스)

- [ ] **Repository 구현체 업데이트**
  - [ ] `_mapFirebaseException()` Helper 추가
  - [ ] `getPost()` Either 래핑
  - [ ] 나머지 4개 Future 메서드 Either 래핑
  - [ ] TODO 마커 추가 (미구현 메서드)

- [ ] **UseCases 업데이트 (8개)**
  - [ ] GetFeedUseCase Either 전환
  - [ ] 나머지 7개 UseCases Either 전환
  - [ ] Firebase Exception 매핑 추가

- [ ] **Providers 업데이트 (3개)**
  - [ ] FeedProvider fold() 패턴
  - [ ] `_mapFailureToMessage()` Helper 추가
  - [ ] 나머지 2개 Providers fold() 패턴

- [ ] **테스트**
  - [ ] PostFailure 단위 테스트 (10개)
  - [ ] GetFeedUseCase 단위 테스트 (5개)
  - [ ] Repository 통합 테스트 (3개)
  - [ ] 커버리지 80%+

- [ ] **빌드 및 검증**
  - [ ] `flutter pub get` 성공
  - [ ] `flutter analyze lib/features/post` 에러 0개
  - [ ] `flutter test lib/features/post` 통과
  - [ ] UI 에러 표시 확인 (사용자 메시지)

- [ ] **문서화**
  - [ ] CHANGELOG.md 업데이트
  - [ ] README.md에 Either 패턴 설명
  - [ ] Phase 2 준비 (Riverpod)

---

## 📊 마이그레이션 영향 분석

### 코드 변경량

| 파일 | Before (줄) | After (줄) | 변경률 |
|------|------------|-----------|--------|
| post_failure.dart | 0 | 150 | +150줄 (신규) |
| i_post_display_repository_v2.dart | 82 | 112 | +37% |
| post_display_repository_v2_impl.dart | ~200 | ~280 | +40% |
| get_feed_usecase.dart | ~120 | ~150 | +25% |
| feed_provider.dart | ~150 | ~180 | +20% |
| **합계** | **~550줄** | **~870줄** | **+58%** |

**Note**: 코드 증가는 타입 안전성과 명시적 에러 처리로 인한 것

### 에러 처리 개선

```
Before (Result<T>):
- Generic Failure: 1개 타입
- 에러 메시지: "Failed to load feed"
- 타입 체크: 런타임 (isSuccess)

After (Either<PostFailure, T>):
- Specific Failures: 15개 타입
- 에러 메시지: 각 타입별 맞춤 메시지 (15개)
- 타입 체크: 컴파일 타임 (fold())

개선율: 1500% (1개 → 15개 구체적 타입)
```

### 사용자 경험 개선

| 항목 | Before | After | 변화 |
|------|--------|-------|------|
| **에러 메시지 명확성** | ⚠️ Generic | ✅ 구체적 | **15배 ↑** |
| **에러 복구 가이드** | ❌ 없음 | ✅ 재시도/로그인 등 | **100% ↑** |
| **타입 안전성** | ⚠️ 런타임 | ✅ 컴파일 타임 | **대폭 개선** |
| **함수형 패턴** | ❌ if-else | ✅ fold() | **표준화** |

---

## 🎓 추가 학습 자료

### Either Pattern 심화

#### 1. fold() vs map()

```dart
// ✅ fold(): 두 경로 모두 처리
result.fold(
  (failure) => print('Error: $failure'),
  (success) => print('Success: $success'),
);

// ✅ map(): Success 경로만 처리
final newResult = result.map((success) => success.copyWith(...));

// ✅ flatMap(): Success 경로에서 새 Either 반환
final newResult = result.flatMap((success) {
  return _anotherOperation(success);
});
```

#### 2. Either Chaining

```dart
// ✅ 여러 Either 작업 체이닝
Future<Either<PostFailure, String>> getUserPostTitle(String userId) async {
  final userResult = await getUserPosts(userId: userId);

  return userResult.flatMap((posts) {
    if (posts.isEmpty) {
      return left(PostFailure.postNotFound(postId: 'none'));
    }

    return right(posts.first.title);
  });
}
```

### Auth/Chat Features 참조

- **Auth PHASE_2_EITHER_PATTERN.md**: Either 패턴 상세 가이드
- **Chat PHASE_1_EITHER_PATTERN.md**: 실제 마이그레이션 예시
- **Profile Feature**: Either with Riverpod 통합 패턴

---

## 📌 다음 단계: Phase 2

Phase 1 완료 후, **Phase 2: Riverpod 2.x Migration**으로 진행:

```
Provider + ChangeNotifier → StreamProvider.autoDispose
```

**예상 효과**:
- 코드 감소: 323줄 → ~180줄 (44% ↓)
- 메모리 누수 방지: autoDispose 자동 해제
- 일관성: Auth/Chat과 동일한 상태 관리

---

**문서 버전**: v1.0.0
**작성일**: 2025-01-31
**작성자**: Claude Code (AI Assistant)
**검토**: 필요 (사용자 승인 대기)
