# 📋 Core Animations 레이어

> 애플리케이션 전역 애니메이션 시스템 레이어  
> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Animations는 Versus Space 애플리케이션의 전역 애니메이션 시스템을 관리하는 레이어입니다.
flutter_animate 패키지를 활용하여 페이지 로드 및 액션 트리거 기반 애니메이션을 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/animations/
└── app_animations.dart     # 113줄 - 애니메이션 시스템 구현
```

## 🔍 현재 코드 분석

### app_animations.dart (113줄)

#### 핵심 구성요소

**1. AnimationTrigger Enum**
```dart
enum AnimationTrigger {
  onPageLoad,      // 페이지 로드 시 자동 실행
  onActionTrigger,  // 액션 트리거로 수동 실행
}
```

**2. AnimationInfo Class**
```dart
class AnimationInfo {
  final AnimationTrigger trigger;           // 애니메이션 트리거 타입
  final List<Effect> Function()? effectsBuilder;  // 효과 생성 빌더
  final bool applyInitialState;            // 초기 상태 적용 여부
  final bool loop;                         // 반복 실행 여부
  final bool reverse;                      // 역방향 실행 여부
  late AnimationController controller;     // 애니메이션 컨트롤러
}
```

**3. Widget Extension Methods**
```dart
extension AnimatedWidgetExtension on Widget {
  // 페이지 로드 시 애니메이션
  Widget animateOnPageLoad(AnimationInfo animationInfo, {List<Effect>? effects})
  
  // 액션 트리거 애니메이션
  Widget animateOnActionTrigger(AnimationInfo animationInfo, {List<Effect>? effects, bool hasBeenTriggered})
}
```

**4. TiltEffect Custom Effect**
```dart
class TiltEffect extends Effect<Offset> {
  // 3D 틸트 효과 구현
  // X, Y 축 회전 변환 적용
}
```

#### 주요 기능

1. **애니메이션 트리거 시스템**
   - 페이지 로드 자동 트리거
   - 액션 기반 수동 트리거
   - 트리거 상태 관리

2. **애니메이션 효과 빌더**
   - 동적 효과 생성
   - 효과 업데이트 지원
   - 효과 캐싱 메커니즘

3. **애니메이션 컨트롤 옵션**
   - 반복 실행 (loop)
   - 역방향 재생 (reverse)
   - 초기 상태 적용 제어

4. **커스텀 3D 효과**
   - TiltEffect: 3D 회전 효과
   - Matrix4 변환 활용
   - X, Y 축 독립 제어

#### 사용 예시

```dart
// 페이지 로드 애니메이션
Container().animateOnPageLoad(
  animationInfo,
  effects: [
    FadeEffect(duration: 600.ms),
    MoveEffect(begin: Offset(0, 50)),
  ],
);

// 액션 트리거 애니메이션
Button().animateOnActionTrigger(
  animationInfo,
  hasBeenTriggered: isTriggered,
);
```

## ⚠️ 현재 문제점 종합

### 1. 아키텍처 문제
- **단일 파일 구조**: 모든 애니메이션 로직이 한 파일에 집중
- **확장성 부족**: 새로운 효과나 트리거 추가 어려움
- **재사용성 한계**: 컴포넌트별 애니메이션 분리 안 됨

### 2. 구현 문제
- **효과 종류 부족**: TiltEffect 하나만 구현
- **애니메이션 프리셋 없음**: 매번 효과 수동 정의
- **성능 최적화 부재**: 애니메이션 최적화 전략 없음

### 3. Feature 통합 문제
- **Feature별 커스터마이징 어려움**: 전역 설정만 존재
- **테마 연동 없음**: 다크/라이트 모드 대응 안 됨
- **접근성 고려 부족**: 애니메이션 비활성화 옵션 없음

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조
```
lib/
├── core/
│   └── animations/
│       ├── interfaces/         # 애니메이션 인터페이스
│       │   ├── i_animation.dart
│       │   └── i_effect.dart
│       ├── models/             # 애니메이션 모델
│       │   ├── animation_config.dart
│       │   └── animation_state.dart
│       ├── effects/            # 기본 효과 모음
│       │   ├── basic_effects.dart
│       │   ├── transform_effects.dart
│       │   └── custom_effects.dart
│       └── presets/            # 애니메이션 프리셋
│           ├── page_transitions.dart
│           ├── micro_interactions.dart
│           └── loading_animations.dart
│
├── services/
│   └── animations/
│       ├── animation_service.dart      # 애니메이션 관리 서비스
│       ├── animation_controller_pool.dart  # 컨트롤러 풀 관리
│       └── performance_optimizer.dart  # 성능 최적화
│
└── features/
    └── [각 feature]/
        └── animations/         # Feature별 커스텀 애니메이션
