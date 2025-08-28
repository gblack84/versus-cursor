# 📐 UI Service 마이그레이션 계획 (Part 3)

> Feature-First Architecture 마이그레이션 - UI Service 개선  
> 작성일: 2025-08-28 | 목표: 2025년 1분기

## 🎯 마이그레이션 목표

UI Service를 Feature-First Architecture 원칙에 맞게 개선하면서 Services Layer의 전역 인프라 역할을 유지합니다.

### 핵심 목표
1. **의존성 역전 해결**: Features → Services 단방향 의존성 확립
2. **테스트 가능성 향상**: 정적 메서드를 인스턴스 메서드로 전환
3. **성능 최적화**: 캐싱 및 메모리 관리 개선
4. **확장성 확보**: 새로운 디바이스/컨테이너 타입 쉽게 추가

## 📊 현재 상태 분석

### 문제점 요약
```yaml
architecture:
  - 정적 메서드 남용 (100% static)
  - DI 패턴 부재
  - 역방향 의존성 (AspectRatioAnalyzer)

code_quality:
  - 중복 코드 (calculate 메서드들)
  - 매직 넘버 하드코딩
  - Deprecated 메서드 방치

performance:
  - MediaQuery 캐싱 없음
  - 반복적인 계산
  - 디버그 로그 과다

extensibility:
  - switch문 기반 확장
  - 새 타입 추가 어려움
  - 테스트 작성 어려움
```

## 🚀 마이그레이션 전략

### Phase 1: 의존성 정리 (Week 1) ⚡ **긴급**

#### 1.1 역방향 의존성 제거
```dart
// ❌ 현재: Services가 Features 의존
import '/features/posts/domain/usecases/media/aspect_ratio_analyzer.dart';

// ✅ 개선: 인터페이스를 Services에 정의
// lib/services/ui/interfaces/layout_analyzer.dart
abstract class ILayoutAnalyzer {
  LayoutType analyzeLayout(List<double> aspectRatios);
}

// Features에서 구현
class AspectRatioAnalyzer implements ILayoutAnalyzer {
  @override
  LayoutType analyzeLayout(List<double> aspectRatios) {
    // 구현
  }
}
```

#### 1.2 LayoutConstants 이동
```dart
// 현재: /core/constants/layout_constants.dart
// 이동: /lib/services/ui/constants/layout_constants.dart

// Services Layer 내부로 이동하여 의존성 명확화
class LayoutConstants {
  // 기존 상수들 유지
  static const double defaultBoxHeight = 300.0;
  static const double singleBoxWidthRatio = 0.8;
  // ...
}
```

#### 1.3 모델 클래스 분리
```dart
// lib/services/ui/models/
├── box_sizes.dart       // BoxSizes 클래스
├── device_type.dart     // DeviceType enum
└── layout_type.dart     // LayoutType enum
```

### Phase 2: 아키텍처 개선 (Week 2)

#### 2.1 서비스 인터페이스 정의
```dart
// lib/services/ui/interfaces/responsive_service.dart
abstract class IResponsiveService {
  void initialize();
  DeviceType getDeviceType(BuildContext context);
  double getMaxMessageWidth(BuildContext context);
  EdgeInsets getMessageMargin(BuildContext context, bool isMe);
  double getVsBoxHeight(BuildContext context, bool hasImages, bool isExpanded);
}

// lib/services/ui/interfaces/box_calculator.dart
abstract class IBoxCalculator {
  BoxSizes calculate(BoxCalculationParams params);
  BoxSizes calculateForMessageCard(MessageCardParams params);
  BoxSizes calculateForNotification(NotificationParams params);
  BoxSizes calculateForQuestion(QuestionParams params);
}
```

#### 2.2 서비스 구현체
```dart
// lib/services/ui/responsive_service.dart
@Singleton()
class ResponsiveService implements IResponsiveService {
  final IConfigService _config;
  final ICacheService _cache;
  
  ResponsiveService(this._config, this._cache);
  
  @override
  DeviceType getDeviceType(BuildContext context) {
    final key = 'device_type_${context.hashCode}';
    return _cache.get(key) ?? _calculateDeviceType(context);
  }
  
  // Private 메서드로 실제 계산
  DeviceType _calculateDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // 계산 로직
    return deviceType;
  }
}
```

#### 2.3 DI 설정
```dart
// lib/services/ui/di/ui_service_module.dart
import 'package:get_it/get_it.dart';

class UiServiceModule {
  static void register(GetIt getIt) {
    // 서비스 등록
    getIt.registerSingleton<IResponsiveService>(
      ResponsiveService(
        getIt<IConfigService>(),
        getIt<ICacheService>(),
      ),
    );
    
    getIt.registerSingleton<IBoxCalculator>(
      UnifiedBoxCalculator(
        getIt<IResponsiveService>(),
        getIt<ILayoutAnalyzer>(),
      ),
    );
  }
}
```

