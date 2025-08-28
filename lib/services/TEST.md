# 🧪 Services 레이어 통합 테스트 전략

> 전역 인프라 서비스의 품질 보증을 위한 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 85%

## 📋 테스트 핵심 원칙

### 1. 테스트 피라미드
```
         /\
        /e2e\       5% - End-to-End 테스트
       /------\
      /통합 테스트\    25% - Integration 테스트
     /------------\
    /  단위 테스트   \  70% - Unit 테스트
   /________________\
```

### 2. 테스트 우선순위
1. **보안 Critical**: API 키 보호, 인증
2. **핵심 기능**: 캐싱, 콘텐츠 검열
3. **성능**: 응답 시간, 병렬 처리
4. **엣지 케이스**: 에러 처리, 복구

## 🎯 서비스별 테스트 전략

### 1. Cache Service (목표: 90%)

#### 단위 테스트
```dart
// test/services/cache/cache_service_test.dart
@GenerateMocks([ICacheLayer, ICacheAdapter])
void main() {
  group('CacheService Unit Tests', () {
    late CacheServiceImpl cache;
    late MockICacheLayer mockMemoryLayer;
    late MockICacheLayer mockHiveLayer;
    late MockICacheAdapter mockAdapter;
    
    setUp(() {
      mockMemoryLayer = MockICacheLayer();
      mockHiveLayer = MockICacheLayer();
      mockAdapter = MockICacheAdapter();
      
      cache = CacheServiceImpl(
        memoryLayer: mockMemoryLayer,
        hiveLayer: mockHiveLayer,
      );
      cache.registerAdapter<TestData>(mockAdapter);
    });
    
    test('should retrieve from L1 when available', () async {
      // Given
      final testData = TestData(id: '1', value: 'test');
      when(mockMemoryLayer.get('key')).thenAnswer((_) async => testData.toJson());
      when(mockAdapter.fromJson(any)).thenReturn(testData);
      
      // When
      final result = await cache.get<TestData>('key');
      
      // Then
      expect(result, equals(testData));
      verifyNever(mockHiveLayer.get(any));
    });
    
    test('should promote from L2 to L1 on miss', () async {
      // Given
      when(mockMemoryLayer.get('key')).thenAnswer((_) async => null);
      when(mockHiveLayer.get('key')).thenAnswer((_) async => {'id': '1'});
      
      // When
      await cache.get<TestData>('key');
      
      // Then
      verify(mockMemoryLayer.set('key', any)).called(1);
    });
    
    test('should handle concurrent requests', () async {
      // Given
      final futures = List.generate(
        10,
        (_) => cache.get<TestData>('same_key'),
      );
      
      // When
      final results = await Future.wait(futures);
      
      // Then
      verify(mockMemoryLayer.get('same_key')).called(1);
    });
  });
  
  group('LRU Memory Cache Tests', () {
    test('should evict least recently used', () async {
      final cache = SimpleMemoryCache(maxSize: 3);
      
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');
      
      // Access key1 to make it recently used
      cache.get('key1');
      
      // Add key4, should evict key2
      cache.set('key4', 'value4');
      
      expect(cache.get('key1'), isNotNull);
      expect(cache.get('key2'), isNull);
      expect(cache.get('key3'), isNotNull);
      expect(cache.get('key4'), isNotNull);
    });
  });
}
```

#### 통합 테스트
```dart
// test/services/cache/cache_integration_test.dart
void main() {
  group('Cache Service Integration', () {
    late CacheServiceImpl cache;
    
    setUpAll(() async {
      await Hive.initFlutter();
      cache = CacheServiceImpl();
    });
    
    tearDownAll(() async {
      await Hive.close();
    });
    
    test('should persist data across layers', () async {
      // Save to cache
      await cache.set('test_key', TestData(id: '1', value: 'test'));
      
      // Clear memory cache
      cache.clearMemory();
      
      // Should still retrieve from L2
      final result = await cache.get<TestData>('test_key');
      expect(result, isNotNull);
      expect(result?.value, equals('test'));
    });
  });
}
```

