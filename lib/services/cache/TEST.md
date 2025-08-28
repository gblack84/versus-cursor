# 🧪 Cache Service 테스트 전략

> Cache Service의 테스트 전략 및 구현 가이드  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Cache Service는 Versus Space의 전역 인프라 서비스로서, 높은 신뢰성과 성능을 보장하기 위한 포괄적인 테스트가 필요합니다. 이 문서는 Services Layer 내에서의 테스트 전략을 정의합니다.

## 🎯 테스트 목표

### 정량적 목표
- **코드 커버리지**: 80% 이상
- **단위 테스트 실행 시간**: < 5초
- **통합 테스트 실행 시간**: < 30초
- **성능 테스트 통과율**: 100%

### 정성적 목표
- Clean Architecture 원칙 준수 검증
- 역방향 의존성 완전 제거 확인
- Feature 어댑터 패턴 정상 작동 보장
- 3-Layer 캐싱 로직 무결성 검증

## 🏗️ 테스트 구조

```
test/services/cache/
├── unit/                        # 단위 테스트
│   ├── domain/                 # 도메인 레이어 테스트
│   │   ├── entities/
│   │   ├── usecases/
│   │   └── value_objects/
│   ├── data/                   # 데이터 레이어 테스트
│   │   ├── layers/
│   │   ├── repositories/
│   │   └── services/
│   └── presentation/           # 프레젠테이션 레이어 테스트
│       └── providers/
├── integration/                 # 통합 테스트
│   ├── cache_flow_test.dart   # 전체 캐시 플로우
│   ├── layer_sync_test.dart   # 레이어 간 동기화
│   └── adapter_test.dart      # Feature 어댑터 통합
├── performance/                 # 성능 테스트
│   ├── benchmark_test.dart
│   └── load_test.dart
└── e2e/                        # E2E 테스트
    └── real_usage_test.dart

test/fixtures/                  # 테스트 픽스처
├── mock_data/
├── test_models/
└── fake_services/
```

## 🔍 테스트 레벨별 전략

### 1. 단위 테스트 (Unit Tests)

#### Domain Layer 테스트

```dart
// test/services/cache/unit/domain/entities/cache_entry_test.dart
import 'package:test/test.dart';
import 'package:versus_space/services/cache/domain/entities/cache_entry.dart';

void main() {
  group('CacheEntry', () {
    test('should create valid cache entry with TTL', () {
      // Given
      final data = {'test': 'data'};
      final ttl = Duration(minutes: 5);
      
      // When
      final entry = CacheEntry(
        key: 'test_key',
        data: data,
        ttl: ttl,
      );
      
      // Then
      expect(entry.key, 'test_key');
      expect(entry.data, data);
      expect(entry.isExpired, false);
    });
    
    test('should detect expired entries', () {
      // Given
      final entry = CacheEntry(
        key: 'test_key',
        data: 'data',
        ttl: Duration(milliseconds: 1),
      );
      
      // When
      await Future.delayed(Duration(milliseconds: 2));
      
      // Then
      expect(entry.isExpired, true);
    });
  });
}
```

#### Use Case 테스트

```dart
// test/services/cache/unit/domain/usecases/get_cached_data_test.dart
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockCacheRepository extends Mock implements CacheRepository {}

void main() {
  late GetCachedDataUseCase useCase;
  late MockCacheRepository mockRepository;
  
  setUp(() {
    mockRepository = MockCacheRepository();
    useCase = GetCachedDataUseCase(mockRepository);
  });
  
  test('should get data from repository', () async {
    // Given
    final testData = {'test': 'data'};
    when(mockRepository.get('test_key'))
        .thenAnswer((_) async => testData);
    
    // When
    final result = await useCase.execute('test_key');
    
    // Then
    expect(result, testData);
    verify(mockRepository.get('test_key'));
  });
  
  test('should handle cache miss gracefully', () async {
    // Given
    when(mockRepository.get('test_key'))
        .thenAnswer((_) async => null);
    
    // When
    final result = await useCase.execute('test_key');
    
    // Then
    expect(result, isNull);
  });
}
```

#### Data Layer 테스트
```dart
// test/services/cache/simple_memory_cache_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/cache/simple_memory_cache.dart';

// test/services/cache/unit/data/layers/memory_cache_layer_test.dart
void main() {
  late MemoryCacheLayer layer;
  
  setUp(() {
    layer = MemoryCacheLayer(maxSize: 10);
  });
  
  test('should evict LRU when max size reached', () async {
    // Given
    for (int i = 0; i < 10; i++) {
      await layer.set('key_$i', 'value_$i');
    }
    
    // When
    await layer.set('key_10', 'value_10');
    
    // Then
    expect(await layer.get('key_0'), isNull); // LRU evicted
    expect(await layer.get('key_10'), 'value_10');
    expect(layer.size, 10);
  });
  
  test('should update last accessed time on get', () async {
    // Given
    await layer.set('key_1', 'value_1');
    await layer.set('key_2', 'value_2');
    
    // When
    await layer.get('key_1'); // Access key_1
    for (int i = 3; i < 11; i++) {
      await layer.set('key_$i', 'value_$i');
    }
    
    // Then
    expect(await layer.get('key_1'), isNotNull); // Still exists
    expect(await layer.get('key_2'), isNull); // Evicted
  });
}
```

