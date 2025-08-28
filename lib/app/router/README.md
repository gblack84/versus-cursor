# 🚦 App Router 레이어

> Feature-First Architecture의 라우팅 및 네비게이션 시스템  
> 최종 업데이트: 2025-08-27 | 버전: 2.0.0

## 📋 개요

App Router는 Versus Space 애플리케이션의 모든 네비게이션과 라우팅을 관리합니다.
GoRouter를 사용한 선언적 라우팅 시스템으로 인증, 딥링크, 파라미터 직렬화를 지원합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/app/router/
├── README.md              # 현재 문서
└── navigation/           # 실제 구현 코드 (❗ 잘못된 위치)
    ├── nav.dart          # 542줄 - GoRouter 설정 및 라우트 정의
    ├── serialization_util.dart  # 270줄 - 파라미터 직렬화
    └── README.md         # 상세 문서
```

## 🔍 현재 코드 분석

### 1. 디렉토리 구조 문제점
- ❌ **이상적인 구조(README)와 실제 구조 불일치**
- ❌ **모든 구현이 navigation 하위 디렉토리에 존재**
- ❌ **router.dart, routes.dart, guards/ 등 핵심 파일 없음**

### 2. navigation/nav.dart 분석

#### 핵심 컴포넌트
```dart
// 현재 구조 (모든 것이 한 파일에)
- AppStateNotifier     // 인증 상태 관리
- createRouter()       // GoRouter 생성
- AppRoute class       // 라우트 래퍼
- NavigationExtensions // 네비게이션 헬퍼
- TransitionInfo       // 전환 효과
```

#### 문제점
- ❌ **단일 파일에 542줄**: 너무 많은 책임
- ❌ **라우트가 하드코딩**: Feature 의존성 직접 import
- ❌ **인증 로직 혼재**: AppStateNotifier가 너무 많은 역할
- ❌ **Feature 결합**: 각 Feature 페이지 직접 import

#### 현재 라우트 구조
```dart
GoRouter(
  routes: [
    // 루트 라우트
    GoRoute(path: '/', ...),
    
    // ShellRoute - 하단 네비게이션 유지
    ShellRoute(
      builder: MainNavigationShell,
      routes: [
        // 7개 메인 페이지
        HomePageWidget,
        SearchPageWidget,
        ProfilePageWidget,
        InPutPostImageWidget,
        ChatListWidget,
        FriendsListWidget,
        ChatSearchWidget,
      ],
    ),
    
    // 20개+ 일반 라우트
    LoginPageWidget,
    CreateAccountWidget,
    // ... 등등
  ],
)
```

### 3. navigation/serialization_util.dart 분석

#### 지원 타입
- ✅ 기본 타입: int, double, String, bool
- ✅ DateTime, DateTimeRange
- ❌ LatLng, AppPlace (미사용 - 제거 필요)
- ✅ Color, AppUploadedFile
- ✅ DocumentReference, FirestoreRecord
- ✅ JSON

#### 문제점
- ❌ **미사용 모델 의존성**: AppPlace, LatLng는 실제로 사용 안 됨
- ❌ **임시 import**: `/core_exports.dart` 사용 (Temporary 주석 있음)
- ⚠️ **타입 안전성 부족**: ParamType enum 관리 필요
- ⚠️ **단일 파일 과부하**: 270줄에 13가지 타입 처리
- ⚠️ **책임 혼재**: 직렬화, 역직렬화, Firebase 로직 혼합

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **잘못된 디렉토리 구조**: navigation 하위에 모든 구현
- **단일 파일 과부하**: nav.dart에 너무 많은 책임
- **모듈화 부족**: guards, routes, config 등 분리 필요

### 2. Feature-First Architecture 위반
- **직접 의존성**: Feature 페이지들을 직접 import
- **중앙집중식**: 모든 라우트가 한 곳에 정의
- **Feature 독립성 부족**: Feature별 라우트 관리 불가

### 3. 유지보수성 문제
- **확장성 부족**: 새 Feature 추가 시 nav.dart 수정 필요
- **테스트 어려움**: 모든 것이 결합되어 있음
- **재사용성 부족**: Feature별 라우트 재사용 불가

## 🛠️ Feature-First Architecture 개선 방안

### 이상적인 구조
```
lib/app/router/
├── router.dart           # GoRouter 인스턴스
├── routes.dart           # 라우트 경로 상수
├── route_params.dart     # 파라미터 관리
├── guards/              # 라우트 가드
│   ├── auth_guard.dart
│   └── permission_guard.dart
├── transitions/         # 전환 효과
│   └── app_transitions.dart
├── config/             # 라우터 설정
│   └── router_config.dart
└── serialization/      # 직렬화 시스템
    ├── base_serializer.dart    # 기본 타입
    ├── firebase_serializer.dart # Firebase 타입
    └── param_type.dart         # 타입 정의
