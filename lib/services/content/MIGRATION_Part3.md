# 🔄 Content Service - Services Layer 내부 리팩토링 계획

> Phase 3: Clean Architecture를 Services Layer 내에서 적용
> 최종 업데이트: 2025-08-28 | 버전: 2.0.0

## 📋 핵심 원칙

### ⚠️ 중요: Services Layer는 유지됩니다

Content Service는 **전역 인프라 서비스**로서 `/lib/services/content/`에 유지됩니다. 이 문서는 Services Layer 내부에서 Clean Architecture를 적용하는 계획입니다. **절대 Feature로 이동하지 않습니다.**

### 의존성 규칙
```
✅ 올바른 방향:
Features → Services → Backend

❌ 금지된 방향:
Services → Features (역방향 의존성)
```

## 🏗️ 현재 상태 분석

### 현재 구조 (1개 파일)
```
lib/services/content/
└── content_filter.dart    # 180줄 - 모든 로직이 하나의 파일에
```

### 현재 문제점
1. **단일 파일에 모든 책임**: 필터링, 정규화, 패턴 매칭, 변환
2. **정적 싱글톤**: 테스트와 DI 어려움
3. **하드코딩된 경로**: JSON 파일 경로 고정
4. **동기적 처리**: UI 블로킹 가능
5. **확장성 부족**: 새로운 언어나 패턴 추가 어려움

## 🎯 목표 구조 (Services Layer 내부)

### Clean Architecture를 Services 내부에 적용
```
lib/services/content/
├── domain/                    # 비즈니스 규칙 (인터페이스)
│   ├── entities/
│   │   ├── filter_result.dart
│   │   ├── filter_policy.dart
│   │   └── severity_level.dart
│   ├── repositories/
│   │   └── content_filter_repository.dart
│   └── usecases/
│       ├── filter_text.dart
│       └── validate_content.dart
│
├── data/                      # 구현 레이어
│   ├── models/
│   │   ├── filter_result_model.dart
│   │   └── blocked_pattern_model.dart
│   ├── datasources/
│   │   ├── local_filter_datasource.dart
│   │   └── json_filter_datasource.dart
│   ├── repositories/
│   │   └── content_filter_repository_impl.dart
│   └── services/
│       ├── text_normalizer.dart
│       ├── pattern_matcher.dart
│       └── korean_variant_detector.dart
│
├── presentation/              # 서비스 인터페이스
│   ├── content_filter_service.dart    # 메인 서비스 (DI)
│   └── content_filter_provider.dart   # Provider 패턴
│
├── README.md
├── MIGRATION_Part3.md
└── TEST.md
```

## 📊 마이그레이션 로드맵

### Phase 1: Domain Layer 구축 (2일)

#### Day 1: 엔티티 정의
```dart
// lib/services/content/domain/entities/filter_result.dart
class FilterResult {
  final bool isBlocked;
  final String filteredText;
  final String? blockedWord;
  final String? category;
  final SeverityLevel severity;
  
  const FilterResult({
    required this.isBlocked,
    required this.filteredText,
    this.blockedWord,
    this.category,
    required this.severity,
  });
}

// lib/services/content/domain/entities/severity_level.dart
enum SeverityLevel {
  none(0),
  low(1),
  medium(2),
  high(3),
  critical(4);
  
  final int value;
  const SeverityLevel(this.value);
}
```

#### Day 2: Repository 인터페이스
```dart
// lib/services/content/domain/repositories/content_filter_repository.dart
abstract class ContentFilterRepository {
  Future<void> initialize();
  
  FilterResult filterText(String text);
  
  String? validateText(String? value);
  
  Map<String, dynamic> getFilterInfo();
  
  String getSeverityLevel(String text);
}
```

### Phase 2: Data Layer 구현 (3일)

#### Day 3-4: 데이터소스 분리
```dart
// lib/services/content/data/datasources/json_filter_datasource.dart
class JsonFilterDatasource {
  final String assetPath;
  Map<String, dynamic>? _filterData;
  
  JsonFilterDatasource({
    this.assetPath = 'assets/data/blocked_words.json',
  });
  
  Future<void> loadFilterData() async {
    final jsonString = await rootBundle.loadString(assetPath);
    _filterData = json.decode(jsonString);
  }
  
  Map<String, dynamic>? get filterData => _filterData;
}

// lib/services/content/data/services/text_normalizer.dart
class TextNormalizer {
  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[\s@#$%^&*()_+=\-\[\]{}|\\:";'+"'"+'<>?,./~`!]'), '')
        .replaceAll(RegExp(r'[0-9]'), '')
        .trim();
  }
}

