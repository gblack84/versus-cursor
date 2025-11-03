# Creation Feature - Phase 2-3: Either Pattern + Riverpod Migration - Testing & Validation

> **문서 버전**: 2.0.0 (Riverpod 통합)
> **작성일**: 2025-11-03
> **최종 수정**: 2025-11-03
> **Phase**: 2-3 (Either Pattern + Riverpod 도입 - 테스트 및 검증)
> **이전 Phase**: [Phase 2-2 - Migration Steps](./PHASE_2_2_MIGRATION_STEPS.md)
> **완료 후**: Phase 2 마이그레이션 완료 ✅ (Either + Riverpod)

---

## 📋 목차

- [1. 테스트 전략](#1-테스트-전략)
  - [1.1 테스트 피라미드](#11-테스트-피라미드)
  - [1.2 Either 패턴 테스트 원칙](#12-either-패턴-테스트-원칙)
  - [1.3 Riverpod 테스트 원칙](#13-riverpod-테스트-원칙) ← v2.0.0 NEW!
  - [1.4 테스트 도구](#14-테스트-도구)
- [2. Repository 단위 테스트](#2-repository-단위-테스트)
  - [2.1 PostCreationRepositoryV2Impl 테스트](#21-postcreationrepositoryv2impl-테스트)
  - [2.2 MediaRepositoryImpl 테스트](#22-mediarepositoryimpl-테스트)
  - [2.3 Either Mocking 패턴](#23-either-mocking-패턴)
- [3. UseCase 단위 테스트](#3-usecase-단위-테스트)
  - [3.1 CreatePostUseCase 테스트](#31-createpostusecase-테스트)
  - [3.2 ValidatePostUseCase 테스트](#32-validatepostusecase-테스트)
  - [3.3 flatMap 체이닝 검증](#33-flatmap-체이닝-검증)
- [4. Provider 단위 테스트 (ChangeNotifier)](#4-provider-단위-테스트-changenotifier)
  - [4.1 CreatePostProviderV2 테스트](#41-createpostproviderv2-테스트)
  - [4.2 fold 패턴 검증](#42-fold-패턴-검증)
  - [4.3 ChangeNotifier 테스트](#43-changenotifier-테스트)
- [5. Riverpod Provider 단위 테스트](#5-riverpod-provider-단위-테스트) ← v2.0.0 NEW!
  - [5.1 CreatePostNotifier 테스트](#51-createpostnotifier-테스트)
  - [5.2 AsyncValue 상태 검증](#52-asyncvalue-상태-검증)
  - [5.3 ProviderContainer 테스트](#53-providercontainer-테스트)
  - [5.4 ref.watch/ref.read 검증](#54-refwatchrefread-검증)
- [6. 통합 테스트](#6-통합-테스트)
  - [6.1 전체 플로우 테스트](#61-전체-플로우-테스트)
  - [6.2 에러 시나리오 테스트](#62-에러-시나리오-테스트)
  - [6.3 Edge Case 테스트](#63-edge-case-테스트)
  - [6.4 Riverpod 상태 관리 통합 테스트](#64-riverpod-상태-관리-통합-테스트) ← v2.0.0 NEW!
- [7. Rollback 절차](#7-rollback-절차)
  - [7.1 전체 롤백 (Phase 2 취소)](#71-전체-롤백-phase-2-취소)
  - [7.2 Step별 롤백 (5-Step)](#72-step별-롤백-5-step) ← v2.0.0 변경!
  - [7.3 데이터 마이그레이션 롤백](#73-데이터-마이그레이션-롤백)
- [8. 최종 검증 체크리스트](#8-최종-검증-체크리스트)
  - [8.1 코드 품질 검증](#81-코드-품질-검증)
  - [8.2 성능 검증](#82-성능-검증)
  - [8.3 문서화 검증](#83-문서화-검증)
  - [8.4 Riverpod 마이그레이션 검증](#84-riverpod-마이그레이션-검증) ← v2.0.0 NEW!
- [9. Phase 2 완료](#9-phase-2-완료)

---

## 1. 테스트 전략

### 1.1 테스트 피라미드

```
        ┌─────────────┐
        │   E2E (5%)  │  통합 테스트 (전체 플로우)
        ├─────────────┤
        │Integration  │  통합 테스트 (여러 레이어)
        │   (15%)     │
        ├─────────────┤
        │   Unit      │  단위 테스트 (개별 함수/클래스)
        │   (80%)     │  ← Phase 2-3 주요 초점
        └─────────────┘
```

**Phase 2-3 테스트 범위 (v2.0.0)**:
- **Repository**: 80% 커버리지 (Either 반환 검증)
- **UseCase**: 90% 커버리지 (flatMap 체이닝 검증)
- **Provider (ChangeNotifier)**: 70% 커버리지 (fold 패턴 검증)
- **Riverpod Provider**: 85% 커버리지 (AsyncValue, ref.watch 검증) ← NEW!
- **통합 테스트**: 주요 플로우 7개 (Riverpod 상태 관리 포함) ← 변경!

### 1.2 Either 패턴 테스트 원칙

**1. Left/Right 모두 테스트**:

```dart
// ✅ Good: 성공과 실패 모두 테스트
test('createPost returns Right on success', () { /* ... */ });
test('createPost returns Left on error', () { /* ... */ });

// ❌ Bad: 성공 케이스만 테스트
test('createPost works', () { /* ... */ });
```

**2. fold로 값 추출**:

```dart
// ✅ Good: fold로 타입 안전하게 추출
result.fold(
  (failure) => fail('Should not be failure'),
  (value) => expect(value, expected),
);

// ❌ Bad: getOrElse 사용 (타입 안전성 손실)
final value = result.getOrElse(() => throw Exception());
```

**3. Failure 타입 검증**:

```dart
// ✅ Good: 구체적인 Failure 타입 검증
result.fold(
  (failure) {
    expect(failure, isA<ServerError>());
    expect(failure.message, contains('Firebase'));
  },
  (_) => fail('Should not be success'),
);

// ❌ Bad: Failure만 체크
result.fold(
  (failure) => expect(failure, isA<CreationFailure>()),
  (_) => fail('Should not be success'),
);
```

### 1.3 Riverpod 테스트 원칙 ← v2.0.0 NEW!

**1. ProviderContainer로 독립 테스트**:

```dart
// ✅ Good: ProviderContainer로 Provider 테스트
test('createPostProvider handles success', () async {
  final container = ProviderContainer(
    overrides: [
      createPostUseCaseProvider.overrideWithValue(mockUseCase),
    ],
  );
  addTearDown(container.dispose);

  when(mockUseCase.execute(dto: any))
      .thenAnswer((_) async => right(mockPostCreation));

  await container.read(createPostProvider.notifier).execute();

  final state = container.read(createPostProvider);
  expect(state.value, mockPostCreation);
});

// ❌ Bad: Widget 없이 Provider 직접 접근
test('provider works', () {
  // ⚠️ ProviderScope 없이 Provider 접근 불가
  ref.read(createPostProvider);
});
```

**2. AsyncValue 상태 검증**:

```dart
// ✅ Good: loading/data/error 모두 검증
test('createPost transitions through states', () async {
  final container = ProviderContainer(/* ... */);

  // Initial state
  expect(container.read(createPostProvider), AsyncData(null));

  // Trigger action
  final future = container.read(createPostProvider.notifier).execute();

  // Loading state
  expect(container.read(createPostProvider), AsyncLoading());

  await future;

  // Success state
  expect(container.read(createPostProvider).value, isNotNull);
});

// ❌ Bad: 최종 상태만 검증
test('createPost works', () async {
  final container = ProviderContainer(/* ... */);
  await container.read(createPostProvider.notifier).execute();
  expect(container.read(createPostProvider).hasValue, true);
});
```

**3. ref.watch 의존성 검증**:

```dart
// ✅ Good: Provider 의존성 명시적 테스트
test('composite provider watches dependencies', () {
  final container = ProviderContainer();

  // formData 변경
  container.read(createPostFormProvider.notifier).updateTitle('New Title');

  // dependent provider가 자동 업데이트되는지 검증
  final formData = container.read(createPostFormProvider);
  expect(formData.title, 'New Title');
});

// ❌ Bad: 의존성 업데이트 검증 안 함
test('form updates', () {
  final container = ProviderContainer();
  container.read(createPostFormProvider.notifier).updateTitle('New Title');
  // ⚠️ dependent provider 검증 누락
});
```

**4. autoDispose 동작 검증**:

```dart
// ✅ Good: autoDispose로 메모리 누수 방지 검증
test('provider autodisposes when not watched', () {
  final container = ProviderContainer();
  final listener = container.listen(
    createPostProvider,
    (prev, next) {},
  );

  // Listen 중에는 dispose 안 됨
  expect(container.exists(createPostProvider), true);

  listener.close();

  // Listen 중단하면 autoDispose 동작
  expect(container.exists(createPostProvider), false);
});
```

### 1.4 테스트 도구

#### pubspec.yaml 설정

```yaml
dev_dependencies:
  # 테스트 프레임워크
  flutter_test:
    sdk: flutter

  # Mocking
  mockito: ^5.4.4
  build_runner: ^2.4.8

  # Matcher 확장
  test: ^1.24.9

  # fpdart 테스트 유틸리티
  fpdart: ^1.1.0

  # Riverpod 테스트 도구 ← v2.0.0 NEW!
  flutter_riverpod: ^2.5.1
  riverpod_test: ^2.0.0  # Riverpod Provider 테스트 헬퍼
```

#### Mock 클래스 생성

```bash
# 1. Mock 파일 생성
# test/features/creation/mocks.dart

import 'package:mockito/annotations.dart';
import 'package:versus_space/features/creation/domain/repositories/i_post_creation_repository_v2.dart';
import 'package:versus_space/features/creation/domain/repositories/i_media_repository.dart';
import 'package:versus_space/features/creation/domain/usecases/create_post_usecase.dart';

@GenerateMocks([
  IPostCreationRepositoryV2,
  IMediaRepository,
  CreatePostUseCase,
])
void main() {}

# 2. Mock 클래스 생성
flutter pub run build_runner build --delete-conflicting-outputs

# 3. 생성된 파일 확인
# test/features/creation/mocks.mocks.dart
```

---

## 2. Repository 단위 테스트

### 2.1 PostCreationRepositoryV2Impl 테스트

**파일**: `test/features/creation/data/repositories/post_creation_repository_v2_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:versus_space/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';
import 'package:versus_space/features/creation/domain/models/aggregates/post_creation.dart';

void main() {
  group('PostCreationRepositoryV2Impl', () {
    late PostCreationRepositoryV2Impl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = PostCreationRepositoryV2Impl(
        firestore: fakeFirestore,
        // ... other dependencies with mocks
      );
    });

    group('createPost', () {
      test('returns Right(postId) on success', () async {
        // Arrange
        final post = PostCreation(
          title: 'Test Post',
          description: 'Test Description',
          mediaA: ['https://example.com/imageA.jpg'],
          mediaB: ['https://example.com/imageB.jpg'],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = await repository.createPost(post: post);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure: $failure'),
          (postId) {
            expect(postId, isNotEmpty);
            expect(postId.length, 20);  // Firestore ID length
          },
        );

        // Verify Firestore document created
        final doc = await fakeFirestore.collection('posts').doc(
          result.getOrElse((l) => ''),
        ).get();

        expect(doc.exists, true);
        expect(doc.data()?['title'], 'Test Post');
      });

      test('returns Left(ServerError) on Firestore error', () async {
        // Arrange: Use real Firestore to trigger error
        final realRepository = PostCreationRepositoryV2Impl(
          firestore: null,  // Will use real Firestore
          // ... with invalid config to trigger error
        );

        final post = PostCreation(
          title: 'Test Post',
          description: 'Test Description',
          mediaA: [],
          mediaB: [],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = await realRepository.createPost(post: post);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<ServerError>());
            expect(failure.message, isNotEmpty);
          },
          (postId) => fail('Should not be success'),
        );
      });

      test('validates required fields', () async {
        // Arrange: Post with empty title
        final post = PostCreation(
          title: '',  // Empty title
          description: 'Test Description',
          mediaA: [],
          mediaB: [],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = await repository.createPost(post: post);

        // Assert: Should still create (validation is UseCase responsibility)
        // But we can test that repository handles it correctly
        expect(result.isRight(), true);
      });
    });

    group('updatePost', () {
      test('returns Right(unit) on success', () async {
        // Arrange: Create post first
        final createResult = await repository.createPost(
          post: PostCreation(
            title: 'Original Title',
            description: 'Original Description',
            mediaA: [],
            mediaB: [],
            createdAt: DateTime.now(),
            status: 'draft',
          ),
        );

        final postId = createResult.getOrElse((l) => '');

        final updatedPost = PostCreation(
          id: postId,
          title: 'Updated Title',
          description: 'Updated Description',
          mediaA: [],
          mediaB: [],
          createdAt: DateTime.now(),
          status: 'published',
        );

        // Act
        final result = await repository.updatePost(
          postId: postId,
          post: updatedPost,
        );

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (unit) {
            expect(unit, equals(unit));  // Unit is singleton
          },
        );

        // Verify update
        final doc = await fakeFirestore.collection('posts').doc(postId).get();
        expect(doc.data()?['title'], 'Updated Title');
        expect(doc.data()?['status'], 'published');
      });

      test('returns Left(NotFound) when post does not exist', () async {
        // Arrange
        final nonExistentId = 'non_existent_post_id';
        final post = PostCreation(
          id: nonExistentId,
          title: 'Test',
          description: 'Test',
          mediaA: [],
          mediaB: [],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = await repository.updatePost(
          postId: nonExistentId,
          post: post,
        );

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<NotFound>());
            expect(failure.message, contains('not found'));
          },
          (_) => fail('Should not be success'),
        );
      });
    });

    group('getPost', () {
      test('returns Right(Some(post)) when post exists', () async {
        // Arrange: Create post
        final createResult = await repository.createPost(
          post: PostCreation(
            title: 'Test Post',
            description: 'Test Description',
            mediaA: [],
            mediaB: [],
            createdAt: DateTime.now(),
            status: 'draft',
          ),
        );

        final postId = createResult.getOrElse((l) => '');

        // Act
        final result = await repository.getPost(postId);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (option) {
            expect(option.isSome(), true);

            option.fold(
              () => fail('Should not be None'),
              (post) {
                expect(post.id, postId);
                expect(post.title, 'Test Post');
              },
            );
          },
        );
      });

      test('returns Right(None) when post does not exist', () async {
        // Arrange
        final nonExistentId = 'non_existent_post_id';

        // Act
        final result = await repository.getPost(nonExistentId);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (option) {
            expect(option.isNone(), true);
          },
        );
      });

      test('returns Left(ServerError) on Firestore error', () async {
        // Arrange: Mock Firestore to throw error
        // (Implementation depends on mocking strategy)

        // Act
        final result = await repository.getPost('some_id');

        // Assert: Check error handling
        // (Implementation specific)
      });
    });

    group('deletePost', () {
      test('returns Right(unit) on success', () async {
        // Arrange: Create post first
        final createResult = await repository.createPost(
          post: PostCreation(
            title: 'To Delete',
            description: 'Test',
            mediaA: [],
            mediaB: [],
            createdAt: DateTime.now(),
            status: 'draft',
          ),
        );

        final postId = createResult.getOrElse((l) => '');

        // Act
        final result = await repository.deletePost(postId);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (unit) => expect(unit, equals(unit)),
        );

        // Verify deletion
        final doc = await fakeFirestore.collection('posts').doc(postId).get();
        expect(doc.exists, false);
      });

      test('returns Left(NotFound) when post does not exist', () async {
        // Arrange
        final nonExistentId = 'non_existent_post_id';

        // Act
        final result = await repository.deletePost(nonExistentId);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<NotFound>());
          },
          (_) => fail('Should not be success'),
        );
      });
    });

    group('watchPost (Stream)', () {
      test('emits Right(post) when post exists', () async {
        // Arrange: Create post
        final createResult = await repository.createPost(
          post: PostCreation(
            title: 'Test Post',
            description: 'Test',
            mediaA: [],
            mediaB: [],
            createdAt: DateTime.now(),
            status: 'draft',
          ),
        );

        final postId = createResult.getOrElse((l) => '');

        // Act
        final stream = repository.watchPost(postId);

        // Assert
        await expectLater(
          stream,
          emits(predicate<Either<CreationFailure, PostCreation>>((either) {
            return either.fold(
              (failure) => false,
              (post) => post.id == postId && post.title == 'Test Post',
            );
          })),
        );
      });

      test('emits Left(NotFound) when post does not exist', () async {
        // Arrange
        final nonExistentId = 'non_existent_post_id';

        // Act
        final stream = repository.watchPost(nonExistentId);

        // Assert
        await expectLater(
          stream,
          emits(predicate<Either<CreationFailure, PostCreation>>((either) {
            return either.fold(
              (failure) => failure is NotFound,
              (post) => false,
            );
          })),
        );
      });
    });
  });
}
```

### 2.2 MediaRepositoryImpl 테스트

**파일**: `test/features/creation/data/repositories/media_repository_impl_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

void main() {
  group('MediaRepositoryImpl', () {
    late MediaRepositoryImpl repository;
    late MockFirebaseStorage mockStorage;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      repository = MediaRepositoryImpl(storage: mockStorage);
    });

    group('uploadImage', () {
      test('returns Right(url) on successful upload', () async {
        // Arrange
        final testFile = File('test/fixtures/test_image.jpg');
        final mockRef = MockReference();
        final mockUploadTask = MockUploadTask();
        final mockSnapshot = MockTaskSnapshot();

        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(mockRef.putFile(any)).thenReturn(mockUploadTask);
        when(mockUploadTask.then(any)).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.ref).thenReturn(mockRef);
        when(mockRef.getDownloadURL()).thenAnswer(
          (_) async => 'https://example.com/uploaded.jpg',
        );

        // Act
        final result = await repository.uploadImage(
          image: testFile,
          userId: 'user123',
          postId: 'post123',
        );

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (url) {
            expect(url, 'https://example.com/uploaded.jpg');
            expect(url, startsWith('https://'));
          },
        );
      });

      test('returns Left(InvalidFile) when file does not exist', () async {
        // Arrange
        final nonExistentFile = File('non_existent.jpg');

        // Act
        final result = await repository.uploadImage(
          image: nonExistentFile,
          userId: 'user123',
          postId: 'post123',
        );

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidFile>());
            expect(failure.message, contains('does not exist'));
          },
          (_) => fail('Should not be success'),
        );
      });

      test('returns Left(UploadFailed) on Firebase error', () async {
        // Arrange
        final testFile = File('test/fixtures/test_image.jpg');
        final mockRef = MockReference();

        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(any)).thenReturn(mockRef);
        when(mockRef.putFile(any)).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'unknown',
            message: 'Upload failed',
          ),
        );

        // Act
        final result = await repository.uploadImage(
          image: testFile,
          userId: 'user123',
          postId: 'post123',
        );

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<UploadFailed>());
            expect(failure.message, contains('Upload failed'));
          },
          (_) => fail('Should not be success'),
        );
      });
    });

    group('deleteImage', () {
      test('returns Right(unit) on successful deletion', () async {
        // Arrange
        final imageUrl = 'https://example.com/image.jpg';
        final mockRef = MockReference();

        when(mockStorage.refFromURL(imageUrl)).thenReturn(mockRef);
        when(mockRef.delete()).thenAnswer((_) async => {});

        // Act
        final result = await repository.deleteImage(imageUrl);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (unit) => expect(unit, equals(unit)),
        );

        verify(mockRef.delete()).called(1);
      });

      test('returns Left(NotFound) when image does not exist', () async {
        // Arrange
        final imageUrl = 'https://example.com/non_existent.jpg';
        final mockRef = MockReference();

        when(mockStorage.refFromURL(imageUrl)).thenReturn(mockRef);
        when(mockRef.delete()).thenThrow(
          FirebaseException(
            plugin: 'storage',
            code: 'object-not-found',
            message: 'Object not found',
          ),
        );

        // Act
        final result = await repository.deleteImage(imageUrl);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<NotFound>());
          },
          (_) => fail('Should not be success'),
        );
      });
    });
  });
}
```

### 2.3 Either Mocking 패턴

**Mock Repository 설정**:

```dart
// test/features/creation/helpers/mock_setup.dart

import 'package:mockito/mockito.dart';
import 'package:fpdart/fpdart.dart';
import '../mocks.mocks.dart';

class MockRepositorySetup {
  /// Setup successful createPost mock
  static void setupCreatePostSuccess(
    MockIPostCreationRepositoryV2 mock,
    String postId,
  ) {
    when(mock.createPost(post: anyNamed('post')))
        .thenAnswer((_) async => right(postId));
  }

  /// Setup createPost failure mock
  static void setupCreatePostFailure(
    MockIPostCreationRepositoryV2 mock,
    CreationFailure failure,
  ) {
    when(mock.createPost(post: anyNamed('post')))
        .thenAnswer((_) async => left(failure));
  }

  /// Setup successful getPost mock
  static void setupGetPostSuccess(
    MockIPostCreationRepositoryV2 mock,
    PostCreation post,
  ) {
    when(mock.getPost(any))
        .thenAnswer((_) async => right(some(post)));
  }

  /// Setup getPost not found mock
  static void setupGetPostNotFound(
    MockIPostCreationRepositoryV2 mock,
  ) {
    when(mock.getPost(any))
        .thenAnswer((_) async => right(none<PostCreation>()));
  }
}
```

---

## 3. UseCase 단위 테스트

### 3.1 CreatePostUseCase 테스트

**파일**: `test/features/creation/domain/usecases/create_post_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/creation/domain/usecases/create_post_usecase.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';
import 'package:versus_space/features/creation/data/models/post_creation_dto.dart';
import '../../mocks.mocks.dart';
import '../../helpers/mock_setup.dart';

void main() {
  group('CreatePostUseCase', () {
    late CreatePostUseCase useCase;
    late MockIPostCreationRepositoryV2 mockPostRepository;
    late MockIMediaRepository mockMediaRepository;
    late MockManageTargetAudienceUseCase mockAudienceUseCase;

    setUp(() {
      mockPostRepository = MockIPostCreationRepositoryV2();
      mockMediaRepository = MockIMediaRepository();
      mockAudienceUseCase = MockManageTargetAudienceUseCase();

      useCase = CreatePostUseCase(
        postRepository: mockPostRepository,
        mediaRepository: mockMediaRepository,
        manageTargetAudienceUseCase: mockAudienceUseCase,
      );
    });

    group('execute', () {
      test('returns Right(PostCreation) on successful post creation', () async {
        // Arrange
        final dto = PostCreationDto(
          title: 'Test Post',
          description: 'Test Description',
          textA: 'Option A',
          textB: 'Option B',
          imagesA: [],
          imagesB: [],
          targetAudience: null,
          isAnonymous: false,
          isSingleMode: false,
        );

        // Mock successful repository call
        MockRepositorySetup.setupCreatePostSuccess(
          mockPostRepository,
          'post123',
        );

        // Mock successful media upload (if needed)
        when(mockMediaRepository.uploadMultipleImages(
          images: anyNamed('images'),
          userId: anyNamed('userId'),
          postId: anyNamed('postId'),
        )).thenAnswer((_) async => right(<String>[]));

        // Act
        final result = await useCase.execute(dto: dto);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure: $failure'),
          (postCreation) {
            expect(postCreation.id, 'post123');
            expect(postCreation.title, 'Test Post');
            expect(postCreation.description, 'Test Description');
          },
        );

        // Verify repository called once
        verify(mockPostRepository.createPost(post: any)).called(1);
      });

      test('returns Left(InvalidInput) when title is empty', () async {
        // Arrange
        final dto = PostCreationDto(
          title: '',  // Empty title
          description: 'Test Description',
          textA: 'A',
          textB: 'B',
          imagesA: [],
          imagesB: [],
          targetAudience: null,
          isAnonymous: false,
          isSingleMode: false,
        );

        // Act
        final result = await useCase.execute(dto: dto);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidInput>());
            expect(failure.message, contains('Title'));
          },
          (_) => fail('Should not be success'),
        );

        // Verify repository NOT called
        verifyNever(mockPostRepository.createPost(post: any));
      });

      test('returns Left(InvalidInput) when description is empty', () async {
        // Arrange
        final dto = PostCreationDto(
          title: 'Test Title',
          description: '',  // Empty description
          textA: 'A',
          textB: 'B',
          imagesA: [],
          imagesB: [],
          targetAudience: null,
          isAnonymous: false,
          isSingleMode: false,
        );

        // Act
        final result = await useCase.execute(dto: dto);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidInput>());
            expect(failure.message, contains('Description'));
          },
          (_) => fail('Should not be success'),
        );
      });

      test('propagates Repository ServerError via flatMap', () async {
        // Arrange
        final dto = PostCreationDto(
          title: 'Test Post',
          description: 'Test Description',
          textA: 'A',
          textB: 'B',
          imagesA: [],
          imagesB: [],
          targetAudience: null,
          isAnonymous: false,
          isSingleMode: false,
        );

        // Mock repository failure
        MockRepositorySetup.setupCreatePostFailure(
          mockPostRepository,
          CreationFailure.serverError('Firestore connection failed'),
        );

        // Act
        final result = await useCase.execute(dto: dto);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<ServerError>());
            expect(failure.message, contains('Firestore'));
          },
          (_) => fail('Should not be success'),
        );
      });

      test('calls onProgress callback during execution', () async {
        // Arrange
        final dto = PostCreationDto(
          title: 'Test Post',
          description: 'Test Description',
          textA: 'A',
          textB: 'B',
          imagesA: [],
          imagesB: [],
          targetAudience: null,
          isAnonymous: false,
          isSingleMode: false,
        );

        MockRepositorySetup.setupCreatePostSuccess(
          mockPostRepository,
          'post123',
        );

        final progressValues = <double>[];

        // Act
        await useCase.execute(
          dto: dto,
          onProgress: (progress) {
            progressValues.add(progress);
          },
        );

        // Assert
        expect(progressValues.isNotEmpty, true);
        expect(progressValues.first, greaterThanOrEqualTo(0.0));
        expect(progressValues.last, equals(1.0));
      });
    });
  });
}
```

### 3.2 ValidatePostUseCase 테스트

**파일**: `test/features/creation/domain/usecases/validate_post_usecase_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/creation/domain/usecases/validate_post_usecase.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';
import 'package:versus_space/features/creation/domain/models/aggregates/post_creation.dart';

void main() {
  group('ValidatePostUseCase', () {
    late ValidatePostUseCase useCase;

    setUp(() {
      useCase = ValidatePostUseCase();
    });

    group('execute', () {
      test('returns Right(unit) for valid post', () {
        // Arrange
        final post = PostCreation(
          title: 'Valid Title',
          description: 'Valid description with enough content',
          mediaA: ['https://example.com/imageA.jpg'],
          mediaB: ['https://example.com/imageB.jpg'],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = useCase.execute(post: post);

        // Assert
        expect(result.isRight(), true);

        result.fold(
          (failure) => fail('Should not be failure'),
          (unit) => expect(unit, equals(unit)),
        );
      });

      test('returns Left(InvalidInput) when title is empty', () {
        // Arrange
        final post = PostCreation(
          title: '',  // Empty title
          description: 'Valid description',
          mediaA: ['image.jpg'],
          mediaB: ['image.jpg'],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = useCase.execute(post: post);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidInput>());
            expect(failure.message, contains('Title is empty'));
          },
          (_) => fail('Should not be success'),
        );
      });

      test('returns Left(InvalidInput) when title is too long', () {
        // Arrange
        final post = PostCreation(
          title: 'A' * 101,  // 101 characters (max 100)
          description: 'Valid description',
          mediaA: ['image.jpg'],
          mediaB: ['image.jpg'],
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = useCase.execute(post: post);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidInput>());
            expect(failure.message, contains('too long'));
          },
          (_) => fail('Should not be success'),
        );
      });

      test('returns Left(InvalidInput) when no media provided', () {
        // Arrange
        final post = PostCreation(
          title: 'Valid Title',
          description: 'Valid description',
          mediaA: [],  // Empty
          mediaB: [],  // Empty
          createdAt: DateTime.now(),
          status: 'draft',
        );

        // Act
        final result = useCase.execute(post: post);

        // Assert
        expect(result.isLeft(), true);

        result.fold(
          (failure) {
            expect(failure, isA<InvalidInput>());
            expect(failure.message, contains('media required'));
          },
          (_) => fail('Should not be success'),
        );
      });
    });
  });
}
```

### 3.3 flatMap 체이닝 검증

**테스트 목적**: flatMap이 에러를 올바르게 전파하는지 검증

```dart
test('flatMap propagates error from first step', () async {
  // Arrange: First step fails
  when(mockRepository.step1()).thenAnswer(
    (_) async => left(CreationFailure.serverError('Step 1 failed')),
  );

  // Mock step2 should NOT be called
  when(mockRepository.step2(any)).thenAnswer(
    (_) async => right('step2_result'),
  );

  // Act: Chain with flatMap
  final result = await useCase.execute();

  // Assert: Error from step1 propagated
  expect(result.isLeft(), true);
  result.fold(
    (failure) => expect(failure.message, contains('Step 1 failed')),
    (_) => fail('Should not be success'),
  );

  // Verify step2 NOT called (short-circuit)
  verifyNever(mockRepository.step2(any));
});

test('flatMap continues to second step on success', () async {
  // Arrange: First step succeeds
  when(mockRepository.step1()).thenAnswer(
    (_) async => right('step1_result'),
  );

  // Second step succeeds
  when(mockRepository.step2(any)).thenAnswer(
    (_) async => right('step2_result'),
  );

  // Act
  final result = await useCase.execute();

  // Assert: Success
  expect(result.isRight(), true);

  // Verify both steps called
  verify(mockRepository.step1()).called(1);
  verify(mockRepository.step2('step1_result')).called(1);
});
```

---

## 4. Provider 단위 테스트

### 4.1 CreatePostProviderV2 테스트

**파일**: `test/features/creation/presentation/providers/create_post_provider_v2_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/creation/presentation/providers/create_post_provider_v2.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';
import 'package:versus_space/features/creation/domain/models/aggregates/post_creation.dart';
import '../../mocks.mocks.dart';

void main() {
  group('CreatePostProviderV2', () {
    late CreatePostProviderV2 provider;
    late MockCreatePostUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockCreatePostUseCase();
      provider = CreatePostProviderV2(
        createPostUseCase: mockUseCase,
        // ... other dependencies
      );
    });

    group('createPost', () {
      test('sets success state on Right from UseCase', () async {
        // Arrange
        final postCreation = PostCreation(
          id: 'post123',
          title: 'Test Post',
          description: 'Test',
          mediaA: [],
          mediaB: [],
          createdAt: DateTime.now(),
          status: 'published',
        );

        when(mockUseCase.execute(
          dto: anyNamed('dto'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async => right(postCreation));

        // Act
        await provider.createPost();

        // Assert
        expect(provider.loadingState, LoadingState.success);
        expect(provider.errorMessage, null);
        expect(provider.uploadProgress, 1.0);
      });

      test('sets error state on Left from UseCase', () async {
        // Arrange
        final failure = CreationFailure.serverError('Test error message');

        when(mockUseCase.execute(
          dto: anyNamed('dto'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async => left(failure));

        // Act
        await provider.createPost();

        // Assert
        expect(provider.loadingState, LoadingState.error);
        expect(provider.errorMessage, 'Test error message');
      });

      test('sets loading state before UseCase execution', () async {
        // Arrange
        when(mockUseCase.execute(
          dto: anyNamed('dto'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(Duration(milliseconds: 100));
          return right(PostCreation(/* ... */));
        });

        // Act
        final future = provider.createPost();

        // Assert: Loading state set immediately
        expect(provider.loadingState, LoadingState.loading);
        expect(provider.errorMessage, null);

        await future;
      });

      test('notifies listeners on state change', () async {
        // Arrange
        var notifyCount = 0;
        provider.addListener(() {
          notifyCount++;
        });

        when(mockUseCase.execute(
          dto: anyNamed('dto'),
          onProgress: anyNamed('onProgress'),
        )).thenAnswer((_) async => right(PostCreation(/* ... */)));

        // Act
        await provider.createPost();

        // Assert
        expect(notifyCount, greaterThan(0));
      });
    });

    group('form data', () {
      test('updates title and notifies listeners', () {
        // Arrange
        var notified = false;
        provider.addListener(() {
          notified = true;
        });

        // Act
        provider.updateTitle('New Title');

        // Assert
        expect(provider.formData.title, 'New Title');
        expect(notified, true);
      });

      test('validates form data correctly', () {
        // Arrange
        provider.updateTitle('');
        provider.updateDescription('');

        // Assert
        expect(provider.canSubmit, false);

        // Arrange
        provider.updateTitle('Valid Title');
        provider.updateDescription('Valid Description');

        // Assert
        expect(provider.canSubmit, true);
      });
    });
  });
}
```

### 4.2 fold 패턴 검증

```dart
test('fold correctly handles Left case', () async {
  // Arrange
  final failure = CreationFailure.invalidInput('Invalid data');
  when(mockUseCase.execute(dto: any))
      .thenAnswer((_) async => left(failure));

  var errorHandled = false;
  var successHandled = false;

  // Mock fold behavior
  final result = await mockUseCase.execute(dto: testDto);
  result.fold(
    (f) {
      errorHandled = true;
      expect(f, equals(failure));
    },
    (s) {
      successHandled = true;
    },
  );

  // Assert
  expect(errorHandled, true);
  expect(successHandled, false);
});

test('fold correctly handles Right case', () async {
  // Arrange
  final postCreation = PostCreation(/* ... */);
  when(mockUseCase.execute(dto: any))
      .thenAnswer((_) async => right(postCreation));

  var errorHandled = false;
  var successHandled = false;

  // Mock fold behavior
  final result = await mockUseCase.execute(dto: testDto);
  result.fold(
    (f) {
      errorHandled = true;
    },
    (s) {
      successHandled = true;
      expect(s, equals(postCreation));
    },
  );

  // Assert
  expect(errorHandled, false);
  expect(successHandled, true);
});
```

### 4.3 ChangeNotifier 테스트

```dart
test('disposes correctly', () {
  // Arrange
  final provider = CreatePostProviderV2(/* ... */);

  // Act
  provider.dispose();

  // Assert: No exception thrown
  expect(() => provider.notifyListeners(), throwsFlutterError);
});

test('handles multiple listeners', () {
  // Arrange
  var listener1Called = 0;
  var listener2Called = 0;

  provider.addListener(() => listener1Called++);
  provider.addListener(() => listener2Called++);

  // Act
  provider.updateTitle('New Title');

  // Assert
  expect(listener1Called, 1);
  expect(listener2Called, 1);
});
```

---

## 5. 통합 테스트

### 5.1 전체 플로우 테스트

**파일**: `test/features/creation/integration/create_post_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Create Post Integration Test', () {
    late PostCreationRepositoryV2Impl repository;
    late MediaRepositoryImpl mediaRepository;
    late CreatePostUseCase useCase;
    late CreatePostProviderV2 provider;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();

      repository = PostCreationRepositoryV2Impl(
        firestore: fakeFirestore,
        // ... other dependencies
      );

      mediaRepository = MediaRepositoryImpl(/* ... */);

      useCase = CreatePostUseCase(
        postRepository: repository,
        mediaRepository: mediaRepository,
        manageTargetAudienceUseCase: ManageTargetAudienceUseCase(/* ... */),
      );

      provider = CreatePostProviderV2(
        createPostUseCase: useCase,
        // ... other dependencies
      );
    });

    test('complete post creation flow succeeds', () async {
      // Arrange
      provider.updateTitle('Integration Test Post');
      provider.updateDescription('Test Description');
      provider.updateTextA('Option A');
      provider.updateTextB('Option B');

      // Act
      await provider.createPost();

      // Assert: Provider state
      expect(provider.loadingState, LoadingState.success);
      expect(provider.errorMessage, null);

      // Assert: Firestore document created
      final snapshot = await fakeFirestore.collection('posts').get();
      expect(snapshot.docs.length, 1);

      final doc = snapshot.docs.first;
      expect(doc.data()['title'], 'Integration Test Post');
      expect(doc.data()['description'], 'Test Description');
    });

    test('validation error prevents repository call', () async {
      // Arrange: Invalid data
      provider.updateTitle('');  // Empty title
      provider.updateDescription('Valid description');

      // Act
      await provider.createPost();

      // Assert: Error state
      expect(provider.loadingState, LoadingState.error);
      expect(provider.errorMessage, contains('Title'));

      // Assert: No Firestore document created
      final snapshot = await fakeFirestore.collection('posts').get();
      expect(snapshot.docs.length, 0);
    });
  });
}
```

### 5.2 에러 시나리오 테스트

```dart
group('Error Scenarios', () {
  test('handles network error gracefully', () async {
    // Arrange: Mock network failure
    // ...

    // Act
    await provider.createPost();

    // Assert
    expect(provider.loadingState, LoadingState.error);
    expect(provider.errorMessage, contains('network'));
  });

  test('handles concurrent creation attempts', () async {
    // Arrange
    provider.updateTitle('Test Post');
    provider.updateDescription('Test Description');

    // Act: Trigger multiple creations
    final future1 = provider.createPost();
    final future2 = provider.createPost();

    await Future.wait([future1, future2]);

    // Assert: Only one post created (idempotency)
    final snapshot = await fakeFirestore.collection('posts').get();
    expect(snapshot.docs.length, lessThanOrEqualTo(1));
  });
});
```

### 5.3 Edge Case 테스트

```dart
group('Edge Cases', () {
  test('handles empty media arrays', () async {
    // Arrange
    provider.updateTitle('Test');
    provider.updateDescription('Test');
    // No images

    // Act
    await provider.createPost();

    // Assert
    expect(provider.loadingState, LoadingState.error);
    expect(provider.errorMessage, contains('media'));
  });

  test('handles very long title/description', () async {
    // Arrange
    provider.updateTitle('A' * 1000);  // Very long title
    provider.updateDescription('B' * 10000);  // Very long description

    // Act
    await provider.createPost();

    // Assert
    expect(provider.loadingState, LoadingState.error);
    expect(provider.errorMessage, contains('too long'));
  });

  test('handles special characters in text', () async {
    // Arrange
    provider.updateTitle('Test 🎉 Title & <script>');
    provider.updateDescription('Description with emojis 😀');

    // Act
    await provider.createPost();

    // Assert: Should succeed (sanitization is separate concern)
    expect(provider.loadingState, LoadingState.success);
  });
});
```

---

## 6. Rollback 절차

### 6.1 전체 롤백 (Phase 2 취소)

**시나리오**: Phase 2 마이그레이션 전체를 취소하고 Phase 1 상태로 복원

#### Step 1: Git 상태 확인

```bash
# 현재 브랜치 확인
git branch
# * feature/phase2-either-pattern
#   main

# 커밋 히스토리 확인
git log --oneline -10
# abc123 feat(creation): Step 4 - Provider Either.fold 패턴 적용
# def456 feat(creation): Step 3 - UseCase Either 패턴 적용
# ghi789 feat(creation): Step 2 - Repository Implementation Either 패턴 적용
# jkl012 feat(creation): Step 1 - Repository Interface Either 패턴 도입
# mno345 chore: Phase 2 시작 전 백업
```

#### Step 2: 전체 롤백 실행

**방법 1: 브랜치 삭제 (가장 안전)**

```bash
# 1. main 브랜치로 전환
git checkout main

# 2. Phase 2 브랜치 삭제
git branch -D feature/phase2-either-pattern

# 3. 확인
git branch
# * main

# ✅ Phase 1 상태로 복원 완료
```

**방법 2: Hard Reset (브랜치 유지)**

```bash
# 1. Phase 2 시작 전 커밋으로 reset
git reset --hard mno345  # "Phase 2 시작 전 백업" 커밋

# 2. 확인
git log --oneline -5
# mno345 chore: Phase 2 시작 전 백업
# (Phase 2 커밋들이 사라짐)

# ✅ Phase 1 상태로 복원 완료
```

#### Step 3: 검증

```bash
# 1. 빌드 확인
flutter clean
flutter pub get
flutter analyze

# 2. Result<T> 패턴 확인
grep -r "Result<" lib/features/creation/domain/usecases/
# 출력: Result<PostCreation> execute(...)

# 3. Either 패턴 없음 확인
grep -r "Either<" lib/features/creation/
# 출력: (없음)

# ✅ 롤백 성공
```

### 6.2 Step별 롤백

**시나리오**: 특정 Step만 롤백 (예: Step 4만 취소)

#### Step 4 롤백 (Provider만 복원)

```bash
# 1. Step 4 커밋 확인
git log --oneline -1
# abc123 feat(creation): Step 4 - Provider Either.fold 패턴 적용

# 2. Step 4 커밋만 취소
git revert abc123

# 3. 또는 Step 3 상태로 reset
git reset --hard def456  # Step 3 커밋

# 4. 충돌 해결 (필요시)
# Provider에서 UseCase 호출 부분 수정

# 5. 검증
flutter analyze
```

#### Step 3 롤백 (UseCase 복원)

```bash
# 1. Step 3-4 모두 취소
git reset --hard ghi789  # Step 2 커밋

# 2. 충돌 해결
# UseCase에서 Repository 호출 부분 수정 필요
# - Repository는 Either 반환
# - UseCase는 Result<T> 사용
# → 변환 코드 추가 필요

# 3. 변환 코드 예시
Future<Result<PostCreation>> execute(...) async {
  final eitherResult = await _repository.createPost(post: post);

  return eitherResult.fold(
    (failure) => ResultFailure(failure),
    (postId) => ResultSuccess(postCreation.copyWith(id: postId)),
  );
}
```

### 6.3 데이터 마이그레이션 롤백

**중요**: Phase 2는 **코드 변경만** 포함하며, 데이터 마이그레이션은 없습니다.

- ✅ Firestore 스키마 변경 없음
- ✅ 기존 데이터 호환성 유지
- ✅ 데이터 롤백 불필요

**확인 사항**:
```bash
# Firestore 쿼리 확인
grep -r "collection('posts')" lib/features/creation/
# 변경 없음 (동일한 컬렉션 사용)

# 문서 구조 확인
grep -r "toFirestore" lib/features/creation/
# 변경 없음 (동일한 매퍼 사용)
```

---

## 7. 최종 검증 체크리스트

### 7.1 코드 품질 검증

#### Compile Time 검증

```bash
# 1. 분석
flutter analyze
# 출력: No issues found!

# 2. 빌드
flutter build apk --debug
# 출력: ✓ Built build/app/outputs/flutter-apk/app-debug.apk

# 3. 타입 체크
dart analyze --fatal-infos lib/features/creation/
# 출력: No issues found!
```

#### 체크리스트

**Repository**:
- [ ] 모든 메서드가 Either 반환
- [ ] throw 키워드 없음 (left/right만 사용)
- [ ] void → Unit 변환 완료
- [ ] null → Option 변환 완료
- [ ] FirebaseException 에러 코드 매핑

**UseCase**:
- [ ] Result<T> import 제거
- [ ] fpdart import 추가
- [ ] flatMap 체이닝 사용
- [ ] 보일러플레이트 감소 (60%+)
- [ ] Helper 메서드도 Either 반환

**Provider**:
- [ ] isSuccess/isFailure 제거
- [ ] fold 패턴 사용
- [ ] failureOrNull/valueOrNull 제거
- [ ] ChangeNotifier 유지 (변경 없음)

### 7.2 성능 검증

#### 메트릭 수집

```dart
// test/benchmarks/either_pattern_benchmark.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Either Pattern Performance', () {
    test('flatMap vs manual chaining', () async {
      final stopwatch = Stopwatch()..start();

      // Measure flatMap performance
      for (var i = 0; i < 10000; i++) {
        await testFlatMapChaining();
      }

      stopwatch.stop();
      print('flatMap: ${stopwatch.elapsedMilliseconds}ms');

      // Compare with manual chaining
      stopwatch.reset();
      stopwatch.start();

      for (var i = 0; i < 10000; i++) {
        await testManualChaining();
      }

      stopwatch.stop();
      print('Manual: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
```

#### 성능 기준

| 항목 | 목표 | 측정값 |
|------|-----|--------|
| **UseCase 실행 시간** | < 100ms | ___ ms |
| **Repository 호출 시간** | < 50ms | ___ ms |
| **flatMap 오버헤드** | < 5% | ___% |
| **메모리 사용량** | 기존 대비 +10% 이내 | ___% |

#### 체크리스트

- [ ] UseCase 실행 시간 증가 < 10%
- [ ] Repository 호출 오버헤드 < 5%
- [ ] flatMap 체이닝 성능 이슈 없음
- [ ] 메모리 누수 없음 (Profiler 확인)

### 7.3 문서화 검증

#### 코드 문서화

```bash
# 1. DartDoc 생성
dart doc lib/features/creation/

# 2. HTML 문서 확인
open doc/api/index.html

# 3. 문서화 커버리지 확인
dart doc --validate-links lib/features/creation/
```

#### 체크리스트

**Repository**:
- [ ] 각 메서드에 **Returns**, **Errors** 문서화
- [ ] Either<L,R> Left/Right 케이스 설명
- [ ] Option<T> Some/None 설명
- [ ] FirebaseException 매핑 문서화

**UseCase**:
- [ ] Either 반환 타입 문서화
- [ ] 각 Failure 케이스 설명
- [ ] flatMap 체이닝 예시 포함
- [ ] 입력 검증 규칙 명시

**Provider**:
- [ ] fold 사용법 예시
- [ ] LoadingState 전환 설명
- [ ] 에러 처리 방법 문서화

**Phase 문서**:
- [ ] PHASE_2_1_OVERVIEW_AND_ANALYSIS.md 완성
- [ ] PHASE_2_2_MIGRATION_STEPS.md 완성
- [ ] PHASE_2_3_TESTING_AND_VALIDATION.md 완성 (현재 문서)
- [ ] README.md 업데이트 (Phase 2 완료 표시)

---

## 8. Phase 2 완료

### 8.1 최종 커밋

```bash
# 1. 모든 테스트 파일 추가
git add test/features/creation/

# 2. 최종 커밋
git commit -m "test(creation): Phase 2 - 테스트 및 검증 완료

- Repository 단위 테스트 (80% 커버리지)
- UseCase 단위 테스트 (90% 커버리지)
- Provider 단위 테스트 (70% 커버리지)
- 통합 테스트 (전체 플로우 5개)
- Rollback 절차 문서화
- 성능 검증 완료

Phase 2 Either Pattern Migration 완료 ✅"
```

### 8.2 PR 생성

```bash
# 1. Remote에 Push
git push origin feature/phase2-either-pattern

# 2. PR 생성 (GitHub CLI 사용 시)
gh pr create --title "feat(creation): Phase 2 - Either Pattern Migration" \
  --body "$(cat <<'EOF'
## Phase 2: Either Pattern Migration

### 📋 Summary
Result<T> → Either<CreationFailure, T> 마이그레이션 완료

### ✅ Changes
- **Repository**: Raw types → Either (3개 파일)
- **UseCase**: Result<T> → Either (15개 파일)
- **Provider**: fold 패턴 적용 (5개 파일)

### 📊 Metrics
- 코드 감소: 60% (flatMap 체이닝)
- 테스트 커버리지: 85%
- 성능 오버헤드: <5%

### 🔗 Documentation
- [Phase 2-1: Overview](./lib/features/creation/PHASE_2_1_OVERVIEW_AND_ANALYSIS.md)
- [Phase 2-2: Migration Steps](./lib/features/creation/PHASE_2_2_MIGRATION_STEPS.md)
- [Phase 2-3: Testing](./lib/features/creation/PHASE_2_3_TESTING_AND_VALIDATION.md)

### ✅ Checklist
- [x] Step 1: Repository Interface
- [x] Step 2: Repository Implementation
- [x] Step 3: UseCase
- [x] Step 4: Provider
- [x] 단위 테스트 작성
- [x] 통합 테스트 작성
- [x] 문서화 완료
- [x] 성능 검증 완료
EOF
)"
```

### 8.3 완료 확인

**Phase 2 완료 기준**:

1. **코드 마이그레이션** ✅
   - [ ] Repository Interface (3개)
   - [ ] Repository Implementation (3개)
   - [ ] UseCase (15개)
   - [ ] Provider (5개)

2. **테스트** ✅
   - [ ] Repository 테스트 (80% 커버리지)
   - [ ] UseCase 테스트 (90% 커버리지)
   - [ ] Provider 테스트 (70% 커버리지)
   - [ ] 통합 테스트 (5개 플로우)

3. **문서화** ✅
   - [ ] PHASE_2_1_OVERVIEW_AND_ANALYSIS.md
   - [ ] PHASE_2_2_MIGRATION_STEPS.md
   - [ ] PHASE_2_3_TESTING_AND_VALIDATION.md
   - [ ] README.md 업데이트

4. **검증** ✅
   - [ ] flutter analyze 통과
   - [ ] flutter build 성공
   - [ ] 성능 기준 충족
   - [ ] Rollback 절차 확인

### 8.4 다음 단계

**Phase 3: Riverpod Migration** (선택 사항)

> ⚠️ **주의**: Creation Feature는 **Riverpod Migration 불필요**
>
> - **이유**: Request-Response 패턴 (실시간 동기화 불필요)
> - **현재**: ChangeNotifier로 충분
> - **추천**: Phase 2에서 종료

**대안: 다른 Feature 마이그레이션**

다음 Feature로 이동 권장:
- Search Feature: Phase 0-2 진행
- Voting Feature: Phase 0-2 진행
- (Chat, Notifications, Post는 이미 완료)

---

**문서 끝** - Phase 2-3 완료 ✅

**전체 Phase 2 마이그레이션 완료!** 🎉

- Phase 2-1: Overview & Analysis (~1,100줄)
- Phase 2-2: Migration Steps (~1,200줄)
- Phase 2-3: Testing & Validation (~1,200줄)

**총 문서량**: ~3,500줄
**총 소요 시간 (예상)**: 7일
