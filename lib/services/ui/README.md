# 📐 UI Service 레이어

> 애플리케이션 전역 UI 계산 및 반응형 서비스  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

UI Service는 Versus Space 애플리케이션의 **전역 인프라 서비스**로서, 모든 Feature에서 사용하는 UI 계산 및 반응형 디자인 기능을 제공합니다. VS 박스 크기 계산, 반응형 브레이크포인트, 레이아웃 최적화 등을 중앙에서 관리합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/services/ui/
├── responsive_breakpoints.dart  # 177줄 - 반응형 디자인 브레이크포인트
└── unified_box_calculator.dart  # 544줄 - VS 박스 통합 계산 서비스
```

## 🔍 현재 코드 분석

### 1. responsive_breakpoints.dart (177줄)

#### 핵심 구성요소

**ResponsiveBreakpoints (정적 클래스)**
```dart
class ResponsiveBreakpoints {
  // 디바이스 브레이크포인트 상수
  static const double mobileSmall = 320;
  static const double mobile = 375;
  static const double mobileLarge = 414;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopLarge = 1440;
  
  // 디바이스 타입 확인 메서드
  static bool isMobile(BuildContext context)
  static bool isTablet(BuildContext context)
  static bool isDesktop(BuildContext context)
  static DeviceType getDeviceType(BuildContext context)
  
  // 채팅 메시지 레이아웃
  static double getMaxMessageWidth(BuildContext context)
  static EdgeInsets getMessageMargin(BuildContext context, bool isMe)
  
  // VS 박스 높이
  static double getVsBoxHeight(BuildContext context, bool hasImages, bool isExpanded)
}

// 디바이스 타입 열거형
enum DeviceType {
  mobileSmall, mobile, mobileLarge,
  tablet, desktop, desktopLarge
}
```

#### 주요 기능
- **디바이스 감지**: MediaQuery를 활용한 실시간 디바이스 타입 판별
- **반응형 레이아웃**: 디바이스별 최적화된 너비/높이/여백 제공
- **채팅 UI 최적화**: 메시지 버블 크기 및 여백 동적 조정
- **VS 박스 크기**: 이미지/텍스트 여부와 확장 상태에 따른 높이 계산
- **6단계 브레이크포인트**: 초소형부터 대형 데스크톱까지 지원

#### 사용 패턴
```dart
// 디바이스 타입 확인
if (ResponsiveBreakpoints.isMobile(context)) {
  // 모바일 전용 UI
}

// 메시지 버블 크기 계산
final maxWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
final margin = ResponsiveBreakpoints.getMessageMargin(context, isMe);

// VS 박스 높이 계산
final height = ResponsiveBreakpoints.getVsBoxHeight(
  context, 
  hasImages: true, 
  isExpanded: false
);
```

### 2. unified_box_calculator.dart (544줄)

#### 핵심 구성요소

**UnifiedBoxCalculator (정적 클래스)**
```dart
class UnifiedBoxCalculator {
  // 통합 계산 메서드
  static BoxSizes calculate({
    required double containerWidth,
    double? containerHeight,
    required String containerType,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  })
  
  // 컨테이너별 특화 메서드
  static BoxSizes calculateForMessageCard(...)
  static BoxSizes calculateForNotificationDialog(...)
  static BoxSizes calculateForQuestion(...)
  
  // Deprecated 메서드들
  @Deprecated('Use calculateForMessageCard instead')
  static BoxSizes calculateForMessage(...)
}

// 박스 크기 결과 모델
class BoxSizes {
  final Size sizeA;
  final Size sizeB;
  final LayoutType layoutType;
  final String containerType;
  final double spacing;
  final double unifiedHeight;
  final double boxWidth;
}
```

#### 주요 기능
- **통합 박스 계산**: 모든 VS 박스 컴포넌트의 일관된 크기 계산
- **컨테이너별 최적화**: 메시지/알림/질문 작성별 맞춤 계산
- **aspectRatio 지원**: 이미지 비율 기반 동적 높이 계산
- **레이아웃 타입 처리**: single/horizontal/vertical 배치 지원
- **높이 통일화**: 평균값 사용으로 일관된 UI 제공
- **제한값 적용**: 최대/최소 높이로 안정적인 레이아웃

#### 계산 원칙
1. **너비 우선**: 컨테이너 너비를 최대한 활용
2. **비율 유지**: aspectRatio 기반 높이 계산
3. **평균 높이**: 두 박스의 평균으로 통일
4. **제한 적용**: min/max 높이로 극단값 방지
5. **스케일링**: 세로 배치 시 화면 초과 방지

## ⚠️ 현재 문제점 종합

### 1. 아키텍처 문제
- **정적 메서드 남용**: 모든 메서드가 static으로 테스트 어려움
- **의존성 주입 불가**: 싱글톤이나 DI 패턴 미적용
- **외부 의존성**: LayoutConstants, AspectRatioAnalyzer 직접 import

### 2. 코드 품질 문제
- **중복 코드**: 각 calculate 메서드에 유사 로직 반복
- **매직 넘버**: 하드코딩된 크기 값들 (100, 200, 300 등)
- **Deprecated 메서드**: 구버전 메서드가 여전히 남아있음

### 3. 성능 문제
- **MediaQuery 반복 호출**: 캐싱 없이 매번 계산
- **디버그 출력 과다**: 프로덕션에서도 조건부 로그

### 4. 확장성 문제
- **새 디바이스 추가 어려움**: switch문에 직접 추가 필요
- **새 컨테이너 타입**: 메서드 추가로 인한 코드 팽창

## 🎯 Services Layer 유지 필요성

### 왜 Services Layer에 있어야 하는가?

1. **전역 서비스 특성**
   - 모든 Feature(posts, chat, notifications)에서 공통 사용
   - 중앙 집중식 UI 계산 로직
   - 일관된 반응형 디자인 보장

2. **인프라 레벨 기능**
   - 애플리케이션 전반의 UI 일관성
   - Feature 독립성 보장
   - 디바이스별 최적화 관리

3. **크로스커팅 관심사**
   - 여러 Feature에 걸친 공통 UI 로직
   - 단일 책임 원칙 준수
   - 중복 코드 방지

### Feature-First Architecture 준수

```
✅ 올바른 의존성:
Features (posts, chat, notifications...)
    ↓ 사용
