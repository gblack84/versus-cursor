# 🎯 Backend Layer 상세 문서

> Feature-First Architecture의 데이터 접근 및 비즈니스 로직 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 3.0.0

## 📋 개요

Backend Layer는 Versus Space 애플리케이션의 데이터 접근, 외부 API 통합, 비즈니스 로직을 관리합니다.
Repository Pattern을 통해 데이터 소스를 추상화하고, Clean Architecture를 구현하여 테스트 가능하고 유지보수 가능한 구조를 제공합니다.

## 🚀 마이그레이션 현황

**통합 마이그레이션 문서가 작성되었습니다**: [MIGRATION_BACKEND_ORDER_RULES.md](./MIGRATION_BACKEND_ORDER_RULES.md)

### 마이그레이션 문서 구조
- **통합 규칙 문서**: `MIGRATION_BACKEND_ORDER_RULES.md` - 전체 실행 순서와 규칙
- **Repositories**: `repositories/MIGRATION_Part3.md` - Repository Pattern 구현 (0% → 100%)
- **Models**: `models/MIGRATION_Part3.md` - 데이터 모델 마이그레이션 (15+ 파일)
- **Firebase**: `firebase/MIGRATION_Part3.md` - Firebase 설정 최적화 (8개 파일)
- **API**: `api/MIGRATION_Part3.md` - API 레이어 통합 (3개 파일)
- **Algolia**: `algolia/MIGRATION_Part3.md` - 검색 서비스 개선 (2개 파일)

## 🏗️ 현재 디렉토리 구조

```
lib/backend/
├── repositories/               # 데이터 접근 레이어 (0% 구현)
│   ├── post_repository.dart   # TODO - 게시물 데이터 접근
│   ├── user_repository.dart   # TODO - 사용자 데이터 접근
│   ├── chat_repository.dart   # TODO - 채팅 데이터 접근
│   ├── media_repository.dart  # TODO - 미디어 데이터 접근
│   └── README.md
├── models/                     # 데이터 모델 (60% 구현)
│   ├── user/                  # 사용자 관련 모델
│   ├── post/                  # 게시물 관련 모델
│   ├── chat/                  # 채팅 관련 모델
│   ├── media/                 # 미디어 관련 모델
│   └── ... (15+ 파일)
├── firebase/                   # Firebase 설정 (90% 구현)
│   ├── firestore/             # Firestore 유틸리티
│   └── README.md
├── api/                        # 외부 API 통합 (70% 구현)
│   ├── api_manager.dart       # API 관리자
│   ├── serializers.dart       # 직렬화 도구
│   └── README.md
├── algolia/                    # Algolia 검색 (80% 구현)
│   ├── algolia_manager.dart   # Algolia 관리
│   └── README.md
└── backend.dart               # Export 파일 (1770줄)
```

## 🔍 현재 코드 분석

### 디렉토리별 상태 평가

| 디렉토리 | 파일 수 | 상태 | 우선순위 | 문제점 |
|---------|--------|------|---------|--------|
| **repositories** | 4 | 🔴 미구현 (0%) | Critical | 모든 파일이 TODO |
| **models** | 30+ | 🟡 부분 구현 (60%) | Critical | Feature 분산 필요 |
| **firebase** | 8 | 🟢 거의 완성 (90%) | Medium | 설정 최적화 필요 |
| **api** | 3 | 🟡 진행중 (70%) | Medium | 통합 필요 |
| **algolia** | 2 | 🟢 거의 완성 (80%) | Low | 최적화 필요 |

### 핵심 문제점

#### 1. Repository Pattern 부재 (Critical)
```dart
// 현재: UI에서 직접 Firestore 호출
// home_page_widget.dart
FirebaseFirestore.instance
    .collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();

// 필요: Repository를 통한 접근
final posts = await postRepository.getFeedPosts(limit: 20);
```