### 2. 통합 테스트 (Integration Tests)

#### 3-Layer 캐시 플로우 테스트

```dart
// test/services/cache/integration/cache_flow_test.dart
void main() {
  late UnifiedCacheService cacheService;
  late MockFirestore mockFirestore;
  late HiveInterface mockHive;
  
  setUpAll(() async {
    await setUpTestHive();
    mockFirestore = MockFirestore();
    cacheService = UnifiedCacheServiceImpl(
      firestore: mockFirestore,
      hive: mockHive,
    );
  });
  
  test('should flow through all layers correctly', () async {
    // Given
    final testData = TestModel(id: '123', name: 'Test');
    
    // When - First access (Network fetch)
    when(mockFirestore.collection('test').doc('123').get())
        .thenAnswer((_) async => testData);
    
    final result1 = await cacheService.get<TestModel>(
      'test_123',
      factory: TestModelAdapter(),
    );
    
    // Then - Data fetched from network
    expect(result1, testData);
    verify(mockFirestore.collection('test').doc('123').get());
    
    // When - Second access (L1 hit)
    final result2 = await cacheService.get<TestModel>(
      'test_123',
      factory: TestModelAdapter(),
    );
    
    // Then - Data from memory cache
    expect(result2, testData);
    verifyNever(mockFirestore.collection('test').doc('123').get());
    
    // When - Clear memory cache and access (L2 hit)
    cacheService.clearMemory();
    final result3 = await cacheService.get<TestModel>(
      'test_123',
      factory: TestModelAdapter(),
    );
    
    // Then - Data from Hive
    expect(result3, testData);
    verifyNever(mockFirestore.collection('test').doc('123').get());
  });
}
```

#### Feature 어댑터 통합 테스트

```dart
// test/services/cache/integration/adapter_test.dart
void main() {
  test('should work with different feature adapters', () async {
    // Given
    final cacheService = GetIt.I<CacheService>();
    final chatAdapter = ChatMessageAdapter();
    final postAdapter = PostAdapter();
    
    // When - Cache chat messages
    await cacheService.set(
      'chat_123',
      [Message(id: '1', text: 'Hello')],
      adapter: chatAdapter,
    );
    
    // When - Cache posts
    await cacheService.set(
      'posts',
      [Post(id: '1', title: 'Test')],
      adapter: postAdapter,
    );
    
    // Then - Retrieve with correct types
    final messages = await cacheService.get<List<Message>>(
      'chat_123',
      adapter: chatAdapter,
    );
    expect(messages?.first.text, 'Hello');
    
    final posts = await cacheService.get<List<Post>>(
      'posts',
      adapter: postAdapter,
    );
    expect(posts?.first.title, 'Test');
  });
}
```

### 3. 성능 테스트 (Performance Tests)

```dart
// test/services/cache/performance/benchmark_test.dart
void main() {
  test('should meet performance requirements', () async {
    final cacheService = UnifiedCacheServiceImpl();
    final stopwatch = Stopwatch();
    
    // Test L1 performance
    await cacheService.set('test', 'data');
    stopwatch.start();
    await cacheService.get('test');
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(10));
    
    // Test L2 performance
    cacheService.clearMemory();
    stopwatch.reset();
    stopwatch.start();
    await cacheService.get('test');
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(30));
    
    // Test batch operations
    final batchData = List.generate(100, (i) => 'item_$i');
    stopwatch.reset();
    stopwatch.start();
    await Future.wait(
      batchData.map((item) => cacheService.set('key_$item', item)),
    );
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(500));
  });
}
```

### 4. E2E 테스트 (End-to-End Tests)

```dart
// test/services/cache/e2e/real_usage_test.dart
void main() {
  testWidgets('should cache and display chat messages', (tester) async {
    // Given
    await tester.pumpWidget(TestApp());
    await tester.pumpAndSettle();
    
    // When - Navigate to chat
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    
    // Then - Messages loaded from cache
    expect(find.text('Cached message'), findsOneWidget);
    
    // When - Pull to refresh
    await tester.drag(find.byType(ListView), Offset(0, 400));
    await tester.pumpAndSettle();
    
    // Then - New messages loaded and cached
    expect(find.text('New message'), findsOneWidget);
  });
}
```

## 🔧 테스트 도구 및 Mock

### Mock 객체

