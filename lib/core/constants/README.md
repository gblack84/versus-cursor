# 📋 Core Constants 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Constants는 애플리케이션 전역에서 사용되는 상수값들을 중앙 집중식으로 관리하는 레이어입니다.
스마트 레이아웃 시스템의 크기 제한값과 비율을 통합 관리하여 일관성을 보장합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/constants/
└── layout_constants.dart    # 214줄 - 스마트 레이아웃 시스템 상수
```

## 🔍 현재 코드 분석

### layout_constants.dart (214줄)

#### 핵심 구성요소

**1. 레이아웃 상수 그룹**
- **질문 작성 페이지 상수**
  - 가로 배치: 최대 500px, 최소 150px
  - 세로 배치: 최대 400px, 최소 120px  
  - 단일 이미지: 최대 600px
  - 너비 사용률: 100%

- **알림 다이얼로그 상수**
  - 화면 대비 비율 기반
  - 가로 배치: 화면의 90%
  - 세로 배치: 화면의 88%
  - 너비: 화면의 92% (최대 500px, 최소 320px)

- **메시지 카드 상수**
  - 가로 배치: 최대 400px, 최소 200px
  - 세로 배치: 최대 350px, 최소 200px
  - 너비 사용률: 95%

**2. 헬퍼 메서드**
```dart
// 컨테이너 타입별 최대/최소 높이 계산
static double getMaxHeight({
  required String containerType,
  required bool isHorizontal,
  bool isSingle = false,
  double? screenHeight,
})

// 너비 사용률 반환
static double getWidthRatio({
  required String containerType,
  required bool isHorizontal,
  required bool isSingle,
})
```

#### 사용 현황

**직접 사용 파일**:
- `lib/services/ui/unified_box_calculator.dart` - 박스 크기 계산
- 3개 컴포넌트에서 통합 사용 중

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **단일 파일 집중**: 모든 레이아웃 상수가 하나의 파일에
- **분산된 상수**: Design System tokens와 분리됨
- **계층 부재**: 도메인별 상수 그룹핑 없음

### 2. 관리 문제
- **네이밍 일관성**: containerType 문자열 상수 사용
- **타입 안정성**: 문자열 기반 타입 구분
- **확장성**: 새로운 컴포넌트 추가 시 파일 수정 필요

### 3. Feature 연관성
- **직접 의존**: Feature들이 Core 상수 직접 참조
- **변경 영향도**: 상수 변경 시 여러 Feature 영향
- **테스트 어려움**: 상수값 변경 테스트 어려움

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조
```
lib/
├── core/
│   └── constants/
│       ├── app/                    # 앱 전역 상수
│       │   ├── app_constants.dart  # 앱 설정
│       │   ├── api_constants.dart  # API 엔드포인트
│       │   └── env_constants.dart  # 환경 변수
│       │
│       ├── layout/                  # 레이아웃 상수
│       │   ├── layout_constants.dart  # 기존 파일 유지
│       │   ├── breakpoints.dart    # 반응형 중단점
│       │   └── grid_constants.dart # 그리드 시스템
│       │
│       ├── theme/                   # 테마 상수 (design_system과 통합)
│       │   ├── color_constants.dart
│       │   ├── spacing_constants.dart
│       │   └── typography_constants.dart
│       │
│       ├── validation/              # 유효성 검증 상수
│       │   ├── input_limits.dart   # 입력 제한
│       │   └── rules_constants.dart # 비즈니스 규칙
│       │
│       └── index.dart              # 통합 export
```

### 2. 타입 안전성 개선
```dart
// 현재 (문자열 기반)
static const String containerTypeQuestion = 'question';

// 개선 (enum 기반)
enum ContainerType {
  question,
  notification,
  message,
}

