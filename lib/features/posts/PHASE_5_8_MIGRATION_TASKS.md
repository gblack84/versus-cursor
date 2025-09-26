# Posts Feature Phase 5-8 Migration Guide - Enhanced Version

> 작성일: 2025-01-26
> 수정일: 2025-01-26
> 버전: 2.0
> 목적: Phase 5-8 안전한 실행 가이드 (실패 경험 반영)
> 선행조건: Phase 1-4 완료 (확인됨 ✅)

## ⚠️ 중요: 이 문서는 이전 실패를 바탕으로 작성되었습니다
- 323개 → 222개 에러 감소 경험
- 타입 불일치 문제 해결 경험
- 무분별한 어댑터 생성 실패 경험

## 🚨 이전 실패에서 배운 교훈 - 반드시 읽을 것!

### 실패 1: 타입/메서드 불일치
**문제**: 기존 PostsModel의 필드명을 무시하고 새로운 이름 생성
```dart
// ❌ 잘못된 예
class NewPostModel {
  String postTitle; // 기존: title
  List<String> mediaUrls; // 기존: imageUrlsA
}

// ✅ 올바른 예
class PostModel {
  String title; // 기존 필드명 유지
  List<String> imageUrlsA; // 기존 필드명 유지
}
```

### 실패 2: 무분별한 어댑터 생성
**문제**: 에러 해결을 위한 임시방편으로 어댑터 남발
```dart
// ❌ 잘못된 예
PostAdapter → TempPostAdapter → PostContractAdapter → ...

// ✅ 올바른 예
PostsModel.fromLegacy() // 직접 변환 메서드 하나만
```

### 실패 3: Firebase 실제 구조 무시
**문제**: Firestore의 실제 필드명과 다른 이름 사용
```dart
// ❌ 잘못된 예
targetAudience['mode'] // 실제로는 'collectionType'

// ✅ 올바른 예
targetAudience['collectionType'] // Firestore 실제 필드명
```

## ⛔ 절대 하지 말아야 할 것들

### 1. Contract 패턴 남용
❌ **하지 마세요**: 모든 Feature 간 통신에 Contract 생성
✅ **대신 이렇게**: 직접 import 가능하면 직접 사용

### 2. 새로운 타입 생성
❌ **하지 마세요**: AuthFailure → AuthError로 이름 변경
✅ **대신 이렇게**: 기존 타입명 그대로 유지

### 3. Sealed Class 오용
❌ **하지 마세요**: Left(AuthFailure.unexpected())
✅ **대신 이렇게**: Left(const Unexpected())

### 4. 임시 서비스 레이어
❌ **하지 마세요**: IAuthService 같은 불필요한 레이어
✅ **대신 이렇게**: Repository만으로 충분

## ✅ 각 단계별 필수 검증

### Phase 5 시작 전 체크리스트
- [ ] backend.dart에서 제거할 함수의 모든 사용처 파악
- [ ] 각 함수의 정확한 시그니처 문서화
- [ ] AppState 필드의 getter/setter 이름 목록화
- [ ] Firestore 컬렉션의 실제 필드명 확인

### 변경 시 체크리스트
- [ ] 기존 필드명 유지했는가?
- [ ] 기존 메서드 시그니처 유지했는가?
- [ ] flutter analyze 에러 0개인가?
- [ ] 앱이 실행되고 기능이 동작하는가?

## 🔍 실제 구조 확인 방법

### Firestore 필드 확인
1. Firebase Console에서 실제 문서 확인
2. 또는 디버깅으로 snapshot.data() 출력
```dart
print('Actual Firestore fields: ${snapshot.data()}');
```

### 기존 모델 구조 확인
```bash
# 모델 파일에서 fromMap/toMap 메서드 확인
grep -A 20 "fromMap\|toMap" lib/backend/schema/posts_model.dart
```

### AppState 구조 확인
```bash
# AppState의 실제 필드와 메서드 확인
grep -E "get |set |update" lib/app/state/app_state.dart | grep -i post
```

## 📋 Phase 5: 레거시 코드 제거 (상세)

### ⚠️ Phase 5 제거 전 필수 확인사항
1. **사용처 완전 파악**
   ```bash
   # 제거할 함수의 모든 사용처 찾기
   grep -r "queryPostsRecord" lib/ --include="*.dart"
   grep -r "FFAppState().*upload" lib/ --include="*.dart"
   ```

