# 📦 내비게이션 시스템 (Navigation System)

> Versus Space 앱의 라우팅과 내비게이션을 관리하는 핵심 시스템

## 개요

`/lib/core/nav` 디렉토리는 GoRouter 기반의 선언적 내비게이션 시스템을 구현합니다. 인증 상태 관리, 페이지 전환, 딥링크 처리, 파라미터 직렬화 등 앱의 모든 내비게이션 관련 기능을 담당하는 중앙 라우팅 레이어입니다.

### 주요 특징
- 🚀 **GoRouter 기반**: Flutter의 공식 선언적 라우팅 패키지 사용
- 🔐 **인증 통합**: Firebase Auth와 완벽한 연동
- 📱 **ShellRoute 지원**: 하단 네비게이션 바 유지하며 페이지 전환
- 🔄 **상태 관리**: Provider 패턴으로 인증 상태 실시간 반영
- 📦 **파라미터 직렬화**: 복잡한 객체도 URL 파라미터로 전달 가능
- 🎯 **딥링크 지원**: 외부 링크로 직접 페이지 접근
- ⚡ **전환 효과**: 커스터마이징 가능한 페이지 전환 애니메이션

## 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `nav.dart`, `serialization_util.dart`
- ✅ **기능별 접미사**: `_util.dart`

### 클래스명
- ✅ **PascalCase 사용**: `AppStateNotifier`, `AppRoute`, `TransitionInfo`
- ✅ **명확한 역할 표현**: `NavigationExtensions`, `GoRouterExtensions`

### 필드 및 메서드
- ✅ **camelCase 사용**: `initialUser`, `showSplashImage`, `loggedIn`
- ✅ **private 필드**: `_instance`, `_redirectLocation`
- ✅ **boolean 접두사**: `isRootPage`, `hasTransition`, `shouldRedirect`

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 주요 구성요소

### 1. nav.dart (542줄)

#### AppStateNotifier (싱글톤 인증 상태 관리자)

**역할**: 앱 전체의 인증 상태와 내비게이션 리다이렉션 관리

```dart
class AppStateNotifier extends ChangeNotifier {
  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;
  bool notifyOnAuthChange = true;
  
  bool get loggedIn => user?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;
}
```

**주요 기능**:
- 사용자 로그인/로그아웃 상태 추적
- 스플래시 화면 표시 제어
- 인증 후 리다이렉션 처리
- 인증 변경 시 앱 리프레시 제어

#### GoRouter 설정

**역할**: 앱의 모든 라우트 정의 및 관리

```dart
GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: appStateNotifier,
  navigatorKey: appNavigatorKey,
  errorBuilder: (context, state) => StartPageWidget(),
  routes: [...],
  observers: [routeObserver, BotToastNavigatorObserver()],
);
```

**라우트 구조**:
1. **루트 라우트** ('/'): 로그인 상태에 따라 자동 리다이렉션
2. **ShellRoute**: 하단 네비게이션 바 유지 페이지들
   - HomePageWidget ('/home')
   - SearchPageWidget ('/search')
   - ProfilePageWidget ('/profile')
   - InPutPostImageWidget ('/inputPostImage')
   - ChatListWidget ('/chatList')
   - FriendsListWidget ('/friendsList')
   - ChatSearchWidget ('/chatSearch')
3. **일반 라우트**: 전체 화면 페이지들
   - LoginPageWidget ('/login')
   - CreateAccountWidget ('/createAccount')
   - ForgotPasswordWidget ('/forgotPassword')
   - UserInfoInputWidget ('/userInfoInput') - 인증 필요
   - ChatDetailWidgetV2 ('/chatDetail') - 인증 필요
   - 기타 20개 이상의 페이지

#### AppRoute 클래스

**역할**: 라우트 설정을 캡슐화하고 인증 체크 자동화

```dart
class AppRoute {
  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, AppParameters) builder;
  
  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(...)
}
```

**특징**:
- 인증 필요 페이지 자동 체크
- 비동기 파라미터 로딩 지원
- 커스텀 페이지 전환 효과

#### NavigationExtensions

**역할**: BuildContext에 편리한 내비게이션 메서드 추가

```dart
extension NavigationExtensions on BuildContext {
  void goNamedAuth(String name, bool mounted, {...})
  void pushNamedAuth(String name, bool mounted, {...})
  void safePop()
}
```

**제공 메서드**:
- `goNamedAuth`: 인증 체크 후 페이지 이동
- `pushNamedAuth`: 인증 체크 후 페이지 푸시
- `safePop`: 안전한 뒤로가기 (스택이 비면 홈으로)

