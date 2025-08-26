# 📦 Voting Presentation Widgets Layer

> Feature-First Architecture - 투표 기능 UI 컴포넌트 구현

## 📋 개요

투표 기능의 재사용 가능한 UI 위젯 컴포넌트들을 관리하는 레이어입니다. 복잡한 투표 카드 시스템, 실시간 알림 UI, 투표 상태 표시 등 다양한 위젯을 포함합니다.

## 🏗️ 디렉토리 구조

```
presentation/widgets/
├── vote_card/                    # 투표 카드 컴포넌트
│   ├── vote_card_message.dart    # 메인 투표 카드
│   ├── base_vote_message.dart    # 베이스 추상 클래스
│   ├── vote_option_box.dart      # A/B 옵션 박스
│   ├── vote_result_display.dart  # 결과 표시
│   ├── vote_card_header.dart     # 카드 헤더
│   └── vote_action_button.dart   # 투표 액션 버튼
│
├── notifications/                # 알림 UI 컴포넌트
│   ├── voting_notification_dialog.dart  # 투표 알림 다이얼로그
│   ├── notification_overlay.dart        # 오버레이 표시
│   ├── voting_overlay.dart             # 투표 전용 오버레이
│   ├── notification_badge.dart         # 알림 뱃지
│   ├── in_app_notification_dialog.dart # 인앱 알림
│   ├── notification_image_viewer.dart  # 이미지 뷰어
│   └── versus_notification_box.dart    # VS 박스 컴포넌트
│
├── vote_timer.dart               # 투표 타이머 위젯
├── vote_progress_bar.dart        # 투표 진행률 바
├── vote_button.dart              # 투표 버튼
└── vote_statistics.dart          # 투표 통계 표시
```

## 🔑 주요 위젯 구현

### 1. VoteCardMessage - 메인 투표 카드

**역할**: AI 피클 채팅에서 사용되는 투표 카드 메시지 위젯

**주요 기능**:
- 4가지 상태 지원: voting_request, in_progress, completed, not_participated
- 스마트 레이아웃 시스템 (가로/세로 자동 배치)
- 박스 크기 캐싱으로 성능 최적화
- 멀티이미지 지원 (A/B 각각)
- 실시간 투표 상태 업데이트

**Props**:
- postId: 투표 게시물 ID
- title: 투표 질문
- description: 상세 설명 (optional)
- optionAText/optionBText: A/B 옵션 텍스트
- optionAImages/optionBImages: 멀티이미지 배열 (optional)
- aspectRatioA/aspectRatioB: 이미지 비율 (스마트 레이아웃용)
- cardStatus: 카드 상태 (voting_request, in_progress, completed)
- voteEndTime: 투표 종료 시간
- userVotes: 사용자 투표 데이터
- voteResults: 투표 결과 데이터
- isMe: 본인 메시지 여부
- messageType: 메시지 타입

**상태 관리**:
- BoxSizes 캐싱: static Map으로 메시지별 크기 저장
- VoteProvider 연동: Consumer 패턴으로 실시간 상태 반영
- 스마트 레이아웃: AspectRatioAnalyzer로 최적 배치 결정

**이벤트 처리**:
- onTap: 카드 상태에 따른 동작 (다이얼로그 표시, 결과 화면 이동)
- handleVote: 투표 실행 및 Provider 업데이트
- showVotingDialog: 투표 다이얼로그 표시
- navigateToResults: 결과 화면으로 라우팅

### 2. BaseVoteMessage - 투표 메시지 베이스 클래스

**역할**: 투표 메시지의 공통 로직을 담은 추상 클래스

**공통 속성**:
- **기본 속성**: postId, title, description, optionAText, optionBText
- **이미지 관련**: optionAImage/B, optionAImages/B, aspectRatioA/B
- **투표 상태**: cardStatus, voteEndTime, userVotes, voteResults
- **메시지 메타데이터**: isMe, timestamp, messageType, messageId, chatId
- **사용자 정보**: currentUserName, senderProfileImageUrl, senderDisplayName, senderId

**BaseVoteMessageStateMixin**:
- **서비스 연동**: VoteTimerService, VoteStateCoordinator 싱글톤 인스턴스
- **스트림 구독**: 타이머 업데이트, 투표 상태 업데이트
- **상태 관리**: remainingTime, currentVoteState
- **라이프사이클**: initState에서 초기화, dispose에서 구독 해제

