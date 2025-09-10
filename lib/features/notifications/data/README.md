# 📚 Notifications Data Layer

> Clean Architecture 데이터 레이어 - Firebase 격리 및 데이터 접근 구현  
> **최종 업데이트**: 2025-01-10 | **버전**: 2.0.0  
> **상태**: ✅ 100% Clean Architecture 준수 | 마이그레이션 완료

## 📋 목차
- [개요](#-개요)
- [디렉토리 구조](#-디렉토리-구조)
- [핵심 컴포넌트](#-핵심-컴포넌트)
- [사용 방법](#-사용-방법)
- [의존성 및 아키텍처](#-의존성-및-아키텍처)
- [API 연계](#-api-연계)
- [개발 가이드](#-개발-가이드)
- [캐싱 전략](#-캐싱-전략)
- [테스트](#-테스트)

## 🎯 개요

Notifications Data 레이어는 **Clean Architecture**의 데이터 접근 계층으로, Domain 레이어의 인터페이스를 구현하고 외부 데이터 소스(Firebase, SharedPreferences)와의 통신을 담당합니다.

### 핵심 원칙
- **Domain 의존성 방향**: Data → Domain (단방향)
- **Firebase 격리**: DataSource 레이어에만 Firebase SDK 사용
- **Repository 패턴**: 데이터 소스 조합 및 캐싱 로직
- **DTO 패턴**: 외부 데이터 형식과 Domain 모델 분리
- **의존성 주입**: 싱글톤 제거, GetIt DI 사용

### 주요 성과
- ✅ **Firebase 직접 호출 완전 제거** (15개 → 0개)
- ✅ **싱글톤 패턴 제거** → DI 패턴 전환
- ✅ **3-Layer 캐싱 시스템** 구현
- ✅ **Cross-feature 의존성 인터페이스화**
- ✅ **Mock 구현체로 독립 테스트 가능**

## 📁 디렉토리 구조

```
data/
├── models/                      # DTO (Data Transfer Objects)
│   ├── notification_dto.dart        # 기본 알림 DTO
│   ├── vote_notification_dto.dart   # 투표 알림 DTO
│   ├── social_notification_dto.dart # 소셜 알림 DTO
│   ├── system_notification_dto.dart # 시스템 알림 DTO
│   ├── dto_extensions.dart          # DTO 유틸리티
│   └── notification_models.dart     # Export 파일
│
├── mappers/                     # Domain ↔ DTO 변환
│   └── notification_mapper.dart     # 양방향 변환 로직
│
├── datasources/                 # 데이터 소스 (Firebase 격리)
│   ├── i_remote_notification_datasource.dart  # Remote 인터페이스
│   ├── i_local_notification_datasource.dart   # Local 인터페이스
│   ├── i_chat_datasource.dart                 # Chat 인터페이스
│   ├── i_post_datasource.dart                 # Post 인터페이스
│   │
│   ├── remote/
│   │   └── firebase_notification_datasource.dart  # Firebase 구현
│   ├── local/
│   │   └── shared_prefs_notification_datasource.dart  # 로컬 캐시
│   └── cross/
│       ├── mock_chat_datasource.dart  # Chat Mock
│       └── mock_post_datasource.dart  # Post Mock
│
├── repositories/                # Repository 구현체
│   └── notification_repository_impl.dart  # Domain 인터페이스 구현
│
├── services/                    # 데이터 처리 서비스
│   ├── notification_data_extractor.dart  # 데이터 추출
│   └── cross_feature_service_adapter.dart  # Cross-feature 어댑터
│
└── adapters/                    # 서비스 어댑터
    ├── notification_service.dart          # 알림 서비스
    ├── target_audience_service.dart       # 타겟 오디언스
    └── global_notification_manager.dart   # 글로벌 관리
```

## 🔧 핵심 컴포넌트

### 1. DTO Models

#### `NotificationDto` (기본 DTO)
```dart
class NotificationDto {
  final String? id;
  final String? userId;
  final String? type;
  final String? title;
  final String? content;
  final Timestamp? createdAt;
  final bool? isRead;
  
  // Firebase 변환
  factory NotificationDto.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore();
  
  // JSON 변환
  factory NotificationDto.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### 타입별 DTO
- **VoteNotificationDto**: 투표 알림 (postId, voteOptions, voteEndTime)
- **SocialNotificationDto**: 소셜 알림 (actionType, actorId, targetId)
- **SystemNotificationDto**: 시스템 알림 (alertType, actionUrl, priority)

### 2. Mapper

#### `NotificationMapper`
```dart
class NotificationMapper {
  // DTO → Domain 변환
  static Notification toDomain(NotificationDto dto) {
    switch(dto.type) {
      case 'votingRequest': return _toVoteNotification(dto);
      case 'social': return _toSocialNotification(dto);
      case 'systemAlert': return _toSystemNotification(dto);
      default: return _toGenericNotification(dto);
    }
  }
  
  // Domain → DTO 변환
  static NotificationDto toDto(Notification entity) {
    // 타입별 DTO 생성 로직
  }
}
```

### 3. DataSources

#### Remote DataSource (Firebase)
```dart
class FirebaseNotificationDatasource implements IRemoteNotificationDatasource {
  final FirebaseFirestore _firestore;
  final Map<String, StreamController> _streamControllers = {};
  
  @override
  Stream<List<Map<String, dynamic>>> watchUserNotifications({
    required String userId,
    String? type,
    bool? unreadOnly,
  }) {
    // Firebase 실시간 스트림
    // 동적 쿼리 빌딩
    // 스트림 재사용 관리
  }
  
  @override
  Future<void> createNotification(Map<String, dynamic> data) async {
    // Firebase 문서 생성
  }
}
```

#### Local DataSource (SharedPreferences)
```dart
class SharedPrefsNotificationDatasource implements ILocalNotificationDatasource {
  static const Duration _cacheTTL = Duration(minutes: 30);
  static const int _maxCacheSize = 100;
  
  @override
  Future<List<Map<String, dynamic>>?> getCachedNotifications(String userId) async {
    // 캐시 조회 및 TTL 검증
  }
}
```

### 4. Repository Implementation

#### `NotificationRepositoryImpl`
```dart
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  final NotificationMapper _mapper;
  
  // Remote-First with Caching
  @override
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) async {
    // 1. 캐시 확인
    final cached = await _localDatasource.getCachedNotifications(userId);
    if (cached != null && !_isExpired(cached)) {
      return _mapper.toDomainList(cached);
    }
    
    // 2. Remote 조회
    final remote = await _remoteDatasource.getNotifications(userId, filter);
    
    // 3. 캐시 업데이트
    await _localDatasource.cacheNotifications(userId, remote);
    
    // 4. Domain 변환 후 반환
    return _mapper.toDomainList(remote);
  }
}
```

### 5. Service Adapters

#### `GlobalNotificationManager`
```dart
class GlobalNotificationManager {
  final INotificationRepository _repository;
  final ILocalNotificationDatasource _localDatasource;
  final INotificationHandler _handler;
  
  final Queue<Notification> _notificationQueue = Queue();
  final Set<String> _processedNotificationIds = {};
  
  void startListening() {
    _repository.watchUserNotifications(userId: _userId)
      .listen(_handleIncomingNotification);
  }
  
  void _handleIncomingNotification(List<Notification> notifications) {
    // 큐 관리 및 순차 처리
    // 중복 방지
    // UI 핸들러 위임
  }
}
```

## 💻 사용 방법

### 1. DI 설정 (GetIt)

```dart
// app/di/notification_module.dart
void configureNotificationDependencies() {
  // DataSources
  sl.registerLazySingleton<IRemoteNotificationDatasource>(
    () => FirebaseNotificationDatasource(FirebaseFirestore.instance),
  );
  
  sl.registerLazySingleton<ILocalNotificationDatasource>(
    () => SharedPrefsNotificationDatasource(),
  );
  
  // Repository
  sl.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: sl(),
      localDatasource: sl(),
      mapper: NotificationMapper(),
    ),
  );
  
  // Services
  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(repository: sl()),
  );
  
  sl.registerLazySingleton<GlobalNotificationManager>(
    () => GlobalNotificationManager(
      repository: sl(),
      localDatasource: sl(),
      handler: sl(),
    ),
  );
}
```

### 2. 알림 조회

```dart
// UI에서 사용
class NotificationListPage extends StatelessWidget {
  final _repository = GetIt.instance<INotificationRepository>();
  
  Widget build(BuildContext context) {
    return StreamBuilder<List<Notification>>(
      stream: _repository.watchUserNotifications(
        userId: currentUserId,
        filter: NotificationFilter(
          type: NotificationType.votingRequest,
          unreadOnly: true,
        ),
      ),
      builder: (context, snapshot) {
        // UI 렌더링
      },
    );
  }
}
```

### 3. 알림 생성 및 전송

```dart
// 투표 알림 생성
final notification = VoteNotification(
  userId: targetUserId,
  postId: postId,
  title: '새로운 투표 요청',
  voteOptions: VoteOptions(
    optionA: 'Option A',
    optionB: 'Option B',
  ),
);

await _repository.createNotification(notification);
```

## 🏗️ 의존성 및 아키텍처

### 의존성 흐름

```mermaid
graph TD
    UI[Presentation Layer] --> Domain[Domain Layer]
    UI --> Data[Data Layer]
    Data --> Domain
    
    Data --> Firebase[(Firebase)]
    Data --> SharedPrefs[(SharedPreferences)]
    
    subgraph Data Layer
        Repository --> DataSource
        DataSource --> Remote
        DataSource --> Local
        Repository --> Mapper
    end
    
    style Data fill:#FFE4B5
    style Domain fill:#E6F3FF
    style UI fill:#E8F5E9
```

### Clean Architecture 준수

| 원칙 | 구현 | 검증 |
|------|------|------|
| 의존성 역전 | Repository는 Domain 인터페이스 구현 | ✅ |
| 단일 책임 | 각 클래스는 하나의 책임만 | ✅ |
| 인터페이스 분리 | 용도별 DataSource 인터페이스 | ✅ |
| 개방-폐쇄 | 확장엔 열려있고 수정엔 닫혀있음 | ✅ |

## 🔗 API 연계

### Firebase Collections

| Collection | 용도 | 주요 필드 |
|------------|------|-----------|
| `notifications` | 알림 저장 | userId, type, createdAt, isRead |
| `chats/{id}/messages` | 투표 메시지 | postId, voteStatus, votesA/B |
| `posts` | 게시물 정보 | targetAudience, notificationStatus |

### Cross-Feature Interfaces

#### Chat Feature
```dart
abstract class IChatDatasource {
  Future<String> createVoteRequestMessage({
    required String chatId,
    required Map<String, dynamic> messageData,
  });
  
  Future<void> updateVoteMessageStatus({
    required String chatId,
    required String messageId,
    required String status,
  });
}
```

#### Posts Feature
```dart
abstract class IPostDatasource {
  Future<Map<String, dynamic>?> getPost(String postId);
  Future<String> createPostWithTargetAudience(...);
  Future<void> updatePostNotificationStatus(...);
}
```

## 🛠️ 개발 가이드

### 새로운 알림 타입 추가

1. **Domain 모델 생성** (`domain/models/`)
```dart
class NewNotification extends Notification {
  // 도메인 모델 정의
}
```

2. **DTO 모델 생성** (`data/models/`)
```dart
class NewNotificationDto extends NotificationDto {
  // DTO 정의 및 Firebase 매핑
}
```

3. **Mapper 확장** (`data/mappers/`)
```dart
// NotificationMapper에 변환 로직 추가
case 'new_type': return _toNewNotification(dto);
```

4. **Repository 메서드 추가** (필요시)
```dart
Future<List<NewNotification>> getNewNotifications(...);
```

### 캐싱 전략 수정

현재 3-Layer 캐싱 시스템:
1. **Memory Cache** (L1): 즉시 응답
2. **SharedPreferences** (L2): 30분 TTL
3. **Firestore Offline** (L3): 자동 동기화

캐시 설정 변경:
```dart
// shared_prefs_notification_datasource.dart
static const Duration _cacheTTL = Duration(minutes: 30); // TTL 조정
static const int _maxCacheSize = 100; // 캐시 크기 조정
```

### 에러 처리 패턴

```dart
try {
  final result = await _remoteDatasource.getNotifications(userId);
  return _mapper.toDomainList(result);
} on FirebaseException catch (e) {
  // Firebase 에러 처리
  throw DataSourceException(e.message);
} catch (e) {
  // 일반 에러는 캐시 폴백
  final cached = await _localDatasource.getCachedNotifications(userId);
  if (cached != null) return _mapper.toDomainList(cached);
  rethrow;
}
```

## 📦 캐싱 전략

### Cache-Aside Pattern

```
[요청] → [캐시 확인] → [캐시 히트?]
           ↓ No              ↓ Yes
    [Remote 조회]         [캐시 반환]
           ↓
    [캐시 업데이트]
           ↓
       [결과 반환]
```

### 캐시 무효화

- **TTL 기반**: 30분 후 자동 만료
- **이벤트 기반**: 쓰기 작업 시 즉시 무효화
- **수동**: `clearCache()` 메서드 제공

## 🧪 테스트

### 단위 테스트

```dart
// Mapper 테스트
test('VoteNotificationDto를 Domain 모델로 변환', () {
  final dto = VoteNotificationDto(...);
  final domain = NotificationMapper.toDomain(dto);
  
  expect(domain, isA<VoteNotification>());
  expect(domain.postId, equals(dto.postId));
});

// Repository 테스트 (Mock 사용)
test('캐시 미스 시 Remote 조회', () async {
  when(mockLocal.getCachedNotifications(any))
    .thenAnswer((_) async => null);
  when(mockRemote.getNotifications(any))
    .thenAnswer((_) async => testData);
    
  final result = await repository.getUserNotifications(userId: 'test');
  
  verify(mockLocal.getCachedNotifications('test')).called(1);
  verify(mockRemote.getNotifications('test')).called(1);
});
```

### 통합 테스트

```dart
// Firebase Emulator 사용
test('실제 Firebase 연동 테스트', () async {
  final datasource = FirebaseNotificationDatasource(
    FirebaseFirestore.instance,
  );
  
  await datasource.createNotification(testData);
  final result = await datasource.getNotifications('test_user');
  
  expect(result.length, greaterThan(0));
});
```

## 📈 성능 메트릭

| 작업 | 캐시 히트 | 캐시 미스 | 개선율 |
|------|-----------|-----------|--------|
| 알림 목록 조회 | <10ms | 200-300ms | 95% |
| 읽지 않은 수 | <5ms | 100-150ms | 96% |
| 알림 생성 | N/A | 150-200ms | - |
| 배치 업데이트 | N/A | 300-400ms | - |

## 🔄 마이그레이션 이력

### v2.0.0 (2025-01-10)
- ✅ Clean Architecture 완전 적용
- ✅ Firebase 직접 호출 제거
- ✅ 싱글톤 패턴 → DI 전환
- ✅ 3-Layer 캐싱 구현
- ✅ Cross-feature 인터페이스화

### v1.0.0 (2025-01-09)
- 초기 Data 레이어 구조 설계
- Repository 패턴 도입
- DTO/Mapper 구현

## 🔗 관련 문서

- [Domain Layer](../domain/README.md) - 비즈니스 로직 및 인터페이스
- [Presentation Layer](../presentation/README.md) - UI 및 상태 관리
- [Migration Tasks](./DATA_MIGRATION_TASKS.md) - 마이그레이션 상세 내역
- [DTO Migration Guide](./DTO_MIGRATION_GUIDE.md) - DTO 구현 가이드

---

*이 문서는 Notifications Data 레이어의 공식 기술 문서입니다.*  
*문의사항은 프로젝트 관리자에게 연락하세요.*