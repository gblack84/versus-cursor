# 🧪 Backend Repositories 테스트 가이드

> Repository 패턴의 완벽한 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 85%

## 📋 테스트 개요

### 현재 상태
- **테스트 커버리지**: 0% (구현 전)
- **테스트 파일**: 0개
- **Mock 객체**: 0개

### 목표 상태
- **테스트 커버리지**: 85% 이상
- **테스트 파일**: 40개+
- **Mock 객체**: 완벽한 Mock 시스템

## 🎯 테스트 전략

### 1. 테스트 피라미드
```
         /\
        /E2E\      10% - End-to-End Tests
       /------\
      /Integration\ 30% - Integration Tests
     /------------\
    /   Unit Tests  \ 60% - Unit Tests
   /----------------\
```

### 2. 테스트 범위
- **Unit Tests**: Repository 메서드, Mapper, Exception
- **Integration Tests**: Firebase 통합, 캐싱 동작
- **E2E Tests**: 실제 사용 시나리오

## 🏗️ 테스트 인프라 설정

### 1. 패키지 설정
```yaml
# pubspec.yaml
dev_dependencies:
  # 테스트 프레임워크
  test: ^1.24.0
  flutter_test:
    sdk: flutter
  
  # Mock 생성
  mockito: ^5.4.0
  build_runner: ^2.4.0
  
  # Firebase 테스트
  fake_cloud_firestore: ^2.4.0
  firebase_auth_mocks: ^0.13.0
  firebase_storage_mocks: ^0.6.0
  
  # 테스트 유틸리티
  faker: ^2.1.0
  equatable: ^2.0.5
```

### 2. 테스트 디렉토리 구조
```
test/
├── backend/
│   └── repositories/
│       ├── unit/
│       │   ├── user_repository_test.dart
│       │   ├── post_repository_test.dart
│       │   ├── chat_repository_test.dart
│       │   └── media_repository_test.dart
│       ├── integration/
│       │   ├── firebase_integration_test.dart
│       │   ├── cache_integration_test.dart
│       │   └── transaction_test.dart
│       ├── mocks/
│       │   ├── mock_repositories.dart
│       │   ├── mock_services.dart
│       │   └── test_data.dart
│       └── fixtures/
│           ├── user_fixtures.dart
│           ├── post_fixtures.dart
│           └── message_fixtures.dart
└── test_utils/
    ├── firebase_test_setup.dart
    ├── mock_generator.dart
    └── test_helpers.dart
```

## 📝 Mock 시스템 구축

### 1. Mock Generator 설정
```dart
// test/backend/repositories/mocks/mock_repositories.dart
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '/backend/repositories/interfaces/i_user_repository.dart';
import '/backend/repositories/interfaces/i_post_repository.dart';
import '/backend/repositories/interfaces/i_chat_repository.dart';
import '/backend/repositories/interfaces/i_media_repository.dart';
import '/services/cache/unified_cache_service.dart';

@GenerateMocks([
  // Firebase
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  FirebaseStorage,
  Reference,
  
  // Repositories
  IUserRepository,
  IPostRepository,
  IChatRepository,
  IMediaRepository,
  
  // Services
  UnifiedCacheService,
  
  // Mappers
  UserMapper,
  PostMapper,
  MessageMapper,
], customMocks: [
  MockSpec<QueryDocumentSnapshot>(
    as: #MockQueryDocumentSnapshot,
    returnNullOnMissingStub: false,
  ),
])
void main() {}

// 생성 명령
// flutter pub run build_runner build --delete-conflicting-outputs
```