**주요 메서드**:
- initializeVoteState(): 초기 투표 상태 설정
- subscribeToUpdates(): 타이머/상태 스트림 구독
- formatRemainingTime(): MM:SS 형식 시간 포맷
- isVoteActive: 투표 진행 중 여부
- hasUserVoted: 사용자 투표 완료 여부
- userVoteChoice: 사용자 선택 옵션 (A/B)

**위젯 업데이트 처리**:
- didUpdateWidget: postId나 voteEndTime 변경 시 재초기화
- 스트림 재구독으로 새로운 투표 데이터 반영

### 3. VotingNotificationDialog - 투표 알림 다이얼로그

**역할**: 투표 요청 알림을 모달 다이얼로그로 표시하는 위젯

**주요 기능**:
- 멀티이미지 지원 (imageUrlsA/B 배열)
- 스마트 레이아웃 시스템 (aspectRatio 기반 자동 배치)
- 투표 결과 표시 모드
- Scale 애니메이션으로 부드러운 진입
- 선택 상태 시각적 피드백

**Props**:
- question: 투표 질문
- optionA/optionB: A/B 옵션 텍스트
- imageUrlsA/imageUrlsB: 멀티이미지 URL 배열
- description: 상세 설명 (optional)
- onVote: 투표 콜백 함수 (option: String)
- onDismiss: 닫기 콜백 함수 (hasVoted: bool)
- sizeData: 미리 계산된 박스 크기 (optional)
- showResults: 결과 표시 여부
- votePercentageA/B: 투표 비율
- voteCountA/B: 투표 수
- aspectRatioA/B: 이미지 비율

**상태 관리**:
- selectedOption: 선택된 옵션 (A/B/null)
- isVoting: 투표 진행 중 상태
- finalSizeData: 최종 박스 크기 데이터
- AnimationController: Scale 애니메이션 제어

**레이아웃 계산**:
- AspectRatioAnalyzer로 최적 레이아웃 결정
- UnifiedBoxCalculator로 박스 크기 계산
- 92% 화면 너비 활용
- 가로/세로 자동 배치

**UI 구성**:
- **Header**: 투표 요청 타이틀, 닫기 버튼
- **Body**: 질문, 설명, A/B 옵션 박스
- **Actions**: 나중에/투표하기 버튼
- **애니메이션**: ElasticOut 커브로 진입 효과

### 4. VoteTimer - 투표 타이머 위젯

**역할**: 실시간 투표 남은 시간을 표시하는 타이머 위젯

**주요 기능**:
- VoteTimerService와 연동하여 실시간 시간 업데이트
- 1분 미만 시 긴급 상태 표시 (빨간색)
- MM:SS 형식 시간 표시
- 타이머 아이콘 옵션
- 타이머 만료 시 자동 숨김

**Props**:
- postId: 투표 게시물 ID (필수)
- voteEndTime: 투표 종료 시간 (필수)
- textStyle: 텍스트 스타일 (optional)
- backgroundColor: 배경색 (optional)
- showIcon: 타이머 아이콘 표시 여부 (기본값: true)

**상태 관리**:
- VoteTimerService 싱글톤 인스턴스 사용
- Stream 구독으로 실시간 업데이트
- remainingTime: 남은 시간 Duration

**UI 상태**:
- **일반 상태**: 노란색 (warning) 테마
- **긴급 상태**: 빨간색 (error) 테마 (1분 미만)
- **만료 상태**: SizedBox.shrink()로 숨김

**애니메이션**:
- AnimatedDefaultTextStyle로 색상 전환 애니메이션
- 300ms 전환 시간

### 5. VoteProgressBar - 투표 진행률 바

**역할**: A/B 투표 결과를 시각적으로 표시하는 진행률 바 위젯

**주요 기능**:
- 양방향 진행률 바 (A는 왼쪽, B는 오른쪽)
- 그라디언트 색상으로 시각적 구분
- 투표 수와 퍼센티지 표시
- 애니메이션 전환 효과
- 중앙 구분선 표시

**Props**:
- percentageA/percentageB: A/B 옵션 비율 (0-100)
- votesA/votesB: A/B 옵션 투표 수
- showNumbers: 숫자 표시 여부 (기본값: true)
- height: 진행률 바 높이 (기본값: 32)
- animationDuration: 애니메이션 시간 (기본값: 500ms)

**UI 구조**:
- **상단 텍스트**: 각 옵션의 투표 수와 퍼센티지
- **진행률 바**: Stack으로 구성된 양방향 바
  - 배경: VersusColors.surface
  - A 옵션: 왼쪽 정렬, 그라디언트
  - B 옵션: 오른쪽 정렬, 그라디언트
  - 구분선: 흰색 2px