```

### Feature 라우트 분리
```dart
// features/auth/presentation/routes/auth_routes.dart
class AuthRoutes {
  static const login = '/login';
  static const signup = '/signup';
  
  static List<GoRoute> routes = [
    GoRoute(
      path: login,
      builder: (context, state) => LoginScreen(),
    ),
    // ...
  ];
}

// app/router/router.dart
class AppRouter {
  static GoRouter create() {
    return GoRouter(
      routes: [
        ...AuthRoutes.routes,
        ...PostsRoutes.routes,
        ...ChatRoutes.routes,
        // Feature별 라우트 통합
      ],
    );
  }
}
```

## 📊 현재 사용 통계

### 라우트 수
- **총 라우트**: 30개+
- **ShellRoute 내부**: 7개
- **인증 필요**: 10개+
- **파라미터 필요**: 15개+

### 파일 크기
| 파일 | 줄 수 | 크기 | 문제 |
|------|-------|------|------|
| nav.dart | 542줄 | 22KB | 너무 큼 - 5개 파일로 분리 필요 |
| serialization_util.dart | 270줄 | 10KB | 미사용 코드 제거 및 분리 필요 |

### 의존성 분석
- **직접 import Feature 수**: 7개+
- **순환 의존성 위험**: High
- **결합도**: 매우 높음

## 🎯 액션 플랜

### Phase 1: 파일 분리 (1일)
1. nav.dart를 기능별로 분리
   - router.dart: GoRouter 인스턴스
   - auth_state.dart: AppStateNotifier
   - route_config.dart: 라우트 설정
   - navigation_extensions.dart: 확장 메서드

### Phase 2: Feature 라우트 분리 (3일)
1. 각 Feature에 routes 디렉토리 생성
2. Feature별 라우트 정의 이동
3. 중앙 라우터에서 통합

### Phase 3: Guard 시스템 구축 (2일)
1. AuthGuard 클래스 생성
2. PermissionGuard 구현
3. RouteGuard 인터페이스 정의

### Phase 4: DI 통합 (2일)
1. Router를 DI에 등록
2. Feature 라우트 자동 발견
3. 동적 라우트 등록

## 📝 사용 가이드

### 현재 사용 방법
```dart
// 페이지 이동
context.goNamed(HomePageWidget.routeName);

// 파라미터와 함께
context.pushNamed(
  ChatDetailWidgetV2.routeName,
  extra: {'chatDocument': chatModel},
);

// 인증 체크 후 이동
context.goNamedAuth(
  UserInfoInputWidget.routeName,
  mounted,
);
```

### 개선 후 사용 방법
```dart
// Feature 라우트 사용
context.go(PostsRoutes.create);
context.push(ChatRoutes.detail(chatId));

// Guard 자동 적용
@RequireAuth()
class UserProfileRoute extends AppRoute {
  // ...
}
```

## ⚠️ 주의사항

1. **즉시 수정 필요**: 파일이 너무 크고 복잡함
2. **Feature 의존성 제거**: 직접 import 금지
3. **점진적 마이그레이션**: 기능 유지하며 리팩토링

## 📚 참고 자료

- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Navigation README](./navigation/README.md) - 상세 구현 문서

---

*이 문서는 App Router 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*즉시 구조 개선이 필요한 상태입니다.*