### 2. Test Fixtures
```dart
// test/backend/repositories/fixtures/user_fixtures.dart
import 'package:faker/faker.dart';
import '/features/auth/domain/models/user.dart';

class UserFixtures {
  static final faker = Faker();
  
  static User createUser({
    String? id,
    String? email,
    String? displayName,
    List<String>? interests,
    int? pointsA,
    int? pointsQ,
  }) {
    return User(
      id: id ?? faker.guid.guid(),
      email: email ?? faker.internet.email(),
      displayName: displayName ?? faker.person.name(),
      photoUrl: faker.image.image(),
      interests: interests ?? List.generate(3, (_) => faker.lorem.word()),
      pointsA: pointsA ?? faker.randomGenerator.integer(1000),
      pointsQ: pointsQ ?? faker.randomGenerator.integer(1000),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isPremium: faker.randomGenerator.boolean(),
      role: 'user',
    );
  }
  
  static List<User> createUsers(int count) {
    return List.generate(count, (_) => createUser());
  }
  
  static Map<String, dynamic> userToJson(User user) {
    return {
      'id': user.id,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoUrl,
      'interests': user.interests,
      'pointsA': user.pointsA,
      'pointsQ': user.pointsQ,
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt.toIso8601String(),
      'isPremium': user.isPremium,
      'role': user.role,
    };
  }
}

// test/backend/repositories/fixtures/post_fixtures.dart
class PostFixtures {
  static Post createPost({
    String? id,
    String? userId,
    String? content,
    int? votesA,
    int? votesB,
    DateTime? voteEndTime,
  }) {
    final faker = Faker();
    
    return Post(
      id: id ?? faker.guid.guid(),
      userId: userId ?? faker.guid.guid(),
      content: content ?? faker.lorem.sentence(),
      optionA: {
        'text': faker.lorem.words(3).join(' '),
        'imageUrl': faker.image.image(),
      },
      optionB: {
        'text': faker.lorem.words(3).join(' '),
        'imageUrl': faker.image.image(),
      },
      votesA: votesA ?? faker.randomGenerator.integer(100),
      votesB: votesB ?? faker.randomGenerator.integer(100),
      voteStartTime: DateTime.now(),
      voteEndTime: voteEndTime ?? DateTime.now().add(Duration(hours: 24)),
      voteStatus: 'active',
      createdAt: DateTime.now(),
      likeCount: faker.randomGenerator.integer(100),
      commentCount: faker.randomGenerator.integer(50),
      shareCount: faker.randomGenerator.integer(20),
    );
  }
}
```

### 3. Test Helpers
```dart
// test/test_utils/test_helpers.dart
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestHelpers {
  // Mock DocumentSnapshot 생성
  static MockDocumentSnapshot createMockDocument({
    required String id,
    required Map<String, dynamic> data,
    bool exists = true,
  }) {
    final mock = MockDocumentSnapshot();
    
    when(mock.id).thenReturn(id);
    when(mock.exists).thenReturn(exists);
    when(mock.data()).thenReturn(exists ? data : null);
    when(mock.get(any)).thenAnswer((invocation) {
      final field = invocation.positionalArguments[0] as String;
      return data[field];
    });
    
    return mock;
  }
  
  // Mock QuerySnapshot 생성
  static MockQuerySnapshot createMockQuerySnapshot({
    required List<Map<String, dynamic>> documents,
  }) {
    final mock = MockQuerySnapshot();
    final docs = documents.map((data) {
      return createMockQueryDocumentSnapshot(data: data);
    }).toList();
    
    when(mock.docs).thenReturn(docs);
    when(mock.size).thenReturn(docs.length);
    
    return mock;
  }
  
  // Firestore 경로 Mock
  static void mockFirestorePath({
    required MockFirebaseFirestore firestore,
    required String collection,
    required String document,
    required Map<String, dynamic> data,
  }) {
    final mockCollection = MockCollectionReference<Map<String, dynamic>>();
    final mockDocument = MockDocumentReference<Map<String, dynamic>>();
    final mockSnapshot = createMockDocument(
      id: document,
      data: data,
      exists: true,
    );
    
    when(firestore.collection(collection)).thenReturn(mockCollection);
    when(mockCollection.doc(document)).thenReturn(mockDocument);
    when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
  }
}
```

## 🧪 Unit Tests

