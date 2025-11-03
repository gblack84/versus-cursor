# Creation Feature - Phase 4: Idempotency Pattern (Part 1/2)

> **문서 버전**: 1.0.0
> **작성일**: 2025-11-03
> **대상 Feature**: Creation Feature
> **Phase**: 4 - Idempotency Pattern Integration
> **Part**: 1/2 (섹션 1-6)

---

## 📋 목차 (Part 1)

- [개요](#-개요)
- [Phase 1,2,3 종속성 확인](#-phase-123-종속성-확인)
- [현재 상태 분석](#-현재-상태-분석)
- [마이그레이션 목표](#-마이그레이션-목표)
- [단계별 마이그레이션 가이드](#-단계별-마이그레이션-가이드)
- [테스트 전략](#-테스트-전략)
- [롤백 계획](#-롤백-계획)

**Part 2 문서**: [PHASE_4_2.md](./PHASE_4_2.md) - 체크리스트, 영향 분석, 학습 자료, 다음 단계

---

## 📋 개요

### Phase 4의 목적

**Idempotency Pattern**을 적용하여 Creation Feature의 중복 작업으로 인한 데이터 손상, 비용 낭비, 사용자 경험 저하를 방지합니다.

### 핵심 문제

#### 1. **게시물 중복 생성** (Critical)
```
사용자 시나리오:
1. 사용자가 "게시물 작성 완료" 버튼 클릭
2. 네트워크 타임아웃 발생 (5초 경과)
3. 사용자가 재시도 버튼 클릭
4. 결과: 동일한 게시물이 2개 생성됨 ❌

영향:
- 사용자 불만 (중복 게시물 삭제 필요)
- Firestore 비용 2배 증가
- 피드 품질 저하
```

#### 2. **미디어 중복 업로드** (Critical)
```
사용자 시나리오:
1. 사용자가 5MB 이미지 3개 업로드
2. 네트워크 불안정으로 2번째 이미지 업로드 실패
3. 자동 재시도로 전체 이미지 재업로드
4. 결과: 1번째 이미지가 중복 저장됨 (총 4개) ❌

영향:
- Firebase Storage 비용 증가
- UI에 동일 이미지 여러 개 표시
- 사용자 혼란
```

#### 3. **AI API 중복 호출** (Important)
```
시스템 시나리오:
1. "제목 생성" AI 요청 전송 (Gemini API)
2. 응답 대기 중 타임아웃 (30초)
3. 클라이언트 자동 재시도
4. 결과: 동일한 프롬프트로 2번 API 호출 ❌

영향:
- API 비용 2배 증가 ($0.10/call → $0.20)
- 월 비용: $70 → $140 (100% 증가)
- 응답 속도 저하 (불필요한 대기)
```

#### 4. **Draft 중복 저장** (Important)
```
시스템 시나리오:
1. Draft 자동 저장 (500ms debounce)
2. Firestore write 진행 중 네트워크 끊김
3. 재연결 후 동일 Draft 재저장
4. 결과: 동일 Draft가 2번 저장됨 ❌

영향:
- Firestore write 비용 2배
- 저장 시간 증가
```

### Idempotency란?

> **멱등성(Idempotency)**: 동일한 작업을 여러 번 수행해도 결과가 한 번 수행한 것과 같은 성질

```dart
// ❌ Non-Idempotent (비멱등)
Future<void> createPost() async {
  final docRef = firestore.collection('posts').doc();
  await docRef.set({...});  // 호출할 때마다 새로운 문서 생성
}

// ✅ Idempotent (멱등)
Future<void> createPost({required String eventId}) async {
  // eventId로 중복 체크
  final existing = await checkEventId(eventId);
  if (existing != null) return existing;  // 이미 실행됨 → 스킵

  // 첫 실행만 작업 수행
  final docRef = firestore.collection('posts').doc();
  await docRef.set({...});
  await saveEventId(eventId, docRef.id);  // 실행 기록 저장
}
```

### Phase 4의 범위

#### 적용 대상 (6개 메서드)

| Priority | 메서드 | 영향 | Firestore 컬렉션 |
|----------|--------|------|-----------------|
| **Critical** | `createPost()` | 중복 게시물 생성 | `posts` |
| **Critical** | `uploadPostMedia()` | 중복 미디어 업로드 | `posts` |
| **Important** | AI API 호출 | 중복 API 비용 | - (외부 API) |
| **Important** | `saveDraftPost()` | 중복 Draft 저장 | `posts` |
| **Optional** | `updatePost()` | 동시 업데이트 충돌 | `posts` |
| **Optional** | `deletePost()` | 중복 삭제 시도 | `posts` |

#### 제외 대상

- **조회 작업** (Query, Get): 이미 멱등성 보장됨
- **캐시 작업** (Phase 3): Cache-First 패턴으로 중복 방지됨
- **검증 작업** (Validation): 부수 효과 없음

### 기대 효과

#### 기능적 개선
- ✅ **데이터 일관성**: 100% 보장 (중복 생성/삭제 방지)
- ✅ **사용자 신뢰**: 네트워크 불안정 시에도 안정적 동작
- ✅ **운영 효율**: 중복 데이터 수동 삭제 작업 제거

#### 비용 절감
- ✅ **Firestore 비용**: 40-60% 절감 (재시도 시나리오)
- ✅ **Storage 비용**: 미디어 중복 업로드 방지
- ✅ **AI API 비용**: +30% 절감 (Phase 3의 70%에 추가)

#### 성능 영향
- ⚠️ **추가 Latency**: +10-20ms (eventId 체크)
- ✅ **재시도 속도**: 50-100ms → <10ms (중복 스킵)
- ✅ **전체 성능**: 재시도 빈도 고려 시 **순증**

---

## 📚 Phase 1,2,3 종속성 확인

Phase 4는 Phase 1,2,3이 완료된 상태를 전제로 합니다.

### ✅ Phase 1 완료 상태 (전제 조건)

**문서**: [PHASE_1_FREEZED_MIGRATION.md](./PHASE_1_FREEZED_MIGRATION.md)

**완료 항목**:
- ✅ **MediaInfo Freezed conversion**: 141줄 → 20줄 (85% 감소)
- ✅ **TargetAudience Domain-Data 의존성 제거**
- ✅ **PostCreation Freezed 적용**: `toJson()`, `fromJson()` 자동 생성

**Phase 4 필요성**:
```dart
// Phase 1에서 생성된 toJson()이 Idempotency 구현에 필수
final PostCreation post = PostCreation(...);
final json = post.toJson();  // ✅ Freezed auto-generated

// Idempotency 기록 저장 시 사용
await firestore.collection('idempotency_records').doc(eventId).set({
  'entityData': json,  // PostCreation 직렬화
});
```

### ✅ Phase 2 완료 상태 (전제 조건)

**문서**: [PHASE_2_2_MIGRATION_STEPS.md](./PHASE_2_2_MIGRATION_STEPS.md)

**완료 항목**:
- ✅ **Either Pattern 적용**: `Result<T>` → `Either<Failure, T>`
- ✅ **Riverpod 2.x 마이그레이션**: `Provider` → `@riverpod`
- ✅ **Failure 체계 정리**: Sealed class로 에러 타입화

**Phase 4 필요성**:
```dart
// Either Pattern으로 Idempotency 실패 처리
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  required String eventId,
}) async {
  return _idempotencyService.executeIdempotent<String>(
    // ...
  ).fold(
    (failure) => left(CreationFailure.idempotencyViolation(failure)),  // ✅ Either
    (postId) => right(postId),
  );
}
```

### ✅ Phase 3 완료 상태 (전제 조건)

**문서**: [PHASE_3_CACHE_INTEGRATION.md](./PHASE_3_CACHE_INTEGRATION.md)

**완료 항목**:
- ✅ **UnifiedCacheService 통합**: 3-Layer 캐싱 (Memory → Hive → Firestore)
- ✅ **Draft 자동 저장**: Write-Through 패턴
- ✅ **AI 결과 캐싱**: 70% 비용 절감

**Phase 4 연계**:
```dart
// Phase 3 캐싱 + Phase 4 Idempotency 결합
Future<Either<CreationFailure, String>> generateTitle({
  required String description,
  required String eventId,
}) async {
  // Phase 3: 캐시 우선 조회
  final cached = await _cacheService.getAIGenerationResult(description);
  if (cached != null) return right(cached);

  // Phase 4: Idempotency로 동시 요청 중복 방지
  return _idempotencyService.executeIdempotent<String>(
    entityType: 'ai_generation',
    entityId: md5(description),
    userId: currentUserId,
    eventId: eventId,
    operation: (_) async {
      final result = await _geminiService.generateTitle(description);
      await _cacheService.setAIGenerationResult(description, result);  // Phase 3
      return result;
    },
  );
}
```

### Phase 4 전제 조건 체크리스트

실행 전 반드시 확인:

- [ ] **Phase 1**: `PostCreation.toJson()`, `fromJson()` 존재 확인
- [ ] **Phase 2**: Repository 메서드가 `Either<Failure, T>` 반환
- [ ] **Phase 3**: `UnifiedCacheService` 인스턴스 사용 가능
- [ ] **코드 생성**: `dart run build_runner build` 성공
- [ ] **테스트 통과**: `flutter test` 모든 테스트 통과

---

## 🔍 현재 상태 분석

### Before: Phase 3 완료 상태

#### 1. Repository 인터페이스 (Phase 2 상태)

**파일**: `lib/features/creation/domain/repositories/i_post_creation_repository_v2.dart`

```dart
/// PostCreation Repository Interface (Phase 2 완료)
///
/// **Phase 2**: Either Pattern 적용
/// **Phase 3**: 캐싱 통합 완료
/// **Phase 4 대상**: ❌ eventId 파라미터 없음
abstract class IPostCreationRepositoryV2 {
  // ❌ Phase 4 Before: eventId 없음
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  });

  // ❌ Phase 4 Before: eventId 없음
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  });

  // ❌ Phase 4 Before: eventId 없음
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
  });

  // 조회 작업 (Phase 4 제외 - 이미 멱등)
  Future<Either<CreationFailure, PostCreation?>> getPost(String postId);
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId);
}
```

**문제점**:
- 네트워크 재시도 시 중복 작업 발생
- 동일 요청 식별 불가 (eventId 없음)
- 트랜잭션 보장 없음

#### 2. Repository 구현 (Phase 3 상태)

**파일**: `lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart:56-75`

```dart
/// PostCreationRepositoryV2 구현 (Phase 3 완료)
///
/// **Phase 3**: CreationFirestoreMapper, UnifiedCacheService 사용
/// **Phase 4 대상**: ❌ IdempotencyService 미주입
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();
  // ❌ Phase 4 Before: IdempotencyService 없음

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // ❌ Phase 4 Before: Idempotency 없음
  @override
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  }) async {
    try {
      // CreationFirestoreMapper 사용 (Phase 3)
      final data = _mapper.toCreateDocument(post);
      data['postCreatedDate'] = post.createdAt;

      // ❌ 문제: 네트워크 재시도 시 중복 문서 생성
      final result = await _dataSource.createPost(data);
      final postId = result['id'] as String;

      return right(postId);
    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  // ❌ Phase 4 Before: Idempotency 없음
  @override
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  }) async {
    try {
      final field = side != null ? 'option$side.images' : 'images';

      // ❌ 문제: 재시도 시 동일 미디어 중복 추가
      await _postsCollection.doc(postId).update({
        field: FieldValue.arrayUnion([
          {
            'url': mediaUrl,
            'type': mediaType,
            'uploadedAt': DateTime.now(),
          }
        ]),
      });

      return right(unit);
    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message ?? 'Unknown error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

**문제점**:
1. **createPost()**: 재시도 시 새 문서 ID 생성 → 중복 게시물
2. **uploadPostMedia()**: `arrayUnion`이 중복 방지하지만 타임스탬프가 다르면 중복 추가
3. **에러 복구 불가**: 실패 시 롤백 메커니즘 없음

#### 3. UseCase (Phase 2 상태)

**파일**: `lib/features/creation/domain/usecases/create_post_usecase.dart:34-177`

```dart
/// CreatePostUseCase (Phase 2 완료)
///
/// **Phase 2**: Result → Either 전환
/// **Phase 4 대상**: ❌ eventId 생성/전달 없음
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;
  // ❌ Phase 4 Before: UUID 생성기 없음

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  }) : _postRepository = postRepository,
       _mediaRepository = mediaRepository,
       _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  // ❌ Phase 4 Before: eventId 파라미터 없음
  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  }) async {
    try {
      onProgress?.call(0.0);

      // 1. 이미지 처리
      final processedMedia = await _processMedia(dto);
      onProgress?.call(0.3);

      // 2. PostCreation 생성
      final post = _buildPostCreation(dto, processedMedia);
      onProgress?.call(0.5);

      // ❌ 문제: Repository에 eventId 전달 불가
      final result = await _postRepository.createPost(post: post);

      return result.fold(
        (failure) => left(failure),
        (postId) {
          final savedPost = post.copyWith(id: postId);
          onProgress?.call(1.0);
          return right(savedPost);
        },
      );
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

**문제점**:
- UseCase에서 eventId 생성 불가
- Repository에 eventId 전달할 방법 없음
- 재시도 시 새로운 요청으로 인식

#### 4. Provider (Riverpod 2.x)

**파일**: `lib/features/creation/presentation/providers/create_post_provider_v2.dart`

```dart
/// CreatePostNotifier (Riverpod 2.x)
///
/// **Phase 2**: Riverpod 2.x 전환
/// **Phase 4 대상**: ❌ UUID 생성 및 재시도 로직 없음
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  // ❌ Phase 4 Before: UUID 생성기 없음

  @override
  FutureOr<PostCreation?> build() => null;

  // ❌ Phase 4 Before: eventId 없음
  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    // ❌ 문제: UseCase에 eventId 전달 불가
    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }

  // ❌ Phase 4 Before: 재시도 메서드 없음
  // Future<void> retryCreatePost(PostCreation post, String eventId) { ... }
}
```

**문제점**:
- UI에서 UUID 생성 불가
- 재시도 시 eventId 보존 불가
- 사용자가 재시도 버튼 누르면 새 요청으로 인식

### After: Phase 4 완료 상태 (목표)

#### 1. Repository 인터페이스 (Phase 4 완료)

**파일**: `lib/features/creation/domain/repositories/i_post_creation_repository_v2.dart`

```dart
/// PostCreation Repository Interface (Phase 4 완료)
///
/// **Phase 4**: ✅ eventId 파라미터 추가
abstract class IPostCreationRepositoryV2 {
  // ✅ Phase 4 After: eventId 추가
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId,  // ✅ UUID for idempotency
  });

  // ✅ Phase 4 After: eventId 추가
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
    required String eventId,  // ✅ UUID for idempotency
  });

  // ✅ Phase 4 After: eventId 추가
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
    required String eventId,  // ✅ UUID for idempotency
  });

  // 조회 작업 (Phase 4 제외)
  Future<Either<CreationFailure, PostCreation?>> getPost(String postId);
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId);
}
```

**개선점**:
- ✅ 모든 write 작업에 eventId 추가
- ✅ 재시도 시 동일 eventId 사용 가능
- ✅ IdempotencyService와 통합 가능

#### 2. Repository 구현 (Phase 4 완료)

**파일**: `lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart`

```dart
/// PostCreationRepositoryV2 구현 (Phase 4 완료)
///
/// **Phase 4**: ✅ IdempotencyService 주입 및 사용
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();
  final IdempotencyService _idempotencyService;  // ✅ Phase 4 추가
  final FirebaseFirestore _firestore;  // ✅ Transaction용

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    required IdempotencyService idempotencyService,  // ✅ DI
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _idempotencyService = idempotencyService,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // ✅ Phase 4 After: Idempotency 적용
  @override
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId,  // ✅ UUID
  }) async {
    return _idempotencyService.executeIdempotent<String>(
      entityType: 'post_create',
      entityId: post.id ?? 'draft_${post.userId}',
      userId: post.userId,
      eventId: eventId,
      operation: (transaction) async {
        // Firestore Transaction 사용
        final data = _mapper.toCreateDocument(post);
        data['postCreatedDate'] = post.createdAt;

        final docRef = _postsCollection.doc();
        transaction.set(docRef, data);

        return docRef.id;  // ✅ 트랜잭션 내에서 ID 반환
      },
    ).then(
      (result) => result.fold(
        (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
        (postId) => right(postId),
      ),
    );
  }

  // ✅ Phase 4 After: Idempotency 적용
  @override
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
    required String eventId,  // ✅ UUID
  }) async {
    return _idempotencyService.executeIdempotent<Unit>(
      entityType: 'media_upload',
      entityId: '$postId:$mediaUrl',  // ✅ Composite key
      userId: await _getCurrentUserId(),
      eventId: eventId,
      operation: (transaction) async {
        final field = side != null ? 'option$side.images' : 'images';

        transaction.update(
          _postsCollection.doc(postId),
          {
            field: FieldValue.arrayUnion([
              {
                'url': mediaUrl,
                'type': mediaType,
                'uploadedAt': DateTime.now(),
              }
            ]),
          },
        );

        return unit;
      },
    ).then(
      (result) => result.fold(
        (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
        (_) => right(unit),
      ),
    );
  }

  // Helper: 현재 사용자 ID 조회
  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
```

**개선점**:
1. ✅ **IdempotencyService 주입**: DI로 서비스 주입
2. ✅ **Transaction 사용**: 원자성 보장
3. ✅ **중복 방지**: eventId로 재시도 식별
4. ✅ **에러 처리**: IdempotencyViolation 전용 Failure

#### 3. UseCase (Phase 4 완료)

**파일**: `lib/features/creation/domain/usecases/create_post_usecase.dart`

```dart
import 'package:uuid/uuid.dart';  // ✅ UUID 패키지

/// CreatePostUseCase (Phase 4 완료)
///
/// **Phase 4**: ✅ UUID 생성 및 eventId 전달
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;
  final Uuid _uuid = const Uuid();  // ✅ UUID 생성기

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  }) : _postRepository = postRepository,
       _mediaRepository = mediaRepository,
       _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  // ✅ Phase 4 After: eventId 파라미터 추가 (optional)
  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    String? eventId,  // ✅ Optional (auto-generate if null)
    Function(double)? onProgress,
  }) async {
    try {
      // ✅ eventId 생성 (없으면 자동 생성)
      final id = eventId ?? _uuid.v4();

      onProgress?.call(0.0);

      // 1. 이미지 처리
      final processedMedia = await _processMedia(dto);
      onProgress?.call(0.3);

      // 2. PostCreation 생성
      final post = _buildPostCreation(dto, processedMedia);
      onProgress?.call(0.5);

      // ✅ Repository에 eventId 전달
      final result = await _postRepository.createPost(
        post: post,
        eventId: id,  // ✅ UUID 전달
      );

      return result.fold(
        (failure) => left(failure),
        (postId) {
          final savedPost = post.copyWith(id: postId);
          onProgress?.call(1.0);
          return right(savedPost);
        },
      );
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

**개선점**:
- ✅ UseCase에서 UUID 생성
- ✅ eventId 파라미터 추가 (재시도 시 동일 ID 재사용 가능)
- ✅ Repository에 eventId 전달

#### 4. Provider (Riverpod 2.x + Phase 4)

**파일**: `lib/features/creation/presentation/providers/create_post_provider_v2.dart`

```dart
import 'package:uuid/uuid.dart';  // ✅ UUID 패키지

/// CreatePostNotifier (Phase 4 완료)
///
/// **Phase 4**: ✅ UUID 생성 및 재시도 로직
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  final Uuid _uuid = const Uuid();  // ✅ UUID 생성기
  String? _lastEventId;  // ✅ 마지막 eventId 저장 (재시도용)

  @override
  FutureOr<PostCreation?> build() => null;

  // ✅ Phase 4 After: eventId 생성 및 저장
  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    // ✅ 새로운 eventId 생성
    final eventId = _uuid.v4();
    _lastEventId = eventId;  // ✅ 재시도용 저장

    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      eventId: eventId,  // ✅ UseCase에 전달
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }

  // ✅ Phase 4 After: 재시도 메서드 추가
  Future<void> retryCreatePost(PostCreation post) async {
    if (_lastEventId == null) {
      // eventId 없으면 새로 생성
      return createPost(post);
    }

    state = const AsyncValue.loading();

    // ✅ 동일한 eventId 재사용 (멱등성 보장)
    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      eventId: _lastEventId!,  // ✅ 기존 eventId 재사용
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }
}
```

**개선점**:
- ✅ UI에서 UUID 생성
- ✅ `_lastEventId` 저장으로 재시도 지원
- ✅ `retryCreatePost()` 메서드로 멱등성 보장

### Before vs After 비교표

| 항목 | Before (Phase 3) | After (Phase 4) | 개선 효과 |
|------|-----------------|----------------|----------|
| **중복 게시물** | 2개 생성됨 ❌ | 1개만 생성 ✅ | 100% 방지 |
| **미디어 중복** | 중복 업로드됨 ❌ | 중복 스킵 ✅ | Storage 비용 절감 |
| **AI API 비용** | 2배 호출 ❌ | 1번만 호출 ✅ | 50% 절감 |
| **Firestore 비용** | 재시도마다 증가 ❌ | 고정 비용 ✅ | 40-60% 절감 |
| **재시도 속도** | 50-100ms (전체 작업) | <10ms (스킵) | 90% 개선 |
| **에러 복구** | 수동 삭제 필요 ❌ | 자동 처리 ✅ | 운영 효율 100% |

---

## 🎯 마이그레이션 목표

### 목표 1: IdempotencyService 구현 및 통합

#### 구현 범위
- ✅ `IdempotencyService` 클래스 구현 (또는 확인)
- ✅ Firestore `idempotency_records` 컬렉션 사용
- ✅ 3가지 시나리오 처리:
  1. **첫 실행**: 작업 수행 + eventId 기록
  2. **재시도** (동일 eventId): 작업 스킵 + 캐시된 결과 반환
  3. **중복** (다른 eventId): `IdempotencyViolation` 예외

#### IdempotencyService 인터페이스

```dart
/// Idempotency 서비스 (전역 서비스)
///
/// **위치**: `lib/services/idempotency/idempotency_service.dart`
/// **Phase 4**: Creation Feature에서 사용
class IdempotencyService {
  final FirebaseFirestore _firestore;

  IdempotencyService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 멱등성 보장 작업 실행
  ///
  /// **시나리오**:
  /// 1. eventId 첫 실행 → operation() 실행 + 기록 저장
  /// 2. 동일 eventId 재시도 → 기록된 결과 반환 (스킵)
  /// 3. 다른 eventId 중복 → IdempotencyViolation 예외
  ///
  /// **파라미터**:
  /// - `entityType`: 작업 유형 ('post_create', 'media_upload')
  /// - `entityId`: 엔티티 식별자 (postId, '$postId:$mediaUrl')
  /// - `userId`: 작업 수행 사용자 ID
  /// - `eventId`: UUID v4 (클라이언트 생성)
  /// - `operation`: Firestore Transaction 내 실행할 작업
  ///
  /// **반환**: Either<IdempotencyFailure, T>
  Future<Either<IdempotencyFailure, T>> executeIdempotent<T>({
    required String entityType,
    required String entityId,
    required String userId,
    required String eventId,
    required Future<T> Function(Transaction) operation,
  }) async {
    final recordId = '${entityType}_$entityId';

    try {
      // 1. Idempotency 기록 확인
      final recordDoc = await _firestore
          .collection('idempotency_records')
          .doc(recordId)
          .get();

      if (recordDoc.exists) {
        final data = recordDoc.data()!;
        final storedEventId = data['eventId'] as String;
        final storedUserId = data['userId'] as String;

        // 사용자 ID 검증
        if (storedUserId != userId) {
          return left(IdempotencyFailure.userMismatch(
            'User mismatch: expected $storedUserId, got $userId',
          ));
        }

        if (storedEventId == eventId) {
          // 시나리오 2: 재시도 (동일 eventId) → 캐시된 결과 반환
          final cachedResult = data['result'];
          return right(cachedResult as T);
        } else {
          // 시나리오 3: 중복 (다른 eventId) → 예외
          return left(IdempotencyFailure.violation(
            'Duplicate operation detected: entity $recordId already processed with eventId $storedEventId',
          ));
        }
      }

      // 시나리오 1: 첫 실행 → Transaction 실행
      final result = await _firestore.runTransaction<T>((transaction) async {
        final opResult = await operation(transaction);

        // Idempotency 기록 저장
        transaction.set(
          _firestore.collection('idempotency_records').doc(recordId),
          {
            'entityType': entityType,
            'entityId': entityId,
            'userId': userId,
            'eventId': eventId,
            'result': opResult,  // 결과 캐싱
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': FieldValue.serverTimestamp(),  // TTL용
          },
        );

        return opResult;
      });

      return right(result);
    } on FirebaseException catch (e) {
      return left(IdempotencyFailure.firestore(e.message ?? 'Firestore error'));
    } catch (e) {
      return left(IdempotencyFailure.unexpected(e.toString()));
    }
  }
}
```

#### IdempotencyFailure 정의

```dart
/// Idempotency 관련 Failure (Sealed class)
///
/// **위치**: `lib/services/idempotency/idempotency_failure.dart`
@freezed
sealed class IdempotencyFailure with _$IdempotencyFailure {
  const factory IdempotencyFailure.violation(String message) = _Violation;
  const factory IdempotencyFailure.userMismatch(String message) = _UserMismatch;
  const factory IdempotencyFailure.firestore(String message) = _Firestore;
  const factory IdempotencyFailure.unexpected(String message) = _Unexpected;
}
```

### 목표 2: Repository 메서드 6개 Idempotency 적용

#### Priority 1 (Critical) - 2개 메서드

##### 1. createPost() - 게시물 중복 생성 방지

**변경 전 (Phase 3)**:
```dart
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  final data = _mapper.toCreateDocument(post);
  final result = await _dataSource.createPost(data);
  return right(result['id'] as String);
}
```

**변경 후 (Phase 4)**:
```dart
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<String>(
    entityType: 'post_create',
    entityId: post.id ?? 'draft_${post.userId}',
    userId: post.userId,
    eventId: eventId,
    operation: (transaction) async {
      final data = _mapper.toCreateDocument(post);
      data['postCreatedDate'] = post.createdAt;

      final docRef = _postsCollection.doc();
      transaction.set(docRef, data);
      return docRef.id;
    },
  ).then((result) => result.fold(
    (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
    (postId) => right(postId),
  ));
}
```

**변경 요약**:
- `eventId` 파라미터 추가
- `IdempotencyService.executeIdempotent()` 래핑
- Firestore Transaction 사용
- IdempotencyFailure → CreationFailure 변환

##### 2. uploadPostMedia() - 미디어 중복 업로드 방지

**변경 전 (Phase 3)**:
```dart
Future<Either<CreationFailure, Unit>> uploadPostMedia({
  required String postId,
  required String mediaUrl,
  required String mediaType,
  String? side,
}) async {
  final field = side != null ? 'option$side.images' : 'images';
  await _postsCollection.doc(postId).update({
    field: FieldValue.arrayUnion([{
      'url': mediaUrl,
      'type': mediaType,
      'uploadedAt': DateTime.now(),
    }]),
  });
  return right(unit);
}
```

**변경 후 (Phase 4)**:
```dart
Future<Either<CreationFailure, Unit>> uploadPostMedia({
  required String postId,
  required String mediaUrl,
  required String mediaType,
  String? side,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'media_upload',
    entityId: '$postId:$mediaUrl',  // ✅ Composite key
    userId: await _getCurrentUserId(),
    eventId: eventId,
    operation: (transaction) async {
      final field = side != null ? 'option$side.images' : 'images';
      transaction.update(_postsCollection.doc(postId), {
        field: FieldValue.arrayUnion([{
          'url': mediaUrl,
          'type': mediaType,
          'uploadedAt': DateTime.now(),
        }]),
      });
      return unit;
    },
  ).then((result) => result.fold(
    (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
    (_) => right(unit),
  ));
}
```

**변경 요약**:
- `eventId` 파라미터 추가
- `entityId`로 Composite key 사용 (`$postId:$mediaUrl`)
- Transaction 내에서 update 수행

#### Priority 2 (Important) - 2개 메서드

##### 3. AI API 호출 - Gemini 중복 요청 방지

**Note**: UseCase 레벨에서 구현 (Repository 아님)

**파일**: `lib/features/creation/domain/usecases/generate_ai_content_usecase.dart`

**변경 후 (Phase 4)**:
```dart
class GenerateAIContentUseCase {
  final IAIService _aiService;
  final CreationCacheService _cacheService;  // Phase 3
  final IdempotencyService _idempotencyService;  // ✅ Phase 4
  final Uuid _uuid = const Uuid();

  Future<Either<CreationFailure, String>> generateTitle({
    required String description,
    String? eventId,  // ✅ Optional
  }) async {
    // Phase 3: 캐시 우선 조회
    final cached = await _cacheService.getAIGenerationResult(description);
    if (cached != null) return right(cached);

    // Phase 4: Idempotency로 동시 요청 중복 방지
    final id = eventId ?? _uuid.v4();

    return _idempotencyService.executeIdempotent<String>(
      entityType: 'ai_generation',
      entityId: md5(description),  // 프롬프트 해시
      userId: 'system',  // AI 요청은 시스템 레벨
      eventId: id,
      operation: (_) async {
        final result = await _aiService.generateTitle(description);
        await _cacheService.setAIGenerationResult(description, result);  // Phase 3
        return result;
      },
    ).then((result) => result.fold(
      (failure) => left(CreationFailure.aiGenerationFailed(failure.message)),
      (title) => right(title),
    ));
  }
}
```

**변경 요약**:
- Phase 3 캐싱 + Phase 4 Idempotency 결합
- 동시 실행 중인 요청 중복 방지
- AI 비용 절감: 70% (Phase 3) + 30% (Phase 4) = 90% 총 절감

##### 4. saveDraftPost() - Draft 중복 저장 방지

**변경 후 (Phase 4)**:
```dart
Future<Either<CreationFailure, Unit>> saveDraftPost({
  required String userId,
  required PostCreation draft,
  required String eventId,  // ✅ 추가
}) async {
  // Phase 3: 캐시 Write-Through
  await _cacheService.setDraftPost(userId, draft);

  // Phase 4: Firestore Idempotency
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'draft_save',
    entityId: draft.id ?? 'draft_$userId',
    userId: userId,
    eventId: eventId,
    operation: (transaction) async {
      final data = _mapper.toCreateDocument(draft);
      transaction.set(
        _postsCollection.doc(draft.id ?? 'draft_$userId'),
        data,
      );
      return unit;
    },
  ).then((result) => result.fold(
    (failure) => left(CreationFailure.draftSaveFailed(failure.message)),
    (_) => right(unit),
  ));
}
```

#### Priority 3 (Optional) - 2개 메서드

##### 5. updatePost() - 동시 업데이트 충돌 방지

**변경 후 (Phase 4)**:
```dart
Future<Either<CreationFailure, Unit>> updatePost({
  required String postId,
  required PostCreation post,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'post_update',
    entityId: postId,
    userId: post.userId,
    eventId: eventId,
    operation: (transaction) async {
      final data = _mapper.toUpdateDocument(post);
      transaction.update(_postsCollection.doc(postId), data);
      return unit;
    },
  ).then((result) => result.fold(
    (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
    (_) => right(unit),
  ));
}
```

##### 6. deletePost() - 중복 삭제 방지

**변경 후 (Phase 4)**:
```dart
Future<Either<CreationFailure, Unit>> deletePost({
  required String postId,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'post_delete',
    entityId: postId,
    userId: await _getCurrentUserId(),
    eventId: eventId,
    operation: (transaction) async {
      transaction.update(_postsCollection.doc(postId), {
        'deleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
      return unit;
    },
  ).then((result) => result.fold(
    (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
    (_) => right(unit),
  ));
}
```

### 목표 3: UUID 생성 전략 수립

#### UUID v4 선택 이유

| 방식 | 장점 | 단점 | Creation Feature 적합성 |
|------|------|------|------------------------|
| **UUID v4** | 전역 유일성, 클라이언트 생성 가능, 예측 불가 | 충돌 확률 1/2^122 (무시 가능) | ✅ **최적** |
| Server Timestamp | 순서 보장 | 서버 왕복 필요, 동시 요청 충돌 가능 | ❌ |
| Auto Increment | 순서 보장, 간단 | 분산 환경 부적합, 예측 가능 | ❌ |
| Hash (MD5) | 결정론적 | 충돌 가능, 보안 취약 | ❌ |

#### UUID 생성 위치

```dart
// ✅ 추천: UI Layer (Provider/Notifier)
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  final Uuid _uuid = const Uuid();

  Future<void> createPost(PostCreation post) async {
    final eventId = _uuid.v4();  // ✅ UI에서 생성
    // ...
  }
}

// ⚠️ 대안: UseCase Layer
class CreatePostUseCase {
  final Uuid _uuid = const Uuid();

  Future<Either<CreationFailure, PostCreation>> execute({
    String? eventId,  // Optional
  }) async {
    final id = eventId ?? _uuid.v4();  // UseCase에서 생성
    // ...
  }
}
```

**추천**: **UI Layer**
- 재시도 버튼 클릭 시 동일 eventId 재사용 가능
- 사용자 액션과 eventId 1:1 매핑
- UseCase는 eventId를 받기만 함 (생성 책임 분리)

#### eventId 저장 전략

```dart
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  String? _lastEventId;  // ✅ 마지막 eventId 저장
  PostCreation? _lastPost;  // ✅ 마지막 요청 저장

  Future<void> createPost(PostCreation post) async {
    final eventId = _uuid.v4();
    _lastEventId = eventId;  // ✅ 저장
    _lastPost = post;
    // ...
  }

  Future<void> retryLast() async {
    if (_lastEventId == null || _lastPost == null) return;

    // ✅ 동일한 eventId + 동일한 post 재시도
    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(_lastPost!),
      eventId: _lastEventId!,  // ✅ 재사용
    );
    // ...
  }
}
```

### 목표 4: DI 모듈 업데이트

#### CreationDIModule 수정

**파일**: `lib/features/creation/di/creation_di_module.dart`

**변경 후 (Phase 4)**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/idempotency/idempotency_service.dart';  // ✅ Import
import '/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import '/features/creation/domain/repositories/i_post_creation_repository_v2.dart';

// ✅ IdempotencyService Provider 추가
final idempotencyServiceProvider = Provider<IdempotencyService>((ref) {
  return IdempotencyService(firestore: FirebaseFirestore.instance);
});

// ✅ Repository에 IdempotencyService 주입
final postCreationRepositoryV2Provider = Provider<IPostCreationRepositoryV2>((ref) {
  return PostCreationRepositoryV2Impl(
    dataSource: ref.watch(postCreationDataSourceProvider),
    targetAudienceService: ref.watch(targetAudienceServiceProvider),
    imageProcessingService: ref.watch(imageProcessingServiceProvider),
    idempotencyService: ref.watch(idempotencyServiceProvider),  // ✅ 주입
    firestore: FirebaseFirestore.instance,
  );
});

// UseCase Provider는 변경 없음 (Repository를 주입받음)
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return CreatePostUseCase(
    postRepository: ref.watch(postCreationRepositoryV2Provider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
    manageTargetAudienceUseCase: ref.watch(manageTargetAudienceUseCaseProvider),
  );
});
```

**변경 요약**:
- `idempotencyServiceProvider` 추가
- `postCreationRepositoryV2Provider`에 주입
- UseCase/Provider는 변경 없음

---

## 📝 단계별 마이그레이션 가이드

### 사전 준비

#### 1. UUID 패키지 추가

```bash
# pubspec.yaml에 추가
flutter pub add uuid

# 설치 확인
flutter pub get
```

**pubspec.yaml**:
```yaml
dependencies:
  uuid: ^4.0.0  # ✅ UUID v4 생성용
```

#### 2. IdempotencyService 존재 확인

```bash
# 파일 확인
ls -la lib/services/idempotency/idempotency_service.dart
```

**존재하지 않으면**:
- Chat Feature의 IdempotencyService 참조
- 또는 위 "목표 1"의 코드 복사하여 생성

#### 3. Phase 1,2,3 완료 확인

```bash
# Freezed 코드 생성 확인
dart run build_runner build --delete-conflicting-outputs

# 테스트 실행
flutter test lib/features/creation/test/

# 확인 항목:
# - PostCreation.toJson() 존재
# - Either<Failure, T> 사용
# - UnifiedCacheService 통합
```

### Step 1: Repository 인터페이스 수정 (6개 메서드)

**파일**: `lib/features/creation/domain/repositories/i_post_creation_repository_v2.dart`

**변경 내용**: 모든 write 작업 메서드에 `eventId` 파라미터 추가

```dart
abstract class IPostCreationRepositoryV2 {
  // ✅ Step 1-1: createPost에 eventId 추가
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId,  // ✅ 추가
  });

  // ✅ Step 1-2: uploadPostMedia에 eventId 추가
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
    required String eventId,  // ✅ 추가
  });

  // ✅ Step 1-3: updatePost에 eventId 추가
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
    required String eventId,  // ✅ 추가
  });

  // ✅ Step 1-4: deletePost에 eventId 추가
  Future<Either<CreationFailure, Unit>> deletePost({
    required String postId,
    required String eventId,  // ✅ 추가
  });

  // ✅ Step 1-5: updatePostStatus에 eventId 추가 (Optional)
  Future<Either<CreationFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
    required String eventId,  // ✅ 추가
  });

  // ✅ Step 1-6: markPostAsProcessed에 eventId 추가 (Optional)
  Future<Either<CreationFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
    required String eventId,  // ✅ 추가
  });

  // 조회 작업은 변경 없음 (이미 멱등)
  Future<Either<CreationFailure, PostCreation?>> getPost(String postId);
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId);
  Stream<Either<CreationFailure, List<PostCreation>>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });
}
```

**변경 파일**: 1개
**추가 줄**: +6줄 (주석 포함)
**삭제 줄**: -6줄 (기존 메서드 시그니처)

### Step 2: Repository 구현 수정 (Priority 1,2만 구현)

**파일**: `lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart`

#### 2-1: 생성자에 IdempotencyService 주입

```dart
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();
  final IdempotencyService _idempotencyService;  // ✅ 추가
  final FirebaseFirestore _firestore;  // ✅ 추가

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    required IdempotencyService idempotencyService,  // ✅ 추가
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _idempotencyService = idempotencyService,  // ✅ 초기화
       _firestore = firestore ?? FirebaseFirestore.instance,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // Helper: 현재 사용자 ID 조회
  Future<String> _getCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }
}
```

#### 2-2: createPost() 메서드 수정 (Priority 1)

**Before (Phase 3)**:
```dart
@override
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  try {
    final data = _mapper.toCreateDocument(post);
    data['postCreatedDate'] = post.createdAt;

    final result = await _dataSource.createPost(data);
    final postId = result['id'] as String;

    return right(postId);
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message ?? 'Unknown error'));
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

**After (Phase 4)**:
```dart
@override
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<String>(
    entityType: 'post_create',
    entityId: post.id ?? 'draft_${post.userId}',
    userId: post.userId,
    eventId: eventId,
    operation: (transaction) async {
      // Mapper 사용 (Phase 3)
      final data = _mapper.toCreateDocument(post);
      data['postCreatedDate'] = post.createdAt;

      // Transaction으로 문서 생성
      final docRef = _postsCollection.doc();
      transaction.set(docRef, data);

      return docRef.id;
    },
  ).then(
    (result) => result.fold(
      (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
      (postId) => right(postId),
    ),
  );
}
```

**변경 요약**:
- `eventId` 파라미터 추가
- `IdempotencyService.executeIdempotent()` 래핑
- Firestore Transaction 사용
- try-catch 제거 (IdempotencyService가 처리)

#### 2-3: uploadPostMedia() 메서드 수정 (Priority 1)

**Before (Phase 3)**:
```dart
@override
Future<Either<CreationFailure, Unit>> uploadPostMedia({
  required String postId,
  required String mediaUrl,
  required String mediaType,
  String? side,
}) async {
  try {
    final field = side != null ? 'option$side.images' : 'images';
    await _postsCollection.doc(postId).update({
      field: FieldValue.arrayUnion([
        {
          'url': mediaUrl,
          'type': mediaType,
          'uploadedAt': DateTime.now(),
        }
      ]),
    });

    return right(unit);
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message ?? 'Unknown error'));
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

**After (Phase 4)**:
```dart
@override
Future<Either<CreationFailure, Unit>> uploadPostMedia({
  required String postId,
  required String mediaUrl,
  required String mediaType,
  String? side,
  required String eventId,  // ✅ 추가
}) async {
  return _idempotencyService.executeIdempotent<Unit>(
    entityType: 'media_upload',
    entityId: '$postId:$mediaUrl',  // ✅ Composite key
    userId: await _getCurrentUserId(),
    eventId: eventId,
    operation: (transaction) async {
      final field = side != null ? 'option$side.images' : 'images';

      transaction.update(_postsCollection.doc(postId), {
        field: FieldValue.arrayUnion([
          {
            'url': mediaUrl,
            'type': mediaType,
            'uploadedAt': DateTime.now(),
          }
        ]),
      });

      return unit;
    },
  ).then(
    (result) => result.fold(
      (failure) => left(CreationFailure.idempotencyViolation(failure.message)),
      (_) => right(unit),
    ),
  );
}
```

**변경 요약**:
- `eventId` 파라미터 추가
- `entityId`로 Composite key 사용 (`$postId:$mediaUrl`)
- Transaction 내에서 update 수행
- `_getCurrentUserId()` Helper 사용

#### 2-4: updatePost() 메서드 수정 (Priority 3, Optional)

**생략 가능** (Phase 5에서 처리)

#### 2-5: deletePost() 메서드 수정 (Priority 3, Optional)

**생략 가능** (Phase 5에서 처리)

**변경 파일**: 1개
**추가 줄**: +70줄 (2개 메서드 수정)
**삭제 줄**: -30줄 (기존 코드)

### Step 3: UseCase 수정 (CreatePostUseCase)

**파일**: `lib/features/creation/domain/usecases/create_post_usecase.dart`

#### 3-1: UUID 패키지 임포트

```dart
import 'package:uuid/uuid.dart';  // ✅ 추가
import 'package:fpdart/fpdart.dart';
import '/features/creation/domain/repositories/i_post_creation_repository_v2.dart';
import '/features/creation/domain/models/aggregates/post_creation.dart';
// ...
```

#### 3-2: UUID 생성기 추가 및 eventId 파라미터

**Before (Phase 3)**:
```dart
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  }) : _postRepository = postRepository,
       _mediaRepository = mediaRepository,
       _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  }) async {
    // ...
    final result = await _postRepository.createPost(post: post);
    // ...
  }
}
```

**After (Phase 4)**:
```dart
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;
  final Uuid _uuid = const Uuid();  // ✅ UUID 생성기 추가

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  }) : _postRepository = postRepository,
       _mediaRepository = mediaRepository,
       _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    String? eventId,  // ✅ Optional eventId 추가
    Function(double)? onProgress,
  }) async {
    try {
      // ✅ eventId 생성 (없으면 자동 생성)
      final id = eventId ?? _uuid.v4();

      onProgress?.call(0.0);

      // 1. 이미지 처리
      final processedMedia = await _processMedia(dto);
      onProgress?.call(0.3);

      // 2. PostCreation 생성
      final post = _buildPostCreation(dto, processedMedia);
      onProgress?.call(0.5);

      // ✅ Repository에 eventId 전달
      final result = await _postRepository.createPost(
        post: post,
        eventId: id,  // ✅ UUID 전달
      );

      return result.fold(
        (failure) => left(failure),
        (postId) {
          final savedPost = post.copyWith(id: postId);
          onProgress?.call(1.0);
          return right(savedPost);
        },
      );
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

**변경 요약**:
- `Uuid _uuid` 필드 추가
- `eventId` 파라미터 추가 (Optional)
- eventId 생성 로직 추가 (없으면 UUID v4 생성)
- Repository 호출 시 eventId 전달

**변경 파일**: 1개
**추가 줄**: +10줄
**삭제 줄**: -2줄

### Step 4: DI 모듈 수정 (IdempotencyService 등록)

**파일**: `lib/features/creation/di/creation_di_module.dart`

**Before (Phase 3)**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import '/features/creation/domain/repositories/i_post_creation_repository_v2.dart';

final postCreationRepositoryV2Provider = Provider<IPostCreationRepositoryV2>((ref) {
  return PostCreationRepositoryV2Impl(
    dataSource: ref.watch(postCreationDataSourceProvider),
    targetAudienceService: ref.watch(targetAudienceServiceProvider),
    imageProcessingService: ref.watch(imageProcessingServiceProvider),
    firestore: FirebaseFirestore.instance,
  );
});
```

**After (Phase 4)**:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/idempotency/idempotency_service.dart';  // ✅ Import 추가
import '/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import '/features/creation/domain/repositories/i_post_creation_repository_v2.dart';

// ✅ IdempotencyService Provider 추가
final idempotencyServiceProvider = Provider<IdempotencyService>((ref) {
  return IdempotencyService(firestore: FirebaseFirestore.instance);
});

// ✅ Repository에 IdempotencyService 주입
final postCreationRepositoryV2Provider = Provider<IPostCreationRepositoryV2>((ref) {
  return PostCreationRepositoryV2Impl(
    dataSource: ref.watch(postCreationDataSourceProvider),
    targetAudienceService: ref.watch(targetAudienceServiceProvider),
    imageProcessingService: ref.watch(imageProcessingServiceProvider),
    idempotencyService: ref.watch(idempotencyServiceProvider),  // ✅ 주입
    firestore: FirebaseFirestore.instance,
  );
});
```

**변경 요약**:
- `IdempotencyService` 임포트 추가
- `idempotencyServiceProvider` 추가
- `postCreationRepositoryV2Provider`에 주입

**변경 파일**: 1개
**추가 줄**: +8줄

### Step 5: Provider (Riverpod 2.x) 수정

**파일**: `lib/features/creation/presentation/providers/create_post_provider_v2.dart`

**Before (Phase 3)**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '/features/creation/domain/models/aggregates/post_creation.dart';
import '/features/creation/domain/usecases/create_post_usecase.dart';

part 'create_post_provider_v2.g.dart';

@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  @override
  FutureOr<PostCreation?> build() => null;

  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }
}
```

**After (Phase 4)**:
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';  // ✅ 추가
import '/features/creation/domain/models/aggregates/post_creation.dart';
import '/features/creation/domain/usecases/create_post_usecase.dart';

part 'create_post_provider_v2.g.dart';

@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  final Uuid _uuid = const Uuid();  // ✅ UUID 생성기
  String? _lastEventId;  // ✅ 마지막 eventId 저장 (재시도용)
  PostCreation? _lastPost;  // ✅ 마지막 요청 저장

  @override
  FutureOr<PostCreation?> build() => null;

  // ✅ Phase 4: eventId 생성 및 저장
  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    // ✅ 새로운 eventId 생성
    final eventId = _uuid.v4();
    _lastEventId = eventId;  // ✅ 저장 (재시도용)
    _lastPost = post;  // ✅ 저장 (재시도용)

    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      eventId: eventId,  // ✅ UseCase에 전달
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }

  // ✅ Phase 4: 재시도 메서드 추가
  Future<void> retryCreatePost() async {
    if (_lastEventId == null || _lastPost == null) {
      // eventId 없으면 새로 생성
      throw Exception('No previous request to retry');
    }

    state = const AsyncValue.loading();

    // ✅ 동일한 eventId 재사용 (멱등성 보장)
    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(_lastPost!),
      eventId: _lastEventId!,  // ✅ 기존 eventId 재사용
      onProgress: (progress) {
        // 진행률 업데이트
      },
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }
}
```

**변경 요약**:
- `Uuid _uuid` 필드 추가
- `_lastEventId`, `_lastPost` 필드 추가 (재시도용)
- `createPost()`: eventId 생성 및 저장
- `retryCreatePost()`: 동일 eventId로 재시도

**변경 파일**: 1개
**추가 줄**: +30줄
**삭제 줄**: -2줄

### Step 6: 코드 생성 및 빌드

```bash
# 1. Riverpod 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 2. 컴파일 확인
flutter analyze

# 3. 테스트 실행 (통합 테스트는 Step 7에서)
flutter test lib/features/creation/test/unit/
```

**예상 출력**:
```
[INFO] Generating build script completed, took 1.2s
[INFO] Creating build script snapshot... completed, took 3.5s
[INFO] Building new asset graph... completed, took 2.1s
[INFO] Checking for unexpected pre-existing outputs. completed, took 0.2s
[INFO] Running build... completed, took 5.8s
[INFO] Caching finalized dependency graph... completed, took 0.1s
[INFO] Succeeded after 5.9s with 12 outputs (24 actions)
```

---

## 🧪 테스트 전략

### 테스트 범위

| 테스트 유형 | 범위 | 파일 수 | 예상 줄 수 |
|------------|------|---------|-----------|
| **Unit 테스트** | IdempotencyService, Repository 메서드 | 2개 | ~200줄 |
| **Integration 테스트** | UseCase + Repository + Firestore | 1개 | ~150줄 |
| **Widget 테스트** | Provider + UI 재시도 | 1개 | ~100줄 |
| **합계** | | **4개** | **~450줄** |

### Unit 테스트 (IdempotencyService)

**파일**: `test/unit/services/idempotency_service_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:versus_space/services/idempotency/idempotency_service.dart';

void main() {
  group('IdempotencyService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late IdempotencyService idempotencyService;
    const uuid = Uuid();

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      idempotencyService = IdempotencyService(firestore: fakeFirestore);
    });

    group('executeIdempotent - 시나리오 1: 첫 실행', () {
      test('첫 실행 시 operation 실행 및 결과 반환', () async {
        // Arrange
        final eventId = uuid.v4();
        const entityType = 'post_create';
        const entityId = 'post_123';
        const userId = 'user_456';
        const expectedResult = 'created_post_id';

        // Act
        final result = await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId,
          eventId: eventId,
          operation: (transaction) async {
            return expectedResult;
          },
        );

        // Assert
        expect(result.isRight(), true);
        expect(result.getOrElse((l) => ''), expectedResult);

        // Idempotency 기록 확인
        final recordDoc = await fakeFirestore
            .collection('idempotency_records')
            .doc('${entityType}_$entityId')
            .get();

        expect(recordDoc.exists, true);
        expect(recordDoc.data()!['eventId'], eventId);
        expect(recordDoc.data()!['userId'], userId);
        expect(recordDoc.data()!['result'], expectedResult);
      });
    });

    group('executeIdempotent - 시나리오 2: 재시도 (동일 eventId)', () {
      test('동일 eventId 재시도 시 캐시된 결과 반환 (operation 스킵)', () async {
        // Arrange
        final eventId = uuid.v4();
        const entityType = 'post_create';
        const entityId = 'post_123';
        const userId = 'user_456';
        const expectedResult = 'created_post_id';

        // 첫 실행
        await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId,
          eventId: eventId,
          operation: (transaction) async => expectedResult,
        );

        int operationCallCount = 0;

        // Act: 재시도 (동일 eventId)
        final result = await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId,
          eventId: eventId,
          operation: (transaction) async {
            operationCallCount++;  // ✅ 호출되면 안됨
            return 'new_result';
          },
        );

        // Assert
        expect(result.isRight(), true);
        expect(result.getOrElse((l) => ''), expectedResult);  // 캐시된 결과
        expect(operationCallCount, 0);  // ✅ operation 호출 안됨
      });
    });

    group('executeIdempotent - 시나리오 3: 중복 (다른 eventId)', () {
      test('다른 eventId로 재시도 시 IdempotencyViolation 반환', () async {
        // Arrange
        final firstEventId = uuid.v4();
        final secondEventId = uuid.v4();
        const entityType = 'post_create';
        const entityId = 'post_123';
        const userId = 'user_456';

        // 첫 실행
        await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId,
          eventId: firstEventId,
          operation: (transaction) async => 'first_result',
        );

        // Act: 다른 eventId로 재시도
        final result = await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId,
          eventId: secondEventId,  // ✅ 다른 eventId
          operation: (transaction) async => 'second_result',
        );

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<IdempotencyFailure>());
            // failure.when()으로 타입 확인
          },
          (r) => fail('Should return Left (failure)'),
        );
      });
    });

    group('executeIdempotent - 사용자 ID 불일치', () {
      test('다른 사용자 ID로 재시도 시 UserMismatch 반환', () async {
        // Arrange
        final eventId = uuid.v4();
        const entityType = 'post_create';
        const entityId = 'post_123';
        const userId1 = 'user_456';
        const userId2 = 'user_789';

        // 첫 실행 (user_456)
        await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId1,
          eventId: eventId,
          operation: (transaction) async => 'result',
        );

        // Act: 다른 사용자로 동일 eventId 재시도
        final result = await idempotencyService.executeIdempotent<String>(
          entityType: entityType,
          entityId: entityId,
          userId: userId2,  // ✅ 다른 사용자
          eventId: eventId,
          operation: (transaction) async => 'result',
        );

        // Assert
        expect(result.isLeft(), true);
        // UserMismatch 타입 확인
      });
    });
  });
}
```

### Integration 테스트 (Repository + UseCase)

**파일**: `test/integration/creation/post_creation_idempotency_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:versus_space/features/creation/domain/models/aggregates/post_creation.dart';
import 'package:versus_space/features/creation/domain/usecases/create_post_usecase.dart';
import 'package:versus_space/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import 'package:versus_space/services/idempotency/idempotency_service.dart';

