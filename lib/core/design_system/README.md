# 📎 Core Design System 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Design System은 Versus Space 애플리케이션 전체에서 사용되는 디자인 토큰과 UI 컴포넌트를 중앙 집중식으로 관리하는 레이어입니다.
일관된 시각적 경험과 효율적인 개발을 위한 표준화된 디자인 시스템을 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/design_system/
├── design_system.dart       # 27줄 - 통합 export 파일
├── tokens/                  # 디자인 토큰 (색상, 간격, 타이포그래피 등)
│   ├── versus_tokens.dart   # 26줄 - 토큰 통합 export
│   ├── versus_colors.dart   # 42줄 - 색상 시스템
│   ├── versus_spacing.dart  # 67줄 - 간격 시스템
│   ├── versus_text_styles.dart # 158줄 - 타이포그래피
│   ├── versus_radius.dart   # 55줄 - 모서리 반경
│   ├── versus_icons.dart    # 176줄 - 아이콘 시스템
│   └── versus_icon_data.dart # 32줄 - 아이콘 데이터
├── components/              # UI 컴포넌트
│   ├── versus_components.dart # 28줄 - 컴포넌트 통합 export
│   ├── versus_button.dart   # 292줄 - 버튼 컴포넌트
│   ├── versus_dialog.dart   # 346줄 - 다이얼로그 컴포넌트
│   ├── versus_text_field.dart # 405줄 - 텍스트 필드
│   └── versus_icon.dart     # 28줄 - 아이콘 컴포넌트
└── utils/                   # 유틸리티
    └── icon_style_manager.dart # 62줄 - 아이콘 스타일 관리

총 14개 파일, 1,717줄
```

## 🔍 현재 코드 분석

### 1. Design Tokens (556줄)

#### versus_colors.dart (42줄)
**핵심 구성요소**:
- 브랜드 색상: primary(빨강), secondary(초록)
- 배경 색상: backgroundPrimary, backgroundSecondary
- 텍스트 색상: textPrimary, textSecondary
- 상태 색상: success, warning, error, info
- 다크모드 색상 준비 (미사용)

**문제점**:
- 하드코딩된 색상값
- 테마 시스템 미구현
- Material 3 가이드라인 미준수

#### versus_spacing.dart (67줄)
**핵심 구성요소**:
- 4px 기반 간격 시스템 (xs: 4, sm: 8, md: 16, lg: 20, xl: 32, xxl: 48)
- EdgeInsets 헬퍼 메서드
- 자주 사용되는 패턴 (screenPadding, cardPadding 등)

**장점**:
- 일관된 4px 그리드 시스템
- EdgeInsets 헬퍼로 편리한 사용

#### versus_text_styles.dart (158줄)
**핵심 구성요소**:
- Google Fonts Plus Jakarta Sans 사용
- 계층적 타이포그래피 (heading, body, label, button)
- 크기별 변형 (Large, Medium, Small)

**문제점**:
- GoogleFonts 직접 의존
- 반응형 타이포그래피 미지원
- 테마별 스타일 변경 불가

### 2. Components (1,071줄)

#### versus_button.dart (292줄)
**구현 특징**:
- Factory 패턴 사용 (primary, secondary, outline, text, icon)
- 크기 시스템 (small, medium, large)
- 로딩 상태 지원
- 전체 너비 옵션

**장점**:
- 일관된 버튼 스타일
- 다양한 변형 지원

#### versus_dialog.dart (346줄)
**구현 특징**:
- Factory 패턴 (warning, error, success, info, custom)
- 커스터마이징 가능한 액션
- 애니메이션 지원

**문제점**:
- 346줄의 단일 파일 (너무 큼)
- 접근성 미고려

#### versus_text_field.dart (405줄)
**구현 특징**:
- 다양한 타입 지원 (text, email, password, multiline)
- 유효성 검증 내장
- 커스텀 데코레이션

**문제점**:
- 405줄의 거대한 단일 파일
- Feature별 커스터마이징 어려움

### 3. 사용 현황

**직접 사용 파일**: 20개 이상의 Feature 모듈
- search, profile, posts, notifications, chat feature에서 활발히 사용
- 특히 VersusColors, VersusSpacing이 가장 많이 사용됨

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **Feature 독립성 위반**: Core에 UI 컴포넌트 포함
- **과도한 중앙 집중**: 모든 컴포넌트가 Core에 위치
- **테마 시스템 부재**: Material Theme 통합 미비

### 2. 확장성 문제
- **큰 파일 크기**: versus_text_field.dart (405줄), versus_dialog.dart (346줄)
- **Feature별 커스터마이징 어려움**: 중앙 집중식 컴포넌트
- **반응형 디자인 미지원**: 고정된 크기와 스타일

### 3. 유지보수 문제
- **테스트 부재**: 디자인 시스템 테스트 없음
- **문서화 미비**: 사용 가이드라인 부족
- **버전 관리 없음**: 디자인 시스템 변경 추적 어려움

## 🎯 Feature-First Architecture 적용 방안

### 1. 올바른 계층 구조

```
lib/
├── core/
│   └── design_system/           # 토큰만 유지
│       └── tokens/              # 디자인 토큰 (색상, 간격, 타이포그래피)
│           ├── colors/
│           ├── spacing/
│           ├── typography/
│           └── theme/
│
├── shared/                      # 공용 컴포넌트로 이동
│   └── widgets/
│       ├── buttons/            # 버튼 컴포넌트
│       ├── dialogs/            # 다이얼로그 컴포넌트
│       ├── inputs/             # 입력 컴포넌트
│       └── feedback/           # 피드백 컴포넌트
│
└── features/
    └── [feature_name]/
        └── presentation/
            └── widgets/         # Feature별 커스텀 컴포넌트
