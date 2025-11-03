# Creation Feature - Phase 5: Extension Pattern (Part 1/3)

> **문서 버전**: 1.0.0
> **작성일**: 2025-11-03
> **대상 Feature**: Creation Feature
> **Phase**: 5 - Extension Pattern (Firebase-Centric v2.0)
> **Part**: 1/3 (섹션 1-3: 개요, 분석, 목표)

---

## 📋 목차 (Part 1)

- [개요](#-개요)
- [현재 상태 분석](#-현재-상태-분석)
- [마이그레이션 목표](#-마이그레이션-목표)

**Part 2 문서**: [PHASE_5_2.md](./PHASE_5_2.md) - 단계별 가이드, Before/After 코드
**Part 3 문서**: [PHASE_5_3.md](./PHASE_5_3.md) - 테스트, 롤백, 일정

---

## 📋 개요

### Phase 5의 목적

**Firebase-Centric v2.0 아키텍처**를 완성하여 Creation Feature의 Data Layer를 단순화하고, 코드 품질과 유지보수성을 극대화합니다.

### Firebase-Centric v2.0 철학

```
Legacy Architecture (Phase 1-4):
Firestore → DataSource → DTO → Mapper → Entity (4단계)

Firebase-Centric v2.0 (Phase 5):
Firestore → Extension → Entity (1단계) ✨
```

**핵심 원칙**:
1. **직접성(Directness)**: Firebase SDK를 Repository에서 직접 사용
2. **단순성(Simplicity)**: 중간 추상화 계층 제거
3. **타입 안전성(Type Safety)**: Extension으로 컴파일 타임 검증
4. **일관성(Consistency)**: 모든 Feature가 동일한 패턴 사용

### Extension Pattern 이점

#### 1. **코드 감소** (60% 감소)
```dart
// ❌ Legacy (4단계, 40줄)
class PostCreationDataSource {
  Future<Map<String, dynamic>> createPost(Map data) {...}  // 10줄
}
class PostCreationDto {
  factory PostCreationDto.fromFirestore(Map data) {...}    // 15줄
}
class CreationFirestoreMapper {
  PostCreation toEntity(PostCreationDto dto) {...}         // 15줄
}

// ✅ Extension (1단계, 15줄)
extension PostCreationFirestore on PostCreation {
  static PostCreation fromFirestore(DocumentSnapshot doc) {...}  // 10줄
  Map<String, dynamic> toFirestore() {...}                       // 5줄
}
```

#### 2. **타입 안전성** (컴파일 타임 검증)
```dart
// ❌ Legacy (런타임 에러 가능)
final dto = PostCreationDto.fromFirestore(data);  // data가 null이면?
final entity = mapper.toEntity(dto);               // dto 필드 누락이면?

// ✅ Extension (컴파일 타임 검증)
final post = PostCreationFirestore.fromFirestore(doc);
// ↑ Freezed + Extension = 모든 필드 보장
```

#### 3. **Phase 1-4 통합** (시너지 효과)
```dart
// Phase 1 (Freezed) + Phase 5 (Extension)
@freezed
class PostCreation with _$PostCreation {
  // Freezed가 toJson() 자동 생성 → Extension이 toFirestore()에서 활용
}

// Phase 2 (Either) + Phase 5 (Extension)
Future<Either<CreationFailure, PostCreation>> getPost(String id) async {
  try {
    final doc = await _firestore.collection('posts').doc(id).get();
    return right(PostCreationFirestore.fromFirestore(doc));  // 타입 안전
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message));
  }
}

// Phase 3 (Cache) + Phase 5 (Extension)
final cached = await cacheService.getPost(id);
if (cached != null) return right(cached);  // Extension으로 변환된 Entity 캐싱

// Phase 4 (Idempotency) + Phase 5 (Extension)
final post = PostCreation(..., eventId: uuid.v4());
await _firestore.collection('posts').doc().set(
  post.toFirestore(),  // Extension이 eventId 포함
);
```

### Creation Feature 특수성

Creation Feature는 Chat Feature보다 복잡한 구조를 가지고 있어, Extension Pattern 적용 시 더 큰 이점을 얻습니다:

#### 복잡도 비교: Chat vs Creation

| 구분 | Chat Feature | Creation Feature | 차이 |
|------|--------------|------------------|------|
| **Repository 개수** | 1개 | 8개 | **8배** |
| **Entity 개수** | 2개 (Chat, Message) | 4개 (PostCreation, MediaInfo, TargetAudience, MediaContent) | **2배** |
| **DataSource 개수** | 1개 | 2개 (Post + Storage) | **2배** |
| **DTO 개수** | 2개 | 6개 | **3배** |
| **Mapper 개수** | 2개 | 3개 | **1.5배** |
| **Nested Structures** | Vote Card (10 fields) | PostOption, VoteConfiguration, TargetAudience | **3배** |
| **Media Handling** | Simple URLs | **Sealed Class** (ImageInfo \| VideoInfo) | **복잡** |
| **Migration Time** | 5-7일 | **10-12일** | **2배** |

#### Creation Feature 특수 요구사항

**1. Sealed Class 지원 (MediaInfo)**
```dart
@freezed
sealed class MediaInfo with _$MediaInfo {
  const factory MediaInfo.image({...}) = ImageInfo;
  const factory MediaInfo.video({...}) = VideoInfo;
}

// Extension이 Sealed Class when() 활용 필요
extension MediaInfoFirestore on MediaInfo {
  Map<String, dynamic> toFirestore() {
    return when(
      image: (info) => {'type': 'image', ...},
      video: (info) => {'type': 'video', ...},
    );
  }
}
```

**2. 복잡한 Nested Structures**
```dart
class PostCreation {
  final PostOption optionA;         // ← Nested structure
  final PostOption optionB;         // ← Nested structure
  final VoteConfiguration voteConfig;  // ← Nested structure
  final TargetAudience targetAudience; // ← Nested structure with criteria Map
}

// Extension이 중첩 변환 처리 필요
extension PostCreationFirestore on PostCreation {
  static PostCreation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostCreation(
      optionA: _parsePostOption(data['optionA']),  // Helper 함수
      optionB: _parsePostOption(data['optionB']),
      voteConfig: _parseVoteConfig(data['voteConfiguration']),
      targetAudience: TargetAudienceFirestore.fromMap(data['targetAudience']),
    );
  }
}
```

**3. Storage + Firestore 이중 처리**
```dart
// Firestore: 메타데이터 저장 (Extension)
await _firestore.collection('posts').doc(id).set(
  post.toFirestore(),
);

// Storage: 파일 업로드 (별도 처리)
final ref = _storage.ref().child('posts/$id/image.jpg');
await ref.putFile(file);
final url = await ref.getDownloadURL();
```

**4. Repository 간 의존성**
```
PostCreationRepositoryV2Impl
  ├── MediaRepositoryImpl
  │   └── MediaInfoFirestore (sealed class)
  ├── MediaUploadRepositoryImpl
  │   └── MediaRepositoryImpl
  └── TargetAudienceRepositoryImpl
      └── TargetAudienceFirestore
```

### 코드 감소 목표

Creation Feature는 Chat Feature(63% 감소)보다 약간 낮은 **60% 감소**를 목표로 합니다:

```
Chat Feature (Phase 5 달성):
- Before: 2,444 lines
- After: 904 lines
- Reduction: 63% (1,540 lines)

Creation Feature (Phase 5 목표):
- Before: 3,873 lines (Chat의 158%)
- After: 1,560 lines (Chat의 173%)
- Reduction: 60% (2,313 lines)
```

**Chat보다 감소율이 낮은 이유**:
1. **Sealed Class 로직 복잡도**: MediaInfo when() 패턴 매칭 코드
2. **Nested Structures**: PostOption, VoteConfiguration 변환 Helper 함수
3. **Storage 처리**: 파일 업로드 로직은 Extension으로 대체 불가

### Phase 1-4 통합 효과

Phase 5는 이전 Phase들의 성과를 통합하여 시너지를 냅니다:

#### Phase 1 (Freezed) + Phase 5 (Extension)
- **Phase 1 달성**: MediaInfo Sealed Class, PostCreation Freezed 적용 (85% 코드 감소)
- **Phase 5 통합**: Freezed의 `toJson()`과 Extension의 `toFirestore()` 결합
- **효과**: Firestore 변환 로직 자동화

#### Phase 2 (Either Pattern) + Phase 5 (Extension)
- **Phase 2 달성**: `Result<T>` → `Either<Failure, T>` 전환, 타입 안전 에러 처리
- **Phase 5 통합**: Extension에서 Either 기반 변환 에러 처리
- **효과**: 컴파일 타임 에러 검증

#### Phase 3 (Cache Integration) + Phase 5 (Extension)
- **Phase 3 달성**: UnifiedCacheService 3-Layer 캐싱, Draft 자동 저장
- **Phase 5 통합**: Extension으로 변환된 Entity를 직접 캐싱
- **효과**: 캐시 히트율 60%+ 유지, Firestore 비용 40% 절감

#### Phase 4 (Idempotency) + Phase 5 (Extension)
- **Phase 4 달성**: IdempotencyService로 중복 작업 방지, UUID eventId 패턴
- **Phase 5 통합**: Extension이 eventId 필드를 Firestore에 자동 포함
- **효과**: Firestore 트랜잭션 + Extension의 간결한 통합

**통합 효과 요약**:
```dart
// ✨ Phase 1-5 통합 예시: 게시물 생성
@riverpod  // Phase 2: Riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  @override
  FutureOr<Either<CreationFailure, PostCreation?>> build() async {
    return right(null);
  }

  Future<void> createPost(PostCreation post) async {
    state = const AsyncValue.loading();

    // Phase 4: Idempotency - eventId 생성
    final eventId = const Uuid().v4();
    final postWithEvent = post.copyWith(eventId: eventId);  // Phase 1: Freezed

    // Phase 3: Cache - Draft 저장
    await _cacheService.putDraft(postWithEvent);

    // Phase 5: Extension - Firestore 직접 저장
    final result = await _repository.createPost(post: postWithEvent);

    // Phase 2: Either - 타입 안전 에러 처리
    state = AsyncValue.data(result);
  }
}

// Repository (Phase 5)
class PostCreationRepositoryV2Impl {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;  // Phase 3

  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  }) async {
    try {
      // Phase 4: Idempotency 확인
      if (post.eventId != null) {
        final existing = await _checkDuplicate(post.eventId!);
        if (existing != null) return right(existing);
      }

      // Phase 5: Extension으로 Firestore 저장
      final docRef = _firestore.collection('posts').doc();
      await docRef.set(post.toFirestore());  // ← Extension!

      // Phase 3: Cache에 저장
      await _cacheService.putPost(docRef.id, post);

      return right(docRef.id);  // Phase 2: Either
    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message));
    }
  }
}
```

---

## 🔍 현재 상태 분석

### 2.1. 현재 아키텍처 구조

Creation Feature의 Data Layer는 현재 **4-Layer 구조**를 가지고 있습니다:

```
lib/features/creation/data/
├── datasources/               # DataSource Layer (4 files, 500 lines)
│   ├── firebase_post_creation_datasource.dart       (289 lines)
│   ├── firebase_storage_datasource.dart             (129 lines)
│   └── interfaces/
│       ├── i_post_creation_datasource.dart          (34 lines)
│       └── i_storage_datasource.dart                (48 lines)
│
├── models/                    # DTO Layer (6 files, 447 lines)
│   ├── post_creation_dto.dart                       (58 lines)
│   ├── content_moderation_dto.dart                  (87 lines)
│   ├── video_result_dto.dart                        (130 lines)
│   ├── target_audience_dto.dart                     (67 lines)
│   ├── image_upload_dto.dart                        (29 lines)
│   └── image_result_dto.dart                        (76 lines)
│
├── mappers/                   # Mapper Layer (3 files, 453 lines)
│   ├── creation_firestore_mapper.dart               (294 lines)
│   ├── post_creation_mapper.dart                    (63 lines)
│   └── target_audience_mapper.dart                  (96 lines)
│
└── repositories/              # Repository Layer (8 files, 2,473 lines)
    ├── post_creation_repository_v2_impl.dart        (399 lines)
    ├── media_repository_impl.dart                   (404 lines)
    ├── media_upload_repository_impl.dart            (252 lines)
    ├── content_moderation_repository_impl.dart      (298 lines)
    ├── content_visibility_repository_impl.dart      (361 lines)
    ├── image_processing_repository_impl.dart        (219 lines)
    ├── target_audience_repository_impl.dart         (253 lines)
    └── content_metrics_repository_impl.dart         (287 lines)

Total: 21 files, 3,873 lines
```

### 2.2. 삭제 예정 파일 상세

Phase 5에서 삭제될 파일 목록 (13개, ~1,400줄):

#### DataSource Layer (4 files, 500 lines) ❌

**1. `firebase_post_creation_datasource.dart` (289줄)**
```dart
/// Legacy DataSource - Phase 5에서 삭제 예정
class FirebasePostCreationDataSource implements IPostCreationDataSource {
  final FirebaseFirestore _firestore;

  // ❌ 문제: Repository가 직접 Firestore 호출하면 불필요한 추상화
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> data) async {
    final docRef = _firestore.collection('posts').doc();
    await docRef.set(data);
    return {'id': docRef.id};
  }

  Future<DocumentSnapshot> getPost(String id) async {
    return await _firestore.collection('posts').doc(id).get();
  }

  // ... 15+ methods (289줄)
}
```

**삭제 이유**:
- Repository에서 FirebaseFirestore를 직접 주입받으면 DataSource 불필요
- Extension Pattern으로 Firestore ↔ Entity 변환 처리

**2. `firebase_storage_datasource.dart` (129줄)**
```dart
/// Legacy Storage DataSource - Phase 5에서 삭제 예정
class FirebaseStorageDataSource implements IStorageDataSource {
  final FirebaseStorage _storage;

  // ❌ 문제: 파일 업로드는 Repository에서 직접 처리 가능
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ... 10+ methods (129줄)
}
```

**3. `i_post_creation_datasource.dart` (34줄) - Interface**
```dart
abstract class IPostCreationDataSource {
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> data);
  Future<DocumentSnapshot> getPost(String id);
  // ... 8+ methods
}
```

**4. `i_storage_datasource.dart` (48줄) - Interface**
```dart
abstract class IStorageDataSource {
  Future<String> uploadImage(File file, String path);
  Future<void> deleteFile(String path);
  // ... 5+ methods
}
```

#### DTO Layer (6 files, 447 lines) ❌

**1. `post_creation_dto.dart` (58줄)**
```dart
/// Legacy DTO - Phase 5에서 삭제 예정
class PostCreationDto {
  final String? id;
  final String userId;
  final String questionTitle;
  // ... 15+ fields

  // ❌ 문제: Entity (PostCreation)와 거의 동일한 필드
  factory PostCreationDto.fromFirestore(Map<String, dynamic> data, String id) {
    return PostCreationDto(
      id: id,
      userId: data['userId'] as String? ?? '',
      questionTitle: data['questionTitle'] as String? ?? '',
      // ... 중복된 변환 로직 (Mapper에서도 동일 작업)
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'questionTitle': questionTitle,
      // ... 중복된 변환 로직
    };
  }
}
```

**삭제 이유**:
- PostCreation Entity (Phase 1 Freezed 적용)와 필드가 거의 동일
- Extension Pattern으로 Entity ↔ Firestore 직접 변환 가능

**2. `content_moderation_dto.dart` (87줄)**
```dart
/// Legacy DTO - AI 응답 변환용
class ContentModerationDto {
  final bool isApproved;
  final List<String> flaggedWords;
  final double toxicityScore;
  // ... AI 응답 필드

  factory ContentModerationDto.fromAI(Map<String, dynamic> aiResponse) {
    // AI 응답 → DTO 변환
  }
}
```

**3. `video_result_dto.dart` (130줄) - 가장 큼**
```dart
/// Legacy DTO - VideoInfo Sealed Class로 대체 가능
class VideoResultDto {
  final String id;
  final String url;
  final int? duration;
  final String? thumbnailUrl;
  // ... 20+ fields

  // ❌ 문제: Phase 1에서 VideoInfo Sealed Class 이미 존재
  factory VideoResultDto.fromFirestore(Map<String, dynamic> data, String id) {
    // DTO → Entity 중간 변환 불필요
  }
}
```

**4. `target_audience_dto.dart` (67줄)**
```dart
/// Legacy DTO - TargetAudience Entity와 중복
class TargetAudienceDto {
  final List<String> gender;
  final Map<String, dynamic> ageRange;
  final List<String> interests;

  factory TargetAudienceDto.fromMap(Map<String, dynamic> data) {
    // Map → DTO 변환 (Extension으로 대체 가능)
  }
}
```

**5. `image_upload_dto.dart` (29줄)**
**6. `image_result_dto.dart` (76줄)**

#### Mapper Layer (3 files, 453 lines) ❌

**1. `creation_firestore_mapper.dart` (294줄) - 가장 큼**
```dart
/// Legacy Mapper - Phase 5에서 삭제 예정
class CreationFirestoreMapper {
  // ❌ 문제: DTO → Entity 변환 (Extension으로 대체 가능)
  PostCreation extractPostCreation(Map<String, dynamic> data, String id) {
    return PostCreation(
      id: id,
      userId: data['userId'] as String? ?? '',
      questionTitle: data['questionTitle'] as String? ?? '',
      optionA: _extractPostOption(data['optionA']),  // ← Helper 함수
      optionB: _extractPostOption(data['optionB']),
      // ... 30+ fields 변환 (294줄)
    );
  }

  Map<String, dynamic> toCreateDocument(PostCreation post) {
    return {
      'userId': post.userId,
      'questionTitle': post.questionTitle,
      'optionA': _optionToMap(post.optionA),
      'optionB': _optionToMap(post.optionB),
      // ... 30+ fields 변환
    };
  }

  // Helper functions (100+ lines)
  PostOption _extractPostOption(dynamic data) {...}
  Map<String, dynamic> _optionToMap(PostOption option) {...}
  // ... 10+ helper methods
}
```

**삭제 이유**:
- Extension Pattern으로 Helper 함수들을 static method로 이동
- PostCreation Entity에 직접 변환 로직 추가

**2. `post_creation_mapper.dart` (63줄)**
```dart
/// Legacy Mapper - DTO ↔ Entity 변환
class PostCreationMapper {
  PostCreation toEntity(PostCreationDto dto) {
    // DTO → Entity 변환 (불필요)
  }

  PostCreationDto toDto(PostCreation entity) {
    // Entity → DTO 변환 (불필요)
  }
}
```

**3. `target_audience_mapper.dart` (96줄)**
```dart
/// Legacy Mapper - TargetAudience 변환
class TargetAudienceMapper {
  TargetAudience toEntity(TargetAudienceDto dto) {
    return TargetAudience(
      gender: dto.gender,
      ageRange: _parseAgeRange(dto.ageRange),
      // ... 중복 로직
    );
  }

  Map<String, dynamic> toStorageFormat(TargetAudience entity) {
    // Extension으로 대체 가능
  }
}
```

**삭제 요약**:
```
총 삭제: 13 files, ~1,400 lines
├── DataSource: 4 files, 500 lines
├── DTO: 6 files, 447 lines
└── Mapper: 3 files, 453 lines
```

### 2.3. 현재 문제점

#### 문제 1: 4단계 변환 과정 (과도한 추상화)

```dart
// ❌ Legacy 흐름: createPost() 예시
class PostCreationRepositoryV2Impl {
  final IPostCreationDataSource _dataSource;  // ← 1. DataSource 의존성
  final CreationFirestoreMapper _mapper;      // ← 2. Mapper 의존성

  Future<String> createPost({required PostCreation post}) async {
    // Step 1: Entity → Map (Mapper)
    final data = _mapper.toCreateDocument(post);

    // Step 2: Map → Firestore (DataSource)
    final result = await _dataSource.createPost(data);

    // Step 3: Extract ID
    final postId = result['id'] as String;

    return postId;
  }
}

// Firestore 쓰기 1번을 위해 3단계 변환!
```

**문제점**:
- **과도한 추상화**: DataSource는 Firestore를 래핑하는 것 외에 역할 없음
- **성능 저하**: Map 변환 3회 (Entity → Mapper Map → DataSource Map → Firestore)
- **디버깅 어려움**: 어느 단계에서 문제인지 추적 복잡

#### 문제 2: 13개 파일에 중복된 Firestore 변환 로직

**DTO별 중복 패턴**:
```dart
// post_creation_dto.dart
factory PostCreationDto.fromFirestore(Map<String, dynamic> data, String id) {
  return PostCreationDto(
    userId: data['userId'] as String? ?? '',  // ← 중복 패턴
    questionTitle: data['questionTitle'] as String? ?? '',
  );
}

// video_result_dto.dart
factory VideoResultDto.fromFirestore(Map<String, dynamic> data, String id) {
  return VideoResultDto(
    id: id,
    url: data['url'] as String? ?? '',  // ← 동일한 패턴
    duration: data['duration'] as int?,
  );
}

// target_audience_dto.dart
factory TargetAudienceDto.fromMap(Map<String, dynamic> data) {
  return TargetAudienceDto(
    gender: (data['gender'] as List?)?.cast<String>() ?? [],  // ← 중복 로직
    interests: (data['interests'] as List?)?.cast<String>() ?? [],
  );
}
```

**문제점**:
- **중복 코드**: String/List 파싱 로직이 6개 DTO에 중복
- **유지보수 어려움**: 파싱 로직 수정 시 6개 파일 동시 수정 필요
- **테스트 부담**: 13개 파일 모두 테스트 필요

#### 문제 3: MediaInfo Sealed Class를 DTO로 변환하는 불필요한 과정

```dart
// ❌ Legacy 흐름: MediaInfo 조회
Stream<List<MediaInfo>> queryImages({...}) {
  return query.snapshots().map((snapshot) {
    return snapshot.docs
      // Step 1: Firestore → DTO
      .map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
      // Step 2: DTO → Entity (Manual Mapper)
      .map((dto) => _dtoToImageInfo(dto))
      .toList();
  });
}

ImageInfo _dtoToImageInfo(ImageResultDto dto) {
  return ImageInfo(
    id: dto.id,
    url: dto.url,
    width: null,  // ❌ DTO 필드 부족! (width가 DTO에 없음)
    height: null,
    aspectRatio: null,
    size: dto.size,
    uploadedAt: dto.uploadedAt,
    uploadedBy: dto.uploadedBy,
  );
}
```

**문제점**:
- **Phase 1 미활용**: MediaInfo는 이미 Freezed Sealed Class인데 DTO로 중간 변환
- **필드 누락**: DTO에 width, height, aspectRatio 필드가 없어 null 대입
- **타입 안전성 저하**: Sealed Class when() 패턴 매칭 불가

#### 문제 4: TargetAudience 복잡한 3단계 변환

```dart
// ❌ Legacy 흐름: TargetAudience 저장
Future<void> saveTargetAudience(TargetAudience audience) async {
  // Step 1: Domain → Map (Service)
  final map = _targetAudienceService.convertToStorageFormat(audience);

  // Step 2: Map → DTO
  final dto = TargetAudienceDto.fromMap(map);

  // Step 3: DTO → Firestore
  await _dataSource.saveTargetAudience(dto.toFirestore());
}
```

**문제점**:
- **3번 변환**: Entity → Map → DTO → Firestore
- **Service 의존성**: Repository가 Service에 의존 (아키텍처 위반)
- **복잡한 criteria Map**: TargetAudience의 criteria 필드(Map<String, dynamic>)가 3단계 변환 중 손실 가능

### 2.4. Before 코드 예시 (현재 상태)

#### 예시 1: PostCreation 생성 (createPost)

**파일**: `lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart:36-75`

```dart
/// Legacy Repository Implementation (Phase 4 상태)
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;              // ← DataSource 의존성
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();  // ← Mapper 의존성

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // ❌ Before: 4단계 변환
  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      // Step 1: Entity → Map (Mapper)
      final data = _mapper.toCreateDocument(post);
      data['postCreatedDate'] = post.createdAt;

      // Step 2: Map → Firestore (DataSource)
      final result = await _dataSource.createPost(data);

      // Step 3: Extract ID
      final postId = result['id'] as String;

      return postId;
    } catch (e) {
      throw CreationException('Failed to create post: $e');
    }
  }
}
```

**문제점**:
- DataSource + Mapper 이중 의존성
- Entity를 3번 변환 (Entity → Mapper Map → DataSource Map → Firestore)
- 총 코드: 40줄 (의존성 주입 25줄 + 로직 15줄)

#### 예시 2: MediaInfo 조회 (Sealed Class)

**파일**: `lib/features/creation/data/repositories/media_repository_impl.dart:26-65`

```dart
/// Legacy MediaRepository (Phase 4 상태)
class MediaRepositoryImpl implements IMediaRepository {
  final IStorageDataSource _storageDataSource;  // ← DataSource 의존성
  final FirebaseFirestore _firestore;

  // ❌ Before: DTO → Entity 수동 변환
  ImageInfo _dtoToImageInfo(ImageResultDto dto) {
    return ImageInfo(
      id: dto.id,
      url: dto.url,
      parentId: dto.parentId,
      width: null,  // ❌ DTO에 필드 없음!
      height: null,
      aspectRatio: null,
      size: dto.size,
      uploadedAt: dto.uploadedAt,
      uploadedBy: dto.uploadedBy,
    );
  }

  @override
  Stream<List<ImageInfo>> queryImages({
    required String parentId,
    int? limit,
  }) {
    var query = _firestore
        .collection('media')
        .where('parentId', isEqualTo: parentId)
        .where('type', isEqualTo: 'image')
        .orderBy('uploadedAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          // Step 1: Firestore → DTO
          .map((doc) => ImageResultDto.fromFirestore(doc.data(), doc.id))
          // Step 2: DTO → Entity (Manual Mapper)
          .map((dto) => _dtoToImageInfo(dto))
          .toList();
    });
  }
}
```

**문제점**:
- DTO에 width, height, aspectRatio 필드 누락 → null 강제
- Sealed Class MediaInfo를 활용 못함 (ImageInfo vs VideoInfo 구분 불가)
- 총 코드: 25줄 (DTO 변환 10줄 + Manual Mapper 15줄)

#### 예시 3: TargetAudience 저장

**파일**: `lib/features/creation/data/repositories/target_audience_repository_impl.dart:15-45`

```dart
/// Legacy TargetAudienceRepository (Phase 4 상태)
class TargetAudienceRepositoryImpl implements ITargetAudienceRepository {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService _targetAudienceService;  // ← Service 의존성
  final TargetAudienceMapper _mapper;                   // ← Mapper 의존성

  // ❌ Before: 3단계 변환
  @override
  Future<void> saveTargetAudience({
    required String postId,
    required TargetAudience audience,
  }) async {
    try {
      // Step 1: Entity → Map (Service)
      final map = _targetAudienceService.convertToStorageFormat(audience);

      // Step 2: Map → DTO
      final dto = TargetAudienceDto.fromMap(map);

      // Step 3: DTO → Firestore (DataSource)
      await _dataSource.updatePost(postId, {
        'targetAudience': dto.toFirestore(),
      });
    } catch (e) {
      throw CreationException('Failed to save target audience: $e');
    }
  }
}
```

**문제점**:
- Service + Mapper + DataSource 삼중 의존성
- 3번 변환 (Entity → Service Map → DTO → Firestore)
- criteria Map<String, dynamic> 필드가 변환 중 손실 가능

---

## 🎯 마이그레이션 목표

### 3.1. 정량적 목표

#### 코드 감소 목표: 60% (2,313줄 감소)

```
현재 상태 (Phase 4):
├── DataSource: 500 lines
├── DTO: 447 lines
├── Mapper: 453 lines
└── Repository: 2,473 lines
Total: 3,873 lines (21 files)

목표 상태 (Phase 5):
├── Extension: 360 lines (new)
└── Repository: 1,200 lines (51% 감소)
Total: 1,560 lines (11 files)

순 감소: 2,313 lines (60% 감소)
```

#### 파일 개수 감소: 47% (10개 파일 감소)

```
삭제:
├── DataSource: 4 files
├── DTO: 6 files
└── Mapper: 3 files
Total: 13 files 삭제

생성:
├── Extension: 3 files (post_creation, media_info, target_audience)

결과:
Before: 21 files
After: 11 files (21 - 13 + 3)
Net: -10 files (47% 감소)
```

#### Repository 코드 감소: 51% (1,273줄 감소)

```
Before: 2,473 lines (8 repositories)
After: 1,200 lines (8 repositories)
Reduction: 1,273 lines (51% 감소)

Repository별 감소 예상:
├── PostCreationRepositoryV2Impl: 399 → 180줄 (55% 감소)
├── MediaRepositoryImpl: 404 → 200줄 (50% 감소)
├── MediaUploadRepositoryImpl: 252 → 120줄 (52% 감소)
├── ContentModerationRepositoryImpl: 298 → 150줄 (50% 감소)
├── ContentVisibilityRepositoryImpl: 361 → 180줄 (50% 감소)
├── ImageProcessingRepositoryImpl: 219 → 110줄 (50% 감소)
├── TargetAudienceRepositoryImpl: 253 → 120줄 (53% 감소)
└── ContentMetricsRepositoryImpl: 287 → 140줄 (51% 감소)
```

### 3.2. 정성적 목표

#### 목표 1: Firebase-Centric v2.0 아키텍처 완성

**Before (Phase 4)**:
```
Firestore → DataSource → DTO → Mapper → Entity (4단계)
        ↓
    Repository는 DataSource/Mapper에 의존
```

**After (Phase 5)**:
```
Firestore → Extension → Entity (1단계) ✨
        ↓
    Repository는 FirebaseFirestore/FirebaseStorage에 직접 의존
```

**달성 기준**:
- ✅ 모든 Repository가 Firebase SDK 직접 주입
- ✅ DataSource/DTO/Mapper 계층 완전 제거
- ✅ Extension Pattern으로 변환 로직 통합

#### 목표 2: MediaInfo Sealed Class 직접 활용

**Before (Phase 4)**:
```dart
// ❌ DTO로 중간 변환
ImageResultDto → Manual Mapper → ImageInfo (필드 누락)
```

**After (Phase 5)**:
```dart
// ✅ Sealed Class 직접 변환
Firestore Map → MediaInfoFirestore.fromFirestore() → ImageInfo | VideoInfo
```

**달성 기준**:
- ✅ MediaInfo Extension이 when() 패턴 매칭 활용
- ✅ ImageInfo, VideoInfo 모든 필드 보존
- ✅ Sealed Class 타입 안전성 100% 활용

#### 목표 3: Extension Pattern 일관성

**모든 Entity에 동일한 패턴 적용**:
```dart
// Pattern Template
extension {EntityName}Firestore on {EntityName} {
  /// Firestore → Entity
  static {EntityName} fromFirestore(DocumentSnapshot doc) {...}

  /// Entity → Firestore
  Map<String, dynamic> toFirestore() {...}

  /// Helper Functions
  static T _parseField(dynamic value) {...}
}
```

**달성 기준**:
- ✅ PostCreation, MediaInfo, TargetAudience 모두 동일 패턴
- ✅ Helper 함수 네이밍 일관성 (_parseInt, _parseStringList, _parseDateTime)
- ✅ Null-safe 파싱 100% 적용

#### 목표 4: 아키텍처 단순화

**Before (의존성 그래프)**:
```
Repository
  ├── DataSource (interface)
  │   └── DataSource Impl
  ├── Mapper
  │   └── DTO
  └── Service (일부)
```

**After (의존성 그래프)**:
```
Repository
  ├── FirebaseFirestore / FirebaseStorage (SDK 직접)
  └── Extension (static methods, 의존성 없음)
```

**달성 기준**:
- ✅ Repository 의존성 50% 감소
- ✅ DI 모듈 30% 단순화
- ✅ 테스트 Mock 40% 감소

### 3.3. Phase 1-4 통합 효과

#### Phase 1 (Freezed) + Phase 5 (Extension)

**통합 전**:
```dart
// Phase 1: Freezed만 적용
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({...}) = _PostCreation;

  factory PostCreation.fromJson(Map<String, dynamic> json) =>
      _$PostCreationFromJson(json);  // JSON Serialization만
}
```

**통합 후**:
```dart
// Phase 1 + Phase 5: Freezed + Extension
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({...}) = _PostCreation;

  // Phase 1: JSON Serialization (이미 있음)
  factory PostCreation.fromJson(Map<String, dynamic> json) =>
      _$PostCreationFromJson(json);
}

// Phase 5: Firestore Serialization (새로 추가)
extension PostCreationFirestore on PostCreation {
  static PostCreation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    // Freezed의 copyWith() 활용
    return PostCreation.fromJson(data).copyWith(id: doc.id);
  }

  Map<String, dynamic> toFirestore() {
    // Freezed의 toJson() 활용
    final json = toJson();
    json['createdAt'] = Timestamp.fromDate(createdAt);  // Timestamp 변환만 추가
    return json;
  }
}
```

**효과**:
- Freezed의 toJson()을 Extension에서 재활용
- copyWith()로 불변 업데이트 간결화
- JSON + Firestore 이중 직렬화 지원

#### Phase 2 (Either) + Phase 5 (Extension)

**통합 전**:
```dart
// Phase 2: Either만 적용
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  try {
    final data = _mapper.toCreateDocument(post);  // ← Mapper 필요
    final result = await _dataSource.createPost(data);  // ← DataSource 필요
    return right(result['id']);
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

**통합 후**:
```dart
// Phase 2 + Phase 5: Either + Extension
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  try {
    final docRef = _firestore.collection('posts').doc();
    await docRef.set(post.toFirestore());  // ← Extension 직접!
    return right(docRef.id);
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message));  // 타입 안전
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

**효과**:
- Extension으로 변환 단순화 → Either 에러 처리에 집중
- FirebaseException 타입별 세밀한 에러 처리
- 컴파일 타임 타입 검증 100%

#### Phase 3 (Cache) + Phase 5 (Extension)

**통합 전**:
```dart
// Phase 3: Cache만 적용
Future<Either<CreationFailure, PostCreation?>> getPost(String id) async {
  // 1. Cache 확인
  final cached = await _cacheService.getPost(id);
  if (cached != null) return right(cached);

  // 2. Firestore 조회
  final doc = await _firestore.collection('posts').doc(id).get();

  // 3. Mapper로 변환 (불필요한 단계)
  final data = doc.data() as Map<String, dynamic>? ?? {};
  final post = _mapper.extractPostCreation(data, doc.id);

  // 4. Cache 저장
  await _cacheService.putPost(id, post);
  return right(post);
}
```

**통합 후**:
```dart
// Phase 3 + Phase 5: Cache + Extension
Future<Either<CreationFailure, PostCreation?>> getPost(String id) async {
  // 1. Cache 확인
  final cached = await _cacheService.getPost(id);
  if (cached != null) return right(cached);

  // 2. Firestore 조회 + Extension 변환 (한 번에!)
  final doc = await _firestore.collection('posts').doc(id).get();
  final post = PostCreationFirestore.fromFirestore(doc);  // ← 1단계!

  // 3. Cache 저장
  await _cacheService.putPost(id, post);
  return right(post);
}
```

**효과**:
- Extension으로 변환 1단계 → 캐시 저장 속도 향상
- Entity 직접 캐싱 → 타입 안전성 100%
- 캐시 히트율 60%+ 유지

#### Phase 4 (Idempotency) + Phase 5 (Extension)

**통합 전**:
```dart
// Phase 4: Idempotency만 적용
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  // 1. Idempotency 확인
  if (post.eventId != null) {
    final existing = await _checkDuplicate(post.eventId!);
    if (existing != null) return right(existing);
  }

  // 2. Firestore 저장 (Mapper 사용)
  final data = _mapper.toCreateDocument(post);
  data['eventId'] = post.eventId;  // ← eventId 수동 추가

  final docRef = _firestore.collection('posts').doc();
  await docRef.set(data);

  // 3. Idempotency 기록
  await _idempotencyService.recordEvent(post.eventId!, docRef.id);

  return right(docRef.id);
}
```

**통합 후**:
```dart
// Phase 4 + Phase 5: Idempotency + Extension
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
}) async {
  // 1. Idempotency 확인
  if (post.eventId != null) {
    final existing = await _checkDuplicate(post.eventId!);
    if (existing != null) return right(existing);
  }

  // 2. Firestore 저장 (Extension 자동으로 eventId 포함!)
  final docRef = _firestore.collection('posts').doc();
  await docRef.set(post.toFirestore());  // ← eventId 자동 포함!

  // 3. Idempotency 기록
  await _idempotencyService.recordEvent(post.eventId!, docRef.id);

  return right(docRef.id);
}
```

**효과**:
- Extension이 eventId 자동 처리 → 누락 방지
- Firestore 트랜잭션과 Extension의 간결한 통합
- Idempotency 기록 로직에 집중 가능

**통합 효과 요약**:
```
Phase 1 (Freezed): toJson() 재활용, copyWith() 활용
  +
Phase 2 (Either): 타입 안전 에러 처리 강화
  +
Phase 3 (Cache): Entity 직접 캐싱, 변환 속도 향상
  +
Phase 4 (Idempotency): eventId 자동 처리, 트랜잭션 간결화
  ↓
Phase 5 (Extension): 1단계 변환으로 모든 Phase 시너지 극대화
```

---

## 다음 단계

**Part 2로 계속**: [PHASE_5_2.md](./PHASE_5_2.md)

Part 2에서는 다음 내용을 다룹니다:
- Section 4: 📝 단계별 마이그레이션 가이드 (6 Steps)
  - Step 1: Extension 파일 3개 생성 (post_creation, media_info, target_audience)
  - Step 2: Repository 순차 전환 (8개 Repository)
  - Step 3: Storage DataSource 특수 처리
  - Step 4: Legacy 파일 삭제 (13개)
  - Step 5: DI 모듈 업데이트
  - Step 6: 검증

- Section 5: 📊 Before/After 전체 코드
  - PostCreation 생성/조회
  - MediaInfo 업로드/스트림 (Sealed Class)
  - TargetAudience 저장

---

**문서 메타데이터**:
- **작성자**: AI Assistant (Claude Code)
- **최종 수정**: 2025-11-03
- **관련 문서**:
  - [PHASE_1_FREEZED_MIGRATION.md](./PHASE_1_FREEZED_MIGRATION.md)
  - [PHASE_2_2_MIGRATION_STEPS.md](./PHASE_2_2_MIGRATION_STEPS.md)
  - [PHASE_3_CACHE_INTEGRATION.md](./PHASE_3_CACHE_INTEGRATION.md)
  - [PHASE_4_1.md](./PHASE_4_1.md), [PHASE_4_2.md](./PHASE_4_2.md)
  - [Chat Feature PHASE_5](/lib/features/chat/PHASE_5_EXTENSION_PATTERN.md)
