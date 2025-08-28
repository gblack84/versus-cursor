# 🧪 Backend API 레이어 테스트 가이드

> API 통합 레이어의 체계적인 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 목표 커버리지: 85%

## 📊 테스트 전략 개요

### 테스트 피라미드
```
         E2E Tests (5%)
        /             \
    Integration Tests (25%)
   /                      \
  Unit Tests (70%)
```

### 커버리지 목표
| 컴포넌트 | 목표 | 우선순위 | 테스트 유형 |
|----------|------|----------|------------|
| **HTTP Client** | 95% | 🔴 Critical | Unit, Integration |
| **Interceptors** | 90% | 🔴 Critical | Unit |
| **Cache System** | 85% | 🟡 High | Unit, Integration |
| **Error Handling** | 95% | 🔴 Critical | Unit |
| **DataSources** | 85% | 🟡 High | Unit, Integration |

## 🎯 테스트 환경 설정

### 필요 패키지
```yaml
dev_dependencies:
  test: ^1.24.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
  dio: ^5.3.0
  http_mock_adapter: ^0.5.0
  fake_async: ^1.3.0
  flutter_dotenv: ^5.1.0
```

### 테스트 구조
```
test/
├── backend/
│   └── api/
│       ├── unit/
│       │   ├── clients/
│       │   ├── interceptors/
│       │   ├── cache/
│       │   └── models/
│       ├── integration/
│       │   ├── api_flow_test.dart
│       │   └── cache_flow_test.dart
│       └── fixtures/
│           ├── api_fixtures.dart
│           └── mock_responses.json
```

## 🔧 Unit Tests

### 1. HTTP Client Tests

#### 1.1 기본 요청 테스트
```dart
// test/backend/api/unit/clients/dio_client_test.dart
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

@GenerateMocks([Dio, RequestInterceptorHandler])
void main() {
  group('DioClient Tests', () {
    late Dio dio;
    late DioAdapter dioAdapter;
    late DioClient client;
    
    setUp(() {
      dio = Dio();
      dioAdapter = DioAdapter(dio: dio);
      client = DioClient(
        dio: dio,
        config: ApiConfig(baseUrl: 'https://test.com'),
      );
    });
    
    group('GET requests', () {
      test('should return success response for 200', () async {
        // Given
        const path = '/test';
        final responseData = {'data': 'test'};
        
        dioAdapter.onGet(
          path,
          (server) => server.reply(200, responseData),
        );
        
        // When
        final response = await client.get<Map<String, dynamic>>(path);
        
        // Then
        expect(response.isSuccess, true);
        expect(response.statusCode, 200);
        expect(response.data, responseData);
      });
      
      test('should return error response for 404', () async {
        // Given
        const path = '/notfound';
        
        dioAdapter.onGet(
          path,
          (server) => server.reply(404, {'error': 'Not Found'}),
        );
        
        // When
        final response = await client.get(path);
        
        // Then
        expect(response.isSuccess, false);
        expect(response.statusCode, 404);
        expect(response.message, contains('Not Found'));
      });
      
      test('should handle network errors', () async {
        // Given
        const path = '/network-error';
        
        dioAdapter.onGet(
          path,
          (server) => server.throws(
            500,
            DioException(
              requestOptions: RequestOptions(path: path),
              type: DioExceptionType.connectionTimeout,
            ),
          ),
        );
        
        // When
        final response = await client.get(path);
        
        // Then
        expect(response.isSuccess, false);
        expect(response.message, contains('Connection timeout'));
      });
    });
    
    group('POST requests', () {
      test('should send data correctly', () async {
        // Given
        const path = '/create';
        final requestData = {'name': 'Test', 'value': 123};
        final responseData = {'id': 'abc123', 'created': true};
        
        dioAdapter.onPost(
          path,
          (server) => server.reply(201, responseData),
          data: requestData,
        );
        
        // When
        final response = await client.post<Map<String, dynamic>>(
          path,
          data: requestData,
        );
        
        // Then
        expect(response.isSuccess, true);
        expect(response.statusCode, 201);
        expect(response.data!['id'], 'abc123');
      });
      
      test('should handle multipart uploads', () async {
        // Given
        const path = '/upload';
        final formData = FormData.fromMap({
          'file': MultipartFile.fromString('content', filename: 'test.txt'),
        });
        
        dioAdapter.onPost(
          path,
          (server) => server.reply(200, {'uploaded': true}),
          data: formData,
        );
        
        // When
        final response = await client.post(path, data: formData);
        
        // Then
        expect(response.isSuccess, true);
        expect(response.data!['uploaded'], true);
      });
    });
  });
}
```

### 2. Interceptor Tests

