# Versus Space Design System

Versus Space 앱의 통합 디자인 시스템입니다. 일관된 UI/UX를 위해 토큰 기반 디자인 시스템을 구축했습니다.

## 📋 개요

이 디자인 시스템은 2025-07-25에 도입되어 앱 전반의 시각적 일관성과 개발 효율성을 향상시킵니다. 기존 AppTheme과 호환되면서도 더 체계적인 디자인 토큰과 컴포넌트를 제공합니다.

## 📁 구조

```
design_system/
├── tokens/               # 디자인 토큰 (색상, 간격, 글꼴 등)
│   ├── versus_colors.dart      # 색상 시스템
│   ├── versus_spacing.dart     # 간격 시스템 (4px 기반)
│   ├── versus_text_styles.dart # 타이포그래피
│   ├── versus_radius.dart      # 모서리 둥글기
│   ├── versus_icons.dart       # 아이콘 세트
│   └── versus_tokens.dart      # 모든 토큰 export
├── components/           # 재사용 가능한 UI 컴포넌트
│   ├── versus_button.dart      # 표준 버튼 컴포넌트
│   ├── versus_dialog.dart      # 다이얼로그 컴포넌트
│   ├── versus_text_field.dart  # 입력 필드 컴포넌트
│   └── versus_icon.dart        # 아이콘 래퍼
├── utils/               # 유틸리티
│   └── icon_style_manager.dart # 아이콘 스타일 관리
└── design_system.dart   # 메인 export 파일
```

## 🎨 디자인 토큰

### 1. 색상 시스템 (VersusColors)

```dart
import 'package:versus_space/design_system/tokens/versus_tokens.dart';

// 브랜드 색상
VersusColors.primary        // #D95B5B - 빨간색 (주요 CTA)
VersusColors.secondary      // #588157 - 초록색 (보조 액션)

// 배경 색상
VersusColors.backgroundPrimary    // #FAF9F6 - 메인 배경
VersusColors.backgroundSecondary  // #F5F2E8 - 카드/섹션 배경

// 텍스트 색상
VersusColors.textPrimary    // #4A444B - 주요 텍스트
VersusColors.textSecondary  // #8A817C - 보조 텍스트

// UI 요소 색상
VersusColors.borderColor    // 검은색 테두리
VersusColors.borderLight    // #E0E3E7 - 연한 테두리

// 상태 색상
VersusColors.success        // #249689 - 성공
VersusColors.warning        // #F9CF58 - 경고
VersusColors.error          // #FF5963 - 에러
VersusColors.info           // #4B39EF - 정보

// 투명도 적용
VersusColors.primaryWithAlpha(0.5)  // 50% 투명도
```

### 2. 간격 시스템 (VersusSpacing)

4px 기반의 일관된 간격 시스템:

```dart
// 기본 간격 값
VersusSpacing.xs   // 4px
VersusSpacing.sm   // 8px
VersusSpacing.md   // 16px
VersusSpacing.lg   // 24px
VersusSpacing.xl   // 32px
VersusSpacing.xxl  // 48px

// 특수 간격
VersusSpacing.screenHorizontal  // EdgeInsets.symmetric(horizontal: 20)
VersusSpacing.screenVertical    // EdgeInsets.symmetric(vertical: 16)
VersusSpacing.cardInternal      // EdgeInsets.all(16)
VersusSpacing.buttonInternal    // EdgeInsets.symmetric(h: 16, v: 8)

// 커스텀 간격
VersusSpacing.fromSTEB(20, 2, 20, 0)  // 기존 코드 호환

// 유틸리티 위젯
VersusSpacing.gapH(16)  // 가로 간격
VersusSpacing.gapV(16)  // 세로 간격
```

### 3. 타이포그래피 (VersusTextStyles)

Plus Jakarta Sans 폰트 기반:

```dart
// Display 스타일 (큰 제목)
VersusTextStyles.displayLarge   // 57px
VersusTextStyles.displayMedium  // 45px
VersusTextStyles.displaySmall   // 36px

// Heading 스타일
VersusTextStyles.headingLarge   // 32px, bold
VersusTextStyles.headingMedium  // 24px, bold
VersusTextStyles.headingSmall   // 18px, bold

// Body 스타일
VersusTextStyles.bodyLarge      // 16px
VersusTextStyles.bodyMedium     // 14px
VersusTextStyles.bodySmall      // 12px

// Label 스타일
VersusTextStyles.labelLarge     // 14px, medium
VersusTextStyles.labelMedium    // 12px, medium
VersusTextStyles.labelSmall     // 11px, medium

// 버튼 스타일
VersusTextStyles.buttonLarge    // 16px, medium
VersusTextStyles.buttonMedium   // 14px, medium
VersusTextStyles.buttonSmall    // 12px, medium
```

### 4. 모서리 둥글기 (VersusRadius)

```dart
VersusRadius.radiusNone     // 0px
VersusRadius.radiusSmall    // 8px
VersusRadius.radiusMedium   // 16px
VersusRadius.radiusLarge    // 24px
VersusRadius.radiusXLarge   // 32px
VersusRadius.radiusCircle   // 9999px (원형)
```

### 5. 아이콘 (VersusIcons)

```dart
// 네비게이션
VersusIcons.home
VersusIcons.search
VersusIcons.chat
VersusIcons.profile

// 액션
VersusIcons.add
VersusIcons.edit
VersusIcons.delete
VersusIcons.share

// 상태
VersusIcons.success
VersusIcons.warning
VersusIcons.error
VersusIcons.info
```