### Phase 3: 성능 최적화 (Week 3)

#### 3.1 캐싱 레이어 구현
```dart
// lib/services/ui/cache/responsive_cache.dart
class ResponsiveCache {
  final Duration _ttl = Duration(seconds: 1);
  final _cache = <String, CacheEntry>{};
  
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    if (DateTime.now().difference(entry.timestamp) > _ttl) {
      _cache.remove(key);
      return null;
    }
    
    return entry.value as T;
  }
  
  void set<T>(String key, T value) {
    _cache[key] = CacheEntry(value, DateTime.now());
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime timestamp;
  
  CacheEntry(this.value, this.timestamp);
}
```

#### 3.2 박스 계산 최적화
```dart
// lib/services/ui/calculators/optimized_calculator.dart
class OptimizedBoxCalculator {
  final Map<String, BoxSizes> _calculationCache = {};
  
  BoxSizes calculate(BoxCalculationParams params) {
    final cacheKey = params.toCacheKey();
    
    // 캐시 확인
    if (_calculationCache.containsKey(cacheKey)) {
      return _calculationCache[cacheKey]!;
    }
    
    // 새로 계산
    final result = _performCalculation(params);
    
    // 캐시 저장
    _calculationCache[cacheKey] = result;
    
    // 캐시 크기 관리 (LRU)
    if (_calculationCache.length > 100) {
      _evictOldestEntry();
    }
    
    return result;
  }
}
```

#### 3.3 디버그 로그 최적화
```dart
// lib/services/ui/utils/debug_logger.dart
class UiDebugLogger {
  static bool _enabled = !kReleaseMode;
  static final Set<String> _enabledTags = {'calculation', 'responsive'};
  
  static void log(String tag, String message) {
    if (!_enabled || !_enabledTags.contains(tag)) return;
    
    if (kDebugMode) {
      developer.log(
        message,
        name: 'UI-Service',
        time: DateTime.now(),
      );
    }
  }
}
```

### Phase 4: 기능 확장 (Week 4)

#### 4.1 설정 기반 브레이크포인트
```dart
// lib/services/ui/config/breakpoint_config.dart
@immutable
class BreakpointConfig {
  final Map<DeviceType, double> breakpoints;
  final Map<DeviceType, SizeConfig> sizeConfigs;
  final Map<DeviceType, SpacingConfig> spacingConfigs;
  
  const BreakpointConfig.defaultConfig() : 
    breakpoints = const {
      DeviceType.mobileSmall: 320,
      DeviceType.mobile: 375,
      // ...
    },
    sizeConfigs = const {
      // ...
    },
    spacingConfigs = const {
      // ...
    };
    
  // 커스텀 설정 지원
  factory BreakpointConfig.custom(Map<String, dynamic> json) {
    return BreakpointConfig.fromJson(json);
  }
}
```

#### 4.2 박스 계산 빌더
```dart
// lib/services/ui/builders/box_size_builder.dart
class BoxSizeBuilder {
  double? _containerWidth;
  double? _containerHeight;
  String? _containerType;
  LayoutType? _layoutType;
  double? _aspectRatioA;
  double? _aspectRatioB;
  bool _hasImageA = true;
  bool _hasImageB = true;
  
  BoxSizeBuilder withContainer(double width, [double? height]) {
    _containerWidth = width;
    _containerHeight = height;
    return this;
  }
  
  BoxSizeBuilder withType(String containerType) {
    _containerType = containerType;
    return this;
  }
  
  BoxSizeBuilder withLayout(LayoutType type) {
    _layoutType = type;
    return this;
  }
  
  BoxSizeBuilder withAspectRatios(double? a, double? b) {
    _aspectRatioA = a;
    _aspectRatioB = b;
    return this;
  }
  
  BoxSizeBuilder withImages({bool hasA = true, bool hasB = true}) {
    _hasImageA = hasA;
    _hasImageB = hasB;
    return this;
  }
  
  BoxSizes build() {
    assert(_containerWidth != null, 'Container width is required');
    assert(_containerType != null, 'Container type is required');
    assert(_layoutType != null, 'Layout type is required');
    
    final calculator = GetIt.I<IBoxCalculator>();
    return calculator.calculate(
      BoxCalculationParams(
        containerWidth: _containerWidth!,
        containerHeight: _containerHeight,
        containerType: _containerType!,
        layoutType: _layoutType!,
        aspectRatioA: _aspectRatioA,
        aspectRatioB: _aspectRatioB,
        hasImageA: _hasImageA,
        hasImageB: _hasImageB,
      ),
    );
  }
}
```

