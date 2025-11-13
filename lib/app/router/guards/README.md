# Guards System - Route Protection & Analytics

**위치**: `/lib/app/router/guards/`
**파일**: `auth_guard.dart` (584줄)
**마지막 업데이트**: 2025-11-10 (Phase 5 Guard Analytics 완료)

---

## 📋 목차

- [개요](#-개요)
- [AuthGuard 시스템](#-authguard-시스템)
  - [기본 인증](#1️⃣-기본-인증-basic-authentication)
  - [Redirect Location 관리](#2️⃣-redirect-location-관리-phase-4)
  - [Role-based Authorization](#3️⃣-role-based-authorization-phase-4)
  - [Guard Composition](#4️⃣-guard-composition-phase-4)
- [Phase 5: Guard Analytics](#-phase-5-guard-analytics)
  - [GuardAnalyticsService](#guardanalyticsservice)
  - [GuardAnalyticsEvent](#guardanalyticsevent)
  - [GuardAnalyticsStats](#guardanalyticsstats)
  - [Firestore 통합](#firestore-통합)
  - [Riverpod Providers](#riverpod-providers)
  - [UI 통합](#ui-통합)
- [실전 사용 예시](#-실전-사용-예시)
- [Firestore 보안 규칙](#-firestore-보안-규칙)
- [아키텍처 결정](#-아키텍처-결정-adr)
- [트러블슈팅](#-트러블슈팅)
- [참고 문서](#-참고-문서)

---

## 🎯 개요

**Guards 시스템**은 Flutter 앱의 라우트를 보호하고, 인증/권한 기반 접근 제어를 제공하며, 모든 Guard 실행을 추적하는 시스템입니다.

### 핵심 컴포넌트

```
┌─────────────────────────────────────────────────┐
│ AuthGuard (auth_guard.dart - 584 lines)         │
│ ├─ Basic Auth (checkAuth, redirectIfAuth)      │
│ ├─ Redirect Location (Phase 4)                 │
│ ├─ Role-based Auth (hasRole, hasAnyRole)       │
│ ├─ Guard Composition (AND/OR patterns)         │
│ └─ Guard Analytics Integration (Phase 5)       │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ GuardAnalyticsService (Phase 5)                 │
│ ├─ logGuardCheck() - Event logging             │
│ ├─ watchRecentEvents() - Real-time stream      │
│ ├─ getStats() - Aggregated statistics          │
│ └─ Filtering (by result, by user)              │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ Firestore Collection: guard_analytics           │
│ - Append-only logs (no updates/deletes)        │
│ - Real-time sync with UI                       │
│ - 30-day auto cleanup (TTL)                    │
└─────────────────────────────────────────────────┘
```

### 주요 기능

| 기능 | 설명 | Phase |
|------|------|-------|
| **Basic Auth** | Firebase Auth 기반 route 보호 | Core |
| **Redirect Location** | 로그인 후 원래 경로 복귀 | Phase 4 |
| **Role-based** | admin/tester/user 역할 기반 접근 제어 | Phase 4 |
| **Guard Composition** | 여러 Guard 조건 AND/OR 조합 | Phase 4 |
| **Guard Analytics** | 모든 Guard 실행 추적 및 분석 | Phase 5 ✨ |

---

## 🛡 AuthGuard 시스템

**파일**: `/lib/app/router/guards/auth_guard.dart` (584줄)

### 클래스 구조

```dart
class AuthGuard {
  // Private constructor (static methods only)
  AuthGuard._();

  // Phase 5: Guard Analytics Service
  static final GuardAnalyticsService _analytics = GuardAnalyticsService();

  // Phase 4: Redirect Location Storage
  static String? _pendingRedirectLocation;

  // Core Methods
  static String? checkAuth({required bool requireAuth, required GoRouterState state});
  static String? redirectIfAuthenticated({String redirectTo = '/home'});
  static bool get isAuthenticated;
  static String? get currentUserId;

  // Phase 4: Redirect Location Management
  static String? getPendingRedirectLocation();
  static void clearRedirectLocation();

  // Phase 4: Role-based Authorization
  static Future<UserRole?> getCurrentUserRole();
  static Future<bool> hasRole(UserRole requiredRole);
  static Future<bool> hasAnyRole(List<UserRole> requiredRoles);
  static Future<bool> hasAllRoles(List<UserRole> requiredRoles);

  // Phase 4: Guard Composition
  static String? checkAuthWithCondition({...});
  static String? composeGuardsAnd({...});
  static String? composeGuardsOr({...});
}
```

---

### 1️⃣ **기본 인증 (Basic Authentication)**

#### `checkAuth()` - Route Protection

**위치**: `auth_guard.dart:101-155`

**동작**:
1. `requireAuth == false` → Public route (통과)
2. `requireAuth == true` + 비로그인 → `/startPage` redirect
3. `requireAuth == true` + 로그인 → 통과

**사용 예시**:
```dart
// GoRouter route 정의
GoRoute(
  path: '/profile',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: true,  // 로그인 필수
    state: state,
  ),
  builder: (context, state) => ProfilePage(),
)

// Public route
GoRoute(
  path: '/home',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: false,  // 누구나 접근 가능
    state: state,
  ),
  builder: (context, state) => HomePage(),
)
```

**Phase 5: Analytics 통합**:
```dart
// Line 110-118: Public route allowed
_analytics.logGuardCheck(
  attemptedPath: '/home',
  redirectPath: null,
  result: GuardResult.allowed,
  userId: user?.uid,
  reason: 'public_route',
);

// Line 133-141: Auth required blocked
_analytics.logGuardCheck(
  attemptedPath: '/profile',
  redirectPath: '/startPage',
  result: GuardResult.blocked,
  userId: null,
  reason: 'auth_required',
);

// Line 146-154: Authenticated allowed
_analytics.logGuardCheck(
  attemptedPath: '/profile',
  redirectPath: null,
  result: GuardResult.allowed,
  userId: user.uid,
  reason: 'authenticated',
);
```

---

#### `redirectIfAuthenticated()` - Reverse Guard

**위치**: `auth_guard.dart:203-221`

**동작**:
- 비로그인 → 현재 페이지 유지
- 로그인 → 저장된 redirectLocation 또는 `/home`으로 redirect

**사용 예시**:
```dart
// Login page - 이미 로그인 되어 있으면 home으로
GoRoute(
  path: '/loginPage',
  redirect: (context, state) => AuthGuard.redirectIfAuthenticated(),
  builder: (context, state) => LoginPage(),
)

// Start page - 로그인 되어 있으면 home으로
GoRoute(
  path: '/',
  redirect: (context, state) => AuthGuard.redirectIfAuthenticated(
    redirectTo: '/home',
  ),
  builder: (context, state) => StartPageWidget(),
)
```

---

#### `isAuthenticated` & `currentUserId` - Getters

**위치**: `auth_guard.dart:167-178`

**사용 예시**:
```dart
// Widget에서 인증 상태 확인
if (AuthGuard.isAuthenticated) {
  // 로그인 됨 → 사용자 정보 표시
  final userId = AuthGuard.currentUserId!;
  return UserProfileWidget(userId: userId);
} else {
  // 로그인 안 됨 → 로그인 버튼 표시
  return LoginButton();
}
```

---

### 2️⃣ **Redirect Location 관리 (Phase 4)**

**목적**: 인증 실패 시 접근하려던 경로를 저장하고, 로그인 후 원래 페이지로 복귀

#### 플로우

```
사용자: /profile 접근 시도
    ↓
AuthGuard.checkAuth() 실행
    ↓
user == null (비로그인)
    ↓
_pendingRedirectLocation = '/profile' (저장)
    ↓
return '/startPage' (로그인 페이지로)
    ↓
[사용자 로그인 완료]
    ↓
AuthGuard.redirectIfAuthenticated() 실행
    ↓
_pendingRedirectLocation이 '/profile'로 저장되어 있음
    ↓
return '/profile' (원래 페이지로 복귀!)
    ↓
clearRedirectLocation() 자동 호출
```

#### API

```dart
// 저장된 경로 확인
final pendingRoute = AuthGuard.getPendingRedirectLocation();
if (pendingRoute != null) {
  print('로그인 후 복귀할 경로: $pendingRoute');
}

// 수동 클리어 (필요 시)
AuthGuard.clearRedirectLocation();
```

**구현 세부사항**:
- **Line 68**: `static String? _pendingRedirectLocation;`
- **Line 126-131**: 로그인 페이지는 저장 안 함 (무한 루프 방지)
- **Line 209-214**: redirectIfAuthenticated에서 자동 복원 + 클리어

---

### 3️⃣ **Role-based Authorization (Phase 4)**

**목적**: admin/tester/user 역할에 따른 페이지 접근 제어

#### UserRole Enum

```dart
// /features/auth/domain/enums/user_role.dart
enum UserRole {
  admin,    // 모든 권한
  tester,   // 테스트 기능 접근
  user;     // 일반 사용자

  bool get isAdmin => this == UserRole.admin;
  bool get isTester => this == UserRole.tester || isAdmin;
  bool get isUser => this == UserRole.user || isTester;

  static UserRole fromValue(String value) { ... }
}
```

---

#### `getCurrentUserRole()` - Firestore에서 역할 조회

**위치**: `auth_guard.dart:269-289`

**동작**:
1. 현재 로그인된 사용자 ID 확인
2. Firestore `users/{userId}` 문서 조회
3. `role` 필드 파싱 → UserRole enum 반환

**사용 예시**:
```dart
// Admin 페이지에서 역할 확인
final role = await AuthGuard.getCurrentUserRole();
if (role == UserRole.admin) {
  // 관리자 기능 표시
  return AdminDashboard();
} else {
  // 권한 없음
  return UnauthorizedPage();
}
```

---

#### `hasRole()` - 특정 역할 보유 확인

**위치**: `auth_guard.dart:326-340`

**로직**:
1. `admin`은 모든 권한 자동 보유
2. `tester` 요청 시 → admin 또는 tester 허용
3. 정확히 일치하는 역할 체크

**사용 예시**:
```dart
// Admin 전용 페이지
GoRoute(
  path: '/admin/dashboard',
  builder: (context, state) => FutureBuilder<bool>(
    future: AuthGuard.hasRole(UserRole.admin),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!) {
        return UnauthorizedPage();
      }
      return AdminDashboard();
    },
  ),
)

// Widget 레벨 사용
class AdminOnlyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthGuard.hasRole(UserRole.admin),
      builder: (context, snapshot) {
        if (snapshot.data != true) return SizedBox.shrink();
        return AdminActions();
      },
    );
  }
}
```

---

#### `hasAnyRole()` - 여러 역할 중 하나 (OR)

**위치**: `auth_guard.dart:364-379`

**사용 예시**:
```dart
// Admin 또는 Tester만 접근 가능
if (!await AuthGuard.hasAnyRole([UserRole.admin, UserRole.tester])) {
  return UnauthorizedPage();
}

// Debug 페이지 (Settings에서 5번 탭)
if (await AuthGuard.hasAnyRole([UserRole.admin, UserRole.tester])) {
  // Debug Tools 표시
  context.push('/debug/logs');
}
```

---

#### `hasAllRoles()` - 모든 역할 보유 (AND)

**위치**: `auth_guard.dart:403-418`

**사용 예시**:
```dart
// 특별한 케이스: 여러 역할 동시 필요 (드물게 사용)
// 예: Beta Tester + Premium User
if (!await AuthGuard.hasAllRoles([UserRole.tester, UserRole.premium])) {
  return UnauthorizedPage();
}
```

**참고**: 일반적으로 `hasRole()` 또는 `hasAnyRole()` 사용 권장

---

### 4️⃣ **Guard Composition (Phase 4)**

**목적**: 여러 Guard 조건을 AND/OR로 조합하여 복잡한 접근 제어 구현

---

#### `checkAuthWithCondition()` - Auth + 커스텀 조건

**위치**: `auth_guard.dart:457-480`

**동작**:
1. 먼저 `requireAuth` 체크
2. 통과하면 `customCheck` 실행
3. 모두 통과하면 null, 실패하면 redirect 경로 반환

**사용 예시**:
```dart
// 프로필 완성된 사용자만 Settings 접근 가능
GoRoute(
  path: '/settings',
  redirect: (context, state) => AuthGuard.checkAuthWithCondition(
    requireAuth: true,
    state: state,
    customCheck: (state) {
      // 프로필 완성 여부 확인 (동기 체크만 가능)
      final hasProfile = ... // 캐시된 상태 확인
      return hasProfile ? null : '/complete-profile';
    },
  ),
)

// 이메일 인증된 사용자만 Post 작성 가능
GoRoute(
  path: '/create-post',
  redirect: (context, state) => AuthGuard.checkAuthWithCondition(
    requireAuth: true,
    state: state,
    customCheck: (state) {
      final emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
      return emailVerified ? null : '/verify-email';
    },
  ),
)
```

---

#### `composeGuardsAnd()` - 여러 Guard AND 조합

**위치**: `auth_guard.dart:516-530`

**동작**:
- 제공된 Guard 함수들을 순차 실행
- **하나라도 실패**하면 즉시 그 redirect 반환
- 모두 통과하면 null

**사용 예시**:
```dart
// Admin Settings - 로그인 + 프로필 완성 + 이메일 인증 모두 필요
GoRoute(
  path: '/admin-settings',
  redirect: (context, state) => AuthGuard.composeGuardsAnd(
    state: state,
    guards: [
      // Guard 1: 로그인 필요
      (state) => AuthGuard.checkAuth(requireAuth: true, state: state),

      // Guard 2: 프로필 완성 필요
      (state) {
        final hasProfile = ... // 체크 로직
        return hasProfile ? null : '/complete-profile';
      },

      // Guard 3: 이메일 인증 필요
      (state) {
        final emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        return emailVerified ? null : '/verify-email';
      },
    ],
  ),
)
```

---

#### `composeGuardsOr()` - 여러 Guard OR 조합

**위치**: `auth_guard.dart:568-583`

**동작**:
- 제공된 Guard 함수들을 순차 실행
- **하나라도 통과**하면 즉시 null 반환
- 모두 실패하면 `fallbackRedirect` 반환

**사용 예시**:
```dart
// Premium Content - Admin 또는 Premium 구독자 또는 Trial 기간 중
GoRoute(
  path: '/premium-content',
  redirect: (context, state) => AuthGuard.composeGuardsOr(
    state: state,
    guards: [
      // Guard 1: Admin이면 무조건 통과
      (state) async {
        final isAdmin = await AuthGuard.hasRole(UserRole.admin);
        return isAdmin ? null : '/unauthorized';
      },

      // Guard 2: Premium 구독자도 통과
      (state) {
        final isPremium = ... // Premium 상태 확인
        return isPremium ? null : '/subscribe';
      },

      // Guard 3: Trial 기간이면 통과
      (state) {
        final isTrialActive = ... // Trial 상태 확인
        return isTrialActive ? null : '/trial-expired';
      },
    ],
    fallbackRedirect: '/unauthorized',  // 모두 실패 시
  ),
)
```

---

## 📊 Phase 5: Guard Analytics

**목적**: 모든 Route Guard 실행을 추적하여 디버깅 및 분석 지원

### 시스템 개요

```
AuthGuard.checkAuth() 실행
        ↓
GuardAnalyticsService.logGuardCheck() 호출
        ↓
Firestore guard_analytics 컬렉션에 이벤트 기록
{
  "eventId": "uuid-v4",
  "timestamp": Timestamp,
  "attemptedPath": "/profile",
  "redirectPath": "/startPage" or null,
  "result": "blocked" or "allowed",
  "userId": "user123" or null,
  "reason": "auth_required" | "public_route" | "authenticated"
}
        ↓
Riverpod guardEventsProvider 실시간 Stream
        ↓
GuardAnalyticsTab UI 자동 업데이트
```

---

### GuardAnalyticsService

**파일**: `/lib/services/analytics/guard_analytics_service.dart` (279줄)

#### 클래스 구조

```dart
class GuardAnalyticsService {
  // Singleton instance
  static final GuardAnalyticsService _instance = GuardAnalyticsService._();
  factory GuardAnalyticsService() => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Core Methods
  Future<void> logGuardCheck({...});
  Stream<List<GuardAnalyticsEvent>> watchRecentEvents({int limit = 100});
  Future<GuardAnalyticsStats> getStats();
  Future<void> clearAllEvents();

  // Filtering
  Future<List<GuardAnalyticsEvent>> getEventsByResult(GuardResult result, {int limit = 100});
  Future<List<GuardAnalyticsEvent>> getEventsByUser(String userId, {int limit = 100});
}
```

---

#### `logGuardCheck()` - 이벤트 기록

**위치**: `guard_analytics_service.dart:85-111`

**동작**:
1. UUID v4 eventId 생성
2. GuardAnalyticsEvent 생성
3. Firestore `guard_analytics/{eventId}` 문서에 저장
4. **Fire-and-forget** (성능 최적화, 실패해도 앱에 영향 없음)

**사용 예시** (AuthGuard에서):
```dart
// Public route allowed
_analytics.logGuardCheck(
  attemptedPath: '/home',
  redirectPath: null,
  result: GuardResult.allowed,
  userId: user?.uid,
  reason: 'public_route',
);

// Auth required blocked
_analytics.logGuardCheck(
  attemptedPath: '/profile',
  redirectPath: '/startPage',
  result: GuardResult.blocked,
  userId: null,
  reason: 'auth_required',
);

// Authenticated allowed
_analytics.logGuardCheck(
  attemptedPath: '/profile',
  redirectPath: null,
  result: GuardResult.allowed,
  userId: user.uid,
  reason: 'authenticated',
);
```

---

#### `watchRecentEvents()` - 실시간 이벤트 스트림

**위치**: `guard_analytics_service.dart:130-140`

**동작**:
- Firestore `snapshots()` 실시간 감지
- 최근 N개 이벤트 (기본 100개)
- Timestamp 내림차순 정렬

**사용 예시**:
```dart
// Riverpod Provider로 사용
@riverpod
Stream<List<GuardAnalyticsEvent>> guardEvents(Ref ref) {
  final service = GuardAnalyticsService();
  return service.watchRecentEvents(limit: 50);
}

// Widget에서 사용
class GuardEventsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(guardEventsProvider);

    return eventsAsync.when(
      data: (events) => ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, i) => Text(events[i].terminalLogLine),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

---

#### `getStats()` - 통계 조회

**위치**: `guard_analytics_service.dart:162-189`

**동작**:
- 모든 이벤트 조회 (Production에서는 pre-aggregated 권장)
- totalChecks, blockedCount, allowedCount 집계

**사용 예시**:
```dart
// Riverpod Provider로 사용
@riverpod
Future<GuardAnalyticsStats> guardStats(Ref ref) async {
  // Events 업데이트 시 자동 invalidate
  ref.watch(guardEventsProvider);

  final service = GuardAnalyticsService();
  return service.getStats();
}

// Widget에서 사용
class GuardStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(guardStatsProvider);

    return statsAsync.when(
      data: (stats) => Column(
        children: [
          Text('Total Checks: ${stats.totalChecks}'),
          Text('Blocked: ${stats.blockedCount} (${stats.blockPercentage.toStringAsFixed(1)}%)'),
          Text('Allowed: ${stats.allowedCount} (${stats.allowPercentage.toStringAsFixed(1)}%)'),
        ],
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading stats'),
    );
  }
}
```

---

#### 필터링 메서드

```dart
// Result별 필터링 (BLOCKED 또는 ALLOWED)
final blockedEvents = await GuardAnalyticsService()
  .getEventsByResult(GuardResult.blocked, limit: 50);

// 사용자별 필터링
final userEvents = await GuardAnalyticsService()
  .getEventsByUser('user123', limit: 50);
```

---

### GuardAnalyticsEvent

**파일**: `/lib/services/analytics/guard_analytics_event.dart` (Line 60-141)

#### Freezed Entity

```dart
@freezed
sealed class GuardAnalyticsEvent with _$GuardAnalyticsEvent {
  const GuardAnalyticsEvent._();

  const factory GuardAnalyticsEvent({
    required String eventId,        // UUID v4
    required DateTime timestamp,    // Server time
    required String attemptedPath,  // Route user tried
    String? redirectPath,           // Where redirected (null if allowed)
    required GuardResult result,    // blocked or allowed
    String? userId,                 // User ID (null if not logged in)
    required String reason,         // Why blocked/allowed
  }) = _GuardAnalyticsEvent;

  factory GuardAnalyticsEvent.fromJson(Map<String, dynamic> json) =>
      _$GuardAnalyticsEventFromJson(json);
}
```

---

#### Extension Pattern

```dart
// Firestore → Entity
static GuardAnalyticsEvent fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};

  return GuardAnalyticsEvent(
    eventId: doc.id,
    timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    attemptedPath: data['attemptedPath'] as String? ?? '',
    redirectPath: data['redirectPath'] as String?,
    result: GuardResult.fromValue(data['result'] as String? ?? 'blocked'),
    userId: data['userId'] as String?,
    reason: data['reason'] as String? ?? '',
  );
}

// Entity → Firestore
Map<String, dynamic> toFirestore() {
  return {
    'timestamp': Timestamp.fromDate(timestamp),
    'attemptedPath': attemptedPath,
    'redirectPath': redirectPath,
    'result': result.toValue(),
    'userId': userId,
    'reason': reason,
  };
}
```

---

#### Display Helpers

```dart
// 🔴 or 🟢 emoji
String get resultEmoji => result == GuardResult.blocked ? '🔴' : '🟢';

// "BLOCKED" or "ALLOWED"
String get resultText => result == GuardResult.blocked ? 'BLOCKED' : 'ALLOWED';

// Terminal-style log line
String get terminalLogLine {
  final formattedTime = '${timestamp.hour.toString().padLeft(2, '0')}:'
      '${timestamp.minute.toString().padLeft(2, '0')}:'
      '${timestamp.second.toString().padLeft(2, '0')}';

  final redirect = redirectPath != null ? ' → $redirectPath' : '';
  final user = userId != null ? ' [$userId]' : '';

  return '$resultEmoji $resultText $attemptedPath$redirect ($reason)$user [$formattedTime]';
}

// 예시 출력:
// 🔴 BLOCKED /admin → /startPage (auth_required) [14:30:45]
// 🟢 ALLOWED /home (public_route) [user123] [14:31:12]
```

---

### GuardAnalyticsStats

**파일**: `/lib/services/analytics/guard_analytics_event.dart` (Line 162-193)

#### Freezed Entity

```dart
@Freezed(fromJson: false, toJson: false)
sealed class GuardAnalyticsStats with _$GuardAnalyticsStats {
  const GuardAnalyticsStats._();

  const factory GuardAnalyticsStats({
    @Default(0) int totalChecks,
    @Default(0) int blockedCount,
    @Default(0) int allowedCount,
  }) = _GuardAnalyticsStats;

  // Computed properties
  double get blockPercentage =>
      totalChecks > 0 ? (blockedCount / totalChecks) * 100 : 0.0;

  double get allowPercentage =>
      totalChecks > 0 ? (allowedCount / totalChecks) * 100 : 0.0;

  String get terminalDisplay {
    return '''
Total Checks: $totalChecks
Blocked:      $blockedCount (${blockPercentage.toStringAsFixed(1)}%)
Allowed:      $allowedCount (${allowPercentage.toStringAsFixed(1)}%)''';
  }
}
```

---

### Firestore 통합

#### Collection Structure

```javascript
// Collection: guard_analytics
{
  "eventId": "550e8400-e29b-41d4-a716-446655440000",  // Document ID
  "timestamp": Timestamp(2025, 11, 10, 14, 30, 45),
  "attemptedPath": "/profile/edit",
  "redirectPath": "/startPage",  // null for allowed
  "result": "blocked",           // "blocked" or "allowed"
  "userId": null,                // null if not logged in
  "reason": "auth_required"      // "auth_required" | "public_route" | "authenticated"
}
```

#### Firestore Queries

```dart
// 최근 100개 이벤트 (실시간 스트림)
_firestore
  .collection('guard_analytics')
  .orderBy('timestamp', descending: true)
  .limit(100)
  .snapshots()

// Result 필터링
_firestore
  .collection('guard_analytics')
  .where('result', isEqualTo: 'blocked')
  .orderBy('timestamp', descending: true)
  .limit(100)

// 사용자별 필터링
_firestore
  .collection('guard_analytics')
  .where('userId', isEqualTo: 'user123')
  .orderBy('timestamp', descending: true)
  .limit(100)
```

---

### Riverpod Providers

**파일**: `/lib/app/widgets/debug/providers/guard_analytics_providers.dart` (179줄)

#### guardEventsProvider - 실시간 이벤트

```dart
@riverpod
Stream<List<GuardAnalyticsEvent>> guardEvents(Ref ref) {
  final service = GuardAnalyticsService();
  return service.watchRecentEvents(limit: 100);
}

// 사용
final eventsAsync = ref.watch(guardEventsProvider);
eventsAsync.when(
  data: (events) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(),
);
```

---

#### guardStatsProvider - 통계 (자동 갱신)

```dart
@riverpod
Future<GuardAnalyticsStats> guardStats(Ref ref) async {
  // Events 업데이트 시 자동 invalidate
  ref.watch(guardEventsProvider);

  final service = GuardAnalyticsService();
  return service.getStats();
}

// 사용
final statsAsync = ref.watch(guardStatsProvider);
statsAsync.when(
  data: (stats) => Text('Total: ${stats.totalChecks}'),
  loading: () => Skeleton(),
  error: (error, stack) => Text('Error'),
);
```

---

#### 필터링 Providers

```dart
// Result별 필터링
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByResult(
  Ref ref,
  GuardResult result,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByResult(result, limit: 100);
}

// 사용자별 필터링
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByUser(
  Ref ref,
  String userId,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByUser(userId, limit: 100);
}
```

---

### UI 통합

#### GuardAnalyticsTab (DebugLogPage)

**파일**: `/lib/app/widgets/debug/guard_analytics_tab.dart` (325줄)

**UI 구조**:
```
┌─────────────────────────────────────┐
│ Guard Analytics Statistics          │
│ Total Checks: 150                   │
│ Blocked: 45 (30.0%)                 │
│ Allowed: 105 (70.0%)                │
├─────────────────────────────────────┤
│ 🔴 BLOCKED /admin → /startPage      │
│    (auth_required) [14:30:45]       │
│ 🟢 ALLOWED /home (authenticated)    │
│    [user123] [14:30:50]             │
│ 🔴 BLOCKED /profile → /startPage    │
│    (auth_required) [14:31:02]       │
└─────────────────────────────────────┘
```

**코드**:
```dart
class GuardAnalyticsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(guardStatsProvider);
    final eventsAsync = ref.watch(guardEventsProvider);

    return Column(
      children: [
        // Statistics Section
        _buildStatisticsSection(statsAsync),

        // Events List
        Expanded(
          child: _buildEventsSection(eventsAsync),
        ),
      ],
    );
  }
}
```

**접근 방법**:
1. Settings 화면 진입
2. 타이틀 5번 연속 탭
3. Debug Tools 페이지 열림
4. "Guard Analytics" 탭 클릭

---

## 💡 실전 사용 예시

### 예시 1: 기본 Route 보호

```dart
// Public route (누구나 접근 가능)
GoRoute(
  path: '/home',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: false,
    state: state,
  ),
  builder: (context, state) => HomePage(),
)

// Protected route (로그인 필수)
GoRoute(
  path: '/chat',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: true,
    state: state,
  ),
  builder: (context, state) => ChatListPage(),
)
```

---

### 예시 2: Role-based 페이지

```dart
// Admin 전용 페이지
GoRoute(
  path: '/admin/dashboard',
  builder: (context, state) => FutureBuilder<bool>(
    future: AuthGuard.hasRole(UserRole.admin),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      if (!snapshot.data!) return UnauthorizedPage();
      return AdminDashboard();
    },
  ),
)

// Admin 또는 Tester 접근 가능
GoRoute(
  path: '/debug/tools',
  builder: (context, state) => FutureBuilder<bool>(
    future: AuthGuard.hasAnyRole([UserRole.admin, UserRole.tester]),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      if (!snapshot.data!) return UnauthorizedPage();
      return DebugToolsPage();
    },
  ),
)
```

---

### 예시 3: 복잡한 Guard 조합

```dart
// Profile 완성 + 이메일 인증 필요
GoRoute(
  path: '/create-post',
  redirect: (context, state) => AuthGuard.composeGuardsAnd(
    state: state,
    guards: [
      // 1. 로그인 필수
      (state) => AuthGuard.checkAuth(requireAuth: true, state: state),

      // 2. 프로필 완성 필수
      (state) {
        final hasProfile = ...;
        return hasProfile ? null : '/complete-profile';
      },

      // 3. 이메일 인증 필수
      (state) {
        final emailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        return emailVerified ? null : '/verify-email';
      },
    ],
  ),
  builder: (context, state) => CreatePostPage(),
)
```

---

### 예시 4: Analytics 데이터 활용

```dart
// Admin Dashboard에서 Guard Analytics 표시
class AdminDashboardPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(guardStatsProvider);
    final blockedEventsAsync = ref.watch(
      guardEventsByResultProvider(GuardResult.blocked),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Column(
        children: [
          // 통계 카드
          statsAsync.when(
            data: (stats) => Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Guard Analytics'),
                    Text('Total Checks: ${stats.totalChecks}'),
                    Text('Blocked: ${stats.blockedCount} (${stats.blockPercentage.toStringAsFixed(1)}%)'),
                    Text('Allowed: ${stats.allowedCount} (${stats.allowPercentage.toStringAsFixed(1)}%)'),
                  ],
                ),
              ),
            ),
            loading: () => CircularProgressIndicator(),
            error: (error, stack) => Text('Error'),
          ),

          // 최근 차단된 이벤트
          Text('Recent Blocked Attempts'),
          Expanded(
            child: blockedEventsAsync.when(
              data: (events) => ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, i) {
                  final event = events[i];
                  return ListTile(
                    title: Text(event.attemptedPath),
                    subtitle: Text(event.reason),
                    trailing: Text(event.terminalLogLine),
                  );
                },
              ),
              loading: () => CircularProgressIndicator(),
              error: (error, stack) => Text('Error'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔒 Firestore 보안 규칙

**파일**: `/firebase/firestore.rules` (Line 304-332)

```javascript
// Guard Analytics 컬렉션
match /guard_analytics/{eventId} {
  // 읽기: 인증된 사용자만
  allow read: if request.auth != null;

  // 쓰기: 필드 검증 + 필수 필드
  allow create: if request.auth != null
    && request.resource.data.keys().hasAll(['eventId', 'timestamp', 'attemptedPath', 'result', 'reason'])
    && request.resource.data.keys().hasOnly(['eventId', 'timestamp', 'attemptedPath', 'redirectPath', 'result', 'userId', 'reason'])
    && request.resource.data.result in ['blocked', 'allowed'];

  // 업데이트 불가 (Append-Only)
  allow update: if false;

  // 삭제: 본인 이벤트 또는 관리자
  allow delete: if request.auth != null
    && (request.auth.uid == resource.data.userId
        || request.auth.uid in ['ADMIN_UID_1', 'ADMIN_UID_2']);
}
```

**보안 요구사항**:
1. ✅ **읽기**: 로그인 필수
2. ✅ **쓰기**: 필드 검증 (필수: eventId, timestamp, attemptedPath, result, reason)
3. ✅ **result 값**: "blocked" 또는 "allowed"만 허용
4. ❌ **업데이트**: 불가 (Append-Only 로그)
5. ✅ **삭제**: 본인 이벤트 또는 관리자만

---

## 🏛 아키텍처 결정 (ADR)

### 왜 Static Methods? (vs Singleton)

**결정**: AuthGuard는 static methods만 제공

**근거**:
- ✅ Firebase Auth는 이미 Singleton (`FirebaseAuth.instance`)
- ✅ 추가 Singleton overhead 불필요
- ✅ 간단한 API (`AuthGuard.checkAuth()`)
- ✅ Testability: Mock Firebase Auth 주입 가능

---

### 왜 Fire-and-forget Analytics? (vs Await)

**결정**: `logGuardCheck()`는 `await` 안 함 (Fire-and-forget)

**근거**:
- ✅ **성능**: Guard 실행이 Analytics 때문에 느려지면 안 됨
- ✅ **신뢰성**: Analytics 실패가 앱 crash로 이어지면 안 됨
- ✅ **사용자 경험**: 로그인 플로우가 빨라야 함
- ⚠️ Trade-off: Analytics 실패 시 로그 누락 가능 (acceptable)

---

### 왜 Firestore? (vs Hive Local)

**결정**: Analytics를 Firestore에 저장

**근거**:
- ✅ **실시간 동기화**: 여러 디바이스에서 동일한 데이터
- ✅ **Admin Dashboard**: 관리자가 모든 사용자 Guard 이벤트 조회 가능
- ✅ **보안**: Firestore Rules로 접근 제어
- ✅ **Cloud Functions**: 30일 자동 정리 (TTL) 구현 가능
- ⚠️ Trade-off: 네트워크 의존성, 비용 (무료 한도 내)

---

### 왜 Extension Pattern? (vs DTO/Mapper)

**결정**: `fromFirestore()` / `toFirestore()` Extension

**근거**:
- ✅ **간결성**: DTO/Mapper 제거로 85% 코드 감소
- ✅ **타입 안전**: Entity 타입에 결합
- ✅ **IDE 지원**: 자동완성 가능
- ✅ **명확성**: Firestore ↔ Entity 직접 변환

---

## 🔧 트러블슈팅

### 문제 1: Analytics가 기록 안 됨

**증상**:
- `guard_analytics` 컬렉션에 데이터 없음
- GuardAnalyticsTab에서 Empty State

**해결책**:
```dart
// 1. Firestore Rules 확인
// firebase/firestore.rules에 guard_analytics 규칙 있는지 확인

// 2. AuthGuard 통합 확인
// auth_guard.dart:60에 _analytics 인스턴스 있는지 확인
static final GuardAnalyticsService _analytics = GuardAnalyticsService();

// 3. logGuardCheck() 호출 확인
// auth_guard.dart:110-118, 133-141, 146-154에 호출 있는지 확인

// 4. Firebase 초기화 확인
// main.dart에 Firebase.initializeApp() 있는지 확인

// 5. Firestore Console에서 직접 확인
// Firebase Console → Firestore Database → guard_analytics 컬렉션
```

---

### 문제 2: Role-based Guard가 느림

**증상**:
- `hasRole()` 호출 시 UI가 버벅임
- FutureBuilder가 계속 loading 상태

**해결책**:
```dart
// ❌ 나쁜 예: 매번 Firestore 조회
build(BuildContext context) {
  return FutureBuilder<bool>(
    future: AuthGuard.hasRole(UserRole.admin),  // 매 빌드마다 Firestore 조회!
    builder: ...
  );
}

// ✅ 좋은 예: Riverpod Provider로 캐싱
@riverpod
Future<UserRole?> currentUserRole(Ref ref) async {
  return AuthGuard.getCurrentUserRole();
}

build(BuildContext context, WidgetRef ref) {
  final roleAsync = ref.watch(currentUserRoleProvider);
  return roleAsync.when(
    data: (role) => role == UserRole.admin ? AdminWidget() : UserWidget(),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => ErrorWidget(),
  );
}
```

---

### 문제 3: Redirect Location이 저장 안 됨

**증상**:
- 로그인 후 항상 `/home`으로 이동
- 원래 접근하려던 페이지로 복귀 안 됨

**해결책**:
```dart
// 1. checkAuth()에서 requireAuth: true 확인
GoRoute(
  path: '/profile',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: true,  // 반드시 true!
    state: state,
  ),
  builder: (context, state) => ProfilePage(),
)

// 2. 로그인 페이지에서 redirectIfAuthenticated() 사용
GoRoute(
  path: '/loginPage',
  redirect: (context, state) => AuthGuard.redirectIfAuthenticated(),
  builder: (context, state) => LoginPage(),
)

// 3. 디버깅
final pendingRoute = AuthGuard.getPendingRedirectLocation();
print('Saved redirect location: $pendingRoute');
```

---

### 문제 4: Guard Composition이 작동 안 함

**증상**:
- `composeGuardsAnd()`에서 첫 번째 Guard만 실행됨
- 비동기 Guard가 동작 안 함

**해결책**:
```dart
// ❌ 나쁜 예: async Guard 사용 (redirect는 동기 함수!)
GoRoute(
  redirect: (context, state) => AuthGuard.composeGuardsAnd(
    state: state,
    guards: [
      (state) async {  // ❌ async는 안 됨!
        final hasRole = await AuthGuard.hasRole(UserRole.admin);
        return hasRole ? null : '/unauthorized';
      },
    ],
  ),
)

// ✅ 좋은 예: FutureBuilder로 비동기 처리
GoRoute(
  builder: (context, state) => FutureBuilder<bool>(
    future: AuthGuard.hasRole(UserRole.admin),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();
      if (!snapshot.data!) return UnauthorizedPage();
      return AdminPage();
    },
  ),
)
```

---

## 📚 참고 문서

- **Router 통합 가이드**: `/lib/app/router/README.md`
- **Navigation 시스템**: `/lib/app/router/navigation/README.md`
- **이슈 분석**: `/lib/app/router/ISSUES_ANALYSIS.md`
- **GuardAnalyticsService**: `/lib/services/analytics/guard_analytics_service.dart`
- **GuardAnalyticsEvent**: `/lib/services/analytics/guard_analytics_event.dart`
- **Firestore Rules**: `/firebase/firestore.rules` (Line 304-332)

---

**마지막 업데이트**: 2025-11-10 (Phase 5 Guard Analytics 완료)
**작성자**: Claude Code (Deep Analysis)
**버전**: v2.0.0 (Phase 5 통합)
