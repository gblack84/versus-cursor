# Common Presentation Utils

## 📋 개요
UI 레이어에서 공통으로 사용되는 유틸리티 함수, 확장 메서드, 헬퍼 클래스들을 관리합니다.

## 🎯 역할
- **UI 헬퍼 함수**: 날짜 포맷팅, 숫자 포맷팅, 색상 변환 등
- **위젯 확장 메서드**: 위젯에 추가 기능 제공
- **애니메이션 유틸리티**: 공통 애니메이션 효과 및 트랜지션
- **반응형 헬퍼**: 화면 크기에 따른 반응형 로직
- **내비게이션 헬퍼**: 라우팅 및 화면 전환 유틸리티

## 📁 파일 구조
```
presentation/
└── utils/
    # Core에서 이동할 파일
    ├── app_utils.dart              # from /lib/core/
    ├── app_animations.dart         # from /lib/core/
    
    # 새로 구현할 구조
    ├── formatters/
    │   ├── date_formatter.dart
    │   ├── number_formatter.dart
    │   └── text_formatter.dart
    ├── extensions/
    │   ├── context_extensions.dart
    │   ├── widget_extensions.dart
    │   └── string_extensions.dart
    ├── animations/
    │   ├── animation_controller.dart
    │   ├── page_transitions.dart
    │   └── animated_effects.dart
    ├── responsive/
    │   ├── responsive_builder.dart
    │   ├── breakpoints.dart
    │   └── screen_utils.dart
    └── navigation/
        ├── navigation_helper.dart
        └── route_observer.dart
```

## 🚀 마이그레이션 대상

### 1. 포매터 (Formatters)

#### DateFormatter
**역할**: 날짜 및 시간 포맷팅 유틸리티

**주요 메서드**:
- `format(DateTime?, {format, locale})`: 날짜를 지정된 포맷으로 변환
- `relative(DateTime?, {locale})`: 상대 시간 포맷 (예: 5분 전)
- `relativeShort(DateTime?, {locale})`: 짧은 상대 시간 포맷 (예: 5분)
- `chatTime(DateTime?)`: 채팅 시간 포맷
- `postTime(DateTime?)`: 게시물 시간 포맷

**지원 로케일**: en, de, ko (각각 일반/짧은 버전)

#### NumberFormatter
**역할**: 숫자 포맷팅 유틸리티

**포맷 타입**:
- `decimal`: 십진수 포맷
- `percent`: 백분율 포맷
- `scientific`: 과학적 표기법
- `compact`: 간단한 포맷 (K, M)
- `compactLong`: 긴 간단한 포맷
- `currency`: 통화 포맷
- `custom`: 사용자 정의 포맷

**특수 메서드**:
- `likes(count)`: 좋아요 수 포맷 (1.2K, 3.4M)
- `views(count)`: 조회수 포맷 (만, 억 단위)
- `percentage(value, {decimals})`: 백분율 포맷
- `votes(votesA, votesB)`: 투표 비율 포맷

#### TextFormatter
**역할**: 텍스트 처리 및 포맷팅 유틸리티

**주요 메서드**:
- `truncate(text, maxLength, {suffix})`: 텍스트 자르기
- `capitalize(text)`: 첫 글자 대문자
- `capitalizeWords(text)`: 각 단어 첫 글자 대문자
- `extractHashtags(text)`: 해시태그 추출
- `extractMentions(text)`: 멘션 추출
- `extractUrls(text)`: URL 추출
- `highlightSearch(text, query, {styles})`: 검색어 하이라이트

### 2. 확장 메서드 (Extensions)

#### ContextExtensions
**역할**: BuildContext 확장 메서드

**테마 접근**:
- `theme`, `textTheme`, `colorScheme`

**MediaQuery 접근**:
- `screenSize`, `screenWidth`, `screenHeight`
- `padding`, `viewInsets`, `viewPadding`
- `safeAreaTop`, `safeAreaBottom`

**디바이스 타입**:
- `isMobile`, `isTablet`, `isDesktop`
- `isPortrait`, `isLandscape`
- `isKeyboardVisible`, `keyboardHeight`

**UI 헬퍼**:
- `showSnackBar(message, {duration, action})`
- `showAlertDialog({title, message, actions})`
- `showBottomSheet({child, options})`

#### WidgetExtensions
**역할**: Widget 확장 메서드

**레이아웃**:
- `paddingAll()`, `paddingSymmetric()`, `paddingOnly()`
- `marginAll()`, `marginSymmetric()`
- `center()`, `expanded()`, `flexible()`

**가시성**:
- `visible(bool)`, `opacity(double)`

**인터랙션**:
- `onTap()`, `onLongPress()`

**애니메이션**:
- `fadeIn()`, `slideIn()`, `scaleIn()`

### 3. 애니메이션 유틸리티 (Animations)

#### AnimationController
**역할**: 애니메이션 관리 및 제어

**AnimationTrigger**:
- `onPageLoad`: 페이지 로드 시 자동 실행
- `onActionTrigger`: 액션 트리거 시 실행

