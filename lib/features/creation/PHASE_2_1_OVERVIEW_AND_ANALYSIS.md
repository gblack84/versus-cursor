# Creation Feature - Phase 2-1: Either Pattern + Riverpod Migration - Overview & Current State Analysis

> **문서 버전**: 2.0.0 (Riverpod 통합)
> **작성일**: 2025-11-03
> **최종 수정**: 2025-11-03
> **Phase**: 2-1 (Either Pattern + Riverpod 도입 - 개요 및 현황 분석)
> **이전 Phase**: [Phase 1 - Freezed Migration](./PHASE_1_EITHER_PATTERN.md)
> **다음 Phase**: [Phase 2-2 - Migration Steps](./PHASE_2_2_MIGRATION_STEPS.md)

---

## 📋 목차

- [1. Phase 2-1 개요](#1-phase-2-1-개요)
  - [1.1 문서 목적](#11-문서-목적)
  - [1.2 Phase 2 전체 구조](#12-phase-2-전체-구조)
  - [1.3 본 문서의 범위](#13-본-문서의-범위)
- [2. Phase 2 배경 및 목적](#2-phase-2-배경-및-목적)
  - [2.1 왜 Either 패턴인가?](#21-왜-either-패턴인가)
  - [2.2 다른 Feature들의 Phase 2](#22-다른-feature들의-phase-2)
  - [2.3 Creation Feature의 특수성](#23-creation-feature의-특수성)
- [3. 현재 상태 분석 (Before)](#3-현재-상태-분석-before)
  - [3.1 UseCase Layer: Result<T> 패턴](#31-usecase-layer-resultt-패턴)
  - [3.2 Repository Layer: Raw Types 패턴](#32-repository-layer-raw-types-패턴)
  - [3.3 Presentation Layer: ChangeNotifier 패턴](#33-presentation-layer-changenotifier-패턴)
  - [3.4 에러 처리 흐름 분석](#34-에러-처리-흐름-분석)
- [4. 목표 상태 (After)](#4-목표-상태-after)
  - [4.1 Either<L,R> 패턴 소개](#41-eitherlr-패턴-소개)
  - [4.2 UseCase Layer 목표](#42-usecase-layer-목표)
  - [4.3 Repository Layer 목표](#43-repository-layer-목표)
  - [4.4 Presentation Layer 변화 없음](#44-presentation-layer-변화-없음)
  - [4.5 에러 처리 흐름 개선](#45-에러-처리-흐름-개선)
- [5. Before/After 비교](#5-beforeafter-비교)
  - [5.1 코드 패턴 비교](#51-코드-패턴-비교)
  - [5.2 에러 처리 비교](#52-에러-처리-비교)
  - [5.3 타입 안전성 비교](#53-타입-안전성-비교)
- [6. 마이그레이션 범위](#6-마이그레이션-범위)
  - [6.1 영향 받는 파일 목록](#61-영향-받는-파일-목록)
  - [6.2 소요 시간 및 난이도](#62-소요-시간-및-난이도)
  - [6.3 의존성 및 순서](#63-의존성-및-순서)
- [7. 다음 단계 안내](#7-다음-단계-안내)

---

## 1. Phase 2-1 개요

### 1.1 문서 목적

본 문서는 **Creation Feature의 Phase 2 마이그레이션** 중 **첫 번째 파트**로, 다음 내용을 다룹니다:

- **Phase 2의 전체 구조** 및 본 문서의 위치
- **Either 패턴 도입의 배경**과 목적
- **현재 상태 (Before)** 의 상세 분석
- **목표 상태 (After)** 의 명확한 정의
- **Before/After 비교**를 통한 변화 이해

> 📌 **Note**: 실제 마이그레이션 단계별 가이드는 [Phase 2-2](./PHASE_2_2_MIGRATION_STEPS.md)에서, 테스트 및 검증은 [Phase 2-3](./PHASE_2_3_TESTING_AND_VALIDATION.md)에서 다룹니다.

### 1.2 Phase 2 전체 구조

Phase 2는 **Either Pattern + Riverpod 마이그레이션**을 모두 다루며, **총 3개의 문서**로 분할되어 있습니다:

```
Phase 2: Either Pattern + Riverpod Migration (총 ~4,000줄)
├── Phase 2-1: Overview & Current State Analysis (~1,200줄) ← 현재 문서
│   ├── Phase 2 배경 및 목적 (Either + Riverpod)
│   ├── 현재 상태 (Before) 분석
│   │   ├── UseCase: Result<T> 패턴
│   │   ├── Repository: Raw Types 패턴
│   │   └── Presentation: ChangeNotifier 패턴 ← 마이그레이션 대상!
│   ├── 목표 상태 (After) 정의
│   │   ├── UseCase: Either<Failure, T> 패턴
│   │   ├── Repository: Either<Failure, T> 패턴
│   │   └── Presentation: Riverpod 2.x @riverpod 패턴 ← NEW!
│   └── Before/After 비교
│
├── Phase 2-2: Migration Steps (~1,500줄)
│   ├── Step 1: Repository 마이그레이션 (Raw → Either)
│   ├── Step 2: UseCase 마이그레이션 (Result<T> → Either)
│   ├── Step 3: Presentation Layer 연동 (Either fold)
│   ├── Step 4: Riverpod 2.x 마이그레이션 (ChangeNotifier → @riverpod) ← NEW!
│   │   ├── FutureProvider 전환 (createPost, uploadMedia)
│   │   ├── StateProvider 전환 (formData, loadingState)
│   │   ├── NotifierProvider 전환 (복잡한 상태 로직)
│   │   └── code generation (build_runner)
│   └── 마이그레이션 체크리스트
│
└── Phase 2-3: Testing & Validation (~1,300줄)
    ├── 단위 테스트 작성 (Either + Riverpod)
    ├── 통합 테스트 작성
    ├── Rollback 절차 (4 Steps)
    └── 최종 검증 체크리스트
```

**주요 변경사항 (v2.0.0)**:
- ✅ **Riverpod 2.x 마이그레이션 추가**: ChangeNotifier → @riverpod 패턴
- ✅ **Step 4 추가**: Presentation Layer Riverpod 전환
- ✅ **파일 개수 정정**: 실제 codebase 검증 반영 (5+8+6+6 = 25 files)
- ✅ **소요 시간 조정**: 5일 (Either) + 2일 (Riverpod) = **7일**

### 1.3 본 문서의 범위

**✅ 본 문서에서 다루는 내용**:
- Phase 2의 목적과 배경 이해
- 현재 코드 상태의 정확한 분석 (실제 코드 기반)
- Either 패턴의 개념 및 장점
- Before/After 코드 비교

**❌ 본 문서에서 다루지 않는 내용**:
- 구체적인 마이그레이션 단계 (→ Phase 2-2)
- 테스트 코드 작성 방법 (→ Phase 2-3)
- Rollback 절차 (→ Phase 2-3)

---

## 2. Phase 2 배경 및 목적

### 2.1 왜 Either 패턴인가?

**Creation Feature**는 현재 **두 가지 에러 처리 패턴**을 혼용하고 있습니다:

1. **UseCase Layer**: `Result<T>` 패턴 (커스텀 구현)
2. **Repository Layer**: **Raw Types** (`Future<String>`, `Future<void>` 등)

이러한 **하이브리드 상태**는 다음 문제를 야기합니다:

#### 문제 1: 타입 안전성 부족 (Repository)

```dart
// ❌ 현재: Repository는 에러를 throw로만 처리 (타입 시스템으로 강제 불가)
abstract class IPostCreationRepositoryV2 {
  Future<String> createPost({required PostCreation post});  // 에러 처리가 타입에 표현되지 않음
  Future<void> updatePost({required String postId, required PostCreation post});
}

// 호출 시 에러 처리 누락 가능
final postId = await repository.createPost(post: post);  // try-catch 없으면 앱 크래시
```

#### 문제 2: 일관성 없는 패턴 (UseCase vs Repository)

```dart
// UseCase: Result<T> 사용
Future<Result<PostCreation>> execute() async {
  return ResultSuccess(postCreation);
}

// Repository: Raw types 사용
Future<String> createPost({required PostCreation post}) async {
  return postId;  // throw Exception on error
}
```

#### 문제 3: 함수형 조합 불가능

```dart
// ❌ 현재: Result<T>는 flatMap, fold 등 함수형 메서드가 부족
final result1 = await useCase1.execute();
if (result1.isFailure) return result1.failureOrNull!;

final result2 = await useCase2.execute(result1.valueOrNull!);
if (result2.isFailure) return result2.failureOrNull!;

// 각 단계마다 수동으로 에러 체크 필요 (보일러플레이트 코드)
```

**Either 패턴의 해결책**:

```dart
// ✅ Either: 타입 안전성 + 함수형 조합 + 일관성
abstract class IPostCreationRepositoryV2 {
  Future<Either<CreationFailure, String>> createPost({required PostCreation post});
  // 반환 타입에 에러 가능성이 명시됨
}

// 함수형 조합 가능 (flatMap으로 에러 자동 전파)
final result = await repository.createPost(post: post)
  .flatMap((postId) => repository.updatePost(postId: postId, post: updated))
  .flatMap((unit) => repository.markAsProcessed(postId: postId));

// 에러는 최종 fold에서 한 번만 처리
result.fold(
  (failure) => handleError(failure),
  (success) => handleSuccess(success),
);
```

### 2.2 다른 Feature들의 Phase 2

Versus Space 프로젝트의 다른 Feature들은 **두 가지 Phase 2 패턴**을 따릅니다:

#### Pattern A: Either Pattern Migration (Auth, Profile)

- **대상**: Request-Response 패턴 Feature (실시간 스트림 없음)
- **마이그레이션**: `Result<T>` → `Either<Failure, T>`
- **상태 관리**: ChangeNotifier 유지 (간단한 상태 관리)
- **소요 시간**: 3-4일

**Auth Feature 예시**:
```dart
// Before
Future<Result<UserProfile>> signIn(String email, String password);

// After
Future<Either<AuthFailure, UserProfile>> signIn(String email, String password);
```

#### Pattern B: Riverpod Migration (Chat, Notifications, Post)

- **대상**: Real-time Stream 패턴 Feature 또는 복잡한 상태 관리 Feature
- **마이그레이션**: ChangeNotifier → Riverpod 2.x (@riverpod)
- **이유**: 실시간 동기화, 자동 메모리 관리, 코드 간소화
- **소요 시간**: 2-3일 (Either 이후)

**Post Feature 예시**:
```dart
// Before: ChangeNotifier (323줄)
class FeedProvider extends ChangeNotifier {
  StreamSubscription? _feedStreamSubscription;
  List<PostDisplay> _posts = [];

  void startFeedStream() {
    _feedStreamSubscription = repository.getFeedStream().listen(...);
  }

  @override
  void dispose() {
    _feedStreamSubscription?.cancel();  // 수동 cleanup
    super.dispose();
  }
}

// After: Riverpod StreamProvider (180줄, 44% 감소)
@riverpod
Stream<List<PostDisplay>> feedStream(FeedStreamRef ref) async* {
  final repository = ref.watch(postRepositoryProvider);

  yield* repository.getFeedStream();
  // autoDispose로 자동 cleanup (dispose 불필요)
}
```

### 2.3 Creation Feature의 특수성

**Creation Feature는 Pattern A+B (Hybrid)를 따릅니다** ← v2.0.0 변경!

✅ **Either Pattern (Pattern A) 적용 이유**:
1. **타입 안전성**: Repository/UseCase 모두 에러를 타입으로 표현
2. **일관성**: 다른 Feature와 동일한 Either 패턴 사용
3. **함수형 조합**: flatMap으로 에러 전파 간소화

✅ **Riverpod (Pattern B) 적용 이유** ← NEW!:
1. **복잡한 폼 상태 관리**: title, description, imagesA, imagesB, targetAudience 등 다수
2. **멀티미디어 업로드 진행률**: 실시간 progress 업데이트 필요
3. **검열 상태 관리**: 실시간 moderation status 업데이트
4. **코드 간소화**: ChangeNotifier의 보일러플레이트 제거
5. **자동 메모리 관리**: autoDispose로 subscription 자동 정리
6. **일관성**: Post/Chat Feature와 동일한 상태 관리 패턴

**Creation Feature의 Provider 복잡도**:
```dart
// ❌ 현재: ChangeNotifier (6개 Provider, ~1,200줄)
CreatePostProviderV2 extends ChangeNotifier         // 메인 폼 상태
TargetAudienceProvider extends ChangeNotifier       // 타겟 관리
MediaSelectionProvider extends ChangeNotifier       // 미디어 선택
MediaValidationProvider extends ChangeNotifier      // 미디어 검증
MediaUploadProvider extends ChangeNotifier          // 업로드 진행률
MediaStateCoordinator                               // Provider 조율

// ✅ 목표: Riverpod 2.x (6개 Provider, ~700줄 예상, 42% 감소)
@riverpod class CreatePostNotifier extends _$CreatePostNotifier  // 메인 폼
@riverpod class TargetAudienceNotifier ...                       // 타겟 관리
@riverpod Stream<MediaUploadProgress> mediaUploadProgress ...    // 업로드 진행률
@riverpod FutureOr<ValidationResult> validateMedia ...           // 미디어 검증
```

**따라서 Phase 2의 목표** (v2.0.0):
- ✅ **Step 1-2**: Repository/UseCase → `Either<CreationFailure, T>`
- ✅ **Step 3**: Presentation Layer에서 Either fold 사용
- ✅ **Step 4**: Presentation Layer → Riverpod 2.x @riverpod 패턴 ← NEW!

---

## 3. 현재 상태 분석 (Before)

### 3.1 UseCase Layer: Result<T> 패턴

**현재 상태**: 모든 UseCase는 `Result<T>` 패턴을 사용합니다.

#### 코드 예시: CreatePostUseCase

**파일**: `lib/features/creation/domain/usecases/create_post_usecase.dart`

```dart
import 'package:versus_space/core/types/result.dart';  // ⚠️ 커스텀 Result 타입
import '../failures/creation_failures.dart';

class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;

  CreatePostUseCase({
    required IPostCreationRepositoryV2 postRepository,
    required IMediaRepository mediaRepository,
    required ManageTargetAudienceUseCase manageTargetAudienceUseCase,
  })  : _postRepository = postRepository,
        _mediaRepository = mediaRepository,
        _manageTargetAudienceUseCase = manageTargetAudienceUseCase;

  /// Execute the use case with DTO
  Future<Result<PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. 입력 검증
      final validationResult = _validateInputs(
        title: dto.title,
        description: dto.description,
        imagesA: dto.imagesA,
        imagesB: dto.imagesB,
      );

      if (validationResult != null) {
        return ResultFailure(validationResult);  // ⚠️ ResultFailure 반환
      }

      onProgress?.call(0.1);

      // 2. 이미지 처리 (Option A)
      final resultA = await _processImages(
        images: dto.imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      if (resultA.isFailure) {
        return ResultFailure(resultA.failureOrNull!);  // ⚠️ 수동 에러 전파
      }

      onProgress?.call(0.4);

      // 3. 이미지 처리 (Option B)
      final resultB = await _processImages(
        images: dto.imagesB,
        box: 'B',
        onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
      );

      if (resultB.isFailure) {
        return ResultFailure(resultB.failureOrNull!);  // ⚠️ 수동 에러 전파
      }

      onProgress?.call(0.7);

      // 4. 이미지 업로드 (Option A)
      final uploadResultA = await _uploadImages(
        processedImages: resultA.valueOrNull!.approvedFiles,
      );

      if (uploadResultA.isFailure) {
        return ResultFailure(uploadResultA.failureOrNull!);  // ⚠️ 수동 에러 전파
      }

      // 5. 이미지 업로드 (Option B)
      final uploadResultB = await _uploadImages(
        processedImages: resultB.valueOrNull!.approvedFiles,
      );

      if (uploadResultB.isFailure) {
        return ResultFailure(uploadResultB.failureOrNull!);  // ⚠️ 수동 에러 전파
      }

      onProgress?.call(0.8);

      // 6. 타겟 오디언스 처리
      // ... (생략)

      // 7. PostCreation aggregate 생성
      final postCreation = PostCreation(
        // ... fields
      );

      // 8. Repository 호출 (Raw type 반환)
      final postId = await _postRepository.createPost(post: postCreation);  // ⚠️ String 반환 (에러는 throw)

      onProgress?.call(1.0);

      return ResultSuccess(postCreation.copyWith(id: postId));  // ⚠️ ResultSuccess 반환

    } on CreationFailure catch (e) {
      return ResultFailure(e);  // ⚠️ Failure를 catch해서 Result로 감싸기
    } catch (e) {
      return ResultFailure(CreationFailure.unexpected(e.toString()));  // ⚠️ 일반 예외 처리
    }
  }

  // ... helper methods
}
```

#### Result<T> 패턴의 특징

**1. Result 타입 정의** (`lib/core/types/result.dart`):

```dart
// ⚠️ 커스텀 구현 (fpdart/dartz 미사용)
abstract class Result<T> {
  bool get isSuccess;
  bool get isFailure;
  T? get valueOrNull;
  Failure? get failureOrNull;
}

class ResultSuccess<T> implements Result<T> {
  final T value;
  ResultSuccess(this.value);

  @override
  bool get isSuccess => true;
  @override
  bool get isFailure => false;
  @override
  T? get valueOrNull => value;
  @override
  Failure? get failureOrNull => null;
}

class ResultFailure<T> implements Result<T> {
  final Failure failure;
  ResultFailure(this.failure);

  @override
  bool get isSuccess => false;
  @override
  bool get isFailure => true;
  @override
  T? get valueOrNull => null;
  @override
  Failure? get failureOrNull => failure;
}
```

**2. 에러 처리 방식**:

```dart
// UseCase에서 사용
final result = await _processImages(...);

if (result.isFailure) {
  return ResultFailure(result.failureOrNull!);  // ⚠️ 수동 전파
}

// 성공 값 추출
final processedImages = result.valueOrNull!;  // ⚠️ null 체크 필요
```

**3. 문제점**:

❌ **보일러플레이트 코드**: 각 단계마다 `if (result.isFailure)` 체크 필요
❌ **Null Safety 취약**: `valueOrNull!`, `failureOrNull!` 사용 (강제 언래핑)
❌ **함수형 조합 불가**: `flatMap`, `fold` 등 메서드 부재
❌ **타입 추론 제한**: Generic 타입 T가 명시적이지 않음

### 3.2 Repository Layer: Raw Types 패턴

**현재 상태**: Repository 인터페이스는 **에러 처리를 타입에 표현하지 않습니다**.

#### 코드 예시: IPostCreationRepositoryV2

**파일**: `lib/features/creation/domain/repositories/i_post_creation_repository_v2.dart`

```dart
import 'dart:io';
import '../models/aggregates/post_creation.dart';
import '../models/value_objects/target_audience.dart';
import '../services/i_target_audience_service.dart' as service;
import '../services/i_image_processing_service.dart';

/// Repository interface for Post creation operations (V2 - Clean Architecture)
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Create a new post using PostCreation aggregate
  /// Returns the created post ID
  ///
  /// ⚠️ 에러는 throw로만 처리 (타입 시스템에 표현 안 됨)
  Future<String> createPost({
    required PostCreation post,
  });

  // ====== Update Operations ======

  /// Update post using PostCreation aggregate
  /// ⚠️ void 반환 (에러는 throw)
  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  });

  /// Update post using partial data (for granular updates)
  /// ⚠️ void 반환 (에러는 throw)
  Future<void> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  // ====== Delete Operations ======

  /// ⚠️ void 반환 (에러는 throw)
  Future<void> deletePost(String postId);

  // ====== Media Operations ======

  /// ⚠️ void 반환 (에러는 throw)
  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
  });

  /// ⚠️ void 반환 (에러는 throw)
  Future<void> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side, // 'A' or 'B'
  });

  // ====== Status Operations ======

  /// ⚠️ void 반환 (에러는 throw)
  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  /// ⚠️ void 반환 (에러는 throw)
  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });

  // ====== Query Operations ======

  /// Get post as PostCreation aggregate
  /// ⚠️ null 반환 가능 (에러는 throw)
  Future<PostCreation?> getPost(String postId);

  /// Stream post changes as PostCreation aggregate
  /// ⚠️ 에러는 stream error로 전파
  Stream<PostCreation> watchPost(String postId);
}
```

#### Raw Types 패턴의 특징

**1. 에러 처리가 타입에 표현되지 않음**:

```dart
// ❌ 타입만 보고는 에러 발생 가능성을 알 수 없음
Future<String> createPost({required PostCreation post});

// 호출 시 에러 처리 강제되지 않음
final postId = await repository.createPost(post: post);  // try-catch 없으면 크래시
```

**2. 실제 구현체에서 throw 사용** (추정):

```dart
// PostCreationRepositoryImpl (구현체)
@override
Future<String> createPost({required PostCreation post}) async {
  try {
    final docRef = await _firestore.collection('posts').add(post.toFirestore());
    return docRef.id;
  } on FirebaseException catch (e) {
    throw CreationFailure.serverError(e.message ?? 'Unknown error');  // ⚠️ throw
  } catch (e) {
    throw CreationFailure.unexpected(e.toString());  // ⚠️ throw
  }
}
```

**3. UseCase에서 try-catch로 처리**:

```dart
// CreatePostUseCase
try {
  final postId = await _postRepository.createPost(post: postCreation);  // ⚠️ throw 가능
  return ResultSuccess(postCreation.copyWith(id: postId));
} on CreationFailure catch (e) {
  return ResultFailure(e);  // ⚠️ catch해서 Result로 변환
} catch (e) {
  return ResultFailure(CreationFailure.unexpected(e.toString()));
}
```

**4. 문제점**:

❌ **타입 안전성 부족**: 컴파일러가 에러 처리 누락을 잡아주지 못함
❌ **런타임 크래시 위험**: try-catch 누락 시 앱 크래시
❌ **일관성 부족**: Repository는 throw, UseCase는 Result 반환
❌ **테스트 어려움**: Mocking 시 에러 케이스 재현 복잡

### 3.3 Presentation Layer: ChangeNotifier 패턴

**현재 상태**: Provider는 **ChangeNotifier** 기반으로 상태를 관리합니다.

#### 코드 예시: CreatePostProviderV2

**파일**: `lib/features/creation/presentation/providers/create_post_provider_v2.dart`

```dart
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/usecases/validate_post_usecase.dart';
import '../../data/coordinators/media_state_coordinator.dart';

/// Form data model
class PostFormData {
  String title;
  String description;
  String textA;
  String textB;
  List<File> imagesA;
  List<File> imagesB;
  TargetAudience? targetAudience;
  bool isAnonymous;
  bool isSingleMode;

  PostFormData({
    this.title = '',
    this.description = '',
    this.textA = '',
    this.textB = '',
    this.imagesA = const [],
    this.imagesB = const [],
    this.targetAudience,
    this.isAnonymous = false,
    this.isSingleMode = false,
  });
}

/// Loading states
enum LoadingState { idle, loading, success, error }

/// Moderation status
enum ModerationStatus { pending, checking, approved, rejected }

/// ChangeNotifier Provider for Post Creation
class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;
  final ModerateContentUseCase _moderateContentUseCase;
  final ValidatePostUseCase _validatePostUseCase;
  final MediaStateCoordinator _mediaCoordinator;

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
    required ModerateContentUseCase moderateContentUseCase,
    required ValidatePostUseCase validatePostUseCase,
    required MediaStateCoordinator mediaCoordinator,
  })  : _createPostUseCase = createPostUseCase,
        _moderateContentUseCase = moderateContentUseCase,
        _validatePostUseCase = validatePostUseCase,
        _mediaCoordinator = mediaCoordinator;

  // State
  PostFormData _formData = PostFormData();
  LoadingState _loadingState = LoadingState.idle;
  ModerationStatus _moderationStatus = ModerationStatus.pending;
  String? _errorMessage;
  double _uploadProgress = 0.0;

  // Getters
  PostFormData get formData => _formData;
  LoadingState get loadingState => _loadingState;
  ModerationStatus get moderationStatus => _moderationStatus;
  String? get errorMessage => _errorMessage;
  double get uploadProgress => _uploadProgress;

  bool get isLoading => _loadingState == LoadingState.loading;
  bool get canSubmit => _formData.title.isNotEmpty &&
                        _formData.description.isNotEmpty;

  /// Create post
  Future<void> createPost() async {
    if (!canSubmit) return;

    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. UseCase 호출 (Result<T> 반환)
      final result = await _createPostUseCase.execute(
        dto: PostCreationDto.fromFormData(_formData),
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      // 2. Result 처리
      if (result.isSuccess) {
        _loadingState = LoadingState.success;
        _uploadProgress = 1.0;
        notifyListeners();
      } else {
        _loadingState = LoadingState.error;
        _errorMessage = result.failureOrNull?.message ?? 'Unknown error';  // ⚠️ Failure 메시지 추출
        notifyListeners();
      }
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Update form field
  void updateTitle(String value) {
    _formData.title = value;
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    notifyListeners();
  }

  // ... other update methods
}
```

#### ChangeNotifier 패턴의 특징

**1. 상태 관리 방식**:

```dart
// ChangeNotifier 기반
class CreatePostProviderV2 extends ChangeNotifier {
  LoadingState _loadingState = LoadingState.idle;

  void _updateState(LoadingState newState) {
    _loadingState = newState;
    notifyListeners();  // ⚠️ 수동으로 리스너에게 알림
  }
}
```

**2. Widget에서 사용**:

```dart
// Consumer로 감싸서 사용
Consumer<CreatePostProviderV2>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator(value: provider.uploadProgress);
    }

    if (provider.loadingState == LoadingState.error) {
      return Text('Error: ${provider.errorMessage}');
    }

    return CreatePostForm();
  },
)
```

**3. 특징**:

✅ **간단함**: ChangeNotifier는 Flutter 기본 제공
✅ **충분함**: 게시물 생성은 일회성 작업 (실시간 동기화 불필요)
✅ **폼 상태 관리에 적합**: 입력 필드, 로딩 상태, 에러 메시지 관리

❌ **Phase 2에서 변경 없음**: Riverpod 도입 불필요 (Creation Feature는 Request-Response 패턴)

### 3.4 에러 처리 흐름 분석

현재 Creation Feature의 에러 처리 흐름:

```
┌──────────────────────────────────────────────────────────────┐
│                  Presentation Layer                          │
│  CreatePostProviderV2 (ChangeNotifier)                      │
│  - Result<T> 처리: isSuccess/isFailure 체크                 │
│  - 에러 메시지 추출: failureOrNull?.message                  │
│  - notifyListeners() 호출                                    │
└────────────────────┬─────────────────────────────────────────┘
                     │ Result<PostCreation>
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                    Domain Layer (UseCase)                    │
│  CreatePostUseCase                                          │
│  - Result<T> 반환: ResultSuccess/ResultFailure              │
│  - 각 단계마다 수동 에러 체크: if (result.isFailure)        │
│  - try-catch로 Repository 에러 포착                         │
└────────────────────┬─────────────────────────────────────────┘
                     │ Raw types (String, void)
                     │ throws CreationFailure
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                  Domain Layer (Repository)                   │
│  IPostCreationRepositoryV2 (Interface)                      │
│  - Raw types 반환: Future<String>, Future<void>             │
│  - 에러는 throw로 전파 (타입에 표현 안 됨)                   │
└────────────────────┬─────────────────────────────────────────┘
                     │ Raw types
                     │ throws FirebaseException
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                     Data Layer (Impl)                        │
│  PostCreationRepositoryImpl                                 │
│  - Firestore 호출                                            │
│  - FirebaseException catch → CreationFailure throw          │
└──────────────────────────────────────────────────────────────┘
```

**현재 흐름의 문제점**:

1. **불일치**: Repository는 throw, UseCase는 Result 반환
2. **타입 안전성 부족**: Repository 메서드만 보고는 에러 발생 가능성 알 수 없음
3. **보일러플레이트**: UseCase 내부에 수동 에러 체크 코드 반복
4. **테스트 어려움**: throw 기반 에러는 Mocking 복잡

---

## 4. 목표 상태 (After)

### 4.1 Either<L,R> 패턴 소개

**Either<L,R>**는 함수형 프로그래밍의 에러 처리 패턴으로, **두 가지 가능한 값** 중 하나를 표현합니다:

- **Left (L)**: 에러 (Failure)
- **Right (R)**: 성공 (Success value)

```dart
// Either<Failure, Success>
Either<CreationFailure, PostCreation> result;

// Left: 에러
final error = left(CreationFailure.invalidInput('Title is empty'));

// Right: 성공
final success = right(postCreation);
```

#### Either 패턴의 장점

**1. 타입 안전성**:

```dart
// ✅ 반환 타입에 에러 가능성이 명시됨
Future<Either<CreationFailure, String>> createPost({
  required PostCreation post,
});

// 컴파일러가 에러 처리를 강제함
final result = await repository.createPost(post: post);
result.fold(
  (failure) => /* 에러 처리 필수 */,
  (postId) => /* 성공 처리 필수 */,
);
```

**2. 함수형 조합 (flatMap)**:

```dart
// ✅ 에러 자동 전파 (if 문 불필요)
final result = await repository.createPost(post: post)
  .flatMap((postId) => repository.updatePost(postId: postId, post: updated))
  .flatMap((unit) => repository.markAsProcessed(postId: postId));

// 에러는 최초 발생 지점에서 자동으로 전파됨 (보일러플레이트 제거)
```

**3. Exhaustive Pattern Matching**:

```dart
// ✅ fold로 모든 경우 처리 강제
result.fold(
  (failure) {
    // Left: 에러 처리 (타입: CreationFailure)
    switch (failure) {
      case CreationFailure.invalidInput():
        showValidationError(failure.message);
      case CreationFailure.serverError():
        showServerError(failure.message);
      // ... 모든 Failure 타입 처리 필수
    }
  },
  (postCreation) {
    // Right: 성공 처리 (타입: PostCreation)
    navigateToPostDetail(postCreation.id);
  },
);
```

**4. Null Safety**:

```dart
// ❌ Before: null 체크 필요
final value = result.valueOrNull!;  // ⚠️ 강제 언래핑 위험

// ✅ After: fold가 타입 안전성 보장
result.fold(
  (failure) => /* failure는 non-null CreationFailure */,
  (value) => /* value는 non-null PostCreation */,
);
```

#### fpdart vs dartz

Versus Space 프로젝트는 **두 가지 Either 라이브러리**를 사용합니다:

| Feature | 라이브러리 | 이유 |
|---------|----------|------|
| Auth | `dartz` | 레거시 코드 유지 |
| Profile | `fpdart` | 최신 Dart 3 호환 |
| Chat | `fpdart` | 최신 Dart 3 호환 |
| Notifications | `fpdart` | 최신 Dart 3 호환 |
| Post | `fpdart` | 최신 Dart 3 호환 |
| **Creation** | **`fpdart`** ✅ | **최신 Dart 3 호환 권장** |

> 📌 **권장**: Creation Feature는 **`fpdart`**를 사용합니다. (Null Safety 개선, Dart 3 호환성)

### 4.2 UseCase Layer 목표

**목표**: `Result<T>` → `Either<CreationFailure, T>` 변환

#### Before (Result<T>)

```dart
import 'package:versus_space/core/types/result.dart';

class CreatePostUseCase {
  Future<Result<PostCreation>> execute({
    required PostCreationDto dto,
  }) async {
    try {
      // 1. 검증
      final validationResult = _validateInputs(...);
      if (validationResult != null) {
        return ResultFailure(validationResult);  // ⚠️ 수동 에러 반환
      }

      // 2. 이미지 처리
      final resultA = await _processImages(...);
      if (resultA.isFailure) {
        return ResultFailure(resultA.failureOrNull!);  // ⚠️ 수동 에러 전파
      }

      // 3. Repository 호출 (Raw type → try-catch 필요)
      final postId = await _postRepository.createPost(post: postCreation);

      return ResultSuccess(postCreation.copyWith(id: postId));

    } on CreationFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

#### After (Either)

```dart
import 'package:fpdart/fpdart.dart';

class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
  }) async {
    // 1. 검증 (Either 반환)
    return _validateInputs(...)
      .toEither(() => CreationFailure.invalidInput('Validation failed'))

      // 2. 이미지 처리 (flatMap으로 에러 자동 전파)
      .flatMap((_) => _processImages(...))

      // 3. Repository 호출 (Either 반환 → flatMap 가능)
      .flatMap((processedData) => _postRepository.createPost(post: postCreation))

      // 4. 성공 값 변환
      .map((postId) => postCreation.copyWith(id: postId));
  }
}
```

**개선 사항**:
- ✅ **보일러플레이트 제거**: `if (result.isFailure)` 체크 불필요
- ✅ **에러 자동 전파**: flatMap이 에러를 자동으로 전달
- ✅ **타입 안전성**: 모든 단계에서 Either<Failure, T> 타입 보장
- ✅ **Null Safety**: 강제 언래핑 (`!`) 제거

### 4.3 Repository Layer 목표

**목표**: Raw Types → `Either<CreationFailure, T>` 변환

#### Before (Raw Types)

```dart
abstract class IPostCreationRepositoryV2 {
  /// ⚠️ 에러는 throw로만 처리 (타입 시스템에 표현 안 됨)
  Future<String> createPost({required PostCreation post});

  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  });

  Future<void> deletePost(String postId);

  Future<PostCreation?> getPost(String postId);
}
```

#### After (Either)

```dart
import 'package:fpdart/fpdart.dart';

abstract class IPostCreationRepositoryV2 {
  /// ✅ 에러 가능성이 타입에 명시됨
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  });

  /// ✅ void → Unit (함수형 프로그래밍의 void 표현)
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
  });

  Future<Either<CreationFailure, Unit>> deletePost(String postId);

  /// ✅ null → Option<T> (함수형 프로그래밍의 null 표현)
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(String postId);
}
```

**개선 사항**:
- ✅ **타입 안전성**: 에러 가능성이 반환 타입에 표현됨
- ✅ **컴파일러 강제**: fold 없이 값 사용 불가
- ✅ **테스트 용이**: Either 기반 Mocking 간단
- ✅ **일관성**: UseCase와 Repository 모두 Either 사용

#### Unit과 Option

**Unit**: 함수형 프로그래밍의 void 표현

```dart
// ❌ Before: void는 Either와 함께 사용 불가
Future<Either<Failure, void>> updatePost(...);  // ⚠️ 컴파일 에러

// ✅ After: Unit 사용
Future<Either<Failure, Unit>> updatePost(...);

// 사용 예시
result.fold(
  (failure) => handleError(failure),
  (unit) => print('Update success'),  // unit은 () 값
);
```

**Option**: 함수형 프로그래밍의 null 표현

```dart
// ❌ Before: null 반환
Future<PostCreation?> getPost(String postId);

// ✅ After: Option<T> 사용
Future<Either<Failure, Option<PostCreation>>> getPost(String postId);

// 사용 예시
result.fold(
  (failure) => handleError(failure),
  (option) => option.fold(
    () => print('Post not found'),  // None
    (post) => showPost(post),       // Some(post)
  ),
);
```

### 4.4 Presentation Layer 목표: Riverpod 2.x 마이그레이션 ← v2.0.0 NEW!

**변경**: Presentation Layer (ChangeNotifier Provider) → **Riverpod 2.x (@riverpod)** 마이그레이션

#### 마이그레이션 이유

1. **복잡한 폼 상태 관리**: 6개의 Provider 조율 필요 (1,200줄)
2. **멀티미디어 업로드 진행률**: 실시간 progress 업데이트
3. **코드 간소화**: ChangeNotifier 보일러플레이트 제거 (42% 감소 예상)
4. **자동 메모리 관리**: autoDispose로 subscription 자동 정리
5. **일관성**: Post/Chat Feature와 동일한 상태 관리 패턴

#### Before: ChangeNotifier (6개 Provider, ~1,200줄)

```dart
class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;

  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  PostFormData _formData = PostFormData();

  // 수동 Getter/Setter
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  PostFormData get formData => _formData;

  void updateTitle(String value) {
    _formData = _formData.copyWith(title: value);
    notifyListeners();  // 수동 notify
  }

  Future<void> createPost() async {
    _loadingState = LoadingState.loading;
    notifyListeners();

    final result = await _createPostUseCase.execute(dto: dto);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _loadingState = LoadingState.error;
      },
      (postCreation) {
        _loadingState = LoadingState.success;
      },
    );
    notifyListeners();  // 수동 notify
  }

  @override
  void dispose() {
    // 수동 cleanup
    super.dispose();
  }
}
```

#### After: Riverpod 2.x (@riverpod, ~700줄 예상, 42% 감소)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_post_providers.g.dart';

// 1. 폼 상태 (StateNotifier 대체)
@riverpod
class CreatePostForm extends _$CreatePostForm {
  @override
  PostFormData build() => PostFormData();  // 초기값

  void updateTitle(String value) {
    state = state.copyWith(title: value);  // 자동 notify
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);  // 자동 notify
  }
}

// 2. 게시물 생성 (FutureProvider)
@riverpod
class CreatePost extends _$CreatePost {
  @override
  FutureOr<PostCreation?> build() => null;  // 초기값

  Future<void> execute() async {
    state = const AsyncLoading();  // 자동 로딩 상태

    final formData = ref.read(createPostFormProvider);
    final useCase = ref.read(createPostUseCaseProvider);

    final result = await useCase.execute(dto: formData.toDto());

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),  // 자동 에러 상태
      (postCreation) => AsyncData(postCreation),  // 자동 성공 상태
    );
  }
}

// 3. 미디어 업로드 진행률 (StreamProvider)
@riverpod
Stream<MediaUploadProgress> mediaUploadProgress(MediaUploadProgressRef ref) async* {
  final uploadProvider = ref.watch(mediaUploadProviderProvider);

  yield* uploadProvider.progressStream();  // autoDispose로 자동 cleanup
}
```

#### 변화 요약

| 항목 | Before (ChangeNotifier) | After (Riverpod 2.x) |
|------|-------------------------|----------------------|
| **코드량** | ~1,200줄 | ~700줄 (42% ↓) |
| **State 관리** | 수동 notifyListeners() | 자동 (state 변경 시) |
| **Cleanup** | 수동 dispose() | 자동 autoDispose |
| **로딩/에러 상태** | 수동 enum 관리 | AsyncValue 자동 |
| **의존성 주입** | GetIt | ref.watch() |
| **코드 생성** | 불필요 | build_runner 필요 |

### 4.5 에러 처리 흐름 개선 (Either + Riverpod)

**After**: 일관된 Either 패턴 + Riverpod 2.x 상태 관리

```
┌──────────────────────────────────────────────────────────────┐
│                  Presentation Layer                          │
│  CreatePostNotifier (@riverpod) ← v2.0.0 변경               │
│  - AsyncValue<PostCreation> 상태 (loading/error/data 자동)  │
│  - Either<L,R> → AsyncValue 변환                            │
│  - autoDispose로 자동 cleanup                                │
└────────────────────┬─────────────────────────────────────────┘
                     │ AsyncValue<PostCreation>
                     │ (내부적으로 Either<CreationFailure, PostCreation>)
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                    Domain Layer (UseCase)                    │
│  CreatePostUseCase                                          │
│  - Either<L,R> 반환: left/right                             │
│  - flatMap으로 에러 자동 전파 (if 문 불필요)                 │
│  - 함수형 조합: map, flatMap, fold                           │
└────────────────────┬─────────────────────────────────────────┘
                     │ Either<CreationFailure, T>
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                  Domain Layer (Repository)                   │
│  IPostCreationRepositoryV2 (Interface)                      │
│  - Either<L,R> 반환: left/right                             │
│  - 타입에 에러 가능성 명시                                    │
│  - 컴파일러가 에러 처리 강제                                  │
└────────────────────┬─────────────────────────────────────────┘
                     │ Either<CreationFailure, T>
                     ▼
┌──────────────────────────────────────────────────────────────┐
│                     Data Layer (Impl)                        │
│  PostCreationRepositoryImpl                                 │
│  - Firestore 호출                                            │
│  - FirebaseException catch → left(CreationFailure) 반환     │
└──────────────────────────────────────────────────────────────┘
```

**개선 사항 (v2.0.0)**:
1. **일관성**: 모든 레이어가 Either 사용 + Riverpod 상태 관리
2. **타입 안전성**: Either + AsyncValue로 이중 타입 보장
3. **보일러플레이트 제거**: flatMap + autoDispose로 40-50% 코드 감소
4. **테스트 용이**: Either + Riverpod Mocking 간단
5. **자동 메모리 관리**: autoDispose로 메모리 누수 방지

---

## 5. Before/After 비교

### 5.1 코드 패턴 비교

#### UseCase 비교

**Before (Result<T>)**:
```dart
Future<Result<PostCreation>> execute({
  required PostCreationDto dto,
}) async {
  try {
    // 검증
    final validationResult = _validateInputs(...);
    if (validationResult != null) {
      return ResultFailure(validationResult);  // ⚠️ 수동 에러 반환
    }

    // 이미지 처리 A
    final resultA = await _processImages(...);
    if (resultA.isFailure) {
      return ResultFailure(resultA.failureOrNull!);  // ⚠️ 수동 에러 전파
    }

    // 이미지 처리 B
    final resultB = await _processImages(...);
    if (resultB.isFailure) {
      return ResultFailure(resultB.failureOrNull!);  // ⚠️ 수동 에러 전파
    }

    // Repository 호출 (Raw type)
    final postId = await _postRepository.createPost(post: postCreation);  // ⚠️ throw 가능

    return ResultSuccess(postCreation.copyWith(id: postId));

  } on CreationFailure catch (e) {
    return ResultFailure(e);
  } catch (e) {
    return ResultFailure(CreationFailure.unexpected(e.toString()));
  }
}
```

**After (Either)**:
```dart
Future<Either<CreationFailure, PostCreation>> execute({
  required PostCreationDto dto,
}) async {
  return _validateInputs(...)
    .toEither(() => CreationFailure.invalidInput('Validation failed'))
    .flatMap((_) => _processImagesA(...))   // ✅ 에러 자동 전파
    .flatMap((_) => _processImagesB(...))   // ✅ 에러 자동 전파
    .flatMap((processedData) => _postRepository.createPost(post: postCreation))  // ✅ Either 반환
    .map((postId) => postCreation.copyWith(id: postId));
}
```

**차이**:
- ❌ Before: 15줄 (if 문 3개, try-catch 블록)
- ✅ After: 6줄 (flatMap 체이닝)
- ✅ **60% 코드 감소**

#### Repository 비교

**Before (Raw Types)**:
```dart
abstract class IPostCreationRepositoryV2 {
  Future<String> createPost({required PostCreation post});  // ⚠️ throw
  Future<void> updatePost({required String postId, ...});   // ⚠️ throw
  Future<PostCreation?> getPost(String postId);             // ⚠️ null 가능
}

// 구현체
@override
Future<String> createPost({required PostCreation post}) async {
  try {
    final docRef = await _firestore.collection('posts').add(...);
    return docRef.id;
  } on FirebaseException catch (e) {
    throw CreationFailure.serverError(e.message);  // ⚠️ throw
  }
}
```

**After (Either)**:
```dart
abstract class IPostCreationRepositoryV2 {
  Future<Either<CreationFailure, String>> createPost({required PostCreation post});  // ✅ 타입 안전
  Future<Either<CreationFailure, Unit>> updatePost({required String postId, ...});   // ✅ Unit
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(String postId);      // ✅ Option
}

// 구현체
@override
Future<Either<CreationFailure, String>> createPost({required PostCreation post}) async {
  try {
    final docRef = await _firestore.collection('posts').add(...);
    return right(docRef.id);  // ✅ Either 반환
  } on FirebaseException catch (e) {
    return left(CreationFailure.serverError(e.message));  // ✅ Either 반환
  } catch (e) {
    return left(CreationFailure.unexpected(e.toString()));
  }
}
```

**차이**:
- ✅ 타입에 에러 가능성 명시
- ✅ throw 제거 → Either 반환
- ✅ null → Option<T>

#### Provider 비교

**Before (Result<T>)**:
```dart
final result = await _createPostUseCase.execute(dto: dto);

if (result.isSuccess) {
  _loadingState = LoadingState.success;
  notifyListeners();
} else {
  _errorMessage = result.failureOrNull?.message ?? 'Unknown error';  // ⚠️ null 체크
  _loadingState = LoadingState.error;
  notifyListeners();
}
```

**After (Either)**:
```dart
final result = await _createPostUseCase.execute(dto: dto);

result.fold(
  (failure) {
    _errorMessage = failure.message;  // ✅ non-null 보장
    _loadingState = LoadingState.error;
    notifyListeners();
  },
  (postCreation) {
    _loadingState = LoadingState.success;
    notifyListeners();
  },
);
```

**차이**:
- ✅ `isSuccess/isFailure` → `fold`
- ✅ `failureOrNull` → `failure` (non-null)
- ✅ 타입 안전성 강화

### 5.2 에러 처리 비교

#### 에러 체크 패턴

**Before**:
```dart
// 각 단계마다 수동 체크 (보일러플레이트)
final result1 = await step1();
if (result1.isFailure) return ResultFailure(result1.failureOrNull!);

final result2 = await step2(result1.valueOrNull!);
if (result2.isFailure) return ResultFailure(result2.failureOrNull!);

final result3 = await step3(result2.valueOrNull!);
if (result3.isFailure) return ResultFailure(result3.failureOrNull!);

return ResultSuccess(result3.valueOrNull!);
```

**After**:
```dart
// flatMap으로 에러 자동 전파 (함수형 조합)
return step1()
  .flatMap((value1) => step2(value1))
  .flatMap((value2) => step3(value2));
```

**차이**:
- ❌ Before: 12줄 (if 문 3개, 강제 언래핑 6개)
- ✅ After: 3줄 (flatMap 체이닝)
- ✅ **75% 코드 감소**

#### 에러 타입 안전성

**Before**:
```dart
// Repository 호출 시 에러 처리 강제되지 않음
final postId = await repository.createPost(post: post);  // ⚠️ try-catch 없으면 크래시
```

**After**:
```dart
// Repository 호출 시 fold 없이 값 사용 불가 (컴파일 에러)
final result = await repository.createPost(post: post);
// ❌ final postId = result;  // 컴파일 에러: Either를 직접 사용 불가

// ✅ fold 필수
result.fold(
  (failure) => /* 에러 처리 */,
  (postId) => /* 성공 처리 */,
);
```

### 5.3 타입 안전성 비교

| 항목 | Before (Result<T> + Raw) | After (Either) |
|------|-------------------------|----------------|
| **에러 표현** | 타입에 표현 안 됨 (throw) | Either<Failure, T> |
| **Null Safety** | `valueOrNull!` 강제 언래핑 | fold로 non-null 보장 |
| **컴파일러 강제** | ❌ 에러 처리 누락 가능 | ✅ fold 없이 사용 불가 |
| **함수형 조합** | ❌ 불가능 (수동 체크) | ✅ flatMap, map 지원 |
| **테스트 용이성** | ⚠️ throw 기반 Mocking | ✅ Either 기반 Mocking |
| **보일러플레이트** | ⚠️ 높음 (if 문 반복) | ✅ 낮음 (flatMap 체이닝) |

---

## 6. 마이그레이션 범위

### 6.1 영향 받는 파일 목록 (v2.0.0 - 실제 codebase 기반)

#### Domain Layer (Repository Interfaces)

**Repository 인터페이스** (5개) ← 실제 검증 완료:
```
lib/features/creation/domain/repositories/
├── i_post_creation_repository_v2.dart       (~80줄)
├── i_media_repository.dart                  (~50줄)
├── specialized/
│   ├── i_moderation_repository.dart         (~40줄)
│   ├── i_metrics_repository.dart            (~30줄)
│   └── i_visibility_repository.dart         (~30줄)
```

**변경 사항**: 모든 메서드 시그니처를 Either로 변경
- `Future<String>` → `Future<Either<CreationFailure, String>>`
- `Future<void>` → `Future<Either<CreationFailure, Unit>>`
- `Future<T?>` → `Future<Either<CreationFailure, Option<T>>>`

#### Domain Layer (UseCases)

**UseCases** (6개) ← 실제 검증 완료:
```
lib/features/creation/domain/usecases/
├── create_post_usecase.dart                 (~300줄) ⚠️ 복잡
├── moderate_content_usecase.dart            (~150줄)
├── validate_post_usecase.dart               (~100줄)
├── manage_target_audience_usecase.dart      (~200줄)
├── upload_images_usecase.dart               (~120줄)
└── ratio_calculator.dart                    (~50줄)
```

**변경 사항**: Result<T> → Either 변환
- `Future<Result<T>>` → `Future<Either<CreationFailure, T>>`
- `if (result.isFailure)` → `flatMap`
- `ResultSuccess/ResultFailure` → `right/left`

#### Data Layer (Repository Implementations)

**Repository 구현체** (8개) ← 실제 검증 완료:
```
lib/features/creation/data/repositories/
├── post_creation_repository_v2_impl.dart    (~400줄) ⚠️ 복잡
├── media_repository_impl.dart               (~250줄)
├── target_audience_repository_impl.dart     (~180줄)
├── image_processing_repository_impl.dart    (~150줄)
├── content_metrics_repository_impl.dart     (~120줄)
├── content_visibility_repository_impl.dart  (~100줄)
├── media_upload_repository_impl.dart        (~100줄)
└── content_moderation_repository_impl.dart  (~80줄)
```

**변경 사항**: throw → Either 변환
- `throw CreationFailure` → `return left(CreationFailure)`
- `return value` → `return right(value)`
- try-catch 블록 유지 (Either 반환으로 변경)

#### Presentation Layer (Providers)

**Providers** (6개) ← 실제 검증 완료:
```
lib/features/creation/presentation/providers/
├── create_post_provider_v2.dart             (~300줄)
├── target_audience_provider.dart            (~150줄)
├── media/
│   ├── media_selection_provider.dart        (~200줄)
│   ├── media_validation_provider.dart       (~150줄)
│   ├── media_upload_provider.dart           (~100줄)
│   └── media_state_coordinator.dart         (~100줄)
```

**변경 사항 (Step 3)**: Result 처리 → fold
- `if (result.isSuccess)` → `result.fold(...)`
- `result.failureOrNull` → `failure` (non-null)
- `result.valueOrNull` → `value` (non-null)

**변경 사항 (Step 4)**: ChangeNotifier → Riverpod 2.x ← NEW!
- `extends ChangeNotifier` → `@riverpod`
- `notifyListeners()` → 자동 (state 변경 시)
- `dispose()` → autoDispose (자동)
- GetIt 의존성 → `ref.watch()`

### 6.2 소요 시간 및 난이도 (v2.0.0 - Either + Riverpod)

| 단계 | 작업 내용 | 파일 수 | 소요 시간 | 난이도 |
|-----|----------|---------|----------|--------|
| **Step 1** | Repository 인터페이스 마이그레이션 (5개) | 5 files | 1일 | ⭐⭐☆☆☆ |
| **Step 2** | Repository 구현체 마이그레이션 (8개) | 8 files | 2일 | ⭐⭐⭐☆☆ |
| **Step 3** | UseCase 마이그레이션 (6개) | 6 files | 1.5일 | ⭐⭐⭐⭐☆ |
| **Step 4** | Provider Either fold 연동 (6개) | 6 files | 0.5일 | ⭐⭐☆☆☆ |
| **Step 5** | Riverpod 2.x 마이그레이션 (6개) ← NEW! | 6 files | 2일 | ⭐⭐⭐⭐☆ |
| **Step 6** | 테스트 작성 및 검증 (Either + Riverpod) | - | 1.5일 | ⭐⭐⭐☆☆ |
| **합계** | **25 files** | - | **8.5일** | **⭐⭐⭐⭐☆** |

**난이도 평가 (v2.0.0)**:
- ⭐⭐⭐⭐☆ (고급): Either 패턴 + Riverpod 2.x 이해 필요
- **Either 패턴**: 함수형 프로그래밍 개념 (flatMap, fold)
- **Riverpod 2.x**: @riverpod 코드 생성, AsyncValue, build_runner
- 복잡도 증가 요인:
  - 8개 Repository 구현체 (기존 추정 3개 → 실제 8개)
  - 6개 Provider Riverpod 전환 (ChangeNotifier → @riverpod)
  - 코드 생성 설정 (build_runner, riverpod_generator)

### 6.3 의존성 및 순서 (v2.0.0 - Either + Riverpod)

**마이그레이션 순서** (의존성 기반):

```
1. Repository Interface (Domain Layer) - 5 files
   ↓ (UseCase가 Repository 의존)
2. Repository Implementation (Data Layer) - 8 files
   ↓ (UseCase가 Repository 구현체 사용)
3. UseCase (Domain Layer) - 6 files
   ↓ (Provider가 UseCase 의존)
4. Provider Either fold 연동 (Presentation Layer) - 6 files
   ↓ (ChangeNotifier 유지, Either 처리만 변경)
5. Riverpod 2.x 마이그레이션 (Presentation Layer) - 6 files ← NEW!
   ↓ (ChangeNotifier → @riverpod, build_runner 실행)
6. Widget (ConsumerWidget으로 변경)
   ↓ (Provider → ref.watch()로 변경)
7. 테스트 작성 및 검증
```

**중요**: 반드시 **하향식 (Top-Down)** 순서로 진행
- ✅ Repository → UseCase → Provider → Riverpod → Widget 순서
- ❌ Provider → UseCase → Repository 순서는 불가능 (컴파일 에러)
- **Step 4와 Step 5 분리 이유**: Either fold 먼저 적용 후 Riverpod 전환 (단계별 검증)

---

## 7. 다음 단계 안내

**Phase 2-1 완료** ✅ (v2.0.0 - Either + Riverpod 통합)

본 문서에서 다룬 내용:
- ✅ Phase 2의 목적과 배경 이해 (Either + Riverpod)
- ✅ 현재 상태 (Before) 정확한 분석 (실제 25 files)
- ✅ 목표 상태 (After) 명확한 정의 (Either + Riverpod 2.x)
- ✅ Before/After 코드 비교
- ✅ 마이그레이션 범위 파악 (5+8+6+6 = 25 files)

**다음 단계: Phase 2-2**

[Phase 2-2: Migration Steps](./PHASE_2_2_MIGRATION_STEPS.md) 문서에서 다음을 다룹니다:

1. **Step 1: Repository Interface 마이그레이션**
   - 5개 Repository 인터페이스 변경 (실제 검증 완료)
   - Raw Types → Either<Failure, T>
   - Unit, Option 도입

2. **Step 2: Repository Implementation 마이그레이션**
   - 8개 Repository 구현체 변경 (실제 검증 완료)
   - throw → left/right 변환
   - FirebaseException 처리

3. **Step 3: UseCase 마이그레이션**
   - 6개 UseCase 변경 (실제 검증 완료)
   - Result<T> → Either<Failure, T>
   - flatMap 체이닝

4. **Step 4: Provider Either fold 연동**
   - 6개 Provider 변경 (실제 검증 완료)
   - isSuccess/isFailure → fold
   - ChangeNotifier 유지 (Riverpod 전 단계)

5. **Step 5: Riverpod 2.x 마이그레이션** ← v2.0.0 NEW!
   - 6개 Provider Riverpod 전환
   - ChangeNotifier → @riverpod
   - build_runner 코드 생성
   - AsyncValue, autoDispose 적용

6. **마이그레이션 체크리스트**
   - 단계별 검증 항목 (Either + Riverpod)
   - 진행 상황 추적

**Phase 2-3 Preview**

[Phase 2-3: Testing & Validation](./PHASE_2_3_TESTING_AND_VALIDATION.md) 문서에서 다음을 다룹니다:

1. **단위 테스트 작성**
   - Repository 테스트 (Either)
   - UseCase 테스트 (Either)
   - Provider 테스트 (Riverpod) ← NEW!
   - Either Mocking 방법

2. **통합 테스트 작성**
   - 전체 플로우 테스트 (Either + Riverpod)
   - 에러 시나리오 테스트

3. **Rollback 절차**
   - Git 기반 롤백 (6 Steps)
   - 단계별 복원 방법

4. **최종 검증 체크리스트**
   - Either 패턴 검증
   - Riverpod 상태 관리 검증 ← NEW!
   - 완료 기준
   - 품질 검증 항목

---

**문서 끝** - Phase 2-1 완료

**다음**: [Phase 2-2: Migration Steps](./PHASE_2_2_MIGRATION_STEPS.md)