// lib/services/content/data/services/pattern_matcher.dart
class PatternMatcher {
  bool containsWord(String text, String word) {
    if (word.isEmpty) return false;
    
    if (text.contains(word)) return true;
    
    if (_checkVariantPattern(text, word)) return true;
    
    return false;
  }
  
  bool _checkVariantPattern(String text, String word) {
    // 변형 패턴 검사 로직
    return false;
  }
}
```

#### Day 5: Repository 구현
```dart
// lib/services/content/data/repositories/content_filter_repository_impl.dart
class ContentFilterRepositoryImpl implements ContentFilterRepository {
  final JsonFilterDatasource _datasource;
  final TextNormalizer _normalizer;
  final PatternMatcher _matcher;
  bool _isInitialized = false;
  
  ContentFilterRepositoryImpl({
    required JsonFilterDatasource datasource,
    TextNormalizer? normalizer,
    PatternMatcher? matcher,
  }) : _datasource = datasource,
       _normalizer = normalizer ?? TextNormalizer(),
       _matcher = matcher ?? PatternMatcher();
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _datasource.loadFilterData();
    _isInitialized = true;
  }
  
  @override
  FilterResult filterText(String text) {
    if (!_isInitialized) {
      return FilterResult(
        isBlocked: false,
        filteredText: text,
        severity: SeverityLevel.none,
      );
    }
    
    final normalized = _normalizer.normalize(text);
    final filterData = _datasource.filterData!;
    
    // 필터링 로직...
    
    return FilterResult(
      isBlocked: false,
      filteredText: text,
      severity: SeverityLevel.none,
    );
  }
  
  // 나머지 메서드 구현...
}
```

### Phase 3: Presentation Layer 및 DI (2일)

#### Day 6: 서비스 인터페이스
```dart
// lib/services/content/presentation/content_filter_service.dart
class ContentFilterService {
  final ContentFilterRepository _repository;
  
  ContentFilterService(this._repository);
  
  Future<void> initialize() => _repository.initialize();
  
  FilterResult filterText(String text) => _repository.filterText(text);
  
  String? validateText(String? value) => _repository.validateText(value);
  
  Map<String, dynamic> getFilterInfo() => _repository.getFilterInfo();
}
```

#### Day 7: 레거시 호환성 어댑터
```dart
// lib/services/content/content_filter.dart (기존 파일 수정)
import 'presentation/content_filter_service.dart';

/// 레거시 호환성을 위한 정적 래퍼
/// 점진적 마이그레이션을 위해 유지
class ContentFilter {
  static ContentFilterService? _service;
  
  static ContentFilterService get _instance {
    _service ??= ContentFilterService(
      ContentFilterRepositoryImpl(
        datasource: JsonFilterDatasource(),
      ),
    );
    return _service!;
  }
  
  static Future<void> initialize() async {
    await _instance.initialize();
  }
  
  static FilterResult filterText(String text) {
    return _instance.filterText(text);
  }
  
  static String? validateText(String? value) {
    return _instance.validateText(value);
  }
  
  static Map<String, dynamic> getFilterInfo() {
    return _instance.getFilterInfo();
  }
  
  static String getSeverityLevel(String text) {
    final result = filterText(text);
    return result.severity.name;
  }
}
```

### Phase 4: 점진적 개선 (1주)

#### 비동기 처리 추가
```dart
// lib/services/content/domain/usecases/filter_text_async.dart
class FilterTextAsync {
  final ContentFilterRepository _repository;
  
  FilterTextAsync(this._repository);
  
  Future<FilterResult> call(String text) async {
    return compute(_filterInIsolate, text);
  }
  
  static FilterResult _filterInIsolate(String text) {
    // Isolate에서 실행될 필터링 로직
    return FilterResult(
      isBlocked: false,
      filteredText: text,
      severity: SeverityLevel.none,
    );
  }
}
```

#### 캐싱 전략 구현
```dart
// lib/services/content/data/cache/filter_cache.dart
class FilterCache {
  final Map<String, FilterResult> _cache = {};
  final Duration _ttl;
  
