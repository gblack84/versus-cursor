# 📍 Router - 라우팅 시스템

> GoRouter 기반 선언적 라우팅 시스템

## 개요

앱의 모든 네비게이션과 라우팅을 관리하는 중앙 시스템입니다. GoRouter를 사용하여 선언적이고 타입 안전한 라우팅을 구현합니다.

## 구조

```
router/
├── router.dart              # GoRouter 메인 설정
├── routes.dart              # 라우트 경로 상수
├── route_params.dart        # 파라미터 직렬화
├── guards/                  # 라우트 가드
│   ├── auth_guard.dart     # 인증 체크
│   └── permission_guard.dart # 권한 체크
└── README.md
```

## 주요 기능

### 1. GoRouter 설정 (router.dart)

**역할**: 앱의 라우팅 시스템 초기화 및 설정

**주요 구성**:
- **initialLocation**: 앱 시작 시 기본 위치
- **refreshListenable**: 라우트 갱신 트리거 (authStateNotifier)
- **redirect**: 라우트 접근 제어 로직
- **routes**: 전체 라우트 트리 정의
  - ShellRoute: 네비게이션 셸 유지
  - authRoutes: 인증 관련 라우트
  - featureRoutes: 기능별 라우트
- **errorBuilder**: 404 등 에러 페이지

### 2. 라우트 정의 (routes.dart)

**역할**: 앱의 모든 라우트 경로 상수 관리

**라우트 카테고리**:
- **인증 라우트**:
  - splash: '/' - 스플래시 화면
  - login: '/login' - 로그인
  - signup: '/signup' - 회원가입
  - forgotPassword: '/forgot-password' - 비밀번호 찾기

- **메인 라우트** (ShellRoute 내부):
  - home: '/home' - 홈 화면
  - profile: '/profile' - 프로필
  - chat: '/chat' - 채팅 목록
  - notifications: '/notifications' - 알림

- **Feature 라우트**:
  - createPost: '/create-post' - 게시물 작성
  - postDetail: '/post/:id' - 게시물 상세
  - chatDetail: '/chat/:id' - 채팅 상세
  - userProfile: '/user/:userId' - 사용자 프로필

- **설정 라우트**:
  - settings: '/settings' - 설정 메인
  - privacy: '/settings/privacy' - 개인정보 설정
  - account: '/settings/account' - 계정 설정

### 3. 파라미터 직렬화 (route_params.dart)

**역할**: 라우트 파라미터 타입 변환 및 직렬화

**지원 타입**:
- **기본 타입**: int, double, String, bool
- **날짜/시간**: DateTime (millisecondsSinceEpoch 변환)
- **위치**: LatLng (위도,경도 문자열 변환)
- **Firestore**: DocumentReference (path 변환)
- **복합 데이터**: JSON (jsonEncode/jsonDecode)

**주요 메서드**:
- `serializeParam()`: 파라미터를 문자열로 변환
- `deserializeParam()`: 문자열을 원래 타입으로 복원

### 4. 인증 가드 (guards/auth_guard.dart)

**역할**: 라우트 접근 시 인증 상태 검증

**검증 로직**:
- 비로그인 상태 + 보호된 라우트 → 로그인 페이지로 리다이렉트
- 로그인 상태 + 인증 라우트 → 홈 페이지로 리다이렉트
- 정상 상태 → null 반환 (진행 허용)

**보호된 라우트**: 인증이 필요한 모든 라우트
**인증 라우트**: login, signup, forgotPassword 등

### 5. 권한 가드 (guards/permission_guard.dart)

**역할**: 사용자 권한에 따른 라우트 접근 제어

**권한 체크**:
- **관리자 전용** ('/admin'): role이 'admin'인 사용자만 접근
- **프리미엄 전용** ('/premium'): isPremium이 true인 사용자만 접근
- **권한 부족 시**: 홈 또는 구독 페이지로 리다이렉트

## 도메인 인터페이스 의존성 패턴

### Feature 라우트 격리 전략

라우터는 Feature의 구체 구현이 아닌 도메인 인터페이스만 의존하여 Feature 간 결합도를 최소화합니다.

#### 1. 라우트 인터페이스 정의
```dart
// features/common/domain/interfaces/route_handler.dart
abstract class IRouteHandler {
  String get routeName;
  String get routePath;
  Widget buildPage(GoRouterState state);
  bool canAccess(User? user);
}
```