## 🧩 컴포넌트

### 1. VersusButton

표준화된 버튼 컴포넌트:

```dart
// Primary 버튼 (주요 액션)
VersusButton.primary(
  text: '투표하기',
  onPressed: () => handleVote(),
  isFullWidth: true,
)

// Secondary 버튼 (보조 액션)
VersusButton.secondary(
  text: '공유',
  icon: Icon(VersusIcons.share),
  onPressed: () => sharePost(),
)

// Outline 버튼 (테두리)
VersusButton.outline(
  text: '취소',
  onPressed: () => Navigator.pop(context),
  size: VersusButtonSize.small,
)

// Text 버튼 (배경 없음)
VersusButton.text(
  text: '더 보기',
  onPressed: () => showMore(),
)

// Error 버튼 (위험한 액션)
VersusButton.error(
  text: '삭제',
  icon: Icon(VersusIcons.delete),
  onPressed: () => deletePost(),
  isLoading: isDeleting,
)
```

버튼 크기:
- `VersusButtonSize.small` - 작은 버튼
- `VersusButtonSize.medium` - 중간 버튼 (기본)
- `VersusButtonSize.large` - 큰 버튼

### 2. VersusDialog

일관된 다이얼로그 스타일:

```dart
// 경고 다이얼로그
VersusDialog.warning(
  context: context,
  title: '주의',
  content: '이 작업은 되돌릴 수 없습니다.',
  actions: [
    VersusButton.outline(text: '취소'),
    VersusButton.error(text: '삭제'),
  ],
);

// 확인 다이얼로그
VersusDialog.confirm(
  context: context,
  title: '로그아웃',
  content: '정말 로그아웃하시겠습니까?',
  onConfirm: () => logout(),
);

// 정보 다이얼로그
VersusDialog.info(
  context: context,
  title: '업데이트 완료',
  content: '프로필이 성공적으로 업데이트되었습니다.',
);
```

### 3. VersusTextField

표준 입력 필드:

```dart
VersusTextField(
  label: '이메일',
  hint: 'example@email.com',
  controller: emailController,
  validator: (value) => validateEmail(value),
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icon(VersusIcons.email),
)
```

### 4. VersusIcon

아이콘 래퍼 컴포넌트:

```dart
VersusIcon(
  VersusIcons.heart,
  size: VersusIconSize.medium,
  color: VersusColors.primary,
)
```

## 🚀 사용 가이드

### 1. Import

```dart
// 전체 디자인 시스템
import 'package:versus_space/design_system/design_system.dart';

// 토큰만 import
import 'package:versus_space/design_system/tokens/versus_tokens.dart';

// 특정 컴포넌트만 import
import 'package:versus_space/design_system/components/versus_button.dart';
```

### 2. 마이그레이션 예시

```dart
// Before (기존 코드)
Container(
  padding: EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 16.0),
  decoration: BoxDecoration(
    color: Color(0xFFFAF9F6),
    borderRadius: BorderRadius.circular(16.0),
    border: Border.all(color: Colors.black),
  ),
  child: Text(
    'Hello World',
    style: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
)

// After (디자인 시스템 적용)
Container(
  padding: VersusSpacing.cardInternal,
  decoration: BoxDecoration(
    color: VersusColors.backgroundPrimary,
    borderRadius: VersusRadius.radiusMedium,
    border: Border.all(color: VersusColors.borderColor),
  ),
  child: Text(
    'Hello World',
    style: VersusTextStyles.bodyMedium,
  ),
)
```

### 3. 베스트 프랙티스

1. **일관성 유지**: 항상 디자인 토큰 사용
2. **하드코딩 금지**: 색상, 간격, 폰트 크기 직접 입력 지양
3. **컴포넌트 우선**: 가능한 경우 표준 컴포넌트 사용
4. **점진적 마이그레이션**: 새 기능부터 디자인 시스템 적용

## 📐 기존 코드와의 호환성

### AppTheme과의 관계
- 디자인 시스템은 AppTheme을 보완하며, 함께 사용 가능
- 새로운 기능은 디자인 시스템 우선 사용
- 기존 코드는 점진적으로 마이그레이션

### FlutterFlow 마이그레이션
- FlutterFlow에서 네이티브 Flutter로 전환 후 도입
- 기존 스타일 패턴을 분석하여 토큰화
- STEB 패턴 등 기존 코드와 호환

## 🎯 장점

1. **일관성**: 모든 UI 요소가 동일한 디자인 언어 사용
2. **유지보수성**: 중앙 집중식 스타일 관리
3. **개발 속도**: 재사용 가능한 컴포넌트로 빠른 개발
4. **확장성**: 새로운 토큰과 컴포넌트 쉽게 추가
5. **다크 모드 준비**: 색상 토큰으로 테마 전환 용이

## 🔮 향후 계획

1. **추가 컴포넌트**
   - VersusCard - 카드 컴포넌트
   - VersusChip - 칩/태그 컴포넌트
   - VersusAvatar - 아바타 컴포넌트
   - VersusBottomSheet - 바텀시트 컴포넌트

2. **테마 시스템**
   - 다크 모드 지원
   - 사용자 정의 테마
   - 동적 테마 전환

3. **애니메이션**
   - 표준 전환 애니메이션
   - 마이크로 인터랙션

4. **접근성**
   - 시맨틱 레이블
   - 고대비 모드
   - 큰 글꼴 지원