  FilterCache({this._ttl = const Duration(minutes: 5)});
  
  FilterResult? get(String key) {
    final entry = _cache[key];
    if (entry != null) {
      // TTL 체크
      return entry;
    }
    return null;
  }
  
  void set(String key, FilterResult value) {
    _cache[key] = value;
  }
}
```

## 🧪 테스트 전략

### 단위 테스트
```dart
// test/services/content/domain/usecases/filter_text_test.dart
void main() {
  group('FilterText', () {
    late ContentFilterRepository repository;
    late FilterText useCase;
    
    setUp(() {
      repository = MockContentFilterRepository();
      useCase = FilterText(repository);
    });
    
    test('should return blocked result for profanity', () {
      // given
      const text = '욕설이 포함된 텍스트';
      when(repository.filterText(text)).thenReturn(
        FilterResult(
          isBlocked: true,
          filteredText: '***이 포함된 텍스트',
          blockedWord: '욕설',
          severity: SeverityLevel.high,
        ),
      );
      
      // when
      final result = useCase(text);
      
      // then
      expect(result.isBlocked, true);
      expect(result.severity, SeverityLevel.high);
    });
  });
}
```

### 통합 테스트
```dart
// test/services/content/integration/content_filter_integration_test.dart
void main() {
  group('ContentFilter Integration', () {
    late ContentFilterService service;
    
    setUp(() async {
      final datasource = JsonFilterDatasource();
      final repository = ContentFilterRepositoryImpl(
        datasource: datasource,
      );
      service = ContentFilterService(repository);
      await service.initialize();
    });
    
    test('full filtering flow', () {
      final result = service.filterText('테스트 텍스트');
      expect(result.isBlocked, false);
    });
  });
}
```

## 📈 성공 지표

### 코드 품질
| 지표 | 현재 | 목표 |
|------|------|------|
| 파일 수 | 1 | 15+ |
| 최대 파일 크기 | 180줄 | <100줄 |
| 테스트 커버리지 | 0% | 85% |
| 순환 복잡도 | 높음 | 낮음 |

### 성능
| 지표 | 현재 | 목표 |
|------|------|------|
| 초기화 시간 | 동기 | 비동기 |
| 필터링 속도 | <1ms | <0.5ms |
| 메모리 사용 | 500KB | 300KB |
| 캐시 히트율 | 0% | 60% |

## ⚠️ 주의사항

### 1. Services Layer 유지
- **절대 금지**: Feature 모듈로 이동
- **필수**: `/lib/services/content/` 경로 유지
- **이유**: 전역 인프라 서비스

### 2. 레거시 호환성
- 기존 `ContentFilter` 정적 메서드 유지
- 점진적 마이그레이션 지원
- Breaking change 최소화

### 3. 의존성 방향
- Services는 Backend만 참조
- Feature 모델 직접 import 금지
- 필요시 인터페이스 정의

## ✅ 체크리스트

### Week 1
- [ ] Domain Layer 생성
- [ ] Data Layer 구현
- [ ] Presentation Layer 구축
- [ ] 레거시 어댑터 생성
- [ ] 기본 테스트 작성

### Week 2
- [ ] 비동기 처리 구현
- [ ] 캐싱 전략 적용
- [ ] DI 컨테이너 통합
- [ ] 통합 테스트 완료
- [ ] 문서 업데이트

## 🔄 마이그레이션 후 구조

### Before (현재)
```
lib/services/content/
└── content_filter.dart (180줄, 모든 책임)
```

### After (목표)
```
lib/services/content/
├── domain/ (비즈니스 규칙)
├── data/ (구현)
├── presentation/ (서비스 인터페이스)
└── content_filter.dart (레거시 어댑터)
```

## 📚 참고 자료

- [Feature-First Architecture](/ARCHITECTURE.md)
- [Services Layer 유지 원칙](/lib/services/README.md)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

*이 문서는 Content Service의 Services Layer 내부 리팩토링 계획입니다.*
*Services Layer는 전역 인프라로 유지되어야 합니다.*