#### 2. Feature별 라우트 구현
```dart
// features/posts/presentation/routes/post_routes.dart
class PostRouteHandler implements IRouteHandler {
  @override
  String get routeName => 'post_detail';
  
  @override
  String get routePath => '/post/:id';
  
  @override
  Widget buildPage(GoRouterState state) {
    final postId = state.pathParameters['id'];
    // DI로 필요한 의존성 해결
    final repository = getIt<IPostRepository>();
    return PostDetailPage(postId: postId);
  }
  
  @override
  bool canAccess(User? user) => true; // 공개 콘텐츠
}
```

#### 3. 라우터 통합
```dart
// app/router/router.dart
class AppRouter {
  final List<IRouteHandler> featureRoutes = [
    // DI에서 Feature 라우트 핸들러 가져오기
    getIt<IRouteHandler>(instanceName: 'posts'),
    getIt<IRouteHandler>(instanceName: 'chat'),
    getIt<IRouteHandler>(instanceName: 'profile'),
  ];
  
  GoRouter buildRouter() {
    return GoRouter(
      routes: [
        // Feature 라우트 동적 생성
        ...featureRoutes.map((handler) => GoRoute(
          name: handler.routeName,
          path: handler.routePath,
          builder: (context, state) => handler.buildPage(state),
          redirect: (context, state) {
            final user = getIt<AuthService>().currentUser;
            return handler.canAccess(user) ? null : '/login';
          },
        )),
      ],
    );
  }
}
```

#### 4. Feature 모듈 등록
```dart
// features/posts/di/post_module.dart
class PostModule {
  static void register() {
    // 라우트 핸들러 등록
    getIt.registerSingleton<IRouteHandler>(
      PostRouteHandler(),
      instanceName: 'posts',
    );
    
    // Feature 내부 의존성 등록
    getIt.registerLazySingleton<IPostRepository>(
      () => PostRepository(),
    );
  }
}
```

### 장점

1. **낮은 결합도**: 라우터는 Feature 구체 구현을 모름
2. **Feature 독립성**: 각 Feature가 자체 라우트 관리
3. **테스트 용이성**: Mock 라우트 핸들러 주입 가능
4. **동적 라우트**: Feature 활성/비활성화 쉬움
5. **순환 의존성 방지**: 인터페이스를 통한 의존성 역전

## 사용 방법

### 1. 네비게이션

**이동 방식**:
- `context.go()`: 스택 교체 (뒤로가기 불가)
- `context.push()`: 스택에 추가 (뒤로가기 가능)
- `context.pop()`: 이전 화면으로
- `context.replace()`: 현재 라우트 교체

### 2. 파라미터 전달

**전달 방식**:
- **Path 파라미터**: URL 경로에 포함 ('/user/${userId}')
- **Query 파라미터**: URL 쿼리 문자열 (?tab=posts&sort=recent)
- **Extra 데이터**: 복잡한 객체 전달 (직렬화 불필요)

### 3. 딥링크 처리

**딥링크 설정**:
- initialLocation에 딥링크 경로 설정
- 커스텀 스킴 처리 (versusspace://)
- 딥링크 파싱 로직 구현

### 4. Feature 라우트 통합

**Feature 라우트 추가 방법**:
```dart
// 1. Feature 모듈 등록 (main.dart)
await PostModule.register();
await ChatModule.register();
await ProfileModule.register();

// 2. 라우터 빌드
final router = AppRouter().buildRouter();

// 3. MaterialApp.router에 적용
MaterialApp.router(
  routerConfig: router,
)
```

## 마이그레이션 체크리스트

- [ ] 기존 Navigator.push 코드를 context.go로 변경
- [ ] MaterialPageRoute를 GoRoute로 변경
- [ ] 라우트 이름을 AppRoutes 상수로 통일
- [ ] 파라미터 전달 방식 통일
- [ ] 라우트 가드 적용
- [ ] 딥링크 테스트

## 주의사항

1. **ShellRoute 사용**: 하단 네비게이션 바가 유지되어야 하는 화면은 ShellRoute 내부에 정의
2. **파라미터 타입**: 복잡한 객체는 Extra로 전달, 단순 값은 Path/Query 파라미터 사용
3. **뒤로가기 처리**: GoRouter의 pop은 Navigator.pop과 동일하게 동작
4. **리다이렉트 성능**: redirect 콜백은 자주 호출되므로 가볍게 유지

---

*라우팅 시스템 문서 - Feature-First Architecture*