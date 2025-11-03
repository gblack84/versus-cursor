# Creation Feature - Phase 5: Extension Pattern (Part 3/3)

> **문서 버전**: 1.0.0
> **작성일**: 2025-11-03
> **대상 Feature**: Creation Feature
> **Phase**: 5 - Extension Pattern (Firebase-Centric v2.0)
> **Part**: 3/3 (섹션 6-8: 테스트, 롤백, 일정)

---

## 📋 목차 (Part 3)

- [테스트 전략](#-테스트-전략)
- [롤백 계획](#-롤백-계획)
- [마이그레이션 일정](#-마이그레이션-일정)

**이전 문서**: [PHASE_5_2.md](./PHASE_5_2.md) - 구현 가이드, Before/After 코드
**시작 문서**: [PHASE_5_1.md](./PHASE_5_1.md) - 개요, 분석, 목표

---

## 🧪 테스트 전략

### 테스트 범위 Overview

```
Extension Tests (3개 파일)
  ├── PostCreationFirestore Extension
  ├── MediaInfoFirestore Extension (Sealed Class)
  └── TargetAudienceFirestore Extension

Repository Tests (8개 파일)
  ├── PostCreationRepositoryV2Impl
  ├── MediaRepositoryImpl
  ├── MediaUploadRepositoryImpl
  ├── ContentModerationRepositoryImpl
  ├── ContentVisibilityRepositoryImpl
  ├── ImageProcessingRepositoryImpl
  ├── TargetAudienceRepositoryImpl
  └── ContentMetricsRepositoryImpl

Integration Tests (E2E)
  ├── 게시물 생성 → 미디어 업로드 → 조회
  ├── Sealed Class roundtrip (ImageInfo ↔ VideoInfo)
  └── Cache + Extension 통합
```

---

## 6.1. Extension Tests

### PostCreationFirestore Extension Test

**파일**: `test/features/creation/domain/entities/post_creation_extensions_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:versus_space/features/creation/domain/entities/post_creation.dart';
import 'package:versus_space/features/creation/domain/entities/post_creation_extensions.dart';

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  group('PostCreationFirestore Extension', () {
    group('fromFirestore', () {
      test('converts DocumentSnapshot with all fields correctly', () {
        // Arrange
        final doc = MockDocumentSnapshot();
        when(doc.id).thenReturn('post123');
        when(doc.data()).thenReturn({
          'userId': 'user1',
          'questionTitle': 'Test Question?',
          'description': 'Test description',
          'optionA': {
            'text': 'Option A',
            'images': ['url1', 'url2'],
            'videos': [],
            'aspectRatios': [1.5, 1.2],
          },
          'optionB': {
            'text': 'Option B',
            'images': [],
            'videos': ['video1'],
            'aspectRatios': [1.0],
          },
          'voteConfiguration': {
            'startTime': Timestamp.fromDate(DateTime(2025, 1, 1)),
            'endTime': Timestamp.fromDate(DateTime(2025, 1, 31)),
            'maxVotesPerUser': 1,
            'allowRevote': false,
          },
          'targetAudience': {
            'gender': ['male', 'female'],
            'ageRange': {'min': 18, 'max': 65},
            'interests': ['tech', 'gaming'],
            'expertise': [],
            'location': [],
            'criteria': {},
          },
          'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1, 12, 0)),
          'status': 'published',
          'isAnonymous': false,
          'mediaUrls': ['media1', 'media2'],
          'eventId': 'event123',
        });

        // Act
        final post = PostCreationFirestore.fromFirestore(doc);

        // Assert
        expect(post.id, 'post123');
        expect(post.userId, 'user1');
        expect(post.questionTitle, 'Test Question?');
        expect(post.description, 'Test description');

        // Nested structures
        expect(post.optionA.text, 'Option A');
        expect(post.optionA.images, ['url1', 'url2']);
        expect(post.optionA.aspectRatios, [1.5, 1.2]);

        expect(post.optionB.text, 'Option B');
        expect(post.optionB.videos, ['video1']);

        expect(post.voteConfiguration.maxVotesPerUser, 1);
        expect(post.voteConfiguration.allowRevote, false);

        expect(post.targetAudience.gender, ['male', 'female']);
        expect(post.targetAudience.interests, ['tech', 'gaming']);

        expect(post.status, 'published');
        expect(post.eventId, 'event123');
      });

      test('handles missing optional fields with defaults', () {
        // Arrange
        final doc = MockDocumentSnapshot();
        when(doc.id).thenReturn('post456');
        when(doc.data()).thenReturn({
          'userId': 'user2',
          'questionTitle': 'Minimal Post',
          // description: null (optional)
          'optionA': {'text': 'A'},
          'optionB': {'text': 'B'},
          // voteConfiguration: null (defaults)
          // targetAudience: null (defaults)
          'createdAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
          // status: null (defaults to 'draft')
          // isAnonymous: null (defaults to false)
        });

        // Act
        final post = PostCreationFirestore.fromFirestore(doc);

        // Assert
        expect(post.description, null);
        expect(post.status, 'draft');  // Default
        expect(post.isAnonymous, false);  // Default
        expect(post.eventId, null);
        expect(post.voteConfiguration.maxVotesPerUser, 1);  // Default
      });

      test('handles null data map gracefully', () {
        // Arrange
        final doc = MockDocumentSnapshot();
        when(doc.id).thenReturn('post789');
        when(doc.data()).thenReturn(null);

        // Act
        final post = PostCreationFirestore.fromFirestore(doc);

        // Assert
        expect(post.id, 'post789');
        expect(post.userId, '');  // Default empty string
        expect(post.questionTitle, '');
        expect(post.status, 'draft');
      });
    });

    group('toFirestore', () {
      test('creates valid Firestore map with all fields', () {
        // Arrange
        final post = PostCreation(
          id: 'post123',
          userId: 'user1',
          questionTitle: 'Test?',
          description: 'Description',
          optionA: PostOption(
            text: 'A',
            images: ['img1'],
            videos: [],
            aspectRatios: [1.5],
          ),
          optionB: PostOption(
            text: 'B',
            images: [],
            videos: ['vid1'],
            aspectRatios: [1.0],
          ),
          voteConfiguration: VoteConfiguration(
            startTime: DateTime(2025, 1, 1),
            endTime: DateTime(2025, 1, 31),
            maxVotesPerUser: 1,
            allowRevote: false,
          ),
          targetAudience: TargetAudience(
            gender: ['male'],
            ageRange: AgeRange(min: 18, max: 65),
            interests: ['tech'],
            expertise: [],
            location: [],
            criteria: {},
          ),
          createdAt: DateTime(2025, 1, 1, 12, 0),
          status: 'published',
          isAnonymous: false,
          mediaUrls: ['media1'],
          eventId: 'event123',
        );

        // Act
        final map = post.toFirestore();

        // Assert
        expect(map['userId'], 'user1');
        expect(map['questionTitle'], 'Test?');
        expect(map['description'], 'Description');

        // Nested structures
        expect(map['optionA']['text'], 'A');
        expect(map['optionA']['images'], ['img1']);
        expect(map['optionB']['videos'], ['vid1']);

        expect(map['voteConfiguration']['maxVotesPerUser'], 1);
        expect(map['targetAudience']['gender'], ['male']);

        expect(map['createdAt'], isA<Timestamp>());
        expect(map['status'], 'published');
        expect(map['eventId'], 'event123');
      });

      test('omits null fields from Firestore map', () {
        // Arrange
        final post = PostCreation(
          id: 'post456',
          userId: 'user2',
          questionTitle: 'Minimal',
          description: null,  // Null field
          optionA: PostOption.empty(),
          optionB: PostOption.empty(),
          voteConfiguration: VoteConfiguration.default_(),
          targetAudience: TargetAudience.empty(),
          createdAt: DateTime(2025, 1, 2),
          status: 'draft',
          isAnonymous: false,
          mediaUrls: [],
          eventId: null,  // Null field
        );

        // Act
        final map = post.toFirestore();

        // Assert
        expect(map.containsKey('description'), false);  // Null omitted
        expect(map.containsKey('eventId'), false);  // Null omitted
        expect(map.containsKey('userId'), true);  // Non-null present
      });
    });

    group('roundtrip', () {
      test('maintains data integrity through fromFirestore → toFirestore', () {
        // Arrange
        final original = PostCreation(
          id: 'roundtrip123',
          userId: 'user3',
          questionTitle: 'Roundtrip Test',
          description: 'Test description',
          optionA: PostOption(text: 'A', images: ['img1'], videos: [], aspectRatios: [1.5]),
          optionB: PostOption(text: 'B', images: [], videos: ['vid1'], aspectRatios: [1.0]),
          voteConfiguration: VoteConfiguration.default_(),
          targetAudience: TargetAudience.empty(),
          createdAt: DateTime(2025, 1, 3, 10, 30),
          status: 'draft',
          isAnonymous: false,
          mediaUrls: ['m1', 'm2'],
          eventId: 'evt123',
        );

        // Act: Entity → Map
        final map = original.toFirestore();

        // Create mock doc with map data
        final doc = MockDocumentSnapshot();
        when(doc.id).thenReturn(original.id);
        when(doc.data()).thenReturn(map);

        // Act: Map → Entity
        final restored = PostCreationFirestore.fromFirestore(doc);

        // Assert: All fields match
        expect(restored.id, original.id);
        expect(restored.userId, original.userId);
        expect(restored.questionTitle, original.questionTitle);
        expect(restored.description, original.description);
        expect(restored.optionA.text, original.optionA.text);
        expect(restored.optionB.videos, original.optionB.videos);
        expect(restored.mediaUrls, original.mediaUrls);
        expect(restored.eventId, original.eventId);
      });
    });
  });
}
```

---

### MediaInfoFirestore Extension Test (Sealed Class)

**파일**: `test/features/creation/domain/entities/media_info_extensions_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:versus_space/features/creation/domain/value_objects/media_info.dart';
import 'package:versus_space/features/creation/domain/entities/media_info_extensions.dart';

void main() {
  group('MediaInfoFirestore Extension - Sealed Class', () {
    group('fromFirestore - ImageInfo', () {
      test('creates ImageInfo for type=image', () {
        // Arrange
        final data = {
          'type': 'image',
          'id': 'img1',
          'url': 'https://example.com/image.jpg',
          'parentId': 'post123',
          'width': 1920,
          'height': 1080,
          'aspectRatio': 1.77,
          'size': 2048000,
          'uploadedAt': Timestamp.fromDate(DateTime(2025, 1, 1)),
          'uploadedBy': 'user1',
        };

        // Act
        final info = MediaInfoFirestore.fromFirestore(data);

        // Assert
        expect(info, isA<ImageInfo>());
        info.when(
          image: (img) {
            expect(img.id, 'img1');
            expect(img.url, 'https://example.com/image.jpg');
            expect(img.parentId, 'post123');
            expect(img.width, 1920);
            expect(img.height, 1080);
            expect(img.aspectRatio, 1.77);
            expect(img.size, 2048000);
            expect(img.uploadedBy, 'user1');
          },
          video: (_) => fail('Should be ImageInfo, not VideoInfo'),
        );
      });

      test('handles missing optional fields for ImageInfo', () {
        // Arrange
        final data = {
          'type': 'image',
          'id': 'img2',
          'url': 'https://example.com/minimal.jpg',
          // width, height, aspectRatio: null (optional)
          'uploadedAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
          'uploadedBy': 'user2',
        };

        // Act
        final info = MediaInfoFirestore.fromFirestore(data);

        // Assert
        info.when(
          image: (img) {
            expect(img.width, null);
            expect(img.height, null);
            expect(img.aspectRatio, null);
          },
          video: (_) => fail('Should be ImageInfo'),
        );
      });
    });

    group('fromFirestore - VideoInfo', () {
      test('creates VideoInfo for type=video', () {
        // Arrange
        final data = {
          'type': 'video',
          'id': 'vid1',
          'url': 'https://example.com/video.mp4',
          'parentId': 'post456',
          'duration': 120,  // 2 minutes
          'thumbnailUrl': 'https://example.com/thumb.jpg',
          'width': 1280,
          'height': 720,
          'aspectRatio': 1.77,
          'size': 10240000,
          'uploadedAt': Timestamp.fromDate(DateTime(2025, 1, 3)),
          'uploadedBy': 'user3',
        };

        // Act
        final info = MediaInfoFirestore.fromFirestore(data);

        // Assert
        expect(info, isA<VideoInfo>());
        info.when(
          image: (_) => fail('Should be VideoInfo, not ImageInfo'),
          video: (vid) {
            expect(vid.id, 'vid1');
            expect(vid.url, 'https://example.com/video.mp4');
            expect(vid.duration, 120);
            expect(vid.thumbnailUrl, 'https://example.com/thumb.jpg');
            expect(vid.width, 1280);
            expect(vid.height, 720);
          },
        );
      });
    });

    group('toFirestore', () {
      test('converts ImageInfo to Firestore map with type=image', () {
        // Arrange
        final imageInfo = ImageInfo(
          id: 'img3',
          url: 'https://example.com/test.jpg',
          parentId: 'post789',
          width: 800,
          height: 600,
          aspectRatio: 1.33,
          size: 1024000,
          uploadedAt: DateTime(2025, 1, 4, 10, 0),
          uploadedBy: 'user4',
        );

        // Act
        final map = imageInfo.toFirestore();

        // Assert
        expect(map['type'], 'image');
        expect(map['id'], 'img3');
        expect(map['url'], 'https://example.com/test.jpg');
        expect(map['width'], 800);
        expect(map['height'], 600);
        expect(map['uploadedAt'], isA<Timestamp>());
        expect(map.containsKey('duration'), false);  // Video field not present
        expect(map.containsKey('thumbnailUrl'), false);
      });

      test('converts VideoInfo to Firestore map with type=video', () {
        // Arrange
        final videoInfo = VideoInfo(
          id: 'vid2',
          url: 'https://example.com/clip.mp4',
          parentId: 'post101',
          duration: 60,
          thumbnailUrl: 'https://example.com/t2.jpg',
          width: 1920,
          height: 1080,
          aspectRatio: 1.77,
          size: 5120000,
          uploadedAt: DateTime(2025, 1, 5, 15, 30),
          uploadedBy: 'user5',
        );

        // Act
        final map = videoInfo.toFirestore();

        // Assert
        expect(map['type'], 'video');
        expect(map['id'], 'vid2');
        expect(map['duration'], 60);
        expect(map['thumbnailUrl'], 'https://example.com/t2.jpg');
        expect(map['width'], 1920);
      });
    });

    group('roundtrip', () {
      test('ImageInfo maintains data through roundtrip', () {
        // Arrange
        final original = ImageInfo(
          id: 'img_rt',
          url: 'https://example.com/rt.jpg',
          parentId: 'post_rt',
          width: 1024,
          height: 768,
          aspectRatio: 1.33,
          size: 2048000,
          uploadedAt: DateTime(2025, 1, 6, 12, 0),
          uploadedBy: 'user_rt',
        );

        // Act
        final map = original.toFirestore();
        final restored = MediaInfoFirestore.fromFirestore(map);

        // Assert
        expect(restored, isA<ImageInfo>());
        restored.when(
          image: (img) {
            expect(img.id, original.id);
            expect(img.url, original.url);
            expect(img.width, original.width);
            expect(img.height, original.height);
          },
          video: (_) => fail('Should restore as ImageInfo'),
        );
      });

      test('VideoInfo maintains data through roundtrip', () {
        // Arrange
        final original = VideoInfo(
          id: 'vid_rt',
          url: 'https://example.com/rt.mp4',
          parentId: 'post_rt',
          duration: 90,
          thumbnailUrl: 'https://example.com/rt_thumb.jpg',
          width: 1280,
          height: 720,
          aspectRatio: 1.77,
          size: 7168000,
          uploadedAt: DateTime(2025, 1, 7, 14, 0),
          uploadedBy: 'user_rt',
        );

        // Act
        final map = original.toFirestore();
        final restored = MediaInfoFirestore.fromFirestore(map);

        // Assert
        expect(restored, isA<VideoInfo>());
        restored.when(
          image: (_) => fail('Should restore as VideoInfo'),
          video: (vid) {
            expect(vid.id, original.id);
            expect(vid.duration, original.duration);
            expect(vid.thumbnailUrl, original.thumbnailUrl);
          },
        );
      });
    });
  });
}
```

---

## 6.2. Repository Tests

### PostCreationRepositoryV2Impl Test

**파일**: `test/features/creation/data/repositories/post_creation_repository_v2_impl_test.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:versus_space/features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import 'package:versus_space/features/creation/domain/entities/post_creation.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late PostCreationRepositoryV2Impl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = PostCreationRepositoryV2Impl(
      firestore: fakeFirestore,
      targetAudienceService: null,
      imageProcessingService: MockImageProcessingService(),
    );
  });

  group('PostCreationRepositoryV2Impl - Extension Pattern', () {
    test('createPost uses Extension and returns doc ID', () async {
      // Arrange
      final post = PostCreation(
        id: '',
        userId: 'user1',
        questionTitle: 'Test Post',
        optionA: PostOption(text: 'A'),
        optionB: PostOption(text: 'B'),
        voteConfiguration: VoteConfiguration.default_(),
        targetAudience: TargetAudience.empty(),
        createdAt: DateTime(2025, 1, 1),
        status: 'draft',
        isAnonymous: false,
        mediaUrls: [],
      );

      // Act
      final postId = await repository.createPost(post: post);

      // Assert
      expect(postId, isNotEmpty);

      // Verify Firestore data (Extension 변환 확인)
      final doc = await fakeFirestore.collection('posts').doc(postId).get();
      expect(doc.exists, true);
      expect(doc.data()!['userId'], 'user1');
      expect(doc.data()!['questionTitle'], 'Test Post');
      expect(doc.data()!['optionA']['text'], 'A');
    });

    test('getPost uses Extension and returns PostCreation', () async {
      // Arrange
      final postId = 'test_post_123';
      await fakeFirestore.collection('posts').doc(postId).set({
        'userId': 'user2',
        'questionTitle': 'Existing Post',
        'optionA': {'text': 'Option A'},
        'optionB': {'text': 'Option B'},
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 2)),
        'status': 'published',
        'isAnonymous': false,
        'mediaUrls': [],
      });

      // Act
      final post = await repository.getPost(postId);

      // Assert
      expect(post, isNotNull);
      expect(post!.id, postId);
      expect(post.userId, 'user2');
      expect(post.questionTitle, 'Existing Post');
      expect(post.optionA.text, 'Option A');
    });

    test('getPost returns null for non-existent post', () async {
      // Act
      final post = await repository.getPost('non_existent');

      // Assert
      expect(post, null);
    });

    test('watchPost uses Extension and streams updates', () async {
      // Arrange
      final postId = 'stream_post';
      await fakeFirestore.collection('posts').doc(postId).set({
        'userId': 'user3',
        'questionTitle': 'Stream Test',
        'optionA': {'text': 'A'},
        'optionB': {'text': 'B'},
        'createdAt': Timestamp.fromDate(DateTime(2025, 1, 3)),
        'status': 'draft',
        'isAnonymous': false,
        'mediaUrls': [],
      });

      // Act
      final stream = repository.watchPost(postId);

      // Assert
      await expectLater(
        stream,
        emits(predicate<PostCreation>((post) {
          return post.id == postId &&
                 post.questionTitle == 'Stream Test' &&
                 post.userId == 'user3';
        })),
      );
    });
  });
}
```

---

## 6.3. Integration Tests (E2E)

**파일**: `integration_test/creation_feature_phase5_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Creation Feature Phase 5 - E2E Integration', () {
    late FirebaseFirestore firestore;

    setUp(() {
      firestore = FirebaseFirestore.instance;
    });

    testWidgets('Complete post creation flow with Extension', (tester) async {
      // 1. Create post (Extension)
      final post = PostCreation(
        id: '',
        userId: 'integration_user',
        questionTitle: 'Integration Test Post',
        optionA: PostOption(text: 'A', images: []),
        optionB: PostOption(text: 'B', images: []),
        voteConfiguration: VoteConfiguration.default_(),
        targetAudience: TargetAudience.empty(),
        createdAt: DateTime.now(),
        status: 'draft',
        isAnonymous: false,
        mediaUrls: [],
      );

      final docRef = firestore.collection('posts').doc();
      await docRef.set(post.toFirestore());  // Extension!

      // 2. Verify Firestore data
      final doc = await docRef.get();
      expect(doc.exists, true);

      // 3. Extension roundtrip
      final retrieved = PostCreationFirestore.fromFirestore(doc);
      expect(retrieved.questionTitle, 'Integration Test Post');
      expect(retrieved.userId, 'integration_user');

      // 4. Cleanup
      await docRef.delete();
    });

    testWidgets('MediaInfo Sealed Class roundtrip', (tester) async {
      // 1. Create ImageInfo
      final imageInfo = ImageInfo(
        id: 'integration_img',
        url: 'https://example.com/integration.jpg',
        parentId: 'integration_post',
        width: 1920,
        height: 1080,
        aspectRatio: 1.77,
        size: 2048000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'integration_user',
      );

      // 2. Save to Firestore (Extension)
      await firestore.collection('media').doc(imageInfo.id).set(
        imageInfo.toFirestore(),
      );

      // 3. Retrieve and verify (Extension)
      final doc = await firestore.collection('media').doc(imageInfo.id).get();
      final data = doc.data() as Map<String, dynamic>;
      final retrieved = MediaInfoFirestore.fromFirestore(data);

      // 4. Assert Sealed Class type
      expect(retrieved, isA<ImageInfo>());
      retrieved.when(
        image: (img) {
          expect(img.id, 'integration_img');
          expect(img.width, 1920);
          expect(img.height, 1080);
        },
        video: (_) => fail('Should be ImageInfo'),
      );

      // 5. Cleanup
      await firestore.collection('media').doc(imageInfo.id).delete();
    });
  });
}
```

---

## 🔄 롤백 계획

### 시나리오별 롤백 절차

#### 시나리오 1: Extension 파일 생성 실패

**발생 시점**: Step 1 (Extension 파일 3개 생성)

**영향 범위**:
- 영향 없음 (기존 코드 변경 없음)
- Extension 파일만 추가

**롤백 절차**:
```bash
# 1. Extension 파일 삭제
rm lib/features/creation/domain/entities/post_creation_extensions.dart
rm lib/features/creation/domain/entities/media_info_extensions.dart
rm lib/features/creation/domain/value_objects/target_audience_extensions.dart

# 2. Git revert
git revert HEAD

# 3. 검증
flutter analyze
flutter test lib/features/creation/
```

**복구 시간**: 5분

---

#### 시나리오 2: Repository 전환 중 에러 발생

**발생 시점**: Step 2 (8개 Repository 전환 중)

**영향 범위**:
- 전환된 Repository만 영향
- 미전환 Repository는 정상 작동

**롤백 절차 (의존성 역순)**:
```bash
# 1. 마지막 전환부터 역순 롤백
# PostCreationRepositoryV2Impl → ... → ImageProcessingRepositoryImpl

# 2. Git log 확인
git log --oneline

# 3. 특정 Repository commit revert
git revert <commit-hash>

# 예: PostCreationRepositoryV2Impl 롤백
git revert abc123  # "feat: Convert PostCreationRepositoryV2Impl to Extension"

# 4. DI 모듈 복구
git checkout HEAD~1 lib/features/creation/di/creation_di_module.dart

# 5. 검증
flutter test lib/features/creation/data/repositories/post_creation_repository_v2_impl_test.dart
```

**Repository 롤백 순서 (역순)**:
1. PostCreationRepositoryV2Impl (가장 먼저 롤백)
2. MediaUploadRepositoryImpl
3. MediaRepositoryImpl
4. ContentMetricsRepositoryImpl
5. ContentVisibilityRepositoryImpl
6. ContentModerationRepositoryImpl
7. TargetAudienceRepositoryImpl
8. ImageProcessingRepositoryImpl (가장 마지막 롤백)

**복구 시간**: 30분 ~ 1시간

---

#### 시나리오 3: Legacy 파일 삭제 후 문제 발견

**발생 시점**: Step 4 (DataSource/DTO/Mapper 삭제)

**영향 범위**:
- 전체 Creation Feature
- Import 에러 발생 가능

**롤백 절차**:
```bash
# 1. Git stash (현재 작업 임시 저장)
git stash

# 2. Legacy 파일 복구
git checkout HEAD~1 lib/features/creation/data/datasources/
git checkout HEAD~1 lib/features/creation/data/models/
git checkout HEAD~1 lib/features/creation/data/mappers/

# 3. Repository 코드 복구 (Phase 4 상태로)
git checkout HEAD~2 lib/features/creation/data/repositories/

# 4. DI 모듈 복구
git checkout HEAD~2 lib/features/creation/di/creation_di_module.dart

# 5. 검증
flutter analyze
flutter test lib/features/creation/

# 6. 성공 시 commit
git add .
git commit -m "Rollback: Restore Phase 4 state due to Step 4 failure"
```

**복구 시간**: 1-2시간

---

#### 시나리오 4: Production 배포 후 이슈 발견

**발생 시점**: Step 6 (검증) 통과 후 배포

**영향 범위**:
- Production 전체
- 사용자 영향 발생

**긴급 롤백 절차**:
```bash
# 1. Production branch로 이동
git checkout production

# 2. Phase 4 tag로 롤백
git tag  # Phase 4 tag 확인 (예: v1.4.0-phase4)
git reset --hard v1.4.0-phase4

# 3. Hotfix branch 생성
git checkout -b hotfix/rollback-phase5

# 4. 빌드 및 배포
flutter build apk --release
# Firebase App Distribution 또는 Play Store Emergency Release

# 5. 배포 확인
# User metrics, Crashlytics 모니터링

# 6. Production merge
git checkout production
git merge hotfix/rollback-phase5
git push origin production

# 7. Phase 5 branch로 돌아가서 수정
git checkout feature/phase5-extension-pattern
# 문제 원인 분석 및 수정
```

**복구 시간**: 3-4시간 (긴급 배포 포함)

---

### 롤백 체크리스트

#### Step 1 롤백 (Extension 생성)
- [ ] Extension 파일 3개 삭제 확인
- [ ] Git history 확인
- [ ] `flutter analyze` 통과
- [ ] 기존 테스트 통과

#### Step 2 롤백 (Repository 전환)
- [ ] 롤백 대상 Repository 확인
- [ ] 의존성 역순으로 롤백
- [ ] DI 모듈 복구
- [ ] Repository 테스트 통과
- [ ] Integration test 통과

#### Step 4 롤백 (Legacy 삭제)
- [ ] DataSource 4개 파일 복구
- [ ] DTO 6개 파일 복구
- [ ] Mapper 3개 파일 복구
- [ ] Repository 코드 Phase 4로 복구
- [ ] DI 모듈 Phase 4로 복구
- [ ] 전체 테스트 통과
- [ ] 빌드 성공

#### Production 롤백
- [ ] Phase 4 tag 확인
- [ ] Hotfix branch 생성
- [ ] 빌드 성공
- [ ] Staging 환경 검증
- [ ] Production 배포
- [ ] 사용자 영향 모니터링 (Crashlytics, Analytics)
- [ ] 롤백 완료 공지

---

## 📅 마이그레이션 일정

### 총 예상 기간: 10-12일

**Chat Feature 대비**:
- Chat: 5-7일 (1 repository, 2 entities)
- Creation: 10-12일 (8 repositories, 4 entities, sealed class)
- **2배 시간 소요 이유**: Repository 개수, Sealed Class 복잡도, Storage 특수 처리

---

### Day 1-2: Extension 파일 3개 생성

**목표**: PostCreation, MediaInfo, TargetAudience Extension 완성

#### Day 1 (8시간)
- **오전 (4시간)**: PostCreation Extension 작성
  - fromFirestore() 구현 (nested structures)
  - toFirestore() 구현
  - Helper 함수 10개 작성
  - 예상 코드: 180줄

- **오후 (4시간)**: MediaInfo Extension 작성
  - Sealed Class when() 패턴 매칭
  - ImageInfo/VideoInfo 구분 변환
  - Helper 함수 3개 작성
  - 예상 코드: 120줄

#### Day 2 (6시간)
- **오전 (3시간)**: TargetAudience Extension 작성
  - fromMap() / toMap() 구현
  - AgeRange Extension 추가
  - 예상 코드: 60줄

- **오후 (3시간)**: Extension 테스트 작성
  - post_creation_extensions_test.dart (20개 테스트)
  - media_info_extensions_test.dart (15개 테스트)
  - target_audience_extensions_test.dart (10개 테스트)
  - 예상 코드: 300줄 테스트

**✅ Checkpoint 1**: Extension 파일 3개 + 테스트 100% pass

---

### Day 3-5: 독립 Repository 5개 전환

**목표**: 의존성 없는 Repository 병렬 전환

#### Day 3 (8시간)
- **오전 (4시간)**:
  - ImageProcessingRepositoryImpl 전환 (219줄 → 110줄)
  - 테스트 작성 및 검증

- **오후 (4시간)**:
  - TargetAudienceRepositoryImpl 전환 (253줄 → 120줄)
  - 테스트 작성 및 검증

#### Day 4 (8시간)
- **오전 (4시간)**:
  - ContentModerationRepositoryImpl 전환 (298줄 → 150줄)
  - 테스트 작성 및 검증

- **오후 (4시간)**:
  - ContentVisibilityRepositoryImpl 전환 (361줄 → 180줄)
  - 테스트 작성 및 검증

#### Day 5 (4시간)
- **오전 (4시간)**:
  - ContentMetricsRepositoryImpl 전환 (287줄 → 140줄)
  - 테스트 작성 및 검증

**✅ Checkpoint 2**: 5개 독립 Repository 테스트 100% pass

---

### Day 6-8: 의존성 있는 Repository 3개 순차 전환

**목표**: MediaRepository → MediaUploadRepository → PostCreationRepositoryV2

#### Day 6 (8시간)
- **전일 (8시간)**: MediaRepositoryImpl 전환
  - Sealed Class MediaInfo 활용
  - queryImages(), queryVideos(), queryAllMedia() 구현
  - Storage 직접 주입
  - 404줄 → 200줄
  - 테스트 작성 (Sealed Class when() 검증)

#### Day 7 (8시간)
- **전일 (8시간)**: MediaUploadRepositoryImpl 전환
  - MediaRepository 의존성 주입
  - uploadImage(), uploadVideo() 구현
  - Storage 직접 사용 (DataSource 제거)
  - 252줄 → 120줄
  - Integration test (파일 업로드 + 메타데이터 저장)

#### Day 8 (8시간)
- **전일 (8시간)**: PostCreationRepositoryV2Impl 전환 (가장 복잡)
  - 모든 Repository 의존성 통합
  - createPost(), getPost(), watchPost() 등 15+ methods
  - 399줄 → 180줄 (가장 큰 감소)
  - 테스트 작성 (전체 흐름 검증)

**✅ Checkpoint 3**: 전체 8개 Repository 테스트 100% pass

---

### Day 9: Legacy 파일 삭제 및 DI 업데이트

**목표**: DataSource/DTO/Mapper 완전 제거

#### Day 9 (8시간)
- **오전 (2시간)**: 삭제 전 검증
  - Extension 사용 확인 (grep)
  - Legacy 참조 확인 (grep)
  - 전체 테스트 실행

- **오전 (2시간)**: Legacy 파일 삭제
  - DataSource 4개 삭제
  - DTO 6개 삭제
  - Mapper 3개 삭제
  - 총 13개 파일, 1,400줄 삭제

- **오후 (2시간)**: DI 모듈 업데이트
  - DataSource/Mapper 등록 제거
  - Repository에 Firebase SDK 직접 주입
  - DI 코드 30% 감소

- **오후 (2시간)**: Import 에러 수정 및 검증
  - `flutter analyze` 실행
  - 모든 import 에러 수정
  - 전체 빌드 성공

**✅ Checkpoint 4**: Import errors 0, 앱 빌드 성공

---

### Day 10-12: 통합 테스트 및 최종 검증

**목표**: Production 배포 준비 완료

#### Day 10 (8시간)
- **오전 (4시간)**: Integration Tests (E2E)
  - 게시물 생성 → 미디어 업로드 → 조회
  - Sealed Class roundtrip 검증
  - Cache + Extension 통합 검증

- **오후 (4시간)**: 성능 벤치마크
  - Before/After 응답 시간 비교
  - 메모리 사용량 비교
  - Firestore 읽기/쓰기 횟수 비교

#### Day 11 (8시간)
- **오전 (4시간)**: Staging 환경 배포
  - Staging Firebase 프로젝트 배포
  - QA 시나리오 실행
  - Crashlytics 모니터링

- **오후 (4시간)**: 문제 발견 시 수정
  - 버그 수정
  - 추가 테스트
  - Staging 재배포

#### Day 12 (4시간)
- **오전 (2시간)**: Production 배포 준비
  - Release Notes 작성
  - Rollback 계획 최종 점검
  - Monitoring Dashboard 준비

- **오후 (2시간)**: Production 배포
  - Firebase Functions 배포
  - Flutter App 배포 (Play Store / App Store)
  - Monitoring 시작 (24시간 집중)

**✅ Final Checkpoint**: Production ready, Monitoring active

---

### 마일스톤 요약

| 마일스톤 | 완료일 | 달성 기준 | 롤백 가능성 |
|---------|--------|----------|-----------|
| **Milestone 1** | Day 2 | Extension 3개 + Tests 100% | 낮음 (5%) |
| **Milestone 2** | Day 5 | 독립 Repository 5개 전환 | 중간 (15%) |
| **Milestone 3** | Day 8 | 전체 Repository 8개 전환 | 중간 (20%) |
| **Milestone 4** | Day 9 | Legacy 삭제, DI 업데이트 | 높음 (30%) |
| **Milestone 5** | Day 12 | Production 배포 완료 | 낮음 (10%) |

**리스크가 가장 높은 구간**: Day 9 (Legacy 삭제)
- Legacy 파일 삭제 후 예상치 못한 의존성 발견 가능
- 충분한 검증 시간 확보 필요 (2시간 → 3시간으로 연장 권장)

---

## 최종 점검 사항

### Phase 5 완료 기준

#### 코드 품질
- [ ] Extension 파일 3개 생성 완료
- [ ] Repository 8개 전환 완료 (Extension 사용)
- [ ] Legacy 파일 13개 삭제 완료
- [ ] DI 모듈 업데이트 완료
- [ ] `flutter analyze` 에러 0개
- [ ] 코드 60% 감소 달성 (3,873줄 → 1,560줄)

#### 테스트
- [ ] Extension 테스트 45개 이상 pass
- [ ] Repository 테스트 80개 이상 pass
- [ ] Integration 테스트 10개 이상 pass
- [ ] 테스트 커버리지 ≥85%

#### 성능
- [ ] Firestore 읽기 비용 유지 또는 감소
- [ ] 응답 시간 유지 또는 개선
- [ ] 메모리 사용량 10% 이내 증가

#### 문서
- [ ] PHASE_5_1.md 완성
- [ ] PHASE_5_2.md 완성
- [ ] PHASE_5_3.md 완성
- [ ] README.md 업데이트
- [ ] Migration Report 작성

#### 배포
- [ ] Staging 환경 검증 완료
- [ ] QA 승인 완료
- [ ] Rollback 계획 준비 완료
- [ ] Production 배포 완료
- [ ] 24시간 모니터링 이상 없음

---

## 다음 단계: Feature 전체 통합

**Phase 5 완료 후**:
1. **다른 Feature 적용**: Profile, Chat, Notifications Feature에도 Extension Pattern 적용
2. **Performance Monitoring**: Firebase Performance Monitoring으로 지속 추적
3. **Continuous Improvement**: Extension Helper 함수 공통화, 재사용성 향상

**관련 문서**:
- [Chat Feature PHASE_5](/lib/features/chat/PHASE_5_EXTENSION_PATTERN.md) - 참조 구현
- [Profile Feature 계획](/lib/features/profile/README.md) - 다음 적용 대상

---

**문서 메타데이터**:
- **작성자**: AI Assistant (Claude Code)
- **최종 수정**: 2025-11-03
- **이전 문서**: [PHASE_5_2.md](./PHASE_5_2.md)
- **시작 문서**: [PHASE_5_1.md](./PHASE_5_1.md)
- **관련 문서**:
  - [PHASE_1_FREEZED_MIGRATION.md](./PHASE_1_FREEZED_MIGRATION.md)
  - [PHASE_2_2_MIGRATION_STEPS.md](./PHASE_2_2_MIGRATION_STEPS.md)
  - [PHASE_3_CACHE_INTEGRATION.md](./PHASE_3_CACHE_INTEGRATION.md)
  - [PHASE_4_1.md](./PHASE_4_1.md), [PHASE_4_2.md](./PHASE_4_2.md)
