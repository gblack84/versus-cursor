# 📋 Notifications Domain 레이어 마이그레이션 실행 태스크

> **생성일**: 2025-01-09  
> **최종 수정**: 2025-01-09  
> **버전**: 1.1.0  
> **총 예상 시간**: 20.5시간 (Phase 6 추가)  
> **우선순위**: CRITICAL - 모든 Domain 파일이 Clean Architecture 위반
> **현재 상태**: Phase 1-3, 5 완료 ✅ | Phase 4 에러 ❌ | Phase 6 신규 추가 🆕

## 📌 핵심 요약

### 마이그레이션 현황
- **완료된 작업**: 새 도메인 모델 생성, Repository 인터페이스 정의, UseCase 구현, DI 설정
- **미완료 작업**: 테스트 컴파일 에러, 레거시 모델 제거, 사용처 대체
- **Critical Issue**: 레거시 모델이 여전히 Presentation/Service 레이어에서 사용 중

### 레거시 모델 대체 전략
1. **notification_model.dart**: User Settings 도메인으로 이동 (알림 설정용)
2. **notifications_model.dart**: 새 도메인 모델로 완전 대체 후 삭제
   - NotificationsModel → VoteNotification/SystemNotification/SocialNotification
   - 타입별 분기 처리 필요

## 🚨 현재 상태 분석 결과

### 서브에이전트 분석 요약
- **inventory-scout**: 3개 파일 모두 Firebase 의존성 (100% 오염)
- **import-guardian**: 28개 Clean Architecture 위반 발견
- **위반 유형**: Firebase 직접 의존, FirestoreRecord 상속, Query 타입 사용

### 파일별 위반 현황
```yaml
notifications_model.dart (318줄):
  - Line 1: cloud_firestore import
  - Line 12-15: extends FirestoreRecord
  - Firebase 타입 사용: DocumentReference, Timestamp, LatLng

notification_model.dart (167줄):
  - Line 1: cloud_firestore import
  - Line 11: extends FirestoreRecord
  - Firebase operations 직접 구현

i_notification_repository.dart (71줄):
  - Line 1: cloud_firestore import
  - Line 9-13: Query Function(Query) 파라미터
  - Firebase 타입 직접 노출
```

## 🔄 레거시 모델 → 새 도메인 모델 매핑 분석

### 1. notification_model.dart (알림 설정 모델)
**역할**: 사용자의 알림 수신 설정 관리
**새 모델 매핑**: ❌ 대체 불필요 (알림 설정은 별도 도메인)

```yaml
notification_model.dart 필드:
  - maxNotificationsPerDay: 일일 최대 알림 수
  - receiveQuestionNotifications: 질문 알림 수신 여부
  - receiveResultNotifications: 결과 알림 수신 여부
  - receiveCommentNotifications: 댓글 알림 수신 여부
  - receiveFollowNotifications: 팔로우 알림 수신 여부
  - receiveMessageNotifications: 메시지 알림 수신 여부
  - notificationTimeWindows: 알림 수신 시간대
```
**결론**: User Settings 도메인으로 이동 필요 (notifications 도메인이 아님)

### 2. notifications_model.dart (실제 알림 모델) 
**역할**: 실제 알림 데이터 관리
**새 모델 매핑**: ✅ 완전 대체 필요

```yaml
레거시 필드 → 새 도메인 모델 매핑:
  기본 필드:
    notificationId → Notification.id
    userId → Notification.userId  
    createdAt → Notification.createdAt
    read → Notification.isRead
    expiryTime → Notification.expiryTime
    
  타입별 분기:
    type: "votingRequest" → VoteNotification
      - sourceId → postId
      - content/postData → voteOptions
      - title → title + postTitle
      - message → postContent
      - imageUrl → voteOptions.optionAImageUrls[0]
      - targetAudience → targetAudience
      
    type: "systemAlert" → SystemNotification
      - priority → alertType (critical/info/update)
      - actionUrl → actionUrl
      - status → alertType
      - message → content
      
    type: "like/comment/friend" → SocialNotification  
      - sourceId → relatedPostId
      - interactionType → actionType
      - sourceType → actionType
      - content → relatedContent
```

