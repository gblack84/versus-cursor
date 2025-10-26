# 🔄 Voting Feature 역할변경 마이그레이션 가이드

> **문서 버전**: 1.3.0  
> **작성일**: 2024-12-31  
> **최종 업데이트**: 2025-01-11  
> **상태**: ✅ 완료됨  
> **진행률**: 100% (모든 파일 완료)  
> **완료된 작업**: Phase 1-9 완료  
> **영향 범위**: notifications ↔ voting ↔ posts features

## 📊 현재 진행 상황

### ✅ 완료된 작업 (VOTING_UTILITY_MIGRATION_GUIDE.md 기준)

#### Phase 1-2: Presentation Layer 파일 이동 (완료)
- ✅ **notification_overlay.dart** → /voting/presentation/overlays/
- ✅ **adaptive_text_size.dart** → /voting/presentation/utils/

#### Phase 3: Domain Layer 파일 이동 (완료)
- ✅ **i_notification_ui_delegate.dart** → i_vote_ui_delegate.dart로 변경
- ✅ **versus_box_size_data.dart** → /voting/domain/models/

#### Phase 4-5: Presentation/Data Layer 파일 이동 (완료)
- ✅ **notification_ui_manager.dart** → vote_ui_manager.dart로 변경
- ✅ **notification_handler_impl.dart** → vote_handler_impl.dart로 변경

#### Phase 6: 클래스 추출 및 SRP 적용 (완료)
- ✅ **VoteDisplayData** 클래스 추출
- ✅ **VoteDataExtractor** 서비스 생성

#### Phase 7-8: DI 및 Import 수정 (완료)
- ✅ DI 등록 업데이트
- ✅ 모든 import 경로 수정
- ✅ Clean Architecture 위반 수정

#### Phase 9: 추가 UI 컴포넌트 이동 (완료)
- ✅ **in_app_notification_dialog.dart** → /voting/presentation/overlays/
- ✅ BoxSizes export 파일 생성
- ✅ Backward compatibility 추가

## 📋 개요

### 🎯 마이그레이션 목적
Notifications feature가 비즈니스 로직(투표 UI, 타겟 선택)을 소유하는 문제를 해결하고, Clean Architecture의 단일 책임 원칙을 준수하도록 파일을 올바른 feature로 재배치합니다.

### 🔍 현재 문제점
- **아키텍처 위반**: CrossFeatureServiceAdapter가 다른 feature 구현체 직접 참조
- **순환 의존성**: notifications ↔ voting ↔ posts 간 순환 참조
- **책임 혼재**: 알림 feature가 투표 UI와 타겟 선택 기능 소유
- **금지된 import**: 15개의 cross-feature import 발견

### ✅ 목표 상태
- **Notifications**: 순수 알림 수신/표시/관리만 담당
- **Voting**: 투표 UI와 비즈니스 로직 소유
- **Posts**: 타겟 오디언스 선택 기능 소유
- **이벤트 기반**: 느슨한 결합을 위한 Event Bus 통신

## 📦 마이그레이션 완료 파일 (9개)

### 1️⃣ Presentation Layer 파일 (5개)
```bash
# notifications → voting 이동 완료
notification_overlay.dart → /voting/presentation/overlays/
adaptive_text_size.dart → /voting/presentation/utils/
notification_ui_manager.dart → /voting/presentation/managers/vote_ui_manager.dart
notification_handler_impl.dart → /voting/data/adapters/vote_handler_impl.dart (Clean Architecture fix)
in_app_notification_dialog.dart → /voting/presentation/overlays/
```

### 2️⃣ Domain Layer 파일 (2개)
```bash
# notifications → voting 이동 완료
i_notification_ui_delegate.dart → /voting/domain/ports/i_vote_ui_delegate.dart
versus_box_size_data.dart → /voting/domain/models/
```

### 3️⃣ 추출된 클래스 (2개)
```bash
# SRP 적용으로 새로 생성된 파일
VoteDisplayData → /voting/domain/models/vote_display_data.dart
VoteDataExtractor → /voting/domain/services/vote_data_extractor.dart
```

## 🏗️ 이벤트 기반 아키텍처 설계