### 1. UserRepository 테스트
```dart
// test/backend/repositories/unit/user_repository_test.dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import '/backend/repositories/user_repository.dart';
import '../mocks/mock_repositories.mocks.dart';
import '../fixtures/user_fixtures.dart';
import '/test_utils/test_helpers.dart';

void main() {
  late UserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockUnifiedCacheService mockCache;
  late MockUserMapper mockMapper;
  
  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCache = MockUnifiedCacheService();
    mockMapper = MockUserMapper();
    
    repository = UserRepository(
      mockFirestore,
      mockCache,
      mockMapper,
      Logger.test(),
    );
  });
  
  group('UserRepository', () {
    group('getUser', () {
      test('should return user from cache when available', () async {
        // Given
        const userId = 'test123';
        final user = UserFixtures.createUser(id: userId);
        final userData = UserFixtures.userToJson(user);
        
        when(mockCache.get<Map<String, dynamic>>('user_$userId'))
            .thenAnswer((_) async => userData);
        when(mockMapper.fromJson(userData))
            .thenReturn(user);
        
        // When
        final result = await repository.getUser(userId);
        
        // Then
        expect(result, equals(user));
        verify(mockCache.get<Map<String, dynamic>>('user_$userId')).called(1);
        verifyNever(mockFirestore.collection(any));
      });
      
      test('should fetch from Firestore when cache miss', () async {
        // Given
        const userId = 'test123';
        final user = UserFixtures.createUser(id: userId);
        final userData = UserFixtures.userToJson(user);
        
        when(mockCache.get<Map<String, dynamic>>('user_$userId'))
            .thenAnswer((_) async => null);
        
        TestHelpers.mockFirestorePath(
          firestore: mockFirestore,
          collection: 'users',
          document: userId,
          data: userData,
        );
        
        when(mockMapper.fromFirestore(any))
            .thenReturn(user);
        when(mockMapper.toJson(user))
            .thenReturn(userData);
        when(mockCache.set(any, any, timeout: anyNamed('timeout')))
            .thenAnswer((_) async {});
        
        // When
        final result = await repository.getUser(userId);
        
        // Then
        expect(result, equals(user));
        verify(mockFirestore.collection('users')).called(1);
        verify(mockCache.set(
          'user_$userId',
          userData,
          timeout: anyNamed('timeout'),
        )).called(1);
      });
      
      test('should return null when user not found', () async {
        // Given
        const userId = 'nonexistent';
        
        when(mockCache.get<Map<String, dynamic>>('user_$userId'))
            .thenAnswer((_) async => null);
        
        final mockDoc = TestHelpers.createMockDocument(
          id: userId,
          data: {},
          exists: false,
        );
        
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDocument = MockDocumentReference<Map<String, dynamic>>();
        
        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDocument);
        when(mockDocument.get()).thenAnswer((_) async => mockDoc);
        
        // When
        final result = await repository.getUser(userId);
        
        // Then
        expect(result, isNull);
        verifyNever(mockCache.set(any, any));
      });
      
      test('should throw ValidationException for empty userId', () async {
        // When & Then
        expect(
          () => repository.getUser(''),
          throwsA(isA<ValidationException>()),
        );
        
        verifyNever(mockCache.get(any));
        verifyNever(mockFirestore.collection(any));
      });
      
      test('should throw NetworkException on Firebase error', () async {
        // Given
        const userId = 'test123';
        
        when(mockCache.get<Map<String, dynamic>>('user_$userId'))
            .thenAnswer((_) async => null);
        when(mockFirestore.collection(any))
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              message: 'Network error',
            ));
        
        // When & Then
        expect(
          () => repository.getUser(userId),
          throwsA(isA<NetworkException>()),
        );
      });
    });
    
    group('getUsers', () {
      test('should return multiple users in parallel', () async {
        // Given
        final users = UserFixtures.createUsers(3);
        final userIds = users.map((u) => u.id).toList();
        
        for (var i = 0; i < users.length; i++) {
          final user = users[i];
          final userData = UserFixtures.userToJson(user);
          
          when(mockCache.get<Map<String, dynamic>>('user_${user.id}'))
              .thenAnswer((_) async => null);
          
          TestHelpers.mockFirestorePath(
            firestore: mockFirestore,
            collection: 'users',
            document: user.id,
            data: userData,
          );
          
          when(mockMapper.fromFirestore(any))
              .thenReturn(user);
        }
        
        // When
        final result = await repository.getUsers(userIds);
        
        // Then
        expect(result.length, equals(3));
        expect(result, containsAll(users));
      });
      
      test('should filter out null results', () async {
        // Given
        final userIds = ['exist1', 'nonexistent', 'exist2'];
        final user1 = UserFixtures.createUser(id: 'exist1');
        final user2 = UserFixtures.createUser(id: 'exist2');
        
        // Mock existing users
        TestHelpers.mockFirestorePath(
          firestore: mockFirestore,
          collection: 'users',
          document: 'exist1',
          data: UserFixtures.userToJson(user1),
        );
        
        TestHelpers.mockFirestorePath(
          firestore: mockFirestore,
          collection: 'users',
          document: 'exist2',
          data: UserFixtures.userToJson(user2),
        );
        
        // Mock non-existing user
        final mockDoc = TestHelpers.createMockDocument(
          id: 'nonexistent',
          data: {},
          exists: false,
        );
        
        when(mockFirestore.collection('users').doc('nonexistent').get())
            .thenAnswer((_) async => mockDoc);
        
        // When
        final result = await repository.getUsers(userIds);
        
        // Then
        expect(result.length, equals(2));
        expect(result.map((u) => u.id), containsAll(['exist1', 'exist2']));
      });
    });
    
    group('createUser', () {
      test('should create user and invalidate cache', () async {
        // Given
        final user = UserFixtures.createUser();
        final userData = UserFixtures.userToJson(user);
        
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDocument = MockDocumentReference<Map<String, dynamic>>();
        
        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(user.id)).thenReturn(mockDocument);
        when(mockDocument.set(any)).thenAnswer((_) async {});
        when(mockMapper.toFirestore(user)).thenReturn(userData);
        when(mockCache.remove('user_${user.id}')).thenAnswer((_) async {});
        
        // When
        await repository.createUser(user);
        
        // Then
        verify(mockDocument.set(userData)).called(1);
        verify(mockCache.remove('user_${user.id}')).called(1);
      });
    });
    
    group('watchUser', () {
      test('should stream user updates', () async {
        // Given
        const userId = 'test123';
        final user = UserFixtures.createUser(id: userId);
        final userData = UserFixtures.userToJson(user);
        
        final mockDoc = TestHelpers.createMockDocument(
          id: userId,
          data: userData,
          exists: true,
        );
        
        final controller = StreamController<DocumentSnapshot>();
        
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDocument = MockDocumentReference<Map<String, dynamic>>();
        
        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(userId)).thenReturn(mockDocument);
        when(mockDocument.snapshots()).thenAnswer((_) => controller.stream);
        when(mockMapper.fromFirestore(any)).thenReturn(user);
        
        // When
        final stream = repository.watchUser(userId);
        final subscription = stream.listen(expectAsync1((result) {
          expect(result, equals(user));
        }));
        
        // Emit event
        controller.add(mockDoc);
        
        // Cleanup
        await Future.delayed(Duration(milliseconds: 100));
        await subscription.cancel();
        await controller.close();
      });
    });
  });
}
```

