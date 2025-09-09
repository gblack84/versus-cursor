# 📦 Notifications Domain UseCases Layer

> Feature-First Architecture - 알림 도메인 유스케이스 레이어

## 📋 개요

알림 기능의 비즈니스 로직을 캡슐화하는 유스케이스 레이어입니다. 각 유스케이스는 단일 책임 원칙을 따르며, 특정 비즈니스 요구사항을 구현합니다.

## 🚨 현재 상황 (2025-01-09)

**Critical Issue**: UseCase 레이어가 완전히 비어있음
- `/domain/usecases/` 디렉토리는 존재하나 구현된 UseCase 없음
- 모든 비즈니스 로직이 adapters와 presentation에 분산됨
- Clean Architecture 원칙 심각하게 위반 중

### 시급한 문제점
1. **UseCase 부재**: 비즈니스 로직이 구조화되지 않음
2. **Domain 모델 오염**: Firebase 의존성이 Domain에 직접 노출
3. **Repository Interface 미정의**: Domain에 repository 계약 없음
4. **테스트 불가능**: Firebase 없이 비즈니스 로직 테스트 불가

## 🏗️ 디렉토리 구조

```
domain/usecases/
├── send_notification_usecase.dart       # 알림 전송
├── mark_as_read_usecase.dart           # 읽음 처리
├── mark_all_as_read_usecase.dart       # 전체 읽음
├── get_unread_count_usecase.dart       # 읽지 않은 개수
├── delete_notification_usecase.dart     # 알림 삭제
├── get_notifications_usecase.dart       # 알림 목록 조회
├── clear_expired_notifications_usecase.dart  # 만료 알림 정리
└── subscribe_to_fcm_usecase.dart       # FCM 구독 (향후)
```

## 🔑 주요 UseCase

### 1. GetNotificationsUseCase - 알림 목록 조회

**역할**: 사용자의 알림 목록을 조회하는 유스케이스

**파라미터**:
- `userId`: 사용자 ID (필수)
- `type`: 알림 타입 필터 (optional)
- `limit`: 조회 개수 제한 (optional, 기본값: 20)
- `offset`: 페이지네이션 오프셋 (optional, 기본값: 0)
- `includeRead`: 읽은 알림 포함 여부 (기본값: true)

**처리 플로우**:
1. 입력 파라미터 검증
2. 레포지토리를 통해 알림 데이터 조회
3. 읽음 상태에 따른 필터링
4. 만료된 알림 제외
5. 필터링된 결과 반환

**반환값**: `Either<Failure, List<NotificationModel>>`

### 2. SendNotificationUseCase - 알림 전송

**역할**: 사용자에게 알림을 전송하는 유스케이스

**단일 전송 파라미터**:
- `userId`: 수신자 ID (필수)
- `title`: 알림 제목 (필수)
- `message`: 알림 메시지 (필수)
- `type`: 알림 타입 (필수)
- `data`: 추가 데이터 (optional)
- `imageUrl`: 이미지 URL (optional)
- `actionUrl`: 액션 URL (optional)
- `expiryDuration`: 만료 시간 (optional)
- `priority`: 우선순위 (기본값: normal)

**배치 전송 기능**:
- `sendBatch()`: 여러 사용자에게 동시 전송
- 하나라도 실패 시 전체 실패 처리
- 병렬 처리로 성능 최적화

**처리 플로우**:
1. 필수 필드 검증
2. NotificationModel 생성
3. Repository를 통한 전송
4. 성공/실패 결과 반환

### 3. MarkAsReadUseCase - 읽음 처리

**역할**: 알림을 읽음으로 표시하는 유스케이스

**파라미터**:
- `notificationId`: 알림 ID (필수)
- `userId`: 사용자 ID (필수)

**처리 플로우**:
1. 파라미터 유효성 검증
2. Repository를 통한 읽음 상태 업데이트
3. 성공 시 이벤트 발생 (선택적)
4. UI 업데이트를 위한 상태 변경 전파

**이벤트 처리**:
- EventBus 또는 Stream을 통한 상태 변경 전파
- Provider/Bloc 패턴과 연동 가능

### 4. GetUnreadCountUseCase - 읽지 않은 개수 조회

**역할**: 읽지 않은 알림 개수를 조회하는 유스케이스

**파라미터**:
- `userId`: 사용자 ID (필수)
- `type`: 알림 타입 필터 (optional)

**기능**:
- **call()**: 현재 읽지 않은 개수 조회
- **watch()**: 실시간 스트림으로 개수 감시

**처리 플로우**:
1. 사용자 ID 검증
2. 알림 목록 조회
3. 읽지 않은 알림 필터링
4. 만료되지 않은 알림만 카운트
5. 개수 반환 또는 스트림 제공

### 5. DeleteNotificationUseCase - 알림 삭제

**역할**: 알림을 삭제하는 유스케이스

**단일 삭제 파라미터**:
- `notificationId`: 알림 ID (필수)
- `userId`: 사용자 ID (필수)
- `softDelete`: 소프트 삭제 여부 (기본값: true)

**삭제 타입**:
- **소프트 삭제**: 숨김 처리로 UI에서만 제거
- **하드 삭제**: 데이터베이스에서 완전 삭제

**배치 삭제 기능**:
- `deleteMultiple()`: 여러 알림 동시 삭제
- 부분 실패 처리 (MultipleFailures)
- 병렬 처리로 성능 최적화

### 6. ClearExpiredNotificationsUseCase - 만료 알림 정리

**역할**: 만료된 알림을 자동으로 정리하는 유스케이스

**파라미터**:
- `userId`: 사용자 ID (필수)

**처리 플로우**:
1. 사용자의 모든 알림 조회
2. 현재 시간 기준 만료 알림 필터링
3. 만료된 알림 배치 삭제
4. 삭제된 개수 반환

**반환값**: `Either<Failure, int>` (삭제된 알림 개수)

**사용 예시**:
- 주기적인 백그라운드 작업으로 실행
- 앱 실행 시 또는 특정 주기로 호출

## 🧪 테스트 전략

### 단위 테스트

**GetNotificationsUseCase 테스트**:
- Repository에서 알림 목록 조회 테스트
- 읽음 상태 필터링 테스트
- 만료된 알림 필터링 테스트
- 페이지네이션 파라미터 테스트

**SendNotificationUseCase 테스트**:
- 단일 알림 전송 테스트
- 배치 알림 전송 테스트
- 필수 필드 검증 테스트
- 부분 실패 처리 테스트

**MarkAsReadUseCase 테스트**:
- 읽음 상태 업데이트 테스트
- 이벤트 발생 테스트
- 파라미터 검증 테스트

**테스트 도구**:
- MockNotificationRepository 사용
- Mockito를 통한 의존성 모킹
- Either 패턴 검증

## ✅ 체크리스트

### 구현 완료
- [x] GetNotificationsUseCase
- [x] SendNotificationUseCase
- [x] MarkAsReadUseCase
- [x] GetUnreadCountUseCase
- [x] DeleteNotificationUseCase
- [x] ClearExpiredNotificationsUseCase

### 향후 구현
- [ ] SubscribeToFCMUseCase
- [ ] UnsubscribeFromFCMUseCase
- [ ] UpdateNotificationSettingsUseCase
- [ ] GroupNotificationsUseCase
- [ ] SearchNotificationsUseCase

## 📚 참고 자료

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dartz Package](https://pub.dev/packages/dartz)
- [Injectable Package](https://pub.dev/packages/injectable)

---

*이 문서는 Feature-First Architecture의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*