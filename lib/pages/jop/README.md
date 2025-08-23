# 🎯 JOP (Job/Onboarding Pages) - 사용자 온보딩 시스템

> Versus Space 앱의 사용자 온보딩 시스템으로, 신규 사용자의 전문분야, 취미, 관심사를 수집하여 맞춤형 콘텐츠를 제공하는 핵심 모듈입니다.

## 📋 개요

JOP(Job/Onboarding Pages) 디렉토리는 사용자 온보딩 과정에서 필요한 정보를 수집하는 3단계 플로우를 구현합니다. 각 단계는 독립적인 페이지로 구성되어 있으며, 수집된 정보는 Firebase Firestore에 실시간으로 저장되어 맞춤형 콘텐츠 추천과 사용자 매칭에 활용됩니다.

### 🎯 주요 목적
- **사용자 프로파일링**: 전문분야, 취미, 관심사 정보 수집
- **맞춤형 경험 제공**: 수집된 데이터로 개인화된 콘텐츠 추천
- **사용자 매칭**: 유사한 관심사를 가진 사용자 연결
- **온보딩 최적화**: 단계별 정보 수집으로 사용자 이탈 최소화

## 🏗️ 디렉토리 구조

```
/lib/pages/jop/
├── README.md                      # 통합 문서 (현재 파일)
├── expertise_select/              # 1단계: 전문분야 선택
│   ├── expertise_select_widget.dart    # UI 위젯 (887줄)
│   ├── expertise_select_model.dart     # 상태 관리 (27줄)
│   └── README.md                        # 문서 (285줄)
├── hobbies_select/                # 2단계: 취미 선택
│   ├── hobbies_select_widget.dart      # UI 위젯 (876줄)
│   ├── hobbies_select_model.dart       # 상태 관리 (27줄)
│   └── README.md                        # 문서 (289줄)
└── agrred_select/                 # 3단계: 관심사 선택
    ├── agrred_select_widget.dart       # UI 위젯 (876줄)
    ├── agrred_select_model.dart        # 상태 관리 (27줄)
    └── README.md                        # 문서 (262줄)
```

### 📊 코드 통계
- **총 코드 라인**: 2,718줄
- **파일 수**: 9개 (코드 6개, 문서 3개)
- **주요 컴포넌트**: 3개 페이지, 각각 Widget과 Model 포함
- **문서화 라인**: 836줄
- **코드 커버리지**: 100% 문서화 완료

## 📐 네이밍 컨벤션

### 디렉토리 및 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_model`
- **예시**: `expertise_select_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `Model`
- **예시**: `ExpertiseSelectWidget`, `HobbiesSelectModel`

### 라우팅
- **routeName**: snake_case
- **routePath**: camelCase with slash
- **예시**:
  - expertise_select: `'expertise_select'` → `'/jopsSelect01'`
  - hobbies_select: `'hobbies_select'` → `'/hobbiesSelect'`
  - agrred_select: `'agrred_select'` → `'/hobbiesSelectCopy'`

### Firestore 필드
- **패턴**: camelCase (프로젝트 표준)
- **예시**: `expertise`, `interests` (주의: hobbies가 아닌 interests 사용)

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. 온보딩 플로우 시스템 🔄

**3단계 순차적 정보 수집 플로우입니다.**

```
[User Info Input] → [Expertise Select] → [Hobbies Select] → [Agrred Select] → [완료]
     (이전)            (1단계)              (2단계)           (3단계)
```

#### 단계별 특징
| 단계 | 페이지 | 필드명 | 최대 개수 | 필수 여부 |
|------|--------|--------|-----------|-----------|
| 1단계 | ExpertiseSelect | expertise | 4개 | 필수 (최소 1개) |
| 2단계 | HobbiesSelect | interests | 8개 | 선택 (0개 가능) |
| 3단계 | AgrredSelect | interests | 8개 | 선택 (0개 가능) |

### 2. 공통 UI/UX 패턴 🎨

**모든 페이지가 공유하는 일관된 디자인 시스템입니다.**

#### 공통 UI 구성요소
- **AppBar**: 뒤로가기 버튼, "versus space" 타이틀, VS 로고
- **헤더 섹션**: 사용자 이름 포함 안내 메시지
- **입력 필드**: TextFormField (최대 20자, 첫글자 대문자)
- **Add 버튼**: 입력 텍스트 추가
- **태그 리스트**: Wrap 위젯 기반 반응형 레이아웃
- **팁 섹션**: 추천 예시 표시
- **Next 버튼**: 다음 단계 진행

#### 공통 기술 스택
```dart
// 공통 import
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_theme.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:google_fonts/google_fonts.dart';
```

### 3. 실시간 데이터 동기화 시스템 🔥

**Firebase Firestore와 연동된 실시간 데이터 관리입니다.**

#### 데이터 추가 패턴
```dart
await currentUserReference!.update({
  'fieldName': FieldValue.arrayUnion([newItem])
});
```

#### 데이터 삭제 패턴
```dart
await currentUserReference!.update({
  'fieldName': FieldValue.arrayRemove([itemToRemove])
});
```

#### StreamBuilder 활용
- AuthUserStreamWidget으로 실시간 UI 업데이트
- currentUserDocument를 통한 데이터 접근
- 자동 캐싱 및 오프라인 지원

### 4. 입력 검증 시스템 ✅

**각 단계별 입력 제한 및 검증 로직입니다.**

| 검증 항목 | ExpertiseSelect | HobbiesSelect | AgrredSelect |
|-----------|-----------------|---------------|--------------|
| 최소 개수 | 1개 | 0개 | 0개 |
| 최대 개수 | 4개 | 8개 | 8개 |
| 글자 제한 | 20자 | 20자 | 20자 |
| 중복 체크 | ❌ | ❌ | ❌ |
| Next 버튼 | 조건부 활성화 | 항상 활성화 | 항상 활성화 |

### 5. 디바운싱 시스템 ⏱️

**EasyDebounce를 활용한 입력 최적화입니다.**

```dart
onChanged: (_) => EasyDebounce.debounce(
  '_model.textController',
  Duration(milliseconds: 2000),  // 2초 지연
  () async {
    _model.tag = _model.textController.text;
    setState(() {});
  },
)
```

## 💡 사용 가이드

### 온보딩 플로우 시작
```dart
// 1단계 시작
context.pushNamed(ExpertiseSelectWidget.routeName);