2. **시그니처 보존**
   ```dart
   // 기존 backend.dart 함수
   Stream<List<PostsRecord>> queryPostsRecord({
     Query Function(Query)? queryBuilder,
     int limit = -1,
   })

   // Repository에서 동일한 시그니처 유지
   Stream<List<PostsModel>> queryPostsRecord({ // 이름도 유지 가능
     Query Function(Query)? queryBuilder,
     int limit = -1,
   })
   ```

### ❌ DO NOT - Phase 5
- 새로운 필드명 만들지 마세요
- 메서드 이름 바꾸지 마세요
- 파라미터 순서 바꾸지 마세요

### 5.1 backend.dart Posts 함수 제거

#### 5.1.1 조회 함수 제거 및 대체
```dart
// ❌ 제거할 함수 (backend.dart)
Stream<List<PostsRecord>> queryPostsRecord({
  Query Function(Query)? queryBuilder,
  int limit = -1,
  bool singleRecord = false,
}) =>
    queryCollection(
      PostsRecord.collection,
      PostsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

// ✅ 대체 (PostRepository 사용)
// data/repositories/post_repository_impl.dart
Stream<List<PostsModel>> getFeedPosts({
  required int limit,
  DocumentSnapshot? lastDocument,
}) {
  Query query = _firestore.collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(limit);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument);
  }

  return query.snapshots().map((snapshot) =>
    snapshot.docs.map((doc) => PostsModel.fromSnapshot(doc)).toList()
  );
}
```

#### 5.1.2 생성 함수 제거 및 대체
```dart
// ❌ 제거할 함수 (backend.dart)
Future<DocumentReference> createPost({
  required Map<String, dynamic> postData,
  List<String>? imageUrls,
}) async {
  final docRef = await FirebaseFirestore.instance
    .collection('posts')
    .add(postData);

  if (imageUrls != null && imageUrls.isNotEmpty) {
    await docRef.update({'imageUrlsA': imageUrls});
  }

  return docRef;
}

// ✅ 대체 (CreatePostProvider 사용)
// presentation/providers/create_post_provider.dart
Future<void> createPost() async {
  final result = await _repository.createPost(_draft);

  result.fold(
    (failure) => _showError(failure.message),
    (post) => _navigateToFeed(post),
  );
}
```

### 5.2 AppState Posts 필드 제거

#### 5.2.1 미디어 관련 상태 마이그레이션
```dart
// ❌ 제거할 AppState 필드
class FFAppState extends ChangeNotifier {
  List<String> _uploadImageA = [];
  List<String> _uploadImageB = [];
  List<double> _uploadImageAspectRatioA = [];
  List<double> _uploadImageAspectRatioB = [];

  // Getters/Setters...
}

// ✅ 대체 (MediaProvider 사용)
class MediaProvider extends ChangeNotifier {
  List<MediaInfo> _mediaA = [];
  List<MediaInfo> _mediaB = [];

  List<MediaInfo> get mediaA => List.unmodifiable(_mediaA);
  List<MediaInfo> get mediaB => List.unmodifiable(_mediaB);

  void addMediaA(MediaInfo media) {
    _mediaA.add(media);
    notifyListeners();
  }

  void clearMedia() {
    _mediaA.clear();
    _mediaB.clear();
    notifyListeners();
  }
}
```

#### 5.2.2 사용처 업데이트
```dart
// ❌ Before
FFAppState().uploadImageA = ['url1', 'url2'];
setState(() {});

// ✅ After
context.read<MediaProvider>().addMediaA(
  MediaInfo(url: 'url1', type: MediaType.image)
);
// 자동으로 UI 업데이트 (Consumer/Selector 사용)
```

### 5.3 직접 Firestore 호출 제거

#### 찾기 및 교체 패턴
```bash
# 찾을 패턴
grep -r "FirebaseFirestore.instance.collection('posts')" lib/
grep -r "PostsRecord\." lib/
grep -r "FFAppState().*upload" lib/
```

#### 교체 매핑
| 기존 코드 | 새 코드 |
|---------|--------|
| `FirebaseFirestore.instance.collection('posts').add()` | `_repository.createPost()` |
| `PostsRecord.collection` | `_repository.postsCollection` |
| `FFAppState().uploadImageA` | `context.read<MediaProvider>().mediaA` |
| `backend.queryPostsRecord()` | `_repository.getFeedPosts()` |