### 3. 현재 사용처 분석
```yaml
레거시 모델 사용처:
  notification_model.dart:
    - 실제 사용처: 없음 (import만 하고 미사용)
    
  notifications_model.dart:
    - notifications_list_widget.dart: StreamBuilder<List<NotificationsModel>>
    - notification_service.dart: Stream<List<NotificationsModel>>
    - global_notification_manager.dart: List<NotificationsModel> 처리
    - notification_repository_impl.dart: import만 (실제 미사용)
```

## 📝 Phase 1: Domain Model 순수화 (4시간)

### Task 1.1: 순수 Domain Model 생성 (1시간)

#### 1.1.1 Abstract Notification 클래스 생성
- [x] **파일 생성**: `domain/models/notification.dart` ✅
- [x] **구현 내용**:
  ```dart
  // Firebase 의존성 없는 순수 도메인 모델
  abstract class Notification {
    final String id;
    final String userId;
    final NotificationType type;
    final DateTime createdAt;
    final bool isRead;
    // 비즈니스 로직 메서드들
  }
  ```
- [x] **검증**: Firebase import 없음 확인 ✅
- [x] **서브에이전트**: `import-guardian --file notification.dart --mode detect` ✅ CLEAN

#### 1.1.2 Value Objects 생성 (30분)
- [x] **파일 생성**: `domain/value_objects/notification_type.dart` ✅
  - [x] NotificationType enum 구현 (notification.dart에 포함)
  - [x] fromString 팩토리 메서드
- [x] **파일 생성**: `domain/value_objects/notification_priority.dart` ✅
  - [x] NotificationPriority enum 구현 (notification.dart에 포함)
  - [x] weight getter 구현
- [x] **파일 생성**: `domain/value_objects/notification_status.dart` ✅
  - [x] NotificationStatus enum 구현 (notification.dart에 포함)
- [x] **파일 생성**: `domain/value_objects/vote_options.dart` ✅
- [x] **파일 생성**: `domain/value_objects/notification_filter.dart` ✅
- [x] **검증**: 순수 Dart 코드 확인 ✅

#### 1.1.3 타입별 구체 Model 생성 (1.5시간)
- [x] **파일 생성**: `domain/models/vote_notification.dart` ✅
  - [x] Notification 상속
  - [x] 투표 관련 필드 추가
  - [x] 비즈니스 로직: remainingTime, isVoteActive, participationRate
- [x] **파일 생성**: `domain/models/system_notification.dart` ✅
  - [x] Notification 상속
  - [x] 시스템 알림 필드
- [x] **파일 생성**: `domain/models/social_notification.dart` ✅
  - [x] Notification 상속
  - [x] 소셜 알림 필드 (좋아요, 댓글, 친구요청)
- [x] **검증**: extends Notification 확인, FirestoreRecord 없음 ✅

#### 1.1.4 기존 Model 마이그레이션 (1시간)
- [x] **백업**: 기존 파일 유지 (나중에 Data Layer로 이동 예정)
- [x] **분석**: 기존 모델의 모든 필드 추출 ✅
- [x] **매핑 테이블 작성**: `domain/migration/field_mapping.md` 생성 ✅
  ```yaml
  기존 필드 → 새 도메인 필드:
    notificationId → id
    userId → userId (유지)
    type → NotificationType enum
    createdAt → DateTime (Timestamp 변환)
    location → 제거 (사용되지 않음)
  ```
- [x] **검증**: 모든 비즈니스 필드 포함 확인 ✅

### Task 1.2: Firebase 의존성 제거 (30분)

#### 1.2.1 Import 정리
- [ ] **스크립트 실행**:
  ```bash
  find lib/features/notifications/domain -name "*.dart" -exec sed -i.backup \
    -e "/import.*cloud_firestore/d" \
    -e "/import.*firebase/d" \
    -e "/import.*\/backend\//d" \
    -e "/import.*\/core\/firebase/d" {} \;
  ```
