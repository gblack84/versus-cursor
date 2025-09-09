# 📦 Notifications Presentation Providers Layer

> Feature-First Architecture - 알림 프레젠테이션 상태 관리 레이어

## 📋 개요

알림 기능의 UI 상태를 관리하는 Provider 레이어입니다. Provider 패턴을 사용하여 알림 데이터와 UI 상태를 효율적으로 관리합니다.

## 🚨 현재 상황 (2025-01-09)

**Critical Issues**: Clean Architecture 심각한 위반
- **Domain 우회**: Presentation이 Data 레이어에 직접 접근 
- **Firebase 직접 사용**: UI 컴포넌트에서 Firestore 작업 수행
- **UseCase 미사용**: 비즈니스 로직이 Provider에 산재
- **Global Services 의존**: Feature가 전역 서비스에 의존

### 발견된 위반사항
1. **Data Layer 직접 접근** (Critical)
   - `notification_badge_provider.dart`: NotificationService 직접 사용
   - `notifications_list_widget.dart`: Repository 직접 접근
   
2. **Firebase Operations in UI** (Critical)
   - UI에서 `reference.update()` 직접 호출
   - FieldValue.serverTimestamp() 사용

3. **Missing UseCase Pattern** (Critical)
   - 모든 비즈니스 로직이 Provider/Widget에 존재
   - Domain 레이어 완전 우회

## 🏗️ 디렉토리 구조

```
presentation/providers/
├── notification_provider.dart           # 메인 알림 상태 관리
├── notification_badge_provider.dart     # 뱃지 카운트 관리
├── notification_filter_provider.dart    # 필터링 상태 관리
├── notification_settings_provider.dart  # 설정 상태 관리
└── fcm_provider.dart                   # FCM 상태 관리 (향후)
```

## 🔑 주요 Provider

### 1. NotificationProvider - 메인 알림 상태 관리

**역할**: 알림 목록과 상태를 관리하는 메인 Provider

**Dependencies**:
- `GetNotificationsUseCase`: 알림 목록 조회
- `MarkAsReadUseCase`: 읽음 처리
- `DeleteNotificationUseCase`: 알림 삭제

**상태 변수**:
- `notifications`: 알림 목록 (List<NotificationModel>)
- `isLoading`: 로딩 상태
- `hasMore`: 추가 데이터 존재 여부
- `error`: 에러 메시지
- `filterType`: 현재 필터 타입
- `currentOffset`: 페이지네이션 오프셋
- `pageSize`: 페이지 크기 (기본값: 20)

**주요 메서드**:
- `loadNotifications(userId)`: 초기 알림 로드
- `loadMore(userId)`: 추가 알림 로드 (페이지네이션)
- `refresh(userId)`: 새로고침
- `markAsRead(notificationId, userId)`: 개별 읽음 처리
- `markAllAsRead(userId)`: 전체 읽음 처리
- `deleteNotification(notificationId, userId)`: 알림 삭제
- `setFilter(type, userId)`: 필터 설정
- `addNotification(notification)`: 실시간 알림 추가
- `updateNotification(notification)`: 알림 업데이트

**Computed Properties**:
- `unreadCount`: 읽지 않은 알림 개수
- `notificationsByType`: 타입별 알림 그룹화

### 2. NotificationBadgeProvider - 뱃지 카운트 관리

**역할**: 알림 뱃지 카운트와 표시 상태를 관리하는 Provider

**Dependencies**:
- `GetUnreadCountUseCase`: 읽지 않은 알림 개수 조회

**상태 변수**:
- `totalUnreadCount`: 전체 읽지 않은 알림 개수
- `unreadCountByType`: 타입별 읽지 않은 알림 개수 Map
- `showBadge`: 뱃지 표시 여부

**주요 메서드**:
- `updateUnreadCount(userId)`: 전체 읽지 않은 개수 업데이트
- `updateUnreadCountByType(userId)`: 타입별 읽지 않은 개수 업데이트
- `subscribeToUnreadCount(userId)`: 실시간 스트림 구독
- `toggleBadgeVisibility()`: 뱃지 표시 토글
- `decrementCount()`: 카운트 감소
- `incrementCount()`: 카운트 증가
- `reset()`: 모든 카운트 초기화

**Helper Methods**:
- `getUnreadCount(type)`: 특정 타입의 읽지 않은 개수 조회

### 3. NotificationFilterProvider - 필터링 상태 관리