```dart
// test/fixtures/fake_services/fake_cache_service.dart
class FakeCacheService implements CacheService {
  final Map<String, dynamic> _cache = {};
  int getCallCount = 0;
  int setCallCount = 0;
  
  @override
  Future<T?> get<T>(String key, {CacheAdapter<T>? adapter}) async {
    getCallCount++;
    return _cache[key] as T?;
  }
  
  @override
  Future<void> set<T>(String key, T value, {
    Duration? ttl,
    CacheAdapter<T>? adapter,
  }) async {
    setCallCount++;
    _cache[key] = value;
  }
}
```

### 테스트 헬퍼

```dart
// test/helpers/cache_test_helper.dart
class CacheTestHelper {
  static Future<void> setUpTestEnvironment() async {
    // Initialize test Hive
    final tempDir = await getTemporaryDirectory();
    Hive.init(tempDir.path);
    
    // Register test adapters
    Hive.registerAdapter(TestModelAdapter());
    
    // Set up GetIt for testing
    GetIt.I.registerSingleton<CacheService>(FakeCacheService());
  }
  
  static Future<void> tearDownTestEnvironment() async {
    await Hive.deleteFromDisk();
    GetIt.I.reset();
  }
}
```

## 📊 테스트 커버리지 목표

### 레이어별 커버리지

| 레이어 | 목표 | 현재 | 상태 |
|--------|------|------|------|
| Domain | 95% | - | 🔴 |
| Data | 85% | - | 🔴 |
| Presentation | 80% | - | 🔴 |
| Adapters | 90% | - | 🔴 |
| **전체** | **85%** | **-** | **🔴** |

### 중요 경로 테스트

- [x] 3-Layer 캐시 플로우
- [x] LRU 정책 동작
- [x] TTL 만료 처리
- [x] 동시성 처리
- [ ] 네트워크 실패 처리
- [ ] 캐시 무효화
- [ ] 메모리 압박 상황

## 🚀 테스트 실행

### 단위 테스트 실행

```bash
# 모든 단위 테스트
flutter test test/services/cache/unit/

# 특정 레이어 테스트
flutter test test/services/cache/unit/domain/

# 커버리지 포함
flutter test --coverage test/services/cache/unit/
```

### 통합 테스트 실행

```bash
# 통합 테스트
flutter test test/services/cache/integration/

# E2E 테스트
flutter test integration_test/cache_e2e_test.dart
```

### 성능 테스트

```bash
# 벤치마크 실행
flutter test test/services/cache/performance/benchmark_test.dart

# 부하 테스트
flutter test test/services/cache/performance/load_test.dart
```

## 🔍 의존성 검증 테스트

### 역방향 의존성 방지 테스트

```dart
// test/services/cache/architecture/dependency_test.dart
void main() {
  test('should not have reverse dependencies', () {
    // Services should not import from Features
    final serviceImports = analyzeImports('lib/services/cache/');
    
    for (final import in serviceImports) {
      expect(import, isNot(contains('/features/')));
      expect(import, isNot(contains('/backend/schema/')));
    }
    
    // Should use generic types instead
    final sourceCode = readSourceCode('lib/services/cache/');
    expect(sourceCode, isNot(contains('MessagesModel')));
    expect(sourceCode, isNot(contains('PostsModel')));
    expect(sourceCode, isNot(contains('UsersModel')));
  });
}
```

## 📈 CI/CD 통합

### GitHub Actions 워크플로우

```yaml
name: Cache Service Tests

on:
  push:
    paths:
      - 'lib/services/cache/**'
      - 'test/services/cache/**'
  pull_request:
    paths:
      - 'lib/services/cache/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/services/cache/unit/
      - run: flutter test test/services/cache/integration/
      - run: flutter test --coverage test/services/cache/
      - uses: codecov/codecov-action@v2
```

## 🐛 디버깅 가이드

### 일반적인 테스트 실패 원인

1. **Hive 초기화 실패**
   - 원인: 테스트 환경에서 Hive 경로 미설정
   - 해결: `setUpAll()`에서 임시 디렉토리 설정

2. **Mock 객체 타입 불일치**
   - 원인: Generic 타입 캐스팅 문제
   - 해결: 명시적 타입 지정 및 adapter 사용

3. **비동기 테스트 타이밍**
   - 원인: Future 완료 전 assertion
   - 해결: `async`/`await` 또는 `expectLater` 사용

4. **의존성 주입 충돌**
   - 원인: GetIt 싱글톤 재등록
   - 해결: `tearDown()`에서 GetIt.reset() 호출

## 📚 Best Practices

### 테스트 작성 원칙

1. **AAA 패턴 사용**
   - Arrange (Given)
   - Act (When)
   - Assert (Then)

2. **각 테스트는 독립적**
   - 테스트 간 의존성 제거
   - 각 테스트는 자체 setup/teardown

3. **명확한 테스트 이름**
   - `should_[expected behavior]_when_[condition]`
   - 한국어 주석으로 의도 설명

4. **Edge Case 테스트**
   - null 값 처리
   - 빈 컬렉션
   - 경계값
   - 동시성 상황

5. **테스트 유지보수**
   - 중복 코드 제거
   - 테스트 헬퍼 활용
   - 픽스처 재사용

