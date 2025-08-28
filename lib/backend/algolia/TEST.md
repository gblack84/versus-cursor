# 🧪 Backend Algolia 테스트 가이드

> Backend Algolia 레이어의 포괄적 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 80%+

## 📋 테스트 전략 개요

### 테스트 피라미드
```
        E2E Tests (10%)
       /              \
    Integration (30%)
   /                    \
  Unit Tests (60%)
 /                        \
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 커버리지 목표
- **전체 목표**: 80% 이상
- **단위 테스트**: 85% (클라이언트, 직렬화, 설정)
- **통합 테스트**: 75% (Repository, DataSource)
- **E2E 테스트**: 60% (실제 검색 플로우)

## 🎯 테스트 범위

### Backend 레이어 테스트
```
backend/api/algolia/
├── client/         → API 클라이언트 테스트
├── config/         → 설정 검증 테스트
├── serializers/    → 직렬화 테스트
└── exceptions/     → 에러 처리 테스트
```

### Feature 레이어 테스트
```
features/search/
├── data/           → Repository, DataSource 테스트
├── domain/         → UseCase, Entity 테스트
└── presentation/   → UI, ViewModel 테스트
```

## 📝 단위 테스트

### 1. Algolia Client 테스트
```dart
// test/backend/api/algolia/client/algolia_client_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:algolia/algolia.dart';

