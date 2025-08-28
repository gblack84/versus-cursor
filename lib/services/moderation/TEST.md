# 🧪 Moderation Service 테스트 전략

> Moderation Service의 테스트 전략 및 구현 가이드  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Moderation Service는 Versus Space의 **전역 인프라 서비스**로서, 모든 Feature에 영향을 미치는 중요한 컴포넌트입니다. 외부 API 통합과 보안이 핵심이므로 철저한 테스트가 필수적입니다.

## 🎯 테스트 원칙

### Services Layer 테스트 특성
1. **격리된 테스트**: Feature 의존성 없이 독립적으로 테스트
2. **Mock 사용**: 외부 API는 Mock으로 대체
3. **보안 중심**: API 키 보안 및 실패 처리 검증
4. **성능 측정**: 응답 시간 및 처리량 테스트

## 🏗️ 테스트 구조

```
test/services/moderation/
├── unit/                           # 단위 테스트
│   ├── perspective_api_test.dart
│   ├── cloud_vision_test.dart
│   ├── toxic_patterns_test.dart
│   ├── image_optimizer_test.dart
│   └── moderation_cache_test.dart
│
├── integration/                    # 통합 테스트
│   ├── text_moderation_test.dart
│   ├── image_moderation_test.dart
│   ├── batch_processing_test.dart
│   └── firebase_integration_test.dart
│
├── performance/                    # 성능 테스트
│   ├── api_response_time_test.dart
│   ├── batch_throughput_test.dart
│   ├── cache_efficiency_test.dart
│   └── memory_usage_test.dart
│
├── security/                       # 보안 테스트
│   ├── api_key_security_test.dart
│   ├── failure_handling_test.dart
│   └── toxic_detection_test.dart
│
├── fixtures/                       # 테스트 데이터
│   ├── sample_texts.dart
│   ├── toxic_texts.dart
│   ├── test_images.dart
│   └── api_responses.json
│
└── helpers/                        # 테스트 헬퍼
    ├── mock_api_client.dart
    ├── test_data_builder.dart
    └── performance_monitor.dart
```

## 🧪 단위 테스트

### 1. Perspective API 테스트

```dart
// test/services/moderation/unit/perspective_api_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

@GenerateMocks([http.Client, ApiKeyManager])
void main() {
  group('PerspectiveApiService - Services Layer', () {
    late MockClient mockClient;
    late MockApiKeyManager mockKeyManager;
    late PerspectiveApiDatasource datasource;
    
    setUp(() {
      mockClient = MockClient();
      mockKeyManager = MockApiKeyManager();
      datasource = PerspectiveApiDatasource(mockClient, mockKeyManager);
      
      when(mockKeyManager.perspectiveApiKey).thenReturn('test_key');
    });
    
    group('텍스트 독성 분석', () {
      test('정상 텍스트는 통과해야 함', () async {
        // Given
        const text = '안녕하세요';
        final mockResponse = {
          'attributeScores': {
            'TOXICITY': {'summaryScore': {'value': 0.1}},
            'PROFANITY': {'summaryScore': {'value': 0.0}},
          }
        };
        
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));
        
        // When
        final result = await datasource.analyzeComment(text);
        
        // Then
        expect(result['attributeScores'], isNotNull);
        verify(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body'))).called(1);
      });
      
      test('독성 텍스트는 차단되어야 함', () async {
        // Given
        const text = '욕설 포함 텍스트';
        final mockResponse = {
          'attributeScores': {
            'TOXICITY': {'summaryScore': {'value': 0.9}},
            'PROFANITY': {'summaryScore': {'value': 0.8}},
          }
        };
        
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(json.encode(mockResponse), 200));
        
        // When
        final result = await datasource.analyzeComment(text);
        final toxicityScore = result['attributeScores']['TOXICITY']['summaryScore']['value'];
        
        // Then
        expect(toxicityScore, greaterThan(0.7));
      });
      
      test('API 에러 시 예외를 발생시켜야 함', () async {
        // Given
        const text = '테스트 텍스트';
        
        when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Error', 500));
        
        // When & Then
        expect(
          () => datasource.analyzeComment(text),
          throwsA(isA<ModerationException>()),
        );
      });
    });
    
    group('API 키 보안', () {
      test('API 키가 환경 변수에서 로드되어야 함', () {
        // Given & When
        final apiKey = mockKeyManager.perspectiveApiKey;
        
        // Then
        expect(apiKey, isNotNull);
        expect(apiKey, isNot(contains('AIzaSy'))); // 실제 키가 아니어야 함
        verify(mockKeyManager.perspectiveApiKey).called(1);
      });
      
      test('API 키가 없으면 예외를 발생시켜야 함', () {
        // Given
        when(mockKeyManager.perspectiveApiKey).thenReturn('');
        
        // When & Then
        expect(
          () => datasource.analyzeComment('test'),
          throwsA(isA<ModerationException>()),
        );
      });
    });
  });
}
```