```

### 2. 인터페이스 기반 설계
```dart
// core/animations/interfaces/i_animation.dart
abstract class IAnimation {
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> reverse();
}

// core/animations/interfaces/i_effect.dart
abstract class IEffect<T> {
  Duration get duration;
  Curve get curve;
  T get begin;
  T get end;
  Widget apply(Widget child, Animation<T> animation);
}
```

### 3. 애니메이션 프리셋 시스템
```dart
// core/animations/presets/page_transitions.dart
class PageTransitions {
  static const fadeIn = AnimationPreset(
    duration: Duration(milliseconds: 300),
    effects: [FadeEffect(), ScaleEffect()],
  );
  
  static const slideUp = AnimationPreset(
    duration: Duration(milliseconds: 400),
    effects: [SlideEffect(), FadeEffect()],
  );
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|---------|----------|--------|--------|
| 애니메이션 프리셋 시스템 | 🔴 매우 높음 | 1일 | 중간 | 높음 |
| 효과 라이브러리 확장 | 🔴 매우 높음 | 2일 | 중간 | 높음 |
| 성능 최적화 | 🟡 중간 | 1일 | 높음 | 중간 |
| Feature 통합 | 🟡 중간 | 2일 | 중간 | 높음 |
| 접근성 지원 | 🟢 낮음 | 1일 | 낮음 | 중간 |

## 🚀 구현 로드맵

### Phase 1: 기본 구조 개선 (1일)
- 인터페이스 정의
- 디렉토리 구조 재편성
- 기본 효과 라이브러리 확장

### Phase 2: 프리셋 시스템 구축 (2일)
- 페이지 전환 프리셋
- 마이크로 인터랙션 프리셋
- 로딩 애니메이션 프리셋

### Phase 3: 성능 최적화 (1일)
- AnimationController 풀 구현
- 메모리 관리 개선
- 프레임 드롭 방지

### Phase 4: Feature 통합 (2일)
- Feature별 커스텀 애니메이션
- 테마 연동
- 접근성 옵션 추가

## 💡 주요 개선 제안

### 1. 애니메이션 프리셋
```dart
// 사용이 간편한 프리셋 제공
widget.animate(Presets.fadeInUp);
```

### 2. 성능 최적화
```dart
// 애니메이션 컨트롤러 재사용
final controller = AnimationControllerPool.get();
```

### 3. 접근성 지원
```dart
// 애니메이션 비활성화 옵션
if (AccessibilityService.reduceMotion) {
  return child; // 애니메이션 없이 반환
}
```

## 🔗 연관 파일 및 의존성

### 현재 의존성
- `flutter_animate: ^4.5.0` - 애니메이션 라이브러리
- Flutter Animation API - 기본 애니메이션 시스템

### 영향받을 Feature들
- 모든 페이지 전환 애니메이션
- 버튼 및 인터랙션 애니메이션
- 로딩 및 스켈레톤 애니메이션
- 차트 및 데이터 시각화

### 통합 필요 시스템
- Theme 시스템과 연동
- Navigation 시스템과 통합
- Accessibility 서비스 연결

## ⚡ 성능 고려사항

1. **AnimationController 재사용**: 풀 패턴으로 메모리 절약
2. **효과 캐싱**: 자주 사용되는 효과 캐싱
3. **조건부 애니메이션**: 필요한 경우에만 애니메이션 적용
4. **RepaintBoundary 활용**: 애니메이션 영역 격리

## 🚨 주의사항

1. **성능 영향**: 과도한 애니메이션은 성능 저하 유발
2. **접근성**: 모션 민감 사용자 고려 필수
3. **일관성**: Feature간 애니메이션 스타일 통일 필요
4. **테스트**: 애니메이션 테스트는 특별한 설정 필요

## 📋 체크리스트

### 즉시 수정 필요
- [ ] 애니메이션 프리셋 시스템 구축
- [ ] 기본 효과 라이브러리 확장
- [ ] 성능 모니터링 추가

### 단기 목표 (1주일)
- [ ] Feature별 애니메이션 분리
- [ ] 테마 시스템 연동
- [ ] 컨트롤러 풀 구현

### 장기 목표 (2주일)
- [ ] 완전한 접근성 지원
- [ ] 고급 3D 효과 추가
- [ ] 애니메이션 디버깅 도구

---

*이 문서는 Core Animations 레이어의 현재 상태와 개선 방안을 담고 있습니다.*  
*flutter_animate 기반의 기본 구현은 있으나 확장과 최적화가 필요한 상황입니다.*