#### 2. 캐싱 전략 부재 (High)
- 매번 네트워크 호출로 성능 저하
- 오프라인 지원 불가능
- 불필요한 Firebase 읽기 비용 발생

#### 3. 에러 처리 불일치 (Medium)
```dart
// 각자 다른 에러 처리
try {
  // Firestore 호출
} catch (e) {
  print(e); // 단순 출력
  // 또는
  showSnackbar(e.toString()); // 사용자 혼란
}
```

#### 4. Models 분산 필요 (Medium)
- 중앙 집중식 models 디렉토리
- Feature별 분산 필요
- Backward compatibility 제공 필요

## 🛠️ Feature-First Architecture 개선 방안

### 1. 즉시 개선 필요 (Critical)

#### Repository Pattern 구현
```dart
// lib/features/posts/domain/repositories/i_post_repository.dart
abstract interface class IPostRepository {
  Future<List<Post>> getFeedPosts({
    int limit = 20,
    DocumentSnapshot? startAfter,
  });
  
  Future<Post?> getPost(String postId);
  Future<void> createPost(Post post);
  Future<void> updatePost(Post post);
  Future<void> deletePost(String postId);
  
  Stream<List<Post>> watchFeedPosts();
  Stream<Post> watchPost(String postId);
}

// lib/features/posts/data/repositories/post_repository.dart
@LazySingleton(as: IPostRepository)
class PostRepository implements IPostRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cache;
  final PostMapper _mapper;
  
  PostRepository({
    required FirebaseFirestore firestore,
    required UnifiedCacheService cache,
    required PostMapper mapper,
  }) : _firestore = firestore,
       _cache = cache,
       _mapper = mapper;
  
  @override
  Future<List<Post>> getFeedPosts({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      // 1. 캐시 확인
      final cacheKey = 'feed_posts_$limit';
      final cached = await _cache.get<List<Post>>(cacheKey);
      if (cached != null) return cached;
      
      // 2. Firestore 쿼리
      Query query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.get();
      
      // 3. 매핑 및 캐싱
      final posts = snapshot.docs
          .map((doc) => _mapper.fromFirestore(doc))
          .toList();
      
      await _cache.set(cacheKey, posts, ttl: Duration(minutes: 5));
      
      return posts;
    } on FirebaseException catch (e) {
      throw RepositoryException(
        code: e.code,
        message: e.message ?? 'Failed to fetch posts',
        userMessage: '게시물을 불러올 수 없습니다.',
      );
    }
  }
}
```

#### 캐싱 시스템 통합
```dart
// 3-Layer 캐싱 전략
class UnifiedCacheService {
  // L1: Memory Cache (LRU)
  final _memoryCache = LruCache<String, dynamic>(100);
  
  // L2: Local Storage (Hive)
  late Box _localStorage;
  
  // L3: Firestore Offline
  // Firestore 자체 오프라인 캐시 활용
  
  Future<T?> get<T>(String key) async {
    // L1 체크
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] as T?;
    }
    
    // L2 체크
    final stored = await _localStorage.get(key);
    if (stored != null) {
      _memoryCache[key] = stored;
      return stored as T?;
    }
    
    return null;
  }
  
  Future<void> set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    _memoryCache[key] = value;
    await _localStorage.put(key, value);
    
    // TTL 설정
    Timer(ttl, () => invalidate(key));
  }
}
```

### 2. 중기 개선 사항

#### Models 마이그레이션
```dart
// 현재: 중앙 집중식
lib/backend/models/
├── user/
│   ├── users_model.dart
│   └── settings_model.dart
├── post/
│   ├── posts_model.dart
│   └── comments_model.dart
└── chat/
    └── messages_model.dart

// 개선안: Feature별 분산
lib/features/
├── auth/
│   └── domain/
│       └── models/
│           └── user.dart
├── posts/
│   └── domain/
│       └── models/
│           └── post.dart
└── chat/
    └── domain/
        └── models/
            └── message.dart

// 호환성 유지
// lib/backend/models/user/users_model.dart
@Deprecated('Use User from features/auth/domain/models')
export 'package:versus_space/features/auth/domain/models/user.dart';
```