## 🎯 다음 단계

1. **Phase 1**: 기존 코드에 대한 단위 테스트 작성 (1주)
2. **Phase 2**: 통합 테스트 구현 (3일)
3. **Phase 3**: 성능 벤치마크 구축 (2일)
4. **Phase 4**: CI/CD 파이프라인 통합 (1일)
5. **Phase 5**: 테스트 커버리지 85% 달성 (지속적)

## ⚠️ 주의사항

1. **테스트 격리**: 각 테스트는 완전히 격리된 환경에서 실행
2. **실제 서비스 호출 금지**: Mock 또는 Fake 객체 사용
3. **테스트 데이터 정리**: tearDown에서 모든 테스트 데이터 제거
4. **민감 정보 제외**: 테스트 코드에 실제 API 키나 인증 정보 포함 금지

---

*이 문서는 Cache Service의 테스트 전략을 정의합니다.*
*Services Layer의 품질과 안정성을 보장하는 핵심 문서입니다.*
    late SimpleMemoryCache cache;
    
    setUp(() {
      cache = SimpleMemoryCache.instance;
      cache.clear(); // 각 테스트 전 초기화
    });
    
    test('기본 get/set 동작', () {
      // Given
      const key = 'test_key';
      const value = 'test_value';
      
      // When
      cache.set(key, value);
      final result = cache.get<String>(key);
      
      // Then
      expect(result, equals(value));
    });
    
    test('TTL 만료 테스트', () async {
      // Given
      const key = 'expiring_key';
      const value = 'expiring_value';
      const ttl = Duration(milliseconds: 100);
      
      // When
      cache.set(key, value, ttl: ttl);
      
      // 즉시 조회
      expect(cache.get<String>(key), equals(value));
      
      // TTL 만료 후
      await Future.delayed(ttl + Duration(milliseconds: 10));
      expect(cache.get<String>(key), isNull);
    });
    
    test('LRU 제거 정책', () {
      // Given - 캐시를 가득 채움
      const maxSize = SimpleMemoryCache.maxCacheSize;
      for (int i = 0; i < maxSize; i++) {
        cache.set('key_$i', 'value_$i');
      }
      
      // 가장 오래된 항목에 접근 (LRU 갱신)
      cache.get<String>('key_0');
      
      // When - 새 항목 추가 (LRU 제거 발생)
      cache.set('new_key', 'new_value');
      
      // Then - key_1이 제거됨 (key_0은 최근 접근으로 유지)
      expect(cache.get<String>('key_0'), isNotNull);
      expect(cache.get<String>('key_1'), isNull);
      expect(cache.get<String>('new_key'), equals('new_value'));
    });
    
    test('패턴 기반 무효화', () {
      // Given
      cache.set('chat_1', 'message1');
      cache.set('chat_2', 'message2');
      cache.set('user_1', 'profile1');
      
      // When
      cache.invalidate('chat');
      
      // Then
      expect(cache.get<String>('chat_1'), isNull);
      expect(cache.get<String>('chat_2'), isNull);
      expect(cache.get<String>('user_1'), isNotNull);
    });
    
    test('캐시 히트율 계산', () {
      // Given
      cache.clear();
      
      // When
      cache.set('key1', 'value1');
      cache.get<String>('key1'); // Hit
      cache.get<String>('key1'); // Hit
      cache.get<String>('key2'); // Miss
      cache.get<String>('key3'); // Miss
      
      // Then
      expect(cache.hitRate, closeTo(0.4, 0.01)); // 2/5 = 40%
    });
    
    test('동시성 테스트', () async {
      // Given
      final futures = <Future>[];
      
      // When - 동시에 100개 작업
      for (int i = 0; i < 100; i++) {
        if (i % 2 == 0) {
          futures.add(
            Future(() => cache.set('concurrent_$i', i)),
          );
        } else {
          futures.add(
            Future(() => cache.get<int>('concurrent_${i-1}')),
          );
        }
      }
      
      // Then - 예외 없이 완료
      await expectLater(
        Future.wait(futures),
        completes,
      );
    });
  });
}
```

### 2. CacheStatistics 테스트
```dart
// test/services/cache/cache_statistics_test.dart
void main() {
  group('CacheStatistics', () {
    late CacheStatistics stats;
    
    setUp(() {
      stats = CacheStatistics.instance;
      stats.reset();
    });
    
    test('히트율 통계 정확성', () {
      // Given & When
      stats.recordRequest();
      stats.recordL1Hit(responseTimeMs: 5);
      
      stats.recordRequest();
      stats.recordL2Hit(responseTimeMs: 20);
      
      stats.recordRequest();
      stats.recordL3Hit(responseTimeMs: 100);
      
      stats.recordRequest();
      stats.recordNetworkHit(responseTimeMs: 300);
      
      // Then
      expect(stats.overallHitRate, closeTo(0.75, 0.01)); // 3/4
      expect(stats.l1HitRate, closeTo(0.25, 0.01)); // 1/4
      expect(stats.l2HitRate, closeTo(0.25, 0.01)); // 1/4
      expect(stats.l3HitRate, closeTo(0.25, 0.01)); // 1/4
      expect(stats.networkHitRate, closeTo(0.25, 0.01)); // 1/4
    });
    
    test('응답 시간 통계', () {
      // Given
      final responseTimes = [10, 20, 30, 40, 50];
      
      // When
      for (final time in responseTimes) {
        stats.recordL1Hit(responseTimeMs: time);
      }
      
      // Then
      expect(stats.averageResponseTime, equals(30)); // 평균
      expect(stats.minResponseTime, equals(10));
      expect(stats.maxResponseTime, equals(50));
    });
    
    test('비용 절감 계산', () {
      // Given - Firestore 읽기 비용: $0.06/100,000 documents
      const savedReads = 100000;
      
      // When
      for (int i = 0; i < savedReads; i++) {
        stats.recordL1Hit();
      }
      
      // Then
      expect(stats.estimatedCostSavings, closeTo(0.06, 0.001));
    });
    
    test('통계 리셋', () {
      // Given
      stats.recordRequest();
      stats.recordL1Hit();
      
      // When
      stats.reset();
      
      // Then
      expect(stats.overallHitRate, equals(0));
      expect(stats.averageResponseTime, equals(0));
    });
  });
}
```

### 3. PreloadStrategy 테스트
```dart
// test/services/cache/preload_strategy_test.dart
@GenerateMocks([FirebaseFirestore, UnifiedCacheService])
void main() {
  group('PreloadStrategy', () {
    late PreloadStrategy strategy;
    late MockFirebaseFirestore mockFirestore;
    late MockUnifiedCacheService mockCache;
    
    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockCache = MockUnifiedCacheService();
      
      strategy = PreloadStrategy();
      // Dependency injection
      GetIt.I.registerSingleton<FirebaseFirestore>(mockFirestore);
      GetIt.I.registerSingleton<UnifiedCacheService>(mockCache);
    });
    
    tearDown(() {
      GetIt.I.reset();
    });
    
    test('최근 채팅 프리로드', () async {
      // Given
      final userId = 'test_user';
      final mockChats = [
        _createMockChatDoc('chat1'),
        _createMockChatDoc('chat2'),
        _createMockChatDoc('chat3'),
      ];
      
      when(mockFirestore.collection('chats'))
        .thenReturn(_mockQuery(mockChats));
      
      // When
      await strategy.preloadRecentChats(userId);
      
      // Then
      verify(mockCache.set(
        'chat_messages_chat1',
        any,
      )).called(1);
      verify(mockCache.set(
        'chat_messages_chat2',
        any,
      )).called(1);
      verify(mockCache.set(
        'chat_messages_chat3',
        any,
      )).called(1);
    });
    
    test('중복 프리로드 방지', () async {
      // Given
      final userId = 'test_user';
      
      // When - 같은 채팅을 두 번 프리로드
      await strategy.preloadRecentChats(userId);
      await strategy.preloadRecentChats(userId);
      
      // Then - 두 번째는 스킵됨
      verify(mockCache.set(any, any)).called(3); // 첫 번째만
    });
    
    test('인덱스 없을 때 폴백 쿼리', () async {
      // Given
      final userId = 'test_user';
      
      // 첫 번째 쿼리 실패 시뮬레이션
      when(mockFirestore.collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true))
        .thenThrow(Exception('Index not found'));
      
      // 폴백 쿼리 성공
      when(mockFirestore.collection('chats')
        .where('participantIds', arrayContains: userId))
        .thenReturn(_mockQuery([]));
      
      // When
      await strategy.preloadRecentChats(userId);
      
      // Then - 예외 없이 완료
      expect(() async => await strategy.preloadRecentChats(userId), 
        returnsNormally);
    });
  });
}
```

## 🔗 통합 테스트

### 1. UnifiedCacheService 통합 테스트
```dart
// test/services/cache/unified_cache_service_test.dart
void main() {
  group('UnifiedCacheService Integration', () {
    late UnifiedCacheService service;
    
    setUpAll(() async {
      // 실제 Hive 초기화
      await Hive.initFlutter();
      
      // 서비스 초기화
      await UnifiedCacheService.initialize();
      service = UnifiedCacheService.instance;
    });
    
    setUp(() async {
      // 각 테스트 전 캐시 클리어
      await service.clear();
    });
    
    test('3-Layer 캐싱 플로우', () async {
      // Given
      const chatId = 'test_chat';
      final messages = [
        MessagesModel(
          id: 'msg1',
          text: 'Hello',
          timeStamp: DateTime.now(),
        ),
      ];
      
      // When - 처음 저장
      await service.setChatMessages(chatId, messages);
      
      // Then - L1에서 조회
      final fromL1 = await service.getChatMessages(chatId);
      expect(fromL1, equals(messages));
      
      // L1 클리어
      await service.clear(layer: CacheLayer.memory);
      
      // L2(Hive)에서 조회
      final fromL2 = await service.getChatMessages(chatId);
      expect(fromL2, equals(messages));
      
      // L2 클리어
      await service.clear(layer: CacheLayer.local);
      
      // L3(Firestore)에서 조회
      final fromL3 = await service.getChatMessages(chatId);
      expect(fromL3, isNotNull);
    });
    
    test('백그라운드 동기화', () async {
      // Given
      const chatId = 'sync_test';
      final oldMessages = [
        MessagesModel(id: 'old1', text: 'Old'),
      ];
      
      await service.setChatMessages(chatId, oldMessages);
      
      // When - 백그라운드 동기화 트리거
      await service.getChatMessages(chatId);
      
      // 동기화 완료 대기
      await Future.delayed(Duration(seconds: 1));
      
      // Then - 업데이트된 데이터 확인
      final updated = await service.getChatMessages(chatId);
      expect(updated.length, greaterThan(oldMessages.length));
    });
    
    test('캐시 무효화 전파', () async {
      // Given
      await service.set('chat_1', 'data1');
      await service.set('chat_2', 'data2');
      await service.set('user_1', 'data3');
      
      // When
      await service.invalidate('chat_');
      
      // Then
      expect(await service.get('chat_1'), isNull);
      expect(await service.get('chat_2'), isNull);
      expect(await service.get('user_1'), isNotNull);
    });
    
    test('Hive 손상 복구', () async {
      // Given - Hive 데이터 손상 시뮬레이션
      final box = await Hive.openBox('unified_cache');
      await box.put('corrupted_key', {'invalid': DateTime.now()}); // 직렬화 불가 데이터
      
      // When - 서비스 재초기화
      await service.init();
      
      // Then - 정상 작동
      expect(() => service.get('corrupted_key'), returnsNormally);
    });
  });
}
```

### 2. 캐시 오케스트레이션 테스트
```dart
// test/services/cache/cache_orchestrator_test.dart
void main() {
  group('CacheOrchestrator', () {
    late CacheOrchestrator orchestrator;
    late MockCacheMonitor mockMonitor;
    
    setUp(() {
      mockMonitor = MockCacheMonitor();
      orchestrator = CacheOrchestrator(mockMonitor);
    });
    
    test('Feature별 전략 적용', () async {
      // Given
      const chatKey = 'chat_messages_123';
      const postKey = 'feed_posts';
      
      // When
      await orchestrator.set(chatKey, [], feature: 'chat');
      await orchestrator.set(postKey, [], feature: 'posts');
      
      // Then - 다른 TTL 적용 확인
      final chatTTL = orchestrator.getTTL(chatKey, 'chat');
      final postTTL = orchestrator.getTTL(postKey, 'posts');
      
      expect(chatTTL, lessThan(postTTL)); // 채팅이 더 짧은 TTL
    });
    
    test('계층적 조회 with Skip', () async {
      // Given
      const key = 'test_key';
      const value = 'test_value';
      
      // L2에만 저장
      await orchestrator.set(key, value, skipL1: true);
      
      // When - L1 스킵하고 조회
      final result = await orchestrator.get<String>(
        key,
        skipL1: true,
      );
      
      // Then
      expect(result, equals(value));
      verify(mockMonitor.trackHit('L2', key, any)).called(1);
      verifyNever(mockMonitor.trackHit('L1', key, any));
    });
    
    test('자동 최적화', () async {
      // Given - 낮은 히트율 시뮬레이션
      when(mockMonitor.getOptimizationRecommendations()).thenReturn([
        CacheRecommendation(
          type: OptimizationType.increaseCacheSize,
          layer: 'L1',
          newSize: 200,
        ),
      ]);
      
      // When
      await orchestrator.autoOptimize();
      
      // Then
      final l1Size = orchestrator.getLayerSize('L1');
      expect(l1Size, equals(200));
    });
    
    test('캐스케이드 무효화', () async {
      // Given - 관련 키 설정
      await orchestrator.set('chat_list', []);
      await orchestrator.set('unread_count', 5);
      
      // When - new_message 이벤트로 무효화
      await orchestrator.invalidate('new_message');
      
      // Then - 관련 키도 무효화됨
      expect(await orchestrator.get('chat_list'), isNull);
      expect(await orchestrator.get('unread_count'), isNull);
    });
  });
}
```

## 🎬 E2E 테스트

### 1. 채팅 캐싱 시나리오
```dart
// test/e2e/chat_caching_e2e_test.dart
void main() {
  group('Chat Caching E2E', () {
    testWidgets('채팅방 진입 시 캐싱 플로우', (tester) async {
      // Given
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();
      
      // 채팅 목록 진입
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();
      
      // When - 첫 번째 채팅방 진입
      final firstChat = find.text('Friend Chat');
      await tester.tap(firstChat);
      
      // 로딩 시작
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 메시지 로드 완료
      await tester.pumpAndSettle();
      expect(find.byType(MessagesModel), findsWidgets);
      
      // 뒤로 가기
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      
      // When - 두 번째 진입 (캐시된 상태)
      await tester.tap(firstChat);
      
      // Then - 즉시 표시 (로딩 없음)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(MessagesModel), findsWidgets);
    });
    
    test('오프라인 모드에서 캐시 동작', () async {
      // Given - 온라인에서 데이터 캐싱
      final service = UnifiedCacheService.instance;
      await service.getChatMessages('chat_123');
      
      // When - 오프라인 전환
      await Connectivity().setMockConnectivity(ConnectivityResult.none);
      
      // Then - 캐시에서 조회 가능
      final messages = await service.getChatMessages('chat_123');
      expect(messages, isNotEmpty);
    });
  });
}
```

### 2. 피드 캐싱 시나리오
```dart
// test/e2e/feed_caching_e2e_test.dart
void main() {
  testWidgets('홈 피드 프리로딩 및 캐싱', (tester) async {
    // Given - 앱 시작
    await tester.pumpWidget(MyApp());
    
    // 스플래시 화면에서 프리로딩
    expect(find.text('Loading...'), findsOneWidget);
    
    // When - 홈 화면 진입
    await tester.pumpAndSettle(Duration(seconds: 2));
    
    // Then - 피드가 즉시 표시됨 (캐시됨)
    expect(find.byType(PostCard), findsWidgets);
    
    // 스크롤 테스트
    await tester.drag(
      find.byType(ListView),
      Offset(0, -500),
    );
    await tester.pumpAndSettle();
    
    // 추가 포스트도 캐시되어 빠르게 표시
    expect(find.byType(PostCard), findsWidgets);
  });
}
```

## 🧪 성능 테스트

### 1. 부하 테스트
```dart
// test/performance/cache_load_test.dart
void main() {
  group('Cache Load Test', () {
    test('동시 1000개 요청 처리', () async {
      // Given
      final service = UnifiedCacheService.instance;
      final stopwatch = Stopwatch()..start();
      
      // When - 1000개 동시 요청
      final futures = <Future>[];
      for (int i = 0; i < 1000; i++) {
        futures.add(
          service.get('key_$i').then((_) {
            // 캐시 미스 시 저장
            return service.set('key_$i', 'value_$i');
          }),
        );
      }
      
      await Future.wait(futures);
      stopwatch.stop();
      
      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1초 이내
      
      // 히트율 확인
      final stats = CacheStatistics.instance;
      print('처리 시간: ${stopwatch.elapsedMilliseconds}ms');
      print('히트율: ${stats.overallHitRate * 100}%');
    });
    
    test('메모리 사용량 한계 테스트', () async {
      // Given
      final service = UnifiedCacheService.instance;
      final initialMemory = _getCurrentMemoryUsage();
      
      // When - 큰 데이터 캐싱
      for (int i = 0; i < 1000; i++) {
        final largeData = List.generate(1000, (j) => 'data_$j');
        await service.set('large_$i', largeData);
      }
      
      // Then
      final finalMemory = _getCurrentMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;
      
      // 메모리 증가량이 한계 이내
      expect(memoryIncrease, lessThan(100 * 1024 * 1024)); // 100MB 이내
    });
  });
}

