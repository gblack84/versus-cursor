# 🔄 Core Animations 마이그레이션 계획 Part 3

> Core Animations 레이어 리팩토링 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 1주

## 📌 Executive Summary

**현재 상황**: 113줄의 단일 파일로 최소한의 애니메이션 시스템 구현  
**목표**: 확장 가능한 프리셋 기반 애니메이션 시스템 구축  
**방법**: 인터페이스 설계, 효과 라이브러리 확장, 성능 최적화

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/core/animations/
└── app_animations.dart    # 113줄 - 모든 로직이 한 파일에
```

### After (목표)
```
lib/
├── core/
│   └── animations/
│       ├── interfaces/         # 애니메이션 인터페이스
│       │   ├── i_animation.dart
│       │   ├── i_effect.dart
│       │   └── i_preset.dart
│       ├── models/             # 애니메이션 모델
│       │   ├── animation_config.dart
│       │   ├── animation_state.dart
│       │   └── animation_options.dart
│       ├── effects/            # 효과 라이브러리
│       │   ├── basic/
│       │   │   ├── fade_effect.dart
│       │   │   ├── scale_effect.dart
│       │   │   └── slide_effect.dart
│       │   ├── transform/
│       │   │   ├── rotate_effect.dart
│       │   │   ├── tilt_effect.dart
│       │   │   └── flip_effect.dart
│       │   └── custom/
│       │       ├── shimmer_effect.dart
│       │       └── wave_effect.dart
│       └── presets/            # 프리셋 모음
│           ├── page_transitions.dart
│           ├── micro_interactions.dart
│           ├── loading_animations.dart
│           └── hero_animations.dart
│
└── services/
    └── animations/
        ├── animation_service.dart
        ├── controller_pool.dart
        └── performance_monitor.dart
```

## 📊 현재 문제점 분석

### 1. 구조적 문제 심각도: 🟡 중간
```dart
// 현재: 모든 로직이 한 파일에
class AnimationInfo { ... }
class TiltEffect { ... }
extension AnimatedWidgetExtension { ... }
```

**영향 분석**:
- 새로운 효과 추가 어려움
- Feature별 커스터마이징 불가
- 코드 재사용성 낮음

### 2. 기능 부족 심각도: 🔴 높음
```
구현된 효과: 1개 (TiltEffect)
필요한 효과: 20개+
구현률: 5%
```

### 3. 성능 최적화 부재 심각도: 🟡 중간
```dart
// 매번 새 컨트롤러 생성
void createAnimation(AnimationInfo animation, TickerProvider vsync) {
  final newController = AnimationController(vsync: vsync);  // 메모리 낭비
}
```

## 🔍 기존 애니메이션 분석 및 통합 계획

### 발견된 기존 애니메이션 현황

#### 1. ChatAnimationService (`/features/chat/data/services/`)
```dart
// 현재: FAB 애니메이션 개별 구현
fabBounceAnimation = Tween<double>(begin: 1.0, end: 1.2)
  .animate(CurvedAnimation(curve: Curves.elasticOut));
fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0)
  .animate(CurvedAnimation(curve: Curves.easeInOut));
```
**→ 마이그레이션**: `MicroInteractions.fabBounce`, `MicroInteractions.fabScale` 프리셋으로 통합

#### 2. 알림 다이얼로그 (`/features/notifications/`)
```dart
// 현재: 각 다이얼로그에 중복 구현
_slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)
_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
Duration: slideAnimationDuration = 500ms, fadeAnimationDuration = 300ms
```
**→ 마이그레이션**: `NotificationAnimations.slideUp`, `NotificationAnimations.fadeIn` 프리셋으로 통합

#### 3. 투표 카드 및 미디어 박스 (`/features/posts/`)
```dart
// 현재: Shake 애니메이션 개별 구현
shakeAnimation: Animation<double>
shakeController: AnimationController
```
**→ 마이그레이션**: `Effects.shake()` 공통 효과로 통합

#### 4. Target Audience 다이얼로그 (`/features/posts/`)
```dart
// 현재: Fade 애니메이션 개별 구현
_fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn)
```
**→ 마이그레이션**: `DialogAnimations.fadeIn` 프리셋으로 통합

### 통합 우선순위
1. **높음**: ChatAnimationService (가장 많이 사용)
2. **높음**: 알림 다이얼로그 애니메이션 (사용자 경험 핵심)
3. **중간**: Shake 애니메이션 (여러 곳에서 재사용)
4. **낮음**: 기타 개별 애니메이션

## 📝 상세 마이그레이션 단계

### Step 1: 인터페이스 정의 (Day 1)

#### 1.1 애니메이션 인터페이스
```dart
// core/animations/interfaces/i_animation.dart
abstract class IAnimation {
  Duration get duration;
  AnimationStatus get status;
  
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> reverse();
  
