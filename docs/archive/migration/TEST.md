# 🧪 Backend 레이어 통합 테스트 가이드

> 전체 Backend 레이어 통합 테스트 전략 및 실행 계획  
> 작성일: 2025-08-28 | 목표 커버리지: 85%+

## 📋 전체 테스트 범위

### 테스트 대상 디렉토리
| 디렉토리 | 파일 수 | 목표 커버리지 | 현재 | 우선순위 |
|----------|---------|--------------|------|---------|
| **repositories** | 4 | 95% | 0% | Critical |
| **models** | 30+ | 90% | 0% | Critical |
| **firebase** | 8 | 85% | 0% | High |
| **api** | 3 | 85% | 0% | Medium |
| **algolia** | 2 | 85% | 0% | Medium |

### 테스트 타입
- **단위 테스트**: Repository 메서드, 모델 직렬화 (50%)
- **통합 테스트**: Repository + Firebase (25%)
- **Mock 테스트**: 외부 의존성 격리 (20%)
- **E2E 테스트**: 전체 데이터 플로우 (5%)

## 🎯 마이그레이션과 동기화된 테스트 전략

### Week 1: Repository 테스트 기반 구축 (20% 커버리지)
- **Day 2**: Repository 인터페이스 테스트 작성
- **Day 3**: Mock 시스템 구축
- **Day 4-5**: UserRepository 테스트 작성

### Week 2: Core Repository 테스트 (50% 커버리지)
- **Day 1**: UserRepository 통합 테스트
- **Day 2-4**: PostRepository 테스트 작성
- **Day 5**: ChatRepository 테스트 시작

### Week 3: 나머지 Repository 및 Models (70% 커버리지)
- **Day 1-2**: ChatRepository 테스트 완성
- **Day 3-4**: MediaRepository 테스트
- **Day 5**: Models 테스트 시작

### Week 4: 통합 테스트 및 완성 (85% 커버리지)
- **Day 1**: Models 테스트 완성
- **Day 2-3**: API/Algolia 테스트
- **Day 4-5**: E2E 통합 테스트

## 📝 테스트 디렉토리 구조

```
test/backend/
├── repositories/               # Repository 테스트
│   ├── user_repository_test.dart
│   ├── post_repository_test.dart
│   ├── chat_repository_test.dart
│   ├── media_repository_test.dart
│   └── mocks/
│       ├── mock_firebase.dart
│       ├── mock_cache_service.dart
│       └── mock_mappers.dart
│
├── models/                     # 모델 테스트
│   ├── user/
│   │   ├── users_model_test.dart
│   │   └── settings_model_test.dart
│   ├── post/
│   │   ├── posts_model_test.dart
│   │   └── comments_model_test.dart
│   ├── chat/
│   │   └── messages_model_test.dart
│   └── serialization/
│       └── serialization_test.dart
│
├── firebase/                   # Firebase 테스트
│   ├── firestore_util_test.dart
│   ├── schema_util_test.dart
│   └── security_rules_test.dart
│
├── api/                        # API 테스트
│   ├── api_manager_test.dart
│   ├── serializers_test.dart
│   └── mock_api_responses.dart
│
├── algolia/                    # Algolia 테스트
│   ├── algolia_search_test.dart
│   └── mock_algolia.dart
│
├── integration/                # 통합 테스트
│   ├── repository_integration_test.dart
│   ├── cache_integration_test.dart
│   └── firebase_integration_test.dart
│
├── e2e/                        # E2E 테스트
│   ├── user_flow_test.dart
│   ├── post_flow_test.dart
│   └── chat_flow_test.dart
│
└── helpers/                    # 테스트 헬퍼
    ├── test_data.dart
    ├── firebase_test_helper.dart
    ├── mock_factory.dart
    └── test_utils.dart
```

## 🧪 Repository 테스트 시나리오