void main() {
  group('PostCreation Idempotency Integration', () {
    late FakeFirebaseFirestore fakeFirestore;
    late IdempotencyService idempotencyService;
    late PostCreationRepositoryV2Impl repository;
    late CreatePostUseCase useCase;
    const uuid = Uuid();

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      idempotencyService = IdempotencyService(firestore: fakeFirestore);

      repository = PostCreationRepositoryV2Impl(
        dataSource: MockPostCreationDataSource(),
        imageProcessingService: MockImageProcessingService(),
        idempotencyService: idempotencyService,
        firestore: fakeFirestore,
      );

      useCase = CreatePostUseCase(
        postRepository: repository,
        mediaRepository: MockMediaRepository(),
        manageTargetAudienceUseCase: MockManageTargetAudienceUseCase(),
      );
    });

    test('게시물 생성 - 재시도 시 동일 게시물 ID 반환', () async {
      // Arrange
      final eventId = uuid.v4();
      final post = PostCreation(
        userId: 'user_123',
        title: 'Test Post',
        // ...
      );
      final dto = PostCreationDto.fromPostCreation(post);

      // Act 1: 첫 실행
      final result1 = await useCase.execute(
        dto: dto,
        eventId: eventId,
      );

      // Act 2: 재시도 (동일 eventId)
      final result2 = await useCase.execute(
        dto: dto,
        eventId: eventId,
      );

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      final postId1 = result1.getOrElse((l) => null)?.id;
      final postId2 = result2.getOrElse((l) => null)?.id;

      expect(postId1, postId2);  // ✅ 동일한 게시물 ID

      // Firestore에 1개만 생성되었는지 확인
      final postsSnapshot = await fakeFirestore.collection('posts').get();
      expect(postsSnapshot.docs.length, 1);
    });

    test('게시물 생성 - 다른 eventId로 재시도 시 IdempotencyViolation', () async {
      // Arrange
      final eventId1 = uuid.v4();
      final eventId2 = uuid.v4();
      final post = PostCreation(
        userId: 'user_123',
        title: 'Test Post',
        // ...
      );
      final dto = PostCreationDto.fromPostCreation(post);

      // Act 1: 첫 실행
      final result1 = await useCase.execute(
        dto: dto,
        eventId: eventId1,
      );

      // Act 2: 다른 eventId로 재시도
      final result2 = await useCase.execute(
        dto: dto,
        eventId: eventId2,  // ✅ 다른 eventId
      );

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isLeft(), true);  // ✅ Failure 반환

      result2.fold(
        (failure) {
          expect(failure, isA<CreationFailure>());
          // CreationFailure.idempotencyViolation 확인
        },
        (r) => fail('Should return Left (failure)'),
      );
    });

    test('미디어 업로드 - 재시도 시 중복 업로드 방지', () async {
      // Arrange
      const postId = 'post_123';
      const mediaUrl = 'https://example.com/image.jpg';
      final eventId = uuid.v4();

      // 게시물 미리 생성
      await fakeFirestore.collection('posts').doc(postId).set({
        'title': 'Test Post',
        'images': [],
      });

      // Act 1: 첫 업로드
      final result1 = await repository.uploadPostMedia(
        postId: postId,
        mediaUrl: mediaUrl,
        mediaType: 'image',
        eventId: eventId,
      );

      // Act 2: 재시도 (동일 eventId)
      final result2 = await repository.uploadPostMedia(
        postId: postId,
        mediaUrl: mediaUrl,
        mediaType: 'image',
        eventId: eventId,
      );

      // Assert
      expect(result1.isRight(), true);
      expect(result2.isRight(), true);

      // Firestore에서 images 배열 확인
      final postDoc = await fakeFirestore.collection('posts').doc(postId).get();
      final images = postDoc.data()!['images'] as List;

      expect(images.length, 1);  // ✅ 1개만 저장됨 (중복 방지)
    });
  });
}
```

### Widget 테스트 (Provider + UI)

**파일**: `test/widget/creation/create_post_retry_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:versus_space/features/creation/presentation/providers/create_post_provider_v2.dart';
import 'package:versus_space/features/creation/presentation/screens/create_post_screen.dart';

