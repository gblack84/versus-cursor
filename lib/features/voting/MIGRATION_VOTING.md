# 📦 /lib/features/voting 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Voting Feature 독립 모듈

## 🎯 목적

투표 관련 핵심 기능을 `/lib/features/voting` 폴더로 통합하여 독립적이고 재사용 가능한 투표 모듈을 구성합니다.

## 📌 알림 시스템 분리 안내

**2025-08-24 업데이트**: 알림 시스템이 별도의 feature로 분리되었습니다.
- **일반 알림 시스템**: `/lib/features/notifications/` - 모든 알림 타입 처리
- **투표 특화 UI**: `/lib/features/voting/` - 투표 관련 UI 컴포넌트만 유지

## 📋 현재 상태 분석

### 투표 관련 디렉토리 현황
| 디렉토리/파일 그룹 | 파일 수 | 설명 |
|-------------------|---------|------|
| `/lib/services/vote_*.dart` | 3개 | 투표 핵심 서비스 |
| `/lib/components/chat/vote_*` | 1개 | 투표 카드 UI 컴포넌트 |
| `/lib/components/chat/base_vote_message.dart` | 1개 | 투표 메시지 베이스 클래스 |
| `/lib/components/notifications/voting_*` | 2개 | 투표 전용 알림 UI |
| `/lib/backend/schema/vote*` | 3개 | 투표 관련 스키마 |
| `/lib/utils/vote_*.dart` | 1개 | 투표 헬퍼 |
| **총합** | **11개** | 투표 관련 파일 |

**Note**: 일반 알림 관련 파일들은 `/lib/features/notifications/`로 이동

### 🔄 Core/App 마이그레이션 의존성
기존 FlutterFlow 마이그레이션으로 인한 영향:
- `FFAppState` → `AppState` 변경
- `flutter_flow/` → `core/` 폴더 구조 변경
- `FFLocalizations` → `AppLocalizations` 변경
- 모든 FF 접두사가 App 접두사로 변경됨
- 투표 관련 Widget들도 App 접두사 사용 필요

## 🏗️ Feature-First 구조 매핑

```
/lib/features/voting/
├── data/
│   ├── repositories/
│   │   ├── vote_repository.dart          # 투표 데이터 접근 추상화
│   │   └── ranking_repository.dart       # 순위 데이터 관리
│   │
│   └── services/
│       ├── vote_service.dart             # 투표 CRUD 서비스
│       ├── vote_timer_service.dart       # 투표 타이머 관리
│       ├── vote_status_service.dart      # 투표 상태 관리
│       ├── vote_state_coordinator.dart   # 투표 상태 조정
│       ├── target_audience_service.dart  # 타겟 오디언스
│       └── vote_analytics_service.dart   # 투표 분석
│
├── domain/
│   ├── models/
│   │   ├── vote_model.dart              # 투표 데이터 모델
│   │   ├── vote_result_model.dart       # 투표 결과 모델
│   │   ├── vote_counts_model.dart       # 투표 집계 모델
│   │   ├── vote_state_model.dart        # 투표 상태 모델
│   │   ├── vote_expansion_model.dart    # 투표 확장 요청
│   │   └── ranking_model.dart           # 순위 모델
│   │
│   └── usecases/
│       ├── cast_vote_usecase.dart       # 투표하기
│       ├── get_vote_results_usecase.dart # 결과 조회
│       ├── create_vote_usecase.dart     # 투표 생성
│       ├── close_vote_usecase.dart      # 투표 종료
│       ├── expand_vote_usecase.dart     # 투표 확장
│       └── calculate_ranking_usecase.dart # 순위 계산
│
└── presentation/
    ├── screens/
    │   ├── voting_detail/                # 투표 상세 화면
    │   │   ├── voting_detail_widget.dart
    │   │   └── voting_detail_model.dart
    │   │
    │   ├── voting_results/               # 투표 결과 화면
    │   │   ├── voting_results_widget.dart
    │   │   └── voting_results_model.dart
    │   │
    │   └── rankings/                     # 순위 화면
    │       ├── rankings_widget.dart
    │       └── rankings_model.dart
    │
    ├── widgets/
    │   ├── vote_card/                    # 투표 카드 컴포넌트
    │   │   ├── vote_card_message.dart
    │   │   ├── base_vote_message.dart
    │   │   ├── vote_option_box.dart
    │   │   ├── vote_result_display.dart
    │   │   ├── vote_card_header.dart
    │   │   └── vote_action_button.dart
    │   │
    │   ├── vote_notifications/           # 투표 전용 알림 UI
    │   │   ├── voting_notification_dialog.dart
    │   │   ├── voting_overlay.dart
    │   │   └── versus_notification_box.dart
    │   │
    │   ├── vote_timer.dart              # 투표 타이머 위젯
    │   ├── vote_progress_bar.dart       # 투표 진행률 바
    │   ├── vote_button.dart             # 투표 버튼
    │   └── vote_statistics.dart         # 투표 통계 표시
    │
    ├── providers/
    │   ├── vote_provider.dart           # 투표 상태 관리
    │   └── ranking_provider.dart        # 순위 상태 관리
    │
    └── constants/
        ├── vote_constraints.dart         # 투표 제약사항
        └── vote_strings.dart             # 투표 문자열 상수
```

