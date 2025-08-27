# 🎯 Agrred Select - 취미 및 관심사 선택 페이지

> Versus Space 앱의 사용자 온보딩 과정에서 취미와 관심사를 수집하는 페이지입니다. 사용자 맞춤형 콘텐츠 추천을 위한 중요한 정보를 수집합니다.

## 📋 개요

Agrred Select는 사용자가 자신의 취미와 관심사를 최대 8개까지 등록할 수 있는 온보딩 페이지입니다. 수집된 정보는 맞춤형 질문 추천과 사용자 매칭에 활용됩니다.

### 🎯 주요 목적
- **관심사 수집**: 사용자의 취미와 관심 분야 파악
- **맞춤 추천**: 수집된 데이터로 개인화된 콘텐츠 제공
- **사용자 프로파일링**: 유사 관심사 사용자 매칭
- **온보딩 완성**: 계정 설정의 마지막 단계

## 🏗️ 디렉토리 구조

```
/lib/pages/jop/agrred_select/
├── agrred_select_widget.dart     # 메인 위젯 UI (876줄)
├── agrred_select_model.dart      # 상태 관리 모델 (27줄)
└── README.md                      # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 903줄
- **파일 수**: 2개
- **주요 컴포넌트**: AgrredSelectWidget, AgrredSelectModel
- **의존성**: 13개 (Firebase Auth, AppTheme, Google Fonts 등)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_model`
- **예시**: `agrred_select_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `Model`
- **예시**: `AgrredSelectWidget`, `AgrredSelectModel`

### 라우팅
- **routeName**: snake_case (`'agrred_select'`)
- **routePath**: camelCase with slash (`'/hobbiesSelectCopy'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `hobbiesTag`, `hobbiesTextController`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. AgrredSelectWidget - 메인 UI 위젯 🎨

