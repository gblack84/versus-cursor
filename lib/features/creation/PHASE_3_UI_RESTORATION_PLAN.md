# Phase 3: Creation Feature UI 픽셀 단위 100% 복원 계획

> **목표**: August 22, 2025 UI를 픽셀 단위로 100% 동일하게 복제 (A/B 박스 로직 포함)
> **기간**: 2025-11-15 (분석 완료) → 2025-11-18 (구현 완료, 3일)
> **작성**: Claude Code Pixel-Perfect Analysis + A/B Box Logic Analysis + Moderation API Investigation
> **최종 업데이트**: 2025-11-15 (v5.0 - 5개 신규 이슈 추가 #15-19)
> **총 소요 시간**: 6-9시간 (검증 포함)
> **문서 크기**: ~6,200줄 (v4.0 대비 11% 증가, v3.0 대비 30% 증가)

---

## 📋 목차

1. [Executive Summary](#-executive-summary)
2. [픽셀 단위 비교표](#-픽셀-단위-비교표)
3. [Critical Issues Summary](#-critical-issues-summary)
4. [Phase 1: Text Input 픽셀 복원](#phase-1-text-input-픽셀-복원-2-3시간)
5. [Phase 2: Layout 순서 복원](#phase-2-layout-순서-복원-30분)
6. [Phase 3: Image Section 픽셀 복원 + A/B 박스 로직](#phase-3-image-section-픽셀-복원--ab-박스-로직-15시간)
7. [Phase 4: FieldStyles 검증/수정](#phase-4-fieldstyles-검증수정-1시간)
8. [Phase 5: Validation & Testing](#phase-5-validation--testing-1-2시간)
9. [Riverpod으로 8월 22일 동작 복원하기](#-riverpod으로-8월-22일-동작-복원하기)
10. [100% 동일 검증 체크리스트](#-100-동일-검증-체크리스트)
11. [구현 가이드 & 일정](#-구현-가이드--일정)
12. [참조 자료](#-참조-자료)

---

## 📋 Executive Summary

### 분석 결과 Overview

**비교 대상**:
- **August 22, 2025** (commit d3fcd80a) - 완전 작동 UI
- **Current** (2025-11-15) - Feature-First 마이그레이션 후 UI

**총 차이점 발견**: **54개 시각적/기능적 불일치** (v4.0 대비 +5개 신규 이슈 #15-19)

**심각도 분류**:
- 🔴 **CRITICAL**: 11개 (v4.0 대비 +4개: Issue #15, #16, #17, #18 - 즉시 수정 필요)
- 🟡 **HIGH**: 6개 (v4.0 대비 +1개: Issue #19 - 조만간 수정)
- 🟢 **LOW/INFO**: 37개 (스타일 미세 조정)

### 핵심 발견 사항

#### ✅ **Box Sizing System - WORKING PERFECTLY**

```
상태: 완벽 작동 (Clean Architecture DI 패턴)
위치: /core/utils/ui/box_sizing/
파일: unified_box_calculator.dart (555줄)
      aspect_ratio_analyzer.dart (130줄)
통합: media_selection_notifier.dart:443
패턴: IBoxCalculatorService (Domain) → GetIt DI → Notifier
기능: ✅ 이미지 aspect ratio 기반 자동 박스 크기 계산
      ✅ 자동 레이아웃 결정 (horizontal/vertical/single)
      ✅ Unified height 계산 (A/B 평균)
```

**증거 코드** (media_selection_notifier.dart:414-483):
```dart
void updateLayout({
  required double containerWidth,
  required bool absellected,
}) {
  // ✅ 1. Aspect ratio 계산
  double? ratioA = RatioCalculator.getRatio(state.aspectRatiosA, box: 'A');

  // ✅ 2. 자동 레이아웃 결정
  final layoutType = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);

  // ✅ 3. Clean Architecture DI로 박스 크기 계산
  final boxCalculatorService = getIt<IBoxCalculatorService>();
  final data = boxCalculatorService.calculateForQuestion(
    containerWidth: containerWidth,
    layoutType: layoutType,
    aspectRatioA: ratioA,
    aspectRatioB: ratioB,
  );

  // ✅ 4. 자동 바인딩
  state = state.copyWith(
    currentLayout: layoutType,
    boxWidthA: data.sizeA.width,
    boxHeightA: data.sizeA.height,
    boxWidthB: data.sizeB.width,
    boxHeightB: data.sizeB.height,
  );
}
```

**결론**: 이미지 크기 기반 자동 계산 + 바인딩 ✅ 정상 작동 (사용자 우려사항 해결)

#### ⚠️ **Text Sizing System - NOT USED (정상)**

```
상태: 유틸리티 존재하나 사용 안 됨
위치: /core/utils/text_sizing/
파일: adaptive_text_size.dart (231줄)
      calculators/text_size_calculator.dart (180줄)
통합: NONE - Creation feature 어디에도 사용 안 됨
역사: August 22 코드에서도 사용 안 했음 (git 검증 완료)
      October 3, 2025에 추가됨 (August 22보다 2개월 후)
결론: 복원 불필요 (원래 안 썼던 기능)
```

**타임라인 증거**:
- **August 1, 2025**: Description 필드 구현 (static fontSize: 20.0)
- **August 22, 2025**: UI 정상 작동 (여전히 static)
- **October 3, 2025**: 텍스트 사이징 유틸리티 **최초 도입** (commit 4b3c9eb9)

**Gap**: 2개월 → August 22에는 존재하지 않았음

#### ❌ **Critical Regressions - 17개 즉시 수정 필요** (v4.0 대비 +5개 신규 이슈 #15-19)

1. **CharacterCountDisplay Widget 완전 누락** (P0 - BLOCKER)
   - 위치: 4개 필드 모두 (Title, Description, TextA, TextB)
   - 영향: 사용자가 글자 수 제한 및 검증 에러를 볼 수 없음

2. **Option A/B 필드가 잘못된 컴포넌트 사용** (P0 - BLOCKER)
   - 현재: Custom TextFormField (하드코딩된 스타일)
   - 올바름: SimpleValidatedField + FieldStyles.textA/textB
   - 영향: 스타일 불일치, FieldConfig 무시

3. **필드 순서 바뀜** (P0 - BLOCKER)
   - August 22: Title → **Image** → Description → Options
   - Current: Title → **Description** → Image → Options
   - 영향: 사용자 워크플로우 파괴

4. **Box Colors 하드코딩** (P1 - CRITICAL)
   - August 22: `AppTheme.primary` / `AppTheme.secondary` (동적)
   - Current: `Color(0x1A2196F3)` / `Color(0x1AF44336)` (고정)
   - 영향: 테마 변경 시 색상 변경 안 됨

5. **Option Fields Border Style** (P1 - CRITICAL)
   - August 22: `underline`, `Colors.black`, width 2.0
   - Current: `outline`, `Theme.dividerColor`, width 1.0
   - 영향: 시각적 일관성 파괴

6. **Image Section Label 추가됨** (P2 - HIGH)
   - Current: `"A vs B 이미지 선택"` 라벨 존재
   - August 22: 라벨 없음
   - 영향: 불필요한 시각적 요소

7. **Border Radius 불일치** (P2 - HIGH)
   - August 22: 12.0 (Options)
   - Current: 8.0 (Options)

8. **Max Lines 감소** (P2 - HIGH)
   - August 22: 5 lines (Options)
   - Current: 2 lines (Options)
   - 영향: 텍스트 잘림 가능성

9. **Container Width 제약 누락** (P2 - HIGH)
   - August 22: 400.0 width constraint (Options)
   - Current: No width constraint
   - 영향: 레이아웃 너비 일관성 파괴

10. **🆕 Plus 아이콘 표시 조건 반대** (P0 - BLOCKER)
    - August 22: `showPlusIcon: isAbsellected` (B박스 숨김 시 Plus 표시)
    - Current: `showPlusIcon: !widget.absellected` (반대!)
    - 영향: B박스 토글 기능이 반대로 동작

11. **🆕 단일 이미지 모드 레이아웃 누락** (P0 - BLOCKER)
    - August 22: `if (isAbsellected) { Center(...) }` 중앙 정렬 레이아웃
    - Current: 단일 이미지 모드 전용 레이아웃 없음
    - 영향: A박스만 있을 때 중앙 정렬 안 됨 (왼쪽 정렬)

12. **🆕 다음 버튼이 Moderation 결과를 무시함** (P2 - MAJOR)
    - August 22: Perspective API 검증 결과를 canSubmit에서 확인
    - Current: `canSubmit`이 `formData.isValid`만 확인 (Moderation 무시)
    - 영향: 부적절한 콘텐츠가 제출 가능

13. **🆕 필드 순서 바뀜 - Screen Level** (P0 - BLOCKER) [Issue #15]
    - August 22: Title → **Image** → Description → Options A/B
    - Current: Title → Description → Options A/B → **Image** (또는 통합 TextInputWidget)
    - 영향: 사용자 워크플로우 파괴, August 22와 완전히 다른 레이아웃
    - 수정 필요: `create_post_screen.dart` Column 구조 재정렬

14. **🆕 Option A/B 컴포넌트 잘못 사용** (P0 - BLOCKER) [Issue #16]
    - August 22: `SimpleValidatedField` 사용 (FieldStyles.textA/textB 통합)
    - Current: Custom `TextFormField` 사용 (하드코딩된 스타일)
    - 영향: FieldConfig 무시, 스타일 불일치, 검증 시스템 미통합
    - 수정 필요: `text_input_widget.dart` 내 `_buildOptionTextField()` 삭제 → SimpleValidatedField로 교체

15. **🆕 CharacterCountDisplay 4개 필드 모두 누락** (P0 - BLOCKER) [Issue #17]
    - August 22: Title, Description, Option A, Option B 모두 CharacterCountDisplay 표시
    - Current: CharacterCountDisplay 완전 누락 (4개 필드 모두)
    - 영향: 사용자가 글자 수 제한을 알 수 없음, 검증 에러 시각적 피드백 없음
    - 수정 필요: `text_input_widget.dart` 내 4개 필드 모두 CharacterCountDisplay 추가

16. **🆕 Image Section 불필요한 요소** (P1 - CRITICAL) [Issue #18]
    - August 22: Label 없음, Container padding 없음 (깔끔한 레이아웃)
    - Current: "A vs B 이미지 선택" Label 추가됨, Container padding 16px 추가됨
    - 영향: 불필요한 시각적 요소, padding 과다
    - 수정 필요: `image_selection_widget.dart` lines 77-84 (Label) 삭제, line 73 (padding) 제거

17. **🆕 Box Colors 하드코딩 - AppColors 사용** (P2 - MEDIUM) [Issue #19]
    - August 22: `AppTheme.of(context).primary/secondary` (동적 테마)
    - Current: `AppColors.boxABackground`/`boxBBackground` (하드코딩된 고정 색상)
    - 영향: 다크 모드 전환 시 Box 색상이 변경되지 않음
    - 수정 필요: `image_selection_widget.dart` line 166 → AppTheme 동적 테마로 변경

---

## 🎯 픽셀 단위 비교표

### 1️⃣ Text Input Section

#### 1.1 Question Title Field

| Property | August 22 (d3fcd80a) | Current | Difference | Impact |
|----------|---------------------|---------|------------|--------|
| **Font Size** | `30.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Label Size** | `30.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Max Length** | `60` (override to `100`) | `60` (override to `100`) | ✅ MATCH | ✅ OK |
| **Max Lines** | `3` | ❓ Unknown | **MISSING DATA** | 🟡 MEDIUM |
| **Min Lines** | `1` | ❓ Unknown | **MISSING DATA** | 🟡 MEDIUM |
| **Border Type** | `underline` | `underline` | ✅ MATCH | ✅ OK |
| **Border Width** | `2.0` | `2.0` | ✅ MATCH | ✅ OK |
| **Border Color** | `Colors.black` | `Colors.black` | ✅ MATCH | ✅ OK |
| **Border Radius** | `12.0` | `12.0` | ✅ MATCH | ✅ OK |
| **Content Padding** | `horizontal: 12.0, vertical: 12.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Field Padding** | `EdgeInsets.zero` | ❓ Unknown | **MISSING DATA** | 🟡 MEDIUM |
| **Container Padding** | `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)` | `horizontal: 16` | 🔴 **-6px horizontal** | 🔴 HIGH |
| **Text Input Action** | `TextInputAction.done` | ❓ Unknown | **MISSING DATA** | 🟢 LOW |
| **Show Character Count** | `true` | ✅ `true` | ✅ MATCH | ✅ OK |
| **Show Clear Button** | `true` | ✅ `true` | ✅ MATCH | ✅ OK |

#### 1.2 Description Field

| Property | August 22 | Current | Difference | Impact |
|----------|-----------|---------|------------|--------|
| **Font Size** | `20.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Label Size** | `25.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Max Length** | `200` (override to `2000`) | `200` (override to `2000`) | ✅ MATCH | ✅ OK |
| **Max Lines** | `null` (unlimited) | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Min Lines** | `1` | ❓ Unknown | **MISSING DATA** | 🟡 MEDIUM |
| **Border Type** | `underline` | `underline` | ✅ MATCH | ✅ OK |
| **Border Width** | `2.0` | `2.0` | ✅ MATCH | ✅ OK |
| **Content Padding** | `horizontal: 12.0, vertical: 12.0` | ❓ Unknown | **MISSING DATA** | 🔴 HIGH |
| **Container Padding** | `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)` | `horizontal: 16` | 🔴 **-6px horizontal** | 🔴 HIGH |
| **Text Input Action** | `TextInputAction.newline` | ❓ Unknown | **MISSING DATA** | 🟡 MEDIUM |

#### 1.3 Option A/B Title Fields (⚠️ 가장 많은 차이)

| Property | August 22 | Current | Difference | Impact |
|----------|-----------|---------|------------|--------|
| **Component** | `SimpleValidatedField` | ❌ `TextFormField` | 🔴 **WRONG COMPONENT** | 🔴 **CRITICAL** |
| **FieldStyles Usage** | ✅ `FieldStyles.textA/textB` | ❌ **NOT USING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Font Size** | `15.0` | ❓ **Unknown** | 🔴 **CUSTOM IMPL** | 🔴 **CRITICAL** |
| **Label Size** | `20.0` | ❓ **Unknown** | 🔴 **CUSTOM IMPL** | 🔴 **CRITICAL** |
| **Max Length** | `20` | ❌ **No maxLength** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Max Lines** | `5` | `2` | 🔴 **-3 lines** | 🔴 HIGH |
| **Border Type** | `underline` | `outline` | 🔴 **DIFFERENT** | 🔴 **CRITICAL** |
| **Border Width** | `2.0` | `1.0` (default) | 🔴 **-1px** | 🔴 HIGH |
| **Border Color** | `Colors.black` | `Theme.dividerColor` | 🔴 **DIFFERENT** | 🔴 **CRITICAL** |
| **Border Radius** | `12.0` | `8.0` | 🔴 **-4px** | 🔴 HIGH |
| **Content Padding** | `horizontal: 12.0, vertical: 12.0` | `horizontal: 12, vertical: 12` | ✅ MATCH | ✅ OK |
| **Container Padding** | `EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)` | `horizontal: 16` | 🔴 **-4px horizontal** | 🔴 HIGH |
| **Container Width** | `400.0` | ❌ **No width constraint** | 🔴 **MISSING** | 🔴 HIGH |
| **Alignment** | `AlignmentDirectional(-1.0, 0.0)` | ❌ **MISSING** | 🔴 **MISSING** | 🟡 MEDIUM |
| **isDense** | `true` | ❓ **Unknown** | **MISSING DATA** | 🟡 MEDIUM |

### 2️⃣ Validation Display

#### 2.1 Character Count Display

| Property | August 22 | Current | Status | Impact |
|----------|-----------|---------|--------|--------|
| **Component** | `CharacterCountDisplay` widget | ❌ **NOT VISIBLE** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Position** | Below each field | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Horizontal Padding (Title)** | `22.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Horizontal Padding (Description)** | `22.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Horizontal Padding (Option A)** | `32.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Horizontal Padding (Option B)** | `32.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Format** | `{current}/{max}` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Font Size** | `12.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Color (Normal)** | `AppTheme.secondaryText` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Color (Error)** | `AppTheme.error` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Position Layout** | `Row(spaceBetween)` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |

#### 2.2 Error Messages

| Property | August 22 | Current | Status | Impact |
|----------|-----------|---------|--------|--------|
| **Empty Message** | `"필수 항목입니다"` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Toxic Message** | `"독성 콘텐츠가 감지되었습니다"` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Blocked Message** | `"⚠️ 부적절한 언어가 포함됨"` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 **CRITICAL** |
| **Font Size** | `12.0` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Font Weight** | `FontWeight.w500` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Text Overflow** | `TextOverflow.ellipsis` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |
| **Max Lines** | `1` | ❌ **MISSING** | 🔴 **MISSING** | 🔴 HIGH |

### 3️⃣ Image Selection Section

#### 3.1 Container & Padding

| Property | August 22 | Current | Difference | Impact |
|----------|-----------|---------|------------|--------|
| **Container Horizontal Padding** | ❌ **NONE** | `16` | 🔴 **+16px added** | 🔴 **CRITICAL** |
| **Section Label** | ❌ **NONE** | ✅ `"A vs B 이미지 선택"` | 🔴 **ADDED** | 🔴 **CRITICAL** |
| **Label Padding** | ❌ **N/A** | `EdgeInsets.only(bottom: 8)` | 🔴 **ADDED** | 🔴 **CRITICAL** |
| **Label Style** | ❌ **N/A** | `Theme.titleMedium` | 🔴 **ADDED** | 🔴 **CRITICAL** |

#### 3.2 Box Visual Properties

| Property | August 22 | Current | Difference | Impact |
|----------|-----------|---------|------------|--------|
| **Box A Color** | `AppTheme.of(context).primary` | `Color(0x1A2196F3)` (Blue 10%) | 🔴 **DIFFERENT** | 🔴 **CRITICAL** |
| **Box B Color** | `AppTheme.of(context).secondary` | `Color(0x1AF44336)` (Red 10%) | 🔴 **DIFFERENT** | 🔴 **CRITICAL** |
| **Box Width Calculation** | `UnifiedBoxCalculator` | ✅ **SAME LOGIC** | ✅ MATCH | ✅ OK |
| **Box Height Calculation** | `UnifiedBoxCalculator` | ✅ **SAME LOGIC** | ✅ MATCH | ✅ OK |
| **Box Spacing (Horizontal)** | `SizedBox(width: Dimensions.smallPadding * 2)` | `SizedBox(width: 8)` | ❓ **NEED VERIFICATION** | 🔴 HIGH |
| **Box Spacing (Vertical)** | `SizedBox(height: Dimensions.smallPadding)` | `SizedBox(height: 8)` | ❓ **NEED VERIFICATION** | 🔴 HIGH |

### 4️⃣ Layout & Spacing

#### 4.1 Field Order

| Position | August 22 | Current | Match |
|----------|-----------|---------|-------|
| **1** | Question Title | Question Title | ✅ MATCH |
| **2** | **Image Section** | Description | 🔴 **SWAPPED** |
| **3** | Description | **Image Section** | 🔴 **SWAPPED** |
| **4** | Option A | Option A | ✅ MATCH |
| **5** | Option B | Option B | ✅ MATCH |

#### 4.2 Vertical Spacing

| Element | August 22 | Current | Difference | Impact |
|---------|-----------|---------|------------|--------|
| **Title → Next Element** | Direct (no SizedBox) | ❓ **Unknown** | **NEED CHECK** | 🟡 MEDIUM |
| **Image → Next Element** | Direct (padding based) | ❓ **Unknown** | **NEED CHECK** | 🟡 MEDIUM |
| **Title → Description** | ❌ **N/A** | `16.0` | **NEW LAYOUT** | 🔴 **CRITICAL** |
| **Description → Options** | ❌ **N/A** | `16.0` | **NEW LAYOUT** | 🔴 **CRITICAL** |
| **Option A → Option B** | ❌ **N/A** | `16.0` | **NEW LAYOUT** | 🔴 **CRITICAL** |

### 5️⃣ Color Palette

#### 5.1 Text Colors

| Element | August 22 | Current | Status |
|---------|-----------|---------|--------|
| **Primary Text** | `AppTheme.of(context).bodyMedium` | ✅ Same | ✅ MATCH |
| **Label Text** | `GoogleFonts.plusJakartaSans()` | ✅ Same | ✅ MATCH |
| **Hint Text** | `AppTheme.of(context).labelMedium` | ✅ Same | ✅ MATCH |
| **Error Text** | `AppTheme.of(context).error` | ✅ Same | ✅ MATCH |
| **Character Count** | `AppTheme.of(context).secondaryText` | ❌ **MISSING** | 🔴 **MISSING** |

#### 5.2 Background Colors

| Element | August 22 | Current | Difference | Impact |
|---------|-----------|---------|------------|--------|
| **TextField Background** | `AppTheme.secondaryBackground` | ✅ Same | ✅ MATCH | ✅ OK |
| **Box A Background** | `AppTheme.primary` (dynamic) | `Color(0x1A2196F3)` (static) | 🔴 **HARDCODED** | 🔴 **CRITICAL** |
| **Box B Background** | `AppTheme.secondary` (dynamic) | `Color(0x1AF44336)` (static) | 🔴 **HARDCODED** | 🔴 **CRITICAL** |
| **Warning Background** | ❌ **NOT IN OLD** | `Color(0x1AFF9800)` | **NEW FEATURE** | ℹ️ INFO |
| **Debug Background** | ❌ **NOT IN OLD** | `Color(0x1A9E9E9E)` | **NEW FEATURE** | ℹ️ INFO |

#### 5.3 Border Colors

| Element | August 22 | Current (Title/Desc) | Current (Options) | Status |
|---------|-----------|---------------------|-------------------|--------|
| **TextField Border** | `Colors.black` (all) | ✅ `Colors.black` | 🔴 `Theme.dividerColor` | 🔴 **DIFFERENT** |
| **Focused Border** | `Colors.black` (all) | ✅ `Colors.black` | 🔴 `Theme.primaryColor` | 🔴 **DIFFERENT** |
| **Error Border** | `Colors.black` (all) | ✅ `Colors.black` | 🔴 `Colors.red` | 🔴 **DIFFERENT** |

### 🆕 9️⃣ A/B 박스 상태 관리 및 토글 로직

#### 9.1 absellected 파라미터 개념

| 항목 | August 22 (5dd372e4) | Current | Difference | Impact |
|------|---------------------|---------|------------|--------|
| **파라미터 의미** | "A-B Single-Selected" = 단일 이미지 모드 | ✅ Same | ✅ MATCH | ✅ OK |
| **true 의미** | B박스 숨김 (A박스만 표시) | ✅ Same | ✅ MATCH | ✅ OK |
| **false 의미** | B박스 표시 (A/B 듀얼 박스) | ✅ Same | ✅ MATCH | ✅ OK |
| **상태 관리 방식** | `_model.absellected` (setState 내부 관리) | `widget.absellected` (부모 prop, Riverpod) | 🟡 **DIFFERENT** | ⚠️ **구조 차이** |

#### 9.2 Plus 아이콘 로직

| 항목 | August 22 | Current | Difference | Impact |
|------|-----------|---------|------------|--------|
| **표시 조건** | `showPlusIcon: isAbsellected` | `showPlusIcon: !widget.absellected` | 🔴 **반대!** | 🔴 **BLOCKER** |
| **표시 위치** | A박스 위에만 | ✅ Same | ✅ MATCH | ✅ OK |
| **클릭 동작** | `callbacks.toggleBoxVisibility()` → `absellected = false` | `mediaSelectionProvider.notifier.toggleBoxBVisibility()` | 🟡 **DIFFERENT** | ⚠️ **구현 차이** |
| **결과** | B박스 표시 + Plus 아이콘 숨김 | ✅ Same (동작은 동일) | ✅ MATCH | ✅ OK |

#### 9.3 B박스 자동 숨김 로직

| 항목 | August 22 | Current | Status | Impact |
|------|-----------|---------|--------|--------|
| **트리거 조건** | `if (tempImageFilesB.isEmpty) { absellected = true; }` | ❓ **UNKNOWN** | 🔴 **NEED VERIFY** | 🔴 **CRITICAL** |
| **실행 위치** | `_deleteFromB()` 메서드 | ❓ **UNKNOWN** | 🔴 **NEED VERIFY** | 🔴 **CRITICAL** |
| **자동 전환** | B박스 이미지 모두 삭제 시 자동 숨김 | ❓ **UNKNOWN** | 🔴 **NEED VERIFY** | 🔴 **CRITICAL** |

#### 9.4 단일 이미지 모드 레이아웃

| 항목 | August 22 | Current | Difference | Impact |
|------|-----------|---------|------------|--------|
| **전용 레이아웃** | `if (isAbsellected) { Center(...) }` | ❌ **NONE** | 🔴 **MISSING** | 🔴 **BLOCKER** |
| **정렬 방식** | `Center(child: SizedBox(width: boxSizeA.width, ...))` | Row의 Expanded (왼쪽 정렬) | 🔴 **DIFFERENT** | 🔴 **CRITICAL** |
| **Padding** | `EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0)` | Row의 padding 없음 | 🔴 **DIFFERENT** | 🔴 **HIGH** |
| **적용 조건** | `isAbsellected && isRatioVertical` | ❌ **NONE** | 🔴 **MISSING** | 🔴 **CRITICAL** |

#### 9.5 박스 간 상호작용 플로우

| 단계 | August 22 동작 | Current | Status |
|------|---------------|---------|--------|
| **초기 상태** | A박스/B박스 모두 빈 상태, `absellected = false` | ✅ Same | ✅ OK |
| **A박스 이미지 추가** | `absellected = true` (자동 전환) → B박스 숨김, Plus 표시 | ❓ Unknown | 🔴 **NEED VERIFY** |
| **Plus 클릭** | `absellected = false` → B박스 다시 표시, Plus 숨김 | ✅ Same (showPlusIcon 조건 반대지만) | 🟡 **WORKS** |
| **B박스 이미지 추가** | `absellected = false` 유지 → Plus 숨김 유지 | ✅ Same | ✅ OK |
| **B박스 이미지 모두 삭제** | `absellected = true` (자동 복귀) → B박스 숨김, Plus 표시 | ❓ Unknown | 🔴 **NEED VERIFY** |

---

## 🚨 Critical Issues Summary

### 🔴 CRITICAL (Breaks UX - Must Fix Immediately)

#### Issue #1: CharacterCountDisplay Widget 완전 누락 (P0 - BLOCKER)

**Impact**: 사용자가 글자 수 제한 및 실시간 검증 에러를 볼 수 없음

**Location**: 4개 필드 모두 (Title, Description, TextA, TextB)

**Evidence**:
```dart
// August 22: CharacterCountDisplay 존재 (4곳)
CharacterCountDisplay(
  controller: _titleController,
  maxLength: 60,
  isEmpty: state.formData.title.trim().isEmpty,
  hasBlockedWord: false,
  validationResult: state.validationResults[FieldStyles.questionTitle],
  horizontalPadding: 22.0,  // Title/Description
  hasValidated: state.hasValidated,
),

CharacterCountDisplay(
  controller: _textAController,
  maxLength: 20,
  isEmpty: state.formData.textA.trim().isEmpty,
  hasBlockedWord: false,
  validationResult: state.validationResults[FieldStyles.textA],
  horizontalPadding: 32.0,  // Options
  hasValidated: state.hasValidated,
),

// Current: ❌ COMPLETELY MISSING
```

**Fix**: Phase 1에서 4개 필드에 모두 추가

---

#### Issue #2: Option A/B 필드가 잘못된 컴포넌트 사용 (P0 - BLOCKER)

**Impact**: FieldStyles 무시, 스타일 불일치, 유지보수성 파괴

**Current Implementation**:
```dart
// ❌ WRONG: Custom TextFormField (lines 206-274)
Widget _buildOptionTextField({
  required String label,
  required TextEditingController controller,
  required FocusNode focusNode,
  String? errorText,
  String? hintText,
  required Function(String) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 8),
      TextFormField(  // ❌ WRONG COMPONENT
        controller: controller,
        focusNode: focusNode,
        maxLines: 2,  // ❌ Should be 5
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: errorText,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(  // ❌ Should be underline
            borderRadius: BorderRadius.circular(8),  // ❌ Should be 12
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,  // ❌ Should be black
            ),
          ),
          // ... more hardcoded styles
        ),
      ),
    ],
  );
}
```

**Expected Implementation**:
```dart
// ✅ CORRECT: SimpleValidatedField with FieldStyles
Align(
  alignment: AlignmentDirectional(-1.0, 0.0),
  child: Padding(
    padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0),
    child: Container(
      width: 400.0,
      child: SimpleValidatedField(  // ✅ CORRECT COMPONENT
        controller: _textAController,
        focusNode: _textAFocus,
        labelKey: 'textA_label',
        hintKey: 'textA_hint',
        fieldName: FieldStyles.textA,  // ✅ FieldConfig
        validationResult: state.validationResults[FieldStyles.textA],
        onFieldChanged: (value, fieldName, isBlocked) {
          ref.read(createPostProvider.notifier).updateTextA(value);
          widget.onTextAChanged?.call(value);
        },
        onFieldCleared: () {
          ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.textA);
          widget.onTextAChanged?.call('');
        },
      ),
    ),
  ),
),
```

**Fix**: Phase 1에서 SimpleValidatedField로 교체 (150줄 수정)

---

#### Issue #3: 필드 순서 바뀜 (P0 - BLOCKER)

**Impact**: 사용자 워크플로우 파괴

**August 22 Order**:
```
1. Question Title
2. Image Section  ← 여기
3. Description
4. Option A
5. Option B
```

**Current Order**:
```
1. Question Title
2. Description  ← 잘못된 위치
3. Image Section  ← 잘못된 위치
4. Option A
5. Option B
```

**Fix**: Phase 2에서 순서 변경 (30분)

---

#### Issue #4: Box Colors 하드코딩 (P1 - CRITICAL)

**Impact**: 테마 변경 시 색상 변경 안 됨, 동적 테마 지원 파괴

**August 22** (동적 테마 사용):
```dart
boxColor: box == 'A'
    ? AppTheme.of(context).primary    // 동적
    : AppTheme.of(context).secondary  // 동적
```

**Current** (하드코딩):
```dart
boxColor: box == 'A'
    ? AppColors.boxABackground  // Color(0x1A2196F3) - 고정
    : AppColors.boxBBackground  // Color(0x1AF44336) - 고정
```

**Fix**: Phase 3에서 AppTheme.primary/secondary로 변경

---

#### Issue #6: Option Fields Border Style (P1 - CRITICAL)

**Impact**: 시각적 일관성 파괴

**Comparison**:

| Property | August 22 | Current | Difference |
|----------|-----------|---------|------------|
| **Border Type** | `underline` | `outline` | 🔴 DIFFERENT |
| **Border Color** | `Colors.black` | `Theme.dividerColor` | 🔴 DIFFERENT |
| **Border Width** | `2.0` | `1.0` | 🔴 -1px |
| **Border Radius** | `12.0` | `8.0` | 🔴 -4px |

**Fix**: Phase 1에서 SimpleValidatedField 사용으로 자동 해결

---

### 🟡 HIGH (Visual Regression - Fix Soon)

#### Issue #7: Image Section Label 추가됨 (P2 - HIGH)

**Impact**: 불필요한 시각적 요소

**Current** (lines 77-84):
```dart
Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    'A vs B 이미지 선택',  // ❌ 추가된 라벨
    style: Theme.of(context).textTheme.titleMedium,
  ),
),
```

**August 22**: 라벨 없음

**Fix**: Phase 3에서 전체 Container 삭제

---

#### Issue #8: Border Radius 불일치 (P2 - HIGH)

**August 22**: `12.0` (all fields)
**Current**: `8.0` (Option fields only)

**Fix**: Phase 1에서 SimpleValidatedField 사용으로 자동 해결

---

#### Issue #9: Max Lines 감소 (P2 - HIGH)

**Impact**: 텍스트 잘림 가능성

**August 22**: `5 lines` (Option fields)
**Current**: `2 lines` (Option fields)

**Fix**: Phase 4에서 FieldStyles.textA/textB 설정 수정

---

#### Issue #10: Container Width 제약 누락 (P2 - HIGH)

**Impact**: 레이아웃 너비 일관성 파괴

**August 22**:
```dart
Container(
  width: 400.0,  // ✅ Width constraint
  child: SimpleValidatedField(...),
)
```

**Current**: No width constraint

**Fix**: Phase 1에서 Container width 추가

---

### 🆕 A/B 박스 로직 Critical Issues

#### Issue #11: Plus 아이콘 표시 조건 반대 (P0 - BLOCKER)

**Impact**: B박스 토글 기능이 반대로 동작

**August 22** (line 1252):
```dart
final aBoxWidget = _buildMediaSelectionBox(
  box: 'A',
  showPlusIcon: isAbsellected,  // ✅ B박스 숨김 시 Plus 표시
  // ...
);
```

**Current** (image_selection_widget.dart:178):
```dart
showPlusIcon: box == 'A' && !widget.absellected,  // ❌ 반대!
```

**Fix**:
```dart
// ✅ CORRECT
showPlusIcon: box == 'A' && widget.absellected,
```

**Phase**: Phase 3에서 수정 (1줄)

---

#### Issue #12: 단일 이미지 모드 레이아웃 누락 (P0 - BLOCKER)

**Impact**: A박스만 있을 때 중앙 정렬 안 됨 (왼쪽 정렬됨)

**August 22** (lines 1230-1255):
```dart
Widget _buildMediaLayoutContent(...) {
  if (_model.isRatioVertical) {  // 가로 배치
    if (isAbsellected) {
      // ✅ 단일 이미지 모드: A박스만 중앙 정렬
      return Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          Dimensions.smallPadding * 2, 0.0,
          Dimensions.smallPadding * 2, 0.0
        ),
        child: Center(  // 중앙 정렬!
          child: SizedBox(
            width: boxSizeA.width,
            height: boxSizeA.height,
            child: aBoxWidget,
          ),
        ),
      );
    } else {
      // ✅ 듀얼 박스 모드: A/B 가로 배치
      return Padding(...child: Row(...));
    }
  }
  // ...
}
```

**Current** (image_selection_widget.dart:97-139):
```dart
Widget _buildMediaBoxes(...) {
  final isHorizontal = mediaSelectionState.currentLayout == LayoutType.horizontal;

  if (isHorizontal) {
    // ❌ 단일 이미지 모드 분기 없음!
    return Row(
      children: [
        Expanded(child: _buildMediaBox(box: 'A', ...)),
        if (!widget.absellected) ...[
          const SizedBox(width: 8),
          Expanded(child: _buildMediaBox(box: 'B', ...)),
        ],
      ],
    );
  }
  // ...
}
```

**Fix**:
```dart
Widget _buildMediaBoxes(...) {
  final isHorizontal = mediaSelectionState.currentLayout == LayoutType.horizontal;

  // ✅ 단일 이미지 모드 분기 추가
  if (widget.absellected && isHorizontal) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        post_dimensions.MediaDimensions.boxSpacingHorizontal,
        0.0,
        post_dimensions.MediaDimensions.boxSpacingHorizontal,
        0.0
      ),
      child: Center(  // 중앙 정렬
        child: SizedBox(
          width: mediaSelectionState.boxWidthA,
          height: mediaSelectionState.boxHeightA,
          child: _buildMediaBox(box: 'A', ...),
        ),
      ),
    );
  }

  // 기존 Row/Column 로직...
}
```

**Phase**: Phase 3에서 추가 (~20줄)

---

#### Issue #13: B박스 자동 숨김 로직 검증 필요 (P1 - CRITICAL)

**Impact**: B박스 이미지 모두 삭제 시 자동으로 숨겨지지 않을 가능성

**August 22** (lines 1470-1480):
```dart
void _deleteFromB(int index) {
  setState(() {
    appState.uploadImageB = [];
    appState.tempImageFilesB = [];

    // ✅ B박스 비었으면 자동 숨김
    if (appState.tempImageFilesB.isEmpty && appState.uploadImageB.isEmpty) {
      model.absellected = true;
    }
  });
}
```

**Current** (MediaSelectionNotifier):
```dart
void removeAtIndex({required String box, required int index}) {
  // ... 삭제 로직 ...

  // ❓ B박스 비었을 때 absellected = true 설정하는가?
  // NEED VERIFICATION
}
```

**Fix**: MediaSelectionNotifier에서 B박스 자동 숨김 로직 추가
```dart
void removeAtIndex({required String box, required int index}) {
  if (box == 'A') {
    final updated = List<File>.from(state.selectedFilesA);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesA: updated);
  } else {
    final updated = List<File>.from(state.selectedFilesB);
    updated.removeAt(index);
    state = state.copyWith(
      selectedFilesB: updated,
      // ✅ B박스 비었으면 자동 숨김
      absellected: updated.isEmpty ? true : state.absellected,
    );
  }
}
```

**Phase**: Phase 3에서 검증 및 추가

---

#### Issue #14: 다음 버튼이 Moderation 결과를 무시함 (P2 - MAJOR)

**Impact**: Perspective API 검증 결과와 관계없이 다음 버튼이 활성화되어 부적절한 콘텐츠 제출 가능

**Current Implementation** (create_post_screen.dart:258-290):
```dart
if (_showNextButton)  // ① 스크롤 >50px
  Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      child: NextButton(
        showButton: createPostState.canSubmit,  // ② Form validation
        onPressed: createPostState.canSubmit && !_isValidating  // ③ 최종 조건
            ? _handleSubmit
            : null,
      ),
    ),
  ),
```

**canSubmit Definition** (create_post_state.dart:45-50):
```dart
bool get canSubmit {
  return formData.isValid && !isLoading;  // ⚠️ Moderation 결과 무시!
}

bool get isValid {
  return title.isNotEmpty &&
      description.isNotEmpty &&
      (textA.isNotEmpty || imagesA.isNotEmpty) &&
      (isSingleMode || textB.isNotEmpty || imagesB.isNotEmpty);
}
```

**Problem Analysis**:
1. **canSubmit은 formData.isValid만 확인** - 필드 비었는지만 체크
2. **validationResults 무시** - Perspective API 독성 검증 결과 안 봄
3. **사용자가 독성 콘텐츠 제출 가능** - 에러 표시만 되고 차단 안 됨

**Expected Behavior**:
```dart
bool get canSubmit {
  // ✅ 1. 필드 비어있지 않은지 확인
  if (!formData.isValid || isLoading) return false;

  // ✅ 2. Moderation 결과 확인
  final titleResult = validationResults[FieldStyles.questionTitle];
  final descResult = validationResults[FieldStyles.description];
  final textAResult = validationResults[FieldStyles.textA];
  final textBResult = validationResults[FieldStyles.textB];

  // ✅ 3. 독성 콘텐츠가 있으면 차단
  if (titleResult?.isToxic == true) return false;
  if (descResult?.isToxic == true) return false;
  if (textAResult?.isToxic == true) return false;
  if (!formData.isSingleMode && textBResult?.isToxic == true) return false;

  return true;
}
```

**Validation Flow** (현재 정상 작동):
```
User Input → 500ms Debounce → CreatePostNotifier.validateTitle()
  → Perspective API Call → state.validationResults[fieldName] = result
  → UI Rebuild → ValidatedTextField shows error below field ✅
  → BUT: Next button still enabled ❌
```

**Fix**: Phase 2에서 canSubmit getter 수정 (~15줄)

**Note**: Perspective API 에러는 TextField 아래에 **이미 표시되고 있음** (August 22부터 현재까지 정상 작동). 문제는 에러가 있어도 다음 버튼이 활성화된다는 점.

---

#### Issue #15: Screen Field 순서 반대 (P0 - BLOCKER)

**August 22** (정상):
```dart
// create_post_screen.dart (Lines 198-253)
Column(
  children: [
    _buildTitleField(),         // 1. 제목
    SizedBox(height: 24),
    ImageSelectionWidget(...),  // 2. 이미지 ⬅️ 먼저!
    SizedBox(height: 24),
    _buildDescriptionField(),   // 3. 설명
    SizedBox(height: 24),
    _buildOptionsFields(),      // 4. 옵션 A/B
  ],
)
```

**Current** (틀림):
```dart
// create_post_screen.dart (Lines 198-253)
Column(
  children: [
    TextInputWidget(              // 1. 제목 + 설명 + 옵션 (통합됨)
      onTitleChanged: ...,
      onDescriptionChanged: ...,
      onTextAChanged: ...,
      onTextBChanged: ...,
    ),
    SizedBox(height: 24),
    ImageSelectionWidget(...),    // 2. 이미지 ⬅️ 나중!
  ],
)
```

**Impact**:
- 사용자가 이미지 선택 **전에** 설명을 입력해야 함 (비직관적)
- August 22: Title → **Image 선택** → Description 작성 (자연스러운 흐름)
- Current: Title → **Description 작성** → Image 선택 (역순)

**Fix**:
```dart
// create_post_screen.dart - Column 재구성
Column(
  children: [
    // 1. Title만 분리
    InputFieldBuilder.buildTitleField(
      context: context,
      controller: _titleController,
      focusNode: _titleFocus,
      onFieldChanged: ...,
      validationResult: state.validationResults[FieldStyles.questionTitle],
    ),
    CharacterCountDisplay(
      currentLength: _titleController.text.length,
      maxLength: FieldStyles.maxLengthTitle,
      validationResult: state.validationResults[FieldStyles.questionTitle],
    ),

    SizedBox(height: 24),

    // 2. Image Selection (MOVED UP)
    ImageSelectionWidget(
      absellected: _absellected,
      isDynamic: true,
      validationSessionId: _validationSessionId,
      onImagesSelected: ...,
    ),

    SizedBox(height: 24),

    // 3. Description (MOVED DOWN)
    InputFieldBuilder.buildDescriptionField(
      context: context,
      controller: _descriptionController,
      focusNode: _descriptionFocus,
      onFieldChanged: ...,
      validationResult: state.validationResults[FieldStyles.description],
    ),
    CharacterCountDisplay(
      currentLength: _descriptionController.text.length,
      maxLength: FieldStyles.maxLengthDescription,
      validationResult: state.validationResults[FieldStyles.description],
    ),

    SizedBox(height: 24),

    // 4. Options A/B
    _buildOptionField(box: 'A'),
    SizedBox(height: 16),
    if (!_absellected) _buildOptionField(box: 'B'),
  ],
)
```

**Verification**:
- [ ] Field 순서: Title → Image → Description → Options
- [ ] 각 필드 간격: 24px (SizedBox)
- [ ] CharacterCountDisplay 4개 모두 표시

**Fix Location**: Phase 2 Step 2.5

---

#### Issue #16: Component 잘못 사용 (P0 - BLOCKER)

**August 22** (정상):
```dart
// text_input_widget.dart - Options A/B는 SimpleValidatedField 사용
InputFieldBuilder.buildSimpleValidatedField(
  context: context,
  fieldName: FieldStyles.optionA,
  labelText: 'A 옵션 텍스트',
  hintText: 'A 옵션에 대한 설명을 입력하세요',
  controller: _textAController,
  focusNode: _textAFocus,
  maxLines: 2,
  maxLength: FieldStyles.maxLengthTextA,
  validationResult: state.validationResults[FieldStyles.optionA],
  onFieldChanged: (value, fieldName, isBlocked) {
    ref.read(createPostProvider.notifier).updateTextA(value);
    widget.onTextAChanged?.call(value);
  },
  onFieldCleared: () {
    ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.optionA);
    widget.onTextAChanged?.call('');
  },
)
```

**Current** (틀림):
```dart
// text_input_widget.dart (Lines 206-274)
Widget _buildOptionTextField({
  required String label,
  required TextEditingController controller,
  required FocusNode focusNode,
  String? errorText,
  String? hintText,
  required Function(String) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(              // ❌ 커스텀 TextFormField 사용
        controller: controller,
        focusNode: focusNode,
        maxLines: 2,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          errorText: errorText,   // ❌ errorText는 항상 null
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          // ... 수동 decoration 구현
        ),
      ),
      // ❌ CharacterCountDisplay 없음
      // ❌ FieldStyles 통합 없음
      // ❌ ValidationResult 미사용
    ],
  );
}
```

**Impact**:
- FieldStyles 시스템 미적용 (maxLength, validation)
- Perspective API validation 결과 표시 불가능
- 문자 수 표시 없음 (사용자가 제한 확인 불가)
- 일관성 없는 UI (Title/Description은 InputFieldBuilder, Options는 커스텀)

**Fix**:
```dart
// text_input_widget.dart (Lines 119-140 교체)
Widget _buildOptionField(String box) {
  final state = ref.watch(createPostProvider);
  final fieldName = box == 'A' ? FieldStyles.optionA : FieldStyles.optionB;
  final controller = box == 'A' ? _textAController : _textBController;
  final focusNode = box == 'A' ? _textAFocus : _textBFocus;

  return InputFieldBuilder.buildSimpleValidatedField(
    context: context,
    fieldName: fieldName,
    labelText: '$box 옵션 텍스트',
    hintText: '$box 옵션에 대한 설명을 입력하세요',
    controller: controller,
    focusNode: focusNode,
    maxLines: 2,
    maxLength: box == 'A' ? FieldStyles.maxLengthTextA : FieldStyles.maxLengthTextB,
    validationResult: state.validationResults[fieldName],
    onFieldChanged: (value, fieldName, isBlocked) {
      if (box == 'A') {
        ref.read(createPostProvider.notifier).updateTextA(value);
        widget.onTextAChanged?.call(value);
      } else {
        ref.read(createPostProvider.notifier).updateTextB(value);
        widget.onTextBChanged?.call(value);
      }
    },
    onFieldCleared: () {
      ref.read(createPostProvider.notifier).clearValidationResult(fieldName);
      if (box == 'A') {
        widget.onTextAChanged?.call('');
      } else {
        widget.onTextBChanged?.call('');
      }
    },
  );
}
```

**Verification**:
- [ ] Options A/B 모두 InputFieldBuilder.buildSimpleValidatedField 사용
- [ ] FieldStyles 통합 (maxLength, validation)
- [ ] ValidationResult 정상 표시
- [ ] CharacterCountDisplay 자동 포함

**Fix Location**: Phase 1 Step 1.5

---

#### Issue #17: CharacterCountDisplay 누락 (P1 - CRITICAL)

**August 22** (정상):
```dart
// 모든 필드 아래에 CharacterCountDisplay
Column(
  children: [
    InputFieldBuilder.buildTitleField(...),
    CharacterCountDisplay(
      currentLength: _titleController.text.length,
      maxLength: FieldStyles.maxLengthTitle,  // 100자
      validationResult: state.validationResults[FieldStyles.questionTitle],
    ),
  ],
)
```

**Current** (틀림):
- CharacterCountDisplay **4개 모두 없음**
- 사용자가 글자 수 확인 불가능
- Validation 에러 메시지 표시 불가능

**Impact**:
- 사용자가 제한 글자 수 초과 여부 모름
- Perspective API 독성 감지 결과 확인 불가
- August 22와 UI 불일치

**필요한 곳** (4개):
1. **Title** (100자 제한)
   - Location: text_input_widget.dart Line 174 이후

2. **Description** (500자 제한)
   - Location: text_input_widget.dart Line 203 이후

3. **Option A** (50자 제한)
   - Location: text_input_widget.dart Line 127 이후

4. **Option B** (50자 제한)
   - Location: text_input_widget.dart Line 139 이후 (if showOptionB)

**Fix**:
```dart
// Example: Title Field
Widget _buildTitleField() {
  final state = ref.watch(createPostProvider);

  return Column(
    children: [
      InputFieldBuilder.buildTitleField(
        context: context,
        controller: _titleController,
        focusNode: _titleFocus,
        onFieldChanged: (value, fieldName, isBlocked) {
          ref.read(createPostProvider.notifier).updateTitle(value);
          _titleDebounce?.run(() async {
            await ref.read(createPostProvider.notifier).validateTitle(value);
          });
          widget.onTitleChanged?.call(value);
        },
        onFieldCleared: () {
          ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.questionTitle);
          widget.onTitleChanged?.call('');
        },
        validationResult: state.validationResults[FieldStyles.questionTitle],
      ),
      // ✅ ADD: CharacterCountDisplay
      CharacterCountDisplay(
        currentLength: _titleController.text.length,
        maxLength: FieldStyles.maxLengthTitle,
        validationResult: state.validationResults[FieldStyles.questionTitle],
      ),
    ],
  );
}
```

**Verification**:
- [ ] Title 아래 CharacterCountDisplay (100자)
- [ ] Description 아래 CharacterCountDisplay (500자)
- [ ] Option A 아래 CharacterCountDisplay (50자)
- [ ] Option B 아래 CharacterCountDisplay (50자)
- [ ] Validation 에러 메시지 표시

**Fix Location**: Phase 1 Step 1.6

---

#### Issue #18: Image Widget 불필요 요소 (P1 - CRITICAL)

**August 22** (정상):
```dart
// image_selection_widget.dart - Padding 없음, Label 없음
@override
Widget build(BuildContext context) {
  final createPostState = ref.watch(createPostProvider);
  final mediaSelectionState = ref.watch(mediaSelectionProvider);

  _updateLayoutIfNeeded(mediaSelectionState);

  return Column(
    children: [
      // 디버그 정보만 (릴리즈 모드에서는 제거됨)
      if (kDebugMode) _buildLayoutDebugInfo(mediaSelectionState),

      // 바로 미디어 박스 렌더링
      _buildMediaBoxes(createPostState, mediaSelectionState),

      // 경고 메시지
      if (_shouldShowWarning(createPostState))
        _buildWarningMessage(),
    ],
  );
}
```

**Current** (틀림):
```dart
// image_selection_widget.dart (Lines 70-91)
@override
Widget build(BuildContext context) {
  final createPostState = ref.watch(createPostProvider);
  final mediaSelectionState = ref.watch(mediaSelectionProvider);

  _updateLayoutIfNeeded(mediaSelectionState);

  return Column(
    children: [
      if (kDebugMode) _buildLayoutDebugInfo(mediaSelectionState),

      // ❌ 불필요한 Container + Padding 추가
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),  // Line 73
        child: Column(
          children: [
            // ❌ 불필요한 Label 추가
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'A vs B 이미지 선택',  // Line 81
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            _buildMediaBoxes(createPostState, mediaSelectionState),
          ],
        ),
      ),

      if (_shouldShowWarning(createPostState))
        _buildWarningMessage(),
    ],
  );
}
```

**Impact**:
- 불필요한 horizontal padding 16px → 전체 레이아웃 어긋남
- "A vs B 이미지 선택" 라벨 → August 22에 없음
- 추가 8px bottom padding → 간격 불일치

**Fix**:
```dart
// image_selection_widget.dart (Lines 70-91 교체)
@override
Widget build(BuildContext context) {
  final createPostState = ref.watch(createPostProvider);
  final mediaSelectionState = ref.watch(mediaSelectionProvider);

  _updateLayoutIfNeeded(mediaSelectionState);

  return Column(
    children: [
      // 디버그 정보 (릴리즈 모드에서 제거)
      if (kDebugMode) _buildLayoutDebugInfo(mediaSelectionState),

      // ✅ Padding 제거, Label 제거 - 바로 박스 렌더링
      _buildMediaBoxes(createPostState, mediaSelectionState),

      // 경고 메시지
      if (_shouldShowWarning(createPostState))
        _buildWarningMessage(),
    ],
  );
}
```

**Verification**:
- [ ] Container padding 제거 (Line 73 삭제)
- [ ] "A vs B 이미지 선택" 라벨 제거 (Lines 77-84 삭제)
- [ ] 전체 레이아웃 August 22와 일치

**Fix Location**: Phase 3 Step 3.9

---

#### Issue #19: Box Color 하드코딩 (P2 - MEDIUM)

**August 22** (정상):
```dart
// image_selection_widget.dart (Line 166)
MediaSelectionBoxMulti(
  label: box,
  isSelected: widget.absellected,
  isVideoSelected: mediaSelectionState.isVideoSelectedA,
  isHorizontal: mediaSelectionState.currentLayout == LayoutType.horizontal,
  boxColor: box == 'A'
      ? AppTheme.of(context).primaryColor.withOpacity(0.1)  // ✅ 동적
      : AppTheme.of(context).secondaryColor.withOpacity(0.1),
  // ...
)
```

**Current** (틀림):
```dart
// image_selection_widget.dart (Line 166)
MediaSelectionBoxMulti(
  label: box,
  isSelected: widget.absellected,
  isVideoSelected: mediaSelectionState.isVideoSelectedA,
  isHorizontal: mediaSelectionState.currentLayout == LayoutType.horizontal,
  boxColor: box == 'A'
      ? AppColors.boxABackground          // ❌ 하드코딩 Color(0x1A2196F3)
      : AppColors.boxBBackground,          // ❌ 하드코딩 Color(0x1AFF5722)
  // ...
)
```

**Impact**:
- 테마 변경 시 box color 미반영
- Light/Dark mode 전환 시 색상 고정
- AppTheme 시스템과 불일치

**Fix**:
```dart
// image_selection_widget.dart (Line 166)
MediaSelectionBoxMulti(
  label: box,
  isSelected: widget.absellected,
  isVideoSelected: mediaSelectionState.isVideoSelectedA,
  isHorizontal: mediaSelectionState.currentLayout == LayoutType.horizontal,
  boxColor: box == 'A'
      ? Theme.of(context).primaryColor.withOpacity(0.1)      // ✅ 동적
      : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
  // ...
)
```

**Verification**:
- [ ] A박스: Theme.of(context).primaryColor 사용
- [ ] B박스: Theme.of(context).colorScheme.secondary 사용
- [ ] Light/Dark mode 전환 시 색상 동적 변경

**Fix Location**: Phase 3 Step 3.10

---

## Phase 1: Text Input 픽셀 복원 (Issue #16, #17) (2-3시간)

### 목표

4개 텍스트 필드를 August 22와 픽셀 단위로 100% 동일하게 복원:
- Question Title
- Description
- Option A (textA)
- Option B (textB)

**해결 Issue**:
- ✅ **Issue #16**: Component wrongly used (TextFormField → SimpleValidatedField)
- ✅ **Issue #17**: CharacterCountDisplay missing (4개 필드 모두 추가)

### 수정 파일

`lib/features/creation/presentation/widgets/create_post/text_input_widget.dart`

**수정 라인**: ~150줄

### Step 1.1: CharacterCountDisplay 통합 (4곳) - Issue #17

#### Title Field (Line 113 이후 추가)

**현재** (lines 146-174):
```dart
Widget _buildTitleField() {
  final state = ref.watch(createPostProvider);

  return InputFieldBuilder.buildTitleField(
    context: context,
    controller: _titleController,
    focusNode: _titleFocus,
    onFieldChanged: (value, fieldName, isBlocked) {
      ref.read(createPostProvider.notifier).updateTitle(value);
      _titleDebounce?.run(() async {
        await ref.read(createPostProvider.notifier).validateTitle(value);
      });
      widget.onTitleChanged?.call(value);
    },
    onFieldCleared: () {
      ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.questionTitle);
      widget.onTitleChanged?.call('');
    },
    onRequiredFieldsCheck: () {},
    validationResult: state.validationResults[FieldStyles.questionTitle],
  );
}
```

**변경** (CharacterCountDisplay 추가):
```dart
Widget _buildTitleField() {
  final state = ref.watch(createPostProvider);

  return Column(  // ← Column으로 감싸기
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InputFieldBuilder.buildTitleField(
        context: context,
        controller: _titleController,
        focusNode: _titleFocus,
        onFieldChanged: (value, fieldName, isBlocked) {
          ref.read(createPostProvider.notifier).updateTitle(value);
          _titleDebounce?.run(() async {
            await ref.read(createPostProvider.notifier).validateTitle(value);
          });
          widget.onTitleChanged?.call(value);
        },
        onFieldCleared: () {
          ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.questionTitle);
          widget.onTitleChanged?.call('');
        },
        onRequiredFieldsCheck: () {},
        validationResult: state.validationResults[FieldStyles.questionTitle],
      ),

      // ✅ CharacterCountDisplay 추가
      CharacterCountDisplay(
        controller: _titleController,
        maxLength: 60,  // FieldStyles.questionTitle.maxLength
        isEmpty: state.formData.title.trim().isEmpty,
        hasBlockedWord: false,  // TODO: Track from validation
        validationResult: state.validationResults[FieldStyles.questionTitle],
        horizontalPadding: 22.0,  // ✅ Title/Description = 22.0
        hasValidated: state.hasValidated,
      ),
    ],
  );
}
```

#### Description Field (Line 116 이후 추가)

**변경** (CharacterCountDisplay 추가):
```dart
Widget _buildDescriptionField() {
  final state = ref.watch(createPostProvider);

  return Column(  // ← Column으로 감싸기
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InputFieldBuilder.buildDescriptionField(
        context: context,
        controller: _descriptionController,
        focusNode: _descriptionFocus,
        onFieldChanged: (value, fieldName, isBlocked) {
          ref.read(createPostProvider.notifier).updateDescription(value);
          _descriptionDebounce?.run(() async {
            await ref.read(createPostProvider.notifier).validateDescription(value);
          });
          widget.onDescriptionChanged?.call(value);
        },
        onFieldCleared: () {
          ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.description);
          widget.onDescriptionChanged?.call('');
        },
        onRequiredFieldsCheck: () {},
        validationResult: state.validationResults[FieldStyles.description],
      ),

      // ✅ CharacterCountDisplay 추가
      CharacterCountDisplay(
        controller: _descriptionController,
        maxLength: 200,  // FieldStyles.description.maxLength
        isEmpty: false,  // Description은 optional
        hasBlockedWord: false,
        validationResult: state.validationResults[FieldStyles.description],
        horizontalPadding: 22.0,  // ✅ Title/Description = 22.0
        hasValidated: state.hasValidated,
      ),
    ],
  );
}
```

#### Option A/B Fields (Step 1.2에서 교체 후 추가)

Step 1.2에서 SimpleValidatedField로 교체한 후 CharacterCountDisplay 추가 예정

---

### Step 1.2: Option A/B를 SimpleValidatedField로 교체 (🔴 가장 중요!) - Issue #16

**현재 코드 삭제** (lines 206-274):
```dart
// ❌ DELETE ENTIRE _buildOptionTextField() METHOD
Widget _buildOptionTextField({
  required String label,
  required TextEditingController controller,
  required FocusNode focusNode,
  String? errorText,
  String? hintText,
  required Function(String) onChanged,
}) {
  return Column(...);  // 전체 삭제
}
```

**새 코드 작성** (Option A - lines 119-140 위치):

```dart
// ✅ Option A Field
Widget _buildOptionAField() {
  final state = ref.watch(createPostProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: AlignmentDirectional(-1.0, 0.0),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0),
          child: Container(
            width: 400.0,  // ✅ Width constraint
            child: SimpleValidatedField(  // ✅ CORRECT COMPONENT
              controller: _textAController,
              focusNode: _textAFocus,
              labelKey: 'textA_label',  // TODO: Add to localization
              hintKey: 'textA_hint',    // TODO: Add to localization
              fieldName: FieldStyles.textA,  // ✅ FieldConfig 사용
              validationResult: state.validationResults[FieldStyles.textA],
              onFieldChanged: (value, fieldName, isBlocked) {
                ref.read(createPostProvider.notifier).updateTextA(value);
                widget.onTextAChanged?.call(value);
              },
              onFieldCleared: () {
                ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.textA);
                widget.onTextAChanged?.call('');
              },
              onRequiredFieldsCheck: () {
                // 필수 필드 검증 (필요시)
              },
            ),
          ),
        ),
      ),

      // ✅ CharacterCountDisplay 추가
      CharacterCountDisplay(
        controller: _textAController,
        maxLength: 20,  // FieldStyles.textA.maxLength
        isEmpty: state.formData.textA.trim().isEmpty,
        hasBlockedWord: false,
        validationResult: state.validationResults[FieldStyles.textA],
        horizontalPadding: 32.0,  // ✅ Options = 32.0
        hasValidated: state.hasValidated,
      ),
    ],
  );
}

// ✅ Option B Field
Widget _buildOptionBField() {
  final state = ref.watch(createPostProvider);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: AlignmentDirectional(-1.0, 0.0),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0),
          child: Container(
            width: 400.0,
            child: SimpleValidatedField(
              controller: _textBController,
              focusNode: _textBFocus,
              labelKey: 'textB_label',
              hintKey: 'textB_hint',
              fieldName: FieldStyles.textB,
              validationResult: state.validationResults[FieldStyles.textB],
              onFieldChanged: (value, fieldName, isBlocked) {
                ref.read(createPostProvider.notifier).updateTextB(value);
                widget.onTextBChanged?.call(value);
              },
              onFieldCleared: () {
                ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.textB);
                widget.onTextBChanged?.call('');
              },
              onRequiredFieldsCheck: () {},
            ),
          ),
        ),
      ),

      // ✅ CharacterCountDisplay 추가
      CharacterCountDisplay(
        controller: _textBController,
        maxLength: 20,
        isEmpty: state.formData.textB.trim().isEmpty,
        hasBlockedWord: false,
        validationResult: state.validationResults[FieldStyles.textB],
        horizontalPadding: 32.0,
        hasValidated: state.hasValidated,
      ),
    ],
  );
}
```

**build() 메서드 수정** (lines 119-140):

**Before**:
```dart
// 옵션 텍스트 A
_buildOptionTextField(
  label: 'A 옵션 텍스트',
  controller: _textAController,
  focusNode: _textAFocus,
  errorText: _textAError,
  hintText: 'A 옵션에 대한 설명을 입력하세요',
  onChanged: (text) => ref.read(createPostProvider.notifier).updateTextA(text),
),

// 옵션 텍스트 B
if (widget.showOptionB) ...{
  const SizedBox(height: 16),
  _buildOptionTextField(
    label: 'B 옵션 텍스트',
    controller: _textBController,
    focusNode: _textBFocus,
    errorText: _textBError,
    hintText: 'B 옵션에 대한 설명을 입력하세요',
    onChanged: (text) => ref.read(createPostProvider.notifier).updateTextB(text),
  ),
},
```

**After**:
```dart
// ✅ 옵션 A
_buildOptionAField(),

// ✅ 옵션 B
if (widget.showOptionB) ...{
  const SizedBox(height: 16),
  _buildOptionBField(),
},
```

---

### Step 1.3: Container Padding 수정

**현재 코드** (line 107):
```dart
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),  // ❌ WRONG
    child: Column(...),
  );
}
```

**변경**:
```dart
Widget build(BuildContext context) {
  return Container(
    padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0),  // ✅ CORRECT
    child: Column(...),
  );
}
```

---

### Step 1.4: Import 추가

**파일 상단에 추가**:
```dart
import '../components/character_count_display.dart';  // CharacterCountDisplay
import '/features/creation/presentation/constants/field_styles.dart';  // FieldStyles
```

---

### Phase 1 검증 체크리스트

완료 후 다음 항목 확인:

**Issue #17 검증** (CharacterCountDisplay):
- [ ] CharacterCountDisplay 4개 필드 모두 표시됨
- [ ] Title/Description horizontalPadding = 22.0
- [ ] Option A/B horizontalPadding = 32.0
- [ ] 글자 수 입력 시 CharacterCountDisplay 업데이트됨
- [ ] Validation 에러 시 CharacterCountDisplay에 표시됨

**Issue #16 검증** (SimpleValidatedField):
- [ ] Option A/B가 SimpleValidatedField 사용 (TextFormField 아님)
- [ ] Option A/B width = 400.0
- [ ] Option A/B alignment = AlignmentDirectional(-1.0, 0.0)
- [ ] Option A/B padding = EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)
- [ ] FieldStyles.textA, FieldStyles.textB 사용됨

**전체 검증**:
- [ ] Text Input Section padding = EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)
- [ ] flutter analyze 0 errors, 0 warnings
- [ ] August 22 커밋과 픽셀 단위 100% 일치 확인

---

## Phase 2: Layout 순서 복원 (Issue #15) + Moderation 검증 (45분)

### 목표

필드 순서를 August 22와 동일하게 변경:
- **August 22**: Title → **Image** → Description → Options
- **Current**: Title → **Description** → Image → Options

**해결 Issue**:
- ✅ **Issue #15**: Screen Field order reversed (P0 - BLOCKER)
- ✅ **Issue #14**: canSubmit Moderation bypass (P2 - MAJOR, 기존)

### 수정 파일

**Issue #15**: `lib/features/creation/presentation/screens/create_post/create_post_screen.dart` (Column 구조 수정)

**Issue #14**: `lib/features/creation/presentation/providers/states/create_post_state.dart` (canSubmit getter)

### Step 2.1: 현재 코드 확인 - Issue #15

**현재 순서 확인** (create_post_screen.dart):
```dart
// ❌ WRONG ORDER (Current)
Column(
  children: [
    TextInputWidget(  // 1. Title, Description, Options (모두 포함)
      onTitleChanged: ...,
      onDescriptionChanged: ...,
      onTextAChanged: ...,
      onTextBChanged: ...,
    ),
    SizedBox(height: 24),
    ImageSelectionWidget(  // 2. Image Section (마지막)
      onImagesSelected: ...,
    ),
  ],
)
```

### Step 2.2: 순서 변경 - Issue #15 핵심

**변경 후**:
```dart
// ✅ CORRECT ORDER
Column(
  children: [
    // 1. Title (TextInputWidget에서 _buildTitleField()만)
    TextInputWidget(
      onTitleChanged: ...,
      // Description/Options는 아래로 이동
    ),

    // 2. Image Section
    ImageSelectionWidget(
      onImagesSelected: ...,
    ),

    // 3. Description + Options (TextInputWidget에서 나머지)
    // ... (구현 방법은 위젯 구조에 따라 다름)
  ],
)
```

**Option A**: TextInputWidget을 2개로 분리
```dart
Column(
  children: [
    TextInputWidget.titleOnly(  // 새 생성자
      onTitleChanged: ...,
    ),

    ImageSelectionWidget(...),

    TextInputWidget.descriptionAndOptions(  // 새 생성자
      onDescriptionChanged: ...,
      onTextAChanged: ...,
      onTextBChanged: ...,
    ),
  ],
)
```

**Option B**: build() 메서드 내에서 분리 (추천)
```dart
// text_input_widget.dart의 build() 메서드를 3개로 분리
Widget build(BuildContext context) {
  if (widget.sectionType == TextInputSection.title) {
    return _buildTitleSection();
  } else if (widget.sectionType == TextInputSection.descriptionAndOptions) {
    return _buildDescriptionAndOptionsSection();
  }
  // ... 기존 로직
}
```

**Option C**: Parent에서 직접 제어 (가장 간단)
```dart
Column(
  children: [
    _buildTitleField(),  // Parent에서 직접 호출
    const SizedBox(height: 16),

    ImageSelectionWidget(...),
    const SizedBox(height: 16),

    _buildDescriptionField(),
    const SizedBox(height: 16),

    _buildOptionAField(),
    if (showOptionB) ...[
      const SizedBox(height: 16),
      _buildOptionBField(),
    ],
  ],
)
```

### Step 2.3: Vertical Spacing 조정

**August 22 Spacing** (padding 기반, SizedBox 없음):
- Title → Image: Direct (no SizedBox)
- Image → Description: Direct (padding based)
- Description → Options: Direct (padding based)
- Option A → Option B: Direct (padding based)

**Current Spacing** (SizedBox 16.0 everywhere):
```dart
const SizedBox(height: 16),  // 모든 곳에 16.0
```

**변경 후** (August 22 스타일):
```dart
// NO SizedBox between sections
// Spacing is controlled by Container padding
```

### Step 2.4: canSubmit Getter 수정 (Issue #14 - P2 MAJOR)

**문제**: 다음 버튼이 Perspective API 검증 결과를 무시하고 활성화됨

**영향**: 부적절한 콘텐츠(욕설, 혐오 발언)가 제출 가능

**수정 파일**: `lib/features/creation/presentation/providers/states/create_post_state.dart`

**현재 코드** (lines 45-50):
```dart
bool get canSubmit {
  return formData.isValid && !isLoading;  // ⚠️ Moderation 결과 무시!
}
```

**변경 후** (15줄 추가):
```dart
bool get canSubmit {
  // ✅ 1. 필드 비어있지 않은지 확인
  if (!formData.isValid || isLoading) return false;

  // ✅ 2. Moderation 결과 확인
  final titleResult = validationResults[FieldStyles.questionTitle];
  final descResult = validationResults[FieldStyles.description];
  final textAResult = validationResults[FieldStyles.textA];
  final textBResult = validationResults[FieldStyles.textB];

  // ✅ 3. 독성 콘텐츠가 있으면 차단
  if (titleResult?.isToxic == true) return false;
  if (descResult?.isToxic == true) return false;
  if (textAResult?.isToxic == true) return false;
  if (!formData.isSingleMode && textBResult?.isToxic == true) return false;

  return true;
}
```

**검증 로직**:
1. `formData.isValid`: 필수 필드 비어있지 않은지 확인
2. `!isLoading`: 제출 중이 아닌지 확인
3. `titleResult?.isToxic`: 제목 독성 검사
4. `descResult?.isToxic`: 설명 독성 검사
5. `textAResult?.isToxic`: Option A 독성 검사
6. `textBResult?.isToxic`: Option B 독성 검사 (단일 모드 제외)

**Edge Cases**:
- `validationResults`가 null인 경우: null 체크로 통과 (검증 전 상태)
- 검증 중인 경우: `isLoading` 체크로 차단
- 단일 모드 (Single Mode): `textBResult` 검사 건너뜀

**Before/After 동작**:
- **Before**: 필드가 채워지면 독성 여부와 관계없이 제출 가능 ❌
- **After**: 필드가 채워지고 독성 검사를 통과해야만 제출 가능 ✅

**Effort**: ~15줄 수정

### Phase 2 검증 체크리스트

**Issue #15 검증** (Screen Field Order):
- [ ] 필드 순서: Title → **Image** → Description → Options (정확한 순서 확인)
- [ ] create_post_screen.dart Column 구조가 올바른 순서로 변경됨
- [ ] TextInputWidget이 3개로 분리되거나 조건부 렌더링 구현됨
- [ ] Title과 Image 사이 Spacing 정확 (SizedBox(height: 24))
- [ ] Image와 Description 사이 Spacing 정확 (SizedBox(height: 24))
- [ ] Description과 Options 사이 Spacing 정확
- [ ] Option A와 Option B 사이 Spacing 정확
- [ ] 시각적으로 August 22 스크린샷과 동일

**Issue #14 검증** (canSubmit Moderation):
- [ ] canSubmit getter가 Moderation 결과를 확인함
  - [ ] `titleResult?.isToxic` 체크
  - [ ] `descResult?.isToxic` 체크
  - [ ] `textAResult?.isToxic` 체크
  - [ ] `textBResult?.isToxic` 체크 (단일 모드 제외)
  - [ ] 독성 콘텐츠 입력 시 다음 버튼 비활성화

**전체 검증**:
- [ ] flutter analyze 0 errors, 0 warnings
- [ ] August 22 커밋과 픽셀 단위 100% 일치 확인

---

## Phase 3: Image Section 픽셀 복원 (Issue #18, #19) + A/B 박스 로직 (1.5시간)

### 목표

Image Selection Section을 August 22와 픽셀 단위로 100% 동일하게 복원:
- Section Label 제거 (Issue #18)
- Container Padding 제거 (Issue #18)
- Box Colors를 동적 테마로 변경 (Issue #19)
- Box Spacing 검증
- **🆕 Plus 아이콘 표시 조건 수정 (Issue #11 - 기존)**
- **🆕 단일 이미지 모드 레이아웃 추가 (Issue #12 - 기존)**
- **🆕 B박스 자동 숨김 로직 검증 및 추가 (Issue #13 - 기존)**

**해결 Issue**:
- ✅ **Issue #18**: Image Widget unnecessary elements (P1 - CRITICAL)
- ✅ **Issue #19**: Box Color hardcoded (P2 - MEDIUM)
- ✅ **Issue #11**: Plus icon condition reversed (P0 - BLOCKER, 기존)
- ✅ **Issue #12**: Center layout missing (P0 - BLOCKER, 기존)
- ✅ **Issue #13**: B Box visibility logic (P1 - CRITICAL, 기존)

### 수정 파일

**Issue #18**: `lib/features/creation/presentation/widgets/create_post/image_selection_widget.dart` (~35줄 수정)

**Issue #19**: `lib/features/creation/presentation/widgets/create_post/image_selection_widget.dart` (1줄 수정)

**Issue #11-13**: `lib/features/creation/presentation/widgets/create_post/image_selection_widget.dart` + `media_selection_notifier.dart`

---

### Step 3.1: Section Label 제거 - Issue #18 (1/2)

**현재 코드 삭제** (lines 77-84):
```dart
// ❌ DELETE ENTIRE LABEL CONTAINER
Container(
  alignment: Alignment.centerLeft,
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(
    'A vs B 이미지 선택',  // ❌ Unnecessary label
    style: Theme.of(context).textTheme.titleMedium,
  ),
),
```

**After**:
```dart
// ✅ NO LABEL - 전체 삭제
```

---

### Step 3.2: Container Padding 제거 - Issue #18 (2/2)

**현재 코드** (line 73):
```dart
return Container(
  padding: const EdgeInsets.symmetric(horizontal: 16),  // ❌ DELETE THIS
  child: Column(...),
);
```

**변경**:
```dart
return Container(
  // NO PADDING - 각 박스가 자체 패딩 처리
  child: Column(...),
);
```

또는 (Container 자체 제거):
```dart
return Column(  // ✅ Container 제거
  children: [
    // 디버그 정보 (kDebugMode)
    if (kDebugMode) _buildLayoutDebugInfo(mediaSelectionState),

    // 메인 미디어 섹션
    _buildMediaSection(createPostState, mediaSelectionState),

    // 경고 메시지
    if (_shouldShowWarning(createPostState))
      _buildWarningMessage(),
  ],
);
```

---

### Step 3.3: Box Colors 수정 - Issue #19

**현재 코드** (line 166):
```dart
boxColor: box == 'A'
    ? AppColors.boxABackground      // ❌ Hardcoded Color(0x1A2196F3)
    : AppColors.boxBBackground,     // ❌ Hardcoded Color(0x1AF44336)
```

**변경**:
```dart
boxColor: box == 'A'
    ? AppTheme.of(context).primary      // ✅ 동적 테마 (다크 모드 지원)
    : AppTheme.of(context).secondary,   // ✅ 동적 테마
```

---

### Step 3.4: Box Spacing 검증 (필요시)

**현재 코드** (lines 109, 130):
```dart
// Horizontal Layout
const SizedBox(width: 8),

// Vertical Layout
const SizedBox(height: 8),
```

**August 22 코드**:
```dart
// Horizontal Layout
SizedBox(width: Dimensions.smallPadding * 2),

// Vertical Layout
SizedBox(height: Dimensions.smallPadding),
```

**검증 필요**:
```bash
# Dimensions.smallPadding 값 확인
git show d3fcd80a:lib/posts/in_put_post_image/constants/dimensions.dart | grep smallPadding
```

**예상 결과**:
- `Dimensions.smallPadding = 4.0`
- `Dimensions.smallPadding * 2 = 8.0` → 현재 코드와 일치 ✅

**만약 다르면**:
```dart
// Example: If smallPadding = 4.0
const double _boxSpacingHorizontal = 8.0;  // smallPadding * 2
const double _boxSpacingVertical = 4.0;    // smallPadding

// Horizontal Layout
SizedBox(width: _boxSpacingHorizontal),

// Vertical Layout
SizedBox(height: _boxSpacingVertical),
```

---

### Step 3.5: _buildMediaSection() 수정

**현재 코드** (lines 70-91):
```dart
Widget _buildMediaSection(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),  // ❌ DELETE
    child: Column(
      children: [
        // ❌ DELETE 라벨
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'A vs B 이미지 선택',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),

        // 미디어 박스들
        _buildMediaBoxes(createPostState, mediaSelectionState),
      ],
    ),
  );
}
```

**변경**:
```dart
Widget _buildMediaSection(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {
  // ✅ NO PADDING, NO LABEL
  return _buildMediaBoxes(createPostState, mediaSelectionState);
}
```

---

### 🆕 Step 3.6: Plus 아이콘 표시 조건 수정 (Issue #11)

**현재 코드** (line 178):
```dart
showPlusIcon: box == 'A' && !widget.absellected,  // ❌ 반대!
```

**변경**:
```dart
showPlusIcon: box == 'A' && widget.absellected,  // ✅ 수정
```

**설명**:
- August 22: `absellected = true` (B박스 숨김) → Plus 아이콘 표시
- Current: 반대 로직 (B박스 표시 시 Plus 표시) → 잘못됨
- Fix: `!widget.absellected` → `widget.absellected` (1줄 수정)

---

### 🆕 Step 3.7: 단일 이미지 모드 레이아웃 추가 (Issue #12)

**현재 코드** (lines 97-139):
```dart
Widget _buildMediaBoxes(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {
  final isHorizontal = mediaSelectionState.currentLayout == LayoutType.horizontal;

  if (isHorizontal) {
    // ❌ 단일 이미지 모드 분기 없음!
    return Row(
      children: [
        Expanded(child: _buildMediaBox(box: 'A', ...)),
        if (!widget.absellected) ...[
          const SizedBox(width: 8),
          Expanded(child: _buildMediaBox(box: 'B', ...)),
        ],
      ],
    );
  } else {
    // Vertical layout...
  }
}
```

**변경** (단일 이미지 모드 분기 추가):
```dart
Widget _buildMediaBoxes(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {
  final isHorizontal = mediaSelectionState.currentLayout == LayoutType.horizontal;

  // ✅ 단일 이미지 모드 분기 추가
  if (widget.absellected && isHorizontal) {
    // 단일 이미지 모드: A박스만 중앙 정렬
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        post_dimensions.MediaDimensions.boxSpacingHorizontal,
        0.0,
        post_dimensions.MediaDimensions.boxSpacingHorizontal,
        0.0
      ),
      child: Center(  // 중앙 정렬
        child: SizedBox(
          width: mediaSelectionState.boxWidthA,
          height: mediaSelectionState.boxHeightA,
          child: _buildMediaBox(
            box: 'A',
            createPostState: createPostState,
            mediaSelectionState: mediaSelectionState,
          ),
        ),
      ),
    );
  }

  // ✅ 기존 듀얼 박스 모드 로직
  if (isHorizontal) {
    return Row(
      children: [
        Expanded(child: _buildMediaBox(box: 'A', ...)),
        if (!widget.absellected) ...[
          const SizedBox(width: 8),
          Expanded(child: _buildMediaBox(box: 'B', ...)),
        ],
      ],
    );
  } else {
    // Vertical layout...
    return Column(
      children: [
        _buildMediaBox(box: 'A', ...),
        if (!widget.absellected) ...[
          const SizedBox(height: 8),
          _buildMediaBox(box: 'B', ...),
        ],
      ],
    );
  }
}
```

**설명**:
- August 22: A박스만 있을 때 (`absellected = true`) 중앙 정렬 레이아웃 사용
- Current: 단일 이미지 모드 전용 레이아웃 없음 → Row의 Expanded로 왼쪽 정렬
- Fix: `if (widget.absellected && isHorizontal)` 분기 추가 (~20줄)

---

### 🆕 Step 3.8: B박스 자동 숨김 로직 검증 및 추가 (Issue #13)

**파일**: `lib/features/creation/presentation/providers/media/media_selection_notifier.dart`

**현재 코드 확인** (removeAtIndex 메서드):
```dart
void removeAtIndex({required String box, required int index}) {
  if (box == 'A') {
    final updated = List<File>.from(state.selectedFilesA);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesA: updated);
  } else {
    final updated = List<File>.from(state.selectedFilesB);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesB: updated);

    // ❓ B박스 비었을 때 absellected = true 설정하는가?
    // NEED VERIFICATION
  }
}
```

**변경** (B박스 자동 숨김 로직 추가):
```dart
void removeAtIndex({required String box, required int index}) {
  if (box == 'A') {
    final updated = List<File>.from(state.selectedFilesA);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesA: updated);
  } else {
    final updated = List<File>.from(state.selectedFilesB);
    updated.removeAt(index);

    // ✅ B박스 자동 숨김 로직 추가
    state = state.copyWith(
      selectedFilesB: updated,
      absellected: updated.isEmpty ? true : state.absellected,
    );
  }
}
```

**추가 검증 필요**:
```dart
// selectImages 메서드에서도 확인
void selectImages({required String box, required List<AssetEntity> assets}) async {
  // ... 이미지 선택 로직 ...

  if (box == 'A' && state.selectedFilesB.isEmpty) {
    // ✅ A박스에 이미지 추가되었고 B박스 비어있으면 자동 숨김
    state = state.copyWith(absellected: true);
  } else if (box == 'B' && files.isNotEmpty) {
    // ✅ B박스에 이미지 추가되면 absellected = false
    state = state.copyWith(absellected: false);
  }
}
```

---

### Phase 3 검증 체크리스트

**Issue #18 검증** (Image Widget Unnecessary Elements):
- [ ] Image Section에 "A vs B 이미지 선택" 라벨 없음 (Step 3.1)
- [ ] Image Section Container에 `padding: EdgeInsets.symmetric(horizontal: 16)` 없음 (Step 3.2)
- [ ] _buildMediaSection() 메서드가 직접 _buildMediaBoxes() 호출 (Step 3.5)
- [ ] 불필요한 Container 제거됨

**Issue #19 검증** (Box Color Hardcoded):
- [ ] Box A color = `AppTheme.of(context).primary` (동적 테마)
- [ ] Box B color = `AppTheme.of(context).secondary` (동적 테마)
- [ ] AppColors.boxABackground, boxBBackground 사용 안 함
- [ ] 다크 모드 전환 시 Box 색상 자동 변경됨

**Issue #11 검증** (Plus Icon Condition Reversed):
- [ ] Plus 아이콘 조건: `box == 'A' && widget.absellected` (기존 `!widget.absellected` 수정)
- [ ] Plus 아이콘이 B박스 숨김 시 표시됨 (`absellected = true`)
- [ ] Plus 아이콘이 B박스 표시 시 숨겨짐 (`absellected = false`)
- [ ] Plus 아이콘 클릭 시 B박스가 나타남

**Issue #12 검증** (Center Layout Missing):
- [ ] `if (widget.absellected && isHorizontal)` 분기 존재
- [ ] 단일 이미지 모드 시 A박스 중앙 정렬됨 (`Center` 위젯 사용)
- [ ] 단일 이미지 모드 시 SizedBox width/height 지정됨
- [ ] A/B 박스 모두 있을 때 기존 Row/Column 레이아웃 사용

**Issue #13 검증** (B Box Visibility Logic):
- [ ] B박스 이미지 모두 삭제 시 `absellected = true` 자동 설정
- [ ] A박스에 이미지 추가 + B박스 비어있으면 `absellected = true` 유지
- [ ] B박스에 이미지 추가 시 `absellected = false` 설정
- [ ] removeAtIndex, selectImages 메서드 모두 검증됨

**전체 검증**:
- [ ] Box spacing (horizontal/vertical) 정확 (SizedBox width: 8, height: 8)
- [ ] 디버그 정보는 kDebugMode에서만 표시
- [ ] Warning 메시지는 조건부로만 표시
- [ ] flutter analyze 0 errors, 0 warnings
- [ ] August 22 커밋과 픽셀 단위 100% 일치 확인

---

## Phase 4: FieldStyles 검증/수정 (1시간)

### 목표

FieldStyles.textA / FieldStyles.textB 설정이 August 22와 동일한지 검증 및 수정

### 수정 파일

`lib/features/creation/presentation/constants/field_styles.dart`

**수정 라인**: ~50줄 (추가 또는 수정)

### Step 4.1: 현재 FieldStyles 확인

**파일 읽기**:
```bash
cat lib/features/creation/presentation/constants/field_styles.dart
```

**확인 항목**:
- [ ] `static const textA = 'textA';` 존재 여부
- [ ] `static const textB = 'textB';` 존재 여부
- [ ] `_configs` Map에 `textA` 설정 존재 여부
- [ ] `_configs` Map에 `textB` 설정 존재 여부

### Step 4.2: textA/textB FieldConfig 추가 (없으면)

**August 22 설정** (field_styles.dart):
```dart
static const textA = 'textA';
static const textB = 'textB';

static final Map<String, FieldConfig> _configs = {
  // ... 기존 설정 ...

  textA: FieldConfig(
    textSize: 15.0,        // ✅ August 22 값
    labelSize: 20.0,       // ✅ August 22 값
    maxLength: 20,         // ✅ August 22 값
    maxLines: 5,           // ✅ August 22 값 (NOT 2)
    minLines: 1,
    isDense: true,         // ✅ August 22 값
    borderType: FieldBorderType.underline,  // ✅ August 22 값
    borderWidth: 2.0,      // ✅ August 22 값
    borderRadius: 12.0,    // ✅ August 22 값 (NOT 8.0)
  ),

  textB: FieldConfig(
    textSize: 15.0,
    labelSize: 20.0,
    maxLength: 20,
    maxLines: 5,
    minLines: 1,
    isDense: true,
    borderType: FieldBorderType.underline,
    borderWidth: 2.0,
    borderRadius: 12.0,
  ),
};
```

### Step 4.3: FieldConfig 클래스 확인

**필요한 필드 확인**:
```dart
class FieldConfig {
  final double textSize;
  final double labelSize;
  final int maxLength;
  final int? maxLines;
  final int minLines;
  final bool isDense;
  final FieldBorderType borderType;
  final double borderWidth;
  final double borderRadius;

  const FieldConfig({
    required this.textSize,
    required this.labelSize,
    required this.maxLength,
    this.maxLines,
    required this.minLines,
    required this.isDense,
    required this.borderType,
    required this.borderWidth,
    required this.borderRadius,
  });
}
```

**만약 필드가 없으면 추가**:
```dart
// Example: borderRadius 필드 추가
final double borderRadius;

const FieldConfig({
  // ... 기존 파라미터 ...
  required this.borderRadius,  // ← 추가
});
```

### Step 4.4: SimpleValidatedField 통합 확인

**SimpleValidatedField가 FieldConfig를 사용하는지 확인**:
```bash
cat lib/features/creation/presentation/widgets/components/simple_validated_field.dart | grep -A 10 "FieldConfig"
```

**예상 코드**:
```dart
final config = FieldStyles.getConfig(widget.fieldName);

// fontSize 적용
style: AppTheme.of(context).bodyMedium.override(
  fontSize: widget.fontSize ?? config.textSize,  // ✅
  // ...
),

// maxLength 적용
maxLength: widget.maxLength ?? config.maxLength,  // ✅

// border 적용
decoration: InputDecoration(
  border: config.borderType == FieldBorderType.underline
      ? UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: config.borderWidth,
          ),
          borderRadius: BorderRadius.circular(config.borderRadius),
        )
      : OutlineInputBorder(...),
  // ...
),
```

**만약 통합 안 되어 있으면 수정 필요**

### Phase 4 검증 체크리스트

- [ ] FieldStyles.textA 정의됨
- [ ] FieldStyles.textB 정의됨
- [ ] textA FieldConfig 모든 속성 정확 (특히 maxLines = 5)
- [ ] textB FieldConfig 모든 속성 정확
- [ ] SimpleValidatedField가 FieldConfig 사용
- [ ] Option A/B 필드가 FieldConfig 적용됨 (Phase 1 완료 후)
- [ ] flutter analyze 0 errors, 0 warnings

---

## Phase 5: Validation & Testing + Moderation 검증 (2-3시간)

### 목표

모든 변경사항을 검증하고 August 22와 100% 동일한지 확인

### Step 5.1: Visual Comparison

#### 5.1.1 Flutter 앱 실행

```bash
flutter run
```

#### 5.1.2 스크린샷 비교

**August 22 스크린샷** (있으면):
- 파일: `docs/screenshots/august_22_creation_ui.png` (또는 유사)

**현재 스크린샷** 찍기:
1. Creation 화면 열기
2. Title, Description, Option A, Option B에 텍스트 입력
3. Image A, Image B 선택
4. 스크린샷 저장

**비교 항목**:
- [ ] 필드 순서 동일
- [ ] 텍스트 필드 크기 동일
- [ ] 이미지 박스 크기 동일
- [ ] Padding/Spacing 동일
- [ ] 색상 동일
- [ ] Character Count 표시 위치 동일
- [ ] Plus 아이콘 표시/숨김 정확
- [ ] A박스만 있을 때 중앙 정렬

#### 5.1.3 Flutter Inspector로 픽셀 측정

**측정 항목**:
1. **Title Field**:
   - Container padding: `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)`
   - fontSize: 30.0
   - CharacterCountDisplay horizontalPadding: 22.0

2. **Description Field**:
   - Container padding: `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)`
   - fontSize: 20.0
   - CharacterCountDisplay horizontalPadding: 22.0

3. **Option A/B Fields**:
   - Container padding: `EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)`
   - Width: 400.0
   - fontSize: 15.0
   - maxLines: 5
   - CharacterCountDisplay horizontalPadding: 32.0

4. **Image Section**:
   - NO horizontal padding
   - NO label
   - Box spacing (horizontal): 8.0
   - Box spacing (vertical): 8.0
   - Plus 아이콘 (B박스 숨김 시만)
   - A박스 중앙 정렬 (단일 이미지 모드)

### Step 5.2: Functional Testing

#### 5.2.1 Character Count Display 테스트

**테스트 케이스**:
1. Title 필드에 텍스트 입력 → Character count 업데이트 확인
2. Title 60자 초과 입력 → 제한 확인
3. Description 200자 초과 입력 → 제한 확인
4. Option A 20자 초과 입력 → 제한 확인
5. Option B 20자 초과 입력 → 제한 확인
6. 빈 필드 → "필수 항목입니다" 메시지 확인 (Title, Options)

#### 5.2.2 Validation Display 테스트

**테스트 케이스**:
1. 욕설 입력 → Perspective API 검증 → 에러 메시지 표시
2. 부적절한 언어 입력 → Gemini AI 검증 → 에러 메시지 표시
3. 정상 텍스트 입력 → 에러 없음 확인

#### 🆕 5.2.3 A/B 박스 토글 테스트

**테스트 케이스**:
1. **초기 상태**: A/B 박스 모두 빈 상태
   - [ ] Plus 아이콘 표시 안 됨

2. **A박스에 이미지 추가**:
   - [ ] B박스 자동 숨김
   - [ ] Plus 아이콘 A박스 위에 표시

3. **Plus 아이콘 클릭**:
   - [ ] B박스 다시 나타남 (빈 상태)
   - [ ] Plus 아이콘 숨김

4. **B박스에 이미지 추가**:
   - [ ] A/B 박스 모두 표시 유지
   - [ ] Plus 아이콘 숨김 유지

5. **B박스 이미지 X 버튼으로 모두 삭제**:
   - [ ] B박스 자동 숨김
   - [ ] Plus 아이콘 다시 표시

#### 🆕 5.2.4 단일 이미지 모드 레이아웃 테스트

**테스트 케이스**:
1. **가로 이미지 1개 (A박스만)**:
   - [ ] A박스 중앙 정렬
   - [ ] Padding 정확 (EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0))

2. **세로 이미지 1개 (A박스만)**:
   - [ ] A박스 세로 레이아웃 (중앙 정렬 아님)

3. **가로 이미지 2개 (A+B)**:
   - [ ] Row 레이아웃 (가로 배치)
   - [ ] A박스 왼쪽, B박스 오른쪽

#### 5.2.5 Layout Toggle 테스트

**테스트 케이스**:
1. Image A 선택 (가로 이미지) + Image B 선택 (가로 이미지) → Vertical layout 자동 선택
2. Image A 선택 (세로 이미지) + Image B 선택 (세로 이미지) → Horizontal layout 자동 선택
3. Layout 변경 시 Box 크기 자동 조정 확인

#### 5.2.6 Clear Button 테스트

**테스트 케이스**:
1. Title Clear 버튼 → 텍스트 삭제 + Character count 0 확인
2. Description Clear 버튼 → 텍스트 삭제 + Character count 0 확인
3. Option A Clear 버튼 → 텍스트 삭제 + Character count 0 확인
4. Option B Clear 버튼 → 텍스트 삭제 + Character count 0 확인

#### 🆕 5.2.7 Moderation 통합 테스트 (Issue #14)

**목표**: canSubmit getter가 Perspective API 검증 결과를 올바르게 확인하는지 검증

**테스트 케이스 1: 정상 콘텐츠**
1. 모든 필드에 정상 텍스트 입력:
   - Title: "일상 질문"
   - Description: "평범한 설명"
   - Option A: "선택지 A"
   - Option B: "선택지 B"
2. **기대 결과**:
   - [ ] Perspective API 검증 통과 (validationResults의 모든 isToxic == false)
   - [ ] 다음 버튼 활성화 (canSubmit == true)
   - [ ] TextField 아래에 에러 메시지 없음

**테스트 케이스 2: Title 독성 콘텐츠**
1. Title에 욕설 입력:
   - Title: "fuck you" (toxicityScore > 0.7)
   - Description: "정상 텍스트"
   - Option A: "정상 텍스트"
   - Option B: "정상 텍스트"
2. 500ms 대기 (Debounce)
3. **기대 결과**:
   - [ ] Perspective API 검증 실패 (titleResult.isToxic == true)
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← Issue #14 Fix
   - [ ] Title TextField 아래에 빨간색 에러 메시지 표시
   - [ ] 에러 메시지: "부적절한 언어가 감지되었습니다..." (한국어)

**테스트 케이스 3: Description 독성 콘텐츠**
1. Description에 혐오 발언 입력:
   - Title: "정상 제목"
   - Description: "you're an idiot" (insultScore > 0.7)
   - Option A: "정상 텍스트"
   - Option B: "정상 텍스트"
2. 500ms 대기
3. **기대 결과**:
   - [ ] Perspective API 검증 실패 (descResult.isToxic == true)
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← Issue #14 Fix
   - [ ] Description TextField 아래에 에러 메시지 표시

**테스트 케이스 4: Option A 독성 콘텐츠**
1. Option A에 욕설 입력:
   - Title: "정상 제목"
   - Description: "정상 설명"
   - Option A: "damn it" (profanityScore > 0.7)
   - Option B: "정상 텍스트"
2. 500ms 대기
3. **기대 결과**:
   - [ ] Perspective API 검증 실패 (textAResult.isToxic == true)
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← Issue #14 Fix
   - [ ] Option A TextField 아래에 에러 메시지 표시

**테스트 케이스 5: Option B 독성 콘텐츠 (단일 모드 제외)**
1. 일반 모드 (showOptionB == true):
   - Title: "정상 제목"
   - Description: "정상 설명"
   - Option A: "정상 텍스트"
   - Option B: "asshole" (toxicityScore > 0.7)
2. 500ms 대기
3. **기대 결과**:
   - [ ] Perspective API 검증 실패 (textBResult.isToxic == true)
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← Issue #14 Fix
   - [ ] Option B TextField 아래에 에러 메시지 표시

**테스트 케이스 6: 단일 모드 (Single Mode)**
1. 단일 모드 활성화 (isSingleMode == true, showOptionB == false):
   - Title: "정상 제목"
   - Description: "정상 설명"
   - Option A: "정상 텍스트"
   - Option B: (표시 안 됨)
2. **기대 결과**:
   - [ ] textBResult 검증 건너뜀 (canSubmit에서 체크 안 함)
   - [ ] 다음 버튼 활성화 (canSubmit == true)

**테스트 케이스 7: 여러 필드 동시 독성 콘텐츠**
1. Title과 Description 모두 욕설:
   - Title: "fuck" (toxicityScore > 0.7)
   - Description: "shit" (profanityScore > 0.7)
   - Option A: "정상 텍스트"
   - Option B: "정상 텍스트"
2. 500ms 대기
3. **기대 결과**:
   - [ ] 두 필드 모두 Perspective API 검증 실패
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← Issue #14 Fix
   - [ ] Title과 Description 아래에 각각 에러 메시지 표시

**테스트 케이스 8: 독성 콘텐츠 수정 후 정상화**
1. Title에 욕설 입력 → 다음 버튼 비활성화 확인
2. Title 수정하여 정상 텍스트로 변경
3. 500ms 대기 (Debounce)
4. **기대 결과**:
   - [ ] Perspective API 재검증 → 통과 (titleResult.isToxic == false)
   - [ ] **다음 버튼 활성화 (canSubmit == true)** ← Issue #14 Fix
   - [ ] 에러 메시지 사라짐

**테스트 케이스 9: validationResults null 상태**
1. 앱 최초 실행 또는 validationResults가 아직 없는 상태
2. 필드에 텍스트 입력 (검증 전)
3. **기대 결과**:
   - [ ] validationResults == null 또는 empty
   - [ ] canSubmit getter에서 null 체크로 통과
   - [ ] formData.isValid == true이면 다음 버튼 활성화

**테스트 케이스 10: 검증 중 상태 (isLoading)**
1. 필드에 텍스트 입력
2. Perspective API 호출 중 (isLoading == true)
3. **기대 결과**:
   - [ ] **다음 버튼 비활성화 (canSubmit == false)** ← isLoading 체크
   - [ ] 로딩 인디케이터 표시 (선택사항)

**검증 포인트 요약**:
- ✅ Perspective API 에러는 TextField 아래에 표시됨 (이미 작동 중)
- ✅ canSubmit getter가 validationResults 확인 (Issue #14 Fix)
- ✅ 독성 콘텐츠가 있으면 다음 버튼 비활성화
- ✅ 독성 콘텐츠 수정 시 다음 버튼 재활성화
- ✅ 단일 모드에서 Option B 검증 건너뜀
- ✅ null 상태 및 isLoading 상태 올바르게 처리

#### 🆕 5.2.8 Field Order 테스트 (Issue #15)

**목표**: create_post_screen.dart의 Column 구조가 August 22 순서와 100% 일치 확인

**테스트 케이스 1: Screen Field 순서 확인**
1. `create_post_screen.dart` 파일 열기
2. `build()` 메서드 내 Column 구조 확인
3. **기대 결과**:
   - [ ] **Column children 순서**: Title → **Image** → Description → Options A/B
   - [ ] TextInputWidget이 3개로 분리되거나 조건부 렌더링됨
   - [ ] `_buildTitleField()` 또는 Title Widget
   - [ ] `ImageSelectionWidget(...)`
   - [ ] `_buildDescriptionField()` 또는 Description Widget
   - [ ] `_buildOptionsFields()` 또는 Options A/B Widget

**테스트 케이스 2: Spacing 정확도**
1. Column children 사이의 SizedBox 확인
2. **기대 결과**:
   - [ ] Title ↔ Image: `SizedBox(height: 24)`
   - [ ] Image ↔ Description: `SizedBox(height: 24)`
   - [ ] Description ↔ Options: `SizedBox(height: 24)`
   - [ ] Option A ↔ Option B: `SizedBox(height: 16)` (또는 적절한 spacing)

**테스트 케이스 3: Visual 검증 (August 22 스크린샷 비교)**
1. 앱 실행 → Creation 화면 진입
2. August 22 스크린샷과 나란히 비교
3. **기대 결과**:
   - [ ] Title 필드가 최상단에 위치
   - [ ] Image Section이 Title 바로 아래
   - [ ] Description이 Image 아래
   - [ ] Options A/B가 Description 아래
   - [ ] 전체 레이아웃이 픽셀 단위 100% 일치

**검증 포인트 요약**:
- ✅ Column 구조가 올바른 순서로 변경됨 (Title → Image → Description → Options)
- ✅ Spacing이 August 22와 정확히 일치
- ✅ 시각적으로 완벽하게 일치

#### 🆕 5.2.9 Component Type 테스트 (Issue #16, #17)

**목표**: Options A/B가 SimpleValidatedField 사용, 4개 필드 모두 CharacterCountDisplay 표시 확인

**테스트 케이스 1: SimpleValidatedField 사용 확인**
1. `text_input_widget.dart` 파일 열기
2. `_buildOptionAField()`, `_buildOptionBField()` 메서드 확인
3. **기대 결과**:
   - [ ] Option A/B가 `SimpleValidatedField` 사용 (NOT TextFormField)
   - [ ] `fieldName: FieldStyles.textA`, `FieldStyles.textB` 설정됨
   - [ ] `controller`, `focusNode`, `validationResult` 연결됨
   - [ ] `width: 400.0`, `alignment: AlignmentDirectional(-1.0, 0.0)` 설정됨
   - [ ] `padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)` 설정됨

**테스트 케이스 2: CharacterCountDisplay 4개 확인**
1. 앱 실행 → Creation 화면 진입
2. CharacterCountDisplay Widget 개수 확인
3. **기대 결과**:
   - [ ] **CharacterCountDisplay 4개** 표시됨:
     - Title 아래 (horizontalPadding: 22.0)
     - Description 아래 (horizontalPadding: 22.0)
     - Option A 아래 (horizontalPadding: 32.0)
     - Option B 아래 (horizontalPadding: 32.0)

**테스트 케이스 3: CharacterCountDisplay 동작**
1. Title 필드에 "Test Title" 입력 (10 chars)
2. **기대 결과**:
   - [ ] Title CharacterCountDisplay: "10/60" 표시
   - [ ] 색상: `AppTheme.of(context).grayText600` (정상 범위)
3. Title에 60자 초과 입력
4. **기대 결과**:
   - [ ] CharacterCountDisplay 색상: `AppTheme.of(context).errorColor` (빨간색)

**테스트 케이스 4: Validation 에러 시 CharacterCountDisplay**
1. Title에 욕설 입력 (Perspective API 검증 실패)
2. **기대 결과**:
   - [ ] CharacterCountDisplay 색상: `AppTheme.of(context).errorColor`
   - [ ] ValidationResult.isToxic == true 반영됨

**검증 포인트 요약**:
- ✅ Options A/B가 SimpleValidatedField 사용
- ✅ CharacterCountDisplay 4개 모두 표시됨
- ✅ horizontalPadding 값이 정확함 (Title/Description: 22.0, Options: 32.0)
- ✅ 글자 수 입력 시 실시간 업데이트됨
- ✅ Validation 에러 시 색상 변경됨

#### 🆕 5.2.10 Image Section 테스트 (Issue #18, #19)

**목표**: Label/Container padding 제거, Box 색상 동적 테마 사용 확인

**테스트 케이스 1: Label 제거 확인**
1. `image_selection_widget.dart` 파일 열기
2. `_buildMediaSection()` 메서드 확인
3. **기대 결과**:
   - [ ] "A vs B 이미지 선택" 라벨 없음 (lines 77-84 삭제됨)
   - [ ] `_buildMediaSection()`이 직접 `_buildMediaBoxes()` 호출
   - [ ] 불필요한 Container 제거됨

**테스트 케이스 2: Container Padding 제거 확인**
1. `_buildMediaSection()` 메서드 확인
2. **기대 결과**:
   - [ ] Container에 `padding: EdgeInsets.symmetric(horizontal: 16)` 없음 (line 73 삭제됨)
   - [ ] MediaSelectionBoxMulti가 자체 padding 관리

**테스트 케이스 3: Box Color 동적 테마 확인**
1. `_buildMediaBox()` 메서드 내 `boxColor` 파라미터 확인 (line 166)
2. **기대 결과**:
   - [ ] Box A color: `AppTheme.of(context).primary` (NOT AppColors.boxABackground)
   - [ ] Box B color: `AppTheme.of(context).secondary` (NOT AppColors.boxBBackground)
   - [ ] AppColors 하드코딩 사용 안 함

**테스트 케이스 4: 다크 모드 전환 테스트**
1. 앱 실행 → Creation 화면 진입
2. A/B 박스 색상 확인 (라이트 모드)
3. 디바이스 다크 모드 활성화
4. **기대 결과**:
   - [ ] Box A/B 색상이 자동으로 변경됨 (동적 테마 작동)
   - [ ] 하드코딩된 색상이 아님

**테스트 케이스 5: Visual 검증 (August 22 비교)**
1. 앱 실행 → Creation 화면 → Image Section
2. August 22 스크린샷과 나란히 비교
3. **기대 결과**:
   - [ ] Label이 없음 (깔끔한 레이아웃)
   - [ ] Box spacing 정확 (horizontal: 8, vertical: 8)
   - [ ] Box 색상이 August 22와 동일

**검증 포인트 요약**:
- ✅ "A vs B 이미지 선택" Label 제거됨
- ✅ Container padding 제거됨
- ✅ Box 색상이 AppTheme 동적 테마 사용
- ✅ 다크 모드 전환 시 색상 자동 변경
- ✅ August 22 스크린샷과 픽셀 단위 100% 일치

### Step 5.3: 코드 품질 검증

```bash
# 1. 정적 분석
flutter analyze
# 목표: 0 errors, 0 warnings

# 2. 포맷 확인
dart format lib/features/creation/ --set-exit-if-changed

# 3. 테스트 실행 (있으면)
flutter test test/features/creation/
```

### Step 5.4: Integration Test (선택사항)

**Integration Test 작성** (test/integration_test/creation_ui_test.dart):
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Creation UI Pixel-Perfect Test', () {
    testWidgets('Text fields display CharacterCountDisplay', (tester) async {
      // 1. 앱 실행
      await tester.pumpWidget(MyApp());

      // 2. Creation 화면으로 이동
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 3. CharacterCountDisplay 4개 확인
      expect(find.byType(CharacterCountDisplay), findsNWidgets(4));

      // 4. Title 입력 시 Character count 업데이트
      await tester.enterText(find.byKey(Key('title_field')), 'Test Title');
      await tester.pumpAndSettle();
      expect(find.text('10/60'), findsOneWidget);
    });

    testWidgets('Option fields use SimpleValidatedField', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // SimpleValidatedField 4개 확인 (Title, Description, Option A, Option B)
      expect(find.byType(SimpleValidatedField), findsNWidgets(4));
    });

    testWidgets('Field order matches August 22', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 순서 확인: Title → Image → Description → Options
      final children = tester.widget<Column>(find.byType(Column)).children;

      expect(children[0], isA<Widget>());  // Title
      expect(children[1], isA<ImageSelectionWidget>());  // Image
      expect(children[2], isA<Widget>());  // Description
      expect(children[3], isA<Widget>());  // Option A
      expect(children[4], isA<Widget>());  // Option B
    });

    testWidgets('Plus icon toggles B box visibility', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 1. A박스에 이미지 추가
      // ... (이미지 선택 로직)

      // 2. Plus 아이콘 확인
      expect(find.byIcon(Icons.add_circle), findsOneWidget);

      // 3. Plus 아이콘 클릭
      await tester.tap(find.byIcon(Icons.add_circle));
      await tester.pumpAndSettle();

      // 4. B박스 나타남 확인
      expect(find.text('B'), findsOneWidget);

      // 5. Plus 아이콘 숨겨짐 확인
      expect(find.byIcon(Icons.add_circle), findsNothing);
    });

    testWidgets('Single image mode centers A box', (tester) async {
      await tester.pumpWidget(MyApp());
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 1. A박스에 가로 이미지 1개 추가
      // ... (이미지 선택 로직)

      // 2. Center 위젯 확인
      final centerWidget = find.ancestor(
        of: find.byKey(Key('media_box_A')),
        matching: find.byType(Center),
      );
      expect(centerWidget, findsOneWidget);

      // 3. B박스 숨겨짐 확인
      expect(find.byKey(Key('media_box_B')), findsNothing);
    });
  });
}
```

### Phase 5 검증 체크리스트

완료 후 다음 항목 확인:

**Issue #15 검증** (Screen Field Order):
- [ ] **필드 순서**: Title → **Image** → Description → Options A/B (정확한 순서)
- [ ] create_post_screen.dart Column 구조가 올바른 순서로 변경됨
- [ ] Title과 Image 사이 Spacing: `SizedBox(height: 24)`
- [ ] Image와 Description 사이 Spacing: `SizedBox(height: 24)`
- [ ] Description과 Options 사이 Spacing: `SizedBox(height: 24)`
- [ ] Option A와 Option B 사이 Spacing 정확
- [ ] 시각적으로 August 22 스크린샷과 동일

**Issue #16 검증** (SimpleValidatedField Component):
- [ ] Option A/B가 `SimpleValidatedField` 사용 (NOT TextFormField)
- [ ] `fieldName: FieldStyles.textA`, `FieldStyles.textB` 설정됨
- [ ] `width: 400.0`, `alignment: AlignmentDirectional(-1.0, 0.0)` 설정됨
- [ ] `padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)` 설정됨
- [ ] `controller`, `focusNode`, `validationResult` 연결됨

**Issue #17 검증** (CharacterCountDisplay):
- [ ] **CharacterCountDisplay 4개** 필드 모두 표시됨
  - Title 아래 (horizontalPadding: 22.0)
  - Description 아래 (horizontalPadding: 22.0)
  - Option A 아래 (horizontalPadding: 32.0)
  - Option B 아래 (horizontalPadding: 32.0)
- [ ] 글자 수 입력 시 CharacterCountDisplay 실시간 업데이트됨
- [ ] Validation 에러 시 CharacterCountDisplay 색상 변경됨 (빨간색)

**Issue #18 검증** (Image Widget Unnecessary Elements):
- [ ] Image Section에 "A vs B 이미지 선택" 라벨 **없음**
- [ ] Image Section Container에 `padding: EdgeInsets.symmetric(horizontal: 16)` **없음**
- [ ] `_buildMediaSection()`이 직접 `_buildMediaBoxes()` 호출
- [ ] 불필요한 Container 제거됨

**Issue #19 검증** (Box Color Hardcoded):
- [ ] Box A color = `AppTheme.of(context).primary` (동적 테마)
- [ ] Box B color = `AppTheme.of(context).secondary` (동적 테마)
- [ ] AppColors.boxABackground, boxBBackground 사용 **안 함**
- [ ] 다크 모드 전환 시 Box 색상 자동 변경됨

**Issue #11 검증** (Plus Icon Condition Reversed - 기존):
- [ ] Plus 아이콘 조건: `box == 'A' && widget.absellected`
- [ ] Plus 아이콘이 B박스 숨김 시 표시됨 (`absellected = true`)
- [ ] Plus 아이콘이 B박스 표시 시 숨겨짐 (`absellected = false`)
- [ ] Plus 아이콘 클릭 시 B박스가 나타남

**Issue #12 검증** (Center Layout Missing - 기존):
- [ ] `if (widget.absellected && isHorizontal)` 분기 존재
- [ ] 단일 이미지 모드 시 A박스 중앙 정렬됨 (`Center` 위젯 사용)
- [ ] 단일 이미지 모드 시 SizedBox width/height 지정됨
- [ ] A/B 박스 모두 있을 때 기존 Row/Column 레이아웃 사용

**Issue #13 검증** (B Box Visibility Logic - 기존):
- [ ] B박스 이미지 모두 삭제 시 `absellected = true` 자동 설정
- [ ] A박스에 이미지 추가 + B박스 비어있으면 `absellected = true` 유지
- [ ] B박스에 이미지 추가 시 `absellected = false` 설정
- [ ] removeAtIndex, selectImages 메서드 모두 검증됨

**Issue #14 검증** (canSubmit Moderation Bypass - 기존):
- [ ] canSubmit getter가 Moderation 결과를 확인함
  - [ ] `titleResult?.isToxic` 체크
  - [ ] `descResult?.isToxic` 체크
  - [ ] `textAResult?.isToxic` 체크
  - [ ] `textBResult?.isToxic` 체크 (단일 모드 제외)
- [ ] 독성 콘텐츠 입력 시 다음 버튼 비활성화

**전체 검증**:
- [ ] Text Input Section padding 정확
- [ ] Image Section box spacing 정확 (horizontal: 8, vertical: 8)
- [ ] 디버그 정보는 kDebugMode에서만 표시
- [ ] Warning 메시지는 조건부로만 표시
- [ ] **flutter analyze 0 errors, 0 warnings**
- [ ] dart format 통과
- [ ] 테스트 통과 (있으면)
- [ ] Integration test 통과 (있으면)
- [ ] **August 22 커밋과 픽셀 단위 100% 일치 확인**

---

## 📋 Implementation Details: Perspective API Validation UI

### 개요

**중요**: Perspective API 검증 에러는 **August 22부터 현재까지 정상적으로 표시되고 있습니다**. TextField 아래에 빨간색 에러 메시지로 표시되며, 이 기능은 올바르게 작동 중입니다.

### UI 표시 위치

```
┌─────────────────────────────────────┐
│ Title TextField                      │
│ [사용자 입력 텍스트]                 │
└─────────────────────────────────────┘
🔴 이 콘텐츠는 부적절한 내용을 포함하고 있을 수 있습니다.
    ↑ Perspective API 에러 메시지 위치

┌─────────────────────────────────────┐
│ Description TextField                 │
│ [사용자 입력 텍스트]                 │
└─────────────────────────────────────┘
🔴 욕설이나 혐오 표현이 감지되었습니다.
    ↑ Perspective API 에러 메시지 위치
```

### 구현 코드 분석

#### 1. InputFieldBuilder.buildErrorMessage() (핵심 로직)

**파일 위치**: `lib/features/creation/presentation/widgets/components/input_field_builder.dart:93-143`

**August 22부터 현재까지 동일한 구현**:

```dart
/// 에러 메시지 표시
/// Step 9: AIModerationFailure로 중앙화된 메시지 사용
static Widget? buildErrorMessage({
  required BuildContext context,
  required PerspectiveResult? validationResult,
}) {
  if (validationResult == null || !validationResult.isToxic) {
    return null;  // ✅ 에러 없으면 null 반환 (표시 안 함)
  }

  // Step 9: Perspective API 점수를 AIModerationFailure 카테고리로 매핑
  // ✅ Phase 3: 하드코딩 제거 (0.8 → ModerationConfig.severeThreshold)
  List<String> detectedCategories = [];
  if (validationResult.toxicityScore > ModerationConfig.severeThreshold) {
    detectedCategories.add('toxicity');
  }
  if (validationResult.profanityScore > ModerationConfig.severeThreshold) {
    detectedCategories.add('profanity');
  }
  if (validationResult.threatScore > ModerationConfig.severeThreshold) {
    detectedCategories.add('harassment');
  }
  if (validationResult.insultScore > ModerationConfig.severeThreshold) {
    detectedCategories.add('hate');
  }

  // Step 9: detectedCategories가 비어있으면 generic 카테고리 사용
  if (detectedCategories.isEmpty) {
    detectedCategories.add('toxicity'); // 기본값
  }

  // Step 9: 최대 점수 계산
  final maxScore = [
    validationResult.toxicityScore,
    validationResult.profanityScore,
    validationResult.threatScore,
    validationResult.insultScore,
  ].reduce((a, b) => a > b ? a : b);

  // Step 9: AIModerationFailed 생성 및 getUserMessage() 사용
  final failure = CreationFailure.aiModerationFailed(
    aiProvider: 'perspective',
    detectedCategories: detectedCategories,
    confidenceScore: maxScore,
  );

  final errorMessage = failure.getUserMessage();

  // ✅ 에러 메시지 Widget 반환 (TextField 아래 표시)
  return Padding(
    padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
    child: Text(
      errorMessage,
      style: TextStyle(
        color: Colors.red,  // 🔴 빨간색
        fontSize: 12.0,
      ),
    ),
  );
}
```

#### 2. SimpleValidatedField Integration

**파일 위치**: `lib/features/creation/presentation/widgets/components/simple_validated_field.dart`

**Title/Description 필드에서 사용**:

```dart
SimpleValidatedField(
  controller: _titleController,
  focusNode: _titleFocus,
  labelKey: 'bjdyxvvl',
  hintKey: 'a8xnk2go',
  fieldName: FieldStyles.questionTitle,
  maxLength: 100,

  // ✅ Perspective API 검증 결과 전달
  validationResult: validationResults[FieldStyles.questionTitle],

  onFieldChanged: (value, fieldName, isBlocked) {
    // Provider 업데이트
    ref.read(createPostProvider.notifier).updateTitle(value);

    // Debounced validation (500ms)
    _titleDebounce?.run(() async {
      await ref.read(createPostProvider.notifier).validateTitle(value);
    });
  },

  onFieldCleared: () {
    ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.questionTitle);
  },

  onRequiredFieldsCheck: () {
    // Optional: Form validation check
  },
);
```

#### 3. Real-time Validation Flow

```
사용자 입력
    ↓
TextField onChange
    ↓
Debounce (500ms)  ← 과도한 API 호출 방지
    ↓
CreatePostNotifier.validateTitle()
    ↓
Perspective API 호출
    ↓
PerspectiveResult 반환
    ↓
CreatePostState.validationResults 업데이트
    ↓
ref.watch(createPostProvider) 리빌드
    ↓
InputFieldBuilder.buildErrorMessage() 호출
    ↓
에러 메시지 Widget 생성 (있으면)
    ↓
TextField 아래에 표시 🔴
```

### ModerationConfig Thresholds

**파일 위치**: `lib/services/moderation/constants/moderation_config.dart`

```dart
class ModerationConfig {
  /// 통합 임계값 (Unified threshold)
  /// - 0.7 이상: 경고 수준 (일반적인 독성)
  /// - Perspective API 기본 사용 값
  static const double unifiedThreshold = 0.7;

  /// 심각한 위반 임계값 (Severe threshold)
  /// - 0.8 이상: 심각한 위반 (강력한 차단 필요)
  /// - AIModerationFailure 카테고리 분류에 사용
  static const double severeThreshold = 0.8;
}
```

**사용 예시**:

```dart
// 일반 독성 체크 (경고 표시)
if (validationResult.toxicityScore > ModerationConfig.unifiedThreshold) {
  return InputFieldBuilder.buildErrorMessage(
    context: context,
    validationResult: validationResult,
  );
}

// 심각한 위반 체크 (카테고리 분류)
if (validationResult.toxicityScore > ModerationConfig.severeThreshold) {
  detectedCategories.add('toxicity');
}
```

### CreationFailure.aiModerationFailed() Extension

**파일 위치**: `lib/features/creation/domain/failures/creation_failure_extensions.dart`

```dart
extension CreationFailureExtensions on CreationFailure {
  String getUserMessage() {
    return when(
      aiModerationFailed: (aiProvider, detectedCategories, confidenceScore) {
        // ✅ 카테고리별 한국어 메시지
        if (detectedCategories.contains('profanity')) {
          return '욕설이나 혐오 표현이 감지되었습니다.';
        }
        if (detectedCategories.contains('harassment')) {
          return '위협적이거나 괴롭힘으로 간주될 수 있는 내용이 포함되어 있습니다.';
        }
        if (detectedCategories.contains('hate')) {
          return '혐오 발언이 감지되었습니다.';
        }

        // 기본 메시지
        return '이 콘텐츠는 부적절한 내용을 포함하고 있을 수 있습니다.';
      },
      // ... other failure types
    );
  }
}
```

### UI 표시 예시

**정상 입력** (독성 없음):
```
┌─────────────────────────────────────┐
│ Title TextField                      │
│ 오늘 날씨 어때요?                    │
└─────────────────────────────────────┘
(에러 메시지 없음)
```

**독성 감지** (toxicity > 0.7):
```
┌─────────────────────────────────────┐
│ Title TextField                      │
│ [부적절한 내용]                      │
└─────────────────────────────────────┘
🔴 이 콘텐츠는 부적절한 내용을 포함하고 있을 수 있습니다.
```

**욕설 감지** (profanity > 0.8):
```
┌─────────────────────────────────────┐
│ Description TextField                 │
│ [욕설 포함 텍스트]                   │
└─────────────────────────────────────┘
🔴 욕설이나 혐오 표현이 감지되었습니다.
```

### 정리

| 항목 | 상태 | 설명 |
|------|------|------|
| **에러 표시 위치** | ✅ 정상 | TextField 아래에 표시 (August 22부터 현재까지) |
| **에러 메시지** | ✅ 정상 | CreationFailure Extension으로 한국어 메시지 |
| **실시간 검증** | ✅ 정상 | Debounce 500ms로 API 호출 최소화 |
| **Threshold 설정** | ✅ 정상 | ModerationConfig로 중앙 관리 (0.7/0.8) |
| **카테고리 분류** | ✅ 정상 | 4가지 카테고리 (toxicity/profanity/harassment/hate) |

**Issue #14와의 관계**: Perspective API 에러 **표시**는 정상 작동. 문제는 **다음 버튼이 이 검증 결과를 무시**한다는 것 (canSubmit getter에서 확인 안 함).

---

## 🚦 다음 버튼 활성화 조건

### 현재 구현 (문제)

**파일 위치**: `lib/features/creation/presentation/providers/states/create_post_state.dart:45-50`

```dart
bool get canSubmit {
  return formData.isValid && !isLoading;  // ⚠️ Moderation 결과 무시!
}
```

**formData.isValid 정의**:

```dart
bool get isValid {
  return title.isNotEmpty &&
      description.isNotEmpty &&
      (textA.isNotEmpty || imagesA.isNotEmpty) &&
      (isSingleMode || textB.isNotEmpty || imagesB.isNotEmpty);
}
```

**문제점**:
1. ❌ **Perspective API 검증 결과를 확인하지 않음**
2. ❌ `validationResults` Map을 완전히 무시
3. ❌ 독성 콘텐츠(`isToxic == true`)도 제출 가능

### 올바른 구현 (기대 동작)

**August 22 동작 복원**:

```dart
bool get canSubmit {
  // ✅ 1. 기본 필드 검증
  if (!formData.isValid || isLoading) return false;

  // ✅ 2. Perspective API 검증 결과 확인
  final titleResult = validationResults[FieldStyles.questionTitle];
  final descResult = validationResults[FieldStyles.description];
  final textAResult = validationResults[FieldStyles.textA];
  final textBResult = validationResults[FieldStyles.textB];

  // ✅ 3. 독성 콘텐츠 차단
  if (titleResult?.isToxic == true) return false;
  if (descResult?.isToxic == true) return false;
  if (textAResult?.isToxic == true) return false;
  if (!formData.isSingleMode && textBResult?.isToxic == true) return false;

  // ✅ 4. 모든 조건 통과 시 활성화
  return true;
}
```

### 활성화 조건 Flow Chart

```
canSubmit 호출
    ↓
formData.isValid?
  NO → return false (필수 필드 비어있음)
  YES ↓
isLoading?
  YES → return false (제출 중)
  NO ↓
titleResult.isToxic?
  YES → return false (제목 독성)
  NO ↓
descResult.isToxic?
  YES → return false (설명 독성)
  NO ↓
textAResult.isToxic?
  YES → return false (A옵션 독성)
  NO ↓
isSingleMode?
  NO → textBResult.isToxic?
    YES → return false (B옵션 독성)
    NO ↓
  YES ↓
return true ✅ (모든 조건 통과)
```

### 다음 버튼 UI 연결

**파일 위치**: `lib/features/creation/presentation/screens/create_post_screen.dart:258-290`

```dart
if (_showNextButton)  // ① 스크롤 위치 확인 (>50px)
  Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: NextButton(
        // ② canSubmit getter 확인 (formData + moderation)
        showButton: createPostState.canSubmit,

        // ③ 최종 조건: canSubmit && !_isValidating
        onPressed: createPostState.canSubmit && !_isValidating
            ? _handleSubmit
            : null,
      ),
    ),
  ),
```

### 단계별 활성화 조건

| 단계 | 조건 | 확인 내용 | 실패 시 |
|------|------|----------|---------|
| **1** | `_showNextButton` | 스크롤 위치 >50px | 버튼 숨김 |
| **2** | `formData.isValid` | 필수 필드 모두 입력 | 버튼 비활성화 (회색) |
| **3** | `!isLoading` | 제출 중이 아님 | 버튼 비활성화 |
| **4** | `validationResults` | Perspective API 통과 | 버튼 비활성화 ⚠️ |
| **5** | `!_isValidating` | 검증 중이 아님 | 버튼 비활성화 |

**현재 문제**: 단계 4 (Perspective API 검증) 확인 누락 → Issue #14

### Edge Cases

#### Case 1: 검증 중 상태

```dart
// 사용자가 텍스트 입력 중 (Debounce 500ms 내)
_isValidating == true
  → canSubmit == true (Perspective 결과 아직 없음)
  → onPressed == null (버튼 비활성화) ✅ 정상
```

#### Case 2: 독성 콘텐츠 입력 후

```dart
// Perspective API 결과 반환 (isToxic == true)
titleResult.isToxic == true
  → canSubmit == false ❌ (현재 true 반환 - 버그!)
  → onPressed == _handleSubmit ❌ (제출 가능 - 버그!)
```

#### Case 3: 단일 모드 (B박스 없음)

```dart
// isSingleMode == true
textBResult.isToxic == true  // B박스 검증 결과 무시
  → canSubmit == true ✅ (B박스는 검증 안 함)
```

#### Case 4: 검증 결과 없음 (null)

```dart
// 사용자가 아직 입력하지 않음
titleResult == null
  → canSubmit == true ✅ (null은 독성 아님)
```

### Fix Impact 분석

**수정 범위**: Phase 2에서 `create_post_state.dart:canSubmit` getter 수정 (~15줄)

**Before (현재)**:
```dart
bool get canSubmit {
  return formData.isValid && !isLoading;  // 2개 조건
}
```

**After (수정 후)**:
```dart
bool get canSubmit {
  if (!formData.isValid || isLoading) return false;

  // Moderation 검증 추가
  final titleResult = validationResults[FieldStyles.questionTitle];
  final descResult = validationResults[FieldStyles.description];
  final textAResult = validationResults[FieldStyles.textA];
  final textBResult = validationResults[FieldStyles.textB];

  if (titleResult?.isToxic == true) return false;
  if (descResult?.isToxic == true) return false;
  if (textAResult?.isToxic == true) return false;
  if (!formData.isSingleMode && textBResult?.isToxic == true) return false;

  return true;  // 총 7개 조건
}
```

**테스트 케이스**:
1. ✅ 정상 입력 → 버튼 활성화
2. ✅ 필수 필드 누락 → 버튼 비활성화
3. ✅ 독성 콘텐츠 → 버튼 비활성화 (수정 후)
4. ✅ 검증 중 → 버튼 비활성화
5. ✅ 단일 모드 → B박스 무시

---

## 🔧 Moderation API 설정 및 호출 흐름

### Perspective API Overview

**Google Cloud AI 기반 콘텐츠 검열 서비스**:
- **목적**: 온라인 대화에서 독성, 욕설, 위협, 혐오 발언 감지
- **기술**: Machine Learning 기반 텍스트 분석
- **응답**: 0.0 ~ 1.0 점수 (높을수록 독성 강함)

**공식 문서**: https://developers.perspectiveapi.com/

### ModerationConfig 중앙 설정

**파일 위치**: `lib/services/moderation/constants/moderation_config.dart`

```dart
/// Perspective API & Gemini AI Moderation 통합 설정
///
/// Phase 3 개선:
/// - 하드코딩된 threshold 제거 (0.7, 0.8)
/// - 중앙화된 설정으로 일관성 보장
/// - 향후 동적 threshold 조정 가능
class ModerationConfig {
  /// 통합 임계값 (Unified threshold)
  /// - Perspective API 기본 사용 값
  /// - 0.7 이상: 경고 수준 (일반적인 독성)
  /// - UI에 에러 메시지 표시
  static const double unifiedThreshold = 0.7;

  /// 심각한 위반 임계값 (Severe threshold)
  /// - AIModerationFailure 카테고리 분류에 사용
  /// - 0.8 이상: 심각한 위반 (강력한 차단 필요)
  /// - detectedCategories 추가
  static const double severeThreshold = 0.8;

  /// Perspective API 속성 목록
  /// - TOXICITY: 일반적인 독성
  /// - SEVERE_TOXICITY: 심각한 독성
  /// - IDENTITY_ATTACK: 정체성 공격
  /// - INSULT: 모욕
  /// - PROFANITY: 욕설
  /// - THREAT: 위협
  static const List<String> perspectiveAttributes = [
    'TOXICITY',
    'SEVERE_TOXICITY',
    'IDENTITY_ATTACK',
    'INSULT',
    'PROFANITY',
    'THREAT',
  ];

  /// Gemini AI Safety Settings
  /// - HARM_CATEGORY_HARASSMENT
  /// - HARM_CATEGORY_HATE_SPEECH
  /// - HARM_CATEGORY_SEXUALLY_EXPLICIT
  /// - HARM_CATEGORY_DANGEROUS_CONTENT
  static const Map<String, String> geminiSafetySettings = {
    'HARM_CATEGORY_HARASSMENT': 'BLOCK_MEDIUM_AND_ABOVE',
    'HARM_CATEGORY_HATE_SPEECH': 'BLOCK_MEDIUM_AND_ABOVE',
    'HARM_CATEGORY_SEXUALLY_EXPLICIT': 'BLOCK_LOW_AND_ABOVE',
    'HARM_CATEGORY_DANGEROUS_CONTENT': 'BLOCK_MEDIUM_AND_ABOVE',
  };
}
```

### Perspective API 호출 흐름

#### 1. TextField onChange 이벤트

**파일 위치**: `lib/features/creation/presentation/widgets/create_post/text_input_widget.dart`

```dart
Widget _buildTitleField() {
  final state = ref.watch(createPostProvider);

  return InputFieldBuilder.buildTitleField(
    context: context,
    controller: _titleController,
    focusNode: _titleFocus,
    onFieldChanged: (value, fieldName, isBlocked) {
      // ① Provider 업데이트 (즉시)
      ref.read(createPostProvider.notifier).updateTitle(value);

      // ② Debounced validation (500ms 지연)
      _titleDebounce?.run(() async {
        await ref.read(createPostProvider.notifier).validateTitle(value);
      });

      // ③ 외부 콜백 호출 (optional)
      widget.onTitleChanged?.call(value);
    },
    onFieldCleared: () {
      ref.read(createPostProvider.notifier).clearValidationResult(FieldStyles.questionTitle);
      widget.onTitleChanged?.call('');
    },
    onRequiredFieldsCheck: () {
      // Optional: Form validation check
    },
    validationResult: state.validationResults[FieldStyles.questionTitle],
  );
}
```

#### 2. Debounce (500ms 지연)

**파일 위치**: `lib/core/utils/helpers/debounce.dart`

```dart
class Debounce {
  final int milliseconds;
  Timer? _timer;

  Debounce({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();  // 기존 타이머 취소
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
```

**효과**:
- 사용자가 빠르게 타이핑 중 → API 호출 안 함 (비용 절감)
- 500ms 동안 입력 없으면 → API 호출 실행

#### 3. CreatePostNotifier.validateTitle() 호출

**파일 위치**: `lib/features/creation/presentation/providers/create_post_notifier.dart`

```dart
Future<void> validateTitle(String text) async {
  if (text.isEmpty) {
    clearValidationResult(FieldStyles.questionTitle);
    return;
  }

  try {
    // ① Perspective API 호출
    final result = await _perspectiveApi.analyzeComment(text);

    // ② CreatePostState.validationResults 업데이트
    state = state.copyWith(
      validationResults: {
        ...state.validationResults,
        FieldStyles.questionTitle: result,
      },
    );
  } catch (e) {
    // ③ 에러 처리 (네트워크 오류 등)
    print('Perspective API error: $e');
  }
}
```

#### 4. Perspective API Service 실제 호출

**파일 위치**: `lib/services/moderation/perspective_api_service.dart`

```dart
class PerspectiveApiService {
  final String apiKey;
  final Dio _dio;

  Future<PerspectiveResult> analyzeComment(String text) async {
    final url = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

    final requestBody = {
      'comment': {'text': text},
      'requestedAttributes': {
        'TOXICITY': {},
        'SEVERE_TOXICITY': {},
        'IDENTITY_ATTACK': {},
        'INSULT': {},
        'PROFANITY': {},
        'THREAT': {},
      },
      'languages': ['en'],  // ⚠️ 영어만 지원 (한국어 패키지 제거됨)
    };

    try {
      final response = await _dio.post(
        url,
        queryParameters: {'key': apiKey},
        data: requestBody,
      );

      return PerspectiveResult.fromJson(response.data);
    } on DioException catch (e) {
      // 네트워크 에러, API 에러 등
      throw PerspectiveApiException(e.message ?? 'Unknown error');
    }
  }
}
```

#### 5. PerspectiveResult 파싱

```dart
class PerspectiveResult {
  final double toxicityScore;
  final double severeToxicityScore;
  final double identityAttackScore;
  final double insultScore;
  final double profanityScore;
  final double threatScore;

  bool get isToxic =>
      toxicityScore > ModerationConfig.unifiedThreshold ||
      severeToxicityScore > ModerationConfig.unifiedThreshold ||
      identityAttackScore > ModerationConfig.unifiedThreshold ||
      insultScore > ModerationConfig.unifiedThreshold ||
      profanityScore > ModerationConfig.unifiedThreshold ||
      threatScore > ModerationConfig.unifiedThreshold;

  factory PerspectiveResult.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributeScores'] as Map<String, dynamic>;

    double getScore(String attribute) {
      final scoreData = attributes[attribute];
      if (scoreData == null) return 0.0;
      return (scoreData['summaryScore']['value'] as num).toDouble();
    }

    return PerspectiveResult(
      toxicityScore: getScore('TOXICITY'),
      severeToxicityScore: getScore('SEVERE_TOXICITY'),
      identityAttackScore: getScore('IDENTITY_ATTACK'),
      insultScore: getScore('INSULT'),
      profanityScore: getScore('PROFANITY'),
      threatScore: getScore('THREAT'),
    );
  }
}
```

### 전체 호출 Sequence Diagram

```
┌─────────┐      ┌───────────┐      ┌────────┐      ┌──────────┐      ┌────────────┐
│ User    │      │ TextField │      │ Notifier│      │ API Svc  │      │ Perspective│
└────┬────┘      └─────┬─────┘      └────┬───┘      └────┬─────┘      └─────┬──────┘
     │                 │                  │               │                  │
     │  타이핑 "hello" │                  │               │                  │
     ├────────────────>│                  │               │                  │
     │                 │  onChange        │               │                  │
     │                 ├─────────────────>│               │                  │
     │                 │                  │  updateTitle  │                  │
     │                 │                  │  (즉시 실행)  │                  │
     │                 │                  │<──────────────┤                  │
     │                 │                  │               │                  │
     │  타이핑 "world" │                  │               │                  │
     ├────────────────>│                  │               │                  │
     │                 │  onChange        │               │                  │
     │                 ├─────────────────>│               │                  │
     │                 │                  │  updateTitle  │                  │
     │                 │                  │  (즉시 실행)  │                  │
     │                 │                  │<──────────────┤                  │
     │                 │                  │               │                  │
     │  (500ms 대기 - Debounce)          │               │                  │
     │                 │                  │               │                  │
     │                 │                  │  validateTitle│                  │
     │                 │                  │  (Debounced)  │                  │
     │                 │                  ├──────────────>│                  │
     │                 │                  │               │  analyzeComment  │
     │                 │                  │               ├─────────────────>│
     │                 │                  │               │                  │
     │                 │                  │               │  HTTP POST       │
     │                 │                  │               │  /comments:analyze
     │                 │                  │               │                  │
     │                 │                  │               │<─────────────────┤
     │                 │                  │               │  PerspectiveResult
     │                 │                  │<──────────────┤                  │
     │                 │                  │  updateState  │                  │
     │                 │  리빌드 (ref.watch)                │                  │
     │                 │<─────────────────┤               │                  │
     │                 │  buildErrorMessage()             │                  │
     │                 │  (에러 메시지 표시)              │                  │
     │<────────────────┤                  │               │                  │
     │  🔴 에러 표시   │                  │               │                  │
     │                 │                  │               │                  │
```

### API 비용 최적화 전략

**Debounce 효과**:
- 사용자가 "hello world" 입력 시
- Without Debounce: 11회 API 호출 (각 글자마다)
- With Debounce (500ms): 1회 API 호출 (마지막 입력 후 500ms 후)
- **비용 절감**: ~90% (11회 → 1회)

**캐싱 전략** (향후 개선 가능):
```dart
// Future enhancement: Cache recent results
final cacheKey = md5(text).toString();
final cachedResult = await _cache.get<PerspectiveResult>(cacheKey);
if (cachedResult != null) return cachedResult;

// API 호출
final result = await _perspectiveApi.analyzeComment(text);

// 캐시 저장 (1시간 TTL)
await _cache.set(cacheKey, result, ttl: Duration(hours: 1));
```

### 에러 처리

**네트워크 오류**:
```dart
try {
  final result = await _perspectiveApi.analyzeComment(text);
} on DioException catch (e) {
  if (e.type == DioExceptionType.connectionTimeout) {
    // 연결 시간 초과
    print('Connection timeout');
  } else if (e.type == DioExceptionType.receiveTimeout) {
    // 응답 시간 초과
    print('Receive timeout');
  } else {
    // 기타 네트워크 오류
    print('Network error: ${e.message}');
  }

  // ✅ 에러 시 null 반환 (검증 스킵)
  return null;
}
```

**API Rate Limit**:
```dart
// Perspective API Free Tier: 1 QPS (Queries Per Second)
// Debounce로 충분히 커버됨 (500ms = 최대 2 QPS)
```

---

## ⚠️ 한국어 패키지 제거 경고

### 개요

**중요**: Perspective API는 **영어(en)만 지원**하도록 설정되어 있습니다. 한국어 언어 패키지는 제거되었으며, 한국어 텍스트 검증은 제한적입니다.

### 제거된 코드

**이전 설정** (August 22 이전):

```dart
// ❌ 삭제됨
final requestBody = {
  'comment': {'text': text},
  'requestedAttributes': { ... },
  'languages': ['ko', 'en'],  // 한국어 + 영어
};
```

**현재 설정** (August 22 이후):

```dart
// ✅ 영어만
final requestBody = {
  'comment': {'text': text},
  'requestedAttributes': { ... },
  'languages': ['en'],  // 영어만
};
```

### 제거 이유

1. **Perspective API 한계**:
   - 한국어 지원이 실험적이고 정확도 낮음
   - 영어 모델이 훨씬 정확함 (Google 공식 권장)

2. **Gemini AI 통합**:
   - 한국어 컨텍스트 이해는 Gemini AI가 담당
   - Perspective API는 영어 욕설/독성만 감지

3. **False Positive 감소**:
   - 한국어 모델이 정상 텍스트를 독성으로 오판하는 경우 많음
   - 영어만 사용 시 오판률 크게 감소

### 한국어 텍스트 검증 흐름

**2단계 검증 시스템**:

```
한국어 입력: "이 음식 맛없어"
    ↓
① Perspective API (영어만)
    → 독성 점수: 0.1 (낮음, 영어 욕설 없음)
    → 통과 ✅
    ↓
② Gemini AI (한국어 컨텍스트)
    → "부정적이지만 욕설/혐오 아님"
    → 통과 ✅
    ↓
제출 허용
```

**독성 콘텐츠 예시**:

```
한국어 + 영어 욕설: "This is f***ing 쓰레기"
    ↓
① Perspective API
    → 독성 점수: 0.9 (영어 욕설 감지)
    → 차단 ❌
    ↓
제출 불가
```

### 향후 개선 계획

**Phase 6-7: 한국어 검증 강화** (예정):

1. **Gemini AI 1차 검증**:
   ```dart
   // 한국어 컨텍스트 이해
   final geminiResult = await _geminiAi.moderateKoreanText(text);
   if (!geminiResult.isAppropriate) {
     return left(CreationFailure.inappropriateContent(
       geminiResult.reason,
     ));
   }
   ```

2. **Perspective API 2차 검증**:
   ```dart
   // 영어 욕설/독성 감지
   final perspectiveResult = await _perspectiveApi.analyzeComment(text);
   if (perspectiveResult.isToxic) {
     return left(CreationFailure.aiModerationFailed(...));
   }
   ```

3. **Custom Korean Profanity Filter**:
   ```dart
   // 한국어 욕설 사전 (로컬)
   final koreanProfanities = ['욕설1', '욕설2', '욕설3', ...];
   if (containsProfanity(text, koreanProfanities)) {
     return left(CreationFailure.profanityDetected());
   }
   ```

### 현재 제한 사항

| 케이스 | Perspective API | Gemini AI | 결과 |
|--------|----------------|-----------|------|
| **영어 욕설** | ✅ 감지 (정확도 95%+) | ✅ 감지 | 차단 |
| **한국어 욕설** | ❌ 감지 안 됨 | ✅ 감지 (컨텍스트) | 제한적 차단 |
| **혼합 욕설** | ⚠️ 영어만 감지 | ✅ 감지 | 부분 차단 |
| **정상 한국어** | ✅ 통과 | ✅ 통과 | 허용 |

### 개발자 가이드

**한국어 검증 추가 시** (Phase 6-7):

1. **Gemini AI Service 통합**:
   ```dart
   // lib/services/moderation/gemini_ai_service.dart
   class GeminiAiService {
     Future<GeminiModerationResult> moderateKoreanText(String text) async {
       final prompt = '''
       다음 한국어 텍스트가 부적절한지 판단해주세요:
       - 욕설, 혐오 발언, 위협, 성적 콘텐츠 포함 여부
       - 이유를 간단히 설명

       텍스트: "$text"
       ''';

       final response = await _gemini.generateContent([Content.text(prompt)]);
       return GeminiModerationResult.fromResponse(response);
     }
   }
   ```

2. **CreatePostNotifier 통합**:
   ```dart
   Future<void> validateTitle(String text) async {
     // ① Gemini AI (한국어)
     final geminiResult = await _geminiAi.moderateKoreanText(text);
     if (!geminiResult.isAppropriate) {
       state = state.copyWith(
         validationResults: {
           ...state.validationResults,
           FieldStyles.questionTitle: PerspectiveResult.fromGemini(geminiResult),
         },
       );
       return;
     }

     // ② Perspective API (영어)
     final perspectiveResult = await _perspectiveApi.analyzeComment(text);
     state = state.copyWith(
       validationResults: {
         ...state.validationResults,
         FieldStyles.questionTitle: perspectiveResult,
       },
     );
   }
   ```

### 정리

| 항목 | 현재 상태 | 향후 계획 |
|------|----------|----------|
| **Perspective API** | 영어만 (languages: ['en']) | 유지 |
| **Gemini AI** | 미통합 | Phase 6-7에서 한국어 검증 추가 |
| **한국어 욕설** | 제한적 감지 | Gemini + Custom Filter |
| **영어 욕설** | 정확한 감지 (95%+) | 유지 |
| **False Positive** | 낮음 (영어 전용) | Gemini로 더 낮춤 |

**개발 우선순위**:
1. ✅ **Phase 2**: Issue #14 수정 (canSubmit Moderation 체크)
2. 📋 **Phase 6**: Gemini AI 한국어 검증 통합
3. 📋 **Phase 7**: Custom Korean Profanity Filter

---

## 🛠 Riverpod으로 8월 22일 동작 복원하기

### 개요

August 22 코드는 `setState`로 `_model.absellected`를 내부 관리했지만, 현재 코드는 Riverpod Provider로 상태를 관리합니다. 이 섹션에서는 **UI/UX 동작은 August 22와 100% 동일하게 유지하면서 Riverpod 구조를 사용하는 방법**을 설명합니다.

### 핵심 원칙

1. ✅ **UI/UX 동작**: August 22와 100% 동일
2. ✅ **구현 방식**: Riverpod 3.x + Clean Architecture 유지
3. ✅ **Backend**: 현재 Firestore 구조 유지

**하이브리드 접근**:
- `absellected` → `MediaSelectionState`의 필드로 Riverpod Provider 관리
- `toggleBoxBVisibility()`, `removeAtIndex()` → `MediaSelectionNotifier` 메서드
- Plus 아이콘, 단일 모드 레이아웃 → August 22 동작 복원

---

### MediaSelectionState에 absellected 추가

**파일**: `lib/features/creation/presentation/providers/media/states/media_selection_state.dart`

**현재 상태 확인**:
```dart
@freezed
class MediaSelectionState with _$MediaSelectionState {
  const factory MediaSelectionState({
    @Default([]) List<File> selectedFilesA,
    @Default([]) List<File> selectedFilesB,
    @Default([]) List<String> uploadedUrlsA,
    @Default([]) List<String> uploadedUrlsB,
    // ... 기타 필드 ...

    // ❓ absellected 필드 있는지 확인
  }) = _MediaSelectionState;
}
```

**absellected 필드 추가** (없으면):
```dart
@freezed
class MediaSelectionState with _$MediaSelectionState {
  const factory MediaSelectionState({
    @Default([]) List<File> selectedFilesA,
    @Default([]) List<File> selectedFilesB,
    @Default([]) List<String> uploadedUrlsA,
    @Default([]) List<String> uploadedUrlsB,
    // ... 기타 필드 ...

    // ✅ absellected 추가
    @Default(false) bool absellected,  // false = A/B 모두 표시, true = A만 표시
  }) = _MediaSelectionState;
}
```

---

### MediaSelectionNotifier에 B박스 토글 메서드 추가

**파일**: `lib/features/creation/presentation/providers/media/media_selection_notifier.dart`

**toggleBoxBVisibility 메서드 추가**:
```dart
class MediaSelectionNotifier extends Notifier<MediaSelectionState> {
  // ... 기존 코드 ...

  /// B박스 토글
  ///
  /// August 22 동작:
  /// - Plus 아이콘 클릭 시 호출
  /// - absellected = false → B박스 표시
  void toggleBoxBVisibility() {
    state = state.copyWith(
      absellected: !state.absellected,
    );
  }
}
```

---

### removeAtIndex에 B박스 자동 숨김 로직 추가

**현재 코드**:
```dart
void removeAtIndex({required String box, required int index}) {
  if (box == 'A') {
    final updated = List<File>.from(state.selectedFilesA);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesA: updated);
  } else {
    final updated = List<File>.from(state.selectedFilesB);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesB: updated);
  }
}
```

**변경** (B박스 자동 숨김 로직 추가):
```dart
void removeAtIndex({required String box, required int index}) {
  if (box == 'A') {
    final updated = List<File>.from(state.selectedFilesA);
    updated.removeAt(index);
    state = state.copyWith(selectedFilesA: updated);
  } else {
    final updated = List<File>.from(state.selectedFilesB);
    updated.removeAt(index);

    // ✅ August 22 동작 복원: B박스 비었으면 자동 숨김
    state = state.copyWith(
      selectedFilesB: updated,
      absellected: updated.isEmpty ? true : state.absellected,
    );
  }
}
```

---

### selectImages에 자동 전환 로직 추가

**현재 코드**:
```dart
Future<void> selectImages({
  required String box,
  required List<AssetEntity> assets,
}) async {
  // ... 파일 변환 로직 ...

  if (box == 'A') {
    state = state.copyWith(selectedFilesA: files);
  } else {
    state = state.copyWith(selectedFilesB: files);
  }
}
```

**변경** (자동 전환 로직 추가):
```dart
Future<void> selectImages({
  required String box,
  required List<AssetEntity> assets,
}) async {
  // ... 파일 변환 로직 ...

  if (box == 'A') {
    state = state.copyWith(
      selectedFilesA: files,
      // ✅ August 22 동작: A박스 이미지 추가 + B박스 비었으면 자동 숨김
      absellected: state.selectedFilesB.isEmpty ? true : state.absellected,
    );
  } else {
    state = state.copyWith(
      selectedFilesB: files,
      // ✅ August 22 동작: B박스 이미지 추가하면 absellected = false
      absellected: files.isNotEmpty ? false : state.absellected,
    );
  }
}
```

---

### ImageSelectionWidget에서 absellected 사용

**현재 코드**:
```dart
class ImageSelectionWidget extends ConsumerStatefulWidget {
  final bool absellected;  // 부모 prop

  const ImageSelectionWidget({
    this.absellected = false,
    // ...
  });
}
```

**이슈**: `widget.absellected`는 부모 prop인데, MediaSelectionState의 `absellected`와 동기화 안 됨

**해결 방법 1**: ImageSelectionWidget에서 MediaSelectionState 읽기
```dart
@override
Widget build(BuildContext context) {
  final createPostState = ref.watch(createPostProvider);
  final mediaSelectionState = ref.watch(mediaSelectionProvider);

  // ✅ MediaSelectionState에서 absellected 읽기
  final absellected = mediaSelectionState.absellected;

  // ... 위젯 빌드 (widget.absellected 대신 absellected 사용)
}
```

**해결 방법 2**: 부모 위젯에서 MediaSelectionState의 absellected 전달
```dart
// 부모 위젯 (create_post_screen.dart 또는 유사)
@override
Widget build(BuildContext context) {
  final mediaSelectionState = ref.watch(mediaSelectionProvider);

  return ImageSelectionWidget(
    absellected: mediaSelectionState.absellected,  // ✅ Provider 상태 전달
    // ...
  );
}
```

**권장**: 해결 방법 1 (ImageSelectionWidget 내부에서 직접 읽기) - Clean Architecture 준수

---

### 전체 동작 플로우 검증

**시나리오 1: A박스에 이미지 추가**
```dart
// 1. selectImages(box: 'A', assets: [asset1])
// 2. MediaSelectionNotifier
state = state.copyWith(
  selectedFilesA: [file1],
  absellected: state.selectedFilesB.isEmpty ? true : state.absellected,
);
// 3. B박스 비어있으므로 absellected = true
// 4. ImageSelectionWidget 리빌드
// 5. showPlusIcon: box == 'A' && absellected → true ✅
// 6. _buildMediaBoxes() → if (absellected && isHorizontal) → 중앙 정렬 레이아웃 ✅
```

**시나리오 2: Plus 아이콘 클릭**
```dart
// 1. onPlusIconTap: () { ref.read(mediaSelectionProvider.notifier).toggleBoxBVisibility(); }
// 2. MediaSelectionNotifier.toggleBoxBVisibility()
state = state.copyWith(absellected: !state.absellected);
// 3. absellected = false
// 4. ImageSelectionWidget 리빌드
// 5. showPlusIcon: box == 'A' && absellected → false ✅ (Plus 숨김)
// 6. if (!absellected) ...[B박스] → B박스 표시 ✅
```

**시나리오 3: B박스 이미지 모두 삭제**
```dart
// 1. removeAtIndex(box: 'B', index: 0) (마지막 이미지)
// 2. MediaSelectionNotifier.removeAtIndex()
final updated = List<File>.from(state.selectedFilesB);
updated.removeAt(0);  // 빈 리스트
state = state.copyWith(
  selectedFilesB: updated,
  absellected: updated.isEmpty ? true : state.absellected,
);
// 3. absellected = true ✅
// 4. ImageSelectionWidget 리빌드
// 5. showPlusIcon: box == 'A' && absellected → true ✅ (Plus 다시 표시)
// 6. B박스 숨김 ✅
```

---

### 구현 체크리스트

#### MediaSelectionState 수정
- [ ] `@Default(false) bool absellected` 필드 추가
- [ ] `dart run build_runner build --delete-conflicting-outputs` 실행

#### MediaSelectionNotifier 수정
- [ ] `toggleBoxBVisibility()` 메서드 추가
- [ ] `removeAtIndex()` B박스 자동 숨김 로직 추가
- [ ] `selectImages()` 자동 전환 로직 추가

#### ImageSelectionWidget 수정
- [ ] `final absellected = mediaSelectionState.absellected;` 사용
- [ ] Plus 아이콘 조건: `showPlusIcon: box == 'A' && absellected`
- [ ] 단일 이미지 모드: `if (absellected && isHorizontal) { Center(...) }`
- [ ] Plus 아이콘 클릭: `ref.read(mediaSelectionProvider.notifier).toggleBoxBVisibility()`

#### 통합 테스트
- [ ] A박스 이미지 추가 → B박스 자동 숨김 확인
- [ ] Plus 클릭 → B박스 표시 확인
- [ ] B박스 이미지 모두 삭제 → 자동 숨김 확인
- [ ] 단일 이미지 모드 레이아웃 (중앙 정렬) 확인

---

## 🔟 100% 동일 검증 체크리스트

### Text Input Section

#### Question Title
- [ ] Component: `SimpleValidatedField` with `FieldStyles.questionTitle`
- [ ] Font Size: `30.0`
- [ ] Label Size: `30.0`
- [ ] Max Length: `60` (override to `100` in builder)
- [ ] Max Lines: `3`
- [ ] Border: `underline`, `Colors.black`, width `2.0`, radius `12.0`
- [ ] Container Padding: `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)`
- [ ] CharacterCountDisplay: `horizontalPadding: 22.0`

#### Description
- [ ] Component: `SimpleValidatedField` with `FieldStyles.description`
- [ ] Font Size: `20.0`
- [ ] Label Size: `25.0`
- [ ] Max Length: `200` (override to `2000` in builder)
- [ ] Max Lines: `null` (unlimited)
- [ ] Border: `underline`, `Colors.black`, width `2.0`, radius `12.0`
- [ ] Container Padding: `EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0)`
- [ ] CharacterCountDisplay: `horizontalPadding: 22.0`

#### Option A/B
- [ ] Component: `SimpleValidatedField` with `FieldStyles.textA/textB` (NOT TextFormField)
- [ ] Font Size: `15.0`
- [ ] Label Size: `20.0`
- [ ] Max Length: `20`
- [ ] Max Lines: `5` (NOT 2)
- [ ] Border: `underline`, `Colors.black`, width `2.0`, radius `12.0`
- [ ] Container Padding: `EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0)`
- [ ] Container Width: `400.0`
- [ ] Alignment: `AlignmentDirectional(-1.0, 0.0)`
- [ ] CharacterCountDisplay: `horizontalPadding: 32.0`

### Image Selection Section

- [ ] NO Section Label (`"A vs B 이미지 선택"` 제거됨)
- [ ] NO Container Horizontal Padding
- [ ] Box A Color: `AppTheme.of(context).primary` (NOT hardcoded)
- [ ] Box B Color: `AppTheme.of(context).secondary` (NOT hardcoded)
- [ ] Box Spacing (Horizontal): `8.0` (verify with Dimensions.smallPadding)
- [ ] Box Spacing (Vertical): `8.0` (verify with Dimensions.smallPadding)
- [ ] Box Width Calculation: `UnifiedBoxCalculator` (working)
- [ ] Box Height Calculation: `UnifiedBoxCalculator` (working)

### 🆕 A/B 박스 동작 검증

- [ ] Plus 아이콘 표시 조건: `box == 'A' && absellected` (August 22 동작)
- [ ] A박스에 이미지 추가 → B박스 자동 숨김 (absellected = true)
- [ ] Plus 아이콘 클릭 → B박스 표시 (absellected = false)
- [ ] B박스 이미지 모두 삭제 → 자동 숨김 + Plus 표시
- [ ] 단일 이미지 모드: A박스 중앙 정렬 (가로 이미지, absellected == true)
- [ ] MediaSelectionState.absellected 플래그 동작 확인

### 🆕 Moderation 검증 (Issue #14)

#### Perspective API 에러 표시 (이미 작동 중)
- [ ] Perspective API 검증 결과가 TextField 아래에 표시됨
- [ ] InputFieldBuilder.buildErrorMessage() 정상 작동 (August 22부터 현재까지)
- [ ] 독성 콘텐츠 입력 시 빨간색 에러 메시지 표시
- [ ] 에러 메시지 한국어 변환: CreationFailure.getUserMessage()
- [ ] ModerationConfig.unifiedThreshold (0.7) 및 severeThreshold (0.8) 적용

#### canSubmit Getter 검증 (Issue #14 Fix)
- [ ] `canSubmit` getter가 `formData.isValid` 체크
- [ ] `canSubmit` getter가 `!isLoading` 체크
- [ ] `canSubmit` getter가 `titleResult?.isToxic` 체크
- [ ] `canSubmit` getter가 `descResult?.isToxic` 체크
- [ ] `canSubmit` getter가 `textAResult?.isToxic` 체크
- [ ] `canSubmit` getter가 `textBResult?.isToxic` 체크 (단일 모드 제외)
- [ ] 독성 콘텐츠 입력 시 다음 버튼 비활성화 (canSubmit == false)
- [ ] 정상 콘텐츠 입력 시 다음 버튼 활성화 (canSubmit == true)

#### Debounce 동작
- [ ] 500ms Debounce로 API 호출 최적화 (~90% 비용 절감)
- [ ] 타이핑 중 API 호출 안 됨 (마지막 입력 후 500ms 대기)
- [ ] Debounce 완료 후 Perspective API 검증 실행

#### Edge Cases
- [ ] validationResults가 null인 경우 다음 버튼 활성화 (검증 전 상태)
- [ ] isLoading == true일 때 다음 버튼 비활성화
- [ ] 단일 모드 (isSingleMode == true)에서 textBResult 검증 건너뜀
- [ ] 여러 필드 동시 독성 시 모든 필드에 에러 표시 + 다음 버튼 비활성화
- [ ] 독성 콘텐츠 수정 후 정상화 시 다음 버튼 재활성화
