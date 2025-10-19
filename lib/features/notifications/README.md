# 🔔 Notifications Feature
> **Clean Architecture v4.0** | **Feature-First Design** | **Port-Adapter Pattern**

## 📋 개요

**Notifications Feature**는 Versus Space 앱의 범용 알림 시스템으로, 실시간 알림 스트림, 알림 목록 관리, 타입별 다이얼로그 라우팅을 통해 사용자에게 시스템 공지, 소셜 상호작용, 투표 요청 등을 전달하는 모듈입니다. Clean Architecture v4.0과 Port-Adapter 패턴을 적용하여 확장 가능하고 Feature 간 의존성이 최소화된 구조로 설계되었습니다.

### 🎯 핵심 특징

**범용 알림 시스템**
- 3가지 알림 타입 지원: System Alert, Social Notification, Voting Request
- String 기반 타입 시스템으로 확장성 확보
- NotificationQueueService를 통한 순차적 알림 표시

**실시간 알림 처리**
- Firebase Firestore 실시간 스트림 기반
- NotificationQueueService 큐 시스템으로 중복 표시 방지
- 타입별 다이얼로그 자동 라우팅

**Port-Adapter 패턴 통합**
- Voting Feature와의 깔끔한 통합 (INotificationDisplayPort)
- Feature 간 의존성 최소화
- 각 Feature가 자신의 알림 UI 완전 제어

**계약 기반 아키텍처**
- NotificationContract 구현으로 App Layer 통합
- Repository가 이중 인터페이스 구현 (INotificationRepository + NotificationContract)
- 다른 Feature와의 명확한 경계

**성능 최적화**
- 30분 캐시 만료 시간 (최대 100개)
- 스트림 재사용으로 중복 구독 방지
- 읽지 않은 알림 개수 실시간 추적

## 🏗️ 전체 아키텍처 구조도

```
lib/features/notifications/
├── data/                           # 데이터 레이어 (10개 파일)
│   ├── repositories/              # 1개 Repository 구현체
│   │   └── notification_repository_impl.dart  # INotificationRepository + NotificationContract
│   │
│   ├── datasources/               # 4개 DataSource (2 인터페이스 + 2 구현)
│   │   ├── i_local_notification_datasource.dart
│   │   ├── i_remote_notification_datasource.dart
│   │   ├── local/
│   │   │   └── shared_prefs_notification_datasource.dart  # 캐싱
│   │   └── remote/
│   │       └── firebase_notification_datasource.dart      # Firestore
│   │
│   ├── models/                    # 4개 DTO
│   │   ├── notification_dto.dart
│   │   ├── social_notification_dto.dart
│   │   ├── system_notification_dto.dart
│   │   └── dto_extensions.dart    # DateTime 파싱 헬퍼
│   │
│   ├── mappers/                   # 1개 Mapper
│   │   └── notification_mapper.dart  # DTO ↔ Domain 양방향 변환
│   │
│   └── adapters/                  # 1개 Service Adapter
│       └── notification_service.dart  # NotificationQueueService 통합
│
├── domain/                         # 도메인 레이어 (12개 파일)
│   ├── models/                    # 3개 도메인 모델
│   │   ├── notification.dart      # 추상 베이스 엔티티
│   │   ├── system_notification.dart
│   │   └── social_notification.dart
│   │
│   ├── repositories/              # 1개 Repository 인터페이스
│   │   └── i_notification_repository.dart
│   │
│   ├── usecases/                  # 5개 UseCase
│   │   ├── base/
│   │   │   ├── use_case.dart      # UseCase<Input, Output>
│   │   │   └── stream_use_case.dart
│   │   ├── watch_user_notifications_use_case.dart
│   │   ├── get_user_notifications_use_case.dart
│   │   ├── watch_unread_count_use_case.dart
│   │   ├── mark_as_read_use_case.dart
│   │   └── send_notification_use_case.dart
│   │
│   ├── value_objects/             # 1개 Value Object
│   │   └── notification_filter.dart
│   │
│   └── services/                  # 1개 Service 인터페이스
│       └── i_notification_service.dart
│
└── presentation/                   # 프레젠테이션 레이어 (6개 파일)
    ├── providers/                 # 2개 Provider
    │   ├── notification_badge_provider.dart      # AppBar 뱃지
    │   └── notification_overlay_provider.dart    # 실시간 알림 표시
    │
    ├── screens/                   # 1개 화면
    │   └── notifications_list/
    │       └── notifications_list_widget.dart
    │
    ├── widgets/                   # 1개 위젯
    │   └── notification_badge.dart
    │
    ├── helpers/                   # 1개 헬퍼
    │   └── notification_display_helper.dart
    │
    └── routes/                    # 1개 라우트
        └── notification_routes.dart
```