#### 2.1 Auth Interceptor 테스트
```dart
// test/backend/api/unit/interceptors/auth_interceptor_test.dart
@GenerateMocks([IAuthService, RequestInterceptorHandler, ErrorInterceptorHandler])
void main() {
  group('AuthInterceptor Tests', () {
    late AuthInterceptor interceptor;
    late MockIAuthService mockAuthService;
    late MockRequestInterceptorHandler mockHandler;
    
    setUp(() {
      mockAuthService = MockIAuthService();
      mockHandler = MockRequestInterceptorHandler();
      
      // DI 설정
      getIt.registerSingleton<IAuthService>(mockAuthService);
      
      interceptor = AuthInterceptor();
    });
    
    tearDown(() {
      getIt.reset();
    });
    
    test('should add auth token to request headers', () async {
      // Given
      final options = RequestOptions(path: '/test');
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => 'test-token');
      
      // When
      await interceptor.onRequest(options, mockHandler);
      
      // Then
      expect(options.headers['Authorization'], 'Bearer test-token');
      verify(mockHandler.next(options)).called(1);
    });
    
    test('should proceed without token if not authenticated', () async {
      // Given
      final options = RequestOptions(path: '/test');
      when(mockAuthService.getAccessToken())
          .thenAnswer((_) async => null);
      
      // When
      await interceptor.onRequest(options, mockHandler);
      
      // Then
      expect(options.headers['Authorization'], isNull);
      verify(mockHandler.next(options)).called(1);
    });
    
    test('should refresh token on 401 error', () async {
      // Given
      final mockErrorHandler = MockErrorInterceptorHandler();
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
      );
      
      when(mockAuthService.refreshToken())
          .thenAnswer((_) async => 'new-token');
      
      // When
      await interceptor.onError(error, mockErrorHandler);
      
      // Then
      verify(mockAuthService.refreshToken()).called(1);
      // Verify retry logic
    });
  });
}
```

#### 2.2 Retry Interceptor 테스트
```dart
// test/backend/api/unit/interceptors/retry_interceptor_test.dart
void main() {
  group('RetryInterceptor Tests', () {
    late RetryInterceptor interceptor;
    late MockDio mockDio;
    
    setUp(() {
      mockDio = MockDio();
      interceptor = RetryInterceptor(dio: mockDio, maxRetries: 3);
    });
    
    test('should retry on network errors', () async {
      // Given
      int attempts = 0;
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );
      
      // When
      await interceptor.onError(error, MockErrorInterceptorHandler());
      
      // Then
      expect(attempts, lessThanOrEqualTo(3));
    });
    
    test('should not retry on client errors', () async {
      // Given
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
        ),
      );
      
      // When
      await interceptor.onError(error, MockErrorInterceptorHandler());
      
      // Then
      verifyNever(mockDio.fetch(any));
    });
  });
}
```

### 3. Cache System Tests

#### 3.1 Memory Cache 테스트
```dart
// test/backend/api/unit/cache/memory_cache_test.dart
void main() {
  group('MemoryCache Tests', () {
    late MemoryCache cache;
    
    setUp(() {
      cache = MemoryCache(maxSize: 100);
    });
    
    test('should store and retrieve data', () {
      // Given
      const key = 'test-key';
      final data = {'data': 'test'};
      
      // When
      cache.put(key, data);
      final retrieved = cache.get(key);
      
      // Then
      expect(retrieved, equals(data));
    });
    
    test('should respect TTL', () {
      // Given
      const key = 'ttl-key';
      final data = {'data': 'test'};
      
      // When
      cache.put(key, data, ttl: Duration(milliseconds: 100));
      
      // Then
      expect(cache.get(key), isNotNull);
      
      // After TTL
      sleep(Duration(milliseconds: 150));
      expect(cache.get(key), isNull);
    });
    
    test('should evict LRU when full', () {
      // Given
      cache = MemoryCache(maxSize: 2);
      
      // When
      cache.put('key1', 'data1');
      cache.put('key2', 'data2');
      cache.get('key1'); // Access key1
      cache.put('key3', 'data3'); // Should evict key2
      
      // Then
      expect(cache.get('key1'), isNotNull);
      expect(cache.get('key2'), isNull);
      expect(cache.get('key3'), isNotNull);
    });
  });
}
```

### 4. Error Handling Tests

#### 4.1 API Exception 테스트
```dart
// test/backend/api/unit/models/api_exception_test.dart
void main() {
  group('ApiException Tests', () {
    test('should create exception with message', () {
      // Given
      const message = 'API Error';
      
      // When
      final exception = ApiException(message);
      
      // Then
      expect(exception.message, message);
      expect(exception.toString(), contains(message));
    });
    
    test('should parse from DioException', () {
      // Given
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
          data: {'error': 'Internal Server Error'},
        ),
      );
      
      // When
      final exception = ApiException.fromDioError(dioError);
      
      // Then
      expect(exception.statusCode, 500);
      expect(exception.message, contains('Internal Server Error'));
    });
  });
}
```