### 2. PostRepository 테스트
```dart
// test/backend/repositories/unit/post_repository_test.dart
void main() {
  group('PostRepository', () {
    group('vote', () {
      test('should execute vote transaction correctly', () async {
        // Given
        const postId = 'post123';
        const userId = 'user456';
        const option = VoteOption.a;
        
        final post = PostFixtures.createPost(
          id: postId,
          voteEndTime: DateTime.now().add(Duration(hours: 1)),
        );
        
        final mockTransaction = MockTransaction();
        final mockPostRef = MockDocumentReference<Map<String, dynamic>>();
        final mockVoteRef = MockDocumentReference<Map<String, dynamic>>();
        final mockPostDoc = TestHelpers.createMockDocument(
          id: postId,
          data: PostFixtures.postToJson(post),
        );
        
        when(mockFirestore.runTransaction(any)).thenAnswer((invocation) async {
          final callback = invocation.positionalArguments[0];
          return await callback(mockTransaction);
        });
        
        when(mockFirestore.collection('posts').doc(postId))
            .thenReturn(mockPostRef);
        when(mockPostRef.collection('votes').doc(userId))
            .thenReturn(mockVoteRef);
        when(mockTransaction.get(mockPostRef))
            .thenAnswer((_) async => mockPostDoc);
        when(mockMapper.fromFirestore(mockPostDoc))
            .thenReturn(post);
        
        // When
        await repository.vote(postId, userId, option);
        
        // Then
        verify(mockTransaction.set(mockVoteRef, {
          'userId': userId,
          'option': 'a',
          'votedAt': FieldValue.serverTimestamp(),
        })).called(1);
        
        verify(mockTransaction.update(mockPostRef, {
          'votesA': FieldValue.increment(1),
        })).called(1);
        
        verify(mockCache.remove('post_$postId')).called(1);
      });
      
      test('should throw ValidationException when voting ended', () async {
        // Given
        const postId = 'post123';
        const userId = 'user456';
        
        final post = PostFixtures.createPost(
          id: postId,
          voteEndTime: DateTime.now().subtract(Duration(hours: 1)), // 종료됨
        );
        
        final mockPostDoc = TestHelpers.createMockDocument(
          id: postId,
          data: PostFixtures.postToJson(post),
        );
        
        when(mockFirestore.runTransaction(any)).thenAnswer((invocation) async {
          final callback = invocation.positionalArguments[0];
          final mockTransaction = MockTransaction();
          
          when(mockTransaction.get(any))
              .thenAnswer((_) async => mockPostDoc);
          when(mockMapper.fromFirestore(mockPostDoc))
              .thenReturn(post);
          
          return await callback(mockTransaction);
        });
        
        // When & Then
        expect(
          () => repository.vote(postId, userId, VoteOption.a),
          throwsA(isA<ValidationException>()),
        );
      });
    });
    
    group('getFeedPosts', () {
      test('should load posts with user information', () async {
        // Given
        final posts = PostFixtures.createPosts(3);
        final users = posts.map((p) => 
            UserFixtures.createUser(id: p.userId)
        ).toList();
        
        final mockQuery = MockQuery<Map<String, dynamic>>();
        final mockSnapshot = TestHelpers.createMockQuerySnapshot(
          documents: posts.map(PostFixtures.postToJson).toList(),
        );
        
        when(mockFirestore.collection('posts'))
            .thenReturn(MockCollectionReference());
        when(mockFirestore.collection('posts')
            .where('isPublished', isEqualTo: true))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.limit(20))
            .thenReturn(mockQuery);
        when(mockQuery.get())
            .thenAnswer((_) async => mockSnapshot);
        
        for (var i = 0; i < posts.length; i++) {
          when(mockMapper.fromFirestore(any))
              .thenReturn(posts[i]);
        }
        
        when(mockUserRepository.getUsers(any))
            .thenAnswer((_) async => users);
        
        // When
        final result = await repository.getFeedPosts();
        
        // Then
        expect(result.length, equals(3));
        verify(mockUserRepository.getUsers(any)).called(1);
      });
    });
  });
}
```