#### 통합 에러 처리
```dart
// lib/backend/exceptions/repository_exception.dart
class RepositoryException implements Exception {
  final String code;
  final String message;
  final String userMessage;
  final dynamic originalError;
  
  const RepositoryException({
    required this.code,
    required this.message,
    required this.userMessage,
    this.originalError,
  });
  
  factory RepositoryException.fromFirebase(FirebaseException e) {
    return RepositoryException(
      code: e.code,
      message: e.message ?? 'Unknown error',
      userMessage: _getUserMessage(e.code),
      originalError: e,
    );
  }
  
  static String _getUserMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return '권한이 없습니다.';
      case 'unavailable':
        return '서버에 연결할 수 없습니다.';
      default:
        return '오류가 발생했습니다. 다시 시도해주세요.';
    }
  }
}
```

### 3. 파일 이동 계획

#### Feature별 분산
| 현재 위치 | 이동 대상 | 이유 |
|---------|----------|------|
| `backend/models/user/users_model.dart` | `features/auth/domain/models/` | Auth Feature 소유 |
| `backend/models/post/posts_model.dart` | `features/posts/domain/models/` | Posts Feature 소유 |
| `backend/models/chat/messages_model.dart` | `features/chat/domain/models/` | Chat Feature 소유 |
| 기타 모델들 | 각 Feature domain/models/ | 소유권 명확화 |

## 📊 현재 상태 평가

### 강점
- ✅ Firebase 설정 완성 (90%)
- ✅ Algolia 검색 구현 (80%)
- ✅ 기본 모델 정의 완료
- ✅ backend.dart에 모든 Query 함수 구현

### 약점
- ❌ Repository Pattern 0% 구현
- ❌ 직접 Firestore 호출 남발
- ❌ 캐싱 전략 부재
- ❌ 테스트 커버리지 0%

### 기회
- 🔄 Repository Pattern으로 테스트 가능성 향상
- 🔄 캐싱으로 성능 50% 개선 가능
- 🔄 에러 처리 통일로 사용자 경험 개선
- 🔄 오프라인 지원 구현 가능

### 위협
- ⚠️ 현재 코드베이스가 직접 호출에 의존
- ⚠️ 마이그레이션 중 Breaking Changes 위험
- ⚠️ 테스트 없이 리팩토링 시 버그 발생 가능

## 🎯 마이그레이션 액션 플랜

### 전체 일정: 4주

#### Week 1: Repository 인터페이스 및 UserRepository
- **Day 1**: 백업 및 준비
- **Day 2-3**: 인터페이스 정의
- **Day 4-5**: UserRepository 구현

#### Week 2: Post & Chat Repository
- **Day 1**: UserRepository 완성
- **Day 2-4**: PostRepository 구현
- **Day 5**: ChatRepository 시작

#### Week 3: Media Repository & Models
- **Day 1-2**: ChatRepository 완성
- **Day 3-4**: MediaRepository 구현
- **Day 5**: Models 마이그레이션 시작

#### Week 4: 정리 및 최적화
- **Day 1**: Models 마이그레이션 완성
- **Day 2-3**: API & Firebase 최적화
- **Day 4-5**: 통합 테스트 및 문서화

### 상세 실행 계획은 [MIGRATION_BACKEND_ORDER_RULES.md](./MIGRATION_BACKEND_ORDER_RULES.md) 참조

## 📝 코드 예시

### Repository 사용 예시
```dart
// lib/features/posts/presentation/screens/home_page.dart
class HomePageWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postRepository = ref.watch(postRepositoryProvider);
    
    return FutureBuilder<List<Post>>(
      future: postRepository.getFeedPosts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // 구조화된 에러 처리
          final error = snapshot.error as RepositoryException;
          return ErrorWidget(message: error.userMessage);
        }
        
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final post = snapshot.data![index];
              return PostCard(post: post);
            },
          );
        }
        
        return LoadingIndicator();
      },
    );
  }
}
```