#### TransitionInfo

**역할**: 페이지 전환 애니메이션 설정

```dart
class TransitionInfo {
  final bool hasTransition;
  final Duration duration;
  
  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}
```

**기본 설정**:
- 전환 효과 비활성화 (즉시 전환)
- 활성화 시 300ms 페이드 효과

### 2. serialization_util.dart (270줄)

#### 직렬화 헬퍼 함수

**지원 타입**:
- 기본 타입: int, double, String, bool
- 날짜/시간: DateTime, DateTimeRange
- ~~위치: LatLng, AppPlace~~ ❌ **미사용 - 제거 필요**
- 색상: Color
- 파일: AppUploadedFile
- Firebase: DocumentReference, Document
- JSON 객체

**문제점**:
- ❌ **미사용 코드**: AppPlace와 LatLng 타입 처리 (line 16-24, 73-78, 111-144)
- ❌ **임시 import**: `/core_exports.dart` 사용 (line 6)
- ⚠️ **책임 과다**: 270줄에 13가지 타입 처리
- ⚠️ **Feature 의존성**: app/models의 미사용 모델에 의존

**직렬화 함수**:
```dart
String? serializeParam(dynamic param, ParamType paramType, {bool isList = false})
```

**역직렬화 함수**:
```dart
dynamic deserializeParam<T>(String? param, ParamType paramType, bool isList, 
  {List<String>? collectionNamePath})
```

#### 특수 직렬화 처리

**DocumentReference 직렬화**:
```dart
String _serializeDocumentReference(DocumentReference ref) {
  // 컬렉션 경로를 | 구분자로 연결
  // 예: "users|userId123|posts|postId456"
}
```

**DateTimeRange 직렬화**:
```dart
String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  // 시작과 끝 타임스탬프를 | 구분자로 연결
  // 예: "1625097600000|1625184000000"
}
```

#### 리팩토링 필요 사항

**분리 계획**:
```
serialization/
├── base_serializer.dart      # 기본 타입 (int, double, String, bool, DateTime, JSON)
├── firebase_serializer.dart  # Firebase 타입 (DocumentReference, Document)
├── file_serializer.dart     # 파일 타입 (AppUploadedFile) 
├── ui_serializer.dart       # UI 타입 (Color, DateTimeRange)
└── param_type.dart          # 타입 enum 정의
```

**제거할 코드**:
- `placeToString()`, `placeFromString()` - AppPlace 미사용
- `latLngFromString()` - LatLng 미사용
- ParamType.LatLng, ParamType.AppPlace enum 값

## 사용 예시

### 1. 페이지 이동

```dart
// 일반 페이지 이동
context.goNamed(HomePageWidget.routeName);

// 인증 체크 후 이동
context.goNamedAuth(
  UserInfoInputWidget.routeName, 
  mounted,
  ignoreRedirect: false,
);

// 파라미터와 함께 이동
context.pushNamed(
  ChatDetailWidgetV2.routeName,
  extra: {'chatDocument': chatModel},
);
```

### 2. 안전한 뒤로가기

```dart
// 스택이 비면 홈으로 이동
context.safePop();
```

### 3. 파라미터 직렬화

```dart
// 복잡한 객체 직렬화
final serialized = serializeParam(
  documentRef, 
  ParamType.DocumentReference,
);

// URL 파라미터로 전달
context.pushNamed(
  'detailPage',
  queryParameters: {'docRef': serialized},
);
```

### 4. 인증 상태 감지

```dart
// Provider로 인증 상태 감지
Consumer<AppStateNotifier>(
  builder: (context, appState, _) {
    if (appState.loggedIn) {
      return HomePageWidget();
    }
    return LoginPageWidget();
  },
)
```

## 내비게이션 플로우

### 앱 시작 플로우
```
1. 앱 실행
2. 스플래시 화면 표시 (showSplashImage: true)
3. Firebase Auth 초기화
4. 사용자 상태 확인
5. 로그인 상태에 따라:
   - 로그인됨: /home으로 이동
   - 로그아웃: /startPage 유지
6. 스플래시 화면 숨기기
```

### 인증 필요 페이지 접근 플로우
```
1. requireAuth: true 페이지 접근 시도
2. AppRoute.toRoute()에서 인증 체크
3. 로그인 안 됨:
   - 현재 URL을 _redirectLocation에 저장
   - /startPage로 리다이렉션
4. 로그인 후:
   - _redirectLocation으로 자동 이동
   - _redirectLocation 클리어
```

