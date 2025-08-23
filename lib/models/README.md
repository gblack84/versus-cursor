# 📊 Models - 앱 런타임 데이터 모델

> Versus Space 앱의 핵심 상태 관리와 런타임 데이터 모델을 담당하는 모듈

## 📋 개요

이 디렉토리는 앱 전역에서 사용되는 런타임 데이터 모델과 상태 객체를 정의합니다. Firestore 스키마(`/lib/backend/schema`)와는 별개로, 앱 실행 중 상태 관리와 비즈니스 로직을 위한 타입 안전한 데이터 구조를 제공합니다.

### 🎯 주요 목적
- **상태 관리**: 투표 상태와 같은 앱 전역 상태 관리
- **타입 안전성**: 강타입 모델로 런타임 오류 방지
- **비즈니스 로직**: 도메인 특화 메서드와 계산 속성 제공
- **불변성 패턴**: 예측 가능한 상태 변경

## 🏗️ 디렉토리 구조

```
/lib/models/
├── README.md          # 현재 문서
└── vote_state.dart    # 투표 상태 관리 모델
```

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: `{domain}_state.dart` 또는 `{domain}_model.dart`
- **규칙**: snake_case 사용 (Dart 표준)
- **예시**: `vote_state.dart`

### 클래스명
- **패턴**: `{Domain}{Type}` (PascalCase)
- **예시**: `VoteState`, `VoteStateData`

### 필드명
- **패턴**: camelCase
- **예시**: `voteEndTime`, `hasUserVoted`, `userChoice`

> 참고: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. VoteState (vote_state.dart)

투표의 현재 상태를 나타내는 열거형입니다.

#### 상태 정의
```dart
enum VoteState {
  votingRequest,    // 투표 요청 대기
  inProgress,       // 투표 진행 중
  completed,        // 투표 완료
  expired,          // 시간 만료
  notParticipated,  // 미참여
}
```

#### 상태 전이 플로우
```
votingRequest → inProgress → completed
      ↓             ↓
   expired    notParticipated
```

### 2. VoteStateData (vote_state.dart)

투표 상태와 관련 데이터를 통합 관리하는 불변 모델입니다.

#### 클래스 구조
```dart
class VoteStateData {
  final VoteState state;              // 현재 상태
  final Duration? remainingTime;      // 남은 시간
  final Map<String, dynamic>? voteResults; // 투표 결과
  final bool isTimerExpired;          // 타이머 만료 여부
  final DateTime? voteEndTime;        // 투표 종료 시간
  final String? errorMessage;         // 에러 메시지
  final bool hasUserVoted;            // 사용자 투표 여부
  final String? userChoice;           // 사용자 선택 (A/B)
}
```

#### 주요 기능

##### 상태 텍스트 한글 변환
```dart
String get statusText {
  switch (state) {
    case VoteState.votingRequest:
      return '피클요청';
    case VoteState.inProgress:
      return hasUserVoted ? 'Pick 완료!(진행중)' : '진행중';
    case VoteState.completed:
      return '완료';
    case VoteState.expired:
      return '만료';
    case VoteState.notParticipated:
      return '미참여';
  }
}
```

##### 불변성을 위한 copyWith 메서드
```dart
VoteStateData copyWith({
  VoteState? state,
  Duration? remainingTime,
  Map<String, dynamic>? voteResults,
  bool? isTimerExpired,
  DateTime? voteEndTime,
  String? errorMessage,
  bool? hasUserVoted,
  String? userChoice,
})
```

## 💡 사용 가이드

### 투표 상태 관리 예제

#### 초기 상태 생성
```dart
var voteState = VoteStateData(
  state: VoteState.votingRequest,
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
);
```

#### 상태 변경 (불변성 유지)
```dart
// 투표 시작
voteState = voteState.copyWith(
  state: VoteState.inProgress,
);

// 사용자 투표
voteState = voteState.copyWith(
  hasUserVoted: true,
  userChoice: 'A',
);

// 투표 완료
voteState = voteState.copyWith(
  state: VoteState.completed,
  voteResults: {
    'votesA': 150,
    'votesB': 120,
    'winner': 'A',
  },
);
```

#### 상태 확인
```dart
// 한글 상태 텍스트
print(voteState.statusText); // "Pick 완료!(진행중)"

// 조건부 UI 렌더링
if (voteState.state == VoteState.inProgress && !voteState.hasUserVoted) {
  // 투표 버튼 표시
  showVoteButtons();
} else if (voteState.state == VoteState.completed) {
  // 결과 표시
  showResults(voteState.voteResults);
}
```

### VoteManager 클래스 구현 예제

```dart
class VoteManager {
  VoteStateData _state = VoteStateData(
    state: VoteState.votingRequest,
  );
  
  VoteStateData get state => _state;
  
  void startVoting(DateTime endTime) {
    _state = _state.copyWith(
      state: VoteState.inProgress,
      voteEndTime: endTime,
      isTimerExpired: false,
    );
    notifyListeners();
  }
  
  void submitVote(String choice) {
    if (_state.state != VoteState.inProgress) {
      _state = _state.copyWith(
        errorMessage: '투표가 진행중이 아닙니다',
      );
      return;
    }
    
    _state = _state.copyWith(
      hasUserVoted: true,
      userChoice: choice,
      errorMessage: null,
    );
    notifyListeners();
  }
  
  void completeVoting(Map<String, dynamic> results) {
    _state = _state.copyWith(
      state: VoteState.completed,
      voteResults: results,
      isTimerExpired: true,
    );
    notifyListeners();
  }
  
  void handleTimeout() {
    _state = _state.copyWith(
      state: VoteState.expired,
      isTimerExpired: true,
      errorMessage: '투표 시간이 만료되었습니다',
    );
    notifyListeners();
  }
}
```