### 📊 파일 통계

- **총 파일**: 28개
- **Data Layer**: 10개 파일 (Repository 1, DataSources 4, DTOs 4, Mapper 1)
- **Domain Layer**: 12개 파일 (Models 3, Repository 1, UseCases 5, Value Objects 1, Services 1)
- **Presentation Layer**: 6개 파일 (Providers 2, Screens 1, Widgets 1, Helpers 1, Routes 1)

## 🔄 데이터 플로우

### 실시간 알림 수신 플로우
```
1. Firebase Functions
   Firebase Functions에서 알림 생성 (onPostCreatedSendNotifications)
   └─ targetAudience 기반 사용자 선택
      └─ AI 매칭 (Quick Collection) 또는 랜덤 (Public)

2. Firestore
   notifications 컬렉션에 문서 추가
   └─ userId, type, title, content, data, createdAt, isRead: false

3. Data Layer
   FirebaseNotificationDatasource.watchUserNotifications()
   └─ Firestore 실시간 스트림 구독
      └─ 스트림 재사용으로 중복 구독 방지

4. Repository Layer
   NotificationRepositoryImpl
   ├─ Local에 캐싱 (30분 TTL, 100개 제한)
   └─ DTO → Domain 변환 (NotificationMapper)

5. Service Layer
   NotificationService (Data/Adapters)
   └─ Repository 스트림을 NotificationQueueService로 전달

6. Queue Layer
   NotificationQueueService (/services/)
   ├─ 큐에 추가 (중복 ID 검증)
   ├─ 처리된 알림 ID 추적 (SharedPrefs)
   └─ 순차적 표시 (showNotificationStream)

7. Presentation Layer
   NotificationOverlayProvider
   └─ 타입별 다이얼로그 라우팅
      ├─ Voting: _votingDisplayPort.showVotingNotification()
      ├─ Social: _showSocialDialog()
      └─ System: _showSystemDialog()

8. User Interaction
   사용자 액션 (투표, 해제)
   └─ MarkAsReadUseCase 호출
      └─ Firestore 업데이트 (isRead: true, readAt: Timestamp)
         └─ NotificationQueueService.notificationClosed()
            └─ 다음 알림 표시 (500ms 지연)
```

### 알림 읽음 처리 플로우
```
1. UI
   사용자가 알림 클릭 (NotificationsListWidget)
   └─ onTap: !isRead && !isExpired

2. UseCase
   MarkAsReadUseCase.call()
   ├─ 비즈니스 규칙 1: userId/notificationId 검증
   ├─ 비즈니스 규칙 2: 알림 존재 확인
   ├─ 비즈니스 규칙 3: 권한 검증 (본인 알림만)
   └─ 비즈니스 규칙 4: Idempotent 처리 (이미 읽은 경우 성공 반환)

3. Repository
   NotificationRepositoryImpl.markAsRead()
   ├─ Remote: updateNotification({ isRead: true, readAt: Timestamp })
   └─ Local: 캐시 업데이트

4. Firestore
   notifications/{notificationId} 문서 업데이트
   └─ Security Rules: userId 일치 확인

5. Real-time Update
   watchUserNotifications 스트림 자동 업데이트
   └─ StreamBuilder 자동 리렌더링
      └─ 읽음 상태 UI 반영 (opacity: 0.6, fontWeight: normal)
```