### 2. 한국어 욕설 패턴 테스트

```dart
// test/services/moderation/unit/toxic_patterns_test.dart
void main() {
  group('한국어 욕설 패턴 감지', () {
    late ToxicPatterns patterns;
    
    setUp(() {
      patterns = ToxicPatterns();
    });
    
    test('일반 욕설 감지', () {
      final testCases = [
        '씨발',
        '병신',
        '개새끼',
        '지랄',
      ];
      
      for (final text in testCases) {
        final result = patterns.detectToxicSpans(text);
        expect(result, isNotEmpty, reason: '$text가 감지되지 않음');
      }
    });
    
    test('변형 패턴 감지', () {
      final testCases = [
        'ㅅㅣㅂㅏㄹ',  // 자음모음 분리
        '시1발',       // 숫자 혼합
        '씨 발',       // 공백 삽입
        'ㅂㅕㅇㅅㅣㄴ',  // 자음모음 분리
      ];
      
      for (final text in testCases) {
        final result = patterns.detectToxicSpans(text);
        expect(result, isNotEmpty, reason: '$text 패턴이 감지되지 않음');
      }
    });
    
    test('정상 텍스트는 감지하지 않아야 함', () {
      final testCases = [
        '안녕하세요',
        '반갑습니다',
        '좋은 하루 되세요',
      ];
      
      for (final text in testCases) {
        final result = patterns.detectToxicSpans(text);
        expect(result, isEmpty, reason: '$text가 잘못 감지됨');
      }
    });
  });
}
```

### 3. 캐시 테스트

```dart
// test/services/moderation/unit/moderation_cache_test.dart
void main() {
  group('ModerationCache', () {
    late ModerationCache cache;
    
    setUp(() {
      cache = ModerationCache(
        ttl: const Duration(seconds: 1),
        maxSize: 3,
      );
    });
    
    test('캐시 저장 및 조회', () async {
      // Given
      const key = 'test_text';
      final result = ModerationResult(
        isApproved: true,
        severity: SeverityLevel.none,
        timestamp: DateTime.now(),
      );
      
      // When
      await cache.set(key, result);
      final cached = await cache.get(key);
      
      // Then
      expect(cached, isNotNull);
      expect(cached!.isApproved, true);
    });
    
    test('TTL 만료 시 null 반환', () async {
      // Given
      const key = 'test_text';
      final result = ModerationResult(
        isApproved: true,
        severity: SeverityLevel.none,
        timestamp: DateTime.now(),
      );
      
      // When
      await cache.set(key, result);
      await Future.delayed(const Duration(seconds: 2));
      final cached = await cache.get(key);
      
      // Then
      expect(cached, isNull);
    });
    
    test('LRU 제거', () async {
      // Given
      for (int i = 0; i < 4; i++) {
        await cache.set(
          'key_$i',
          ModerationResult(
            isApproved: true,
            severity: SeverityLevel.none,
            timestamp: DateTime.now(),
          ),
        );
      }
      
      // When
      final firstKey = await cache.get('key_0');
      final lastKey = await cache.get('key_3');
      
      // Then
      expect(firstKey, isNull); // 첫 번째 키는 제거됨
      expect(lastKey, isNotNull); // 마지막 키는 유지됨
    });
  });
}
```

## 🔄 통합 테스트

### 1. 텍스트 검열 통합 테스트