## 🔄 Integration Tests

### 1. Firebase Integration 테스트
```dart
// test/backend/repositories/integration/firebase_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/test_utils/firebase_test_setup.dart';

void main() {
  setUpAll(() async {
    // Firebase Emulator 초기화
    await Firebase.initializeApp();
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    
    // 테스트 데이터 시드
    await FirebaseTestSetup.seedTestData();
  });
  
  tearDownAll(() async {
    // 테스트 데이터 정리
    await FirebaseTestSetup.clearTestData();
  });
  
  group('Firebase Integration', () {
    late UserRepository repository;
    
    setUp(() {
      repository = UserRepository(
        FirebaseFirestore.instance,
        UnifiedCacheService.instance,
        UserMapper(),
        Logger.test(),
      );
    });
    
    test('should create and retrieve user from Firestore', () async {
      // Given
      final user = UserFixtures.createUser();
      
      // When
      await repository.createUser(user);
      final retrieved = await repository.getUser(user.id);
      
      // Then
      expect(retrieved?.id, equals(user.id));
      expect(retrieved?.email, equals(user.email));
      expect(retrieved?.displayName, equals(user.displayName));
    });
    
    test('should handle concurrent writes correctly', () async {
      // Given
      final user = UserFixtures.createUser();
      await repository.createUser(user);
      
      // When - 동시 업데이트
      final futures = List.generate(10, (i) {
        final updated = user.copyWith(
          pointsA: user.pointsA + i,
        );
        return repository.updateUser(updated);
      });
      
      await Future.wait(futures);
      
      // Then
      final final retrieved = await repository.getUser(user.id);
      expect(retrieved, isNotNull);
      // 마지막 업데이트가 반영되어야 함
    });
    
    test('should stream real-time updates', () async {
      // Given
      final user = UserFixtures.createUser();
      await repository.createUser(user);
      
      // When
      final stream = repository.watchUser(user.id);
      final updates = <User>[];
      
      final subscription = stream.listen((u) {
        updates.add(u);
      });
      
      // 업데이트 실행
      await Future.delayed(Duration(milliseconds: 100));
      await repository.updateUser(user.copyWith(displayName: 'Updated'));
      
      await Future.delayed(Duration(milliseconds: 100));
      await repository.updateUser(user.copyWith(displayName: 'Updated Again'));
      
      await Future.delayed(Duration(milliseconds: 500));
      
      // Then
      expect(updates.length, greaterThanOrEqualTo(3));
      expect(updates.last.displayName, equals('Updated Again'));
      
      await subscription.cancel();
    });
  });
}
```