### 뱃지 카운트 플로우
```
1. AppBar
   NotificationAppBarAction 렌더링
   └─ GetCurrentUserUseCase.currentUserId

2. UseCase
   WatchUnreadCountUseCase.call(userId)
   └─ Repository.watchUnreadCount(userId)

3. Firestore
   Firestore 실시간 쿼리
   └─ where('userId', isEqualTo: userId)
         .where('isRead', isEqualTo: false)
         .where('expiryTime', isGreaterThan: now)

4. StreamBuilder
   snapshot.data → count
   └─ NotificationIconWithBadge
      └─ NotificationBadge (count > 0일 때만 표시)
         └─ 99보다 크면 "99+" 표시
```

## 💻 빠른 시작 가이드

### 1. 초기 설정

**의존성 주입 등록** (`lib/app/di/notification_module.dart`):
```dart
class NotificationModule {
  static void registerDependencies(GetIt getIt) {
    // DataSources
    getIt.registerLazySingleton<IRemoteNotificationDatasource>(
      () => FirebaseNotificationDatasource(),
    );
    getIt.registerLazySingleton<ILocalNotificationDatasource>(
      () => SharedPrefsNotificationDatasource(),
    );

    // Mappers
    getIt.registerLazySingleton(() => NotificationMapper());

    // Repositories
    getIt.registerLazySingleton<INotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        notificationService: getIt(),
      ),
    );

    // Repository가 NotificationContract도 구현하므로 동일 인스턴스 등록
    getIt.registerLazySingleton<NotificationContract>(
      () => getIt<INotificationRepository>() as NotificationContract,
    );

    // Services
    getIt.registerLazySingleton<NotificationQueueService>(
      () => NotificationQueueService(
        localDatasource: getIt(),
        notificationService: getIt(),
      ),
    );

    getIt.registerLazySingleton<INotificationService>(
      () => NotificationService(
        repository: getIt(),
        queueService: getIt(),
      ),
    );

    // UseCases
    getIt.registerFactory(() => WatchUserNotificationsUseCase(getIt()));
    getIt.registerFactory(() => GetUserNotificationsUseCase(getIt()));
    getIt.registerFactory(() => WatchUnreadCountUseCase(getIt()));
    getIt.registerFactory(() => MarkAsReadUseCase(getIt()));

    // Providers
    getIt.registerLazySingleton(() => NotificationOverlayProvider(
      queueService: getIt(),
      markAsRead: getIt(),
      votingDisplayPort: getIt(),  // Voting Feature Port
    ));
  }
}
```

### 2. 앱 시작 시 초기화

**main.dart**:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // DI 초기화
  await setupDependencies();

  // 알림 시스템 초기화
  final overlayProvider = getIt<NotificationOverlayProvider>();
  final authContract = getIt<AuthContract>();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: overlayProvider),
        // ... 다른 Provider
      ],
      child: MyApp(),
    ),
  );

  // 로그인 후 알림 리스닝 시작
  authContract.onAuthStateChanged.listen((user) {
    if (user != null) {
      overlayProvider.startListening();
    } else {
      overlayProvider.stopListening();
    }
  });
}
```

### 3. AppBar에 알림 뱃지 추가

**AppBar 통합**:
```dart
AppBar(
  title: Text('홈'),
  actions: [
    NotificationAppBarAction(),  // 실시간 뱃지 표시
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {},
    ),
  ],
);
```

### 4. 알림 목록 화면 통합

**GoRouter 설정**:
```dart
// app/router/app_router.dart
final router = GoRouter(
  routes: [
    ...HomeRoutes.routes,
    ...NotificationRoutes.routes,  // 알림 라우트 추가
    ...ProfileRoutes.routes,
  ],
);

// 네비게이션
context.pushNamed(NotificationRoutes.notificationsList);
```

### 5. 실시간 알림 처리 사용 예제

**NotificationOverlayProvider 커스터마이징**:
```dart
class CustomNotificationHandler {
  final NotificationOverlayProvider _overlayProvider;

  CustomNotificationHandler(this._overlayProvider);

  void initialize() {
    // 알림 리스닝 시작
    _overlayProvider.startListening();

    // 특정 타입만 필터링하고 싶다면
    // NotificationService.startListening(userId, type: 'systemAlert')
  }

  void dispose() {
    _overlayProvider.stopListening();
  }
}
```

### 6. 커스텀 알림 발송

**알림 생성 예시** (Firebase Functions):
```javascript
// firebase/functions/notifications/index.js
const admin = require('firebase-admin');

