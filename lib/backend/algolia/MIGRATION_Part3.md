# 🔄 Backend Algolia 마이그레이션 계획 Part 3

> Backend Algolia 레이어 리팩토링 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 1주

## 📌 Executive Summary

**현재 상황**: Algolia 구현이 Feature 레이어에 종속되어 있고, Backend 레이어는 문서만 존재  
**목표**: Backend 레이어에 공통 Algolia 인프라 구축, Repository 패턴 적용  
**방법**: 단계별 마이그레이션으로 Feature 종속성 제거, 테스트 가능한 구조 구축

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/backend/algolia/
└── README.md                      # 문서만 존재

lib/features/search/data/services/
├── algolia_manager.dart           # 모든 구현이 Feature에
└── serialization_util.dart        # Feature 종속적

lib/backend/api/algolia/
└── (empty)                        # 빈 디렉토리
```

### After (목표)
```
lib/
├── backend/
│   └── api/
│       └── algolia/
│           ├── client/
│           │   ├── algolia_client.dart         # 핵심 클라이언트
│           │   └── algolia_client_impl.dart    # 구현체
│           ├── config/
│           │   ├── algolia_config.dart         # 설정 관리
│           │   └── algolia_indices.dart        # 인덱스 정의
│           ├── serializers/
│           │   ├── algolia_serializer.dart     # 공통 직렬화
│           │   └── type_converters.dart        # 타입 변환기
│           └── exceptions/
│               └── algolia_exceptions.dart     # 에러 처리
│
├── features/search/
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── search_remote_datasource.dart   # 인터페이스
│   │   │   └── search_remote_datasource_impl.dart
│   │   └── repositories/
│   │       └── search_repository_impl.dart
│   └── domain/
│       └── repositories/
│           └── search_repository.dart
│
└── services/
    └── search/
        ├── search_service.dart           # 전역 검색 서비스
        ├── search_cache_service.dart     # 캐싱 전략
        └── search_analytics_service.dart # 검색 분석
```

## 📊 현재 문제점 분석

### 1. 아키텍처 위반 심각도: 🔴 높음
```dart
// 현재: Feature가 직접 Algolia 관리
// lib/features/search/data/services/algolia_manager.dart
class AppAlgoliaManager {
  static AppAlgoliaManager? _instance;
  // Feature 내부에 모든 로직이 있음
}
```

**영향 분석**:
- 다른 Feature에서 재사용 불가
- 테스트 어려움 (직접 의존성)
- API 키 관리 문제
- 캐싱 전략 공유 불가

### 2. 코드 중복 위험 심각도: 🟡 중간
```
예상되는 검색 필요 Feature:
- Chat: 메시지 검색
- Posts: 게시물 검색
- Users: 사용자 검색
- Comments: 댓글 검색

각 Feature가 독립적으로 구현 시 4배 중복 발생
```

### 3. 테스트 불가능 심각도: 🔴 높음
```dart
// 현재: 싱글톤 + 직접 의존성
AppAlgoliaManager.instance.algoliaQuery()  // Mock 불가능
```

## 📝 상세 마이그레이션 단계

### Phase 1: Backend 인프라 구축 (Day 1-2)

#### 1.1 디렉토리 구조 생성
```bash
mkdir -p lib/backend/api/algolia/{client,config,serializers,exceptions}
```

#### 1.2 Algolia Client 인터페이스
```dart
// lib/backend/api/algolia/client/algolia_client.dart
abstract class AlgoliaClient {
  Future<List<Map<String, dynamic>>> search({
    required String index,
    required String query,
    Map<String, dynamic>? filters,
    int? limit,
    int? offset,
  });
  
  Future<List<Map<String, dynamic>>> searchByLocation({
    required String index,
    required double lat,
    required double lng,
    double? radiusInMeters,
    int? limit,
  });
  
  Future<void> saveObject({
    required String index,
    required String objectId,
    required Map<String, dynamic> data,
  });
  