**애니메이션**:
- AnimatedContainer로 너비 변경 애니메이션
- 500ms 기본 전환 시간
- 부드러운 비율 변경 효과

## 🔌 통합 지점

### Provider 연동

**VoteProvider 통합**:
- castVote(): 투표 실행
- getVoteState(): 투표 상태 조회
- voteStateStream: 실시간 상태 스트림

**NotificationProvider 통합**:
- markAsRead(): 알림 읽음 처리
- deleteNotification(): 알림 삭제
- notificationStream: 실시간 알림 스트림

### Service 연동

**VoteTimerService**:
- 싱글턴 인스턴스로 접근
- startTimer(): 타이머 시작
- getTimerStream(): 타이머 스트림
- getRemainingTime(): 남은 시간 조회

**VoteStateCoordinator**:
- 싱글턴 인스턴스로 접근
- updateVoteState(): 상태 업데이트
- getVoteStateStream(): 상태 스트림
- initializeVoteState(): 초기화

## 📊 위젯 계층 구조

```
BaseVoteMessage (추상 클래스)
├── VoteCardMessage (채팅용)
└── VoteRequestMessage (알림용)

VotingNotificationDialog
├── VersusNotificationBox
├── NotificationImageViewer
└── VoteActionButtons

VoteTimer
├── StreamBuilder (타이머 스트림)
└── AnimatedContainer (긴급 상태)

VoteProgressBar
├── AnimatedContainer (A 옵션)
└── AnimatedContainer (B 옵션)
```

## 🎨 디자인 시스템 통합

### 색상 체계
- **Primary**: 기본 강조색
- **Warning**: 진행중 상태 (노란색)
- **Success**: 완료 상태 (초록색)
- **Error**: 에러/긴급 상태 (빨간색)
- **OptionA/B**: 각 옵션별 색상

### 타이포그래피
- **Headline**: 투표 제목
- **Body**: 설명 텍스트
- **Caption**: 타이머, 투표 수
- **Button**: 액션 버튼

### 애니메이션
- **Scale**: 다이얼로그 진입
- **Fade**: 상태 전환
- **Slide**: 옵션 선택
- **Progress**: 진행률 바

## 🧪 테스트 전략

### Widget 테스트

**테스트 범위**:
- 위젯 렌더링 테스트
- 상태 변경에 따른 UI 업데이트
- 사용자 인터랙션
- 애니메이션 테스트
- 스트림 구독/해제

**Mock 객체**:
- MockVoteProvider
- MockNotificationProvider
- MockVoteTimerService
- MockVoteStateCoordinator

**테스트 케이스**:
- VoteCardMessage: 카드 표시, 투표 처리, 상태 업데이트
- VotingNotificationDialog: 다이얼로그 표시, 선택, 투표 실행
- VoteTimer: 타이머 업데이트, 긴급 상태, 만료 처리
- VoteProgressBar: 비율 표시, 애니메이션

### Golden 테스트

**테스트 시나리오**:
- 각 상태별 UI 스냅샷
- 다크모드/라이트모드
- 다양한 화면 크기
- 애니메이션 프레임

## ✅ 체크리스트

### 위젯 구현
- [x] VoteCardMessage - 메인 투표 카드
- [x] BaseVoteMessage - 베이스 클래스
- [x] VoteOptionBox - 옵션 박스
- [x] VoteResultDisplay - 결과 표시
- [x] VoteCardHeader - 카드 헤더
- [x] VoteActionButton - 액션 버튼
- [x] VotingNotificationDialog - 알림 다이얼로그
- [x] NotificationOverlay - 오버레이
- [x] NotificationBadge - 뱃지
- [x] VoteTimer - 타이머
- [x] VoteProgressBar - 진행률 바

### 기능 통합
- [x] Provider 연동
- [x] Service 연동  
- [x] 스마트 레이아웃
- [x] 멀티이미지 지원
- [x] 실시간 업데이트
- [x] 애니메이션

### 성능 최적화
- [x] Widget 재사용
- [x] 크기 캐싱
- [x] 이미지 캐싱
- [x] Stream 관리

## 📚 참고 자료

- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Provider Package](https://pub.dev/packages/provider)
- [CachedNetworkImage](https://pub.dev/packages/cached_network_image)
- [Design System Guide](/design_system/README.md)
- [Vote Service Documentation](../data/services/README.md)

---

*이 문서는 Feature-First Architecture 마이그레이션의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*