async function sendCustomNotification(userId, notificationData) {
  const notificationRef = admin.firestore().collection('notifications').doc();

  await notificationRef.set({
    userId: userId,
    type: 'systemAlert',  // 또는 'social'
    title: '새로운 업데이트',
    content: '앱에 새로운 기능이 추가되었습니다!',
    data: {
      actionUrl: 'https://example.com/updates',
    },
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    isRead: false,
    expiryTime: null,  // 만료 없음
    metadata: {},
    priority: 1,
  });

  return notificationRef.id;
}
```

**Flutter에서 알림 생성** (드물게 사용):
```dart
final notification = SystemNotification(
  id: '',  // Firestore에서 자동 생성
  userId: 'user123',
  createdAt: DateTime.now(),
  isRead: false,
  title: '환영합니다',
  content: 'Versus Space에 오신 것을 환영합니다!',
  alertType: SystemAlertType.info,
  actionUrl: 'https://example.com/welcome',
  actionLabel: '시작하기',
  isDismissible: true,
);

await getIt<INotificationRepository>().createNotification(notification);
```

## 🔒 보안 기능

### Firestore 보안 규칙
```javascript
// firestore.rules
match /notifications/{notificationId} {
  // 읽기: 자신의 알림만
  allow read: if request.auth != null &&
                 request.auth.uid == resource.data.userId;

  // 생성: Firebase Functions만 (일반 사용자 불가)
  allow create: if false;

  // 업데이트: 자신의 알림만, isRead/readAt 필드만 수정 가능
  allow update: if request.auth != null &&
                   request.auth.uid == resource.data.userId &&
                   request.resource.data.diff(resource.data)
                     .affectedKeys()
                     .hasOnly(['isRead', 'readAt']);

  // 삭제: 금지 (자동 정리 함수에서만)
  allow delete: if false;
}
```

### 데이터 검증
- **필수 필드 검증**: userId, type, title, content
- **권한 검증**: 본인의 알림만 읽음 처리 가능 (MarkAsReadUseCase)
- **Idempotent 처리**: 이미 읽은 알림 재호출 시 성공 반환
- **만료 검증**: expiryTime 이후 알림은 canBeRead: false

### 캐싱 보안
- **30분 TTL**: SharedPrefs 캐시 자동 만료
- **최대 100개**: 메모리 사용 제한
- **처리된 ID 추적**: 중복 표시 방지 (SharedPrefs에 Set 저장)

## 📁 레이어별 책임

### Data Layer
**역할**: 외부 데이터 소스와의 통신 및 데이터 변환

**핵심 컴포넌트:**
- **Repository**: `NotificationRepositoryImpl` (이중 인터페이스 구현)
  - INotificationRepository (Domain 계약)
  - NotificationContract (App Layer 계약)
- **DataSources**:
  - Remote: Firebase Firestore 실시간 스트림 관리
  - Local: SharedPrefs 캐싱 (30분 TTL, 100개 제한)
- **DTOs**: Firestore 문서 구조에 맞춘 데이터 전송 객체
- **Mapper**: DTO ↔ Domain Model 양방향 변환

**핵심 기능:**
- Firebase 실시간 스트림 재사용 (중복 구독 방지)
- 30분 캐시 만료 시간 (최대 100개 알림)
- 배치 작업 최적화 (markAllAsRead)
- 에러 발생 시 캐시 폴백

**상세 문서**: [Data Layer README](./data/README.md)

### Domain Layer
**역할**: 비즈니스 로직과 규칙 정의 (프레임워크 독립적)

**핵심 컴포넌트:**
- **Models**: 순수 Dart 객체 (Firebase 의존성 제거)
  - `Notification` (추상 베이스 클래스): 공통 비즈니스 로직
  - `SystemNotification`: 시스템 공지 전용 필드 및 로직
  - `SocialNotification`: 소셜 상호작용 전용 필드 및 로직
- **UseCases**: 단일 비즈니스 작업 캡슐화
  - `WatchUserNotificationsUseCase`: 실시간 알림 스트림
  - `MarkAsReadUseCase`: 권한 검증 포함 읽음 처리
  - `WatchUnreadCountUseCase`: 뱃지 카운트 실시간 추적
- **Repository Interface**: Data Layer가 구현할 계약 정의
- **Value Objects**: `NotificationFilter` (불변 필터링 조건)

**비즈니스 규칙:**
1. 알림 만료 검증 (`isExpired`)
2. 읽음 처리 권한 검증 (본인만)
3. Idempotent 읽음 처리
4. 30일 경과 알림 자동 삭제 대상 (`shouldAutoDelete`)
5. 소셜 알림 그룹화 (동일 액션 24시간 이내)

**상세 문서**: [Domain Layer README](./domain/README.md)

### Presentation Layer
**역할**: UI 표시 및 사용자 상호작용

**핵심 컴포넌트:**
- **Providers**:
  - `NotificationOverlayProvider`: 실시간 알림 다이얼로그 표시
    - NotificationQueueService 스트림 구독
    - 타입별 다이얼로그 라우팅 (Voting, Social, System)
    - Port-Adapter 패턴으로 Voting Feature 통합
  - `NotificationAppBarAction`: AppBar 뱃지 실시간 업데이트
- **Screens**:
  - `NotificationsListWidget`: 알림 목록 전체 화면
    - StreamBuilder 기반 실시간 업데이트
    - 읽음/읽지 않음 시각적 구분 (opacity, fontWeight)
    - 빈 상태 UI (알림 없을 때)
- **Widgets**:
  - `NotificationBadge`: 재사용 가능한 뱃지 컴포넌트 (99+ 표시)
  - `NotificationIconWithBadge`: 아이콘 + 뱃지 헬퍼 위젯
- **Helpers**:
  - `NotificationDisplayHelper`: 타입별 아이콘/타이틀 매핑

**UI/UX 패턴:**
- 읽지 않은 알림: opacity 1.0, fontWeight bold, 파란색 점
- 읽은 알림: opacity 0.6, fontWeight normal
- 만료된 알림: opacity 0.6, 클릭 불가
- 뱃지 카운트: 99보다 크면 "99+" 표시

**상세 문서**: [Presentation Layer README](./presentation/README.md)

## 🔗 Feature 간 통합

### Voting Feature 통합 (Port-Adapter 패턴)

**통합 포인트**: `NotificationOverlayProvider._showVotingDialog()`

**Port 인터페이스**:
```dart
// core/domain/ports/i_notification_display_port.dart
abstract class INotificationDisplayPort {
  Future<void> showVotingNotification({
    required Notification notification,  // 베이스 Notification
    required BuildContext context,
    required Map<String, dynamic> displayData,
    required Future<void> Function(String) onVote,
    required void Function(bool hasVoted) onDismiss,
  });
}
```

**Voting Feature 구현체**:
```dart
// features/voting/data/adapters/voting_notification_display_adapter.dart
class VotingNotificationDisplayAdapter implements INotificationDisplayPort {
  @override
  Future<void> showVotingNotification({...}) async {
    // 1. Notification → VoteNotification 캐스팅
    final voteNotif = notification as VoteNotification;

    // 2. Voting Feature 자체 데이터 추출
    final question = voteNotif.data['question'];
    final optionA = voteNotif.data['optionA'];
    final optionB = voteNotif.data['optionB'];

    // 3. Voting Feature UI 표시
    await NotificationOverlay.showVoting(
      context: context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      onVote: onVote,
      onDismiss: onDismiss,
    );
  }
}
```

**DI 등록**:
```dart
// app/di.dart
getIt.registerLazySingleton<INotificationDisplayPort>(
  () => VotingNotificationDisplayAdapter(),
);
```

**호출 시퀀스**:
```
1. NotificationOverlayProvider receives Notification
2. Checks type == NotificationTypes.votingRequest
3. Calls _votingDisplayPort.showVotingNotification()
4. Voting Feature casts to VoteNotification
5. Voting Feature extracts its own data from notification.data
6. Voting Feature shows its own UI (NotificationOverlay.showVoting)
7. User votes → onVote callback
8. NotificationOverlayProvider marks as read
9. NotificationQueueService.notificationClosed()
```

**장점**:
- Notification Feature는 Voting Feature에 의존하지 않음
- Voting Feature는 자신의 UI와 데이터를 완전히 제어
- 새로운 알림 타입 추가 시 Port만 구현하면 됨

### Auth Feature 통합

**AuthContract 사용**:
```dart
// 현재 사용자 ID 가져오기
final authContract = getIt<AuthContract>();
final userId = authContract.getCurrentUserId();

