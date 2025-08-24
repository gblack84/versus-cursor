# 🆚 VSMark - Versus Space 브랜드 마크

## 📋 개요

Versus Space 앱의 브랜드 마크(VS 로고)를 표시하는 컴포넌트입니다. 두 개의 이미지를 겹쳐서 VS 효과를 표현하는 레거시 위젯입니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`VsmarkWidget`, `VsmarkModel`)
- **라우트명**: 라우트 미설정 (컴포넌트 위젯)
- 참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
vsmark/
├── vsmark_widget.dart    # VS 마크 UI
└── vsmark_model.dart     # 상태 관리
```

## 📱 기능

### 주요 컴포넌트
- **이미지 스택**: 두 이미지 겹침 효과
- **중앙 정렬**: VS 마크 중앙 배치
- **고정 크기**: 200x100 픽셀

### UI 구성
```dart
Stack(
  children: [
    // 첫 번째 이미지 (좌측)
    Align(
      alignment: AlignmentDirectional(-1.2, 0.0),
      child: Image.asset('...')
    ),
    // 두 번째 이미지 (우측)
    Align(
      alignment: AlignmentDirectional(1.2, 0.0),
      child: Image.asset('...')
    ),
  ]
)
```

## 💻 코드 분석

### VsmarkWidget
- 두 개의 이미지 에셋 사용
- Stack으로 겹침 효과
- 고정된 크기와 위치
- phoneloginpincode에서 참조됨

### 이미지 에셋
- `20250402_1112_____remix_01jqt4bfgvebj8s1j9b2ywjy5z.png`
- 동일 이미지 두 개 사용
- BorderRadius 8.0 적용

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 크기**: 200x100 고정
2. **하드코딩된 위치**: -1.2, 1.2 고정
3. **중복 이미지**: 동일 이미지 두 번 사용
4. **긴 파일명**: 자동 생성된 이미지 이름

## 🔄 대체 구현

### 프로덕션 로고
```dart
// 실제 브랜드 로고
/assets/images/logo/       # 브랜드 로고 에셋
/lib/components/brand/     # 브랜드 컴포넌트
```

## 📊 통계

- **위젯 파일**: 약 100줄
- **모델 파일**: 약 20줄
- **상태**: 🟡 부분 사용 (phoneloginpincode에서 참조)
- **의존성**: 이미지 에셋

## ⚠️ 주의사항

> **경고**: phoneloginpincode에서 직접 참조됩니다.
> 제거 시 의존성 확인 필요.

### 권장 사항
- ✅ SVG 로고 사용
- ✅ 동적 크기 지원
- ✅ 디자인 시스템 통합

## 🗑️ 제거 계획

- **Phase 1**: phoneloginpincode 의존성 제거 필요 ⚠️
- **Phase 2**: 브랜드 로고 통합
- **Phase 3**: 다음 정리 작업 시 제거 예정 📅

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 디렉토리는 레거시 테스트 코드를 포함하고 있으며, 향후 제거될 예정입니다.*