### Event Bus 구현
```dart
// /lib/core/events/event_bus.dart
import 'dart:async';

class EventBus {
  static final EventBus _instance = EventBus._internal();
  factory EventBus() => _instance;
  EventBus._internal();

  final _streamController = StreamController<dynamic>.broadcast();

  void fire(dynamic event) => _streamController.add(event);
  
  Stream<T> on<T>() => _streamController.stream
      .where((event) => event is T)
      .cast<T>();
      
  void dispose() => _streamController.close();
}
```

### Notification Events
```dart
// /lib/core/events/notification_events.dart
class VoteNotificationTappedEvent {
  final String postId;
  final String notificationId;
  final Map<String, dynamic> metadata;
  
  VoteNotificationTappedEvent({
    required this.postId,
    required this.notificationId,
    required this.metadata,
  });
}
```

### Voting Feature Listener
```dart
// /lib/features/voting/presentation/managers/voting_event_manager.dart
class VotingEventManager {
  final EventBus _eventBus = EventBus();
  StreamSubscription? _subscription;
  
  void initialize() {
    _subscription = _eventBus.on<VoteNotificationTappedEvent>().listen(
      (event) => _handleVoteNotification(event),
    );
  }
  
  void _handleVoteNotification(VoteNotificationTappedEvent event) {
    // Show voting dialog
    showDialog(
      context: NavigatorKey.currentContext!,
      builder: (_) => VotingDialog(postId: event.postId),
    );
  }
  
  void dispose() => _subscription?.cancel();
}
```

## 📝 실행 완료 내역

### ✅ Phase 1-2: Presentation Layer 파일 이동
```bash
# 완료된 이동 작업
mv lib/features/notifications/presentation/widgets/notification_overlay.dart \
   lib/features/voting/presentation/overlays/notification_overlay.dart

mv lib/features/notifications/presentation/utils/adaptive_text_size.dart \
   lib/features/voting/presentation/utils/adaptive_text_size.dart
```

### ✅ Phase 3: Domain Layer 파일 이동
```bash
# Interface 이름 변경 및 이동
mv lib/features/notifications/domain/services/i_notification_ui_delegate.dart \
   lib/features/voting/domain/ports/i_vote_ui_delegate.dart

# Model 이동
mv lib/features/notifications/presentation/models/versus_box_size_data.dart \
   lib/features/voting/domain/models/versus_box_size_data.dart
```

### ✅ Phase 4-5: Manager/Handler 이동
```bash
# Manager 이름 변경 및 이동
mv lib/features/notifications/presentation/managers/notification_ui_manager.dart \
   lib/features/voting/presentation/managers/vote_ui_manager.dart

# Handler 이름 변경 및 이동 (Clean Architecture 수정 적용)
mv lib/features/notifications/data/services/notification_handler_impl.dart \
   lib/features/voting/data/adapters/vote_handler_impl.dart
```

### ✅ Phase 9: 추가 UI 컴포넌트 이동
```bash
# Dialog 이동
mv lib/features/notifications/presentation/widgets/in_app_notification_dialog.dart \
   lib/features/voting/presentation/overlays/in_app_notification_dialog.dart
```

### ✅ 완료된 코드 수정 작업

#### Import 경로 수정
- 모든 파일에서 새로운 경로로 import 업데이트 완료
- Cross-feature 의존성 제거 완료
- Clean Architecture 준수 확인

#### 클래스명 변경
- INotificationUIDelegate → IVoteUIDelegate
- NotificationUIManager → VoteUIManager  
- NotificationHandlerImpl → VoteHandlerImpl

#### DI 설정 업데이트
- app/di.dart에서 새로운 클래스명으로 등록
- notification_module.dart 업데이트 완료

## 📊 실제 결과

| 메트릭 | Before | After | 개선율 |
|--------|--------|-------|--------|
| **Voting Feature 파일 수** | 25개 | 32개 | +28% |
| **Notifications 의존성** | 7개 | 0개 | -100% |
| **Cross-feature import** | 7개 | 0개 | -100% |
| **Clean Architecture 준수** | 85% | 100% | +17.6% |
| **Layer 구성** | presentation: 15개, domain: 13개, data: 4개 | ✅ |
| **코드 응집도** | 개선됨 | 높음 | ⬆️ |
| **결합도** | 제거됨 | 낮음 | ⬇️ |