```dart
// test/services/moderation/integration/text_moderation_test.dart
void main() {
  group('TextModerationRepository 통합', () {
    late TextModerationRepository repository;
    late MockPerspectiveApiDatasource mockDatasource;
    late ModerationCache cache;
    
    setUp(() {
      mockDatasource = MockPerspectiveApiDatasource();
      cache = ModerationCache();
      repository = TextModerationRepositoryImpl(
        mockDatasource,
        cache,
        ToxicPatterns(),
      );
    });
    
    test('여러 텍스트 병렬 처리', () async {
      // Given
      final texts = {
        'title': '제목입니다',
        'content': '본문 내용입니다',
        'comment': '댓글입니다',
      };
      
      when(mockDatasource.analyzeComment(any))
        .thenAnswer((_) async => {
          'attributeScores': {
            'TOXICITY': {'summaryScore': {'value': 0.1}},
          }
        });
      
      // When
      final startTime = DateTime.now();
      final results = await repository.analyzeMultiple(texts);
      final duration = DateTime.now().difference(startTime);
      
      // Then
      expect(results.length, 3);
      expect(duration.inSeconds, lessThan(1)); // 병렬 처리로 1초 이내
      results.forEach((key, result) {
        expect(result.isApproved, true);
      });
    });
    
    test('API 실패 시 차단 처리', () async {
      // Given
      when(mockDatasource.analyzeComment(any))
        .thenThrow(ModerationException('API Error'));
      
      // When
      final result = await repository.analyzeText('test');
      
      // Then
      expect(result.isApproved, false); // 안전 우선: 차단
      expect(result.severity, SeverityLevel.high);
    });
  });
}
```

### 2. 이미지 검열 통합 테스트

```dart
// test/services/moderation/integration/image_moderation_test.dart
void main() {
  group('ImageModerationRepository 통합', () {
    late ImageModerationRepository repository;
    late MockCloudVisionDatasource mockDatasource;
    late ImageOptimizer optimizer;
    
    setUp(() {
      mockDatasource = MockCloudVisionDatasource();
      optimizer = ImageOptimizer();
      repository = ImageModerationRepositoryImpl(
        mockDatasource,
        optimizer,
      );
    });
    
    test('이미지 최적화 및 검열', () async {
      // Given
      final imageBytes = await loadTestImage('test_image.jpg');
      
      when(mockDatasource.analyzeImage(any))
        .thenAnswer((_) async => {
          'isAppropriate': true,
          'adult': 'UNLIKELY',
          'violence': 'VERY_UNLIKELY',
        });
      
      // When
      final result = await repository.checkImage(imageBytes);
      
      // Then
      expect(result.isApproved, true);
      verify(mockDatasource.analyzeImage(any)).called(1);
    });
    
    test('여러 이미지 병렬 처리', () async {
      // Given
      final images = await Future.wait([
        loadTestImage('image1.jpg'),
        loadTestImage('image2.jpg'),
        loadTestImage('image3.jpg'),
      ]);
      
      when(mockDatasource.analyzeImage(any))
        .thenAnswer((_) async => {
          'isAppropriate': true,
          'adult': 'UNLIKELY',
        });
      
      // When
      final startTime = DateTime.now();
      final results = await repository.checkMultipleImages(images);
      final duration = DateTime.now().difference(startTime);
      
      // Then
      expect(results.length, 3);
      expect(duration.inSeconds, lessThan(2)); // 병렬 처리
    });
  });
}
```

## ⚡ 성능 테스트

### 1. API 응답 시간 테스트

```dart
// test/services/moderation/performance/api_response_time_test.dart
void main() {
  group('API 응답 시간', () {
    late ModerationService service;
    late PerformanceMonitor monitor;
    
    setUp(() {
      service = getIt<ModerationService>();
      monitor = PerformanceMonitor();
    });
    
    test('텍스트 검열 응답 시간', () async {
      final times = <Duration>[];
      
      for (int i = 0; i < 100; i++) {
        final text = 'Test text $i';
        final stopwatch = Stopwatch()..start();
        
        await service.checkContent(text: text);
        
        stopwatch.stop();
        times.add(stopwatch.elapsed);
      }
      
      // P95 계산
      times.sort();
      final p95 = times[95];
      
      expect(p95.inMilliseconds, lessThan(200)); // P95 < 200ms
    });
    
    test('캐시 히트율 측정', () async {
      final texts = List.generate(50, (i) => 'Text ${i % 10}'); // 10개 반복
      var cacheHits = 0;
      
      for (final text in texts) {
        final stopwatch = Stopwatch()..start();
        await service.checkContent(text: text);
        stopwatch.stop();
        
        // 캐시된 경우 10ms 이하
        if (stopwatch.elapsedMilliseconds < 10) {
          cacheHits++;
        }
      }
      
      final hitRate = cacheHits / texts.length;
      expect(hitRate, greaterThan(0.6)); // 60% 이상 캐시 히트
    });
  });
}
```