### 1. UserRepository 테스트
```dart
// test/backend/repositories/user_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/backend/repositories/user_repository.dart';
import '../helpers/test_data.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  UnifiedCacheService,
])
void main() {
  late UserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockUnifiedCacheService mockCache;
  late UserMapper mapper;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCache = MockUnifiedCacheService();
    mapper = UserMapper();
    
    repository = UserRepository(
      firestore: mockFirestore,
      cache: mockCache,
      mapper: mapper,
    );
  });

  group('UserRepository - getUser', () {
    test('캐시에 사용자가 있으면 캐시에서 반환해야 함', () async {
      // Given
      const userId = 'test_user_123';
      final cachedUser = TestData.createUser(id: userId);
      
      when(mockCache.get<User>('user_$userId'))
          .thenAnswer((_) async => cachedUser);
      
      // When
      final result = await repository.getUser(userId);
      
      // Then
      expect(result, equals(cachedUser));
      verifyNever(mockFirestore.collection(any));
      verify(mockCache.get<User>('user_$userId')).called(1);
    });
    
    test('캐시에 없으면 Firestore에서 조회해야 함', () async {
      // Given
      const userId = 'test_user_123';
      final firestoreUser = TestData.createUserMap(id: userId);
      
      when(mockCache.get<User>('user_$userId'))
          .thenAnswer((_) async => null);
      
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(userId)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn(firestoreUser);
      
      // When
      final result = await repository.getUser(userId);
      
      // Then
      expect(result?.id, equals(userId));
      verify(mockFirestore.collection('users')).called(1);
      verify(mockCache.set('user_$userId', any, ttl: any)).called(1);
    });
    
    test('사용자가 존재하지 않으면 null을 반환해야 함', () async {
      // Given
      const userId = 'non_existent_user';
      
      when(mockCache.get<User>('user_$userId'))
          .thenAnswer((_) async => null);
      
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(userId)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.exists).thenReturn(false);
      
      // When
      final result = await repository.getUser(userId);
      
      // Then
      expect(result, isNull);
      verifyNever(mockCache.set(any, any));
    });
    
    test('Firebase 에러가 발생하면 RepositoryException을 throw해야 함', () async {
      // Given
      const userId = 'test_user_123';
      
      when(mockCache.get<User>('user_$userId'))
          .thenAnswer((_) async => null);
      
      when(mockFirestore.collection('users'))
          .thenThrow(FirebaseException(
            plugin: 'firestore',
            code: 'permission-denied',
            message: 'Permission denied',
          ));
      
      // When & Then
      expect(
        () async => await repository.getUser(userId),
        throwsA(isA<RepositoryException>()),
      );
    });
  });
  
  group('UserRepository - createUser', () {
    test('새 사용자를 성공적으로 생성해야 함', () async {
      // Given
      final newUser = TestData.createUser();
      
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(newUser.id)).thenReturn(mockDoc);
      when(mockDoc.set(any)).thenAnswer((_) async {});
      
      // When
      await repository.createUser(newUser);
      
      // Then
      verify(mockDoc.set(any)).called(1);
      verify(mockCache.invalidate('user_${newUser.id}')).called(1);
    });
  });
  
  group('UserRepository - watchUser', () {
    test('사용자 변경사항을 스트림으로 제공해야 함', () async {
      // Given
      const userId = 'test_user_123';
      final userData1 = TestData.createUserMap(id: userId, name: 'User 1');
      final userData2 = TestData.createUserMap(id: userId, name: 'User 2');
      
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockDoc = MockDocumentReference<Map<String, dynamic>>();
      final mockSnapshot1 = MockDocumentSnapshot<Map<String, dynamic>>();
      final mockSnapshot2 = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockFirestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc(userId)).thenReturn(mockDoc);
      
      when(mockSnapshot1.exists).thenReturn(true);
      when(mockSnapshot1.data()).thenReturn(userData1);
      when(mockSnapshot2.exists).thenReturn(true);
      when(mockSnapshot2.data()).thenReturn(userData2);
      
      when(mockDoc.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockSnapshot1, mockSnapshot2]),
      );
      
      // When
      final stream = repository.watchUser(userId);
      
      // Then
      await expectLater(
        stream,
        emitsInOrder([
          predicate<User>((u) => u.displayName == 'User 1'),
          predicate<User>((u) => u.displayName == 'User 2'),
        ]),
      );
    });
  });
});
```