#### 성능 테스트
```dart
// test/services/cache/cache_performance_test.dart
void main() {
  test('should meet performance targets', () async {
    final cache = CacheServiceImpl();
    
    // Warm up cache
    await cache.set('key', TestData());
    
    // Measure L1 performance
    final l1Start = DateTime.now();
    for (int i = 0; i < 1000; i++) {
      await cache.get<TestData>('key');
    }
    final l1Duration = DateTime.now().difference(l1Start);
    
    expect(l1Duration.inMilliseconds / 1000, lessThan(10)); // <10ms avg
  });
}
```

### 2. Moderation Service (목표: 85%)

#### 단위 테스트
```dart
// test/services/moderation/moderation_service_test.dart
@GenerateMocks([IPerspectiveApiClient, ICloudVisionClient, IGeminiClient])
void main() {
  group('ModerationService Unit Tests', () {
    late ModerationServiceImpl service;
    late MockIPerspectiveApiClient mockPerspective;
    late MockICloudVisionClient mockVision;
    late MockIGeminiClient mockGemini;
    
    setUp(() {
      mockPerspective = MockIPerspectiveApiClient();
      mockVision = MockICloudVisionClient();
      mockGemini = MockIGeminiClient();
      
      service = ModerationServiceImpl(
        perspectiveApi: mockPerspective,
        visionApi: mockVision,
        geminiApi: mockGemini,
      );
    });
    
    test('should reject toxic text', () async {
      // Given
      when(mockPerspective.analyzeText(any)).thenAnswer(
        (_) async => PerspectiveResult(toxicity: 0.9),
      );
      
      // When
      final result = await service.moderateText('toxic content');
      
      // Then
      expect(result.isValid, isFalse);
      expect(result.reason, contains('toxic'));
    });
    
    test('should process images in parallel', () async {
      // Given
      final images = List.generate(5, (i) => 'image$i.jpg');
      when(mockVision.analyzeImage(any)).thenAnswer(
        (_) async => Future.delayed(
          Duration(milliseconds: 100),
          () => ImageSafetyResult(safe: true),
        ),
      );
      
      // When
      final stopwatch = Stopwatch()..start();
      final results = await service.moderateImages(images);
      stopwatch.stop();
      
      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Parallel
      expect(results.every((r) => r.safe), isTrue);
    });
  });
  
  group('API Key Security Tests', () {
    test('should not expose API keys', () {
      final service = ModerationServiceImpl();
      final serialized = service.toString();
      
      expect(serialized, isNot(contains('AIza')));
      expect(serialized, isNot(contains('sk-')));
    });
    
    test('should load from environment', () {
      expect(EnvConfig.perspectiveApiKey, isNotEmpty);
      expect(EnvConfig.perspectiveApiKey, isNot(contains('PLACEHOLDER')));
    });
  });
}
```

#### 에러 처리 테스트
```dart
// test/services/moderation/moderation_error_test.dart
void main() {
  group('Moderation Error Handling', () {
    test('should handle API timeout', () async {
      final service = ModerationServiceImpl(
        perspectiveApi: TimeoutMockClient(),
      );
      
      final result = await service.moderateText('test');
      
      expect(result.isValid, isTrue); // Fail open
      expect(result.warning, contains('timeout'));
    });
    
    test('should retry on transient errors', () async {
      int attempts = 0;
      final service = ModerationServiceImpl(
        perspectiveApi: RetryMockClient(
          onCall: () {
            attempts++;
            if (attempts < 3) throw NetworkException();
            return PerspectiveResult(toxicity: 0.1);
          },
        ),
      );
      
      final result = await service.moderateText('test');
      
      expect(attempts, equals(3));
      expect(result.isValid, isTrue);
    });
  });
}
```

### 3. UI Service (목표: 80%)

