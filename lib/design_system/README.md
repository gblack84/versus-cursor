# Versus Space Design System

Versus Space 앱을 위한 통합 디자인 시스템입니다. 일관된 UI/UX를 위해 기존 코드 패턴을 분석하여 표준화했습니다.

## 📁 구조

```
design_system/
├── tokens/           # 디자인 토큰 (색상, 간격, 글꼴 등)
├── components/       # 재사용 가능한 UI 컴포넌트
└── README.md        # 문서
```

## 🎨 디자인 토큰

### VersusColors
```dart
import 'package:versus_space/design_system/tokens/versus_tokens.dart';

Container(
  color: VersusColors.primary,        // 브랜드 빨간색
  border: Border.all(color: VersusColors.borderColor), // 검은 테두리
)
```

### VersusSpacing
```dart
Container(
  padding: VersusSpacing.paddingMD,   // 16px 패딩
  margin: VersusSpacing.screenHorizontal, // 좌우 20px 마진
)
```

### VersusRadius
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: VersusRadius.radiusMedium, // 16px 둥근 모서리
  ),
)
```

### VersusTextStyles
```dart
Text(
  'Hello World',
  style: VersusTextStyles.headingMedium, // Plus Jakarta Sans 24px 굵게
)
```

## 🧩 컴포넌트

### VersusDialog (계획됨)
```dart
VersusDialog.warning(
  context: context,
  title: '경고',
  content: '내용을 확인해주세요.',
);
```

### VersusButton (계획됨)
```dart
VersusButton.outline(
  text: '취소',
  onPressed: () => Navigator.pop(context),
)
```

## 🚀 사용법

1. **토큰 import**
```dart
import 'package:versus_space/design_system/tokens/versus_tokens.dart';
```

2. **기존 하드코딩된 값 대체**
```dart
// Before (기존)
Padding(
  padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0),
  child: Text('Hello', style: GoogleFonts.plusJakartaSans(fontSize: 14)),
)

// After (디자인 시스템 적용)
Padding(
  padding: VersusSpacing.fromSTEB(20.0, 2.0, 20.0, 0.0),
  child: Text('Hello', style: VersusTextStyles.bodyMedium),
)
```

## 📐 기존 코드와의 호환성

- **기존 AppTheme**: 계속 사용 가능
- **기존 스타일**: 점진적으로 교체
- **새로운 기능**: 디자인 시스템 우선 사용

## 🎯 장점

1. **일관성**: 모든 UI 요소가 동일한 스타일
2. **유지보수성**: 한 곳에서 스타일 변경
3. **개발 속도**: 표준 컴포넌트 재사용
4. **확장성**: 새로운 컴포넌트 쉽게 추가