### 2. Cache Integration 테스트
```dart
// test/backend/repositories/integration/cache_integration_test.dart
void main() {
  group('Cache Integration', () {
    test('should use cache hierarchy correctly', () async {
      // Given
      final repository = UserRepository(
        FakeFirebaseFirestore(),
        UnifiedCacheService.test(), // 테스트용 인스턴스
        UserMapper(),
        Logger.test(),
      );
      
      final user = UserFixtures.createUser();
      
      // When - 첫 번째 호출 (네트워크)
      final start1 = DateTime.now();
      await repository.createUser(user);
      final result1 = await repository.getUser(user.id);
      final duration1 = DateTime.now().difference(start1);
      
      // When - 두 번째 호출 (L1 캐시)
      final start2 = DateTime.now();
      final result2 = await repository.getUser(user.id);
      final duration2 = DateTime.now().difference(start2);
      
      // Then
      expect(result1, equals(result2));
      expect(duration2.inMilliseconds, lessThan(duration1.inMilliseconds ~/ 10));
    });
    
    test('should invalidate cache on update', () async {
      // Given
      final repository = UserRepository(
        FakeFirebaseFirestore(),
        UnifiedCacheService.test(),
        UserMapper(),
        Logger.test(),
      );
      
      final user = UserFixtures.createUser();
      await repository.createUser(user);
      
      // 캐시에 저장
      await repository.getUser(user.id);
      
      // When - 업데이트
      final updated = user.copyWith(displayName: 'Updated Name');
      await repository.updateUser(updated);
      
      // Then - 새 데이터 반환
      final result = await repository.getUser(user.id);
      expect(result?.displayName, equals('Updated Name'));
    });
  });
}
```

## 🎯 E2E Tests

### 1. 전체 시나리오 테스트
```dart
// test/backend/repositories/e2e/user_flow_test.dart
void main() {
  group('User Flow E2E', () {
    test('complete user journey', () async {
      // Given - DI 설정
      await configureDependencies(environment: 'test');
      final userRepo = getIt<IUserRepository>();
      final postRepo = getIt<IPostRepository>();
      
      // 1. 사용자 생성
      final newUser = User(
        id: 'test_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      await userRepo.createUser(newUser);
      
      // 2. 프로필 업데이트
      final updated = newUser.copyWith(
        interests: ['Flutter', 'Dart', 'Firebase'],
        photoUrl: 'https://example.com/photo.jpg',
      );
      
      await userRepo.updateUser(updated);
      
      // 3. 게시물 작성
      final post = Post(
        id: 'test_post_${DateTime.now().millisecondsSinceEpoch}',
        userId: newUser.id,
        content: 'Test post content',
        optionA: {'text': 'Option A'},
        optionB: {'text': 'Option B'},
      );
      
      await postRepo.createPost(post);
      
      // 4. 투표
      await postRepo.vote(post.id, newUser.id, VoteOption.a);
      
      // 5. 검증
      final userPosts = await postRepo.getUserPosts(newUser.id);
      expect(userPosts.length, equals(1));
      expect(userPosts.first.votesA, equals(1));
      
      // 6. 정리
      await postRepo.deletePost(post.id);
      await userRepo.deleteUser(newUser.id);
    });
  });
}
```