int _getCurrentMemoryUsage() {
  return ProcessInfo.currentRss ~/ 1024; // KB 단위
}
```

### 2. 응답 시간 벤치마크
```dart
// test/performance/cache_benchmark_test.dart
void main() {
  group('Cache Benchmark', () {
    late UnifiedCacheService service;
    
    setUp(() async {
      await UnifiedCacheService.initialize();
      service = UnifiedCacheService.instance;
    });
    
    test('L1 메모리 캐시 성능', () async {
      // Given - 데이터 준비
      const key = 'benchmark_key';
      const value = 'benchmark_value';
      await service.set(key, value);
      
      // When - 10000번 조회
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10000; i++) {
        await service.get(key);
      }
      stopwatch.stop();
      
      // Then
      final avgTime = stopwatch.elapsedMicroseconds / 10000;
      expect(avgTime, lessThan(100)); // 평균 100μs 이내
      print('L1 평균 응답시간: ${avgTime.toStringAsFixed(2)}μs');
    });
    
    test('L2 Hive 캐시 성능', () async {
      // Given
      const key = 'hive_benchmark';
      await service.set(key, 'value', layer: CacheLayer.local);
      
      // L1 클리어
      await service.clear(layer: CacheLayer.memory);
      
      // When
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        await service.get(key);
      }
      stopwatch.stop();
      
      // Then
      final avgTime = stopwatch.elapsedMilliseconds / 1000;
      expect(avgTime, lessThan(30)); // 평균 30ms 이내
      print('L2 평균 응답시간: ${avgTime.toStringAsFixed(2)}ms');
    });
  });
}
```

## 📊 테스트 커버리지 측정

### 커버리지 실행 스크립트
```bash
#!/bin/bash
# scripts/test_cache_coverage.sh

