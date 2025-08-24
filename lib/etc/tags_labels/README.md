# 🏷️ Tags_Labels - 태그/라벨 UI 테스트

## 📋 개요

태그와 라벨 UI 컴포넌트를 테스트하기 위한 페이지입니다. 칩(Chip) 컴포넌트와 태그 스타일링을 실험한 레거시 코드입니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`TagsLabelsWidget`, `TagsLabelsModel`)
- **라우트명**: 라우트 미설정 (미사용 페이지)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
tags_labels/
├── tags_labels_widget.dart    # 태그/라벨 UI
└── tags_labels_model.dart     # 상태 관리
```

## 📱 기능

### 주요 컴포넌트
- **태그 칩**: 선택 가능한 태그
- **라벨 표시**: 카테고리 라벨
- **색상 변형**: 다양한 색상 테스트
- **애니메이션**: 페이드 인 효과

### UI 요소
- Chip 위젯 활용
- 태그 추가/삭제 기능
- 선택 상태 토글
- 동적 색상 변경

## 💻 코드 분석

### TagsLabelsWidget
```dart
// 애니메이션 설정
AnimationInfo(
  trigger: AnimationTrigger.onPageLoad,
  effectsBuilder: () => [
    VisibilityEffect(duration: 200.ms),
    FadeEffect(
      delay: 200.0.ms,
      duration: 400.0.ms,
    ),
  ],
)
```

### 애니메이션 시스템
- TickerProviderStateMixin 사용
- 페이지 로드 시 페이드 인
- 200ms 지연 후 400ms 애니메이션

## 🚫 문제점

### 코드 품질 이슈
1. **미완성 기능**: 태그 관리 로직 부재
2. **하드코딩된 애니메이션**: 재사용 불가능
3. **상태 관리 미흡**: 태그 선택 상태 미구현

## 🔄 대체 구현

### 프로덕션 태그
```dart
// 관심사 태그 시스템
/lib/createaccount/interests/    # 관심사 선택
/lib/components/tags/            # 재사용 태그 컴포넌트
```

## 📊 통계

- **위젯 파일**: 약 150줄
- **모델 파일**: 약 30줄
- **상태**: 🔴 미사용 (레거시)
- **애니메이션**: flutter_animate 사용

## ⚠️ 주의사항

> **경고**: UI 실험용 코드입니다.
> 프로덕션에서 사용하지 마세요.

### 권장 사항
- ✅ Material Chip 위젯 사용
- ✅ 디자인 시스템 태그 컴포넌트
- ✅ 상태 관리 구현

## 🗑️ 제거 계획

- **Phase 1**: 의존성 확인 ✅
- **Phase 2**: 프로덕션 영향 없음 확인 ✅
- **Phase 3**: 다음 정리 작업 시 제거 예정 📅

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 디렉토리는 레거시 테스트 코드를 포함하고 있으며, 향후 제거될 예정입니다.*