**Note**: 일반 알림 관련 컴포넌트는 `/lib/features/notifications/`에서 관리

## 📁 상세 파일 이동 계획

### Phase 1: Services 이동 (data/services/)

```bash
# 투표 서비스
git mv lib/services/vote_timer_service.dart lib/features/voting/data/services/
git mv lib/services/vote_status_service.dart lib/features/voting/data/services/
git mv lib/services/vote_state_coordinator.dart lib/features/voting/data/services/
git mv lib/services/target_audience_service.dart lib/features/voting/data/services/

# 헬퍼 유틸리티
git mv lib/utils/vote_message_helper.dart lib/features/voting/data/services/vote_helper_service.dart

# Note: notification_service.dart와 global_notification_manager.dart는 
# /lib/features/notifications/로 이동
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 투표 모델
git mv lib/backend/schema/votes_model.dart lib/features/voting/domain/models/vote_model.dart
git mv lib/backend/schema/votecounts_model.dart lib/features/voting/domain/models/vote_counts_model.dart
git mv lib/backend/schema/vote_expansion_requests_model.dart lib/features/voting/domain/models/vote_expansion_model.dart
git mv lib/models/vote_state.dart lib/features/voting/domain/models/vote_state_model.dart

# 순위 모델
git mv lib/backend/schema/rankings_model.dart lib/features/voting/domain/models/ranking_model.dart

# Note: notifications_model.dart와 notification_model.dart는 
# /lib/features/notifications/로 이동
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 새로 생성할 화면들
# voting_detail/ - 투표 상세 화면
# voting_results/ - 투표 결과 화면
# rankings/ - 순위 화면

# Note: notifications_list 화면은 /lib/features/notifications/로 이동
```

### Phase 4: Widgets 이동 (presentation/widgets/)

```bash
# 투표 카드 컴포넌트
mkdir -p lib/features/voting/presentation/widgets/vote_card
git mv lib/components/chat/vote_card_message.dart lib/features/voting/presentation/widgets/vote_card/
git mv lib/components/chat/base_vote_message.dart lib/features/voting/presentation/widgets/vote_card/
git mv lib/components/chat/vote_card/vote_option_box.dart lib/features/voting/presentation/widgets/vote_card/
git mv lib/components/chat/vote_card/vote_result_display.dart lib/features/voting/presentation/widgets/vote_card/
git mv lib/components/chat/vote_card/vote_card_header.dart lib/features/voting/presentation/widgets/vote_card/
git mv lib/components/chat/vote_card/vote_action_button.dart lib/features/voting/presentation/widgets/vote_card/

# 투표 전용 알림 UI
mkdir -p lib/features/voting/presentation/widgets/vote_notifications
git mv lib/components/notifications/voting_notification_dialog.dart lib/features/voting/presentation/widgets/vote_notifications/
git mv lib/components/notifications/voting_overlay.dart lib/features/voting/presentation/widgets/vote_notifications/
git mv lib/components/notifications/widgets/versus_notification_box.dart lib/features/voting/presentation/widgets/vote_notifications/

# Note: 일반 알림 UI 컴포넌트는 /lib/features/notifications/로 이동
```

### Phase 5: Providers 이동 (presentation/providers/)

```bash
# 새로 생성할 Provider들
# vote_provider.dart
# ranking_provider.dart

# Note: notification_badge_provider.dart와 notification_provider.dart는 
# /lib/features/notifications/로 이동
```

### Phase 6: Constants 이동 (presentation/constants/)

```bash
# 상수 파일들
git mv lib/components/notifications/constants/voting_notification_constraints.dart lib/features/voting/presentation/constants/vote_notification_constraints.dart

# 새로 생성할 상수 파일
# vote_constraints.dart
# vote_strings.dart
```

### Phase 7: Repository 생성 (data/repositories/)

