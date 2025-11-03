# Creation Feature - Phase 2-2: Either Pattern + Riverpod Migration - Step-by-Step Guide

> **문서 버전**: 2.0.0 (Riverpod 통합)
> **작성일**: 2025-11-03
> **최종 수정**: 2025-11-03
> **Phase**: 2-2 (Either Pattern + Riverpod 도입 - 단계별 가이드)
> **이전 Phase**: [Phase 2-1 - Overview & Analysis](./PHASE_2_1_OVERVIEW_AND_ANALYSIS.md)
> **다음 Phase**: [Phase 2-3 - Testing & Validation](./PHASE_2_3_TESTING_AND_VALIDATION.md)

---

## 📋 목차

- [1. 시작하기 전에](#1-시작하기-전에)
  - [1.1 사전 요구사항](#11-사전-요구사항)
  - [1.2 의존성 설치](#12-의존성-설치)
  - [1.3 Git 백업](#13-git-백업)
- [2. Step 1: Repository Interface 마이그레이션 (5개)](#2-step-1-repository-interface-마이그레이션-5개)
  - [2.1 IPostCreationRepositoryV2](#21-ipostcreationrepositoryv2)
  - [2.2 IMediaRepository](#22-imediarepository)
  - [2.3 Specialized Repositories (3개)](#23-specialized-repositories-3개)
  - [2.4 Step 1 검증](#24-step-1-검증)
- [3. Step 2: Repository Implementation 마이그레이션 (8개)](#3-step-2-repository-implementation-마이그레이션-8개)
  - [3.1 PostCreationRepositoryV2Impl](#31-postcreationrepositoryv2impl)
  - [3.2 MediaRepositoryImpl](#32-mediarepositoryimpl)
  - [3.3 나머지 Repositories (6개)](#33-나머지-repositories-6개)
  - [3.4 Step 2 검증](#34-step-2-검증)
- [4. Step 3: UseCase 마이그레이션 (6개)](#4-step-3-usecase-마이그레이션-6개)
  - [4.1 CreatePostUseCase (복잡)](#41-createpostusecase-복잡)
  - [4.2 ModerateContentUseCase](#42-moderatecontentusecase)
  - [4.3 ValidatePostUseCase](#43-validatepostusecase)
  - [4.4 나머지 UseCases (3개)](#44-나머지-usecases-3개)
  - [4.5 Step 3 검증](#45-step-3-검증)
- [5. Step 4: Provider Either fold 연동 (6개)](#5-step-4-provider-either-fold-연동-6개)
  - [5.1 CreatePostProviderV2](#51-createpostproviderv2)
  - [5.2 나머지 Providers (5개)](#52-나머지-providers-5개)
  - [5.3 Step 4 검증](#53-step-4-검증)
- [6. Step 5: Riverpod 2.x 마이그레이션 (6개)](#6-step-5-riverpod-2x-마이그레이션-6개) ← NEW!
  - [6.1 의존성 설정 (riverpod_generator)](#61-의존성-설정-riverpod_generator)
  - [6.2 CreatePostNotifier](#62-createpostnotifier)
  - [6.3 MediaUploadNotifier](#63-mediauploadnotifier)
  - [6.4 나머지 Notifiers (4개)](#64-나머지-notifiers-4개)
  - [6.5 Widget ConsumerWidget 전환](#65-widget-consumerwidget-전환)
  - [6.6 Step 5 검증](#66-step-5-검증)
- [7. 마이그레이션 체크리스트](#7-마이그레이션-체크리스트)
  - [7.1 Repository Interface (5개)](#71-repository-interface-5개)
  - [7.2 Repository Implementation (8개)](#72-repository-implementation-8개)
  - [7.3 UseCase (6개)](#73-usecase-6개)
  - [7.4 Provider Either fold (6개)](#74-provider-either-fold-6개)
  - [7.5 Riverpod 2.x (6개)](#75-riverpod-2x-6개) ← NEW!
- [8. 트러블슈팅](#8-트러블슈팅)
- [9. 다음 단계 안내](#9-다음-단계-안내)

---

## 1. 시작하기 전에

### 1.1 사전 요구사항

**✅ 필수 조건**:
1. **Phase 1 완료**: Freezed Migration 완료 (CreationFailure sealed class 존재)
2. **Phase 2-1 이해**: Overview & Analysis 문서 숙지
3. **Git 브랜치**: 새 브랜치 생성 (`git checkout -b feature/phase2-either-pattern`)
4. **개발 환경**: Flutter 3.8.0+, Dart 3.0.0+

**📚 권장 학습** (v2.0.0):
- **Either 패턴**: fpdart 라이브러리, flatMap, fold, Unit, Option
- **Riverpod 2.x**: @riverpod 어노테이션, AsyncValue, autoDispose, build_runner

### 1.2 의존성 설치 (v2.0.0 - Either + Riverpod)

#### pubspec.yaml 확인

```yaml
dependencies:
  # Either 패턴 라이브러리
  fpdart: ^1.1.0  # ✅ 최신 Dart 3 호환

  # Riverpod 2.x ← v2.0.0 NEW!
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # 기존 의존성 유지
  freezed_annotation: ^2.4.1
  get_it: ^7.6.0  # ⚠️ Step 5 이후 점진적 제거
  # ... (기타 의존성)

dev_dependencies:
  # 코드 생성
  freezed: ^2.4.7
  build_runner: ^2.4.8
  riverpod_generator: ^2.4.0  # ← v2.0.0 NEW!
```

#### 의존성 설치 명령어

```bash
# 1. pubspec.yaml에 fpdart + riverpod 추가 (위 참조)
# 2. 의존성 설치
flutter pub get

# 3. 설치 확인
flutter pub deps | grep -E '(fpdart|riverpod)'
# 출력:
# fpdart 1.1.0
# flutter_riverpod 2.5.1
# riverpod_annotation 2.3.5
# riverpod_generator 2.4.0
```

### 1.3 Git 백업

**중요**: 마이그레이션 시작 전 반드시 백업하세요.

```bash
# 1. 새 브랜치 생성
git checkout -b feature/phase2-either-pattern

# 2. 현재 상태 커밋
git add .
git commit -m "chore: Phase 2 시작 전 백업"

# 3. 브랜치 확인
git branch
# * feature/phase2-either-pattern
#   main
```

**롤백 방법** (문제 발생 시):
```bash
# 전체 롤백
git checkout main
git branch -D feature/phase2-either-pattern

# 특정 Step 롤백
git reset --hard HEAD~1  # 마지막 커밋 취소
```

---

## 2. Step 1: Repository Interface 마이그레이션

**목표**: Repository 인터페이스의 모든 메서드를 Either 패턴으로 변경

**소요 시간**: 1일
**난이도**: ⭐⭐☆☆☆

### 2.1 IPostCreationRepositoryV2

**파일**: `lib/features/creation/domain/repositories/i_post_creation_repository_v2.dart`

#### Before (Raw Types)

```dart
import 'dart:io';
import '../models/aggregates/post_creation.dart';
import '../models/value_objects/target_audience.dart';

abstract class IPostCreationRepositoryV2 {
  // ❌ Raw types (에러는 throw)
  Future<String> createPost({required PostCreation post});

  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  });

  Future<void> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  Future<void> deletePost(String postId);

  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  });

  Future<void> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side,
  });

  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });

  Future<PostCreation?> getPost(String postId);

  Stream<PostCreation> watchPost(String postId);
}
```

#### After (Either Pattern)

```dart
import 'dart:io';
import 'package:fpdart/fpdart.dart';  // ✅ fpdart 추가
import '../models/aggregates/post_creation.dart';
import '../models/value_objects/target_audience.dart';
import '../failures/creation_failures.dart';  // ✅ Failure 추가

abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Create a new post using PostCreation aggregate
  /// Returns the created post ID
  ///
  /// **Errors**:
  /// - ServerError: Firestore 연결 실패
  /// - NetworkError: 네트워크 오류
  /// - Unexpected: 알 수 없는 오류
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  });

  // ====== Update Operations ======

  /// Update post using PostCreation aggregate
  ///
  /// **Returns**: Unit (함수형 프로그래밍의 void)
  /// **Errors**:
  /// - NotFound: 게시물 미존재
  /// - ServerError: Firestore 업데이트 실패
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
  });

  /// Update post using partial data (for granular updates)
  Future<Either<CreationFailure, Unit>> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  });

  // ====== Delete Operations ======

  /// Delete post
  ///
  /// **Errors**:
  /// - NotFound: 게시물 미존재
  /// - PermissionDenied: 권한 없음
  Future<Either<CreationFailure, Unit>> deletePost(String postId);

  // ====== Media Operations ======

  /// Upload post media
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
  });

  /// Delete post media
  Future<Either<CreationFailure, Unit>> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side, // 'A' or 'B'
  });

  // ====== Status Operations ======

  /// Update post status
  Future<Either<CreationFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
  });

  /// Mark post as processed
  Future<Either<CreationFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  });

  // ====== Query Operations ======

  /// Get post as PostCreation aggregate
  ///
  /// **Returns**: Option<PostCreation> (함수형 프로그래밍의 null)
  /// - Some(post): 게시물 존재
  /// - None: 게시물 미존재
  ///
  /// **Errors**:
  /// - ServerError: Firestore 조회 실패
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(String postId);

  /// Stream post changes as PostCreation aggregate
  ///
  /// **Note**: Stream 에러는 StreamError로 전파됨
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId);
}
```

#### 주요 변경 사항

**1. Import 추가**:
```dart
import 'package:fpdart/fpdart.dart';           // ✅ Either, Unit, Option
import '../failures/creation_failures.dart';   // ✅ CreationFailure
```

**2. 반환 타입 변경**:

| Before | After | 이유 |
|--------|-------|------|
| `Future<String>` | `Future<Either<CreationFailure, String>>` | 에러 타입 명시 |
| `Future<void>` | `Future<Either<CreationFailure, Unit>>` | void → Unit |
| `Future<T?>` | `Future<Either<CreationFailure, Option<T>>>` | null → Option |
| `Stream<T>` | `Stream<Either<CreationFailure, T>>` | Stream 에러 처리 |

**3. 문서화 강화**:
- 각 메서드에 **Errors** 섹션 추가
- Either의 Left/Right 케이스 명시
- Option의 Some/None 설명 추가

### 2.2 IMediaRepository

**파일**: `lib/features/creation/domain/repositories/i_media_repository.dart`

#### Before

```dart
abstract class IMediaRepository {
  Future<String> uploadImage({
    required File image,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  });

  Future<void> deleteImage(String imageUrl);

  Future<List<String>> uploadMultipleImages({
    required List<File> images,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  });
}
```

#### After

```dart
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';

abstract class IMediaRepository {
  /// Upload single image to Firebase Storage
  ///
  /// **Returns**: Image URL
  /// **Errors**:
  /// - InvalidFile: 파일 형식 오류
  /// - UploadFailed: 업로드 실패
  /// - NetworkError: 네트워크 오류
  Future<Either<CreationFailure, String>> uploadImage({
    required File image,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  });

  /// Delete image from Firebase Storage
  Future<Either<CreationFailure, Unit>> deleteImage(String imageUrl);

  /// Upload multiple images to Firebase Storage
  ///
  /// **Returns**: List of image URLs
  /// **Errors**:
  /// - InvalidFile: 하나 이상의 파일 형식 오류
  /// - UploadFailed: 일부 업로드 실패
  /// - NetworkError: 네트워크 오류
  Future<Either<CreationFailure, List<String>>> uploadMultipleImages({
    required List<File> images,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  });
}
```

### 2.3 IAIGenerationRepository

**파일**: `lib/features/creation/domain/repositories/i_ai_generation_repository.dart`

#### Before

```dart
abstract class IAIGenerationRepository {
  Future<String> generateTitle({
    required String description,
    required String context,
  });

  Future<List<String>> generateTags({
    required String title,
    required String description,
  });
}
```

#### After

```dart
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';

abstract class IAIGenerationRepository {
  /// Generate post title using AI
  ///
  /// **Returns**: Generated title
  /// **Errors**:
  /// - AIServiceError: AI 서비스 오류
  /// - InvalidInput: 입력 데이터 오류
  /// - QuotaExceeded: API 할당량 초과
  Future<Either<CreationFailure, String>> generateTitle({
    required String description,
    required String context,
  });

  /// Generate post tags using AI
  ///
  /// **Returns**: List of generated tags
  /// **Errors**:
  /// - AIServiceError: AI 서비스 오류
  /// - InvalidInput: 입력 데이터 오류
  Future<Either<CreationFailure, List<String>>> generateTags({
    required String title,
    required String description,
  });
}
```

### 2.4 Step 1 검증

**컴파일 확인**:

```bash
# 1. 빌드 (컴파일 에러 확인)
flutter analyze

# 예상 에러:
# - Repository 구현체: 반환 타입 불일치
# - UseCase: Repository 호출 부분 에러
# ⚠️ 이는 정상입니다 (Step 2, 3에서 수정 예정)
```

**체크리스트**:

- [ ] IPostCreationRepositoryV2: 모든 메서드 Either 반환
- [ ] IMediaRepository: 모든 메서드 Either 반환
- [ ] IAIGenerationRepository: 모든 메서드 Either 반환
- [ ] void → Unit 변경
- [ ] T? → Option<T> 변경
- [ ] 각 메서드에 **Errors** 문서화 추가
- [ ] fpdart import 추가
- [ ] CreationFailure import 추가

**Git 커밋**:

```bash
git add lib/features/creation/domain/repositories/
git commit -m "feat(creation): Step 1 - Repository Interface Either 패턴 도입

- IPostCreationRepositoryV2: Raw types → Either
- IMediaRepository: Raw types → Either
- IAIGenerationRepository: Raw types → Either
- void → Unit, T? → Option<T> 변경
- Errors 문서화 추가

Phase 2-2 Step 1/4 완료"
```

---

## 3. Step 2: Repository Implementation 마이그레이션

**목표**: Repository 구현체의 throw → Either 변환

**소요 시간**: 1.5일
**난이도**: ⭐⭐⭐☆☆

### 3.1 PostCreationRepositoryV2Impl

**파일**: `lib/features/creation/data/repositories/post_creation_repository_v2_impl.dart`

#### Before (throw 패턴)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../../domain/failures/creation_failures.dart';

class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final FirebaseFirestore _firestore;

  PostCreationRepositoryV2Impl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> createPost({required PostCreation post}) async {
    try {
      final data = _mapper.toCreateDocument(post);

      // Create the post using DataSource
      final docRef = await _firestore.collection('posts').add(data);

      return docRef.id;  // ✅ 성공 시 ID 반환

    } on FirebaseException catch (e) {
      throw CreationFailure.serverError(e.message ?? 'Firebase error');  // ❌ throw
    } catch (e) {
      throw CreationFailure.unexpected(e.toString());  // ❌ throw
    }
  }

  @override
  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  }) async {
    try {
      final data = _mapper.toUpdateDocument(post);
      await _firestore.collection('posts').doc(postId).update(data);

      // ✅ void 반환 (성공)

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        throw CreationFailure.notFound('Post not found: $postId');  // ❌ throw
      }
      throw CreationFailure.serverError(e.message ?? 'Firebase error');  // ❌ throw
    } catch (e) {
      throw CreationFailure.unexpected(e.toString());  // ❌ throw
    }
  }

  @override
  Future<PostCreation?> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return null;  // ✅ null 반환 (존재하지 않음)
      }

      return _mapper.fromFirestore(doc);

    } on FirebaseException catch (e) {
      throw CreationFailure.serverError(e.message ?? 'Firebase error');  // ❌ throw
    } catch (e) {
      throw CreationFailure.unexpected(e.toString());  // ❌ throw
    }
  }
}
```

#### After (Either 패턴)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';  // ✅ Either, Unit, Option
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../../domain/failures/creation_failures.dart';

class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final FirebaseFirestore _firestore;

  PostCreationRepositoryV2Impl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
  }) async {
    try {
      final data = _mapper.toCreateDocument(post);

      // Create the post using DataSource
      final docRef = await _firestore.collection('posts').add(data);

      return right(docRef.id);  // ✅ Either 성공 (Right)

    } on FirebaseException catch (e) {
      return left(
        CreationFailure.serverError(e.message ?? 'Firebase error'),
      );  // ✅ Either 에러 (Left)
    } catch (e) {
      return left(
        CreationFailure.unexpected(e.toString()),
      );  // ✅ Either 에러 (Left)
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
  }) async {
    try {
      final data = _mapper.toUpdateDocument(post);
      await _firestore.collection('posts').doc(postId).update(data);

      return right(unit);  // ✅ Unit 반환 (성공)

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return left(
          CreationFailure.notFound('Post not found: $postId'),
        );
      }
      return left(
        CreationFailure.serverError(e.message ?? 'Firebase error'),
      );
    } catch (e) {
      return left(
        CreationFailure.unexpected(e.toString()),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update(data);
      return right(unit);  // ✅ Unit

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return left(CreationFailure.notFound('Post not found: $postId'));
      }
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      return right(unit);

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return left(CreationFailure.notFound('Post not found: $postId'));
      }
      if (e.code == 'permission-denied') {
        return left(CreationFailure.permissionDenied('Cannot delete post'));
      }
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(
    String postId,
  ) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return right(none());  // ✅ Option.none() (존재하지 않음)
      }

      final post = _mapper.fromFirestore(doc);
      return right(some(post));  // ✅ Option.some(post) (존재함)

    } on FirebaseException catch (e) {
      return left(
        CreationFailure.serverError(e.message ?? 'Firebase error'),
      );
    } catch (e) {
      return left(
        CreationFailure.unexpected(e.toString()),
      );
    }
  }

  @override
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId) {
    try {
      return _firestore
          .collection('posts')
          .doc(postId)
          .snapshots()
          .map((doc) {
            if (!doc.exists) {
              return left(
                CreationFailure.notFound('Post not found: $postId'),
              ) as Either<CreationFailure, PostCreation>;
            }

            try {
              final post = _mapper.fromFirestore(doc);
              return right(post) as Either<CreationFailure, PostCreation>;
            } catch (e) {
              return left(
                CreationFailure.unexpected(e.toString()),
              ) as Either<CreationFailure, PostCreation>;
            }
          });
    } catch (e) {
      // Stream 생성 실패 시 에러 스트림 반환
      return Stream.value(
        left(CreationFailure.unexpected(e.toString())),
      );
    }
  }

  // ====== Media Operations ======

  @override
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  }) async {
    try {
      final data = {
        if (side == 'A') 'mediaA': FieldValue.arrayUnion([mediaUrl]),
        if (side == 'B') 'mediaB': FieldValue.arrayUnion([mediaUrl]),
        if (side == null) 'media': FieldValue.arrayUnion([mediaUrl]),
        'mediaType': mediaType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('posts').doc(postId).update(data);
      return right(unit);

    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        return left(CreationFailure.notFound('Post not found: $postId'));
      }
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side,
  }) async {
    try {
      final data = {
        if (side == 'A') 'mediaA': FieldValue.arrayRemove([mediaUrl]),
        if (side == 'B') 'mediaB': FieldValue.arrayRemove([mediaUrl]),
        if (side == null) 'media': FieldValue.arrayRemove([mediaUrl]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('posts').doc(postId).update(data);
      return right(unit);

    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return right(unit);

    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  }) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'processedAt': processedAt ?? FieldValue.serverTimestamp(),
        'status': 'processed',
      });
      return right(unit);

    } on FirebaseException catch (e) {
      return left(CreationFailure.serverError(e.message ?? 'Firebase error'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

#### 주요 변경 패턴

**1. throw → left 변환**:

```dart
// Before
throw CreationFailure.serverError('Error message');

// After
return left(CreationFailure.serverError('Error message'));
```

**2. 성공 반환 → right 변환**:

```dart
// Before: 값 반환
return postId;

// After: right로 감싸기
return right(postId);

// Before: void (암묵적 return)
await someOperation();

// After: Unit 명시적 반환
await someOperation();
return right(unit);
```

**3. null → Option 변환**:

```dart
// Before
if (!doc.exists) {
  return null;
}
return post;

// After
if (!doc.exists) {
  return right(none());  // Option.none()
}
return right(some(post));  // Option.some(post)
```

**4. Stream 변환**:

```dart
// Before
Stream<PostCreation> watchPost(String postId) {
  return _firestore
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map((doc) => _mapper.fromFirestore(doc));
}

// After
Stream<Either<CreationFailure, PostCreation>> watchPost(String postId) {
  return _firestore
      .collection('posts')
      .doc(postId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) {
          return left(CreationFailure.notFound('Post not found'));
        }

        try {
          final post = _mapper.fromFirestore(doc);
          return right(post);
        } catch (e) {
          return left(CreationFailure.unexpected(e.toString()));
        }
      });
}
```

### 3.2 MediaRepositoryImpl

**파일**: `lib/features/creation/data/repositories/media_upload_repository_impl.dart`

#### 패턴 적용 예시

```dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../domain/failures/creation_failures.dart';

class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseStorage _storage;

  MediaRepositoryImpl({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<Either<CreationFailure, String>> uploadImage({
    required File image,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. 파일 검증
      if (!await image.exists()) {
        return left(CreationFailure.invalidFile('Image file does not exist'));
      }

      // 2. 파일 크기 확인
      final fileSize = await image.length();
      if (fileSize > 10 * 1024 * 1024) {  // 10MB
        return left(CreationFailure.invalidFile('Image too large (max 10MB)'));
      }

      // 3. Firebase Storage 업로드
      final ref = _storage.ref().child('posts/$userId/$postId/${DateTime.now().millisecondsSinceEpoch}.jpg');

      final uploadTask = ref.putFile(image);

      // 4. 프로그레스 모니터링
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
      });

      // 5. 업로드 완료 대기
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return right(downloadUrl);  // ✅ 성공

    } on FirebaseException catch (e) {
      if (e.code == 'unauthorized') {
        return left(CreationFailure.permissionDenied('Upload permission denied'));
      }
      if (e.code == 'canceled') {
        return left(CreationFailure.uploadCanceled('Upload was canceled'));
      }
      return left(CreationFailure.uploadFailed(e.message ?? 'Upload failed'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return right(unit);

    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return left(CreationFailure.notFound('Image not found'));
      }
      return left(CreationFailure.serverError(e.message ?? 'Delete failed'));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, List<String>>> uploadMultipleImages({
    required List<File> images,
    required String userId,
    required String postId,
    Function(double)? onProgress,
  }) async {
    try {
      final urls = <String>[];
      final totalImages = images.length;

      for (var i = 0; i < totalImages; i++) {
        final result = await uploadImage(
          image: images[i],
          userId: userId,
          postId: postId,
          onProgress: (progress) {
            final totalProgress = (i + progress) / totalImages;
            onProgress?.call(totalProgress);
          },
        );

        // Either 처리: 실패 시 즉시 반환
        final url = result.fold(
          (failure) => throw failure,  // ⚠️ 임시로 throw (나중에 개선 가능)
          (url) => url,
        );

        urls.add(url);
      }

      return right(urls);

    } on CreationFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

### 3.3 AIGenerationRepositoryImpl

**파일**: `lib/features/creation/data/repositories/ai_generation_repository_impl.dart`

```dart
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../domain/repositories/i_ai_generation_repository.dart';
import '../../domain/failures/creation_failures.dart';

class AIGenerationRepositoryImpl implements IAIGenerationRepository {
  final http.Client _client;
  final String _apiKey;

  AIGenerationRepositoryImpl({
    http.Client? client,
    required String apiKey,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey;

  @override
  Future<Either<CreationFailure, String>> generateTitle({
    required String description,
    required String context,
  }) async {
    try {
      // 1. 입력 검증
      if (description.isEmpty) {
        return left(CreationFailure.invalidInput('Description is empty'));
      }

      // 2. API 호출
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'prompt': 'Generate a title for: $description\nContext: $context',
          'max_tokens': 50,
        }),
      );

      // 3. 응답 처리
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['choices'][0]['text'].trim();
        return right(title);
      } else if (response.statusCode == 429) {
        return left(CreationFailure.quotaExceeded('AI API quota exceeded'));
      } else if (response.statusCode == 401) {
        return left(CreationFailure.permissionDenied('Invalid API key'));
      } else {
        return left(CreationFailure.aiServiceError(
          'API returned ${response.statusCode}',
        ));
      }

    } on http.ClientException catch (e) {
      return left(CreationFailure.networkError(e.message));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, List<String>>> generateTags({
    required String title,
    required String description,
  }) async {
    try {
      if (title.isEmpty && description.isEmpty) {
        return left(CreationFailure.invalidInput('Title and description are empty'));
      }

      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'prompt': 'Generate tags for:\nTitle: $title\nDescription: $description',
          'max_tokens': 100,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tagsText = data['choices'][0]['text'].trim();
        final tags = tagsText.split(',').map((tag) => tag.trim()).toList();
        return right(tags);
      } else if (response.statusCode == 429) {
        return left(CreationFailure.quotaExceeded('AI API quota exceeded'));
      } else {
        return left(CreationFailure.aiServiceError(
          'API returned ${response.statusCode}',
        ));
      }

    } on http.ClientException catch (e) {
      return left(CreationFailure.networkError(e.message));
    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }
}
```

### 3.4 Step 2 검증

**컴파일 확인**:

```bash
# 1. 빌드
flutter analyze

# 예상: Repository 구현체는 에러 없음
# 여전히 UseCase에서 에러 발생 (Step 3에서 수정)
```

**단위 테스트 (선택)**:

```dart
// test/features/creation/data/repositories/post_creation_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('PostCreationRepositoryV2Impl', () {
    test('createPost returns Right(postId) on success', () async {
      // Arrange
      final repository = PostCreationRepositoryV2Impl(/* mock firestore */);
      final post = PostCreation(/* test data */);

      // Act
      final result = await repository.createPost(post: post);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not be failure'),
        (postId) => expect(postId, isNotEmpty),
      );
    });

    test('createPost returns Left(ServerError) on Firebase error', () async {
      // Arrange
      final repository = PostCreationRepositoryV2Impl(/* mock firestore with error */);
      final post = PostCreation(/* test data */);

      // Act
      final result = await repository.createPost(post: post);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerError>()),
        (postId) => fail('Should not be success'),
      );
    });
  });
}
```

**체크리스트**:

- [ ] PostCreationRepositoryV2Impl: 모든 메서드 Either 반환
- [ ] MediaRepositoryImpl: 모든 메서드 Either 반환
- [ ] AIGenerationRepositoryImpl: 모든 메서드 Either 반환
- [ ] throw → left 변환
- [ ] 성공 값 → right 변환
- [ ] void → right(unit) 변환
- [ ] null → right(none()) / right(some(value)) 변환
- [ ] Stream → Stream<Either> 변환
- [ ] FirebaseException 에러 코드 별 Failure 매핑

**Git 커밋**:

```bash
git add lib/features/creation/data/repositories/
git commit -m "feat(creation): Step 2 - Repository Implementation Either 패턴 적용

- PostCreationRepositoryV2Impl: throw → Either
- MediaRepositoryImpl: throw → Either
- AIGenerationRepositoryImpl: throw → Either
- Unit, Option 타입 도입
- Stream<Either> 처리 추가

Phase 2-2 Step 2/4 완료"
```

---

## 4. Step 3: UseCase 마이그레이션

**목표**: UseCase의 Result<T> → Either<Failure, T> 변환

**소요 시간**: 2일
**난이도**: ⭐⭐⭐⭐☆ (가장 복잡)

### 4.1 CreatePostUseCase (복잡)

**파일**: `lib/features/creation/domain/usecases/create_post_usecase.dart`

이 UseCase는 **가장 복잡**하므로 상세히 다룹니다.

#### Before (Result<T>)

```dart
import 'package:versus_space/core/types/result.dart';
import '../failures/creation_failures.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';

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
        return ResultFailure(validationResult);  // ❌ 수동 에러 반환
      }

      onProgress?.call(0.1);

      // 2. 이미지 처리 A
      final resultA = await _processImages(
        images: dto.imagesA,
        box: 'A',
        onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
      );

      if (resultA.isFailure) {
        return ResultFailure(resultA.failureOrNull!);  // ❌ 수동 에러 전파
      }

      onProgress?.call(0.4);

      // 3. 이미지 처리 B
      final resultB = await _processImages(
        images: dto.imagesB,
        box: 'B',
        onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
      );

      if (resultB.isFailure) {
        return ResultFailure(resultB.failureOrNull!);  // ❌ 수동 에러 전파
      }

      onProgress?.call(0.7);

      // 4. 이미지 업로드 A
      final uploadResultA = await _uploadImages(
        processedImages: resultA.valueOrNull!.approvedFiles,
      );

      if (uploadResultA.isFailure) {
        return ResultFailure(uploadResultA.failureOrNull!);  // ❌ 수동 에러 전파
      }

      // 5. 이미지 업로드 B
      final uploadResultB = await _uploadImages(
        processedImages: resultB.valueOrNull!.approvedFiles,
      );

      if (uploadResultB.isFailure) {
        return ResultFailure(uploadResultB.failureOrNull!);  // ❌ 수동 에러 전파
      }

      onProgress?.call(0.8);

      // 6. PostCreation 생성
      final postCreation = PostCreation(
        title: dto.title,
        description: dto.description,
        mediaA: uploadResultA.valueOrNull!,
        mediaB: uploadResultB.valueOrNull!,
        // ... other fields
      );

      // 7. Repository 호출 (Raw type → try-catch 필요)
      final postId = await _postRepository.createPost(post: postCreation);  // ⚠️ throw 가능

      onProgress?.call(1.0);

      return ResultSuccess(postCreation.copyWith(id: postId));

    } on CreationFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(CreationFailure.unexpected(e.toString()));
    }
  }

  // Helper method
  Future<Result<ProcessedImages>> _processImages({
    required List<File> images,
    required String box,
    Function(double)? onProgress,
  }) async {
    // ... (복잡한 로직)
  }
}
```

#### After (Either)

```dart
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';
import '../repositories/i_post_creation_repository_v2.dart';
import '../repositories/i_media_repository.dart';

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

  /// Execute post creation with Either pattern
  ///
  /// **Process**:
  /// 1. Validate inputs → Either<Failure, Unit>
  /// 2. Process images A → Either<Failure, ProcessedImages>
  /// 3. Process images B → Either<Failure, ProcessedImages>
  /// 4. Upload images A → Either<Failure, List<String>>
  /// 5. Upload images B → Either<Failure, List<String>>
  /// 6. Create post → Either<Failure, String>
  ///
  /// **Returns**: Either<CreationFailure, PostCreation>
  Future<Either<CreationFailure, PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  }) async {
    onProgress?.call(0.0);

    // ✅ 함수형 조합: 각 단계가 flatMap으로 연결됨
    return _validateInputsEither(
      title: dto.title,
      description: dto.description,
      imagesA: dto.imagesA,
      imagesB: dto.imagesB,
    )
        .map((_) {
          onProgress?.call(0.1);
          return unit;
        })
        // 2. 이미지 처리 A (flatMap으로 에러 자동 전파)
        .flatMap((_) => _processImagesEither(
              images: dto.imagesA,
              box: 'A',
              onProgress: (progress) => onProgress?.call(0.1 + progress * 0.3),
            ))
        .map((processedA) {
          onProgress?.call(0.4);
          return processedA;
        })
        // 3. 이미지 처리 B
        .flatMap((processedA) => _processImagesEither(
              images: dto.imagesB,
              box: 'B',
              onProgress: (progress) => onProgress?.call(0.4 + progress * 0.3),
            ).map((processedB) => (processedA, processedB)))
        .map((tuple) {
          onProgress?.call(0.7);
          return tuple;
        })
        // 4. 이미지 업로드 A
        .flatMap((tuple) {
          final (processedA, processedB) = tuple;
          return _uploadImagesEither(
            processedImages: processedA.approvedFiles,
          ).map((urlsA) => (urlsA, processedB));
        })
        // 5. 이미지 업로드 B
        .flatMap((tuple) {
          final (urlsA, processedB) = tuple;
          return _uploadImagesEither(
            processedImages: processedB.approvedFiles,
          ).map((urlsB) => (urlsA, urlsB));
        })
        .map((tuple) {
          onProgress?.call(0.8);
          return tuple;
        })
        // 6. PostCreation 생성
        .map((tuple) {
          final (urlsA, urlsB) = tuple;
          return PostCreation(
            title: dto.title,
            description: dto.description,
            mediaA: urlsA,
            mediaB: urlsB,
            createdAt: DateTime.now(),
            // ... other fields
          );
        })
        // 7. Repository 호출 (Either 반환 → flatMap 가능)
        .flatMap((postCreation) => _postRepository
                .createPost(post: postCreation)
                .map((postId) => postCreation.copyWith(id: postId)))
        .map((finalPost) {
          onProgress?.call(1.0);
          return finalPost;
        });
  }

  /// 입력 검증 (Either 반환)
  Either<CreationFailure, Unit> _validateInputsEither({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) {
    if (title.isEmpty) {
      return left(CreationFailure.invalidInput('Title is empty'));
    }

    if (description.isEmpty) {
      return left(CreationFailure.invalidInput('Description is empty'));
    }

    if (imagesA.isEmpty && imagesB.isEmpty) {
      return left(CreationFailure.invalidInput('At least one image required'));
    }

    return right(unit);  // ✅ 검증 성공
  }

  /// 이미지 처리 (Either 반환)
  Future<Either<CreationFailure, ProcessedImages>> _processImagesEither({
    required List<File> images,
    required String box,
    Function(double)? onProgress,
  }) async {
    // ... (복잡한 로직 - Either 패턴으로 변경)
    try {
      // 이미지 검증
      for (final image in images) {
        if (!await image.exists()) {
          return left(CreationFailure.invalidFile('Image does not exist'));
        }
      }

      // 처리 로직
      final processed = ProcessedImages(
        approvedFiles: images,
        rejectedFiles: [],
      );

      onProgress?.call(1.0);

      return right(processed);

    } catch (e) {
      return left(CreationFailure.unexpected(e.toString()));
    }
  }

  /// 이미지 업로드 (Either 반환)
  Future<Either<CreationFailure, List<String>>> _uploadImagesEither({
    required List<File> processedImages,
  }) async {
    // MediaRepository는 이미 Either 반환
    return _mediaRepository.uploadMultipleImages(
      images: processedImages,
      userId: 'currentUserId',  // TODO: Get from auth
      postId: 'tempPostId',
    );
  }
}
```

#### 주요 변경 사항

**1. Result<T> → Either 변환**:

```dart
// Before
Future<Result<PostCreation>> execute(...);

// After
Future<Either<CreationFailure, PostCreation>> execute(...);
```

**2. 보일러플레이트 제거 (flatMap)**:

```dart
// Before: 각 단계마다 수동 에러 체크 (15줄)
final resultA = await _processImages(...);
if (resultA.isFailure) {
  return ResultFailure(resultA.failureOrNull!);
}

final resultB = await _processImages(...);
if (resultB.isFailure) {
  return ResultFailure(resultB.failureOrNull!);
}

// After: flatMap 체이닝 (6줄)
return _processImagesEither(...)
  .flatMap((_) => _processImagesEither(...));
```

**3. Helper 메서드도 Either 반환**:

```dart
// Before
Future<Result<ProcessedImages>> _processImages(...);

// After
Future<Either<CreationFailure, ProcessedImages>> _processImagesEither(...);
```

**4. Tuple 패턴 사용** (중간 값 전달):

```dart
// 두 값을 다음 단계로 전달
.flatMap((processedA) => _processImagesEither(...)
    .map((processedB) => (processedA, processedB)))  // Tuple

// Tuple 분해
.flatMap((tuple) {
  final (processedA, processedB) = tuple;
  return _uploadImagesEither(...);
})
```

### 4.2 ModerateContentUseCase

**파일**: `lib/features/creation/domain/usecases/moderate_content_usecase.dart`

#### 간단한 예시 (패턴 동일)

```dart
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';
import '../services/i_moderation_service.dart';

class ModerateContentUseCase {
  final IModerationService _moderationService;

  ModerateContentUseCase({
    required IModerationService moderationService,
  }) : _moderationService = moderationService;

  /// Moderate content using AI
  Future<Either<CreationFailure, ModerationResult>> execute({
    required String content,
    required String contentType,
  }) async {
    // 1. 입력 검증
    if (content.isEmpty) {
      return left(CreationFailure.invalidInput('Content is empty'));
    }

    // 2. Moderation Service 호출 (이미 Either 반환 가정)
    return _moderationService.moderateContent(
      content: content,
      contentType: contentType,
    );
  }
}
```

### 4.3 ValidatePostUseCase

**파일**: `lib/features/creation/domain/usecases/validate_post_usecase.dart`

```dart
import 'package:fpdart/fpdart.dart';
import '../failures/creation_failures.dart';
import '../models/aggregates/post_creation.dart';

class ValidatePostUseCase {
  /// Validate post creation data
  Either<CreationFailure, Unit> execute({
    required PostCreation post,
  }) {
    // 1. Title 검증
    if (post.title.isEmpty) {
      return left(CreationFailure.invalidInput('Title is empty'));
    }

    if (post.title.length > 100) {
      return left(CreationFailure.invalidInput('Title too long (max 100)'));
    }

    // 2. Description 검증
    if (post.description.isEmpty) {
      return left(CreationFailure.invalidInput('Description is empty'));
    }

    if (post.description.length > 1000) {
      return left(CreationFailure.invalidInput('Description too long (max 1000)'));
    }

    // 3. Media 검증
    if (post.mediaA.isEmpty && post.mediaB.isEmpty) {
      return left(CreationFailure.invalidInput('At least one media required'));
    }

    // ✅ 모든 검증 통과
    return right(unit);
  }
}
```

### 4.4 나머지 UseCases (12개)

**동일한 패턴 적용**:

1. `Result<T>` → `Either<CreationFailure, T>`
2. `ResultSuccess/ResultFailure` → `right/left`
3. `if (result.isFailure)` → `flatMap`
4. Helper 메서드도 Either 반환

**UseCase 목록**:

```
lib/features/creation/domain/usecases/
├── create_post_usecase.dart                 ✅ (위에서 완료)
├── moderate_content_usecase.dart            ✅ (위에서 완료)
├── validate_post_usecase.dart               ✅ (위에서 완료)
├── audience/
│   ├── manage_target_audience_usecase.dart  ← 동일 패턴
│   └── validate_audience_usecase.dart       ← 동일 패턴
├── media/
│   ├── process_media_usecase.dart           ← 동일 패턴
│   └── upload_media_usecase.dart            ← 동일 패턴
└── ... (5개 더)
```

**패턴 요약**:

```dart
// 1. Import 변경
import 'package:versus_space/core/types/result.dart';  // ❌ 제거
import 'package:fpdart/fpdart.dart';  // ✅ 추가

// 2. 반환 타입 변경
Future<Result<T>> execute(...);  // ❌
Future<Either<CreationFailure, T>> execute(...);  // ✅

// 3. 에러 반환
return ResultFailure(failure);  // ❌
return left(failure);  // ✅

// 4. 성공 반환
return ResultSuccess(value);  // ❌
return right(value);  // ✅

// 5. flatMap 체이닝
if (result.isFailure) return ResultFailure(...);  // ❌
return step1().flatMap((_) => step2());  // ✅
```

### 4.5 Step 3 검증

**컴파일 확인**:

```bash
# 1. 빌드
flutter analyze

# 예상: UseCase 에러 해결됨
# 여전히 Provider에서 에러 발생 (Step 4에서 수정)
```

**단위 테스트**:

```dart
// test/features/creation/domain/usecases/create_post_usecase_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('CreatePostUseCase', () {
    late CreatePostUseCase useCase;
    late MockPostRepository mockRepository;
    late MockMediaRepository mockMediaRepository;

    setUp(() {
      mockRepository = MockPostRepository();
      mockMediaRepository = MockMediaRepository();
      useCase = CreatePostUseCase(
        postRepository: mockRepository,
        mediaRepository: mockMediaRepository,
        manageTargetAudienceUseCase: MockAudienceUseCase(),
      );
    });

    test('execute returns Right(PostCreation) on success', () async {
      // Arrange
      when(mockRepository.createPost(post: any))
          .thenAnswer((_) async => right('post123'));

      final dto = PostCreationDto(/* test data */);

      // Act
      final result = await useCase.execute(dto: dto);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not be failure'),
        (postCreation) {
          expect(postCreation.id, 'post123');
          expect(postCreation.title, dto.title);
        },
      );
    });

    test('execute returns Left(InvalidInput) when title is empty', () async {
      // Arrange
      final dto = PostCreationDto(title: '', /* other data */);

      // Act
      final result = await useCase.execute(dto: dto);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<InvalidInput>());
          expect(failure.message, contains('Title'));
        },
        (postCreation) => fail('Should not be success'),
      );
    });

    test('execute propagates Repository error via flatMap', () async {
      // Arrange
      when(mockRepository.createPost(post: any))
          .thenAnswer((_) async => left(CreationFailure.serverError('Firestore error')));

      final dto = PostCreationDto(/* valid data */);

      // Act
      final result = await useCase.execute(dto: dto);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerError>()),
        (postCreation) => fail('Should not be success'),
      );
    });
  });
}
```

**체크리스트**:

- [ ] 모든 UseCase (15개) Either 반환
- [ ] Result import 제거, fpdart import 추가
- [ ] ResultSuccess/ResultFailure → right/left
- [ ] if (isFailure) → flatMap 체이닝
- [ ] Helper 메서드도 Either 반환
- [ ] 단위 테스트 작성 (최소 3개 UseCase)

**Git 커밋**:

```bash
git add lib/features/creation/domain/usecases/
git commit -m "feat(creation): Step 3 - UseCase Either 패턴 적용

- CreatePostUseCase: Result → Either, flatMap 체이닝
- ModerateContentUseCase: Result → Either
- ValidatePostUseCase: Result → Either
- 나머지 12개 UseCases: 동일 패턴 적용
- 보일러플레이트 60% 감소 (flatMap 사용)

Phase 2-2 Step 3/4 완료"
```

---

## 5. Step 4: Provider 마이그레이션

**목표**: Provider의 Result 처리 → Either.fold 변환

**소요 시간**: 1일
**난이도**: ⭐⭐☆☆☆

### 5.1 CreatePostProviderV2

**파일**: `lib/features/creation/presentation/providers/create_post_provider_v2.dart`

#### Before (Result<T> 처리)

```dart
import 'package:flutter/foundation.dart';
import '../../domain/usecases/create_post_usecase.dart';

class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
  }) : _createPostUseCase = createPostUseCase;

  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;

  Future<void> createPost() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // ❌ Result<T> 처리
      final result = await _createPostUseCase.execute(
        dto: PostCreationDto.fromFormData(_formData),
      );

      // Result 타입 체크
      if (result.isSuccess) {
        _loadingState = LoadingState.success;
        notifyListeners();
      } else {
        _loadingState = LoadingState.error;
        _errorMessage = result.failureOrNull?.message ?? 'Unknown error';  // ⚠️ null 체크
        notifyListeners();
      }
    } catch (e) {
      _loadingState = LoadingState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
}
```

#### After (Either 처리)

```dart
import 'package:flutter/foundation.dart';
import '../../domain/usecases/create_post_usecase.dart';

class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
  }) : _createPostUseCase = createPostUseCase;

  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;

  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;

  Future<void> createPost() async {
    _loadingState = LoadingState.loading;
    _errorMessage = null;
    notifyListeners();

    // ✅ Either 처리
    final result = await _createPostUseCase.execute(
      dto: PostCreationDto.fromFormData(_formData),
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
      },
    );

    // fold로 Left/Right 처리 (타입 안전)
    result.fold(
      // Left: 에러
      (failure) {
        _loadingState = LoadingState.error;
        _errorMessage = failure.message;  // ✅ non-null 보장
        notifyListeners();
      },
      // Right: 성공
      (postCreation) {
        _loadingState = LoadingState.success;
        _createdPost = postCreation;
        _uploadProgress = 1.0;
        notifyListeners();
      },
    );
  }
}
```

#### 주요 변경 사항

**1. isSuccess/isFailure → fold**:

```dart
// Before
if (result.isSuccess) {
  // 성공 처리
} else {
  // 에러 처리
}

// After
result.fold(
  (failure) => /* 에러 처리 */,
  (success) => /* 성공 처리 */,
);
```

**2. null 체크 제거**:

```dart
// Before
_errorMessage = result.failureOrNull?.message ?? 'Unknown error';  // ⚠️ null 체크

// After
_errorMessage = failure.message;  // ✅ non-null 보장
```

**3. try-catch 제거 가능** (선택):

```dart
// Before: Repository throw 대비
try {
  final result = await useCase.execute(...);
  // ...
} catch (e) {
  _errorMessage = e.toString();
}

// After: Either는 에러를 값으로 반환 (throw 없음)
final result = await useCase.execute(...);
result.fold(
  (failure) => _errorMessage = failure.message,
  (success) => /* 성공 처리 */,
);
```

### 5.2 나머지 Providers (4개)

**동일한 패턴 적용**:

```
lib/features/creation/presentation/providers/
├── create_post_provider_v2.dart             ✅ (위에서 완료)
├── media_upload_provider.dart               ← 동일 패턴
├── moderation_provider.dart                 ← 동일 패턴
├── audience_provider.dart                   ← 동일 패턴
└── validation_provider.dart                 ← 동일 패턴
```

**패턴 요약**:

```dart
// 1. isSuccess/isFailure → fold
if (result.isSuccess) { /* ... */ }  // ❌
result.fold((l) => /* ... */, (r) => /* ... */);  // ✅

// 2. failureOrNull/valueOrNull → fold 파라미터
result.failureOrNull?.message  // ❌
failure.message  // ✅ (fold 내부)

// 3. try-catch 제거 (선택)
try { final result = await useCase(...); } catch (e) { /* ... */ }  // ❌
final result = await useCase(...); result.fold(...);  // ✅
```

### 5.3 Step 4 검증

**컴파일 확인**:

```bash
# 1. 빌드
flutter analyze

# 예상: 모든 에러 해결됨
# ✅ Phase 2 마이그레이션 완료!
```

**Widget 테스트** (선택):

```dart
// test/features/creation/presentation/providers/create_post_provider_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('CreatePostProviderV2', () {
    late CreatePostProviderV2 provider;
    late MockCreatePostUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockCreatePostUseCase();
      provider = CreatePostProviderV2(createPostUseCase: mockUseCase);
    });

    test('createPost sets success state on Right', () async {
      // Arrange
      final postCreation = PostCreation(/* test data */);
      when(mockUseCase.execute(dto: any))
          .thenAnswer((_) async => right(postCreation));

      // Act
      await provider.createPost();

      // Assert
      expect(provider.loadingState, LoadingState.success);
      expect(provider.errorMessage, null);
    });

    test('createPost sets error state on Left', () async {
      // Arrange
      final failure = CreationFailure.serverError('Test error');
      when(mockUseCase.execute(dto: any))
          .thenAnswer((_) async => left(failure));

      // Act
      await provider.createPost();

      // Assert
      expect(provider.loadingState, LoadingState.error);
      expect(provider.errorMessage, 'Test error');
    });
  });
}
```

**체크리스트**:

- [ ] CreatePostProviderV2: fold 패턴 적용
- [ ] 나머지 4개 Providers: fold 패턴 적용
- [ ] isSuccess/isFailure 제거
- [ ] failureOrNull/valueOrNull 제거
- [ ] try-catch 제거 (선택)
- [ ] 단위 테스트 작성 (최소 2개 Provider)

**Git 커밋**:

```bash
git add lib/features/creation/presentation/providers/
git commit -m "feat(creation): Step 4 - Provider Either.fold 패턴 적용

- CreatePostProviderV2: Result → Either.fold
- 나머지 4개 Providers: 동일 패턴 적용
- isSuccess/isFailure, failureOrNull 제거
- 타입 안전성 강화 (non-null 보장)

Phase 2-2 Step 4/5 완료"
```

---

## 6. Step 5: Riverpod 2.x 마이그레이션 (6개) ← v2.0.0 NEW!

**목표**: ChangeNotifier Provider → Riverpod 2.x @riverpod 패턴

**소요 시간**: 2일

**난이도**: ⭐⭐⭐⭐☆ (고급)

### 6.1 의존성 설정 (riverpod_generator)

**이미 완료**: Section 1.2에서 riverpod 의존성 설치 완료

#### build.yaml 설정 (선택)

```yaml
# build.yaml (프로젝트 루트)
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          # Riverpod 코드 생성 최적화
          line_length: 120
```

#### 코드 생성 명령어

```bash
# Watch 모드 (개발 중 자동 생성)
dart run build_runner watch --delete-conflicting-outputs

# 한 번만 실행
dart run build_runner build --delete-conflicting-outputs
```

### 6.2 CreatePostNotifier

**파일**: `lib/features/creation/presentation/providers/create_post_providers.dart` (새 파일)

#### Before: ChangeNotifier (CreatePostProviderV2, ~300줄)

```dart
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;
  final ValidatePostUseCase _validatePostUseCase;
  final ModerateContentUseCase _moderateContentUseCase;

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
    required ValidatePostUseCase validatePostUseCase,
    required ModerateContentUseCase moderateContentUseCase,
  })  : _createPostUseCase = createPostUseCase,
        _validatePostUseCase = validatePostUseCase,
        _moderateContentUseCase = moderateContentUseCase;

  // State
  LoadingState _loadingState = LoadingState.idle;
  String? _errorMessage;
  PostFormData _formData = PostFormData();

  // Getters
  LoadingState get loadingState => _loadingState;
  String? get errorMessage => _errorMessage;
  PostFormData get formData => _formData;

  // Methods
  void updateTitle(String value) {
    _formData = _formData.copyWith(title: value);
    _clearError();
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData = _formData.copyWith(description: value);
    _clearError();
    notifyListeners();
  }

  Future<void> createPost() async {
    _loadingState = LoadingState.loading;
    _clearError();
    notifyListeners();

    final result = await _createPostUseCase.execute(dto: _formData.toDto());

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _loadingState = LoadingState.error;
      },
      (postCreation) {
        _loadingState = LoadingState.success;
      },
    );
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
```

#### After: Riverpod 2.x (@riverpod, ~180줄, 40% 감소)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import '/features/creation/domain/usecases/create_post_usecase.dart';
import '/features/creation/domain/usecases/validate_post_usecase.dart';
import '/features/creation/domain/usecases/moderate_content_usecase.dart';
import '/features/creation/domain/models/post_creation.dart';
import '/features/creation/presentation/models/post_form_data.dart';

part 'create_post_providers.g.dart';

// 1. 폼 상태 Provider (StateNotifier 대체)
@riverpod
class CreatePostForm extends _$CreatePostForm {
  @override
  PostFormData build() => PostFormData();  // 초기값

  void updateTitle(String value) {
    state = state.copyWith(title: value);  // 자동 notifyListeners()
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void updateImagesA(List<File> images) {
    state = state.copyWith(imagesA: images);
  }

  void updateImagesB(List<File> images) {
    state = state.copyWith(imagesB: images);
  }

  void toggleAnonymous() {
    state = state.copyWith(isAnonymous: !state.isAnonymous);
  }

  void reset() {
    state = PostFormData();
  }
}

// 2. 게시물 생성 Provider (Future 기반)
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

// 3. UseCase Providers (DI)
@riverpod
CreatePostUseCase createPostUseCase(CreatePostUseCaseRef ref) {
  return CreatePostUseCase(
    postRepository: ref.watch(postCreationRepositoryProvider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
    manageTargetAudienceUseCase: ref.watch(manageTargetAudienceUseCaseProvider),
  );
}

@riverpod
ValidatePostUseCase validatePostUseCase(ValidatePostUseCaseRef ref) {
  return ValidatePostUseCase();
}

@riverpod
ModerateContentUseCase moderateContentUseCase(ModerateContentUseCaseRef ref) {
  return ModerateContentUseCase(
    moderationRepository: ref.watch(moderationRepositoryProvider),
  );
}
```

**변화**:
- ✅ `extends ChangeNotifier` → `@riverpod class`
- ✅ `notifyListeners()` → 자동 (state 변경 시)
- ✅ `dispose()` → autoDispose (자동)
- ✅ LoadingState enum → AsyncValue<T>
- ✅ GetIt 의존성 → `ref.watch()`

### 6.3 MediaUploadNotifier

**파일**: `lib/features/creation/presentation/providers/media/media_upload_provider.dart`

#### Before: ChangeNotifier (~100줄)

```dart
class MediaUploadProvider extends ChangeNotifier {
  final UploadImagesUseCase _uploadImagesUseCase;

  MediaUploadProvider({required UploadImagesUseCase uploadImagesUseCase})
      : _uploadImagesUseCase = uploadImagesUseCase;

  double _uploadProgress = 0.0;
  bool _isUploading = false;

  double get uploadProgress => _uploadProgress;
  bool get isUploading => _isUploading;

  Future<Either<CreationFailure, List<String>>> uploadImages({
    required List<File> images,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    final result = await _uploadImagesUseCase.execute(
      images: images,
      onProgress: (progress) {
        _uploadProgress = progress;
        notifyListeners();
      },
    );

    _isUploading = false;
    notifyListeners();

    return result;
  }
}
```

#### After: Riverpod StreamProvider (~50줄, 50% 감소)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_upload_provider.g.dart';

// 1. 업로드 진행률 Stream
@riverpod
class MediaUploadProgress extends _$MediaUploadProgress {
  @override
  Stream<double> build() async* {
    yield 0.0;  // 초기값
  }

  void updateProgress(double progress) {
    state = AsyncData(progress);  // Stream에 새 값 방출
  }
}

// 2. 업로드 실행 Provider
@riverpod
class UploadImages extends _$UploadImages {
  @override
  FutureOr<List<String>?> build() => null;

  Future<void> execute(List<File> images) async {
    state = const AsyncLoading();

    final useCase = ref.read(uploadImagesUseCaseProvider);
    final progressNotifier = ref.read(mediaUploadProgressProvider.notifier);

    final result = await useCase.execute(
      images: images,
      onProgress: (progress) {
        progressNotifier.updateProgress(progress);
      },
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (urls) => AsyncData(urls),
    );
  }
}
```

### 6.4 나머지 Notifiers (4개)

동일한 패턴으로 변환:

**1. TargetAudienceNotifier** (target_audience_provider.dart)
```dart
@riverpod
class TargetAudience extends _$TargetAudience {
  @override
  TargetAudienceData build() => TargetAudienceData();

  void updateAgeRange(int min, int max) {
    state = state.copyWith(ageMin: min, ageMax: max);
  }
}
```

**2. MediaSelectionNotifier** (media/media_selection_provider.dart)
```dart
@riverpod
class MediaSelection extends _$MediaSelection {
  @override
  MediaSelectionState build() => MediaSelectionState();

  void selectImagesA(List<File> images) {
    state = state.copyWith(imagesA: images);
  }
}
```

**3. MediaValidationNotifier** (media/media_validation_provider.dart)
```dart
@riverpod
class MediaValidation extends _$MediaValidation {
  @override
  FutureOr<ValidationResult?> build() => null;

  Future<void> validate(List<File> images) async {
    state = const AsyncLoading();

    final useCase = ref.read(validateMediaUseCaseProvider);
    final result = await useCase.execute(images: images);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (validation) => AsyncData(validation),
    );
  }
}
```

**4. MediaStateCoordinator** (media/media_state_coordinator.dart)
```dart
// ⚠️ Coordinator는 Notifier가 아니므로 일반 Provider로 유지
@riverpod
MediaStateCoordinator mediaStateCoordinator(MediaStateCoordinatorRef ref) {
  return MediaStateCoordinator(
    selection: ref.watch(mediaSelectionProvider.notifier),
    validation: ref.watch(mediaValidationProvider.notifier),
    upload: ref.watch(uploadImagesProvider.notifier),
  );
}
```

### 6.5 Widget ConsumerWidget 전환

**파일**: `lib/features/creation/presentation/screens/create_post_screen.dart`

#### Before: StatefulWidget + ChangeNotifierProvider

```dart
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late CreatePostProviderV2 _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<CreatePostProviderV2>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<CreatePostProviderV2>(
        builder: (context, provider, child) {
          switch (provider.loadingState) {
            case LoadingState.loading:
              return CircularProgressIndicator();
            case LoadingState.error:
              return Text('Error: ${provider.errorMessage}');
            case LoadingState.success:
              return Text('Success!');
            default:
              return _buildForm(provider);
          }
        },
      ),
    );
  }

  Widget _buildForm(CreatePostProviderV2 provider) {
    return Column(
      children: [
        TextField(
          onChanged: (value) => provider.updateTitle(value),
          decoration: InputDecoration(labelText: 'Title'),
        ),
        ElevatedButton(
          onPressed: () => provider.createPost(),
          child: Text('Create Post'),
        ),
      ],
    );
  }
}
```

#### After: ConsumerWidget + ref.watch()

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreatePostScreen extends ConsumerWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formData = ref.watch(createPostFormProvider);
    final createPostAsync = ref.watch(createPostProvider);

    return Scaffold(
      body: createPostAsync.when(
        data: (postCreation) {
          if (postCreation != null) {
            return Text('Success! Post ID: ${postCreation.id}');
          }
          return _buildForm(ref, formData);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  Widget _buildForm(WidgetRef ref, PostFormData formData) {
    return Column(
      children: [
        TextField(
          onChanged: (value) {
            ref.read(createPostFormProvider.notifier).updateTitle(value);
          },
          decoration: InputDecoration(labelText: 'Title'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(createPostProvider.notifier).execute();
          },
          child: Text('Create Post'),
        ),
      ],
    );
  }
}
```

**변화**:
- ✅ `StatefulWidget` → `ConsumerWidget`
- ✅ `Provider.of` → `ref.watch()`
- ✅ `Consumer<T>` → `ref.watch(provider)`
- ✅ `provider.method()` → `ref.read(provider.notifier).method()`
- ✅ switch문 → `AsyncValue.when()`

### 6.6 Step 5 검증

#### 코드 생성 실행

```bash
# 1. Riverpod 코드 생성
dart run build_runner build --delete-conflicting-outputs

# 2. 생성된 파일 확인
ls lib/features/creation/presentation/providers/*.g.dart
# 출력:
# create_post_providers.g.dart
# media_upload_provider.g.dart
# target_audience_provider.g.dart
# ...
```

#### 컴파일 확인

```bash
# 1. 분석
flutter analyze

# 2. 빌드
flutter build apk --debug

# 예상 에러: GetIt 의존성 해결 필요 (DI 모듈 수정)
```

#### DI 모듈 수정

**파일**: `lib/app/di/di_module.dart`

```dart
// ❌ 기존: GetIt으로 Provider 등록
final getIt = GetIt.instance;

void setupDI() {
  // CreatePostProviderV2 등록
  getIt.registerFactory<CreatePostProviderV2>(() => CreatePostProviderV2(
        createPostUseCase: getIt(),
        validatePostUseCase: getIt(),
        moderateContentUseCase: getIt(),
      ));
}

// ✅ 변경: Riverpod으로 이동 (GetIt에서 Provider 제거)
void setupDI() {
  // ⚠️ Provider는 이제 Riverpod이 관리
  // GetIt에서는 Repository와 UseCase만 등록

  getIt.registerLazySingleton<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(...),
  );

  // ⚠️ 점진적으로 Repository도 Riverpod으로 이동 권장
}
```

#### 테스트 실행

```bash
# 1. Widget 테스트
flutter test test/features/creation/presentation/screens/create_post_screen_test.dart

# 2. Provider 테스트 (Riverpod)
flutter test test/features/creation/presentation/providers/create_post_providers_test.dart
```

#### 동작 확인

**수동 테스트 시나리오**:
1. **폼 입력**: Title, Description 입력 시 화면 업데이트 확인
2. **게시물 생성**: Create 버튼 클릭 → 로딩 → 성공/에러 확인
3. **미디어 업로드**: 이미지 선택 → 진행률 업데이트 확인
4. **에러 처리**: 잘못된 입력 → 에러 메시지 확인

#### Step 5 체크리스트

- [ ] CreatePostNotifier: @riverpod 전환
- [ ] MediaUploadNotifier: @riverpod 전환
- [ ] TargetAudienceNotifier: @riverpod 전환
- [ ] MediaSelectionNotifier: @riverpod 전환
- [ ] MediaValidationNotifier: @riverpod 전환
- [ ] MediaStateCoordinator: Provider 전환
- [ ] Widget: ConsumerWidget 전환
- [ ] DI 모듈: GetIt에서 Provider 제거
- [ ] build_runner 코드 생성 완료
- [ ] 컴파일 성공
- [ ] 테스트 통과
- [ ] 수동 테스트 완료

#### Git 커밋

```bash
git add lib/features/creation/presentation/
git commit -m "feat(creation): Step 5 - Riverpod 2.x 마이그레이션

- ChangeNotifier → @riverpod 전환 (6개 Provider)
- AsyncValue 자동 로딩/에러 상태 관리
- autoDispose 자동 메모리 관리
- ConsumerWidget 전환
- build_runner 코드 생성 설정
- GetIt 의존성 제거 (Provider만)

코드 감소: ~1,200줄 → ~700줄 (42% 감소)

Phase 2-2 Step 5/5 완료"
```

---

## 7. 마이그레이션 체크리스트 (v2.0.0 - Either + Riverpod)

### 7.1 Repository Interface (5개)

**IPostCreationRepositoryV2**:
- [ ] `Future<String>` → `Future<Either<CreationFailure, String>>`
- [ ] `Future<void>` → `Future<Either<CreationFailure, Unit>>`
- [ ] `Future<T?>` → `Future<Either<CreationFailure, Option<T>>>`
- [ ] `Stream<T>` → `Stream<Either<CreationFailure, T>>`
- [ ] Errors 문서화 추가

**IMediaRepository**:
- [ ] 모든 메서드 Either 반환
- [ ] Errors 문서화 추가

**IAIGenerationRepository**:
- [ ] 모든 메서드 Either 반환
- [ ] Errors 문서화 추가

### 7.2 Repository Implementation (8개)

**PostCreationRepositoryV2Impl**:
- [ ] `throw` → `return left()`
- [ ] 성공 값 → `return right()`
- [ ] `void` → `return right(unit)`
- [ ] `null` → `return right(none())` / `return right(some(value))`
- [ ] FirebaseException 에러 코드 매핑
- [ ] Stream 변환

**MediaRepositoryImpl**:
- [ ] 동일 패턴 적용
- [ ] FirebaseStorageException 처리

**AIGenerationRepositoryImpl**:
- [ ] 동일 패턴 적용
- [ ] HTTP 에러 코드 매핑

### 7.3 UseCase (6개)

**모든 UseCases (6개)**:
- [ ] `Result<T>` → `Either<CreationFailure, T>`
- [ ] `ResultSuccess/ResultFailure` → `right/left`
- [ ] `if (isFailure)` → `flatMap`
- [ ] Helper 메서드도 Either 반환
- [ ] Tuple 패턴 사용 (필요시)

**CreatePostUseCase** (특별 검증):
- [ ] 6단계 flatMap 체이닝
- [ ] onProgress 콜백 유지
- [ ] 에러 자동 전파 확인

### 7.4 Provider (6개)

**모든 Providers (6개)**:
- [ ] `isSuccess/isFailure` → `fold`
- [ ] `failureOrNull/valueOrNull` 제거
- [ ] try-catch 제거 (선택)
- [ ] ChangeNotifier → Riverpod 2.x (Step 5에서 진행)

### 7.5 Riverpod 2.x Migration (6개) ← v2.0.0 NEW!

**Dependencies**:
- [ ] pubspec.yaml에 Riverpod 패키지 추가
- [ ] build.yaml 설정 추가
- [ ] build_runner 코드 생성 준비

**CreatePostNotifier**:
- [ ] @riverpod annotation 추가
- [ ] part directive 추가 (create_post_providers.g.dart)
- [ ] CreatePostForm: PostFormData 상태 관리
- [ ] CreatePost: AsyncValue<PostCreation?> 비동기 작업
- [ ] UseCase Providers: DI 설정 (@riverpod)
- [ ] ChangeNotifier 제거

**MediaUploadNotifier**:
- [ ] StreamProvider로 진행률 관리
- [ ] MediaUploadProgress: Stream<double> 상태
- [ ] UploadImages: AsyncValue<List<String>?> 업로드
- [ ] onProgress 콜백을 progressNotifier로 전달
- [ ] ChangeNotifier 제거

**TargetAudienceNotifier**:
- [ ] @riverpod class TargetAudienceForm
- [ ] TargetAudience 상태 관리
- [ ] ChangeNotifier 제거

**MediaSelectionNotifier**:
- [ ] @riverpod class MediaSelection
- [ ] List<File> 상태 관리 (imagesA, imagesB)
- [ ] ChangeNotifier 제거

**MediaValidationNotifier**:
- [ ] @riverpod class MediaValidation
- [ ] ValidationResult 상태 관리
- [ ] ChangeNotifier 제거

**MediaStateCoordinator**:
- [ ] Plain @riverpod provider로 전환
- [ ] 다른 Provider들 조합 (ref.watch)
- [ ] ChangeNotifier 제거

**Widget Conversion**:
- [ ] StatefulWidget → ConsumerWidget
- [ ] Provider.of<T>(context) → ref.watch(provider)
- [ ] Consumer<T> → ref.watch(provider)
- [ ] AsyncValue.when() 패턴 적용
- [ ] loading/error/data 상태 자동 처리

**Build & Verification**:
- [ ] `dart run build_runner build --delete-conflicting-outputs`
- [ ] .g.dart 파일 생성 확인 (6개)
- [ ] GetIt DI에서 Provider 제거 시작
- [ ] `flutter analyze` 통과
- [ ] `flutter test` Riverpod 테스트 통과

### 7.6 전체 검증

**컴파일**:
- [ ] `flutter analyze` 에러 없음
- [ ] `flutter build` 성공

**테스트**:
- [ ] Repository 단위 테스트 통과
- [ ] UseCase 단위 테스트 통과
- [ ] Provider 단위 테스트 통과

**Git**:
- [ ] 5개 커밋 생성 (Step 1-5) ← v2.0.0 변경!
- [ ] 브랜치 이름: `feature/phase2-either-riverpod`

---

## 8. 트러블슈팅 (v2.0.0)

### 8.1 컴파일 에러: "The return type 'Either<L, R>' isn't a 'Result<T>'"

**원인**: Repository 인터페이스는 변경했지만 구현체는 아직 변경 안 함

**해결**:
```bash
# Step 순서 확인
# 1. Repository Interface (Step 1)
# 2. Repository Implementation (Step 2) ← 이 순서 지키기
# 3. UseCase (Step 3)
# 4. Provider (Step 4)
# 5. Riverpod (Step 5)
```

### 8.2 Runtime 에러: "type 'Unit' is not a subtype of type 'void'"

**원인**: void 반환 메서드를 Unit으로 변경했지만 호출 부분 수정 안 함

**해결**:
```dart
// ❌ Before
await repository.updatePost(...);

// ✅ After
final result = await repository.updatePost(...);
result.fold(
  (failure) => /* 에러 처리 */,
  (unit) => /* 성공 처리 (unit 무시) */,
);
```

### 8.3 에러: "The argument type 'Either<L, R> Function()' can't be assigned"

**원인**: async 함수를 flatMap에 전달할 때 await 누락

**해결**:
```dart
// ❌ Wrong
return _validateInputs()
  .flatMap(() => _processImages());  // ⚠️ Future 반환

// ✅ Correct
return _validateInputs()
  .flatMap((_) async => await _processImages());  // ✅ async/await
```

### 8.4 테스트 에러: "Bad state: Cannot use mock after verification"

**원인**: Mockito의 when() 순서 문제

**해결**:
```dart
// ❌ Wrong
when(mockRepository.createPost(post: any))
    .thenAnswer((_) async => right('post123'));
verify(mockRepository.createPost(post: any));  // ⚠️ verify 후 when 불가

// ✅ Correct
when(mockRepository.createPost(post: any))
    .thenAnswer((_) async => right('post123'));
// ... test code ...
verify(mockRepository.createPost(post: any));  // ✅ verify는 마지막
```

### 8.5 에러: "Option<T> requires type argument"

**원인**: some/none 사용 시 타입 명시 필요

**해결**:
```dart
// ❌ Wrong
return right(none());  // ⚠️ 타입 추론 실패

// ✅ Correct
return right(none<PostCreation>());  // ✅ 타입 명시
// 또는
return right(Option<PostCreation>.none());
```

### 8.6 Riverpod 에러: "Provider was disposed" ← v2.0.0 NEW!

**원인**: autoDispose Provider를 dispose 후 접근

**해결**:
```dart
// ❌ Wrong
@riverpod
class CreatePost extends _$CreatePost {
  @override
  FutureOr<PostCreation?> build() => null;

  Future<void> execute() async {
    // Widget이 dispose되면 Provider도 dispose됨
    await Future.delayed(Duration(seconds: 5));  // ⚠️ 오래 걸리는 작업
    state = AsyncData(result);  // ❌ Provider was disposed 에러
  }
}

// ✅ Correct: keepAlive 사용
@Riverpod(keepAlive: true)  // ✅ autoDispose 비활성화
class CreatePost extends _$CreatePost {
  @override
  FutureOr<PostCreation?> build() => null;

  Future<void> execute() async {
    await Future.delayed(Duration(seconds: 5));
    state = AsyncData(result);  // ✅ 정상 동작
  }
}
```

### 8.7 Riverpod 에러: "Could not find a provider" ← v2.0.0 NEW!

**원인**: ProviderScope 없이 Provider 사용

**해결**:
```dart
// ❌ Wrong
void main() {
  runApp(MyApp());  // ⚠️ ProviderScope 없음
}

// ✅ Correct
void main() {
  runApp(
    ProviderScope(  // ✅ ProviderScope로 감싸기
      child: MyApp(),
    ),
  );
}
```

### 8.8 Build Runner 에러: "Conflicting outputs" ← v2.0.0 NEW!

**원인**: .g.dart 파일이 이미 존재하는데 재생성 시도

**해결**:
```bash
# 기존 .g.dart 파일 삭제 후 재생성
dart run build_runner build --delete-conflicting-outputs

# 또는 clean 후 재생성
dart run build_runner clean
dart run build_runner build
```

---

## 9. 다음 단계 안내 (v2.0.0)

**Phase 2-2 완료** ✅

본 문서에서 다룬 내용:
- ✅ Step 1: Repository Interface 마이그레이션 (5개 파일)
- ✅ Step 2: Repository Implementation 마이그레이션 (8개 파일)
- ✅ Step 3: UseCase 마이그레이션 (6개 파일)
- ✅ Step 4: Provider Either fold 적용 (6개 파일)
- ✅ Step 5: Riverpod 2.x 마이그레이션 (6개 파일) ← v2.0.0 NEW!
- ✅ 마이그레이션 체크리스트 (v2.0.0)
- ✅ 트러블슈팅 가이드 (Riverpod 포함)

**다음 단계: Phase 2-3**

[Phase 2-3: Testing & Validation](./PHASE_2_3_TESTING_AND_VALIDATION.md) 문서에서 다음을 다룹니다:

1. **단위 테스트 작성**
   - Repository 테스트 (Either Mocking)
   - UseCase 테스트 (flatMap 검증)
   - Provider 테스트 (fold 검증)
   - Riverpod Provider 테스트 (AsyncValue, ref.watch 검증) ← v2.0.0 NEW!

2. **통합 테스트 작성**
   - 전체 플로우 테스트
   - 에러 시나리오 테스트
   - Edge Case 테스트
   - Riverpod 상태 관리 통합 테스트 ← v2.0.0 NEW!

3. **Rollback 절차**
   - Git 기반 롤백
   - 5-Step 복원 방법 (Step 5 포함) ← v2.0.0 변경!
   - 데이터 마이그레이션 롤백

4. **최종 검증 체크리스트**
   - 코드 품질 검증
   - 성능 검증
   - 문서화 검증
   - Riverpod 마이그레이션 검증 ← v2.0.0 NEW!

---

**문서 끝** - Phase 2-2 완료

**다음**: [Phase 2-3: Testing & Validation](./PHASE_2_3_TESTING_AND_VALIDATION.md)
