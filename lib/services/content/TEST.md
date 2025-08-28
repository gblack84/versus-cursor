# 🧪 Content Service 테스트 전략

> Content Service의 테스트 전략 및 구현 가이드
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 개요

Content Service는 Versus Space의 **전역 인프라 서비스**로서, 모든 Feature에 영향을 미치는 중요한 컴포넌트입니다. 따라서 철저한 테스트가 필수적입니다.

## 🎯 테스트 원칙

### Services Layer 테스트 특성
1. **격리된 테스트**: Feature 의존성 없이 독립적으로 테스트
2. **Mock 사용**: Backend 의존성은 Mock으로 대체
3. **성능 중심**: 전역 서비스이므로 성능이 중요
4. **안정성 보장**: 모든 Feature가 의존하므로 높은 신뢰성 필요

## 🏗️ 테스트 구조

```
test/services/content/
├── unit/                           # 단위 테스트
│   ├── content_filter_test.dart
│   ├── filter_result_test.dart
│   ├── text_normalizer_test.dart
│   ├── pattern_matcher_test.dart
│   └── korean_variant_test.dart
│
├── integration/                    # 통합 테스트
│   ├── filter_service_test.dart
│   ├── json_datasource_test.dart
│   └── repository_test.dart
│
├── performance/                    # 성능 테스트
│   ├── filter_speed_test.dart
│   ├── memory_usage_test.dart
│   └── concurrent_test.dart
│
├── fixtures/                       # 테스트 데이터
│   ├── test_words.json
│   ├── korean_samples.dart
│   └── edge_cases.dart
│
└── helpers/                        # 테스트 헬퍼
    ├── mock_repository.dart
    └── test_data_builder.dart
```

## 🧪 단위 테스트

### 1. ContentFilter 핵심 기능 테스트

```dart
// test/services/content/unit/content_filter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ContentFilter - Services Layer', () {
    late ContentFilterRepository mockRepository;
    late ContentFilterService service;
    
    setUp(() {
      mockRepository = MockContentFilterRepository();
      service = ContentFilterService(mockRepository);
    });
    
    group('텍스트 필터링', () {
      test('정상 텍스트는 통과해야 함', () {
        // Given
        const text = '안녕하세요';
        when(mockRepository.filterText(text)).thenReturn(
          FilterResult(
            isBlocked: false,
            filteredText: text,
            severity: SeverityLevel.none,
          ),
        );
        
        // When
        final result = service.filterText(text);
        
        // Then
        expect(result.isBlocked, false);
        expect(result.filteredText, text);
      });
      
      test('금지어는 차단되어야 함', () {
        // Given
        const text = '부적절한 단어';
        when(mockRepository.filterText(text)).thenReturn(
          FilterResult(
            isBlocked: true,
            filteredText: '*** 단어',
            blockedWord: '부적절한',
            severity: SeverityLevel.high,
          ),
        );
        
        // When
        final result = service.filterText(text);
        
        // Then
        expect(result.isBlocked, true);
        expect(result.filteredText, contains('*'));
        expect(result.severity, SeverityLevel.high);
      });
    });
    
    group('한국어 변형 패턴', () {
      test('자음모음 분리 패턴을 감지해야 함', () {
        // Given
        const variations = [
          'ㅅㅣㅂㅏㄹ',
          'ㅂㅕㅇㅅㅣㄴ',
          'ㅁㅣㅊㅣㄴ',
        ];
        
        for (final text in variations) {
          when(mockRepository.filterText(text)).thenReturn(
            FilterResult(
              isBlocked: true,
              filteredText: '***',
              severity: SeverityLevel.high,
            ),
          );
          
          // When
          final result = service.filterText(text);
          
          // Then
          expect(result.isBlocked, true,
            reason: '$text 패턴이 감지되지 않음');
        }
      });
      
      test('숫자/특수문자 혼합 패턴을 감지해야 함', () {
        // Given
        const variations = [
          '시1발',
          '씨@발',
          '병.신',
        ];
        
        // Test implementation...
      });
    });
  });
}
```

### 2. 의존성 방향 테스트

```dart
// test/services/content/unit/dependency_test.dart
void main() {
  group('의존성 방향 검증', () {
    test('Services는 Features를 import하지 않아야 함', () {
      // Content Service의 모든 import 검사
      final imports = getImportsFromFile(
        'lib/services/content/content_filter.dart'
      );
      
      // Features 디렉토리 import가 없어야 함
      final hasFeatureImport = imports.any(
        (import) => import.contains('lib/features/')
      );
      
      expect(hasFeatureImport, false,
        reason: 'Services는 Features를 참조할 수 없습니다');
    });
    
    test('Services는 Backend를 import할 수 있음', () {
      // Backend import는 허용됨
      final imports = getImportsFromFile(
        'lib/services/content/content_filter.dart'
      );
      
      final backendImports = imports.where(
        (import) => import.contains('lib/backend/')
      );
      
      // Backend import는 허용됨 (하지만 모델 직접 참조는 피해야 함)
      expect(backendImports, isNotEmpty);
    });
  });
}
```