@GenerateMocks([Algolia, AlgoliaQuery])
void main() {
  group('AlgoliaClient', () {
    late AlgoliaClientImpl client;
    late MockAlgolia mockAlgolia;
    late MockAlgoliaQuery mockQuery;
    
    setUp(() {
      mockAlgolia = MockAlgolia();
      mockQuery = MockAlgoliaQuery();
      client = AlgoliaClientImpl(algolia: mockAlgolia);
    });
    
    group('search', () {
      test('정상적인 검색 쿼리 실행', () async {
        // Given
        final mockSnapshot = AlgoliaObjectSnapshot.fromMap(
          mockAlgolia,
          {'objectID': '1', 'title': 'Test Post'},
        );
        
        when(mockAlgolia.index('posts')).thenReturn(mockQuery);
        when(mockQuery.query('test')).thenReturn(mockQuery);
        when(mockQuery.setHitsPerPage(50)).thenReturn(mockQuery);
        when(mockQuery.getObjects()).thenAnswer(
          (_) async => AlgoliaQuerySnapshot(
            algolia: mockAlgolia,
            index: 'posts',
            hits: [mockSnapshot],
            nbHits: 1,
            page: 0,
            nbPages: 1,
            hitsPerPage: 50,
            processingTimeMS: 10,
          ),
        );
        
        // When
        final results = await client.search(
          index: 'posts',
          query: 'test',
          limit: 50,
        );
        
        // Then
        expect(results, hasLength(1));
        expect(results[0]['title'], 'Test Post');
        verify(mockAlgolia.index('posts')).called(1);
        verify(mockQuery.query('test')).called(1);
      });
      
      test('빈 검색어 처리', () async {
        // When & Then
        expect(
          () => client.search(index: 'posts', query: ''),
          throwsA(isA<AlgoliaException>()),
        );
      });
      
      test('네트워크 에러 처리', () async {
        // Given
        when(mockAlgolia.index(any)).thenThrow(
          Exception('Network error'),
        );
        
        // When & Then
        expect(
          () => client.search(index: 'posts', query: 'test'),
          throwsA(isA<AlgoliaException>()),
        );
      });
    });
    
    group('searchByLocation', () {
      test('위치 기반 검색', () async {
        // Given
        when(mockAlgolia.index('posts')).thenReturn(mockQuery);
        when(mockQuery.setAroundLatLng('37.5665,126.9780'))
            .thenReturn(mockQuery);
        when(mockQuery.setAroundRadius(5000)).thenReturn(mockQuery);
        when(mockQuery.getObjects()).thenAnswer(
          (_) async => AlgoliaQuerySnapshot(
            algolia: mockAlgolia,
            index: 'posts',
            hits: [],
            nbHits: 0,
            page: 0,
            nbPages: 0,
            hitsPerPage: 50,
            processingTimeMS: 10,
          ),
        );
        
        // When
        final results = await client.searchByLocation(
          index: 'posts',
          lat: 37.5665,
          lng: 126.9780,
          radiusInMeters: 5000,
        );
        
        // Then
        expect(results, isEmpty);
        verify(mockQuery.setAroundLatLng('37.5665,126.9780')).called(1);
        verify(mockQuery.setAroundRadius(5000)).called(1);
      });
    });
  });
}
```

### 2. Serializer 테스트
```dart
// test/backend/api/algolia/serializers/algolia_serializer_test.dart
void main() {
  group('AlgoliaSerializer', () {
    group('toJson', () {
      test('DateTime 직렬화', () {
        // Given
        final date = DateTime(2025, 8, 28, 12, 0, 0);
        
        // When
        final json = AlgoliaSerializer.toJson(date);
        
        // Then
        expect(json['_timestamp'], date.millisecondsSinceEpoch);
      });
      
      test('LatLng 직렬화', () {
        // Given
        final location = LatLng(37.5665, 126.9780);
        
        // When
        final json = AlgoliaSerializer.toJson(location);
        
        // Then
        expect(json['_geoloc'], {
          'lat': 37.5665,
          'lng': 126.9780,
        });
      });
      
      test('커스텀 객체 직렬화', () {
        // Given
        final post = PostModel(
          id: '1',
          title: 'Test',
          content: 'Content',
        );
        
        // When
        final json = AlgoliaSerializer.toJson(post);
        
        // Then
        expect(json['id'], '1');
        expect(json['title'], 'Test');
        expect(json['content'], 'Content');
      });
      
      test('null 처리', () {
        // When
        final json = AlgoliaSerializer.toJson(null);
        
        // Then
        expect(json, {});
      });
    });
    
    group('fromJson', () {
      test('PostModel 역직렬화', () {
        // Given
        final json = {
          'id': '1',
          'title': 'Test',
          'content': 'Content',
        };
        
        // When
        final post = AlgoliaSerializer.fromJson<PostModel>(
          json,
          PostModel.fromJson,
        );
        
        // Then
        expect(post.id, '1');
        expect(post.title, 'Test');
        expect(post.content, 'Content');
      });
    });
  });
}
```

### 3. Configuration 테스트
```dart
// test/backend/api/algolia/config/algolia_config_test.dart
void main() {
  group('AlgoliaConfig', () {
    test('기본 설정값 확인', () {
      expect(AlgoliaConfig.applicationId, '0GAS0MPT9Z');
      expect(AlgoliaConfig.apiKey, isNotEmpty);
      expect(AlgoliaConfig.userAgent, 'VersusSpace/2.0.0');
      expect(AlgoliaConfig.cacheTimeout, Duration(minutes: 5));
      expect(AlgoliaConfig.maxCacheSize, 100);
    });
  });
  
  group('AlgoliaIndices', () {
    test('인덱스 이름 상수', () {
      expect(AlgoliaIndices.posts, 'posts');
      expect(AlgoliaIndices.users, 'users');
      expect(AlgoliaIndices.comments, 'comments');
      expect(AlgoliaIndices.chats, 'chats');
    });
    
    test('인덱스 유효성 검사', () {
      expect(AlgoliaIndices.isValidIndex('posts'), isTrue);
      expect(AlgoliaIndices.isValidIndex('invalid'), isFalse);
    });
    
    test('모든 인덱스 목록', () {
      expect(AlgoliaIndices.all, hasLength(5));
      expect(AlgoliaIndices.all, contains('posts'));
    });
  });
}
```

## 🔄 통합 테스트

### 1. Repository 통합 테스트
```dart
// test/features/search/data/repositories/search_repository_test.dart
@GenerateMocks([SearchRemoteDataSource, SearchCacheService, NetworkInfo])
void main() {
  group('SearchRepository', () {
    late SearchRepositoryImpl repository;
    late MockSearchRemoteDataSource mockDataSource;
    late MockSearchCacheService mockCache;
    late MockNetworkInfo mockNetwork;
    
    setUp(() {
      mockDataSource = MockSearchRemoteDataSource();
      mockCache = MockSearchCacheService();
      mockNetwork = MockNetworkInfo();
      
      repository = SearchRepositoryImpl(
        remoteDataSource: mockDataSource,
        cacheService: mockCache,
        networkInfo: mockNetwork,
      );
    });
    
    group('searchPosts', () {
      final tQuery = 'test';
      final tPosts = [
        PostModel(id: '1', title: 'Test 1'),
        PostModel(id: '2', title: 'Test 2'),
      ];
      
      test('캐시가 있을 때 캐시 반환', () async {
        // Given
        when(mockCache.get(any)).thenReturn(tPosts);
        
        // When
        final result = await repository.searchPosts(query: tQuery);
        
        // Then
        expect(result, Right(tPosts));
        verifyNever(mockDataSource.searchPosts(any, any));
        verify(mockCache.get('posts_test{}'));
      });
      
      test('캐시가 없고 온라인일 때 API 호출', () async {
        // Given
        when(mockCache.get(any)).thenReturn(null);
        when(mockNetwork.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.searchPosts(tQuery, any))
            .thenAnswer((_) async => tPosts);
        
        // When
        final result = await repository.searchPosts(query: tQuery);
        
        // Then
        expect(result, Right(tPosts));
        verify(mockDataSource.searchPosts(tQuery, any));
        verify(mockCache.set(any, tPosts));
      });
      
      test('오프라인일 때 에러 반환', () async {
        // Given
        when(mockCache.get(any)).thenReturn(null);
        when(mockNetwork.isConnected).thenAnswer((_) async => false);
        
        // When
        final result = await repository.searchPosts(query: tQuery);
        
        // Then
        expect(result, isA<Left>());
        expect(
          result.fold((l) => l, (r) => null),
          isA<NetworkFailure>(),
        );
      });
      
      test('서버 에러 처리', () async {
        // Given
        when(mockCache.get(any)).thenReturn(null);
        when(mockNetwork.isConnected).thenAnswer((_) async => true);
        when(mockDataSource.searchPosts(tQuery, any))
            .thenThrow(ServerException('Server error'));
        
        // When
        final result = await repository.searchPosts(query: tQuery);
        
        // Then
        expect(result, isA<Left>());
        expect(
          result.fold((l) => l, (r) => null),
          isA<ServerFailure>(),
        );
      });
    });
  });
}
```

### 2. Service 통합 테스트
```dart
// test/services/search/search_service_test.dart
void main() {
  group('SearchService', () {
    late SearchService service;
    late MockSearchRepository mockRepository;
    late MockSearchAnalyticsService mockAnalytics;
    
    setUp(() {
      mockRepository = MockSearchRepository();
      mockAnalytics = MockSearchAnalyticsService();
      
      service = SearchService(
        searchRepository: mockRepository,
        analyticsService: mockAnalytics,
      );
    });
    
    test('통합 검색 실행', () async {
      // Given
      final tPosts = [PostModel(id: '1')];
      final tUsers = [UserModel(id: '2')];
      
      when(mockRepository.searchPosts(query: 'test'))
          .thenAnswer((_) async => Right(tPosts));
      when(mockRepository.searchUsers(query: 'test'))
          .thenAnswer((_) async => Right(tUsers));
      
      // When
      final results = await service.universalSearch('test');
      
      // Then
      expect(results.posts, tPosts);
      expect(results.users, tUsers);
      verify(mockAnalytics.trackSearch('test', any));
    });
  });
}
```

## 🎬 E2E 테스트

### 1. 검색 플로우 E2E 테스트
```dart
// test/e2e/search_e2e_test.dart
void main() {
  testWidgets('전체 검색 플로우', (tester) async {
    // Setup
    await setupTestEnvironment();
    
    // Given: 앱 실행
    await tester.pumpWidget(TestApp());
    await tester.pumpAndSettle();
    
    // When: 검색 페이지 열기
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    
    // And: 검색어 입력
    await tester.enterText(
      find.byKey(Key('searchField')),
      'football vs soccer',
    );
    
    // And: 검색 실행
    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    
    // Then: 결과 확인
    expect(find.text('Football vs Soccer'), findsOneWidget);
    expect(find.byType(PostCard), findsWidgets);
    
    // When: 결과 클릭
    await tester.tap(find.byType(PostCard).first);
    await tester.pumpAndSettle();
    
    // Then: 상세 페이지 확인
    expect(find.byType(PostDetailScreen), findsOneWidget);
  });
  
  testWidgets('위치 기반 검색', (tester) async {
    // Setup: 위치 권한 설정
    await mockLocationPermission();
    
    // Given: 앱 실행
    await tester.pumpWidget(TestApp());
    
    // When: 위치 검색 버튼 탭
    await tester.tap(find.byIcon(Icons.location_on));
    await tester.pumpAndSettle();
    
    // Then: 주변 포스트 표시
    expect(find.text('Nearby Posts'), findsOneWidget);
    expect(find.byType(PostCard), findsWidgets);
  });
  
  testWidgets('오프라인 모드 처리', (tester) async {
    // Setup: 네트워크 차단
    await disableNetwork();
    
    // Given: 앱 실행
    await tester.pumpWidget(TestApp());
    
    // When: 검색 시도
    await tester.enterText(find.byKey(Key('searchField')), 'test');
    await tester.tap(find.byKey(Key('searchButton')));
    await tester.pumpAndSettle();
    
    // Then: 오프라인 메시지 표시
    expect(find.text('No internet connection'), findsOneWidget);
    
    // And: 캐시된 데이터 표시
    expect(find.text('Showing cached results'), findsOneWidget);
  });
}
```

## 🎨 Golden 테스트

### 검색 결과 UI 테스트
```dart
// test/golden/search_results_golden_test.dart
void main() {
  testGoldens('검색 결과 화면', (tester) async {
    // Given: Mock 데이터
    final mockResults = [
      PostModel(id: '1', title: 'Test 1', imageUrl: 'image1.jpg'),
      PostModel(id: '2', title: 'Test 2', imageUrl: 'image2.jpg'),
    ];
    
    // When: 위젯 렌더링
    await tester.pumpWidget(
      TestWrapper(
        child: SearchResultsScreen(results: mockResults),
      ),
    );
    
    // Then: Golden 비교
    await screenMatchesGolden(tester, 'search_results');
  });
}
```

## ⚡ 성능 테스트

### 검색 응답 시간 테스트
```dart
// test/performance/search_performance_test.dart
void main() {
  test('검색 응답 시간', () async {
    final client = AlgoliaClientImpl();
    final stopwatch = Stopwatch()..start();
    
    // 100개 검색 쿼리 실행
    for (int i = 0; i < 100; i++) {
      await client.search(
        index: 'posts',
        query: 'test $i',
        limit: 50,
      );
    }
    
    stopwatch.stop();
    final averageTime = stopwatch.elapsedMilliseconds / 100;
    
    // 평균 응답 시간 200ms 이하
    expect(averageTime, lessThan(200));
  });
  
  test('캐시 성능', () async {
    final cache = SearchCacheService();
    final stopwatch = Stopwatch();
    
    // 쓰기 성능
    stopwatch.start();
    for (int i = 0; i < 1000; i++) {
      await cache.set('key_$i', 'value_$i');
    }
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
    
    // 읽기 성능
    stopwatch.reset();
    stopwatch.start();
    for (int i = 0; i < 1000; i++) {
      await cache.get('key_$i');
    }
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(50));
  });
}
```

## 📊 테스트 커버리지

### 커버리지 목표 및 현황
```yaml
coverage:
  backend/api/algolia:
    client: 85%        # 목표: 85%
    serializers: 90%   # 목표: 85%
    config: 100%       # 목표: 100%
    exceptions: 80%    # 목표: 80%
  
  features/search:
    data: 75%          # 목표: 75%
    domain: 80%        # 목표: 80%
    presentation: 70%  # 목표: 70%
  
  services/search:
    service: 80%       # 목표: 80%
    cache: 85%         # 목표: 85%
    analytics: 70%     # 목표: 70%