```dart
// 새로 생성할 파일: vote_repository.dart
class VoteRepository {
  final VoteService _voteService;
  final VoteTimerService _timerService;
  final VoteStatusService _statusService;
  final VoteStateCoordinator _coordinator;
  
  Future<VoteResult> castVote({
    required String postId,
    required String userId,
    required VoteOption option,
  }) async {
    // 투표 로직 통합
  }
  
  Stream<VoteState> getVoteState(String postId) {
    // 실시간 투표 상태 스트림
  }
}
```

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 채팅 관련 | 20개+ | 투표 카드 메시지 |
| 게시물 관련 | 15개+ | 투표 생성 |
| 알림 관련 | 10개+ | 알림 표시 |
| 홈 화면 | 5개+ | 알림 뱃지 |

### Import 변경 예시

```dart
// Before (Legacy)
import '/services/vote_timer_service.dart';
import '/components/chat/vote_card_message.dart';
import '/components/notifications/notification_overlay.dart';
import '/flutter_flow/flutter_flow_util.dart';

// After (Feature-First + Core Migration)
import '/features/voting/data/services/vote_timer_service.dart';
import '/features/voting/presentation/widgets/vote_card/vote_card_message.dart';
import '/features/voting/presentation/widgets/notifications/notification_overlay.dart';
import '/core/app_utils.dart';  // 이전 flutter_flow_util.dart

// Widget 네이밍 변경
// FFVoteCard → AppVoteCard
// FFVoteTimer → AppVoteTimer
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 투표 생성 & 설정
- [ ] 투표 생성
- [ ] 타겟 오디언스 설정
- [ ] 10분 타이머 설정
- [ ] AI 사용자 매칭

#### 2. 투표 참여
- [ ] A/B 선택
- [ ] 중복 투표 방지
- [ ] 실시간 집계
- [ ] 투표 상태 업데이트

#### 3. 투표 타이머
- [ ] 10분 카운트다운
- [ ] 서버 시간 동기화
- [ ] 자동 종료
- [ ] 타이머 표시

#### 4. 알림 시스템
- [ ] 실시간 알림 수신
- [ ] 알림 다이얼로그
- [ ] 알림 뱃지
- [ ] 알림 목록
- [ ] 푸시 알림

#### 5. 투표 결과
- [ ] 결과 집계
- [ ] 승자 표시
- [ ] 통계 표시
- [ ] 순위 업데이트

## ⚠️ 주의사항

### 1. 실시간 동기화
- Firebase Realtime 리스너
- 서버 시간 동기화
- 타이머 정확도

### 2. 상태 관리
- VoteStateCoordinator 통합
- 투표 상태 일관성
- 중복 투표 방지 로직

### 3. 알림 시스템
- GlobalNotificationManager 유지
- 알림 큐 관리
- 우선순위 처리

### 4. AI 통합
- 타겟 오디언스 매칭
- Genkit 프레임워크 연동
- Firebase Functions 호출

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 매우 높음 | 5개 | 핵심 투표 로직 |
| **Models** | 높음 | 5개 | 데이터 구조 |
| **Screens** | 중간 | 3개 | 화면 구성 |
| **Widgets** | 매우 높음 | 12개 | UI 컴포넌트 |
| **Providers** | 높음 | 2개 | 상태 관리 |
| **총 영향** | **높음** | **27개** | 투표 핵심 기능 |

**Note**: 알림 관련 기능은 별도 `/lib/features/notifications/`에서 관리

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-voting-migration
```

## 📅 예상 소요 시간

| Phase | 소요 시간 | 난이도 |
|-------|----------|--------|
| Phase 1: Services | 1시간 | ⭐⭐⭐ |
| Phase 2: Models | 30분 | ⭐⭐ |
| Phase 3: Screens | 1시간 | ⭐⭐⭐ |
| Phase 4: Widgets | 2시간 | ⭐⭐⭐⭐ |
| Phase 5: Providers | 1시간 | ⭐⭐⭐ |
| Phase 6: Constants | 30분 | ⭐ |
| Phase 7: Repository | 1.5시간 | ⭐⭐⭐⭐ |
| **총 소요 시간** | **7.5시간** | ⭐⭐⭐⭐ |

## 🚀 다음 단계

1. **타이머 시스템 검증**
   - 서버 동기화 확인
   - 정확도 테스트

2. **알림 플로우 테스트**
   - 실시간 수신
   - 큐 관리

3. **AI 통합 확인**
   - Firebase Functions 연동
   - 타겟 매칭 알고리즘

---

*이 문서는 Feature-First Architecture 마이그레이션의 Voting Feature 통합 가이드입니다.*
*작성일: 2025-08-24*