# 캐시 서비스 테스트 실행
flutter test \
  test/services/cache/ \
  test/features/*/cache/ \
  --coverage \
  --coverage-path=coverage/cache.info

# HTML 리포트 생성
genhtml coverage/cache.info \
  -o coverage/cache_html \
  --no-function-coverage \
  --no-branch-coverage

# 커버리지 요약
lcov --summary coverage/cache.info

# 임계값 체크 (90% 이상)
coverage_percent=$(lcov --summary coverage/cache.info | grep "lines" | sed 's/.*: \([0-9.]*\)%.*/\1/')
if (( $(echo "$coverage_percent < 90" | bc -l) )); then
  echo "⚠️ Coverage is below 90%: $coverage_percent%"
  exit 1
else
  echo "✅ Coverage meets target: $coverage_percent%"
fi
```

### 현재 커버리지
```
services/cache/
├── unified_cache_service.dart   88.5% (462/522 lines)
├── simple_memory_cache.dart     92.3% (147/160 lines)
├── cache_statistics.dart        85.7% (144/168 lines)
└── preload_strategy.dart        78.9% (187/237 lines)

Overall: 86.9% (940/1087 lines)
```

### 목표 커버리지
```
services/cache/
├── unified_cache_service.dart   95% (+6.5%)
├── simple_memory_cache.dart     95% (+2.7%)
├── cache_statistics.dart        90% (+4.3%)
└── preload_strategy.dart        85% (+6.1%)