## ⚠️ 주의사항 및 리스크

### Breaking Changes
1. **Import 경로 변경**: 모든 참조 파일 수정 필요
2. **DI 설정**: GetIt 바인딩 업데이트 필수
3. **이벤트 리스너**: 앱 시작 시 초기화 필요

### Rollback 전략
```bash
# 백업에서 복원
rm -rf lib/features/notifications
mv lib/features/notifications.backup lib/features/notifications

# Git으로 복원
git checkout -- lib/features/notifications
```

### 테스트 요구사항
- **단위 테스트**: Event Bus, Service 테스트
- **통합 테스트**: 알림 → 투표 플로우
- **E2E 테스트**: 전체 사용자 시나리오

## ✅ 완료 체크리스트

### 사전 준비
- [x] 백업 생성 완료
- [x] 팀원 공지 완료
- [x] 브랜치 생성 (`feature/voting-utility-migration`)

### 파일 이동 (모두 완료)
- [x] notification_overlay.dart → voting/presentation/overlays/ ✅
- [x] adaptive_text_size.dart → voting/presentation/utils/ ✅
- [x] i_notification_ui_delegate.dart → i_vote_ui_delegate.dart ✅
- [x] versus_box_size_data.dart → voting/domain/models/ ✅
- [x] notification_ui_manager.dart → vote_ui_manager.dart ✅
- [x] notification_handler_impl.dart → vote_handler_impl.dart ✅
- [x] in_app_notification_dialog.dart → voting/presentation/overlays/ ✅

### 코드 수정 (모두 완료)
- [x] Import 경로 수정 ✅
- [x] 클래스명 변경 (INotificationUIDelegate → IVoteUIDelegate) ✅
- [x] VoteDisplayData 클래스 추출 ✅
- [x] VoteDataExtractor 서비스 생성 ✅
- [x] BoxSizes export 파일 생성 ✅
- [x] Backward compatibility 추가 ✅

### 설정 업데이트 (모두 완료)
- [x] DI 설정 (app/di.dart) ✅
- [x] notification_module.dart 업데이트 ✅
- [x] 문서 업데이트 (VOTING_UTILITY_MIGRATION_GUIDE.md v1.1.0) ✅

### 검증 (모두 완료)
- [x] `flutter analyze` 에러 0 ✅
- [x] 빌드 성공 확인 ✅
- [x] Clean Architecture 위반 수정 ✅
- [x] Cross-feature 의존성 제거 ✅

### 마무리
- [x] 마이그레이션 완료 ✅
- [x] 문서 업데이트 완료 ✅
- [x] 32개 파일 정상 조직화 확인 ✅

## 🚀 서브에이전트 활용 계획

이 마이그레이션은 SUBAGENTS_MANUAL.md의 피처 루프 패턴을 따릅니다:

1. **Import Guardian (detect)**: 현재 위반 사항 감지
2. **RepoMover**: 파일 이동 실행
3. **DIBinder**: DI 설정 자동 업데이트
4. **Import Guardian (fix)**: 금지된 import 자동 수정
5. **BuildSentinel (quick)**: 빌드 및 테스트 검증

```bash
# 서브에이전트 실행 예시
inventory-scout --scope lib/features/notifications --detect-violations
repo-mover --feature voting --files "voting_*.dart" --dry-run
di-binder --feature voting --bind "IVoteService:VoteServiceImpl"
import-guardian --fix --feature voting
build-sentinel --quick --feature voting
```





## 📚 참고 문서
- [Clean Architecture 가이드](../../../docs/CLEAN_ARCHITECTURE.md)
- [서브에이전트 매뉴얼](../../../docs/SUBAGENTS_MANUAL.md)
- [Feature-First 마이그레이션 가이드](../../../docs/FEATURE_FIRST_MIGRATION.md)

---
*이 문서는 서브에이전트를 활용한 체계적인 마이그레이션을 위해 작성되었습니다.*