### 테스트 예시
```dart
// test/features/posts/data/repositories/post_repository_test.dart
@GenerateMocks([FirebaseFirestore, UnifiedCacheService, PostMapper])
void main() {
  late PostRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockUnifiedCacheService mockCache;
  late MockPostMapper mockMapper;
  
  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCache = MockUnifiedCacheService();
    mockMapper = MockPostMapper();
    
    repository = PostRepository(
      firestore: mockFirestore,
      cache: mockCache,
      mapper: mockMapper,
    );
  });
  
  group('getFeedPosts', () {
    test('should return posts from cache when available', () async {
      // Given
      final cachedPosts = [testPost1, testPost2];
      when(mockCache.get<List<Post>>('feed_posts_20'))
          .thenAnswer((_) async => cachedPosts);
      
      // When
      final posts = await repository.getFeedPosts();
      
      // Then
      expect(posts, equals(cachedPosts));
      verifyNever(mockFirestore.collection(any));
    });
    
    test('should fetch from Firestore when cache is empty', () async {
      // Given
      when(mockCache.get<List<Post>>('feed_posts_20'))
          .thenAnswer((_) async => null);
      
      // Setup Firestore mock
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();
      when(mockFirestore.collection('posts')).thenReturn(mockCollection);
      
      // When
      final posts = await repository.getFeedPosts();
      
      // Then
      verify(mockFirestore.collection('posts')).called(1);
      verify(mockCache.set('feed_posts_20', any, ttl: any)).called(1);
    });
  });
}
```

## ⚠️ 마이그레이션 주의사항

### 핵심 원칙
1. **점진적 마이그레이션**: 기능 유지하며 단계별 진행
2. **Backward Compatibility**: 2주간 이전 코드 호환성 유지
3. **테스트 우선**: Repository 구현 전 테스트 작성
4. **문서화**: 모든 변경사항 즉시 문서화
5. **성능 측정**: 캐싱 효과 정량적 측정

### 백업 전략
```bash
# 마이그레이션 시작 전
git checkout -b migration/backend-layer-$(date +%Y%m%d)
git tag -a backup/backend-pre-migration -m "Before backend layer migration"

# 각 Repository별 체크포인트
git tag -a checkpoint/backend-user-repo -m "UserRepository complete"
git tag -a checkpoint/backend-post-repo -m "PostRepository complete"
```

### 상세 규칙은 [MIGRATION_BACKEND_ORDER_RULES.md](./MIGRATION_BACKEND_ORDER_RULES.md) 참조

## 📚 참고 자료

### 마이그레이션 문서
- [통합 마이그레이션 규칙](./MIGRATION_BACKEND_ORDER_RULES.md)
- [Repositories 마이그레이션](./repositories/MIGRATION_Part3.md)
- [Models 마이그레이션](./models/MIGRATION_Part3.md)
- [Firebase 마이그레이션](./firebase/MIGRATION_Part3.md)
- [API 마이그레이션](./api/MIGRATION_Part3.md)
- [Algolia 마이그레이션](./algolia/MIGRATION_Part3.md)

### 테스트 문서
- [Backend 통합 테스트](./TEST.md)
- [Repositories 테스트](./repositories/TEST.md)
- [Models 테스트](./models/TEST.md)
- [Firebase 테스트](./firebase/TEST.md)
- [API 테스트](./api/TEST.md)
- [Algolia 테스트](./algolia/TEST.md)

### 아키텍처 문서
- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)
- [Clean Architecture Guide](/CLEAN_ARCHITECTURE.md)
- [Core Layer Documentation](/lib/core/README.md)

---

*이 문서는 Backend Layer의 현재 상태와 마이그레이션 계획을 담고 있습니다.*
*마지막 업데이트: 2025-08-28*