void main() {
  group('CreatePostScreen - 재시도 버튼', () {
    testWidgets('재시도 버튼 클릭 시 동일 eventId 재사용', (tester) async {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CreatePostScreen(),
          ),
        ),
      );

      // Act 1: 게시물 작성
      await tester.enterText(find.byKey(Key('title_field')), 'Test Post');
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pump();

      // 네트워크 에러 시뮬레이션 (Failure 상태)
      // ...

      // Act 2: 재시도 버튼 클릭
      await tester.tap(find.byKey(Key('retry_button')));
      await tester.pump();

      // Assert
      // Provider에서 _lastEventId가 재사용되었는지 확인
      final notifier = container.read(createPostNotifierProvider.notifier);
      // expect(notifier._lastEventId, isNotNull);  // Private 필드 접근 불가

      // 대안: Mock Repository로 eventId 검증
    });
  });
}
```

### 테스트 실행 명령어

```bash
# 1. Unit 테스트만 실행
flutter test test/unit/services/idempotency_service_test.dart

# 2. Integration 테스트 실행
flutter test test/integration/creation/post_creation_idempotency_test.dart

# 3. Widget 테스트 실행
flutter test test/widget/creation/create_post_retry_test.dart

# 4. 전체 Creation Feature 테스트
flutter test test/unit/features/creation/ test/integration/creation/ test/widget/creation/

