# 🗳️ Voting Feature

> Feature-First Architecture 기반 투표 시스템 모듈

## 📋 개요

Voting Feature는 A vs B 형식의 투표 시스템을 관리합니다.
실시간 투표, 타이머 관리, 결과 집계 등 투표와 관련된 모든 기능을 담당합니다.

## 🏗️ 아키텍처

```
voting/
├── data/                  # 데이터 레이어
│   ├── datasources/      # Firestore votes 컬렉션
│   ├── repositories/     # VoteRepository 구현
│   └── services/         # 투표 타이머, 상태 관리
│
├── domain/               # 도메인 레이어
│   ├── models/          # Vote, VoteResult 모델
│   ├── repositories/    # VoteRepository 인터페이스
│   └── usecases/        # 투표 생성, 참여, 완료
│
└── presentation/         # 프레젠테이션 레이어
    ├── screens/         # 투표 화면
    ├── widgets/         # 투표 카드, 결과 표시
    └── providers/       # VoteProvider 상태 관리
```

## 🎯 주요 기능

### 투표 시스템
- **A vs B 형식**: 두 가지 선택지 비교
- **10분 타이머**: 자동 완료 처리
- **실시간 동기화**: 투표 상태 실시간 반영
- **중복 투표 방지**: 사용자당 1표 보장

### 투표 상태 관리
- **진행중 (pending)**: 투표 가능 상태
- **완료 (completed)**: 결과 공개 상태
- **타임아웃**: 10분 후 자동 완료

### 투표 타겟팅
- **AI 추천**: 관련 사용자 자동 매칭
- **공개 투표**: 랜덤 사용자 배포
- **커스텀 타겟**: 조건별 사용자 선택

## 📦 의존성

### 전역 서비스 사용
- `services/vote_timer_service`: 타이머 관리
- `services/vote_status_service`: 상태 동기화
- `services/vote_state_coordinator`: 통합 관리
- `backend/models/posts`: Post 모델 연동

### Firebase Functions
```javascript
// 투표 관련 Cloud Functions
- onPostVoteUpdate: 투표 업데이트 감지
- processVoteCompletion: 투표 완료 처리
- flushThrottleQueue: 스로틀 큐 처리
```

## 🔄 상태 관리

### VoteProvider
```dart
class VoteProvider extends ChangeNotifier {
  Map<String, VoteStatus> _voteStatuses = {};
  Map<String, Timer> _timers = {};
  
  // 투표 상태 조회
  VoteStatus getStatus(String postId) => _voteStatuses[postId];
  
  // 투표 참여
  Future<void> vote(String postId, VoteOption option) async {
    // 구현
  }
  
  // 타이머 관리
  void startTimer(String postId, DateTime endTime) {
    // 구현
  }
}
```

## 🔀 다른 Feature와의 통신

### Posts Feature 연동
```dart
// Post 생성 시 투표 설정
final post = PostModel(
  voteStartTime: DateTime.now(),
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
);
```

### Notifications Feature 연동
```dart
// 투표 요청 알림 발송
eventBus.fire(VoteRequestEvent(postId, targetUsers));
```

### Chat Feature 연동
```dart
// 투표 카드 메시지 전송
final voteMessage = VoteCardMessage(
  postId: postId,
  voteOptions: ['A', 'B'],
);
```

## 📊 투표 통계

### VoteAnalytics
- 투표 참여율
- 옵션별 득표율
- 시간대별 투표 패턴
- 사용자 선호도 분석

## 📋 API 레퍼런스

### UseCases
- `CreateVoteUseCase`: 투표 생성
- `CastVoteUseCase`: 투표 참여
- `GetVoteResultUseCase`: 결과 조회
- `CompleteVoteUseCase`: 투표 완료 처리
- `CheckVoteTimeoutUseCase`: 타임아웃 확인

### Models
- `Vote`: 개별 투표 정보
- `VoteResult`: 투표 결과
- `VoteStatus`: 투표 상태
- `VoteTimer`: 타이머 정보

### Services
- `VoteTimerService`: 타이머 관리
- `VoteStatusService`: 상태 관리
- `VoteStateCoordinator`: 통합 조정

## 🧪 테스트

```bash
# 유닛 테스트
flutter test test/features/voting/domain/

# 통합 테스트
flutter test test/features/voting/integration/

# Firebase Functions 테스트
cd firebase/functions && npm test
```

## 📝 변경 이력

### v1.0.0 (2025-08-27)
- Feature-First Architecture 마이그레이션 완료
- VoteStateCoordinator 중심 리팩토링
- 실시간 동기화 시스템 구축
- 10분 타이머 자동화