## 🔄 통합 테스트

### 1. JSON 데이터소스 통합 테스트

```dart
// test/services/content/integration/json_datasource_test.dart
void main() {
  group('JSON 데이터소스 통합', () {
    late JsonFilterDatasource datasource;
    
    setUp(() {
      datasource = JsonFilterDatasource(
        assetPath: 'test/fixtures/test_words.json',
      );
    });
    
    test('JSON 파일을 정상적으로 로드해야 함', () async {
      // When
      await datasource.loadFilterData();
      
      // Then
      expect(datasource.filterData, isNotNull);
      expect(datasource.filterData!['categories'], isNotNull);
      expect(datasource.filterData!['version'], isNotNull);
    });
    
    test('잘못된 경로 처리', () async {
      // Given
      datasource = JsonFilterDatasource(
        assetPath: 'invalid/path.json',
      );
      
      // When & Then
      expect(
        () => datasource.loadFilterData(),
        throwsA(isA<AssetException>()),
      );
    });
  });
}
```

### 2. Repository 통합 테스트

```dart
// test/services/content/integration/repository_test.dart
void main() {
  group('ContentFilterRepository 통합', () {
    late ContentFilterRepository repository;
    
    setUp(() async {
      final datasource = JsonFilterDatasource(
        assetPath: 'assets/data/blocked_words.json',
      );
      
      repository = ContentFilterRepositoryImpl(
        datasource: datasource,
        normalizer: TextNormalizer(),
        matcher: PatternMatcher(),
      );
      
      await repository.initialize();
    });
    
    test('초기화 후 필터링이 작동해야 함', () {
      // When
      final result = repository.filterText('테스트');
      
      // Then
      expect(result, isNotNull);
      expect(result.isBlocked, anyOf(true, false));
    });
    
    test('초기화 전 필터링은 안전하게 실패해야 함', () {
      // Given
      final uninitializedRepo = ContentFilterRepositoryImpl(
        datasource: JsonFilterDatasource(),
      );
      
      // When
      final result = uninitializedRepo.filterText('테스트');
      
      // Then
      expect(result.isBlocked, false);
      expect(result.severity, SeverityLevel.none);
    });
  });
}
```

## ⚡ 성능 테스트

### 1. 처리 속도 테스트

```dart
// test/services/content/performance/filter_speed_test.dart
void main() {
  group('필터링 성능', () {
    late ContentFilterService service;
    
    setUpAll(() async {
      // 실제 서비스 초기화
      service = await createRealService();
    });
    
    test('단일 필터링은 1ms 이내여야 함', () {
      final stopwatch = Stopwatch()..start();
      
      service.filterText('테스트 텍스트');
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1));
    });
    
    test('1000건 배치 처리는 1초 이내여야 함', () {
      final texts = List.generate(1000, (i) => '텍스트 $i');
      final stopwatch = Stopwatch()..start();
      
      for (final text in texts) {
        service.filterText(text);
      }
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
    
    test('텍스트 길이에 따른 성능 저하가 선형적이어야 함', () {
      final results = <int, int>{};
      
      for (final length in [100, 1000, 10000]) {
        final text = 'a' * length;
        final stopwatch = Stopwatch()..start();
        
        service.filterText(text);
        
        stopwatch.stop();
        results[length] = stopwatch.elapsedMicroseconds;
      }
      
      // O(n) 복잡도 검증
      final ratio = results[10000]! / results[100]!;
      expect(ratio, lessThan(150)); // 100배 길이에 150배 미만 시간
    });
  });
}
```

### 2. 메모리 사용량 테스트

```dart
// test/services/content/performance/memory_usage_test.dart
void main() {
  group('메모리 사용량', () {
    test('초기화 후 메모리 사용량이 1MB 미만이어야 함', () async {
      final initialMemory = getCurrentMemoryUsage();
      
      final service = await createRealService();
      
      final afterInit = getCurrentMemoryUsage();
      final increase = afterInit - initialMemory;
      
      expect(increase, lessThan(1024 * 1024)); // 1MB
    });
    
    test('대량 처리 후 메모리 누수가 없어야 함', () async {
      final service = await createRealService();
      final beforeMemory = getCurrentMemoryUsage();
      
      // 10000건 처리
      for (int i = 0; i < 10000; i++) {
        service.filterText('테스트 $i');
      }
      
      // GC 실행 대기
      await Future.delayed(Duration(seconds: 2));
      
      final afterMemory = getCurrentMemoryUsage();
      final increase = afterMemory - beforeMemory;
      
      expect(increase, lessThan(5 * 1024 * 1024)); // 5MB 미만
    });
  });
}
```