# 5. 커버리지 포함 실행
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 🔄 롤백 계획

Phase 4 마이그레이션 실패 시 안전하게 Phase 3 상태로 복원하는 4단계 롤백 계획입니다.

### 롤백 시나리오 1: IdempotencyService 버그 발견

**증상**:
- IdempotencyService가 잘못된 결과 캐싱
- Transaction 충돌로 Firestore 에러
- Idempotency 기록 삭제 실패

**롤백 단계**:

#### Step 1: Repository 원복 (즉시)

```dart
// PostCreationRepositoryV2Impl.createPost() 원복
@override
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  // required String eventId,  // ❌ 제거
}) async {
  try {
    final data = _mapper.toCreateDocument(post);
    data['postCreatedDate'] = post.createdAt;

    final result = await _dataSource.createPost(data);
    final postId = result['id'] as String;

    return right(postId);
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message ?? 'Unknown error'));
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

#### Step 2: Repository Interface 원복

```dart
// IPostCreationRepositoryV2 원복
abstract class IPostCreationRepositoryV2 {
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    // required String eventId,  // ❌ 제거
  });

  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
    // required String eventId,  // ❌ 제거
  });
}
```

#### Step 3: UseCase 원복

```dart
// CreatePostUseCase 원복
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  // final Uuid _uuid = const Uuid();  // ❌ 제거

  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    // String? eventId,  // ❌ 제거
    Function(double)? onProgress,
  }) async {
    // ...
    final result = await _postRepository.createPost(post: post);
    // ...
  }
}
```

#### Step 4: Provider 원복

```dart
// CreatePostNotifier 원복
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  // final Uuid _uuid = const Uuid();  // ❌ 제거
  // String? _lastEventId;  // ❌ 제거

  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    final result = await ref.read(createPostUseCaseProvider).execute(
      dto: PostCreationDto.fromPostCreation(post),
      // eventId: eventId,  // ❌ 제거
    );

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (createdPost) => state = AsyncValue.data(createdPost),
    );
  }

  // Future<void> retryCreatePost() async { ... }  // ❌ 제거
}
```

#### Step 5: DI 모듈 원복

```dart
// creation_di_module.dart 원복
// final idempotencyServiceProvider = ...  // ❌ 제거