  void addStatusListener(AnimationStatusListener listener);
  void removeStatusListener(AnimationStatusListener listener);
}

// core/animations/interfaces/i_effect.dart
abstract class IEffect<T> {
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final T begin;
  final T end;
  
  Widget apply(Widget child, Animation<T> animation);
  
  // 효과 합성 지원
  IEffect<T> operator +(IEffect<T> other);
}
```

#### 1.2 프리셋 인터페이스
```dart
// core/animations/interfaces/i_preset.dart
abstract class IPreset {
  String get name;
  String get description;
  Duration get duration;
  List<IEffect> get effects;
  PresetCategory get category;
  
  // 프리셋 적용
  Widget apply(Widget child, {AnimationController? controller});
  
  // 프리셋 커스터마이징
  IPreset withDuration(Duration duration);
  IPreset withEffects(List<IEffect> effects);
}

enum PresetCategory {
  pageTransition,
  microInteraction,
  loading,
  hero,
  custom,
}
```

### Step 2: 효과 라이브러리 구축 (Day 2-3)

#### 2.1 기본 효과 구현
```dart
// core/animations/effects/basic/fade_effect.dart
class FadeEffect extends IEffect<double> {
  FadeEffect({
    super.duration = const Duration(milliseconds: 300),
    super.delay = Duration.zero,
    super.curve = Curves.easeInOut,
    super.begin = 0.0,
    super.end = 1.0,
  });
  