// 또는 sealed class 활용
sealed class ContainerType {
  const ContainerType();
}
class QuestionContainer extends ContainerType {
  const QuestionContainer();
}
```

### 3. Feature별 상수 확장
```dart
// core/constants/base/base_constants.dart
abstract class BaseConstants {
  // 공통 인터페이스
}

// features/posts/constants/post_constants.dart
class PostConstants extends BaseConstants {
  static const maxImageSize = 10 * 1024 * 1024; // 10MB
  static const maxVideoLength = 60; // seconds
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|---------|----------|--------|--------|
| 타입 안전성 개선 | 🔴 매우 높음 | 1일 | 낮음 | 높음 |
| 디렉토리 구조화 | 🟡 중간 | 0.5일 | 낮음 | 중간 |
| Design System 통합 | 🟡 중간 | 1일 | 중간 | 높음 |
| Feature별 확장 | 🟢 낮음 | 2일 | 중간 | 중간 |

## 🚀 구현 로드맵

### Phase 1: 타입 안전성 (즉시)
- ContainerType enum 생성
- 기존 문자열 상수를 enum으로 마이그레이션
- 컴파일 타임 타입 체크 활성화

### Phase 2: 구조 개선 (1일)
- 디렉토리 구조 생성
- 상수 그룹별 분리
- index.dart 통합 export 생성

### Phase 3: Design System 통합 (2일)
- design_system/tokens와 constants 통합
- 중복 제거
- 일관된 네이밍 적용

## 💡 주요 개선 제안

### 1. 환경별 상수 관리
```dart
class AppConstants {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get apiUrl => isProduction
    ? 'https://api.versus.space'
    : 'http://localhost:8080';
}
```

### 2. 반응형 상수
```dart
class ResponsiveConstants {
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 600;
    
  static double getAdaptiveSpacing(BuildContext context) =>
    isMobile(context) ? 8.0 : 16.0;
}
```

### 3. Feature별 오버라이드
```dart
class FeatureConstants {
  static Map<String, dynamic> _overrides = {};
  
  static void override(String key, dynamic value) {
    _overrides[key] = value;
  }
  
  static T get<T>(String key, T defaultValue) {
    return _overrides[key] ?? defaultValue;
  }
}
```

## 🔗 연관 파일 및 의존성

### 현재 사용처
- `lib/services/ui/unified_box_calculator.dart` - 박스 크기 계산
- `lib/components/notifications/voting_notification_dialog.dart` - 알림 UI
- `lib/components/chat/vote_card_message.dart` - 메시지 카드

### Design System 연관
- `lib/core/design_system/tokens/` - 디자인 토큰들
- `lib/core/theme/app_theme.dart` - 테마 설정

### Feature 의존성
- Posts Feature - 질문 작성 레이아웃
- Chat Feature - 메시지 카드 크기
- Notification Feature - 알림 다이얼로그 크기

## ⚡ 성능 고려사항

1. **컴파일 타임 최적화**: const 상수로 트리 쉐이킹 지원
2. **런타임 계산 최소화**: 정적 메서드로 빠른 접근
3. **메모리 효율성**: 싱글톤 패턴 불필요

## 🚨 주의사항

1. **Breaking Changes**: 타입 변경 시 전체 앱 영향
2. **Design System 동기화**: tokens와 일관성 유지 필수
3. **Feature 독립성**: Core 상수는 Feature 독립적이어야 함

## 📋 체크리스트

### 즉시 수정 필요
- [ ] ContainerType enum 생성
- [ ] 문자열 상수를 enum으로 변경
- [ ] 타입 안전성 테스트 추가

### 단기 목표 (1주일)
- [ ] 디렉토리 구조 개선
- [ ] Design System과 통합
- [ ] 문서화 완성

### 장기 목표 (2주일)
- [ ] Feature별 상수 확장 시스템
- [ ] 환경별 상수 관리
- [ ] 반응형 상수 시스템

---

*이 문서는 Core Constants 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*스마트 레이아웃 시스템의 핵심 상수 관리를 담당합니다.*