### 2. 메모리 사용량 테스트

```dart
// test/services/moderation/performance/memory_usage_test.dart
void main() {
  group('메모리 사용량', () {
    test('대량 텍스트 처리 시 메모리 사용', () async {
      final service = getIt<ModerationService>();
      final initialMemory = getCurrentMemoryUsage();
      
      // 1000개 텍스트 처리
      for (int i = 0; i < 1000; i++) {
        await service.checkContent(text: 'Test text $i');
      }
      
      final finalMemory = getCurrentMemoryUsage();
      final increase = finalMemory - initialMemory;
      
      expect(increase, lessThan(10 * 1024 * 1024)); // 10MB 미만
    });
    
    test('캐시 메모리 관리', () async {
      final cache = ModerationCache(maxSize: 100);
      final initialMemory = getCurrentMemoryUsage();
      
      // 200개 항목 추가 (최대 100개 유지)
      for (int i = 0; i < 200; i++) {
        await cache.set(
          'key_$i',
          ModerationResult(
            isApproved: true,
            severity: SeverityLevel.none,
            timestamp: DateTime.now(),
          ),
        );
      }
      
      final finalMemory = getCurrentMemoryUsage();
      final usage = finalMemory - initialMemory;
      
      expect(usage, lessThan(5 * 1024 * 1024)); // 5MB 미만
    });
  });
}
```

## 🔐 보안 테스트

### 1. API 키 보안 테스트

```dart
// test/services/moderation/security/api_key_security_test.dart
void main() {
  group('API 키 보안', () {
    test('소스 코드에 API 키가 없어야 함', () {
      // Given
      final sourceFiles = Directory('lib/services/moderation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
      
      // When & Then
      for (final file in sourceFiles) {
        final content = file.readAsStringSync();
        
        // API 키 패턴 검사
        expect(content, isNot(contains('AIzaSy'))); // Google API 키 패턴
        expect(content, isNot(contains('sk-'))); // OpenAI API 키 패턴
        expect(content, isNot(matches(RegExp(r'[a-zA-Z0-9]{32,}')))); // 긴 키 패턴
      }
    });
    
    test('환경 변수에서 API 키 로드', () {
      // Given
      final keyManager = ApiKeyManager();
      
      // When
      final perspectiveKey = keyManager.perspectiveApiKey;
      final visionKey = keyManager.cloudVisionApiKey;
      
      // Then
      expect(perspectiveKey, isNotEmpty);
      expect(visionKey, isNotEmpty);
      expect(perspectiveKey, isNot(equals(visionKey)));
    });
  });
}
```

### 2. 실패 처리 테스트

```dart
// test/services/moderation/security/failure_handling_test.dart
void main() {
  group('실패 처리', () {
    test('API 실패 시 차단이 기본값', () async {
      // Given
      final service = ModerationService(
        MockFailingTextRepository(),
        MockFailingImageRepository(),
        BatchProcessor(),
      );
      
      // When
      final textResult = await service.checkContent(text: 'test');
      final imageResult = await service.checkContent(image: Uint8List(0));
      
      // Then
      expect(textResult.isApproved, false); // 차단
      expect(imageResult.isApproved, false); // 차단
      expect(textResult.severity, SeverityLevel.high);
    });
    
    test('부분 실패 시 가장 심각한 결과 반환', () async {
      // Given
      final service = ModerationService(
        MockMixedResultRepository(),
        MockSuccessImageRepository(),
        BatchProcessor(),
      );
      
      // When
      final result = await service.checkContent(
        text: 'test',
        image: Uint8List(0),
      );
      
      // Then
      expect(result.isApproved, false); // 하나라도 실패하면 차단
      expect(result.severity, SeverityLevel.high);
    });
  });
}
```

## 📊 커버리지 목표

### Services Layer 커버리지 요구사항