## 📋 Phase 6: 의존성 주입 완성 (상세)

### ⚠️ Phase 6 DI 설정 시 주의사항
1. **기존 싱글톤 패턴 유지**
   ```dart
   // 기존 패턴 확인
   class SomeService {
     static SomeService? _instance;
     static SomeService get instance => _instance ??= SomeService._();
   }

   // DI에서도 싱글톤으로 등록
   getIt.registerLazySingleton<SomeService>(() => SomeService.instance);
   ```

2. **기존 생성자 패턴 확인**
   ```dart
   // 기존에 팩토리 패턴이면 팩토리로 등록
   getIt.registerFactory<CreatePostProvider>(() => CreatePostProvider());
   ```

### ❌ DO NOT - Phase 6
- 새로운 의존성 만들지 마세요
- 기존 생성 패턴 무시하지 마세요
- Contract/Adapter 남발하지 마세요

### 6.1 Module 구조
```dart
// lib/app/di/posts_module.dart
import 'package:get_it/get_it.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostsModule {
  static void setup(GetIt getIt) {
    _registerServices(getIt);
    _registerRepositories(getIt);
    _registerProviders(getIt);
    _registerUseCases(getIt);
  }

  static void _registerServices(GetIt getIt) {
    // Media Service
    getIt.registerLazySingleton<IMediaService>(
      () => MediaServiceImpl(
        storage: getIt<FirebaseStorage>(),
        imageProcessor: ImageProcessor(),
      ),
    );

    // Validation Service
    getIt.registerLazySingleton<IValidationService>(
      () => ValidationServiceImpl(),
    );

    // AI Moderation Service
    getIt.registerLazySingleton<IModerationService>(
      () => ModerationServiceImpl(
        httpClient: getIt<Dio>(),
      ),
    );
  }

  static void _registerRepositories(GetIt getIt) {
    // Main Post Repository
    getIt.registerLazySingleton<IPostRepository>(
      () => PostRepositoryImpl(
        firestore: getIt<FirebaseFirestore>(),
        storage: getIt<FirebaseStorage>(),
        votingContract: getIt<IPostVotingContract>(),
        notificationContract: getIt<INotificationContract>(),
      ),
    );

    // Media Repository
    getIt.registerLazySingleton<IMediaRepository>(
      () => MediaRepositoryImpl(
        storage: getIt<FirebaseStorage>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    );
  }

  static void _registerProviders(GetIt getIt) {
    // Create Post Provider
    getIt.registerFactory<CreatePostProvider>(
      () => CreatePostProvider(
        repository: getIt<IPostRepository>(),
        mediaService: getIt<IMediaService>(),
        validationService: getIt<IValidationService>(),
        moderationService: getIt<IModerationService>(),
      ),
    );

    // Feed Provider
    getIt.registerFactory<FeedProvider>(
      () => FeedProvider(
        repository: getIt<IPostRepository>(),
      ),
    );

    // Media Provider
    getIt.registerFactory<MediaProvider>(
      () => MediaProvider(
        mediaService: getIt<IMediaService>(),
      ),
    );

    // Target Audience Provider
    getIt.registerFactory<TargetAudienceProvider>(
      () => TargetAudienceProvider(),
    );
  }

  static void _registerUseCases(GetIt getIt) {
    // Create Post UseCase
    getIt.registerFactory<CreatePostUseCase>(
      () => CreatePostUseCase(
        repository: getIt<IPostRepository>(),
      ),
    );

    // Get Feed UseCase
    getIt.registerFactory<GetFeedUseCase>(
      () => GetFeedUseCase(
        repository: getIt<IPostRepository>(),
      ),
    );

    // Upload Media UseCase
    getIt.registerFactory<UploadMediaUseCase>(
      () => UploadMediaUseCase(
        mediaService: getIt<IMediaService>(),
      ),
    );
  }
}
```