```

### 커버리지 리포트 생성
```bash
# 테스트 실행 및 커버리지 생성
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 리포트 열기
open coverage/html/index.html
```

## 🛠️ 테스트 인프라

### Mock 생성
```yaml
# pubspec.yaml
dev_dependencies:
  mockito: ^5.4.0
  build_runner: ^2.4.0
  
# Mock 생성 명령
flutter pub run build_runner build --delete-conflicting-outputs
```

### 테스트 데이터
```dart
// test/fixtures/search_fixtures.dart
class SearchFixtures {
  static final mockPosts = [
    PostModel(id: '1', title: 'Football vs Soccer'),
    PostModel(id: '2', title: 'Pizza vs Burger'),
  ];
  
  static final mockUsers = [
    UserModel(id: '1', name: 'John Doe'),
    UserModel(id: '2', name: 'Jane Smith'),
  ];
  
  static final mockAlgoliaResponse = {
    'hits': [
      {'objectID': '1', 'title': 'Test'},
    ],
    'nbHits': 1,
    'page': 0,
    'nbPages': 1,
  };
}
```

### 테스트 환경 설정
```dart
// test/helpers/test_helper.dart
Future<void> setupTestEnvironment() async {
  // DI 초기화
  configureDependencies(Environment.test);
  
  // Mock 데이터 설정
  await setupMockData();
  
  // 테스트 서버 시작
  await startMockServer();
}

Future<void> teardownTestEnvironment() async {
  // 정리 작업
  await stopMockServer();
  await clearMockData();
  getIt.reset();
}
```

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/test.yml
name: Test Algolia Integration

on:
  push:
    paths:
      - 'lib/backend/api/algolia/**'
      - 'lib/features/search/**'
      - 'test/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## 📈 테스트 메트릭

### 주요 지표
- **테스트 실행 시간**: < 5분
- **커버리지**: 80% 이상
- **Flaky 테스트**: 0%
- **테스트 성공률**: 100%

### 모니터링
```dart
// 테스트 실행 시간 추적
void main() {
  setUpAll(() {
    print('Test started at: ${DateTime.now()}');
  });
  
  tearDownAll(() {
    print('Test completed at: ${DateTime.now()}');
  });
  
  // 테스트 코드...
}
```

---

*이 문서는 Backend Algolia 모듈의 테스트 전략과 구현 가이드입니다.*  
*80% 이상의 테스트 커버리지 달성을 목표로 합니다.*