#### 단위 테스트
```dart
// test/services/ui/responsive_service_test.dart
void main() {
  group('ResponsiveService Tests', () {
    test('should detect device type correctly', () {
      final context320 = MockBuildContext(width: 320);
      final context768 = MockBuildContext(width: 768);
      final context1024 = MockBuildContext(width: 1024);
      
      expect(ResponsiveService.isMobile(context320), isTrue);
      expect(ResponsiveService.isTablet(context768), isTrue);
      expect(ResponsiveService.isDesktop(context1024), isTrue);
    });
    
    test('should calculate box sizes', () {
      final calculator = UnifiedBoxCalculator();
      
      final sizes = calculator.calculate(
        containerWidth: 400,
        containerHeight: 600,
        layoutType: LayoutType.horizontal,
        aspectRatios: [16/9, 16/9],
      );
      
      expect(sizes.boxAWidth, closeTo(196, 1));
      expect(sizes.boxBWidth, closeTo(196, 1));
      expect(sizes.spacing, equals(8));
    });
  });
}
```

#### Widget 테스트
```dart
// test/services/ui/ui_widget_test.dart
void main() {
  testWidgets('should adapt layout to screen size', (tester) async {
    // Mobile size
    await tester.binding.setSurfaceSize(Size(320, 640));
    await tester.pumpWidget(TestApp());
    
    expect(find.byType(MobileLayout), findsOneWidget);
    
    // Tablet size
    await tester.binding.setSurfaceSize(Size(768, 1024));
    await tester.pump();
    
    expect(find.byType(TabletLayout), findsOneWidget);
  });
}
```

### 4. Content Service (목표: 85%)

#### 단위 테스트
```dart
// test/services/content/content_service_test.dart
void main() {
  group('ContentService Tests', () {
    late ContentServiceImpl service;
    
    setUp(() {
      service = ContentServiceImpl();
    });
    
    test('should generate valid content', () async {
      final params = GenerationParams(
        type: ContentType.post,
        template: 'versus',
      );
      
      final content = await service.generate(params);
      
      expect(content.type, equals(ContentType.post));
      expect(content.data['optionA'], isNotNull);
      expect(content.data['optionB'], isNotNull);
    });
    
    test('should validate content structure', () async {
      final validContent = Content(
        type: ContentType.post,
        data: {
          'title': 'Test',
          'optionA': 'A',
          'optionB': 'B',
        },
      );
      
      final invalidContent = Content(
        type: ContentType.post,
        data: {'title': 'Test'}, // Missing options
      );
      
      expect(await service.validate(validContent), isTrue);
      expect(await service.validate(invalidContent), isFalse);
    });
    
    test('should transform content', () async {
      final original = Content(
        type: ContentType.text,
        data: {'text': 'HELLO'},
      );
      
      final transformed = await service.transform(
        original,
        TransformationType.lowercase,
      );
      
      expect(transformed.data['text'], equals('hello'));
    });
  });
}
```

### 5. Image Service (목표: 85%)

#### 단위 테스트
```dart
// test/services/image/image_service_test.dart
void main() {
  group('ImageService Tests', () {
    late ImageServiceImpl service;
    
    setUp(() {
      service = ImageServiceImpl();
    });
    
    test('should compress image', () async {
      final testImage = await loadTestImage('test_image.jpg');
      
      final compressed = await service.compress(
        testImage,
        quality: 85,
      );
      
      expect(compressed.lengthInBytes, lessThan(testImage.lengthInBytes));
    });
    
    test('should generate multiple sizes', () async {
      final testImage = await loadTestImage('test_image.jpg');
      
      final processed = await service.process(
        ProcessImageParams(
          file: testImage,
          sizes: [800, 400, 150],
        ),
      );
      
      expect(processed.original, isNotNull);
      expect(processed.display, isNotNull);
      expect(processed.thumbnail, isNotNull);
    });
    
    test('should handle concurrent processing', () async {
      final images = List.generate(10, (i) => loadTestImage('image$i.jpg'));
      
      final stopwatch = Stopwatch()..start();
      final results = await Future.wait(
        images.map((img) async => service.process(
          ProcessImageParams(file: await img),
        )),
      );
      stopwatch.stop();
      
      expect(results.length, equals(10));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
```