| 컴포넌트 | 최소 커버리지 | 권장 커버리지 | 현재 |
|---------|-------------|-------------|------|
| Domain Layer | 95% | 100% | - |
| Data Layer | 85% | 95% | - |
| Presentation | 90% | 95% | - |
| Security | 100% | 100% | - |
| 전체 | 90% | 95% | 0% |

### 테스트 타입별 목표

| 테스트 타입 | 개수 | 우선순위 |
|-----------|------|---------|
| Unit Tests | 50+ | 필수 |
| Integration | 20+ | 필수 |
| Performance | 10+ | 필수 |
| Security | 10+ | 필수 |

## ✅ 테스트 체크리스트

### 개발 시
- [ ] 모든 public 메서드에 단위 테스트 작성
- [ ] 경계값 테스트 포함
- [ ] 예외 상황 테스트 포함
- [ ] Mock 사용으로 외부 의존성 제거

### PR 전
- [ ] 90% 이상 코드 커버리지 달성
- [ ] 모든 테스트 통과
- [ ] 성능 테스트 기준 충족
- [ ] 보안 테스트 통과

### 배포 전
- [ ] 통합 테스트 완료
- [ ] 실제 API로 E2E 테스트 (개발 환경)
- [ ] 부하 테스트 수행
- [ ] 보안 감사 완료

## 🔧 테스트 헬퍼

### Mock API Client
```dart
// test/helpers/mock_api_client.dart
class MockApiClient extends Mock implements http.Client {
  final Map<String, dynamic> responses;
  
  MockApiClient({this.responses = const {}});
  
  @override
  Future<http.Response> post(Uri url, {headers, body}) async {
    final path = url.path;
    if (responses.containsKey(path)) {
      return http.Response(json.encode(responses[path]), 200);
    }
    return http.Response('Not Found', 404);
  }
}
```

### Test Data Builder
```dart
// test/helpers/test_data_builder.dart
class TestDataBuilder {
  static List<String> getToxicTexts() => [
    '씨발',
    '병신',
    'fuck',
    'shit',
  ];
  
  static List<String> getCleanTexts() => [
    '안녕하세요',
    '좋은 하루 되세요',
    'Hello world',
  ];
  
  static Future<Uint8List> getTestImage(String name) async {
    final file = File('test/fixtures/images/$name');
    return await file.readAsBytes();
  }
}
```

## 🏁 CI/CD 통합

### GitHub Actions 설정

```yaml
# .github/workflows/moderation_service_test.yml
name: Moderation Service Tests

on:
  push:
    paths:
      - 'lib/services/moderation/**'
      - 'test/services/moderation/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
      
      - name: Set up environment
        run: |
          echo "PERSPECTIVE_API_KEY=${{ secrets.PERSPECTIVE_API_KEY }}" >> .env
          echo "CLOUD_VISION_API_KEY=${{ secrets.CLOUD_VISION_API_KEY }}" >> .env
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage test/services/moderation/
      
      - name: Check coverage
        run: |
          coverage_percent=$(lcov --summary coverage/lcov.info | 
            grep "lines" | 
            sed 's/.*: \([0-9.]*\)%.*/\1/')
          
          if (( $(echo "$coverage_percent < 90" | bc -l) )); then
            echo "Coverage $coverage_percent% is below 90%"
            exit 1
          fi
      
      - name: Security scan
        run: |
          # API 키 노출 검사
          if grep -r "AIzaSy" lib/; then
            echo "API key exposed in source code!"
            exit 1
          fi
```

## 🎯 다음 단계

### Phase 1: 기본 테스트 구축
- Perspective API 단위 테스트
- Cloud Vision 단위 테스트
- 캐시 테스트

### Phase 2: 통합 테스트 추가
- 텍스트/이미지 검열 통합
- 배치 처리 테스트
- Firebase 통합 테스트

### Phase 3: 고급 테스트 추가
- 성능 벤치마크
- 보안 감사
- 부하 테스트

## 📚 참고 자료

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Services Layer Architecture](/lib/services/README.md)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)

---

*이 문서는 Moderation Service의 테스트 전략을 설명합니다.*  
*Services Layer는 전역 인프라로서 철저한 테스트가 필요합니다.*  
*🔴 보안 테스트는 특히 중요합니다.*