## 🔄 Integration Tests

### 1. API Flow 테스트
```dart
// test/backend/api/integration/api_flow_test.dart
void main() {
  group('API Flow Integration Tests', () {
    late DioClient client;
    late MockServer mockServer;
    
    setUpAll(() async {
      // Mock 서버 시작
      mockServer = await MockServer.start();
      
      // 테스트 환경 설정
      dotenv.testLoad(fileInput: '''
        API_BASE_URL=${mockServer.url}
        ALGOLIA_APP_ID=test_app
        ALGOLIA_API_KEY=test_key
      ''');
      
      // DI 설정
      await configureDependencies(Environment.test);
      
      client = getIt<IHttpClient>();
    });
    
    tearDownAll(() async {
      await mockServer.stop();
      getIt.reset();
    });
    
    test('should complete full authentication flow', () async {
      // Given
      mockServer.when(
        path: '/auth/login',
        method: 'POST',
      ).thenRespond(200, {
        'token': 'access_token',
        'refreshToken': 'refresh_token',
        'expiresIn': 3600,
      });
      
      // When
      final response = await client.post('/auth/login', data: {
        'email': 'test@example.com',
        'password': 'password123',
      });
      
      // Then
      expect(response.isSuccess, true);
      expect(response.data!['token'], 'access_token');
      
      // Verify token is used in subsequent requests
      mockServer.when(
        path: '/user/profile',
        method: 'GET',
      ).thenRespond(200, {'id': 'user123'});
      
      final profileResponse = await client.get('/user/profile');
      
      expect(profileResponse.isSuccess, true);
      expect(
        mockServer.lastRequest!.headers['authorization'],
        'Bearer access_token',
      );
    });
    
    test('should handle token refresh flow', () async {
      // Given - expired token
      mockServer.when(
        path: '/protected',
        method: 'GET',
      ).thenRespond(401, {'error': 'Token expired'});
      
      mockServer.when(
        path: '/auth/refresh',
        method: 'POST',
      ).thenRespond(200, {'token': 'new_token'});
      
      // When
      final response = await client.get('/protected');
      
      // Then - should retry with new token
      verify(mockServer.called('/auth/refresh')).called(1);
      expect(response.isSuccess, true);
    });
  });
}
```

### 2. Cache Flow 테스트
```dart
// test/backend/api/integration/cache_flow_test.dart
void main() {
  group('Cache Flow Integration Tests', () {
    late DioClient client;
    late CacheManager cacheManager;
    
    setUp(() async {
      await configureDependencies(Environment.test);
      client = getIt<IHttpClient>();
      cacheManager = getIt<CacheManager>();
    });
    
    test('should cache GET requests', () async {
      // Given
      final mockAdapter = DioAdapter(dio: client.dio);
      
      mockAdapter.onGet(
        '/cached-data',
        (server) => server.reply(200, {'data': 'test'}),
      );
      
      // When - First request
      final response1 = await client.get('/cached-data');
      
      // Then
      expect(response1.isSuccess, true);
      expect(cacheManager.contains('/cached-data'), true);
      
      // When - Second request (should be from cache)
      final response2 = await client.get('/cached-data');
      
      // Then
      expect(response2.isSuccess, true);
      expect(response2.data, equals(response1.data));
      verify(mockAdapter.onGet('/cached-data')).called(1); // Only once
    });
    
    test('should invalidate cache on POST', () async {
      // Given
      await client.get('/resource');
      expect(cacheManager.contains('/resource'), true);
      
      // When
      await client.post('/resource', data: {'update': true});
      
      // Then
      expect(cacheManager.contains('/resource'), false);
    });
  });
}
```

## 🎪 E2E Tests

### 1. 실제 API 테스트
```dart
// test/backend/api/e2e/real_api_test.dart
@Tags(['e2e'])
void main() {
  group('E2E API Tests', () {
    late DioClient client;
    
    setUpAll(() async {
      // 실제 테스트 서버 사용
      dotenv.testLoad(fileInput: '''
        API_BASE_URL=https://staging-api.versusspace.com
      ''');
      
      await configureDependencies(Environment.staging);
      client = getIt<IHttpClient>();
    });
    
    test('should connect to real server', () async {
      // When
      final response = await client.get('/health');
      
      // Then
      expect(response.isSuccess, true);
      expect(response.data!['status'], 'healthy');
    });
  }, skip: 'Only run in CI/CD pipeline');
}
```

## 🔬 Test Fixtures