### 6. Logger Service (목표: 90%)

#### 단위 테스트
```dart
// test/services/logger/logger_service_test.dart
void main() {
  group('LoggerService Tests', () {
    late LoggerServiceImpl logger;
    late MockLogOutput mockOutput;
    
    setUp(() {
      mockOutput = MockLogOutput();
      logger = LoggerServiceImpl(output: mockOutput);
    });
    
    test('should log with correct level', () {
      logger.debug('Debug message');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');
      
      verify(mockOutput.output(LogLevel.debug, any)).called(1);
      verify(mockOutput.output(LogLevel.info, any)).called(1);
      verify(mockOutput.output(LogLevel.warning, any)).called(1);
      verify(mockOutput.output(LogLevel.error, any)).called(1);
    });
    
    test('should include metadata', () {
      logger.info('User action', metadata: {
        'userId': '123',
        'action': 'login',
      });
      
      final captured = verify(
        mockOutput.output(any, captureAny),
      ).captured.single;
      
      expect(captured.metadata['userId'], equals('123'));
      expect(captured.metadata['action'], equals('login'));
    });
    
    test('should format stack traces', () {
      try {
        throw Exception('Test error');
      } catch (e, stackTrace) {
        logger.error('Error occurred', error: e, stackTrace: stackTrace);
      }
      
      final captured = verify(
        mockOutput.output(LogLevel.error, captureAny),
      ).captured.single;
      
      expect(captured.stackTrace, contains('test/services/logger'));
    });
  });
}
```

## 🔄 통합 테스트

### 서비스 간 통합
```dart
// test/integration/services_integration_test.dart
void main() {
  group('Services Integration', () {
    late ICacheService cache;
    late IModerationService moderation;
    late IImageService imageService;
    late ILoggerService logger;
    
    setUpAll(() {
      setupServiceLocator();
      cache = getIt<ICacheService>();
      moderation = getIt<IModerationService>();
      imageService = getIt<IImageService>();
      logger = getIt<ILoggerService>();
    });
    
    test('should moderate and cache content', () async {
      // Moderate content
      final result = await moderation.moderateContent(
        'Test content',
        images: ['image1.jpg'],
      );
      
      // Cache result
      await cache.set('moderation_result', result);
      
      // Log action
      logger.info('Content moderated', metadata: {
        'contentId': 'test',
        'result': result.isValid,
      });
      
      // Verify cache
      final cached = await cache.get<ModerationResult>('moderation_result');
      expect(cached, equals(result));
    });
    
    test('should process image with caching', () async {
      // Process image
      final processed = await imageService.process(
        ProcessImageParams(file: testImage),
      );
      
      // Cache processed images
      await cache.set('image_original', processed.original);
      await cache.set('image_thumbnail', processed.thumbnail);
      
      // Verify cache hit
      final stats = cache.getStatistics();
      expect(stats.hitRate, greaterThan(0));
    });
  });
}
```

## 🎭 Mock & Stub 전략

### Mock 생성
```dart
// test/mocks/service_mocks.dart
@GenerateMocks([
  ICacheService,
  IModerationService,
  IImageService,
  ILoggerService,
  IContentService,
  IUIService,
])
void main() {}
```

### Test Doubles
```dart
// test/doubles/fake_cache_service.dart
class FakeCacheService implements ICacheService {
  final Map<String, dynamic> _data = {};
  
  @override
  Future<T?> get<T>(String key) async {
    return _data[key] as T?;
  }
  
  @override
  Future<void> set<T>(String key, T value, {Duration? ttl}) async {
    _data[key] = value;
  }
}
```

## 📊 테스트 커버리지 목표