final postCreationRepositoryV2Provider = Provider<IPostCreationRepositoryV2>((ref) {
  return PostCreationRepositoryV2Impl(
    dataSource: ref.watch(postCreationDataSourceProvider),
    targetAudienceService: ref.watch(targetAudienceServiceProvider),
    imageProcessingService: ref.watch(imageProcessingServiceProvider),
    // idempotencyService: ref.watch(idempotencyServiceProvider),  // ❌ 제거
    firestore: FirebaseFirestore.instance,
  );
});
```

#### Step 6: 코드 재생성 및 빌드

```bash
# 1. 코드 재생성
dart run build_runner build --delete-conflicting-outputs

# 2. 컴파일 확인
flutter analyze

# 3. 테스트 실행
flutter test
```

**소요 시간**: 15-30분
**영향 범위**: 6개 파일
**데이터 손실**: 없음 (Idempotency 기록만 삭제)

### 롤백 시나리오 2: 성능 저하

**증상**:
- createPost() 응답 시간 100ms → 150ms (+50%)
- Firestore Transaction 충돌로 재시도 빈발
- Idempotency 기록 조회로 추가 Latency

**롤백 단계**:

#### Step 1: 성능 측정

```bash
# Firestore 쿼리 로그 확인
firebase firestore:logs --limit 100