## 🧩 테스트 데이터

### 1. 한국어 테스트 세트

```dart
// test/fixtures/korean_samples.dart
class KoreanTestData {
  static const cleanTexts = [
    '안녕하세요',
    '좋은 아침입니다',
    '감사합니다',
  ];
  
  static const profanityTexts = [
    // 실제 욕설 (테스트용)
    '시발',
    '병신',
    '씨발',
  ];
  
  static const variantTexts = [
    // 변형 패턴
    'ㅅㅣㅂㅏㄹ',
    '시1발',
    '씨 발',
    'ㅂㅕㅇㅅㅣㄴ',
  ];
  
  static const edgeCases = [
    '', // 빈 문자열
    ' ', // 공백만
    '😀🔥💯', // 이모지
    'a' * 10000, // 매우 긴 텍스트
    '!@#\$%^&*()', // 특수문자만
  ];
}
```

### 2. Mock Repository

```dart
// test/helpers/mock_repository.dart
class MockContentFilterRepository extends Mock 
    implements ContentFilterRepository {
  
  @override
  FilterResult filterText(String text) {
    // 테스트용 간단한 필터링 로직
    if (text.contains('욕설')) {
      return FilterResult(
        isBlocked: true,
        filteredText: text.replaceAll('욕설', '**'),
        blockedWord: '욕설',
        severity: SeverityLevel.high,
      );
    }
    
    return FilterResult(
      isBlocked: false,
      filteredText: text,
      severity: SeverityLevel.none,
    );
  }
}
```

## 📊 커버리지 목표

### Services Layer 커버리지 요구사항

| 컴포넌트 | 최소 커버리지 | 권장 커버리지 | 현재 |
|---------|-------------|-------------|------|
| Domain Layer | 90% | 100% | - |
| Data Layer | 80% | 90% | - |
| Presentation | 85% | 95% | - |
| 전체 | 85% | 95% | 0% |

### 테스트 타입별 목표

| 테스트 타입 | 개수 | 우선순위 |
|-----------|------|---------|
| Unit Tests | 50+ | 필수 |
| Integration | 20+ | 필수 |
| Performance | 10+ | 권장 |
| Security | 5+ | 권장 |

## ✅ 테스트 체크리스트

### 개발 시
- [ ] 모든 public 메서드에 단위 테스트 작성
- [ ] 경계값 테스트 포함
- [ ] 예외 상황 테스트 포함
- [ ] Mock 의존성 사용

### PR 전
- [ ] 85% 이상 코드 커버리지 달성
- [ ] 모든 테스트 통과
- [ ] 성능 테스트 기준 충족
- [ ] 의존성 방향 검증 통과

### 배포 전
- [ ] 통합 테스트 완료
- [ ] 실제 데이터로 테스트
- [ ] 메모리 누수 검사
- [ ] 동시성 테스트 통과

## 🔄 CI/CD 통합

### GitHub Actions 설정

```yaml
# .github/workflows/content_service_test.yml
name: Content Service Tests

on:
  push:
    paths:
      - 'lib/services/content/**'
      - 'test/services/content/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests with coverage
        run: flutter test --coverage test/services/content/
      
      - name: Check coverage
        run: |
          coverage_percent=$(lcov --summary coverage/lcov.info | 
            grep "lines" | 
            sed 's/.*: \([0-9.]*\)%.*/\1/')
          
          if (( $(echo "$coverage_percent < 85" | bc -l) )); then
            echo "Coverage $coverage_percent% is below 85%"
            exit 1
          fi
```

## 🎯 다음 단계

### Phase 1: 기본 테스트 구축
- ContentFilter 단위 테스트
- 기본 통합 테스트
- 커버리지 85% 달성

### Phase 2: 고급 테스트 추가
- 성능 벤치마크 구축
- 메모리 프로파일링
- 보안 테스트 추가

### Phase 3: 자동화 강화
- Mutation Testing 도입
- Property-based Testing
- Fuzzing 테스트

## 📚 참고 자료

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Services Layer Architecture](/lib/services/README.md)
- [Feature-First Architecture](/ARCHITECTURE.md)

---

*이 문서는 Content Service의 테스트 전략을 설명합니다.*
*Services Layer는 전역 인프라로서 철저한 테스트가 필요합니다.*