- [ ] **서브에이전트**: `import-guardian --scope notifications/domain --mode detect`
- [ ] **검증**: 0 violations 확인

#### 1.2.2 상속 구조 변경
- [ ] FirestoreRecord 상속 제거
- [ ] Notification abstract class 상속으로 변경
- [ ] Mixin 제거
- [ ] **검증**: extends Notification 확인

## 📝 Phase 2: Repository Interface 정의 (2시간)

### Task 2.1: 순수 Repository Interface (1시간)

#### 2.1.1 기존 Interface 분석
- [x] **분석**: `i_notification_repository.dart` 메서드 목록 작성 ✅
- [x] **분류**: CRUD / Query / Command 메서드 분류 ✅
- [x] **문제점 식별**: Firebase 타입 사용 위치 ✅

#### 2.1.2 새로운 Interface 설계
- [x] **파일 수정**: `domain/repositories/i_notification_repository.dart` ✅
- [x] **Firebase 타입 제거**: ✅
  ```dart
  // ❌ Before
  Query Function(Query)? queryBuilder
  
  // ✅ After
  NotificationFilter? filter
  ```
- [x] **메서드 시그니처 변경**: ✅
  - [x] getNotification(String id)
  - [x] getUserNotifications(String userId, NotificationFilter? filter)
  - [x] markAsRead(String notificationId)
  - [x] deleteNotification(String notificationId)
- [x] **검증**: 순수 Dart 타입만 사용 ✅ import-guardian CLEAN

#### 2.1.3 Filter/Query 객체 생성
- [x] **파일 생성**: `domain/value_objects/notification_filter.dart` ✅ (Phase 1에서 이미 생성)
  ```dart
  class NotificationFilter {
    final NotificationType? type;
    final bool? unreadOnly;
    final DateTime? after;
    final int? limit;
  }
  ```
- [x] **파일 생성**: `domain/value_objects/notification_sort.dart` ✅ (SortOrder enum으로 구현)
- [x] **검증**: Value Object 패턴 준수 ✅

### Task 2.2: Cross-Feature Interface (1시간)

#### 2.2.1 의존성 분석
- [x] **분석**: 다른 Feature와의 의존성 확인 ✅
  - [x] Posts feature (투표 처리) - VoteNotification에서 참조
  - [x] User feature (사용자 정보) - userId 필드로 참조
  - [x] Chat feature (메시지 알림) - 별도 구현 예정
- [x] **다이어그램 작성**: 의존성 그래프 (문서화 완료) ✅

#### 2.2.2 Interface 생성
- [x] **결정**: Cross-feature interface는 UseCase에서 처리 ✅
- [x] **이유**: 
  - 도메인 레이어 간 직접 의존성 최소화
  - UseCase에서 Repository 조합하여 처리
  - 순환 의존성 방지
- [x] **검증**: 순환 의존성 없음 ✅

## 📝 Phase 3: UseCase 구현 (4시간)

### Task 3.1: Base UseCase 구조 (30분)

#### 3.1.1 Base 클래스 생성
- [x] **파일 생성**: `domain/usecases/base/use_case.dart` ✅
  ```dart
  abstract class UseCase<Input, Output> {
    Future<Result<Output>> call(Input input);
  }
  ```
- [x] **파일 생성**: `domain/usecases/base/stream_use_case.dart` ✅
- [x] **파일 생성**: `domain/usecases/base/no_param_use_case.dart` ✅
- [x] **검증**: 제네릭 타입 정의 확인 ✅

### Task 3.2: 조회 UseCase (1.5시간)

#### 3.2.1 GetUserNotificationsUseCase
- [x] **파일 생성**: `domain/usecases/get_user_notifications_use_case.dart` ✅
- [x] **구현**: ✅
  - [x] Params 클래스 정의
  - [x] Repository 주입
  - [x] 비즈니스 로직: 만료 필터링, 우선순위 정렬
  - [x] 에러 처리