// 알림 UseCase 호출
final notifications = await getNotifications.call(
  GetNotificationsParams(userId: userId),
);
```

**로그인 상태에 따른 알림 리스닝**:
```dart
authContract.onAuthStateChanged.listen((user) {
  if (user != null) {
    // 로그인 시 알림 리스닝 시작
    notificationOverlayProvider.startListening();
  } else {
    // 로그아웃 시 알림 리스닝 중지
    notificationOverlayProvider.stopListening();
  }
});
```

### App Layer 통합

**NotificationContract 구현**:
```dart
// app/contracts/notification_contract.dart
abstract class NotificationContract {
  Future<void> showNotification(Map<String, dynamic> notificationData);
  Stream<Map<String, dynamic>> getNotificationStream(String userId);
  Future<void> updateNotificationSettings(String userId, Map<String, bool> settings);
  Future<Map<String, bool>> getNotificationSettings(String userId);
}

// Repository가 구현
class NotificationRepositoryImpl
    implements INotificationRepository, NotificationContract {
  // ... 구현
}
```

## 🚀 주요 화면 구성

### 1. NotificationsListWidget
**경로**: `lib/features/notifications/presentation/screens/notifications_list/`
- 사용자의 모든 알림 목록 표시
- StreamBuilder 기반 실시간 업데이트
- 읽음/읽지 않음 시각적 구분 (opacity, fontWeight, 파란색 점)
- 만료된 알림 흐리게 표시 및 클릭 불가
- 빈 상태 UI (알림 없을 때)

### 2. NotificationAppBarAction
**경로**: `lib/features/notifications/presentation/providers/`
- AppBar에 통합되는 알림 아이콘 + 뱃지
- 읽지 않은 알림 개수 실시간 표시
- 99보다 크면 "99+" 표시
- 클릭 시 NotificationsListWidget로 네비게이션

### 3. NotificationOverlay (Voting Feature)
**경로**: `lib/features/voting/presentation/overlays/`
- NotificationOverlayProvider가 Port를 통해 호출
- 투표 다이얼로그 표시
- 사용자 투표 처리 및 결과 표시

## 🔧 기술 스택

### Core Architecture
- **Clean Architecture v4.0**: 완전한 레이어 분리 (Presentation → Domain ← Data)
- **Port-Adapter Pattern**: Feature 간 의존성 최소화
- **Contract Pattern**: App Layer 통합 (NotificationContract)
- **Repository Pattern**: 인터페이스 기반 데이터 접근 추상화
- **UseCase Pattern**: 단일 비즈니스 작업 캡슐화
- **Result<T> Type**: 안전한 에러 처리

### State Management
- **Provider Pattern**: ChangeNotifier 기반
- **GetIt**: 의존성 주입 (Service Locator)
- **StreamBuilder**: 실시간 UI 업데이트

### Backend & Services
- **Firebase**:
  - Firestore: 실시간 알림 스트림
  - Security Rules: userId 기반 권한 관리
- **SharedPreferences**: 로컬 캐싱 (30분 TTL, 100개 제한)
- **NotificationQueueService** (/services/): 알림 큐 관리 및 순차적 표시

### UI Components
- **StreamBuilder**: 실시간 데이터 구독 및 UI 업데이트
- **ListView.builder**: 알림 목록 효율적 렌더링
- **NotificationBadge**: 재사용 가능한 뱃지 컴포넌트
- **GoRouter**: 타입 안전 네비게이션

## 📚 관련 문서

### Layer READMEs
- [Data Layer README](./data/README.md) - Repository, DataSource, DTO, Mapper 세부 가이드
- [Domain Layer README](./domain/README.md) - Model, UseCase, Business Rules 세부 가이드
- [Presentation Layer README](./presentation/README.md) - Provider, Screen, Widget 세부 가이드

### Feature Documentation
- [Voting Feature](../voting/README.md) - VoteNotification 타입 처리 및 Port-Adapter 통합
- [Auth Feature](../auth/README.md) - AuthContract 사용 및 사용자 인증

### App Layer Documentation
- [App Contracts](../../app/contracts/README.md) - NotificationContract 인터페이스
- [NotificationQueueService](../../services/notification/README.md) - 실시간 알림 큐 관리
- [DI Container](../../app/di/README.md) - 의존성 주입 설정

### Project Documentation
- [Project CLAUDE.md](/CLAUDE.md) - 프로젝트 전체 구조
- [System ARCHITECTURE.md](/ARCHITECTURE.md) - 시스템 아키텍처
- [Clean Architecture Guide](/docs/architecture/clean-architecture.md)
- [Feature-First Structure](/docs/architecture/feature-first.md)

## 🤝 기여 가이드

### 코드 추가 시 체크리스트

**새로운 알림 타입 추가**:
- [ ] Domain Layer에 새 모델 클래스 추가 (extends Notification)
- [ ] Data Layer에 새 DTO 클래스 추가 (extends NotificationDto)
- [ ] NotificationMapper에 변환 로직 추가 (toDomain/toDto)
- [ ] NotificationDisplayHelper에 아이콘/타이틀 추가
- [ ] NotificationOverlayProvider에 다이얼로그 라우팅 추가
- [ ] (필요 시) Port 인터페이스 정의 및 구현

**새로운 UseCase 추가**:
- [ ] Domain Layer에 UseCase 클래스 생성 (`usecases/`)
- [ ] Repository 인터페이스에 메서드 추가 (필요 시)
- [ ] Data Layer에 Repository 구현 추가
- [ ] GetIt 의존성 주입 등록 (`app/di/notification_module.dart`)
- [ ] 단위 테스트 작성

**새로운 화면 추가**:
- [ ] Presentation Layer에 Screen 위젯 생성 (`screens/`)
- [ ] Provider 생성 및 ChangeNotifier 구현 (`providers/`)
- [ ] NotificationRoutes에 GoRouter 경로 등록
- [ ] Widget 테스트 작성

### 테스트 작성 가이드

**Unit Test** (Repository, UseCase):
```dart
// Example: MarkAsReadUseCase 테스트
test('본인 알림은 읽음 처리 성공', () async {
  // Arrange
  final mockRepository = MockINotificationRepository();
  final useCase = MarkAsReadUseCase(repository: mockRepository);
  final notification = SystemNotification(...);

  when(() => mockRepository.getNotification('notif1'))
    .thenAnswer((_) async => notification);

  // Act
  final result = await useCase.call(
    MarkAsReadParams(notificationId: 'notif1', userId: 'user1'),
  );

  // Assert
  expect(result.isSuccess, true);
  verify(() => mockRepository.markAsRead('notif1')).called(1);
});
```

**Widget Test** (Provider, Screen):
```dart
// Example: NotificationBadge 테스트
testWidgets('count가 99보다 크면 99+로 표시한다', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: NotificationBadge(
        count: 150,
        child: Icon(Icons.notifications),
      ),
    ),
  );

  expect(find.text('99+'), findsOneWidget);
});
```

### 코드 스타일 가이드

**Naming Conventions**:
- Repository 구현: `{Entity}RepositoryImpl`
- DataSource 구현: `Firebase{Entity}DataSource` 또는 `SharedPrefs{Entity}DataSource`
- DTO: `{Entity}Dto`
- UseCase: `{Action}{Entity}UseCase`
- Provider: `{Feature}Provider`

**File Organization**:
- 한 파일당 하나의 클래스 원칙
- 관련 파일은 서브디렉토리로 그룹화
- constants는 feature별로 분리하지 않고 공통 사용

**Documentation**:
- 모든 public 메서드에 Dart doc 주석 추가
- README 파일은 각 레이어마다 유지
- 복잡한 로직은 inline 주석으로 설명

---

**마지막 업데이트**: 2025-01-20
**버전**: v2.0.0 (Clean Architecture v4.0)
**유지관리자**: Notifications Feature Team