  @override
  Widget apply(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

// core/animations/effects/basic/scale_effect.dart
class ScaleEffect extends IEffect<double> {
  @override
  Widget apply(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}

// core/animations/effects/basic/shake_effect.dart (기존 코드 통합)
class ShakeEffect extends IEffect<double> {
  final double intensity;
  
  ShakeEffect({
    this.intensity = 8.0,
    super.duration = const Duration(milliseconds: 200),
    super.curve = Curves.easeInOut,
  });
  
  @override
  Widget apply(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(sin(animation.value * pi * 2) * intensity, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}
```

#### 2.2 변형 효과 구현
```dart
// core/animations/effects/transform/rotate_effect.dart
class RotateEffect extends IEffect<double> {
  final Axis axis;
  
  RotateEffect({
    this.axis = Axis.z,
    super.duration = const Duration(milliseconds: 400),
    super.begin = 0.0,
    super.end = 1.0,
  });
  
  @override
  Widget apply(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.identity()
            ..rotate(axis, animation.value * 2 * pi),
          alignment: Alignment.center,
          child: child,
        );
      },
      child: child,
    );
  }
}
```

### Step 3: 프리셋 시스템 구현 (Day 3-4)

#### 3.1 페이지 전환 프리셋
```dart
// core/animations/presets/page_transitions.dart
class PageTransitions {
  static final fadeIn = AnimationPreset(
    name: 'fadeIn',
    description: '페이드인 전환',
    duration: const Duration(milliseconds: 300),
    effects: [
      FadeEffect(begin: 0, end: 1),
    ],
  );
  
  static final slideUp = AnimationPreset(
    name: 'slideUp',
    description: '아래에서 위로 슬라이드',
    duration: const Duration(milliseconds: 400),
    effects: [
      SlideEffect(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ),
      FadeEffect(begin: 0, end: 1),
    ],
  );
  
  static final zoomIn = AnimationPreset(
    name: 'zoomIn',
    description: '확대 진입',
    duration: const Duration(milliseconds: 350),
    effects: [
      ScaleEffect(begin: 0.8, end: 1.0),
      FadeEffect(begin: 0, end: 1),
    ],
  );
}
```

#### 3.2 마이크로 인터랙션 프리셋 (기존 ChatAnimationService 통합)
```dart
// core/animations/presets/micro_interactions.dart
class MicroInteractions {
  // ChatAnimationService의 FAB 애니메이션 통합
  static final fabBounce = AnimationPreset(
    name: 'fabBounce',
    description: 'FAB 바운스 효과',
    duration: const Duration(milliseconds: 600),
    curve: Curves.elasticOut,
    effects: [
      ScaleEffect(
        begin: 1.0,
        end: 1.2,
        curve: Curves.elasticOut,
      ),
    ],
  );
  
  static final fabScale = AnimationPreset(
    name: 'fabScale',
    description: 'FAB 스케일 효과',
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    effects: [
      ScaleEffect(
        begin: 0.0,
        end: 1.0,
        curve: Curves.easeInOut,
      ),
    ],
  );
  
  static final bounce = AnimationPreset(
    name: 'bounce',
    description: '바운스 효과',
    duration: const Duration(milliseconds: 600),
    curve: Curves.elasticOut,
    effects: [
      ScaleEffect(
        begin: 0.8,
        end: 1.0,
        curve: Curves.elasticOut,
      ),
    ],
  );
  
  // InPutPostImageWidget의 Shake 애니메이션 통합
  static final shake = AnimationPreset(
    name: 'shake',
    description: '흔들림 효과',
    duration: const Duration(milliseconds: 200),  // 기존 설정값 사용
    effects: [
      ShakeEffect(intensity: 8.0),  // 기존 설정값 사용
    ],
  );
}
```

#### 3.3 알림 애니메이션 프리셋 (기존 알림 다이얼로그 통합)
```dart
// core/animations/presets/notification_animations.dart
class NotificationAnimations {
  // 알림 다이얼로그의 슬라이드 애니메이션 통합
  static final slideUp = AnimationPreset(
    name: 'notificationSlideUp',
    description: '알림 슬라이드업',
    duration: const Duration(milliseconds: 500),  // 기존 설정값 사용
    effects: [
      SlideEffect(
        begin: const Offset(0, 1),
        end: Offset.zero,
        curve: Curves.easeOut,
      ),
    ],
  );
  
  // 알림 다이얼로그의 페이드 애니메이션 통합
  static final fadeIn = AnimationPreset(
    name: 'notificationFadeIn',
    description: '알림 페이드인',
    duration: const Duration(milliseconds: 300),  // 기존 설정값 사용
    effects: [
      FadeEffect(
        begin: 0.0,
        end: 1.0,
        curve: Curves.easeIn,
      ),
    ],
  );
  
  // 복합 애니메이션
  static final slideUpWithFade = AnimationPreset(
    name: 'notificationSlideUpWithFade',
    description: '알림 슬라이드업 + 페이드',
    duration: const Duration(milliseconds: 500),
    effects: [
      SlideEffect(
        begin: const Offset(0, 1),
        end: Offset.zero,
        curve: Curves.easeOut,
      ),
      FadeEffect(
        begin: 0.0,
        end: 1.0,
        curve: Curves.easeIn,
      ),
    ],
  );
}
```

### Step 4: 서비스 레이어 구현 (Day 4-5)

#### 4.1 애니메이션 서비스
```dart
// services/animations/animation_service.dart
@LazySingleton()
class AnimationService {
  final ControllerPool _controllerPool;
  final PerformanceMonitor _performanceMonitor;
  final Map<String, IPreset> _presets = {};
  
  AnimationService(this._controllerPool, this._performanceMonitor);
  
  // 프리셋 등록
  void registerPreset(IPreset preset) {
    _presets[preset.name] = preset;
  }
  
  // 프리셋 적용
  Widget applyPreset(
    Widget child,
    String presetName, {
    AnimationController? controller,
  }) {
    final preset = _presets[presetName];
    if (preset == null) {
      return child;
    }
    
    // 성능 모니터링
    _performanceMonitor.track(presetName);
    
    // 컨트롤러 재사용
    final animController = controller ?? _controllerPool.get();
    
    return preset.apply(child, controller: animController);
  }
  
  // 접근성 지원
  bool get reduceMotion => _accessibilityService.reduceMotion;
}
```

#### 4.2 컨트롤러 풀
```dart
// services/animations/controller_pool.dart
@LazySingleton()
class ControllerPool {
  final Queue<AnimationController> _available = Queue();
  final Set<AnimationController> _inUse = {};
  static const int _maxPoolSize = 10;
  
  AnimationController get() {
    if (_available.isNotEmpty) {
      final controller = _available.removeFirst();
      _inUse.add(controller);
      return controller;
    }
    
    // 새로 생성
    final controller = AnimationController(
      vsync: TickerProviderService.instance,
    );
    _inUse.add(controller);
    return controller;
  }
  
  void release(AnimationController controller) {
    controller.reset();
    _inUse.remove(controller);
    
    if (_available.length < _maxPoolSize) {
      _available.add(controller);
    } else {
      controller.dispose();
    }
  }
}
```

### Step 5: 테스트 및 최적화 (Day 6-7)

#### 5.1 단위 테스트
```dart
// test/core/animations/effects_test.dart
void main() {
  group('Animation Effects', () {
    test('FadeEffect should animate opacity', () async {
      final effect = FadeEffect(begin: 0, end: 1);
      final controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: TestVSync(),
      );
      
      // 애니메이션 시작
      controller.forward();
      
      // 중간 지점 확인
      controller.value = 0.5;
      expect(controller.value, 0.5);
      
      // 완료 확인
      await controller.forward();
      expect(controller.value, 1.0);
    });
  });
}
```

#### 5.2 성능 모니터링
```dart
// services/animations/performance_monitor.dart
class PerformanceMonitor {
  final Map<String, AnimationMetrics> _metrics = {};
  