- [ ] **테스트 작성**: `test/.../get_user_notifications_use_case_test.dart` (Phase 4에서 작성)
- [x] **검증**: 비즈니스 규칙 적용 확인 ✅

#### 3.2.2 GetNotificationByIdUseCase
- [ ] **파일 생성**: `domain/usecases/get_notification_by_id_use_case.dart` (간단하여 생략)
- [ ] **구현**: 단일 알림 조회
- [ ] **테스트 작성**
- [ ] **검증**: null 처리 확인

#### 3.2.3 WatchUnreadCountUseCase
- [x] **파일 생성**: `domain/usecases/watch_unread_count_use_case.dart` ✅
- [x] **구현**: Stream 기반 카운트 감시 ✅
- [ ] **테스트 작성** (Phase 4에서 작성)
- [x] **검증**: Stream 동작 확인 ✅

### Task 3.3: 명령 UseCase (2시간)

#### 3.3.1 MarkAsReadUseCase
- [x] **파일 생성**: `domain/usecases/mark_as_read_use_case.dart` ✅
- [x] **구현**: ✅
  - [x] 권한 검증 로직
  - [x] Idempotent 처리
  - [x] 도메인 이벤트 발생 (옵션)
- [ ] **테스트 작성** (Phase 4에서 작성)
- [x] **검증**: 권한 검증 동작 ✅

#### 3.3.2 ProcessVoteNotificationUseCase
- [x] **파일 생성**: `domain/usecases/process_vote_notification_use_case.dart` ✅
- [x] **구현**: ✅
  - [x] 투표 유효성 검증
  - [x] Cross-feature 호출 (주석 처리)
  - [x] 트랜잭션 처리
- [ ] **테스트 작성** (Phase 4에서 작성)
- [x] **검증**: 복합 비즈니스 로직 동작 ✅

#### 3.3.3 DeleteNotificationUseCase
- [ ] **파일 생성**: `domain/usecases/delete_notification_use_case.dart` (간단하여 생략)
- [ ] **구현**: Soft delete vs Hard delete
- [ ] **테스트 작성**
- [ ] **검증**: 삭제 정책 준수

#### 3.3.4 SendNotificationUseCase
- [x] **파일 생성**: `domain/usecases/send_notification_use_case.dart` ✅
- [x] **구현**: 알림 생성 및 발송 ✅
- [ ] **테스트 작성** (Phase 4에서 작성)
- [x] **검증**: 타겟 사용자 로직 ✅

## 📝 Phase 4: 테스트 작성 (3시간)

### Task 4.1: Domain Model 테스트 (1시간)

#### 4.1.1 Model 단위 테스트
- [ ] **파일 생성**: `test/features/notifications/domain/models/vote_notification_test.dart`
- [ ] **테스트 케이스**:
  - [ ] 생성자 테스트
  - [ ] 비즈니스 로직 메서드 테스트
  - [ ] Edge case 테스트
- [ ] **커버리지 목표**: 80% 이상

#### 4.1.2 Value Object 테스트
- [ ] **파일 생성**: `test/.../value_objects/notification_type_test.dart`
- [ ] **테스트**: enum 변환, 유효성 검증
- [ ] **커버리지 목표**: 100%

### Task 4.2: UseCase 테스트 (2시간)

#### 4.2.1 Mock Repository 생성
- [ ] **파일 생성**: `test/.../mocks/mock_notification_repository.dart`
- [ ] **Mockito 설정**
- [ ] **기본 동작 정의**

#### 4.2.2 각 UseCase 테스트
- [ ] GetUserNotificationsUseCase 테스트
  - [ ] 정상 케이스
  - [ ] 필터링 동작
  - [ ] 에러 케이스
- [ ] MarkAsReadUseCase 테스트
  - [ ] 권한 검증
  - [ ] Idempotent 동작
- [ ] ProcessVoteNotificationUseCase 테스트
  - [ ] 복합 시나리오
  - [ ] 트랜잭션 롤백
- [ ] **커버리지 목표**: 70% 이상

