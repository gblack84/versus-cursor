# 📦 Notifications Data Datasources Layer

> Feature-First Clean Architecture - 알림 데이터 소스 레이어  
> **최종 업데이트**: 2025-01-09 | **상태**: 🔴 구현 필요 (0% 완료)

## 📋 현재 상황

**⚠️ 상태**: 구현 진행 중 (설계 완료, 코드 이동 대기)

**진행 상황**: 
- ✅ 인터페이스 설계 완료
- ✅ DTO 모델 의존성 정의 완료  
- ⏳ Firebase 코드 이동 대기 중
- ⏳ DI 바인딩 설정 대기 중

**중요**: 현재 datasources 레이어가 구현되지 않아 모든 데이터 접근 로직이 adapters와 repositories에 혼재되어 있습니다. 이는 Clean Architecture의 심각한 위반이며 단계별 마이그레이션이 진행 중입니다.

### 현재 문제점
- **Datasources 디렉토리**: README.md만 존재 (실제 구현 없음)
- **Firebase 직접 호출**: adapters/repositories에서 직접 Firestore 호출
- **캐싱 로직 혼재**: GlobalNotificationManager에 SharedPreferences 직접 사용
- **레이어 책임 혼재**: 데이터 접근과 비즈니스 로직이 분리되지 않음

## 🏗️ 목표 구조

```
data/datasources/
├── remote/
│   ├── i_remote_notification_datasource.dart    # 인터페이스
│   └── remote_notification_datasource_impl.dart # Firebase 구현
├── local/
│   ├── i_local_notification_datasource.dart     # 인터페이스
│   └── local_notification_datasource_impl.dart  # Hive/SharedPrefs 구현
├── post/
│   ├── i_post_datasource.dart                   # 인터페이스
│   └── post_datasource_impl.dart                # Posts 관련 구현
└── fcm/                                         # (향후)
    ├── i_fcm_datasource.dart
    └── fcm_datasource_impl.dart
```

## 🔗 DTO 모델과의 관계

### 의존성 명시
- **Datasource → DTO**: Datasource는 DTO 모델만 사용 (`data/models/notification_dto.dart`)
- **Datasource ❌ Domain**: Domain 모델 직접 사용 금지
- **변환 위치**: Repository에서 Mapper를 통해 DTO ↔ Domain 변환

### DTO 사용 예시
```dart
// datasources/remote/remote_notification_datasource_impl.dart
import '../../models/notification_dto.dart'; // DTO 모델 import

class RemoteNotificationDatasourceImpl {
  Future<NotificationDto?> getNotification(String id) async {
    final doc = await _firestore.collection('notifications').doc(id).get();
    return NotificationDto.fromFirestore(doc); // DTO 반환
  }
}
```

## 📦 구현 필요 파일 상세

### 1. RemoteNotificationDatasource (최우선)
**파일**: `remote/remote_notification_datasource_impl.dart`  
**현재 위치**: adapters와 repositories에 분산됨  
**이동할 코드**: 
- `notification_service.dart` (46-122줄): Firestore 쿼리 및 스트림
- `notification_repository_impl.dart` (96-227줄): CRUD 작업
- `global_notification_manager.dart` (230-276줄): 게시물 조회

```dart
// 인터페이스 정의
abstract class IRemoteNotificationDatasource {
  // Stream operations
  Stream<List<Map<String, dynamic>>> watchUserNotifications({
    required String userId,
    required String type,
    required bool unreadOnly,
  });
  
  Stream<int> watchUnreadCount({
    required String userId,
    required String type,
  });
  
  // CRUD operations
  Future<Map<String, dynamic>?> getNotification(String id);
  Future<String> createNotification(Map<String, dynamic> data);
  Future<void> updateNotification(String id, Map<String, dynamic> updates);
  Future<void> deleteNotification(String id);
  
  // Batch operations
  Future<void> batchUpdate(List<BatchUpdateRequest> requests);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteExpiredNotifications();
  
  // Chat integration
  Future<void> createVoteRequestMessage({
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

### 2. LocalNotificationDatasource
**파일**: `local/local_notification_datasource_impl.dart`  
**현재 위치**: GlobalNotificationManager (432-450줄)  
**이동할 코드**: SharedPreferences 처리 로직

```dart
abstract class ILocalNotificationDatasource {
  // Cache operations
  Future<List<Map<String, dynamic>>> getCachedNotifications(String userId);
  Future<void> cacheNotifications(String userId, List<Map<String, dynamic>> data);
  Future<void> clearCache(String userId);
  
  // Processed IDs tracking
  Future<Set<String>> getProcessedNotificationIds();
  Future<void> saveProcessedNotificationIds(Set<String> ids);
  Future<void> addProcessedId(String id);
  