### 2. PostRepository 테스트
```dart
// test/backend/repositories/post_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('PostRepository - getFeedPosts', () {
    test('페이지네이션이 올바르게 작동해야 함', () async {
      // Given
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockQuery = MockQuery<Map<String, dynamic>>();
      final mockSnapshot = MockQuerySnapshot<Map<String, dynamic>>();
      
      final posts = List.generate(
        20,
        (i) => TestData.createPostMap(id: 'post_$i'),
      );
      
      final mockDocs = posts.map((data) {
        final doc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn(data['id'] as String);
        return doc;
      }).toList();
      
      when(mockFirestore.collection('posts')).thenReturn(mockCollection);
      when(mockCollection.orderBy('createdAt', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(20)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.docs).thenReturn(mockDocs);
      
      // When
      final result = await repository.getFeedPosts(limit: 20);
      
      // Then
      expect(result.length, equals(20));
      expect(result.first.id, equals('post_0'));
    });
    
    test('투표 상태가 올바르게 매핑되어야 함', () async {
      // Given
      final postWithVotes = TestData.createPostMap(
        id: 'post_with_votes',
        votesA: 10,
        votesB: 15,
        voteStatus: 'completed',
      );
      
      // Setup mocks...
      
      // When
      final result = await repository.getPost('post_with_votes');
      
      // Then
      expect(result?.votesA, equals(10));
      expect(result?.votesB, equals(15));
      expect(result?.voteStatus, equals(VoteStatus.completed));
    });
  });
  
  group('PostRepository - vote', () {
    test('중복 투표를 방지해야 함', () async {
      // Given
      const postId = 'post_123';
      const userId = 'user_456';
      
      // 이미 투표한 상태 시뮬레이션
      final mockVotesCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockVoteDoc = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockVoteDoc.exists).thenReturn(true); // 이미 투표함
      
      // When & Then
      expect(
        () async => await repository.vote(postId, userId, VoteOption.A),
        throwsA(
          isA<RepositoryException>().having(
            (e) => e.code,
            'code',
            'already-voted',
          ),
        ),
      );
    });
    
    test('투표가 성공적으로 처리되어야 함', () async {
      // Given
      const postId = 'post_123';
      const userId = 'user_456';
      
      // 투표하지 않은 상태 시뮬레이션
      final mockVotesCollection = MockCollectionReference<Map<String, dynamic>>();
      final mockVoteDoc = MockDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockVoteDoc.exists).thenReturn(false); // 투표 안 함
      
      // When
      await repository.vote(postId, userId, VoteOption.A);
      
      // Then
      verify(mockFirestore.runTransaction(any)).called(1);
    });
  });
});
```