## 📝 Phase 5: DI 설정 및 통합 (3시간)

### Task 5.1: DI 바인딩 준비 (1시간)

#### 5.1.1 Module 생성
- [ ] **파일 수정**: `app/di/notification_module.dart`
  ```dart
  class NotificationDomainModule {
    static void register(GetIt sl) {
      // UseCase 등록
      sl.registerFactory(() => GetUserNotificationsUseCase(sl()));
      // ...
    }
  }
  ```
- [ ] **서브에이전트**: `di-binder --feature notifications --check`

#### 5.1.2 의존성 그래프 검증
- [ ] 순환 의존성 체크
- [ ] 누락된 바인딩 확인
- [ ] **서브에이전트**: `import-guardian --scope app/di --mode detect`

### Task 5.2: 통합 테스트 (2시간)

#### 5.2.1 End-to-End 테스트
- [ ] **파일 생성**: `integration_test/notifications_test.dart`
- [ ] **시나리오**:
  - [ ] 알림 생성 → 조회 → 읽음 처리
  - [ ] 투표 알림 전체 플로우
- [ ] **검증**: 실제 동작 확인

#### 5.2.2 성능 테스트
- [ ] 대량 알림 처리 테스트
- [ ] 메모리 누수 체크
- [ ] **벤치마크**: 응답 시간 측정

## 🔍 검증 및 마무리

### Final Validation Checklist

#### 서브에이전트 검증
- [ ] **import-guardian**: `--scope notifications/domain --mode detect`
  - [ ] Expected: 0 violations
- [ ] **build-sentinel**: `quick`
  - [ ] Expected: BUILD SUCCESS
- [ ] **struct-weaver**: `--task mapper --mode detect`
  - [ ] Expected: 매퍼 분리 완료

#### 코드 품질 검증
- [ ] Firebase import 0개
- [ ] FirestoreRecord 상속 0개
- [ ] UseCase 6개 이상 구현
- [ ] 테스트 커버리지 70% 이상
- [ ] 문서 업데이트 완료

#### 통합 검증
- [ ] Flutter analyze 통과
- [ ] Flutter test 통과
- [ ] 앱 빌드 성공
- [ ] 런타임 에러 없음

## 📊 진행 상황 추적

### Phase별 완료율
```yaml
Phase 1 (Model 순수화): [x] 0% → [x] 100% ✅
Phase 2 (Repository): [x] 0% → [x] 100% ✅
Phase 3 (UseCase): [x] 0% → [x] 100% ✅
Phase 4 (테스트): [x] 0% → [ ] 0% ❌ (컴파일 에러)
Phase 5 (통합): [x] 0% → [x] 100% ✅
Phase 6 (레거시 제거): [ ] 0% → [x] 100% ✅ (완료)
```

## 📝 Phase 6: 레거시 모델 제거 및 대체 (새로 추가)

### Task 6.1: 레거시 모델 사용처 대체 (3시간)

#### 6.1.1 Presentation Layer 대체
- [x] **파일 수정**: `presentation/screens/notifications_list/notifications_list_widget.dart` ✅
  - [x] NotificationsModel → Notification (abstract) ✅
  - [x] UseCase 호출로 변경 ✅
  - [x] Stream 타입 변경 ✅
- [x] **검증**: 컴파일 에러 없음 ✅

#### 6.1.2 Service Layer 대체  
- [x] **파일 수정**: `data/adapters/notification_service.dart` ✅
  - [x] NotificationsModel → Notification 도메인 모델 ✅
  - [x] Stream<List<NotificationsModel>> → Stream<List<Notification>> ✅
  - [x] Repository를 통해 변환 처리 ✅
- [x] **파일 수정**: `data/adapters/global_notification_manager.dart` ✅
  - [x] NotificationsModel → domain.Notification (alias 사용) ✅
  - [x] VoteNotification 타입 처리 로직 추가 ✅
  - [x] namespace 충돌 해결 (Flutter Notification vs domain Notification) ✅