#### 4.3 테스트 가능한 구조
```dart
// test/services/ui/responsive_service_test.dart
void main() {
  late IResponsiveService service;
  late MockConfigService mockConfig;
  late MockCacheService mockCache;
  
  setUp(() {
    mockConfig = MockConfigService();
    mockCache = MockCacheService();
    service = ResponsiveService(mockConfig, mockCache);
  });
  
  group('ResponsiveService', () {
    test('should return correct device type for mobile', () {
      final context = MockBuildContext(width: 375);
      final result = service.getDeviceType(context);
      expect(result, DeviceType.mobile);
    });
    
    test('should cache device type calculation', () {
      final context = MockBuildContext(width: 375);
      
      // 첫 번째 호출
      service.getDeviceType(context);
      
      // 두 번째 호출 - 캐시에서 가져와야 함
      service.getDeviceType(context);
      
      verify(mockCache.get(any)).called(2);
      verify(mockCache.set(any, any)).called(1);
    });
  });
}
```

## 🔄 마이그레이션 순서

### 주차별 실행 계획

#### Week 1: 의존성 정리 ⚡
- [ ] AspectRatioAnalyzer 의존성 제거
- [ ] LayoutConstants Services Layer로 이동
- [ ] 모델 클래스 분리
- [ ] 순환 의존성 체크

#### Week 2: 아키텍처 개선
- [ ] 인터페이스 정의
- [ ] 서비스 구현체 작성
- [ ] DI 설정 구현
- [ ] 기존 코드 마이그레이션

#### Week 3: 성능 최적화
- [ ] 캐싱 레이어 구현
- [ ] MediaQuery 최적화
- [ ] 디버그 로그 정리
- [ ] 성능 테스트

#### Week 4: 기능 확장
- [ ] 설정 기반 시스템
- [ ] 빌더 패턴 구현
- [ ] 테스트 작성
- [ ] 문서화

## 🧪 테스트 전략

### 단위 테스트
```yaml
coverage_target: 90%
test_categories:
  - 디바이스 타입 감지
  - 박스 크기 계산
  - 캐싱 동작
  - 빌더 패턴
```

### 통합 테스트
```yaml
test_scenarios:
  - 실제 위젯에서 반응형 동작
  - 다양한 화면 크기 시뮬레이션
  - 레이아웃 전환 애니메이션
  - 메모리 누수 체크
```

### 성능 테스트
```yaml
performance_targets:
  - 계산 시간: < 1ms
  - 캐시 히트율: > 80%
  - 메모리 사용: < 1MB
  - MediaQuery 호출: 프레임당 1회
```

## 📋 체크리스트

### 마이그레이션 전
- [x] 현재 코드 분석 완료
- [x] 문제점 도출
- [x] 개선 방안 수립
- [ ] 영향 범위 파악

### 마이그레이션 중
- [ ] 기존 API 유지 (Deprecated 처리)
- [ ] 점진적 마이그레이션
- [ ] 테스트 코드 작성
- [ ] 성능 모니터링

### 마이그레이션 후
- [ ] 구버전 코드 제거
- [ ] 문서 업데이트
- [ ] 성능 리포트
- [ ] 팀 교육

## ⚠️ 리스크 관리

### 잠재적 위험
1. **기존 코드 깨짐**: Deprecated 기간 동안 양립
2. **성능 저하**: 캐싱 레이어로 보완
3. **메모리 증가**: LRU 캐시 크기 제한
4. **학습 곡선**: 문서화 및 예제 제공

### 롤백 계획
```yaml
rollback_triggers:
  - 크래시율 > 0.1%
  - 성능 저하 > 20%
  - 메모리 사용 > 5MB
  
rollback_procedure:
  1. Feature 플래그로 새 코드 비활성화
  2. 구버전 코드 재활성화
  3. 핫픽스 배포
  4. 원인 분석 및 수정
```

## 📈 성공 지표

### 정량적 지표
- 테스트 커버리지: 90% 이상
- 성능: 계산 시간 50% 감소
- 캐시 효율: 히트율 80% 이상
- 메모리: 1MB 미만 유지

### 정성적 지표
- 개발자 만족도 향상
- 코드 가독성 개선
- 유지보수 용이성
- 확장 가능성

## 📚 참고 자료

### 관련 문서
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [Core Layer 마이그레이션 가이드](/lib/core/MIGRATION_CORE_ORDER_RULES.md)
- [Services Layer 가이드](/lib/services/README.md)

### 외부 참고
- [Flutter Responsive Design Best Practices](https://docs.flutter.dev/ui/layout/responsive)
- [Dependency Injection in Flutter](https://pub.dev/packages/get_it)
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

---

*이 문서는 UI Service의 단계별 마이그레이션 계획을 담고 있습니다.*  
*Services Layer의 전역 인프라 역할을 유지하면서 점진적으로 개선합니다.*