  Future<void> deleteObject({
    required String index,
    required String objectId,
  });
}
```

#### 1.3 Configuration 관리
```dart
// lib/backend/api/algolia/config/algolia_config.dart
class AlgoliaConfig {
  static const String applicationId = String.fromEnvironment(
    'ALGOLIA_APP_ID',
    defaultValue: '0GAS0MPT9Z',
  );
  
  static const String apiKey = String.fromEnvironment(
    'ALGOLIA_API_KEY',
    defaultValue: '123e265bbab0702b220a66a59f22ab8e',
  );
  
  static const String userAgent = 'VersusSpace/2.0.0';
  
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxCacheSize = 100;
}

// lib/backend/api/algolia/config/algolia_indices.dart
class AlgoliaIndices {
  static const String posts = 'posts';
  static const String users = 'users';
  static const String comments = 'comments';
  static const String chats = 'chats';
  static const String messages = 'messages';
  
  static const List<String> all = [
    posts, users, comments, chats, messages
  ];
  
  static bool isValidIndex(String index) => all.contains(index);
}
```

#### 1.4 Serializer 구현
```dart
// lib/backend/api/algolia/serializers/algolia_serializer.dart
class AlgoliaSerializer {
  static Map<String, dynamic> toJson(dynamic object) {
    if (object == null) return {};
    
    // Type-specific serialization
    if (object is DateTime) {
      return {'_timestamp': object.millisecondsSinceEpoch};
    }
    
    if (object is LatLng) {
      return {
        '_geoloc': {
          'lat': object.latitude,
          'lng': object.longitude,
        }
      };
    }
    
    // Firestore document
    if (object is DocumentSnapshot) {
      final data = object.data() as Map<String, dynamic>?;
      return {
        'objectID': object.id,
        ...?data,
        '_timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }
    
    return object.toJson();
  }
  
  static T fromJson<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return fromJson(json);
  }
}
```

### Phase 2: Repository 패턴 구현 (Day 3-4)

#### 2.1 Domain Repository 인터페이스
```dart
// lib/features/search/domain/repositories/search_repository.dart
abstract class SearchRepository {
  Future<Either<Failure, List<PostModel>>> searchPosts({
    required String query,
    SearchFilter? filter,
    int? limit,
  });
  
  Future<Either<Failure, List<UserModel>>> searchUsers({
    required String query,
    SearchFilter? filter,
    int? limit,
  });
  
  Future<Either<Failure, List<PostModel>>> searchNearby({
    required LatLng location,
    double radiusInMeters,
    String? query,
    int? limit,
  });
  
  Future<Either<Failure, SearchAnalytics>> getSearchAnalytics();
}
```

#### 2.2 Data Source 구현
```dart
// lib/features/search/data/datasources/search_remote_datasource.dart
abstract class SearchRemoteDataSource {
  Future<List<PostModel>> searchPosts(String query, Map<String, dynamic> params);
  Future<List<UserModel>> searchUsers(String query, Map<String, dynamic> params);
}

// lib/features/search/data/datasources/search_remote_datasource_impl.dart
@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final AlgoliaClient algoliaClient;
  
  SearchRemoteDataSourceImpl(this.algoliaClient);
  