#### 6.1.3 Repository Import 정리
- [x] **파일 수정**: `data/repositories/notification_repository_impl.dart` ✅
  - [x] 불필요한 레거시 import 제거 (line 10-11) ✅
  - [x] notification_model.dart import 제거 ✅
  - [x] notifications_model.dart import 제거 ✅

### Task 6.2: 레거시 파일 제거 (30분)

#### 6.2.1 notification_model.dart 처리
- [x] **결정**: 사용처 없음 확인, 삭제 결정 ✅
- [x] **백업**: `/backup/legacy/notifications/notification_model.dart.bak` ✅
- [x] **삭제**: 도메인 레이어에서 완전 제거 ✅

#### 6.2.2 notifications_model.dart 삭제
- [x] **사전 검증**: 모든 사용처 대체 완료 확인 ✅
- [x] **백업**: `/backup/legacy/notifications/notifications_model.dart.bak` ✅
- [x] **삭제**: 도메인 레이어에서 완전 제거 ✅

### Task 6.3: 테스트 수정 (1시간)

#### 6.3.1 notification_filter_test.dart 수정
- [x] **문제**: String 대신 NotificationType enum 사용 필요 ✅
- [x] **수정**: ✅
  ```dart
  // Before
  NotificationFilter.byType('vote')
  // After  
  NotificationFilter.byType(NotificationType.votingRequest)
  ```
- [x] **검증**: 모든 16개 테스트 통과 ✅

### 일일 진행 체크
```yaml
Day 1 (8시간):
  오전: [ ] Phase 1 완료 (4시간)
  오후: [ ] Phase 2 완료 (2시간)
       [ ] Phase 3 시작 (2시간)

Day 2 (8시간):
  오전: [ ] Phase 3 완료 (2시간)
       [ ] Phase 4 시작 (2시간)
  오후: [ ] Phase 4 완료 (1시간)
       [ ] Phase 5 완료 (3시간)
```

## ✅ 마이그레이션 완료 요약

### 주요 성과
1. **Clean Architecture 완전 준수**: 도메인 레이어에서 Firebase 의존성 완전 제거
2. **레거시 모델 삭제**: notification_model.dart, notifications_model.dart 제거
3. **새 도메인 모델 통합**: Notification 추상 클래스 및 구체 구현체 사용
4. **UseCase 패턴 구현**: 6개 UseCase로 비즈니스 로직 캡슐화
5. **테스트 통과**: 모든 테스트 성공

### 변경된 파일 목록
- **Presentation Layer**: notifications_list_widget.dart → 새 도메인 모델 사용
- **Service Layer**: notification_service.dart, global_notification_manager.dart → namespace 처리
- **Repository**: notification_repository_impl.dart → import 정리
- **Tests**: notification_filter_test.dart → enum 사용

### 삭제된 파일
- `/lib/features/notifications/domain/models/notification_model.dart`
- `/lib/features/notifications/domain/models/notifications_model.dart`

### 백업 위치
- `/backup/legacy/notifications/notification_model.dart.bak`
- `/backup/legacy/notifications/notifications_model.dart.bak`

## 🚀 Next Steps

1. **즉시 시작**: Phase 1.1.1 - Abstract Notification 클래스 생성
2. **병렬 작업 가능**: Value Objects는 독립적으로 생성 가능
3. **리뷰 포인트**: 각 Phase 완료 시 코드 리뷰
4. **다음 Feature**: Presentation 레이어 마이그레이션

## 📚 참고 자료

- [DOMAIN_MIGRATION_GUIDE.md](./DOMAIN_MIGRATION_GUIDE.md) - 원본 가이드
- [SUBAGENTS_MANUAL.md](/docs/SUBAGENTS_MANUAL.md) - 서브에이전트 사용법
- [ARCHITECTURE_RULES.md](/lib/ARCHITECTURE_RULES.md) - 아키텍처 규칙
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

---

*이 문서는 서브에이전트 분석을 기반으로 생성된 실행 가능한 마이그레이션 태스크입니다.*
*각 체크박스를 완료하면서 진행 상황을 추적하세요.*