**사용자 관심사 수집을 위한 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'agrred_select';
static String routePath = '/hobbiesSelectCopy';
```

#### 주요 UI 구성
- **헤더 섹션**: 사용자 이름과 안내 메시지
- **입력 필드**: 취미/관심사 입력 (최대 20자)
- **추가 버튼**: 입력된 텍스트를 리스트에 추가
- **태그 리스트**: 추가된 관심사 표시 (삭제 가능)
- **팁 섹션**: 추천 관심사 예시
- **다음 버튼**: 온보딩 완료

### 2. 입력 시스템 📝

**TextFormField 기반의 관심사 입력 시스템입니다.**

#### 입력 필드 특징
```dart
TextFormField(
  controller: _model.hobbiesTextController,
  focusNode: _model.hobbiesFocusNode,
  maxLength: 20,  // 최대 20자 제한
  textCapitalization: TextCapitalization.words,  // 단어 첫글자 대문자
  autofocus: true,  // 페이지 진입 시 자동 포커스
)
```

#### 디바운싱 처리
- **지연 시간**: 2000ms
- **목적**: 불필요한 상태 업데이트 방지
- **구현**: EasyDebounce 패키지 사용

### 3. 관심사 관리 시스템 🏷️

**Firebase Firestore와 연동된 실시간 관심사 관리입니다.**

#### 추가 로직
```dart
// 8개 제한 체크
if ((currentUserDocument?.interests.toList() ?? []).length >= 8) {
  // 제한 도달 알림
} else {
  // Firestore 업데이트
  await currentUserReference!.update({
    'interests': FieldValue.arrayUnion([inputText])
  });
}
```

#### 삭제 로직
```dart
await currentUserReference!.update({
  'interests': FieldValue.arrayRemove([item])
});
```

### 4. 태그 디스플레이 시스템 🎯

**Wrap 위젯을 사용한 반응형 태그 표시입니다.**

#### 태그 UI 구성
- **컨테이너**: 둥근 모서리 (8px radius)
- **색상**: accent3 배경, tertiary 테두리
- **삭제 버튼**: X 아이콘 (15px)
- **레이아웃**: Wrap으로 자동 줄바꿈

### 5. AgrredSelectModel - 상태 관리 📊

**페이지 상태를 관리하는 모델 클래스입니다.**

```dart
class AgrredSelectModel extends AppModel<AgrredSelectWidget> {
  String hobbiesTag = '';  // 현재 입력된 텍스트
  FocusNode? hobbiesFocusNode;  // 포커스 관리
  TextEditingController? hobbiesTextController;  // 텍스트 컨트롤러
}
```

## 💡 사용 가이드

### 페이지 진입
```dart
context.pushNamed(AgrredSelectWidget.routeName);
```

### 관심사 추가 플로우
1. 텍스트 필드에 관심사 입력 (최대 20자)
2. "Add" 버튼 클릭 또는 Enter 키
3. Firestore `interests` 필드에 추가
4. 화면에 태그로 표시
5. 최대 8개까지 추가 가능

### 관심사 삭제 플로우
1. 태그의 X 버튼 클릭
2. Firestore에서 즉시 제거
3. UI 자동 업데이트 (StreamBuilder)

## 🎨 디자인 시스템

### 색상 스킴
| 요소 | 색상 | 용도 |
|------|------|------|
| **배경** | #ECECEC | 메인 배경 |
| **AppBar** | Colors.white | 상단 바 |
| **태그 배경** | accent3 | 관심사 태그 |
| **태그 테두리** | tertiary | 태그 경계선 |
| **버튼** | primaryText | 액션 버튼 |
| **비활성 버튼** | #646464 | 비활성 상태 |

### 텍스트 스타일
- **제목**: headlineMedium (GoogleFonts.plusJakartaSans)
- **본문**: bodyMedium (16px)
- **팁 텍스트**: 이탤릭체 + 언더라인
- **태그 텍스트**: bodyMedium

### 간격 및 패딩
| 위치 | 값 | 적용 영역 |
|------|-----|----------|
| **전체 패딩** | 16px | 좌우 여백 |
| **상단 여백** | 30px | AppBar 아래 |
| **태그 간격** | 4px spacing, 1px runSpacing | Wrap 레이아웃 |
| **태그 패딩** | 8px | 각 태그 내부 |

## 🚀 성능 최적화

### 디바운싱 전략
- 입력 필드에 2초 디바운싱 적용
- 불필요한 setState 호출 최소화
- 사용자 입력 완료 후 처리

### StreamBuilder 활용
- AuthUserStreamWidget으로 실시간 업데이트
- Firestore 변경사항 즉시 반영
- 캐시 활용으로 성능 향상

### 메모리 관리
- dispose()에서 컨트롤러 정리
- FocusNode 적절한 해제
- 메모리 누수 방지

## 📚 의존성

```dart
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_icon_button.dart';
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/core/app_widgets.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:google_fonts/google_fonts.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **필드 혼용 문제**: expertise와 interests 필드 일관성 개선 필요
2. **라우트 경로**: `/hobbiesSelectCopy` → 더 명확한 이름으로 변경
3. **Next 버튼**: 실제 네비게이션 구현 필요 (현재 print만)

### 우선순위 중간
4. **입력 검증**: 중복 관심사 체크
5. **추천 시스템**: 인기 관심사 제안 기능
6. **검색 기능**: 기존 관심사 목록에서 검색

### 우선순위 낮음
7. **애니메이션**: 태그 추가/삭제 애니메이션
8. **드래그 앤 드롭**: 태그 순서 변경 기능
9. **카테고리화**: 관심사 카테고리별 그룹핑

## 🐛 알려진 이슈

### 현재 이슈
1. **필드 불일치**: expertise 체크하지만 interests에 저장
   - Line 548-549: expertise 체크
   - Line 491: interests에 저장
2. **Next 버튼 미구현**: 클릭 시 동작 없음 (Line 829)
3. **하드코딩된 문자열**: 알림 메시지 하드코딩 (Line 471-473)

### 해결 방법
- expertise/interests 필드 통일 필요
- Next 버튼에 적절한 네비게이션 추가
- 다국어 지원을 위한 문자열 리소스화

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v2.0.0 | README 문서 전체 개편 (services 형식 적용) | AI Assistant |
| 2025-08-22 | v1.0.0 | 초기 문서 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [User Info Input](../user_info_input/README.md)
- [Firebase Auth 가이드](../../../auth/README.md)
- [Core 유틸리티](../../../core/README.md)

---

*이 문서는 Versus Space 앱의 관심사 선택 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*