### 3. Models 테스트
```dart
// test/backend/models/serialization/serialization_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsersModel Serialization', () {
    test('fromMap이 올바르게 파싱해야 함', () {
      // Given
      final map = {
        'uid': 'user_123',
        'email': 'test@example.com',
        'displayName': 'Test User',
        'photoUrl': 'https://example.com/photo.jpg',
        'createdTime': Timestamp.now(),
        'pointsA': 100,
        'pointsQ': 50,
        'role': 'user',
      };
      
      // When
      final user = UsersModel.fromMap(map);
      
      // Then
      expect(user.uid, equals('user_123'));
      expect(user.email, equals('test@example.com'));
      expect(user.displayName, equals('Test User'));
      expect(user.pointsA, equals(100));
      expect(user.pointsQ, equals(50));
      expect(user.role, equals('user'));
    });
    
    test('toMap이 올바르게 직렬화해야 함', () {
      // Given
      final user = UsersModel(
        uid: 'user_123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      
      // When
      final map = user.toMap();
      
      // Then
      expect(map['uid'], equals('user_123'));
      expect(map['email'], equals('test@example.com'));
      expect(map['displayName'], equals('Test User'));
      expect(map.containsKey('createdTime'), isTrue);
    });
    
    test('nullable 필드가 올바르게 처리되어야 함', () {
      // Given
      final map = {
        'uid': 'user_123',
        'email': null,
        'displayName': null,
        'photoUrl': null,
      };
      
      // When
      final user = UsersModel.fromMap(map);
      
      // Then
      expect(user.uid, equals('user_123'));
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.photoUrl, isNull);
    });
  });
  
  group('PostsModel Serialization', () {
    test('복잡한 옵션 구조가 올바르게 파싱되어야 함', () {
      // Given
      final map = {
        'postId': 'post_123',
        'optionA': {
          'text': 'Option A',
          'imageUrls': ['url1', 'url2'],
          'aspectRatio': 1.5,
        },
        'optionB': {
          'text': 'Option B',
          'imageUrls': ['url3', 'url4'],
          'aspectRatio': 0.75,
        },
        'votesA': 10,
        'votesB': 15,
        'voteStatus': 'active',
        'voteStartTime': Timestamp.now(),
        'voteEndTime': Timestamp.fromDate(
          DateTime.now().add(Duration(minutes: 10)),
        ),
      };
      
      // When
      final post = PostsModel.fromMap(map);
      
      // Then
      expect(post.postId, equals('post_123'));
      expect(post.optionA['text'], equals('Option A'));
      expect(post.optionA['imageUrls'].length, equals(2));
      expect(post.optionA['aspectRatio'], equals(1.5));
      expect(post.votesA, equals(10));
      expect(post.votesB, equals(15));
      expect(post.voteStatus, equals('active'));
    });
  });
  
  group('MessagesModel Serialization', () {
    test('투표 카드 메시지가 올바르게 파싱되어야 함', () {
      // Given
      final map = {
        'id': 'msg_123',
        'authorId': 'user_456',
        'text': null,
        'createdAt': Timestamp.now(),
        'type': 'vote_card',
        'metadata': {
          'postId': 'post_789',
          'voteOptionAText': 'Option A',
          'voteOptionBText': 'Option B',
          'voteOptionAImages': ['url1'],
          'voteOptionBImages': ['url2'],
          'receiverId': 'user_999',
          'cardStatus': 'pending',
        },
      };
      
      // When
      final message = MessagesModel.fromMap(map);
      
      // Then
      expect(message.id, equals('msg_123'));
      expect(message.type, equals('vote_card'));
      expect(message.metadata?['postId'], equals('post_789'));
      expect(message.metadata?['cardStatus'], equals('pending'));
    });
  });
});
```

### 4. 통합 테스트
```dart
// test/backend/integration/repository_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late UserRepository userRepository;
  late PostRepository postRepository;
  
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });
  
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    
    userRepository = UserRepository(
      firestore: fakeFirestore,
      cache: MockCacheService(),
      mapper: UserMapper(),
    );
    
    postRepository = PostRepository(
      firestore: fakeFirestore,
      cache: MockCacheService(),
      mapper: PostMapper(),
    );
  });
  
  group('Repository Integration', () {
    test('사용자 생성 후 포스트 작성이 가능해야 함', () async {
      // Given - 사용자 생성
      final user = TestData.createUser(
        id: 'user_123',
        displayName: 'Test User',
      );
      
      await userRepository.createUser(user);
      
      // When - 포스트 작성
      final post = TestData.createPost(
        id: 'post_456',
        userId: user.id,
        optionA: {'text': 'Option A'},
        optionB: {'text': 'Option B'},
      );
      
      await postRepository.createPost(post);
      
      // Then - 포스트 조회
      final createdPost = await postRepository.getPost('post_456');
      expect(createdPost?.userId, equals('user_123'));
      expect(createdPost?.optionA['text'], equals('Option A'));
    });
    
    test('투표 후 결과가 실시간으로 업데이트되어야 함', () async {
      // Given - 포스트 생성
      final post = TestData.createPost(id: 'post_vote_test');
      await postRepository.createPost(post);
      
      // When - 여러 사용자가 투표
      await postRepository.vote('post_vote_test', 'user_1', VoteOption.A);
      await postRepository.vote('post_vote_test', 'user_2', VoteOption.B);
      await postRepository.vote('post_vote_test', 'user_3', VoteOption.A);
      
      // Then - 투표 결과 확인
      final updatedPost = await postRepository.getPost('post_vote_test');
      expect(updatedPost?.votesA, equals(2));
      expect(updatedPost?.votesB, equals(1));
    });
  });
}
```