**AnimationInfo**:
- `trigger`: 애니메이션 트리거 타입
- `effectsBuilder`: Effect 리스트 생성 함수
- `loop`: 반복 여부
- `reverse`: 역방향 재생 여부
- `applyInitialState`: 초기 상태 적용 여부

**AnimationManager**:
- `createAnimation()`: 애니메이션 생성
- `setupAnimations()`: 여러 애니메이션 설정
- `animateOnPageLoad()`: 페이지 로드 애니메이션
- `animateOnActionTrigger()`: 액션 트리거 애니메이션

**마이그레이션 커맨드**:
```bash
git mv lib/core/app_animations.dart lib/features/common/presentation/utils/animations/animation_controller.dart
```

### 4. 반응형 유틸리티 (Responsive)

#### ResponsiveBuilder
**역할**: 반응형 UI 빌더

**DeviceType**:
- `mobile`: < 600px
- `tablet`: 600px - 1024px
- `desktop`: >= 1024px

**사용 방법**:
- 개별 위젯 제공: `mobile`, `tablet`, `desktop` 프로퍼티
- 빌더 함수: `builder(context, deviceType)`
- 헬퍼 메서드: `isMobile()`, `isTablet()`, `isDesktop()`
- 값 선택: `value(context, {mobile, tablet, desktop})`

#### ScreenUtils
**역할**: 화면 크기 기반 유틸리티

**주요 기능**:
- 화면 크기 계산 블록 (100분할)
- Safe area 고려한 크기 계산
- 반응형 폰트 크기: `fontSize(size)`
- 반응형 너비: `width(percentage)`
- 반응형 높이: `height(percentage)`
- 반응형 패딩: `paddingAll()`, `paddingSymmetric()`

### 5. 내비게이션 유틸리티 (Navigation)

#### NavigationHelper
**역할**: 고급 내비게이션 기능

**주요 메서드**:
- `pushAndRemoveAll()`: 스택 초기화 후 이동
- `popUntilAndPush()`: 특정 화면까지 팝 후 푸시
- `popWithResult()`: 결과와 함께 팝
- `navigateAfterDelay()`: 딜레이 후 네비게이션
- `navigateIf()`: 조건부 네비게이션
- `navigateWithAuth()`: 인증 체크 후 네비게이션

#### RouteObserver
**역할**: 라우트 변경 감지

**RouteAware mixin**:
- `subscribeToRouteObserver()`: 옵저버 구독
- `unsubscribeFromRouteObserver()`: 구독 해제
- 라이프사이클 콜백: `didPush()`, `didPop()`, `didPushNext()`, `didPopNext()`

## 🧪 테스트 전략

### 유닛 테스트
- 포매터 정확성 테스트
- 확장 메서드 동작 테스트
- 애니메이션 트리거 테스트
- 반응형 브레이크포인트 테스트

### 테스트 케이스
- DateFormatter: 상대 시간, 채팅 시간, 포스트 시간
- NumberFormatter: 좋아요, 조회수, 투표 비율
- TextFormatter: 텍스트 자르기, 해시태그 추출
- ResponsiveBuilder: 디바이스 타입 감지

## ✅ 마이그레이션 체크리스트

### Phase 1: 포매터
- [ ] DateFormatter 구현
- [ ] NumberFormatter 구현
- [ ] TextFormatter 구현

### Phase 2: 확장 메서드
- [ ] ContextExtensions 구현
- [ ] WidgetExtensions 구현
- [ ] StringExtensions 구현

### Phase 3: 애니메이션
- [ ] AnimationController 마이그레이션
- [ ] PageTransitions 구현
- [ ] AnimatedEffects 구현

### Phase 4: 반응형
- [ ] ResponsiveBuilder 구현
- [ ] Breakpoints 구현
- [ ] ScreenUtils 구현

### Phase 5: 내비게이션
- [ ] NavigationHelper 구현
- [ ] RouteObserver 마이그레이션

### Phase 6: 테스트
- [ ] 유닛 테스트 작성
- [ ] 통합 테스트 작성

## 📝 사용 가이드

### 포매터 사용
```dart
// 날짜 포맷
Text(DateFormatter.relative(post.createdAt));
Text(DateFormatter.chatTime(message.sentAt));

// 숫자 포맷
Text(NumberFormatter.likes(post.likeCount));
Text(NumberFormatter.votes(post.votesA, post.votesB));

// 텍스트 포맷
Text(TextFormatter.truncate(description, 100));
```

### 확장 메서드 사용
```dart
// Context extensions
context.showSnackBar('저장되었습니다');
final width = context.screenWidth;

// Widget extensions
Container()
  .paddingAll(16)
  .marginSymmetric(horizontal: 8)
  .fadeIn()
  .onTap(() => print('Tapped'));
```

### 반응형 사용
```dart
// ResponsiveBuilder
ResponsiveBuilder(
  mobile: MobileLayout(),
  tablet: TabletLayout(),
  desktop: DesktopLayout(),
);

// Responsive value
final padding = Responsive.value(
  context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

## 🔗 관련 문서
- [Common Widgets Documentation](../widgets/README.md)
- [Design System Documentation](../design_system/README.md)
- [Common Feature Architecture](../../README.md)