### 6.2 Main DI 통합
```dart
// lib/app/di.dart
import 'posts_module.dart';
import 'auth_module.dart';
import 'voting_module.dart';

class DI {
  static final GetIt _getIt = GetIt.instance;

  static Future<void> setup() async {
    // Core dependencies
    await _setupCore();

    // Feature modules
    PostsModule.setup(_getIt);
    AuthModule.setup(_getIt);
    VotingModule.setup(_getIt);

    // Cross-feature contracts
    _setupContracts();
  }

  static void _setupContracts() {
    _getIt.registerLazySingleton<IPostVotingContract>(
      () => PostVotingContractAdapter(
        votingService: _getIt<IVotingService>(),
      ),
    );

    _getIt.registerLazySingleton<INotificationContract>(
      () => NotificationContractAdapter(
        notificationService: _getIt<INotificationService>(),
      ),
    );
  }
}
```

## 📋 Phase 7: 테스트 및 검증 (상세)

### 7.1 Unit Test 구현

#### 7.1.1 Model Tests
```dart
// test/features/posts/domain/models/target_audience_test.dart
import 'package:test/test.dart';
import 'package:versus_cursor/features/posts/domain/models/target_audience.dart';

void main() {
  group('TargetAudience', () {
    test('should create with default values', () {
      const audience = TargetAudience(mode: 'quick');

      expect(audience.mode, 'quick');
      expect(audience.selectedUserIds, isEmpty);
      expect(audience.filters, isEmpty);
    });

    test('should copy with new values', () {
      const audience = TargetAudience(mode: 'quick');
      final updated = audience.copyWith(mode: 'public');

      expect(updated.mode, 'public');
      expect(updated.selectedUserIds, isEmpty);
    });
  });
}
```

#### 7.1.2 Repository Tests
```dart
// test/features/posts/data/repositories/post_repository_test.dart
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}
class MockStorage extends Mock implements FirebaseStorage {}

void main() {
  late PostRepositoryImpl repository;
  late MockFirestore mockFirestore;
  late MockStorage mockStorage;

  setUp(() {
    mockFirestore = MockFirestore();
    mockStorage = MockStorage();
    repository = PostRepositoryImpl(
      firestore: mockFirestore,
      storage: mockStorage,
    );
  });

  group('createPost', () {
    test('should return post when creation succeeds', () async {
      // Arrange
      final post = PostsModel(title: 'Test');
      when(mockFirestore.collection('posts').add(any))
        .thenAnswer((_) async => MockDocumentReference());

      // Act
      final result = await repository.createPost(post);

      // Assert
      expect(result.isRight(), true);
    });

    test('should return failure when creation fails', () async {
      // Arrange
      final post = PostsModel(title: 'Test');
      when(mockFirestore.collection('posts').add(any))
        .thenThrow(Exception('Network error'));

      // Act
      final result = await repository.createPost(post);

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
```

### 7.2 Integration Test 구현

#### 7.2.1 Create Post Flow Test
```dart
// test/features/posts/integration/create_post_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Post Flow', () {
    testWidgets('should create post with images', (tester) async {
      // Launch app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Navigate to create post
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(
        find.byKey(Key('titleField')),
        'Test Post',
      );

      // Add images
      await tester.tap(find.byKey(Key('addImageA')));
      await tester.pumpAndSettle();

      // Select images from gallery (mocked)
      await tester.tap(find.text('Gallery'));
      await tester.pumpAndSettle();

      // Create post
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify navigation to feed
      expect(find.text('Test Post'), findsOneWidget);
    });
  });
}
```

### 7.3 E2E Checklist

#### 7.3.1 포스트 생성 플로우
- [ ] 앱 실행
- [ ] Create 버튼 탭
- [ ] 제목 입력
- [ ] 설명 입력
- [ ] 이미지 A 추가
- [ ] 이미지 B 추가
- [ ] 타겟 설정 (quick/public/custom)
- [ ] 미리보기 확인
- [ ] 생성 완료
- [ ] 피드에서 확인

#### 7.3.2 미디어 업로드
- [ ] 갤러리에서 선택
- [ ] 카메라 촬영
- [ ] 여러 이미지 선택
- [ ] 이미지 편집
- [ ] 썸네일 생성
- [ ] 업로드 진행률
- [ ] 에러 처리

#### 7.3.3 에러 시나리오
- [ ] 네트워크 끊김
- [ ] 스토리지 한도 초과
- [ ] 잘못된 이미지 형식
- [ ] 권한 거부
- [ ] 서버 에러

## 📋 Phase 8: 문서화 및 정리 (상세)