  @override
  Future<List<PostModel>> searchPosts(String query, Map<String, dynamic> params) async {
    try {
      final results = await algoliaClient.search(
        index: AlgoliaIndices.posts,
        query: query,
        filters: params,
      );
      
      return results
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
```

#### 2.3 Repository 구현
```dart
// lib/features/search/data/repositories/search_repository_impl.dart
@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDataSource remoteDataSource;
  final SearchCacheService cacheService;
  final NetworkInfo networkInfo;
  
  SearchRepositoryImpl({
    required this.remoteDataSource,
    required this.cacheService,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<PostModel>>> searchPosts({
    required String query,
    SearchFilter? filter,
    int? limit,
  }) async {
    // 캐시 체크
    final cacheKey = 'posts_$query${filter?.toJson()}';
    final cached = cacheService.get(cacheKey);
    if (cached != null) {
      return Right(cached);
    }
    
    // 네트워크 체크
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final results = await remoteDataSource.searchPosts(
        query,
        {'limit': limit ?? 50, ...?filter?.toJson()},
      );
      
      // 캐시 저장
      cacheService.set(cacheKey, results);
      
      return Right(results);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
```

### Phase 3: Service 레이어 구축 (Day 4-5)

#### 3.1 전역 검색 서비스
```dart
// lib/services/search/search_service.dart
@lazySingleton
class SearchService {
  final SearchRepository searchRepository;
  final SearchAnalyticsService analyticsService;
  
  SearchService({
    required this.searchRepository,
    required this.analyticsService,
  });
  
  // 통합 검색
  Future<SearchResults> universalSearch(String query) async {
    final futures = await Future.wait([
      searchRepository.searchPosts(query: query),
      searchRepository.searchUsers(query: query),
    ]);
    
    // 분석 기록
    analyticsService.trackSearch(query, futures);
    
    return SearchResults(
      posts: futures[0].getOrElse(() => []),
      users: futures[1].getOrElse(() => []),
    );
  }
  
  // 추천 검색어
  Stream<List<String>> getSuggestions(String partial) {
    return Stream.value(_generateSuggestions(partial));
  }
}
```

#### 3.2 캐싱 서비스
```dart
// lib/services/search/search_cache_service.dart
@lazySingleton
class SearchCacheService {
  final UnifiedCacheService _cacheService;
  static const String _prefix = 'search_';
  
  SearchCacheService(this._cacheService);
  
  Future<T?> get<T>(String key) async {
    return await _cacheService.get('$_prefix$key');
  }
  
  Future<void> set<T>(String key, T value) async {
    await _cacheService.set(
      '$_prefix$key',
      value,
      expiry: AlgoliaConfig.cacheTimeout,
    );
  }
  
  Future<void> invalidateAll() async {
    await _cacheService.clearPrefix(_prefix);
  }
}
```

### Phase 4: 마이그레이션 실행 (Day 5-6)

#### 4.1 기존 코드 리팩토링
```dart
// Before: features/search/data/services/algolia_manager.dart
// 이 파일을 Deprecated로 표시하고 점진적 마이그레이션

@Deprecated('Use SearchRepository instead')
class AppAlgoliaManager {
  // 기존 코드 유지하되 새 Repository 호출로 위임
  Future<List<AlgoliaObjectSnapshot>> algoliaQuery(...) async {
    final repository = getIt<SearchRepository>();
    // Repository 호출로 위임
  }
}
```

#### 4.2 DI 설정
```dart
// lib/app/di/modules/search_module.dart
@module
abstract class SearchModule {
  @lazySingleton
  AlgoliaClient provideAlgoliaClient() => AlgoliaClientImpl();
  
  @lazySingleton
  SearchRemoteDataSource provideSearchDataSource(
    AlgoliaClient client,
  ) => SearchRemoteDataSourceImpl(client);
  
  @lazySingleton
  SearchRepository provideSearchRepository(
    SearchRemoteDataSource dataSource,
    SearchCacheService cacheService,
    NetworkInfo networkInfo,
  ) => SearchRepositoryImpl(
    remoteDataSource: dataSource,
    cacheService: cacheService,
    networkInfo: networkInfo,
  );
}
```

### Phase 5: 테스트 및 검증 (Day 6-7)

#### 5.1 단위 테스트
```dart
// test/backend/api/algolia/client/algolia_client_test.dart
void main() {
  group('AlgoliaClient', () {
    late AlgoliaClient client;
    late MockAlgolia mockAlgolia;
    
    setUp(() {
      mockAlgolia = MockAlgolia();
      client = AlgoliaClientImpl(algolia: mockAlgolia);
    });
    
    test('search returns results', () async {
      // Given
      when(mockAlgolia.search(any)).thenAnswer(
        (_) async => [{'objectID': '1', 'title': 'Test'}],
      );
      
      // When
      final results = await client.search(
        index: 'posts',
        query: 'test',
      );
      
      // Then
      expect(results, hasLength(1));
      expect(results[0]['title'], 'Test');
    });
  });
}
```

#### 5.2 통합 테스트
```dart
// test/features/search/integration/search_integration_test.dart
void main() {
  testWidgets('Search flow test', (tester) async {
    // DI 설정
    await setupTestDI();
    
    // 앱 실행
    await tester.pumpWidget(MyApp());
    
    // 검색 실행
    await tester.enterText(find.byKey(Key('searchField')), 'test');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    
    // 결과 확인
    expect(find.text('Test Post'), findsOneWidget);
  });
}
```

## 🚀 실행 계획

### Week 1: 기초 구축
- [ ] Day 1-2: Backend 인프라 구축
- [ ] Day 3-4: Repository 패턴 구현
- [ ] Day 4-5: Service 레이어 구축
- [ ] Day 5-6: 마이그레이션 실행
- [ ] Day 6-7: 테스트 및 검증

## 📈 성공 지표

### 정량적 지표
- ✅ 코드 재사용성: 0% → 100% (모든 Feature 공유 가능)
- ✅ 테스트 커버리지: 0% → 80%+
- ✅ API 호출 감소: 캐싱으로 30% 감소
- ✅ 응답 시간: 평균 200ms 단축

### 정성적 지표
- ✅ Feature-First Architecture 준수
- ✅ Repository 패턴 적용
- ✅ DI를 통한 테스트 가능성
- ✅ 환경 변수로 API 키 관리

## ⚠️ 리스크 및 대응 방안

### Risk 1: Breaking Change
**문제**: 기존 Search Feature 동작 중단 가능  
**대응**: 
- Deprecated 어노테이션으로 점진적 마이그레이션
- Facade 패턴으로 하위 호환성 유지
- 2주간 이전 버전 유지

### Risk 2: 성능 저하
**문제**: 새로운 레이어 추가로 지연 발생 가능  
**대응**: 
- 적극적인 캐싱 전략
- 병렬 처리 적용
- 프로파일링으로 병목 지점 파악

### Risk 3: API 한도 초과
**문제**: 마이그레이션 중 API 호출 급증  
**대응**: 
- Rate limiting 구현
- 캐싱 우선 전략
- 점진적 롤아웃

## 🔄 롤백 계획

### 즉시 롤백 시나리오
```dart
// Feature flag로 제어
class FeatureFlags {
  static bool useNewSearchBackend = false;
}

// 사용처
if (FeatureFlags.useNewSearchBackend) {
  // 새로운 Repository 사용
  return getIt<SearchRepository>().searchPosts(query);
} else {
  // 기존 AlgoliaManager 사용
  return AppAlgoliaManager.instance.algoliaQuery(...);
}
```

## 📚 참고 자료

- [Algolia Flutter SDK](https://pub.dev/packages/algolia)
- [Repository Pattern in Flutter](https://resocoder.com/2019/08/27/flutter-tdd-clean-architecture-course-1-explanation-project-structure/)
- [GetIt DI](https://pub.dev/packages/get_it)
- [Injectable](https://pub.dev/packages/injectable)

## 🏁 체크리스트

### 마이그레이션 전
- [ ] 현재 사용처 파악
- [ ] API 사용량 모니터링
- [ ] 테스트 환경 준비
- [ ] 백업 계획 수립

### 마이그레이션 중
- [ ] Backend 인프라 구축
- [ ] Repository 패턴 구현
- [ ] Service 레이어 구축
- [ ] DI 통합
- [ ] 테스트 작성

### 마이그레이션 후
- [ ] 성능 측정
- [ ] API 사용량 확인
- [ ] 에러 모니터링
- [ ] 문서 업데이트

---

*이 문서는 Backend Algolia 레이어의 구체적인 마이그레이션 계획입니다.*  
*1주간의 집중 개발로 완전한 Backend 검색 인프라를 구축합니다.*