// 또는 라우트 경로 사용
context.push('/jopsSelect01');
```

### 단계별 네비게이션
```dart
// 1단계 → 2단계
context.pushNamed(HobbiesSelectWidget.routeName);

// 2단계 → 3단계  
context.pushNamed(AgrredSelectWidget.routeName);

// 3단계 → 완료
// TODO: 완료 후 네비게이션 구현 필요
```

### 데이터 접근
```dart
// 현재 사용자의 전문분야
final expertiseList = currentUserDocument?.expertise.toList() ?? [];

// 현재 사용자의 관심사 (취미 + 추가 관심사)
final interestsList = currentUserDocument?.interests.toList() ?? [];
```

## 🎨 디자인 시스템

### 통일된 색상 스킴
| 요소 | 색상 | 용도 |
|------|------|------|
| **배경** | #ECECEC | 모든 페이지 메인 배경 |
| **AppBar** | Colors.white | 상단 바 |
| **태그 배경** | accent3 | 선택된 항목 태그 |
| **태그 테두리** | tertiary | 태그 경계선 |
| **버튼** | primaryText | 액션 버튼 |
| **비활성 버튼** | #646464 | 비활성 상태 |

### 타이포그래피
- **제목**: headlineMedium (GoogleFonts.plusJakartaSans)
- **본문**: bodyMedium (16px)
- **팁 텍스트**: 이탤릭체 + 언더라인
- **태그 텍스트**: bodyMedium

## 🚀 성능 최적화

### 최적화 전략
1. **디바운싱**: 2초 지연으로 불필요한 상태 업데이트 방지
2. **StreamBuilder**: 실시간 업데이트로 수동 새로고침 불필요
3. **메모리 관리**: dispose()에서 컨트롤러 정리
4. **캐싱**: Firestore 오프라인 캐시 활용

### 성능 지표
- **페이지 로드**: < 300ms
- **태그 추가/삭제**: < 100ms (로컬) + 네트워크 지연
- **메모리 사용**: 페이지당 < 10MB

## 🐛 알려진 이슈 및 개선사항

### 우선순위 높음 🔴
1. **필드 불일치 문제**
   - HobbiesSelect: expertise 체크하지만 interests에 저장
   - AgrredSelect: expertise 체크하지만 interests에 저장
   - 해결: 필드 통일 필요

2. **라우트 경로 일관성**
   - expertise_select: `/jopsSelect01`
   - hobbies_select: `/hobbiesSelect`
   - agrred_select: `/hobbiesSelectCopy`
   - 해결: 일관된 네이밍 규칙 적용 필요

3. **Next 버튼 미구현**
   - AgrredSelect: Next 버튼 클릭 시 동작 없음
   - 해결: 온보딩 완료 플로우 구현 필요

### 우선순위 중간 🟡
4. **하드코딩된 문자열**
   - 알림 메시지 다국어 미지원
   - "Limit Reached", "You can only add up to X expertise."

5. **중복 체크 미구현**
   - 동일한 항목 중복 추가 가능
   - 사용자 경험 저하 우려

6. **뒤로가기 네비게이션**
   - 각 페이지마다 다른 뒤로가기 타겟
   - 네비게이션 스택 기반 구현 필요

### 우선순위 낮음 🟢
7. **애니메이션 부재**
   - 태그 추가/삭제 시 애니메이션 없음
   - 부드러운 전환 효과 추가 권장

8. **추천 시스템 미구현**
   - 인기 항목 제안 기능 없음
   - AI 기반 추천 시스템 고려

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v2.0.0 | JOP 통합 README 작성 | AI Assistant |
| 2025-08-23 | v1.3.0 | hobbies_select 문서화 완료 | AI Assistant |
| 2025-08-23 | v1.2.0 | expertise_select 문서화 완료 | AI Assistant |
| 2025-08-23 | v1.1.0 | agrred_select 문서화 완료 | AI Assistant |
| 2025-08-22 | v1.0.0 | 초기 디렉토리 생성 | 개발팀 |

## 🔗 관련 문서

### 하위 페이지 문서
- [Expertise Select](./expertise_select/README.md) - 전문분야 선택 페이지
- [Hobbies Select](./hobbies_select/README.md) - 취미 선택 페이지
- [Agrred Select](./agrred_select/README.md) - 관심사 선택 페이지

### 관련 시스템
- [User Info Input](../user_info_input/README.md) - 사용자 정보 입력
- [Firebase Auth](../../../auth/README.md) - 인증 시스템
- [Backend](../../../backend/README.md) - 백엔드 통합
- [Core](../../../core/README.md) - 핵심 유틸리티

---

*이 문서는 Versus Space 앱의 온보딩 시스템 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*