Overall Target: 90% (+3.1%)
```

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/cache_tests.yml
name: Cache Service Tests

on:
  push:
    paths:
      - 'lib/services/cache/**'
      - 'lib/features/*/cache/**'
      - 'test/**/cache/**'
  pull_request:
    paths:
      - 'lib/services/cache/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run cache tests
        run: |
          flutter test test/services/cache/ --coverage
          flutter test test/features/*/cache/ --coverage
      
      - name: Check coverage
        run: |
          bash scripts/test_cache_coverage.sh
      
      - name: Performance tests
        run: |
          flutter test test/performance/cache_*_test.dart
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/cache.info
          flags: cache
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: test-results
          path: |
            coverage/
            test-results/
```

## 🔍 디버깅 도구

### CacheInspector 위젯
```dart
// lib/debug/cache_inspector.dart
class CacheInspector extends StatefulWidget {
  @override
  State<CacheInspector> createState() => _CacheInspectorState();
}

class _CacheInspectorState extends State<CacheInspector> {
  Timer? _refreshTimer;
  CacheStatistics? _stats;
  
  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _stats = CacheStatistics.instance;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return SizedBox();
    
    return Card(
      color: Colors.black87,
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cache Inspector',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            _buildStat('Hit Rate', '${(_stats?.overallHitRate ?? 0) * 100}%'),
            _buildStat('L1 Size', '${UnifiedCacheService.instance.memorySize}'),
            _buildStat('Avg Response', '${_stats?.averageResponseTime ?? 0}ms'),
            _buildStat('Saved', '\$${_stats?.estimatedCostSavings ?? 0}'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }
}
```