| 서비스 | 단위 테스트 | 통합 테스트 | E2E | 전체 목표 |
|--------|------------|------------|-----|-----------|
| Cache | 70% | 15% | 5% | **90%** |
| Moderation | 65% | 15% | 5% | **85%** |
| UI | 60% | 15% | 5% | **80%** |
| Content | 65% | 15% | 5% | **85%** |
| Image | 65% | 15% | 5% | **85%** |
| Logger | 70% | 15% | 5% | **90%** |
| **전체** | **65%** | **15%** | **5%** | **85%** |

## ⚡ 성능 테스트

### 벤치마크 목표
```dart
// test/performance/benchmark_test.dart
void main() {
  group('Performance Benchmarks', () {
    test('Cache Service', () async {
      expect(cacheGetTime, lessThan(Duration(milliseconds: 10)));
      expect(cacheSetTime, lessThan(Duration(milliseconds: 20)));
    });
    
    test('Moderation Service', () async {
      expect(textModerationTime, lessThan(Duration(milliseconds: 200)));
      expect(imageModerationTime, lessThan(Duration(milliseconds: 500)));
    });
    
    test('Image Service', () async {
      expect(compressionTime, lessThan(Duration(milliseconds: 100)));
      expect(thumbnailTime, lessThan(Duration(milliseconds: 50)));
    });
  });
}
```

## 🔒 보안 테스트

### API 키 보안
```dart
// test/security/api_key_test.dart
void main() {
  test('should not expose API keys in logs', () {
    final logger = LoggerServiceImpl();
    logger.info('API call', metadata: {'key': 'secret'});
    
    final logs = logger.getLogs();
    expect(logs, isNot(contains('secret')));
  });
  
  test('should sanitize error messages', () {
    final error = ApiException('Invalid key: AIzaSy123');
    final sanitized = ErrorSanitizer.sanitize(error);
    
    expect(sanitized.message, isNot(contains('AIzaSy')));
  });
}
```

## 🚀 CI/CD 통합

### GitHub Actions
```yaml
# .github/workflows/test.yml
name: Test Services

on: [push, pull_request]

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
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check coverage
        run: |
          coverage=$(lcov --summary coverage/lcov.info | grep "lines" | sed 's/.*: \(.*\)%.*/\1/')
          if (( $(echo "$coverage < 85" | bc -l) )); then
            echo "Coverage $coverage% is below 85%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## 📝 테스트 문서화

### 테스트 케이스 템플릿
```dart
/// Test: [기능명]
/// 
/// Given: [전제 조건]
/// When: [실행 동작]
/// Then: [예상 결과]
/// 
/// Coverage: [커버하는 요구사항]
/// Priority: [High/Medium/Low]
test('should [동작 설명]', () async {
  // Given
  
  // When
  
  // Then
});
```

## 🏁 테스트 체크리스트

### 각 서비스별 필수 테스트
- [ ] **기본 기능 테스트**
  - [ ] Happy path
  - [ ] Error cases
  - [ ] Edge cases
  - [ ] Null safety

- [ ] **성능 테스트**
  - [ ] 응답 시간
  - [ ] 동시성
  - [ ] 메모리 사용량
  - [ ] 부하 테스트

- [ ] **보안 테스트**
  - [ ] Input validation
  - [ ] API key protection
  - [ ] Error message sanitization
  - [ ] Access control

- [ ] **통합 테스트**
  - [ ] Service dependencies
  - [ ] Data flow
  - [ ] Error propagation
  - [ ] Transaction handling

## 📚 참고 자료

### 테스트 가이드
- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage Best Practices](https://codecov.io/blog/flutter-test-coverage/)

### 서비스별 테스트 문서
- [Cache Service Tests](./cache/TEST.md)
- [Moderation Service Tests](./moderation/TEST.md)
- [UI Service Tests](./ui/TEST.md)

---

*이 문서는 Services 레이어의 종합적인 테스트 전략을 정의합니다.*  
*85% 이상의 테스트 커버리지로 안정적인 서비스 품질을 보장합니다.*