  // Preferences
  Future<NotificationPreferences> getPreferences(String userId);
  Future<void> savePreferences(String userId, NotificationPreferences prefs);
}
```

### 3. PostDatasource (Cross-feature 분리)
**파일**: `post/post_datasource_impl.dart`  
**현재 위치**: TargetAudienceService  
**이동할 코드**: Posts 컬렉션 접근

```dart
abstract class IPostDatasource {
  Future<Map<String, dynamic>?> getPost(String postId);
  Future<String> createPost(Map<String, dynamic> postData);
  Future<void> updatePostNotificationStatus({
    required String postId,
    required Map<String, dynamic> status,
  });
}
```

## 🔌 API 연계 및 의존성

### Firebase Firestore
- **Collections**: 
  - `notifications` - 알림 데이터
  - `posts` - 게시물 데이터 (cross-feature)
  - `chats/messages` - 투표 요청 메시지
- **인덱스 필요**:
  ```
  notifications: [userId, type, read, expiryTime, createdAt]
  ```

### 로컬 저장소
- **SharedPreferences**: 처리된 알림 ID 추적
- **Hive** (향후): 구조화된 캐싱
- **TTL**: 30분 캐시 만료

### 외부 서비스
- **Firebase Functions**: 알림 생성 트리거
- **FCM** (향후): 푸시 알림

## 🔧 사용 방법

### 1. Datasource 초기화 (DI)
```dart
// app/di/modules/notification_module.dart
void setupNotificationDatasources() {
  // Remote datasource
  GetIt.I.registerLazySingleton<IRemoteNotificationDatasource>(
    () => RemoteNotificationDatasourceImpl(
      firestore: GetIt.I<FirebaseFirestore>(),
    ),
  );
  
  // Local datasource
  GetIt.I.registerLazySingleton<ILocalNotificationDatasource>(
    () => LocalNotificationDatasourceImpl(
      prefs: GetIt.I<SharedPreferences>(),
      hive: GetIt.I<HiveInterface>(), // 향후
    ),
  );
}
```

### 2. Repository에서 사용
```dart
class NotificationRepositoryImpl implements INotificationRepository {
  final IRemoteNotificationDatasource _remoteDatasource;
  final ILocalNotificationDatasource _localDatasource;
  
  @override
  Stream<List<NotificationEntity>> watchNotifications(String userId) {
    return _remoteDatasource
        .watchUserNotifications(userId: userId, type: 'votingRequest', unreadOnly: false)
        .map((dataList) => dataList.map(_mapToEntity).toList());
  }
  
  @override
  Future<List<NotificationEntity>> getCachedNotifications(String userId) async {
    final cached = await _localDatasource.getCachedNotifications(userId);
    return cached.map(_mapToEntity).toList();
  }
}
```

## 🚨 아키텍처 위반 현황

### Critical (즉시 수정)
1. **adapters에서 Firestore 직접 호출** 
   - `notification_service.dart`: 255줄 중 100줄+ Firebase 코드
   - `global_notification_manager.dart`: 493줄 중 50줄+ 데이터 접근

2. **repositories에서 복잡한 데이터 변환**
   - `notification_repository_impl.dart`: 비즈니스 로직과 데이터 접근 혼재

3. **Cross-feature 직접 의존**
   - Posts 컬렉션 직접 접근 (도메인 인터페이스 없음)

## 📊 코드 이동 매핑

| 현재 위치 | 이동할 코드 | 목표 Datasource | 우선순위 |
|----------|------------|----------------|----------|
| notification_service.dart (46-122) | Firestore 쿼리/스트림 | RemoteNotificationDatasource | 🔴 High |
| notification_repository_impl.dart (96-227) | CRUD 작업 | RemoteNotificationDatasource | 🔴 High |
| global_notification_manager.dart (230-276) | 게시물 조회 | PostDatasource | 🟡 Medium |
| global_notification_manager.dart (432-450) | SharedPreferences | LocalNotificationDatasource | 🟡 Medium |
| target_audience_service.dart (137, 171) | Posts 생성/업데이트 | PostDatasource | 🟢 Low |

## 🎯 마이그레이션 전략

### Phase 1: Remote Datasource (2-3시간)
1. 인터페이스 정의
2. Firestore 직접 호출 코드 이동
3. Repository에서 datasource 사용하도록 수정
4. 테스트 작성

### Phase 2: Local Datasource (1-2시간)
1. SharedPreferences 처리 분리
2. 캐싱 전략 구현
3. TTL 관리 로직

### Phase 3: Cross-feature 정리 (2시간)
1. PostDatasource 생성
2. 도메인 인터페이스 정의
3. DI 바인딩 업데이트

## ⚡ 성능 최적화 고려사항

### 쿼리 최적화
```dart
// Firestore 복합 인덱스 활용
.where('userId', isEqualTo: userId)
.where('type', isEqualTo: 'votingRequest')
.where('read', isEqualTo: false)
.where('expiryTime', isGreaterThan: Timestamp.now())
.orderBy('expiryTime', descending: false)
.orderBy('createdAt', descending: true)
.limit(20) // 페이지네이션
```

### 캐싱 전략
- **L1 캐시**: 메모리 (5분 TTL)
- **L2 캐시**: Hive (30분 TTL)
- **L3 캐시**: Firestore 오프라인 캐시

### 배치 처리
```dart
// Batch operations for performance
final batch = firestore.batch();
for (final request in requests) {
  batch.update(request.ref, request.data);
}
await batch.commit();
```

## ✅ 완료 체크리스트

### 구현 전
- [ ] 현재 코드 백업
- [ ] 테스트 시나리오 작성
- [ ] DI 설정 준비

### 구현 중
- [ ] RemoteNotificationDatasource 인터페이스
- [ ] RemoteNotificationDatasource 구현
- [ ] LocalNotificationDatasource 인터페이스
- [ ] LocalNotificationDatasource 구현
- [ ] PostDatasource 인터페이스
- [ ] PostDatasource 구현
- [ ] Repository 리팩토링
- [ ] Adapters 정리

### 구현 후
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 실행
- [ ] Import Guardian 실행 (위반 0 확인)
- [ ] BuildSentinel 실행
- [ ] 문서 업데이트

---

*Clean Architecture 준수를 위한 datasources 레이어 구현 가이드*  
*관련 문서: [MIGRATION_GUIDE.md](../adapters/MIGRATION_GUIDE.md)*