# 🧪 TestPageSelect - 테스트 페이지 네비게이션 허브

## 📋 개요

개발 및 테스트를 위한 중앙 네비게이션 허브 페이지입니다. 여러 페이지로 빠르게 이동할 수 있는 버튼들을 제공하여 개발 중 기능 테스트와 페이지 접근을 용이하게 합니다. **프로덕션 환경에서는 제거되어야 할 테스트 전용 페이지입니다.**

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`TestpageSelectWidget`, `TestpageSelectModel`)
- **라우트명**: lowerCamelCase (`routeName = 'testpageSelect'`)
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
testpage_select/
├── testpage_select_widget.dart    # 테스트 페이지 UI (824줄)
├── testpage_select_model.dart     # 상태 관리 (13줄)
└── README.md                       # 문서 파일
```

## 📱 기능

### 주요 컴포넌트
- **네비게이션 버튼 그룹**: 여러 페이지로 이동하는 버튼들
- **알림 테스트**: 투표 알림 오버레이 테스트
- **AppBar 통합**: 알림 아이콘 및 브랜드 로고

### 네비게이션 타겟

#### 인증 관련 페이지
- **Login** (`LoginPageWidget`): 로그인 페이지
- **Create Account** (`CreateAccountWidget`): 계정 생성
- **Forgot Password** (`ForgotPasswordWidget`): 비밀번호 찾기

#### 온보딩 페이지  
- **User Info** (`UserInfoInputWidget`): 사용자 정보 입력
- **Job Select** (`ExpertiseSelectWidget`): 전문분야 선택

#### 테스트 페이지
- **Test Algolia** (`TestalgoriaWidget`): Algolia 검색 테스트
- **Start** (`StartPageWidget`): 시작 페이지
- **Image** (`InPutPostImageWidget`): 이미지 업로드
- **투표테스트**: 투표 알림 오버레이 테스트

## 💻 코드 분석

### TestpageSelectWidget
```dart
static String routeName = 'testpageSelect';
static String routePath = '/testpageSelect';

// 투표 알림 테스트
VotingOverlay.showVotingNotification(
  context,
  question: '어떤 스마트폰을 선호하시나요?',
  optionA: 'iPhone 15 Pro',
  optionB: 'Galaxy S24 Ultra',
  // ...
);
```

### UI 구성
- **배경색**: `Color(0xFFECECEC)` (연한 회색)
- **AppBar**: 흰색 배경, VS 로고 포함
- **버튼 스타일**: 
  - Primary 색상 버튼 (기능 페이지)
  - 회색 버튼 (비활성)
  - 빨간색 버튼 (투표 테스트)

### 레이아웃 구조
```dart
Column(
  children: [
    // Hello World 타이틀
    Text('Hello World'),
    
    // 첫 번째 버튼 그룹 (인증)
    Wrap(children: [login, create_ac, forgot_ps, ...]),
    
    // 두 번째 버튼 그룹 (테스트)
    Wrap(children: [testalgolia, start]),
    
    // 세 번째 버튼 그룹 (기타)
    Wrap(children: [phonelogin, image, 투표테스트, ...])
  ]
)
```

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 값**: 
   - 고정 높이 `307.0`, `35.0`
   - 고정 너비 `521.0`
   - 하드코딩된 색상값

2. **중복 코드**:
   - 버튼 스타일 반복 (50번 이상)
   - GoogleFonts 설정 중복
   - Wrap 위젯 설정 반복

3. **미완성 기능**:
   - phonelogin 버튼 print만 출력
   - 마지막 Button 기능 없음

4. **i18n 키 사용**:
   - 일부는 i18n 키 사용
   - 일부는 하드코딩된 한글 ('투표테스트')

## 🔄 대체 구현

### 프로덕션 네비게이션
```dart
// 실제 앱 네비게이션
/lib/navigation/          # 네비게이션 시스템
/lib/components/drawer/   # 드로어 메뉴
/lib/components/tab_bar/  # 탭 네비게이션
```

### 개발 도구
```dart
// Flutter DevTools 사용
flutter inspector        # 위젯 트리 검사
flutter navigator        # 라우트 디버깅
```

## 📊 통계

- **위젯 파일**: 824줄 (매우 큼)
- **모델 파일**: 13줄 (최소)
- **상태**: 🟡 개발용 (테스트 전용)
- **버튼 수**: 13개 페이지 연결
- **중복 코드**: 약 60%

## ⚠️ 주의사항

> **경고**: 이 페이지는 개발/테스트 전용입니다.
> 프로덕션 빌드에서는 반드시 제거되어야 합니다.

### 보안 위험
- 모든 페이지에 직접 접근 가능
- 인증 우회 가능
- 테스트 데이터 노출

### 권장 사항
- ✅ 개발 환경에서만 활성화
- ✅ 조건부 컴파일 사용
- ✅ 프로덕션 빌드에서 제외
- ✅ 환경 변수로 제어

## 🗑️ 제거 계획

### Phase 1: 조건부 활성화
```dart
// 개발 모드에서만 표시
if (kDebugMode) {
  // TestpageSelect 라우트 등록
}
```

### Phase 2: 프로덕션 제외
```dart
// 빌드 설정에서 제외
flutter build apk --dart-define=EXCLUDE_TEST_PAGES=true
```

### Phase 3: 완전 제거
- **타겟**: 정식 출시 전
- **영향도**: 낮음 (독립적 페이지)
- **대체**: Flutter DevTools 사용

## 📝 변경 이력
- 2025-08-24: 문서화 완료
- 2025-08-22: 초기 생성

---

*이 페이지는 개발 테스트 전용이며, 프로덕션 환경에서는 제거되어야 합니다.*