# Latency 측정
flutter run --profile
# DevTools에서 Timeline 확인
```

#### Step 2: Idempotency 기록 TTL 설정

```dart
// IdempotencyService에서 expiresAt 설정
transaction.set(
  _firestore.collection('idempotency_records').doc(recordId),
  {
    // ...
    'expiresAt': Timestamp.fromDate(DateTime.now().add(Duration(hours: 24))),
  },
);
```

```javascript
// Firestore Rules에서 TTL 적용 (firebase/firestore.rules)
match /idempotency_records/{recordId} {
  allow read, write: if request.time < resource.data.expiresAt;
}
```

#### Step 3: 캐싱 계층 추가 (Phase 3 연계)

```dart
// Repository에서 Idempotency 기록 캐싱 (Phase 3 UnifiedCacheService)
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  required String eventId,
}) async {
  // Phase 3 캐시로 Idempotency 기록 조회
  final cachedResult = await _cacheService.get<String>('idempotency:$eventId');
  if (cachedResult != null) {
    return right(cachedResult);  // ✅ Firestore 조회 스킵
  }

  // Idempotency 실행
  return _idempotencyService.executeIdempotent<String>(
    // ...
  ).then((result) async {
    if (result.isRight()) {
      final postId = result.getOrElse((l) => '');
      // 캐시에 저장 (10분)
      await _cacheService.set('idempotency:$eventId', postId, ttl: Duration(minutes: 10));
    }
    return result;
  });
}
```

**성능 개선 예상**: +50ms → +10ms (80% 개선)

### 롤백 시나리오 3: Idempotency 로직 복잡도 증가

**증상**:
- 코드 가독성 저하
- 유지보수 어려움
- 새로운 메서드 추가 시 Idempotency 적용 누락

**해결책**: 롤백 대신 **Annotation 기반 AOP** 도입 (Phase 5 고려)

```dart
// Future Phase 5: Annotation 기반 Idempotency
@Idempotent(
  entityType: 'post_create',
  entityIdField: 'post.id',
  userIdField: 'post.userId',
)
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
  required String eventId,
}) async {
  // Idempotency 로직 자동 적용 (AOP)
  final data = _mapper.toCreateDocument(post);
  // ...
}
```

**Note**: Dart는 AOP 직접 지원 안함 → Code Generation으로 구현 필요

### 롤백 시나리오 4: Production 긴급 상황

**증상**:
- Idempotency 버그로 게시물 생성 실패
- 사용자 불만 급증
- 긴급 롤백 필요

**긴급 롤백 절차** (Hot-Fix):

#### Step 1: Feature Flag로 Idempotency 비활성화 (5분)

```dart
// Repository에 Feature Flag 추가
class PostCreationRepositoryV2Impl {
  final bool _enableIdempotency = false;  // ✅ 긴급 비활성화

  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId,
  }) async {
    if (!_enableIdempotency) {
      // ✅ Phase 3 로직으로 우회
      final data = _mapper.toCreateDocument(post);
      final result = await _dataSource.createPost(data);
      return right(result['id'] as String);
    }

    // Idempotency 로직 (비활성화됨)
    return _idempotencyService.executeIdempotent<String>(/*...*/);
  }
}
```

#### Step 2: Hot-Fix 배포 (10분)

```bash
# 1. Flutter Web 빌드 (가장 빠름)
flutter build web --release

# 2. Firebase Hosting 배포
firebase deploy --only hosting

# 3. 사용자에게 새로고침 안내
```

#### Step 3: 모니터링 (30분)

```bash
# Firebase Analytics 확인
firebase analytics:events

# Crashlytics 확인
firebase crashlytics:issues

# 게시물 생성 성공률 확인 (>95%)
```

#### Step 4: 근본 원인 분석 및 수정 (1-2시간)

```dart
// 버그 수정 후 재배포
class PostCreationRepositoryV2Impl {
  final bool _enableIdempotency = true;  // ✅ 재활성화
  // ...
}
```

**총 소요 시간**: 2시간 이내
**사용자 영향**: 최소화 (Feature Flag로 즉시 우회)

---

**Part 1/2 종료**

다음 문서: [PHASE_4_2.md](./PHASE_4_2.md) - 완료 체크리스트, 영향 분석, 학습 자료, 다음 단계