### 1. Mock 데이터
```dart
// test/backend/api/fixtures/api_fixtures.dart
class ApiFixtures {
  static Map<String, dynamic> successResponse() => {
    'status': 'success',
    'data': {'id': 'test123'},
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  static Map<String, dynamic> errorResponse() => {
    'status': 'error',
    'message': 'Something went wrong',
    'code': 'ERR_001',
  };
  
  static Map<String, dynamic> paginatedResponse() => {
    'data': List.generate(10, (i) => {'id': i, 'name': 'Item $i'}),
    'pagination': {
      'page': 1,
      'perPage': 10,
      'total': 100,
      'totalPages': 10,
    },
  };
  
  static FormData multipartData() => FormData.fromMap({
    'file': MultipartFile.fromString(
      'test content',
      filename: 'test.txt',
    ),
    'metadata': jsonEncode({'type': 'document'}),
  });
}
```

### 2. Mock Server
```dart
// test/backend/api/fixtures/mock_server.dart
class MockServer {
  final int port;
  late HttpServer _server;
  final Map<String, dynamic Function(HttpRequest)> _routes = {};
  
  MockServer._(this.port);
  
  static Future<MockServer> start({int port = 8080}) async {
    final server = MockServer._(port);
    server._server = await HttpServer.bind('localhost', port);
    server._listen();
    return server;
  }
  
  void when({
    required String path,
    required String method,
  }) => _RouteBuilder(this, path, method);
  
  void _listen() {
    _server.listen((request) async {
      final key = '${request.method}:${request.uri.path}';
      final handler = _routes[key];
      
      if (handler != null) {
        final response = handler(request);
        request.response
          ..statusCode = response['status'] ?? 200
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(response['body']));
      } else {
        request.response
          ..statusCode = 404
          ..write('Not Found');
      }
      
      await request.response.close();
    });
  }
  
  Future<void> stop() async {
    await _server.close();
  }
}
```

## 📈 테스트 커버리지 목표

### 최소 커버리지 요구사항
```yaml
# coverage.yaml
min_coverage:
  global: 85
  per_file:
    - path: lib/backend/api/clients/
      min: 95
    - path: lib/backend/api/interceptors/
      min: 90
    - path: lib/backend/api/cache/
      min: 85
    - path: lib/backend/api/models/
      min: 90
```

### 커버리지 실행
```bash
# 커버리지 측정
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 커버리지 확인
lcov --list coverage/lcov.info
```

## 🏃 테스트 실행 전략

### 로컬 개발
```bash
# Unit 테스트만
flutter test test/backend/api/unit/

# Integration 테스트 포함
flutter test test/backend/api/

# 특정 테스트만
flutter test test/backend/api/unit/clients/dio_client_test.dart
```

### CI/CD 파이프라인
```yaml
# .github/workflows/test.yml
name: API Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        
      - name: Install dependencies
        run: flutter pub get
        
      - name: Run tests with coverage
        run: flutter test --coverage test/backend/api/
        
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
          
      - name: Check minimum coverage
        run: |
          coverage=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$coverage < 85" | bc -l) )); then
            echo "Coverage $coverage% is below minimum 85%"
            exit 1
          fi
```

## ✅ 테스트 체크리스트

### Unit Tests
- [ ] DioClient 모든 HTTP 메서드
- [ ] 모든 Interceptor 로직
- [ ] Cache 저장/조회/만료
- [ ] Error 처리 및 변환
- [ ] Model 직렬화/역직렬화

### Integration Tests
- [ ] 전체 API 호출 플로우
- [ ] 인증 플로우
- [ ] 캐시 플로우
- [ ] 에러 복구 플로우

### E2E Tests
- [ ] 실제 서버 연결
- [ ] 프로덕션 시나리오
- [ ] 성능 벤치마크

## 🎯 Best Practices

### 1. 테스트 명명 규칙
```dart
// Good
test('should return success response when valid data is provided', () {});
test('should throw ApiException when network error occurs', () {});

// Bad
test('test1', () {});
test('error test', () {});
```

### 2. AAA 패턴 사용
```dart
test('should do something', () {
  // Arrange (Given)
  final input = TestData();
  
  // Act (When)
  final result = sut.method(input);
  
  // Assert (Then)
  expect(result, expected);
});
```

### 3. Mock 최소화
```dart
// Prefer fakes over mocks when possible
class FakeAuthService implements IAuthService {
  String? token;
  
  @override
  Future<String?> getAccessToken() async => token;
}
```

---

*이 문서는 Backend API 레이어의 포괄적인 테스트 전략을 제공합니다.*  
*85% 이상의 테스트 커버리지를 목표로 안정적인 API 레이어를 구축합니다.*