## 🔄 데이터 흐름

### 투표 생명 주기

```
1. 초기화 (votingRequest)
   ↓
2. 투표 시작 (inProgress)
   ↓
3. 사용자 참여 (hasUserVoted = true)
   ↓
4. 시간 경과
   ├─→ 정상 완료 (completed)
   └─→ 시간 초과 (expired)
```

### 상태 관리 플로우

```
UI Component
    ↓
VoteManager (상태 관리)
    ↓
VoteStateData (불변 모델)
    ↓
UI Update (리렌더링)
```

## 🎨 설계 원칙

### 1. 불변성 (Immutability)
- 모든 필드는 `final`로 선언
- 상태 변경 시 `copyWith()` 사용
- 새 인스턴스 생성으로 예측 가능한 상태 관리

### 2. 단일 책임 원칙
- `VoteState`: 상태 정의만 담당
- `VoteStateData`: 데이터 캡슐화와 헬퍼 메서드
- 비즈니스 로직은 별도 Manager 클래스에서 처리

### 3. 타입 안전성
- 강타입 열거형 사용
- nullable 타입 명시적 처리
- 런타임 에러 방지

## 🧪 테스트

### 단위 테스트 예제

```dart
test('VoteStateData copyWith 테스트', () {
  final initial = VoteStateData(
    state: VoteState.votingRequest,
  );
  
  final updated = initial.copyWith(
    state: VoteState.inProgress,
    hasUserVoted: true,
    userChoice: 'A',
  );
  
  // 원본은 변경되지 않음
  expect(initial.state, equals(VoteState.votingRequest));
  expect(initial.hasUserVoted, isFalse);
  
  // 새 인스턴스는 업데이트됨
  expect(updated.state, equals(VoteState.inProgress));
  expect(updated.hasUserVoted, isTrue);
  expect(updated.userChoice, equals('A'));
  expect(updated.statusText, equals('Pick 완료!(진행중)'));
});

test('상태 전이 테스트', () {
  final manager = VoteManager();
  
  // 초기 상태
  expect(manager.state.state, equals(VoteState.votingRequest));
  
  // 투표 시작
  manager.startVoting(DateTime.now().add(Duration(minutes: 10)));
  expect(manager.state.state, equals(VoteState.inProgress));
  
  // 사용자 투표
  manager.submitVote('B');
  expect(manager.state.hasUserVoted, isTrue);
  expect(manager.state.userChoice, equals('B'));
  
  // 투표 완료
  manager.completeVoting({'votesA': 100, 'votesB': 150});
  expect(manager.state.state, equals(VoteState.completed));
  expect(manager.state.voteResults?['votesB'], equals(150));
});
```

## 📈 성능 고려사항

### 메모리 최적화
- 불변 객체 패턴으로 메모리 예측 가능
- 불필요한 객체 생성 최소화
- 상태 변경 시에만 새 인스턴스 생성

### 상태 업데이트 최적화
```dart
// ❌ 나쁜 예: 여러 번 상태 변경
state = state.copyWith(hasUserVoted: true);
state = state.copyWith(userChoice: 'A');
state = state.copyWith(errorMessage: null);

// ✅ 좋은 예: 한 번에 모든 변경
state = state.copyWith(
  hasUserVoted: true,
  userChoice: 'A',
  errorMessage: null,
);
```

## 🔗 관련 컴포넌트

### 사용처
- `/lib/components/chat/vote_card_message.dart` - 투표 카드 메시지
- `/lib/services/vote_state_coordinator.dart` - 투표 상태 조정자
- `/lib/services/vote_timer_service.dart` - 투표 타이머 서비스

### 연관 모듈
- `/lib/backend/schema/posts_model.dart` - 게시물 투표 데이터
- `/lib/backend/schema/notifications_model.dart` - 투표 알림 데이터

## 🔮 향후 계획

### 추가 예정 모델
1. **UserStateModel**: 사용자 세션 상태 관리
2. **ChatStateModel**: 채팅 상태 관리
3. **MediaStateModel**: 미디어 재생 상태 관리
4. **FormStateModel**: 폼 입력 상태 관리

### 개선 사항
- State 패턴 적용으로 상태 전이 로직 강화
- Provider/Riverpod 통합으로 전역 상태 관리
- 상태 직렬화로 상태 복원 기능 추가

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 2.0.0 | 2025-08-23 | VotingNotification 삭제, VoteState 중심으로 재구성 | AI Assistant |
| 1.2.0 | 2025-08-23 | 실제 코드와 문서 동기화, VoteState 모델 추가 문서화 | AI Assistant |
| 1.1.0 | 2024-XX-XX | VotingNotification 모델 구현 (현재 삭제됨) | 개발팀 |
| 1.0.0 | 2024-XX-XX | 초기 모델 디렉토리 생성 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 앱 런타임 데이터 모델을 설명합니다.*
*마지막 업데이트: 2025-08-23*