**역할**: 알림 필터링 옵션과 검색 상태를 관리하는 Provider

**필터 상태**:
- `selectedType`: 선택된 알림 타입 필터
- `selectedPriority`: 선택된 우선순위 필터
- `showOnlyUnread`: 읽지 않은 알림만 표시 여부
- `startDate`: 시작 날짜 필터
- `endDate`: 종료 날짜 필터
- `searchQuery`: 검색어

**주요 메서드**:
- `setTypeFilter(type)`: 타입 필터 설정
- `setPriorityFilter(priority)`: 우선순위 필터 설정
- `setShowOnlyUnread(value)`: 읽지 않은 알림만 표시 설정
- `setDateRange(start, end)`: 날짜 범위 설정
- `setSearchQuery(query)`: 검색어 설정
- `clearAllFilters()`: 모든 필터 초기화
- `applyFilters(notifications)`: 필터 적용

**Computed Properties**:
- `activeFilterCount`: 활성 필터 개수
- `hasActiveFilters`: 필터 활성 여부

**필터 적용 로직**:
1. 타입 필터: 선택된 타입만 표시
2. 우선순위 필터: 선택된 우선순위만 표시
3. 읽음 상태 필터: 읽지 않은 알림만 표시
4. 날짜 범위 필터: 지정된 기간 내 알림만 표시
5. 검색어 필터: 제목/메시지에 검색어 포함된 알림만 표시

### 4. NotificationSettingsProvider - 설정 상태 관리

**역할**: 알림 설정과 사용자 선호도를 관리하는 Provider

**Dependencies**:
- `SharedPreferences`: 설정 영구 저장

**설정 상태**:
- `typeEnabled`: 타입별 알림 활성화 Map
- `soundEnabled`: 알림음 활성화
- `vibrationEnabled`: 진동 활성화
- `doNotDisturb`: 방해 금지 모드
- `doNotDisturbStart`: 방해 금지 시작 시간
- `doNotDisturbEnd`: 방해 금지 종료 시간

**주요 메서드**:
- `init()`: SharedPreferences 초기화
- `setTypeEnabled(type, enabled)`: 타입별 알림 설정
- `setSoundEnabled(enabled)`: 사운드 설정
- `setVibrationEnabled(enabled)`: 진동 설정
- `setDoNotDisturb(enabled)`: 방해 금지 모드 설정
- `setDoNotDisturbTime(start, end)`: 방해 금지 시간 설정
- `isInDoNotDisturbTime()`: 현재 방해 금지 시간인지 확인
- `setAllTypesEnabled(enabled)`: 모든 타입 일괄 설정
- `resetToDefaults()`: 기본값으로 초기화

**Helper Methods**:
- `isTypeEnabled(type)`: 특정 타입 활성화 여부 확인

**설정 저장 키**:
- `notification_{type}_enabled`: 타입별 활성화
- `notification_sound_enabled`: 사운드 설정
- `notification_vibration_enabled`: 진동 설정
- `notification_do_not_disturb`: 방해 금지 모드
- `dnd_start_hour`, `dnd_start_minute`: 시작 시간
- `dnd_end_hour`, `dnd_end_minute`: 종료 시간

## 🧪 테스트 전략

### 단위 테스트

**NotificationProvider 테스트**:
- 알림 로드 성공/실패 케이스
- 페이지네이션 동작
- 읽음 처리 및 롤백
- 삭제 및 복원
- 필터 적용

**NotificationBadgeProvider 테스트**:
- 카운트 업데이트
- 증가/감소 로직
- 스트림 구독
- 타입별 카운트

**NotificationFilterProvider 테스트**:
- 필터 설정 및 초기화
- 필터 적용 결과
- 활성 필터 카운트
- 검색 기능

**NotificationSettingsProvider 테스트**:
- 설정 저장 및 로드
- 방해 금지 시간 계산
- 기본값 초기화
- 타입별 설정

## ✅ 체크리스트

### 구현 완료
- [x] NotificationProvider
- [x] NotificationBadgeProvider
- [x] NotificationFilterProvider
- [x] NotificationSettingsProvider

### 향후 구현
- [ ] FCMProvider (푸시 알림)
- [ ] NotificationGroupProvider (그룹화)
- [ ] NotificationAnimationProvider (애니메이션)

## 📚 참고 자료

- [Provider Package](https://pub.dev/packages/provider)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)

---

*이 문서는 Feature-First Architecture의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*