Services (ui, cache, moderation...)
    ↓ 사용
Backend (firebase, models...)

❌ 잘못된 접근:
- UI 계산을 Feature로 이동
- Feature별 반응형 중복 구현
- Services가 Feature 모델 직접 import
```

## 💡 주요 개선 제안

### 1. 의존성 주입 패턴 적용
```dart
// 인터페이스 정의
abstract class IResponsiveService {
  DeviceType getDeviceType(BuildContext context);
  double getMaxMessageWidth(BuildContext context);
}

// DI 컨테이너 등록
getIt.registerSingleton<IResponsiveService>(
  ResponsiveService()
);
```

### 2. 브레이크포인트 설정 클래스
```dart
@immutable
class BreakpointConfig {
  final Map<DeviceType, double> breakpoints;
  final Map<DeviceType, double> messageWidths;
  
  const BreakpointConfig({
    required this.breakpoints,
    required this.messageWidths,
  });
}
```

### 3. 박스 계산 빌더 패턴
```dart
class BoxSizeBuilder {
  BoxSizeBuilder withContainer(double width);
  BoxSizeBuilder withLayout(LayoutType type);
  BoxSizeBuilder withAspectRatios(double? a, double? b);
  BoxSizes build();
}
```

### 4. 캐싱 시스템
```dart
class ResponsiveCache {
  final _cache = <String, dynamic>{};
  
  T getCached<T>(String key, T Function() calculate) {
    return _cache[key] ??= calculate();
  }
}
```

## 🔗 연관 시스템

### 사용처 (Features)
- **posts**: 질문 작성 시 VS 박스 크기 계산
- **chat**: 메시지 카드 레이아웃 및 버블 크기
- **notifications**: 알림 다이얼로그 VS 박스 표시
- **profile**: 프로필 카드 반응형 레이아웃

### 의존성 (Core/Backend)
- **core/constants**: LayoutConstants 상수값
- **features/posts**: AspectRatioAnalyzer (문제: 역방향 의존!)

### 통합 대상
- **Cache Service**: 계산 결과 캐싱
- **Theme Service**: 디바이스별 테마 적용
- **Animation Service**: 레이아웃 전환 애니메이션

## 📊 메트릭스

### 현재 성능
- MediaQuery 호출: 프레임당 3-5회
- 박스 계산 시간: ~2ms
- 메모리 사용: 최소 (정적 메서드)
- 캐싱: 없음

### 개선 목표
- MediaQuery 캐싱: 프레임당 1회
- 계산 시간: <0.5ms (캐시 히트)
- 메모리: <1MB (캐시 포함)
- 재사용률: >80%

## 📝 다음 단계

### Phase 1: 의존성 정리 (긴급)
```dart
// AspectRatioAnalyzer 의존성 제거
// LayoutConstants를 Services Layer로 이동
// 순환 의존성 해결
```

### Phase 2: 아키텍처 개선 (1주)
```dart
// 인터페이스 정의
// DI 패턴 적용
// 단위 테스트 추가
```

### Phase 3: 성능 최적화 (1주)
```dart
// 캐싱 시스템 구현
// MediaQuery 최적화
// 디버그 로그 정리
```

### Phase 4: 기능 확장 (2주)
```dart
// 새로운 디바이스 타입 지원
// 동적 브레이크포인트 설정
// 테마별 크기 조정
```

## ⚠️ 주의사항

1. **Services Layer 유지**: Feature로 이동하지 말 것
2. **역방향 의존성 제거**: Features에서 Services로의 import 금지
3. **일관성 유지**: 모든 VS 박스는 UnifiedBoxCalculator 사용
4. **버전 호환성**: Deprecated 메서드 제거 시 마이그레이션 가이드 제공

## 🏆 품질 목표

### 코드 품질
- 테스트 커버리지: 90% 이상
- 정적 분석 경고: 0개
- 문서화: 모든 public API

### 성능 목표
- 계산 시간: P95 < 1ms
- 메모리: < 1MB
- 캐시 히트율: > 80%

### 신뢰성 목표
- 크래시율: 0%
- 레이아웃 깨짐: 0건
- 디바이스 호환성: 100%

## 📚 참고 자료

- [Flutter Responsive Design](https://docs.flutter.dev/ui/layout/responsive)
- [Material Design Breakpoints](https://material.io/design/layout/responsive-layout-grid.html)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)

---

*이 문서는 Versus Space UI Service의 구조와 사용법을 설명합니다.*  
*Services Layer는 전역 인프라로 유지되어야 합니다.*