```

### 2. 토큰 시스템 개선

```dart
// 현재 (정적 클래스)
class VersusColors {
  static const Color primary = Color(0xFFD95B5B);
}

// 개선 (Theme Extension)
@immutable
class VersusColorScheme extends ThemeExtension<VersusColorScheme> {
  final Color primary;
  final Color secondary;
  
  const VersusColorScheme({
    required this.primary,
    required this.secondary,
  });
  
  @override
  ThemeExtension<VersusColorScheme> copyWith({...}) {...}
  
  @override
  ThemeExtension<VersusColorScheme> lerp(...) {...}
}
```

### 3. 컴포넌트 분리 전략

```dart
// Core: 토큰만
// core/design_system/tokens/colors.dart
abstract class DesignTokens {
  static const Map<String, Color> colors = {...};
}

// Shared: 범용 컴포넌트
// shared/widgets/buttons/app_button.dart
class AppButton extends StatelessWidget {
  // 기본 버튼 구현
}

// Feature: 특화 컴포넌트
// features/posts/presentation/widgets/vote_button.dart
class VoteButton extends AppButton {
  // 투표 기능 특화 버튼
}
```

## 📊 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|----------|----------|--------|--------|
| 토큰 Theme Extension 전환 | 🔴 매우 높음 | 2일 | 중간 | 매우 높음 |
| 컴포넌트 shared로 이동 | 🔴 매우 높음 | 1일 | 낮음 | 높음 |
| 테마 시스템 구현 | 🟡 중간 | 2일 | 높음 | 매우 높음 |
| 컴포넌트 분할 | 🟡 중간 | 3일 | 중간 | 중간 |
| 반응형 시스템 | 🟢 낮음 | 2일 | 중간 | 중간 |

## 🚀 구현 로드맵

### Phase 1: 토큰 시스템 개선 (즉시)
- Design Token을 Theme Extension으로 전환
- Material 3 테마 통합
- 다크모드 지원 구현

### Phase 2: 구조 재편성 (1주일)
- 컴포넌트를 shared/widgets로 이동
- Feature별 커스텀 위젯 분리
- 의존성 정리

### Phase 3: 품질 개선 (2주일)
- 컴포넌트 테스트 작성
- Storybook 스타일 문서화
- 접근성 개선

## 💡 주요 개선 제안

### 1. Material 3 통합
```dart
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: VersusColors.primary,
      ),
      extensions: [
        VersusColorScheme.light(),
        VersusSpacingTheme.standard(),
        VersusTypography.standard(),
      ],
    );
  }
}
```

### 2. 원자 디자인 시스템
```
atoms/       # 기본 요소 (색상, 타이포그래피)
molecules/   # 간단한 컴포넌트 (버튼, 입력)
organisms/   # 복합 컴포넌트 (카드, 다이얼로그)
templates/   # 페이지 템플릿
```

### 3. 디자인 토큰 버전 관리
```dart
class DesignSystemVersion {
  static const String version = '1.0.0';
  static const Map<String, dynamic> changelog = {
    '1.0.0': 'Initial design system',
  };
}
```

## 🔗 연관 파일 및 의존성

### 현재 사용처 (20+ 파일)
- `features/posts/`: 투표 카드, 피드 UI
- `features/chat/`: 채팅 UI, 메시지 컴포넌트
- `features/notifications/`: 알림 다이얼로그
- `features/profile/`: 프로필 페이지
- `features/search/`: 검색 바

### 의존 관계
- Material Design → Design System
- Google Fonts → Typography System
- Features → Design Tokens
- Shared Widgets → Design Tokens

## ⚡ 성능 고려사항

1. **트리 쉐이킹**: 사용하지 않는 컴포넌트 제거
2. **동적 테마**: Theme Extension으로 런타임 변경
3. **폰트 최적화**: 필요한 글리프만 로드

## 🚨 주의사항

1. **Breaking Changes**: 토큰 시스템 변경 시 전체 앱 영향
2. **Feature 독립성**: Core에서 UI 로직 제거 필수
3. **버전 호환성**: 점진적 마이그레이션 필요

## 📋 체크리스트

### 즉시 수정 필요
- [ ] Theme Extension으로 토큰 전환
- [ ] 컴포넌트 shared로 이동
- [ ] Material 3 통합

### 단기 목표 (1주일)
- [ ] 컴포넌트 분할 (대형 파일)
- [ ] 테스트 작성
- [ ] 문서화 개선

### 장기 목표 (1개월)
- [ ] 완전한 테마 시스템
- [ ] Storybook 스타일 컴포넌트 갤러리
- [ ] 접근성 완벽 지원

---

*이 문서는 Core Design System 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*일관된 디자인 언어와 효율적인 개발을 위한 핵심 인프라입니다.*