### 8.1 API Documentation

```dart
/// Posts Feature API Documentation
///
/// ## Overview
/// Posts Feature는 Clean Architecture v4.0을 따르며,
/// 다음과 같은 레이어로 구성됩니다:
///
/// - Domain Layer: 비즈니스 로직과 엔티티
/// - Data Layer: 데이터 소스와 레포지토리 구현
/// - Presentation Layer: UI와 상태 관리
///
/// ## Usage Example
/// ```dart
/// // Get repository from DI
/// final repository = getIt<IPostRepository>();
///
/// // Create a post
/// final result = await repository.createPost(
///   PostsModel(
///     title: 'My Post',
///     description: 'Description',
///   ),
/// );
///
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (post) => print('Created: ${post.id}'),
/// );
/// ```
///
/// ## Architecture
/// ```
/// UI Widget
///    ↓
/// Provider (State Management)
///    ↓
/// UseCase (Business Logic)
///    ↓
/// Repository (Interface)
///    ↓
/// Data Source (Firebase)
/// ```
```

### 8.2 Migration Report

```markdown
# Posts Feature Migration Report

## Summary
- **Start Date**: 2025-01-26
- **End Date**: TBD
- **Total Files Modified**: XX
- **Total Lines Changed**: +XXXX / -XXXX

## Changes Made
1. Separated ChangeNotifier from Domain models
2. Implemented Repository pattern
3. Added Contract pattern for cross-feature communication
4. Migrated from AppState to Provider
5. Removed direct Firebase calls

## Benefits Achieved
- ✅ Clear separation of concerns
- ✅ Testable architecture
- ✅ Maintainable code structure
- ✅ No UI/UX changes

## Metrics
- Code Coverage: XX% → XX%
- Build Time: XXs → XXs
- App Size: XX MB → XX MB
```

---

## 🎯 안전한 실행 순서

### Step 1: 현황 파악 (Phase 5 시작 전 필수)
1. 기존 구조 완전 문서화
   ```bash
   # 현재 사용 중인 모든 메서드 찾기
   grep -r "queryPostsRecord\|createPost\|FFAppState" lib/ --include="*.dart" > usage_report.txt
   ```
2. 모든 의존성 매핑
3. 테스트 시나리오 작성

### Step 2: 점진적 변경
1. **하나씩 변경**: 한 번에 하나의 함수/필드만 변경
2. **각 변경 후 테스트**:
   ```bash
   flutter analyze
   flutter test
   # 앱 실행 및 기능 테스트
   ```
3. **즉시 커밋**: 각 성공적인 변경 후 바로 커밋

### Step 3: 검증
1. flutter analyze (에러 0개 확인)
2. 앱 실행 테스트
3. 주요 기능 동작 확인:
   - 포스트 생성
   - 이미지 업로드
   - 피드 로딩
   - 투표 기능

## 🔴 절대 규칙

### 기능과 UI는 절대 변경 없음
- 모든 화면 레이아웃 유지
- 버튼 위치/크기 그대로
- 애니메이션 효과 유지
- 색상/폰트 변경 금지

### 기존 구조 무시 금지
- 필드명 그대로 사용
- 메서드 시그니처 유지
- 파라미터 순서 보존
- 타입 변경 금지

### 임시방편 어댑터 금지
- 에러 나면 근본 원인 해결
- Adapter → Adapter → Adapter 체인 금지
- 직접 변환 메서드 사용

## 🚨 Important Notes

1. **절대 UI 변경 금지**: 모든 Widget의 시각적 출력은 동일해야 함
2. **기능 유지**: 사용자가 체감하는 모든 기능 그대로
3. **점진적 진행**: 한 번에 모든 것을 바꾸지 말 것
4. **테스트 우선**: 각 단계마다 동작 확인 필수
5. **실패 시 즉시 롤백**: 에러 증가하면 바로 이전 커밋으로 복귀

## 🔗 관련 문서
- [CLEAN_ARCHITECTURE_MIGRATION_COMPLETE_GUIDE.md](./CLEAN_ARCHITECTURE_MIGRATION_COMPLETE_GUIDE.md)
- [MIGRATION_TASKS_UPDATED_V2.md](./MIGRATION_TASKS_UPDATED_V2.md)
- [REFACTORING_TASKS.md](./REFACTORING_TASKS.md)