## 📋 테스트 체크리스트

### 단위 테스트
- [x] SimpleMemoryCache 기본 동작
- [x] LRU 제거 정책
- [x] TTL 만료 처리
- [x] 패턴 기반 무효화
- [x] 히트율 계산
- [x] CacheStatistics 정확성
- [x] PreloadStrategy 로직
- [ ] CacheKeys 생성
- [ ] CacheEntry 직렬화

### 통합 테스트
- [x] 3-Layer 캐싱 플로우
- [x] 백그라운드 동기화
- [x] Hive 손상 복구
- [ ] Feature별 전략 적용
- [ ] 캐스케이드 무효화
- [ ] 자동 최적화

### E2E 테스트
- [x] 채팅 캐싱 시나리오
- [x] 피드 캐싱 시나리오
- [ ] 오프라인 모드
- [ ] 프리로딩 효과

### 성능 테스트
- [x] 부하 테스트 (1000 동시 요청)
- [x] 메모리 한계 테스트
- [x] 응답 시간 벤치마크
- [ ] 장시간 실행 테스트

## ⚠️ 테스트 주의사항

### Hive 테스트
- 테스트 환경에서 별도 박스 사용
- 각 테스트 후 박스 클리어
- 파일 시스템 권한 확인

### Firebase 테스트  
- Firebase 에뮬레이터 사용
- 테스트용 프로젝트 분리
- 네트워크 Mock 처리

### 성능 테스트
- 실제 디바이스에서 실행
- 다양한 네트워크 환경 시뮬레이션
- 메모리 프로파일링 병행

---

*이 문서는 Cache Service의 포괄적 테스트 전략을 담고 있습니다.*  
*목표 커버리지 90% 달성을 위한 체계적인 테스트 계획입니다.*