  void track(String animationName) {
    _metrics[animationName] ??= AnimationMetrics();
    _metrics[animationName]!.increment();
  }
  
  void reportFrameDrop(String animationName, int droppedFrames) {
    _metrics[animationName]?.recordFrameDrop(droppedFrames);
    
    if (droppedFrames > 5) {
      debugPrint('⚠️ Animation $animationName dropped $droppedFrames frames');
    }
  }
  
  AnimationMetrics? getMetrics(String animationName) {
    return _metrics[animationName];
  }
}
```

## 🚀 실행 계획

### Week 1: 애니메이션 시스템 구축
- [ ] Day 1: 인터페이스 정의 및 디렉토리 구조 생성
- [ ] Day 2-3: 효과 라이브러리 구현 (20개 효과) + 기존 효과 통합
- [ ] Day 3-4: 프리셋 시스템 구축 + 기존 애니메이션 마이그레이션
- [ ] Day 4-5: 서비스 레이어 및 성능 최적화
- [ ] Day 6-7: 기존 코드 리팩토링 및 테스트 작성

### 기존 코드 마이그레이션 계획
#### Phase 1: 우선순위 높음 (Day 3)
- [ ] ChatAnimationService → MicroInteractions 프리셋
  - `/features/chat/data/services/chat_animation_service.dart` 리팩토링
  - FAB 애니메이션을 프리셋으로 교체
- [ ] 알림 다이얼로그 → NotificationAnimations 프리셋
  - `/features/notifications/presentation/widgets/in_app_notification_dialog.dart`
  - `/features/notifications/presentation/widgets/voting_notification_dialog.dart`

#### Phase 2: 우선순위 중간 (Day 4)
- [ ] Shake 애니메이션 → Effects.shake() 통합
  - `/features/posts/presentation/screens/create_post/in_put_post_image_widget.dart`
  - `/features/posts/presentation/widgets/components/base_media_selection_box.dart`
  - `/features/posts/presentation/widgets/components/media_selection_box_single.dart`

#### Phase 3: 우선순위 낮음 (Day 5)
- [ ] Target Audience 다이얼로그 → DialogAnimations 프리셋
  - `/features/posts/presentation/widgets/dialogs/target_audience_dialog.dart`

## 📈 성공 지표

### 정량적 지표
- ✅ 효과 구현: 1개 → 20개+
- ✅ 프리셋 제공: 0개 → 15개+
- ✅ 성능: 60fps 유지
- ✅ 메모리: 컨트롤러 재사용으로 50% 절감

### 정성적 지표
- ✅ 일관된 애니메이션 경험
- ✅ Feature별 커스터마이징 가능
- ✅ 접근성 지원 완비
- ✅ 개발자 경험 향상

## ⚠️ 리스크 및 대응 방안

### Risk 1: 성능 저하
**문제**: 복잡한 애니메이션으로 프레임 드롭  
**대응**: 
- RepaintBoundary 적극 활용
- 조건부 애니메이션 적용
- 성능 모니터링 강화

### Risk 2: 기존 코드 호환성
**문제**: 기존 AnimationInfo 사용 코드와 충돌  
**대응**: 
- 하위 호환성 레이어 제공
- 점진적 마이그레이션 지원
- Deprecated 어노테이션 활용

### Risk 3: 테스트 복잡도
**문제**: 애니메이션 테스트 어려움  
**대응**: 
- TestVSync 제공
- 애니메이션 목 객체 구현
- Golden 테스트 활용

## 🔄 롤백 계획

### 즉시 롤백 시나리오
```dart
// 기능 플래그로 제어
class AnimationConfig {
  static bool useNewSystem = false; // 문제 발생 시 false로
}

// 사용처
if (AnimationConfig.useNewSystem) {
  return widget.applyPreset(PageTransitions.fadeIn);
} else {
  return widget.animateOnPageLoad(oldAnimationInfo);
}
```

## 📚 참고 자료

- [flutter_animate](https://pub.dev/packages/flutter_animate) - 현재 사용 중인 패키지
- [Flutter Animations](https://docs.flutter.dev/development/ui/animations) - 공식 문서
- [Material Motion](https://material.io/design/motion) - 디자인 가이드라인

## 🏁 체크리스트

### 마이그레이션 전
- [ ] 현재 애니메이션 사용처 파악 ✅ (32개 파일 확인 완료)
- [ ] 성능 베이스라인 측정
- [ ] 테스트 환경 준비

### 마이그레이션 중
- [ ] 인터페이스 정의 (IAnimation, IEffect, IPreset)
- [ ] 효과 라이브러리 구축
  - [ ] 기본 효과 (fade, scale, slide)
  - [ ] 기존 효과 통합 (shake, tilt)
  - [ ] 추가 효과 (rotate, flip, shimmer, wave)
- [ ] 프리셋 시스템 구현
  - [ ] PageTransitions
  - [ ] MicroInteractions (FAB 애니메이션 통합)
  - [ ] NotificationAnimations (알림 애니메이션 통합)
  - [ ] DialogAnimations
- [ ] 서비스 레이어 구축
  - [ ] AnimationService
  - [ ] ControllerPool
  - [ ] PerformanceMonitor
- [ ] 기존 코드 리팩토링
  - [ ] ChatAnimationService 교체
  - [ ] 알림 다이얼로그 교체
  - [ ] Shake 애니메이션 통합
  - [ ] Target Audience 다이얼로그 교체

### 마이그레이션 후
- [ ] 모든 테스트 통과
- [ ] 성능 지표 달성
- [ ] 문서 업데이트
- [ ] 기존 애니메이션 제거 및 정리

---

*이 문서는 Core Animations 레이어의 구체적인 마이그레이션 계획입니다.*  
*1주간의 집중 개발로 확장 가능한 애니메이션 시스템을 구축합니다.*