## 🔧 Mock 시스템 설정

### 1. Mock Factory
```dart
// test/backend/helpers/mock_factory.dart
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/services/cache/unified_cache_service.dart';

@GenerateMocks([
  // Firebase
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  QueryDocumentSnapshot,
  WriteBatch,
  Transaction,
  
  // Services
  UnifiedCacheService,
  
  // Mappers
  UserMapper,
  PostMapper,
  MessageMapper,
  
  // Algolia
  AlgoliaClient,
  AlgoliaIndex,
])
void main() {}

// Mock 데이터 생성기
class MockDataGenerator {
  static Map<String, dynamic> createUserData({
    String? id,
    String? email,
    String? displayName,
    int? pointsA,
    int? pointsQ,
  }) {
    return {
      'uid': id ?? 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email ?? 'test@example.com',
      'displayName': displayName ?? 'Test User',
      'pointsA': pointsA ?? 0,
      'pointsQ': pointsQ ?? 0,
      'createdTime': Timestamp.now(),
    };
  }
  
  static Map<String, dynamic> createPostData({
    String? id,
    String? userId,
    Map<String, dynamic>? optionA,
    Map<String, dynamic>? optionB,
  }) {
    return {
      'postId': id ?? 'post_${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId ?? 'user_123',
      'optionA': optionA ?? {'text': 'Option A'},
      'optionB': optionB ?? {'text': 'Option B'},
      'createdAt': Timestamp.now(),
      'votesA': 0,
      'votesB': 0,
    };
  }
}
```

### 2. Firebase Test Helper
```dart
// test/backend/helpers/firebase_test_helper.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class FirebaseTestHelper {
  static FakeFirebaseFirestore createFakeFirestore({
    Map<String, List<Map<String, dynamic>>>? initialData,
  }) {
    final firestore = FakeFirebaseFirestore();
    
    if (initialData != null) {
      initialData.forEach((collection, documents) {
        for (final doc in documents) {
          final id = doc['id'] ?? doc['uid'] ?? doc['postId'];
          if (id != null) {
            firestore.collection(collection).doc(id).set(doc);
          }
        }
      });
    }
    
    return firestore;
  }
  
  static Future<void> seedTestData(FakeFirebaseFirestore firestore) async {
    // 테스트 사용자 생성
    for (int i = 1; i <= 5; i++) {
      await firestore.collection('users').doc('user_$i').set({
        'uid': 'user_$i',
        'email': 'user$i@test.com',
        'displayName': 'User $i',
        'createdTime': Timestamp.now(),
      });
    }
    
    // 테스트 포스트 생성
    for (int i = 1; i <= 10; i++) {
      await firestore.collection('posts').doc('post_$i').set({
        'postId': 'post_$i',
        'userId': 'user_${(i % 5) + 1}',
        'optionA': {'text': 'Option A $i'},
        'optionB': {'text': 'Option B $i'},
        'createdAt': Timestamp.now(),
      });
    }
  }
}
```

## 📊 커버리지 목표 및 측정

### 전체 목표
| 메트릭 | 목표 | 현재 | 차이 |
|-------|------|------|-----|
| **전체 커버리지** | 85% | 0% | -85% |
| **Repositories** | 95% | 0% | -95% |
| **Models** | 90% | 0% | -90% |
| **Firebase** | 85% | 0% | -85% |
| **API/Algolia** | 85% | 0% | -85% |