### ShellRoute 내비게이션
```
1. MainNavigationShell 유지
2. 하단 네비게이션 바로 페이지 선택
3. ShellRoute 내부에서만 페이지 전환
4. 애니메이션 없이 즉시 전환
5. 스택 관리는 GoRouter가 자동 처리
```

## 성능 최적화

### 1. 전환 애니메이션 최적화
- 기본값: 애니메이션 없음 (즉시 전환)
- 필요 시에만 페이드 효과 적용
- Duration.zero로 불필요한 대기 제거

### 2. 비동기 파라미터 로딩
- FutureBuilder로 파라미터 로딩 중 화면 표시
- 병렬 로딩으로 대기 시간 최소화
- 실패 시 null 처리로 앱 크래시 방지

### 3. 메모리 관리
- 싱글톤 패턴으로 AppStateNotifier 인스턴스 제한
- RouteObserver로 불필요한 위젯 해제
- BotToast로 효율적인 토스트 메시지 관리

## 트러블슈팅

### 자주 발생하는 문제

#### 1. 인증 후 리다이렉션 실패
```dart
// 원인: notifyOnAuthChange가 false
// 해결: 인증 후 명시적으로 true 설정
appStateNotifier.updateNotifyOnAuthChange(true);
```

#### 2. 파라미터 직렬화 에러
```dart
// 원인: 지원하지 않는 타입
// 해결: ParamType enum에 정의된 타입만 사용
// 또는 JSON으로 변환 후 전달
final jsonParam = json.encode(complexObject);
serializeParam(jsonParam, ParamType.JSON);
```

#### 3. 딥링크 동작 안 함
```dart
// 원인: 라우트 경로 불일치
// 해결: AppRoute의 path와 정확히 일치하는지 확인
// 대소문자 구분 주의
```

## 보안 고려사항

### 1. 인증 체크
- requireAuth: true로 보호된 페이지 자동 인증 체크
- 미인증 사용자는 로그인 페이지로 강제 리다이렉션
- 인증 토큰 만료 시 자동 로그아웃 처리

### 2. 파라미터 검증
- deserializeParam에서 타입 안전성 보장
- try-catch로 파싱 에러 처리
- null 체크로 잘못된 파라미터 방어

### 3. URL 보안
- DocumentReference는 ID만 직렬화 (민감 정보 제외)
- 파라미터 인코딩으로 injection 공격 방지

## 테스팅

### 단위 테스트
```dart
testWidgets('인증 상태 변경 테스트', (tester) async {
  final appState = AppStateNotifier.instance;
  
  expect(appState.loggedIn, false);
  
  appState.update(mockUser);
  
  expect(appState.loggedIn, true);
});
```

### 통합 테스트
```dart
testWidgets('인증 필요 페이지 리다이렉션', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 로그아웃 상태에서 보호된 페이지 접근
  router.pushNamed(UserInfoInputWidget.routeName);
  await tester.pumpAndSettle();
  
  // 로그인 페이지로 리다이렉션 확인
  expect(find.byType(StartPageWidget), findsOneWidget);
});
```

## 성능 지표

### 목표 성능
- **페이지 전환**: <16ms (60fps 유지)
- **파라미터 직렬화**: <10ms
- **인증 체크**: <5ms
- **딥링크 처리**: <100ms

### 모니터링
```dart
// 라우트 성능 측정
final stopwatch = Stopwatch()..start();
context.goNamed(targetPage);
print('Navigation time: ${stopwatch.elapsedMilliseconds}ms');
```

## 변경 이력

### v2.0.0 (2025-08-22)
- GoRouter 기반 내비게이션 시스템 문서화
- 542줄 nav.dart, 270줄 serialization_util.dart 분석
- ShellRoute 구조 및 인증 플로우 상세 설명

### v1.5.0 (2025-07-25)
- ShellRoute 도입으로 하단 네비게이션 바 구현
- MainNavigationShell 통합

### v1.4.0 (2025-07-03)
- FlutterFlow 의존성 제거
- 네이티브 Flutter 코드로 마이그레이션

### v1.3.0 (2025-06-15)
- 전환 애니메이션 최적화
- hasTransition: false 기본값 설정

### v1.2.0 (2025-06-01)
- 비동기 파라미터 로딩 지원 추가
- AppParameters 클래스 구현

### v1.1.0 (2025-05-15)
- 파라미터 직렬화 시스템 구축
- 모든 ParamType 지원

### v1.0.0 (2025-05-01)
- 초기 GoRouter 기반 내비게이션 구현
- AppStateNotifier 인증 상태 관리

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-22  
**관리**: Versus Space 개발팀