## 📊 커버리지 측정

### 1. 커버리지 설정
```yaml
# coverage_options.yaml
include:
  - lib/backend/repositories/**
exclude:
  - **/*.g.dart
  - **/*.freezed.dart
  - **/mock_*.dart
minimum_coverage: 85
```

### 2. 커버리지 실행
```bash
# 테스트 실행 및 커버리지 생성
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 커버리지 확인
open coverage/html/index.html
```

### 3. CI/CD 통합
```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          fail_ci_if_error: true
          verbose: true
      
      - name: Check minimum coverage
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$COVERAGE < 85" | bc -l) )); then
            echo "Coverage $COVERAGE% is below minimum 85%"
            exit 1
          fi
```

## 🐛 디버깅 전략

### 1. 테스트 디버깅
```dart
// 상세 로그 활성화
void main() {
  setUp(() {
    Logger.level = Level.verbose;
  });
  
  test('debug test', () async {
    // 중단점 설정
    debugger();
    
    // 상태 출력
    print('Current state: $state');
    
    // Mock 호출 확인
    verify(mock.method()).called(1);
    verifyInOrder([
      mock.method1(),
      mock.method2(),
    ]);
  });
}
```

### 2. Mock 검증
```dart
// Mock 동작 검증
test('verify mock behavior', () {
  // Setup
  when(mock.method(any))
      .thenReturn('default');
  when(mock.method('specific'))
      .thenReturn('special');
  
  // Verify
  expect(mock.method('test'), equals('default'));
  expect(mock.method('specific'), equals('special'));
  
  // 호출 순서 검증
  verifyInOrder([
    mock.method('test'),
    mock.method('specific'),
  ]);
  
  // 호출되지 않은 메서드 확인
  verifyNever(mock.otherMethod());
});
```

## 📈 성능 테스트

### 1. 벤치마크 테스트
```dart
// test/backend/repositories/performance/benchmark_test.dart
void main() {
  group('Performance Benchmarks', () {
    test('getUser performance', () async {
      final repository = createTestRepository();
      
      // Warm up
      for (var i = 0; i < 10; i++) {
        await repository.getUser('test$i');
      }
      
      // Measure
      final stopwatch = Stopwatch()..start();
      const iterations = 1000;
      
      for (var i = 0; i < iterations; i++) {
        await repository.getUser('test${i % 10}');
      }
      
      stopwatch.stop();
      
      final avgTime = stopwatch.elapsedMicroseconds / iterations;
      print('Average time: ${avgTime}μs');
      
      // Assert
      expect(avgTime, lessThan(1000)); // < 1ms
    });
  });
}
```

## ✅ 테스트 체크리스트

### Unit Tests
- [ ] 모든 Repository 메서드 테스트
- [ ] 성공 케이스 테스트
- [ ] 실패 케이스 테스트
- [ ] 엣지 케이스 테스트
- [ ] Exception 처리 테스트

### Integration Tests
- [ ] Firebase 연동 테스트
- [ ] 캐시 동작 테스트
- [ ] 트랜잭션 테스트
- [ ] 동시성 테스트

### E2E Tests
- [ ] 사용자 시나리오 테스트
- [ ] 성능 요구사항 테스트
- [ ] 실제 워크플로우 테스트

### Coverage
- [ ] 85% 이상 커버리지
- [ ] CI/CD 통합
- [ ] 커버리지 리포트 생성

## 📚 참고 문서

- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Firebase Test Lab](https://firebase.google.com/docs/test-lab)
- [Test Coverage Best Practices](https://dart.dev/guides/testing)

---

*이 문서는 Backend Repositories 레이어의 완벽한 테스트 전략을 제공합니다.*  
*85% 이상의 테스트 커버리지로 안정적이고 신뢰할 수 있는 Repository 시스템을 구축합니다.*