### 커버리지 측정 명령어
```bash
# 전체 Backend 테스트 실행
flutter test test/backend/ --coverage

# Repository별 테스트
flutter test test/backend/repositories/ --coverage

# Models 테스트
flutter test test/backend/models/ --coverage

# 통합 테스트
flutter test test/backend/integration/ --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 커버리지 체크
lcov --summary coverage/lcov.info | grep backend
```

## ✅ 테스트 체크리스트

### Week 1
- [ ] UserRepository 인터페이스 테스트
- [ ] UserRepository getUser 테스트
- [ ] UserRepository createUser 테스트
- [ ] UserRepository updateUser 테스트
- [ ] UserRepository watchUser 테스트
- [ ] Mock 시스템 구축

### Week 2
- [ ] PostRepository CRUD 테스트
- [ ] PostRepository 투표 테스트
- [ ] PostRepository 피드 테스트
- [ ] ChatRepository 메시지 테스트
- [ ] ChatRepository 채팅방 테스트

### Week 3
- [ ] MediaRepository 업로드 테스트
- [ ] MediaRepository 다운로드 테스트
- [ ] Models 직렬화 테스트
- [ ] Models 유효성 검사 테스트
- [ ] Firebase 유틸리티 테스트

### Week 4
- [ ] API Manager 테스트
- [ ] Algolia 검색 테스트
- [ ] 통합 테스트 작성
- [ ] E2E 플로우 테스트
- [ ] 성능 테스트

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/backend-test.yml
name: Backend Layer Tests

on:
  pull_request:
    paths:
      - 'lib/backend/**'
      - 'test/backend/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate mocks
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Run Backend tests
        run: flutter test test/backend/ --coverage
      
      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep backend | grep -oP '\d+\.\d+')
          echo "Backend Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 85" | bc -l) )); then
            echo "Coverage is below 85%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          flags: backend
```

## 📚 테스트 원칙

### 1. Repository 테스트 원칙
- **격리**: 외부 의존성은 모두 Mock 처리
- **캐싱**: 캐시 동작을 명시적으로 테스트
- **에러**: 모든 에러 시나리오 커버
- **스트림**: 실시간 업데이트 테스트

### 2. Model 테스트 원칙
- **직렬화**: fromMap/toMap 완벽 테스트
- **타입**: 타입 변환 및 null 처리
- **유효성**: 비즈니스 규칙 검증
- **호환성**: 이전 버전과 호환성

### 3. 통합 테스트 원칙
- **실제 플로우**: 사용자 시나리오 기반
- **트랜잭션**: 복잡한 트랜잭션 테스트
- **동시성**: 동시 접근 시나리오
- **성능**: 응답 시간 측정

## 🔍 문제 해결 가이드

### 자주 발생하는 문제

#### 1. Mock 생성 실패
```dart
// 문제: Cannot mock sealed class
// 해결: @GenerateMocks 대신 수동 Mock 생성
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return super.noSuchMethod(
      Invocation.method(#collection, [collectionPath]),
      returnValue: MockCollectionReference<Map<String, dynamic>>(),
    );
  }
}
```

#### 2. Timestamp 직렬화 문제
```dart
// 문제: Timestamp is not JSON serializable
// 해결: Custom converter 사용
class TimestampConverter {
  static DateTime? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is Timestamp) return json.toDate();
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    return DateTime.parse(json.toString());
  }
  
  static dynamic toJson(DateTime? date) {
    return date?.millisecondsSinceEpoch;
  }
}
```

#### 3. 비동기 스트림 테스트
```dart
// 문제: Stream test timeout
// 해결: expectLater와 emitsInOrder 사용
await expectLater(
  repository.watchUser(userId),
  emitsInOrder([
    isA<User>().having((u) => u.name, 'name', 'Initial'),
    isA<User>().having((u) => u.name, 'name', 'Updated'),
  ]),
);
```

---

*이 문서는 Backend 레이어 전체의 통합 테스트 전략과 실행 계획을 담고 있습니다.*  
*마이그레이션과 동시에 점진적으로 테스트를 구축하여 85% 이상의 커버리지를 달성합니다.*