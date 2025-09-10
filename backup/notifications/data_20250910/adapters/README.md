# 📦 Notifications Data Adapters Layer

> Feature-First Architecture - 알림 서비스 구현 레이어  
> **최종 업데이트**: 2025-01-09 | **상태**: ⚠️ 아키텍처 개선 필요

## 📋 현재 상황

알림 기능의 데이터 레이어 어댑터로서 Firebase와 UI 간의 브릿지 역할을 수행합니다.  
**중요**: 현재 Clean Architecture 위반 사항이 있어 마이그레이션이 필요합니다.

## 🏗️ 현재 구조

```
data/adapters/
├── notification_service.dart          # 알림 핵심 서비스 (254줄)
├── global_notification_manager.dart   # 전역 알림 관리 (492줄) ⚠️
├── target_audience_service.dart       # 타겟 오디언스 서비스 (271줄)
└── README.md                          # 본 문서
```

## 📦 구현 파일 상세

### NotificationService
- **파일**: `notification_service.dart` (254줄)
- **역할**: Firebase 알림 리스닝 및 처리
- **주요 기능**:
  - Firestore notifications 컬렉션 실시간 감시
  - 투표 요청 알림 필터링 (type: 'votingRequest')
  - 읽지 않은 알림 카운트 스트림 제공
  - 투표 요청 채팅 메시지 생성
  - AI 채팅 메시지 상태 업데이트
- **의존성**: 
  - ✅ Domain 모델 (`NotificationsModel`, `PostsModel`)
  - ✅ Domain 인터페이스 (`INotificationRepository`)
- **아키텍처 준수**: ✅ Clean

### GlobalNotificationManager
- **파일**: `global_notification_manager.dart` (492줄)
- **역할**: 전역 알림 큐 관리 및 UI 표시
- **주요 기능**:
  - 알림 큐 관리 (순차적 표시)
  - 중복 알림 방지 (SharedPreferences 활용)
  - 알림 다이얼로그 직접 표시 ⚠️
  - 투표 처리 로직 통합
- **의존성**:
  - ✅ Domain 모델
  - 🚨 **Presentation 위젯 직접 import** (`VotingNotificationDialog`)
  - 🚨 **Cross-feature 의존** (`auth`, `posts`)
- **아키텍처 준수**: ❌ **Critical Violation**

### TargetAudienceService  
- **파일**: `target_audience_service.dart` (271줄)
- **역할**: AI 기반 사용자 타겟팅
- **주요 기능**:
  - 타겟 모드별 사용자 선택 (quick/public/custom/test)
  - 사용자 프로필 필터링
  - 관련성 점수 계산
  - 랜덤 사용자 선택
- **의존성**:
  - ✅ Domain 모델
  - ⚠️ Cross-feature 의존 (`users` 모델)
- **아키텍처 준수**: ⚠️ Minor Issues

## 🔌 API 연계 현황

### Firebase Firestore
- **Collections**: `notifications`, `posts`, `users`, `chats`, `messages`
- **실시간 리스너**: 4개 활성 스트림
- **쿼리 최적화**: 복합 인덱스 사용

### Firebase Functions
- `onPostCreatedSendNotifications`: 투표 알림 생성 트리거
- `processVoteCompletion`: 투표 완료 처리
- `getUserPostingHistory`: AI 사용자 분석

### 외부 서비스
- **Gemini AI**: 사용자 매칭 및 콘텐츠 분석
- **SharedPreferences**: 로컬 상태 저장

## 🚨 아키텍처 위반 사항

### Critical (즉시 수정 필요)
1. **Data → Presentation 직접 의존** (2건)
   - `global_notification_manager.dart` → `voting_notification_dialog.dart`
   - `global_notification_manager.dart` → `versus_box_size_data.dart`

2. **Cross-Feature Data Coupling** (2건)
   - `global_notification_manager.dart` → `auth/data/adapters/auth_util.dart`
   - `global_notification_manager.dart` → `posts/data/adapters/vote/vote_status_service.dart`

### 권장 수정 방향
- GlobalNotificationManager를 UseCase로 분리
- UI 표시 로직을 Presentation Provider로 이동
- Cross-feature 의존성을 Domain 인터페이스로 추상화

## 🔧 사용 방법

### 1. 알림 서비스 초기화
```dart
// main.dart 또는 app 초기화 시점
NotificationService.instance.startListening(userId);
GlobalNotificationManager.instance.startListening();
```

### 2. 알림 수신 상태 확인
```dart
// 읽지 않은 알림 카운트
NotificationService.instance.getUnreadNotificationCount(userId).listen((count) {
  print('읽지 않은 알림: $count개');
});
```

### 3. 타겟 사용자 선택
```dart
final users = await TargetAudienceService.selectTargetUsers(
  targetMode: 'quick',
  currentUserId: userId,
  postId: postId,
);
```

## 🔄 향후 개선 계획

### Phase 1: 의존성 분리 (우선순위 High)
- [ ] GlobalNotificationManager를 UseCase와 Provider로 분리
- [ ] UI 로직을 Presentation 레이어로 이동
- [ ] Cross-feature 의존성 인터페이스화

### Phase 2: 구조 개선 (우선순위 Medium)
- [ ] NotificationQueueService 구현
- [ ] FCMService 통합
- [ ] 알림 우선순위 시스템 구현

### Phase 3: 성능 최적화 (우선순위 Low)
- [ ] 알림 배치 처리
- [ ] 캐싱 전략 구현
- [ ] 스로틀링 메커니즘

## 📊 코드 메트릭스

| 파일 | 라인 수 | 복잡도 | 테스트 커버리지 | 상태 |
|------|---------|---------|----------------|------|
| notification_service.dart | 254 | Low | 0% | ✅ |
| global_notification_manager.dart | 492 | High | 0% | 🚨 |
| target_audience_service.dart | 271 | Medium | 0% | ⚠️ |

## 🎯 마이그레이션 시 고려사항

새로운 기능이나 페이지 추가 시:

1. **의존성 규칙 준수**
   - Data 레이어는 절대 Presentation을 import하지 않음
   - Cross-feature 의존은 Domain 인터페이스 사용
   - UI 로직은 Presentation 레이어에만 위치

2. **테스트 가능성**
   - 비즈니스 로직과 UI 로직 분리
   - Mock 가능한 인터페이스 제공
   - 의존성 주입 활용

3. **확장성**
   - UseCase 패턴으로 비즈니스 로직 캡슐화
   - Provider 패턴으로 상태 관리
   - 이벤트 기반 아키텍처 고려

---

*Feature-First Clean Architecture 준수를 위한 개선 진행 중*  
*마이그레이션 가이드: [MIGRATION_GUIDE.md](./MIGRATION_GUIDE.md) 참조*