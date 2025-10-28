# Voting Presentation Layer - Clean Architecture v4.0

> **최종 업데이트**: 2025-01-20
> **아키텍처**: Clean Architecture v4.0 (Presentation → Domain Only)
> **상태 관리**: Riverpod 2.x (StateProvider, StreamProvider.family, Provider)
> **총 파일 수**: 39개 (~4,500 라인)

---

## 📋 목차

1. [개요](#개요)
2. [완전한 디렉토리 구조](#완전한-디렉토리-구조)
3. [Chat Vote Card - 채팅 투표 카드 시스템](#chat-vote-card---채팅-투표-카드-시스템)
4. [Dialogs - 투표 다이얼로그 시스템](#dialogs---투표-다이얼로그-시스템)
5. [Providers - 상태 관리 레이어](#providers---상태-관리-레이어)
6. [Domain Layer 연결성](#domain-layer-연결성)
7. [Data Layer 연결성](#data-layer-연결성)
8. [Riverpod 패턴 및 상태 관리](#riverpod-패턴-및-상태-관리)
9. [컴포넌트 아키텍처 원칙](#컴포넌트-아키텍처-원칙)
10. [TODO 및 미완성 기능](#todo-및-미완성-기능)
11. [베스트 프랙티스](#베스트-프랙티스)
12. [트러블슈팅 가이드](#트러블슈팅-가이드)

---

## 개요

Voting Presentation Layer는 Clean Architecture v4.0 원칙에 따라 설계된 **UI 레이어**입니다.
**Presentation → Domain** 단방향 의존성만 허용하며, Data Layer를 직접 참조하지 않습니다.

### 핵심 원칙

1. **Clean Architecture v4.0 준수**
   - Presentation → Domain (✅ 허용)
   - Presentation → Data (❌ 금지)
   - Domain interfaces를 통한 비즈니스 로직 호출

2. **Riverpod 기반 상태 관리**
   - `StreamProvider.family`: PostID별 독립 상태 관리
   - `StateProvider`: 단순 상태 (선택된 옵션, 로딩 상태)
   - `Provider`: UseCase 인스턴스 제공 (GetIt DI 통합)
   - `keepAlive()`: 캐싱 전략 (불필요한 재생성 방지)

3. **Component-Driven Architecture**
   - 단일 책임 원칙 (SRP): 각 컴포넌트는 하나의 역할만 수행
   - 재사용 가능한 작은 위젯으로 분해
   - Props 패턴: Config + State 분리

4. **UseCase Pattern Integration**
   - `SubmitVoteUseCase`: 투표 제출 비즈니스 로직
   - `WatchVoteStateUseCase`: 실시간 투표 상태 감시
   - Domain Layer의 `Either<VotingFailure, T>` 패턴 사용

---

## 완전한 디렉토리 구조

```
presentation/                                           # 39 files (~4,500 lines)
├── chat_vote_card/                                     # 12 files (~1,700 lines) - 채팅 투표 카드 시스템
│   ├── vote_card/                                      # 10 files - 투표 카드 핵심 컴포넌트
│   │   ├── components/                                 # 4 files - 재사용 가능한 하위 컴포넌트
│   │   │   ├── vote_card_profile_header.dart          # 183 lines - 프로필 헤더 (Pikle 브랜딩 + 발신자 정보)
│   │   │   │                                          #   - Pikle 아이콘 + "Pikle 도착!" 텍스트
│   │   │   │                                          #   - 발신자 프로필 이미지 (40px 원형)
│   │   │   │                                          #   - 투표 상태 배지 (색상 + 아이콘)
│   │   │   │                                          #   - isMe 구분: "내가 만든 피클" vs "XXX님이 물어봅니다"
│   │   │   ├── vote_card_header.dart                  # 57 lines - 투표 카드 상단 영역
│   │   │   │                                          #   - 상태 배지 (VoteStatusBadge)
│   │   │   │                                          #   - 타이머 위젯 (VoteTimerWidget)
│   │   │   │                                          #   - 가로 배치 (Row 레이아웃)
│   │   │   ├── vote_card_body.dart                    # 129 lines - 투표 카드 본문
│   │   │   │                                          #   - 제목 + 설명 표시
│   │   │   │                                          #   - 검색어 하이라이팅 지원
│   │   │   │                                          #   - VoteOptionsWidget (투표 중)
│   │   │   │                                          #   - VoteResultsWidget (완료 시)
│   │   │   │                                          #   - 조건부 렌더링 (state 기반)
│   │   │   └── vote_card_footer.dart                  # 76 lines - 액션 버튼 영역
│   │   │                                              #   - "투표하기" / "투표 현황 보기" 버튼
│   │   │                                              #   - isMe 구분: "투표 현황 보기" 고정
│   │   │                                              #   - state 기반 버튼 색상 변경
│   │   │                                              #   - 로딩 상태 처리 (isVoting)
│   │   ├── models/                                     # 1 file - 데이터 모델
│   │   │   └── vote_card_props.dart                   # ~80 lines - VoteCardConfig, VoteCardState
│   │   │                                              #   - Config: 불변 설정 (postId, title, images)
│   │   │                                              #   - State: 가변 상태 (isSelected, isVoting)
│   │   ├── utils/                                      # 1 file - 헬퍼 함수
│   │   │   └── vote_card_helpers.dart                 # 130 lines - VoteCardHelpers 클래스
│   │   │                                              #   - highlightText(): 검색어 하이라이팅
│   │   │                                              #   - mapStatusToState(): String → VoteState 변환
│   │   │                                              #   - getStateDisplayText(): 상태 텍스트 반환
│   │   │                                              #   - getStateColor(): 상태별 색상 반환
│   │   │                                              #   - getStateIcon(): 상태별 아이콘 반환
│   │   ├── vote_card_widget.dart                      # 279 lines - 메인 투표 카드 위젯 (Consumer)
│   │   │                                              #   - StreamProvider.family 통합
│   │   │                                              #   - WatchVoteStateUseCase 호출
│   │   │                                              #   - AsyncValue.when() 패턴 (loading, error, data)
│   │   │                                              #   - 4-Component 조합:
│   │   │                                              #     1) VoteCardProfileHeader
│   │   │                                              #     2) VoteCardHeader
│   │   │                                              #     3) VoteCardBody
│   │   │                                              #     4) VoteCardFooter
│   │   │                                              #   - GestureDetector: 투표 / 결과 보기 네비게이션
│   │   │                                              #   - _showVotingDialog(): VotingNotificationDialog 표시
│   │   ├── base_vote_message.dart                     # 299 lines - 채팅 메시지용 베이스 클래스
│   │   │                                              #   - BaseVoteMessageStateMixin 제공
│   │   │                                              #   - ⚠️ TODO: submitVote() 메서드 미연결
│   │   │                                              #   - chat_message_builder.dart에서 사용 대기
│   │   │                                              #   - 실시간 투표 상태 업데이트 구조 준비
│   │   ├── vote_timer_widget.dart                     # 92 lines - 타이머 표시 위젯
│   │   │                                              #   - remainingTime 문자열 렌더링
│   │   │                                              #   - hasUserVoted 구분: 텍스트 색상 변경
│   │   │                                              #   - buildExpiredTimer(): 만료 상태 정적 메서드
│   │   │                                              #   - 진행중 상태에서만 표시
│   │   ├── vote_status_badge.dart                     # 95 lines - 상태 배지 위젯
│   │   │                                              #   - VoteState enum 기반 렌더링
│   │   │                                              #   - 5가지 상태 지원:
│   │   │                                              #     1) votingRequest: 피클요청 (primary)
│   │   │                                              #     2) inProgress: 진행중 (blue)
│   │   │                                              #     3) completed: 완료 (success)
│   │   │                                              #     4) expired: 만료 (textSecondary)
│   │   │                                              #     5) notParticipated: 미참여 (textSecondary)
│   │   │                                              #   - hasUserVoted 구분: "Pick 완료!(진행중)"
│   │   ├── vote_results_widget.dart                   # 215 lines - 투표 결과 표시 위젯
│   │   │                                              #   - _buildDetailedResults(): 상세 결과 (진행바)
│   │   │                                              #   - _buildBasicResults(): 기본 메시지
│   │   │                                              #   - "피클! 피클! 피클! XXX님 결과를 보러오세요!"
│   │   │                                              #   - percentA/percentB 계산 (소수점 반올림)
│   │   │                                              #   - isWinner 시각적 강조
│   │   └── vote_options_widget.dart                   # 213 lines - 투표 옵션 A/B 표시
│   │                                                  #   - _buildHorizontalLayout(): 가로 배치
│   │                                                  #   - _buildVerticalLayout(): 세로 배치
│   │                                                  #   - _buildImageContent(): 이미지 렌더링
│   │                                                  #     * 단일 이미지: CachedNetworkImage
│   │                                                  #     * 멀티 이미지: PageView.builder
│   │                                                  #   - _buildTextContent(): 텍스트 옵션
│   │                                                  #   - UnifiedBoxCalculator의 BoxSizes 사용
│   │                                                  #   - A/B 라벨 배지 표시
│   └── common/                                         # 1 file - 공통 컴포넌트
│       └── simple_avatar.dart                         # ~50 lines - 단순 아바타 위젯
│                                                      #   - 재사용 가능한 원형 아바타
│                                                      #   - CachedNetworkImageProvider 통합
│
├── dialogs/                                            # 25 files (~2,500 lines) - 투표 다이얼로그 시스템
│   ├── voting_dialog/                                  # 7 files - 메인 투표 다이얼로그
│   │   ├── components/                                 # 4 files - 다이얼로그 하위 컴포넌트
│   │   │   ├── voting_dialog_header.dart              # ~80 lines - 다이얼로그 헤더
│   │   │   │                                          #   - 질문 텍스트 표시
│   │   │   │                                          #   - 닫기 버튼 (X 아이콘)
│   │   │   │                                          #   - 타이머 카운트다운
│   │   │   ├── voting_dialog_timer.dart               # ~120 lines - VotingDialogTimer 클래스
│   │   │   │                                          #   - Timer 기반 카운트다운 (10분 제한)
│   │   │   │                                          #   - _formatDuration(): "9:30" 형식 변환
│   │   │   │                                          #   - onTimerUpdate: 1초마다 콜백
│   │   │   │                                          #   - onTimerExpired: 만료 시 콜백
│   │   │   │                                          #   - dispose() 자동 정리
│   │   │   ├── voting_dialog_content.dart             # ~200 lines - 다이얼로그 본문 영역
│   │   │   │                                          #   - VotingBox A/B 배치
│   │   │   │                                          #   - VotingBoxBuilder.buildBoxPair() 사용
│   │   │   │                                          #   - 가로/세로 레이아웃 자동 선택
│   │   │   │                                          #   - selectedBox 상태 관리
│   │   │   └── voting_dialog_actions.dart             # ~150 lines - 액션 버튼 영역
│   │   │                                              #   - "투표하기" 버튼
│   │   │                                              #   - "건너뛰기" 버튼
│   │   │                                              #   - 로딩 상태 처리 (CircularProgressIndicator)
│   │   ├── models/                                     # 1 file - 상태 모델
│   │   │   └── voting_dialog_state.dart               # 92 lines - VotingDialogState 클래스
│   │   │                                              #   - 투표 다이얼로그 상태 관리
│   │   │                                              #   - selectedOption, isVoting, error
│   │   ├── utils/                                      # 1 file - 헬퍼 함수
│   │   │   └── voting_dialog_helpers.dart             # ~100 lines - VotingDialogHelpers
│   │   │                                              #   - showVotingDialog(): 다이얼로그 표시
│   │   │                                              #   - _handleVoteSubmit(): 투표 제출 로직
│   │   └── animations/                                 # 1 file - 애니메이션 정의
│   │       └── voting_dialog_animations.dart          # ~180 lines - VotingDialogAnimations
│   │                                                  #   - fadeIn: 페이드 인 애니메이션
│   │                                                  #   - slideUp: 슬라이드 업 애니메이션
│   │                                                  #   - scaleIn: 스케일 인 애니메이션
│   │                                                  #   - CurvedAnimation 사용
│   ├── voting_box/                                     # 6 files - 투표 박스 컴포넌트
│   │   ├── components/                                 # 4 files - 박스 하위 컴포넌트
│   │   │   ├── voting_box_header.dart                 # ~120 lines - 박스 헤더
│   │   │   │                                          #   - A/B 라벨 표시
│   │   │   │                                          #   - 투표 수 표시 (showResult 모드)
│   │   │   │                                          #   - votePercentage 렌더링
│   │   │   ├── voting_box_content.dart                # ~180 lines - 박스 본문
│   │   │   │                                          #   - 이미지 렌더링 (CachedNetworkImage)
│   │   │   │                                          #   - 멀티이미지 지원 (PageView)
│   │   │   │                                          #   - 텍스트 옵션 표시
│   │   │   │                                          #   - gradientColors 적용
│   │   │   ├── voting_box_overlay.dart                # ~150 lines - 오버레이 레이어
│   │   │   │                                          #   - 선택 상태 오버레이 (isSelected)
│   │   │   │                                          #   - 결과 오버레이 (showResult)
│   │   │   │                                          #   - 디버그 정보 표시 (showDebugInfo)
│   │   │   └── voting_box_animations.dart             # ~100 lines - 박스 애니메이션
│   │   │                                              #   - FadeTransition
│   │   │                                              #   - ScaleTransition
│   │   │                                              #   - AnimationController 통합
│   │   ├── models/                                     # 1 file - 박스 모델
│   │   │   └── voting_box_state.dart                  # ~120 lines - VotingBoxConfig, VotingBoxState
│   │   │                                              #   - Config: 불변 설정 (boxType, title, images)
│   │   │                                              #   - State: 가변 상태 (isSelected, showResult)
│   │   └── utils/                                      # 1 file - 헬퍼 함수
│   │       └── voting_box_helpers.dart                # ~200 lines - VotingBoxHelpers
│   │                                                  #   - validateBoxSize(): 크기 검증
│   │                                                  #   - getAdaptiveTextSize(): 텍스트 크기 계산
│   │                                                  #   - showImageViewer(): 이미지 뷰어 표시
│   ├── image_viewer/                                   # 7 files - 이미지 뷰어
│   │   ├── components/                                 # 5 files - 뷰어 하위 컴포넌트
│   │   │   ├── image_viewer_app_bar.dart              # ~80 lines - 뷰어 상단 바
│   │   │   │                                          #   - boxType 표시 (A 또는 B)
│   │   │   │                                          #   - 이미지 인덱스 표시 (1/3)
│   │   │   │                                          #   - 닫기 버튼
│   │   │   ├── image_viewer_page_view.dart            # ~150 lines - 이미지 스와이프 뷰
│   │   │   │                                          #   - PageView.builder
│   │   │   │                                          #   - CachedNetworkImage 통합
│   │   │   │                                          #   - onPageChanged 콜백
│   │   │   │                                          #   - 인접 이미지 프리로딩 (UnifiedImageCacheService)
│   │   │   ├── image_viewer_controls.dart             # ~120 lines - 뷰어 컨트롤
│   │   │   │                                          #   - DualModeViewerWrapper
│   │   │   │                                          #   - 좌우 스와이프 감지
│   │   │   │                                          #   - A ↔ B 박스 전환
│   │   │   │                                          #   - GestureDetector 통합
│   │   │   ├── image_viewer_indicators.dart           # ~100 lines - 페이지 인디케이터
│   │   │   │                                          #   - 현재 페이지 표시 (도트)
│   │   │   │                                          #   - A/B 박스 구분
│   │   │   │                                          #   - 애니메이션 전환
│   │   │   └── image_viewer_text_sections.dart        # ~150 lines - 텍스트 정보 영역
│   │   │                                              #   - 질문 텍스트
│   │   │                                              #   - 옵션 A/B 텍스트
│   │   │                                              #   - 설명 (description)
│   │   └── utils/                                      # 1 file - 헬퍼 함수
│   │       └── image_viewer_helpers.dart              # ~180 lines - ImageViewerHelpers
│   │                                                  #   - getEffectiveImageUrls(): 유효한 이미지 URL 추출
│   │                                                  #   - calculateInitialPosition(): 초기 위치 계산
│   │                                                  #   - 멀티이미지 지원 로직
│   ├── voting_dialog.dart                             # 410 lines - 메인 투표 다이얼로그 위젯 (Consumer)
│   │                                                  #   - 듀얼 모드 지원:
│   │                                                  #     1) Full Voting Mode: 투표 + 타이머
│   │                                                  #     2) Simple Notification Mode: 결과만 표시
│   │                                                  #   - TickerProviderStateMixin: 애니메이션 관리
│   │                                                  #   - VotingDialogTimer 통합
│   │                                                  #   - VoteSubmissionController (ref.read)
│   │                                                  #   - _handleVoteSubmission(): 투표 제출 로직
│   │                                                  #   - _showErrorSnackBar(): 에러 처리
│   │                                                  #   - UnifiedImageCacheService.preloadImages(): 이미지 프리로딩
│   ├── voting_dialog_constraints.dart                 # 233 lines - UI 제약 조건
│   │                                                  #   - 화면 크기별 스케일링 팩터
│   │                                                  #   - 박스 크기 제약 (최소/최대)
│   │                                                  #   - 텍스트 크기 계산
│   │                                                  #   - 애니메이션 설정 (Duration)
│   │                                                  #   - 그림자/Elevation 설정
│   │                                                  #   - Border radius 설정
│   │                                                  #   - getScaleFactor(): 화면 너비 기반 스케일링
│   │                                                  #   - getNotificationWidth(): 알림 너비 계산
│   │                                                  #   - constrainBoxSize(): 크기 제약 적용
│   ├── voting_image_viewer.dart                       # 394 lines - 이미지 뷰어 메인 위젯
│   │                                                  #   - ConsumerStatefulWidget
│   │                                                  #   - 단일/듀얼 모드 지원
│   │                                                  #   - 독립적인 PageController (A/B 각각)
│   │                                                  #   - AnimatedOpacity: A ↔ B 전환
│   │                                                  #   - ImageViewerHelpers 통합
│   │                                                  #   - UnifiedImageCacheService.preloadAdjacentImages()
│   │                                                  #   - show(): 정적 메서드 (PageRouteBuilder)
│   ├── voting_box.dart                                # 463 lines - 투표 박스 메인 위젯
│   │                                                  #   - VotingBox 클래스
│   │                                                  #   - VotingBoxBuilder 팩토리
│   │                                                  #   - buildFromSizeData(): VersusBoxSizeData 기반 빌드
│   │                                                  #   - buildBoxPair(): A/B 박스 쌍 생성
│   │                                                  #   - IBoxCalculatorService 통합 (GetIt DI)
│   │                                                  #   - calculateForNotificationDialog(): 크기 계산
│   │                                                  #   - 멀티이미지 지원 (imageUrlsA/B)
│   │                                                  #   - 레이아웃 자동 선택 (horizontal/vertical)
│   └── vote_ui_manager.dart                           # 335 lines - UI 관리 싱글톤
│                                                      #   - 투표 UI 상태 중앙 관리
│                                                      #   - showVotingDialog(): 다이얼로그 표시
│                                                      #   - showImageViewer(): 이미지 뷰어 표시
│                                                      #   - isDialogShowing: 중복 방지 플래그
│
└── providers/                                          # 2 files (~350 lines) - 상태 관리 레이어
    ├── vote_providers.dart                            # 210 lines - 투표 제출 Provider
    │                                                  #   - VoteSubmissionController 클래스
    │                                                  #   - selectedOptionProvider: StateProvider<String?>
    │                                                  #   - isVotingProvider: StateProvider<bool>
    │                                                  #   - SubmitVoteUseCase 통합 (GetIt DI)
    │                                                  #   - submitVote(): Either<VotingFailure, PostVoting>
    │                                                  #   - 18가지 VotingFailure 타입 매핑:
    │                                                  #     1) duplicateVote → "이미 투표하셨습니다"
    │                                                  #     2) voteExpired → "투표가 종료되었습니다"
    │                                                  #     3) networkError → "네트워크 오류"
    │                                                  #     4) serverError → "서버 오류"
    │                                                  #     ... (14가지 추가 실패 타입)
    └── vote_state_providers.dart                      # 140 lines - 투표 상태 Provider
                                                       #   - VoteStateParams 클래스 (postId, userId, voteEndTime)
                                                       #   - voteStateStreamProvider: StreamProvider.family
                                                       #   - WatchVoteStateUseCase 통합 (GetIt DI)
                                                       #   - keepAlive(): 캐싱 전략
                                                       #   - Immediate Loading 패턴:
                                                       #     * yield defaultState 먼저 (깜빡임 방지)
                                                       #     * await for stream 실시간 업데이트
                                                       #   - VoteStateData → AsyncValue<VoteStateData> 변환
                                                       #   - Coordinator BehaviorSubject 대체
```

---

## Chat Vote Card - 채팅 투표 카드 시스템

### 개요

채팅 메시지에 표시되는 투표 카드 시스템입니다. **Component-Driven Architecture**를 따라 4개의 주요 컴포넌트로 분해되었습니다:

1. **VoteCardProfileHeader**: Pikle 브랜딩 + 발신자 정보
2. **VoteCardHeader**: 상태 배지 + 타이머
3. **VoteCardBody**: 제목 + 설명 + 옵션/결과
4. **VoteCardFooter**: 액션 버튼

### 핵심 컴포넌트

#### 1. VoteCardWidget (메인 컨테이너)

```dart
class VoteCardWidget extends ConsumerStatefulWidget {
  // StreamProvider.family 통합
  final voteStateAsync = ref.watch(voteStateStreamProvider(voteStateParams));

  return voteStateAsync.when(
    loading: () => _buildCard(defaultState),      // 기본 상태 즉시 표시
    error: (error, stack) => _buildErrorCard(),   // 에러 UI
    data: (stateData) => _buildCard(stateData),   // 실시간 데이터
  );
}
```

**특징**:
- `AsyncValue.when()` 패턴으로 로딩/에러/데이터 상태 처리
- Domain Layer의 `WatchVoteStateUseCase` 호출
- 4개 컴포넌트 조합으로 UI 구성
- GestureDetector로 투표/결과 보기 네비게이션

**Domain Layer 의존성**:
```dart
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/features/voting/domain/entities/chat/vote_state_data.dart';
import '/features/voting/presentation/providers/vote_state_providers.dart';
```

#### 2. VoteCardProfileHeader (프로필 영역)

```dart
/// Pikle 브랜딩 + 발신자 정보 표시
Widget build(BuildContext context) {
  return Row(
    children: [
      // 1) 프로필 이미지 (40px 원형)
      CircleAvatar(radius: 20, ...),

      // 2) Pikle 브랜딩 + 발신자명
      Column(
        children: [
          Row([Pikle 아이콘, "Pikle 도착!"]),
          Text(isMe ? "나 • 투표 생성됨" : "XXX님이 물어봅니다"),
        ],
      ),

      // 3) 상태 배지 (VoteState enum 기반)
      Container([아이콘, 텍스트]),
    ],
  );
}
```

**isMe 구분 로직**:
- `isMe == true` → "내가 만든 피클" + "나 • 투표 생성됨"
- `isMe == false` → "Pikle 도착!" + "XXX님이 물어봅니다"

#### 3. VoteStatusBadge (상태 배지)

**5가지 VoteState 매핑**:

| VoteState | 텍스트 | 색상 | 아이콘 |
|-----------|--------|------|--------|
| `votingRequest` | 피클요청 | primary | how_to_vote |
| `inProgress` | 진행중 / Pick 완료!(진행중) | blue | timer / check_circle_outline |
| `completed` | 완료 | success | check_circle |
| `expired` | 만료 | textSecondary | timer_off |
| `notParticipated` | 미참여 | textSecondary | block |

```dart
// hasUserVoted에 따른 텍스트 변경
if (state == VoteState.inProgress) {
  return hasUserVoted
    ? "Pick 완료!(진행중)"
    : "진행중";
}
```

#### 4. VoteOptionsWidget (투표 옵션 A/B)

```dart
/// 가로/세로 레이아웃 자동 선택
if (isHorizontal) {
  return Row([
    Expanded(child: _buildOptionBox(A)),
    SizedBox(width: 8),
    Expanded(child: _buildOptionBox(B)),
  ]);
} else {
  return Column([
    _buildOptionBox(A),
    SizedBox(height: 8),
    _buildOptionBox(B),
  ]);
}
```

**이미지 렌더링 전략**:
- **단일 이미지**: `CachedNetworkImage` 직접 표시
- **멀티 이미지**: `PageView.builder`로 스와이프 가능

```dart
if (images.length == 1) {
  return CachedNetworkImage(
    imageUrl: images[0],
    memCacheWidth: memCacheWidth,  // 동적 캐시 크기 계산
  );
} else {
  return PageView.builder(
    itemCount: images.length,
    itemBuilder: (context, index) {
      return CachedNetworkImage(imageUrl: images[index]);
    },
  );
}
```

#### 5. VoteResultsWidget (결과 표시)

```dart
/// 상세 결과 vs 기본 메시지
if (state == VoteState.completed && voteResults != null) {
  return _buildDetailedResults();  // 진행바 + 퍼센트
}
return _buildBasicResults();  // "피클! 피클! 피클! XXX님 결과를 보러오세요!"
```

**진행바 계산 로직**:
```dart
final votesA = voteResults?['votesA'] ?? 0;
final votesB = voteResults?['votesB'] ?? 0;
final totalVotes = votesA + votesB;

final percentA = (votesA / totalVotes * 100).round();
final percentB = (votesB / totalVotes * 100).round();

// isWinner 시각적 강조
_buildResultBar(
  label: 'A',
  votes: votesA,
  percentage: percentA,
  isWinner: votesA > votesB,
);
```

### BaseVoteMessage (TODO: 미완성)

```dart
/// ⚠️ TODO: chat_message_builder.dart에서 submitVote() 연결 필요
class BaseVoteMessage extends StatefulWidget {
  // submitVote() 메서드 존재하지만 미사용 상태

  Future<void> submitVote(String postId, String voteOption) async {
    // VoteSubmissionController 통합 준비 완료
    // chat_message_builder.dart에서 이 메서드 호출 필요
  }
}
```

**해결 방법**:
1. `chat_message_builder.dart`에서 `BaseVoteMessage` import
2. VoteCard의 `onVote` 콜백에서 `submitVote()` 호출
3. `VoteSubmissionController.submitVote()` 체인 연결

---

## Dialogs - 투표 다이얼로그 시스템

### 개요

투표 알림 및 투표 다이얼로그를 관리하는 시스템입니다. 3개의 주요 다이얼로그로 구성:

1. **VotingDialog**: 메인 투표 다이얼로그 (Full Mode + Simple Mode)
2. **VotingBox**: A/B 투표 박스 컴포넌트
3. **VotingImageViewer**: 전체화면 이미지 뷰어

### 핵심 컴포넌트

#### 1. VotingDialog (메인 다이얼로그)

**듀얼 모드 지원**:

```dart
/// Full Voting Mode (투표 + 타이머)
if (mode == VotingMode.full) {
  return Column([
    VotingDialogHeader(timer: true),
    VotingDialogContent(boxes: A/B, selectable: true),
    VotingDialogActions(buttons: ["투표하기", "건너뛰기"]),
  ]);
}

/// Simple Notification Mode (결과만 표시)
if (mode == VotingMode.simple) {
  return Column([
    VotingDialogHeader(timer: false),
    VotingDialogContent(boxes: A/B, selectable: false, showResults: true),
  ]);
}
```

**애니메이션 시스템**:
```dart
class _VotingDialogState extends State<VotingDialog>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: VotingDialogConstraints.fadeAnimationDuration,
      vsync: this,
    );
    _slideController = AnimationController(
      duration: VotingDialogConstraints.slideAnimationDuration,
      vsync: this,
    );

    // 애니메이션 시작
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
```

**투표 제출 로직**:
```dart
Future<void> _handleVoteSubmission() async {
  if (_selectedOption == null) return;

  setState(() => _isVoting = true);

  // VoteSubmissionController 사용
  final controller = ref.read(voteSubmissionControllerProvider);
  final result = await controller.submitVote(
    postId: widget.postId,
    voteOption: _selectedOption!,
    userId: widget.userId,
  );

  result.fold(
    (failure) => _showErrorSnackBar(failure),  // Left: 실패
    (success) => Navigator.pop(context),        // Right: 성공
  );

  setState(() => _isVoting = false);
}
```

#### 2. VotingBox (투표 박스 컴포넌트)

**VotingBoxBuilder 팩토리 패턴**:

```dart
/// 사이즈 데이터를 기반으로 자동 빌드
Widget buildFromSizeData({
  required BuildContext context,
  required VersusBoxSizeData sizeData,
  required String boxType,
  required String title,
  String? imageUrl,
  List<String>? imageUrls,  // 멀티이미지 지원
}) {
  // 1) IBoxCalculatorService로 크기 계산
  final votingSizes = _boxCalculator.calculateForNotificationDialog(
    dialogWidth: MediaQuery.of(context).size.width * 0.92,
    layoutType: sizeData.layoutType,
    aspectRatioA: sizeData.aspectRatioA,
    aspectRatioB: sizeData.aspectRatioB,
  );

  // 2) 박스 타입에 따라 크기 선택
  final boxSize = boxType == 'A' ? votingSizes.sizeA : votingSizes.sizeB;

  // 3) VotingBox 위젯 생성
  return VotingBox.legacy(
    boxType: boxType,
    boxSize: boxSize,
    title: title,
    imageUrl: imageUrl,
    imageUrls: imageUrls,
  );
}
```

**A/B 박스 쌍 생성**:
```dart
Widget buildBoxPair({
  required BuildContext context,
  required VersusBoxSizeData sizeData,
  required String titleA,
  required String titleB,
  String? selectedBox,
}) {
  final votingSizes = _boxCalculator.calculateForNotificationDialog(...);

  if (votingSizes.layoutType == LayoutType.horizontal) {
    return Row([
      buildFromSizeData(boxType: 'A', ...),
      SizedBox(width: votingSizes.spacing),
      buildFromSizeData(boxType: 'B', ...),
    ]);
  } else {
    return Column([
      buildFromSizeData(boxType: 'A', ...),
      SizedBox(height: votingSizes.spacing),
      buildFromSizeData(boxType: 'B', ...),
    ]);
  }
}
```

#### 3. VotingDialogConstraints (UI 제약 조건)

**화면 크기별 스케일링**:
```dart
static double getScaleFactor(double screenWidth) {
  if (screenWidth > 400) return 1.0;      // 큰 화면: 100%
  if (screenWidth > 350) return 0.95;     // 중간 화면: 95%
  return 0.85;                            // 작은 화면: 85%
}
```

**박스 크기 제약**:
```dart
static Size constrainBoxSize(
  Size proposedSize,
  double scaleFactor,
  {double? maxWidth, double? screenHeight}
) {
  final maxHeight = screenHeight != null
    ? getMaxBoxHeight(screenHeight)  // 화면 높이의 80%
    : 500.0;

  // 1) 높이 제약 적용
  constrainedHeight = scaledHeight.clamp(minBoxHeight, maxHeight);

  // 2) 비율 유지하면서 너비 조정
  final aspectRatio = proposedSize.width / proposedSize.height;
  constrainedWidth = constrainedHeight * aspectRatio;

  // 3) 너비 제약 적용
  if (maxWidth != null && constrainedWidth > maxWidth) {
    constrainedWidth = maxWidth;
    constrainedHeight = constrainedWidth / aspectRatio;
  }

  return Size(constrainedWidth, constrainedHeight);
}
```

#### 4. VotingImageViewer (이미지 뷰어)

**듀얼 모드 지원 (A/B 박스 독립 관리)**:
```dart
class _VotingImageViewerState extends ConsumerState<VotingImageViewer> {
  // 각 박스별 독립적인 PageController
  late PageController _pageControllerA;
  late PageController _pageControllerB;

  // 박스별 상태 변수
  String _currentBoxType = 'A';
  int _currentIndexInBoxA = 0;
  int _currentIndexInBoxB = 0;

  @override
  void initState() {
    super.initState();

    // 효과적인 URL 리스트 계산
    _effectiveUrlsA = ImageViewerHelpers.getEffectiveImageUrls(
      boxType: 'A',
      imageUrlsA: widget.imageUrlsA,
      imageUrlsB: widget.imageUrlsB,
      imageUrlA: widget.imageUrlA,
      imageUrlB: widget.imageUrlB,
    );

    _effectiveUrlsB = ImageViewerHelpers.getEffectiveImageUrls(
      boxType: 'B',
      ...
    );

    // PageController 초기화
    _pageControllerA = PageController(initialPage: _currentIndexInBoxA);
    _pageControllerB = PageController(initialPage: _currentIndexInBoxB);
  }
}
```

**A ↔ B 전환 로직**:
```dart
/// 듀얼 모드 뷰어 (A/B 레이어 전환)
Widget _buildDualModeViewer() {
  return DualModeViewerWrapper(
    canSwitchToA: _effectiveUrlsA.isNotEmpty && _currentBoxType == 'B',
    canSwitchToB: _effectiveUrlsB.isNotEmpty && _currentBoxType == 'A',
    onSwitchToA: _handleSwitchToA,
    onSwitchToB: _handleSwitchToB,
    child: Stack([
      // A박스 레이어
      AnimatedOpacity(
        opacity: _currentBoxType == 'A' ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: ImageViewerPageView(
          imageUrls: _effectiveUrlsA,
          controller: _pageControllerA,
          onPageChanged: (index) {
            setState(() => _currentIndexInBoxA = index);
            // 인접 이미지 프리로딩
            UnifiedImageCacheService.instance.preloadAdjacentImages(
              context, _effectiveUrlsA, index, range: 2,
            );
          },
        ),
      ),

      // B박스 레이어 (동일 구조)
      AnimatedOpacity(...),
    ]),
  );
}
```

#### 5. VoteUIManager (싱글톤 관리자)

```dart
class VoteUIManager {
  static final VoteUIManager _instance = VoteUIManager._internal();
  factory VoteUIManager() => _instance;
  VoteUIManager._internal();

  bool _isDialogShowing = false;

  /// 투표 다이얼로그 표시 (중복 방지)
  Future<void> showVotingDialog(BuildContext context, ...) async {
    if (_isDialogShowing) {
      print('[VoteUIManager] 다이얼로그가 이미 표시 중입니다');
      return;
    }

    _isDialogShowing = true;

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => VotingDialog(...),
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  /// 이미지 뷰어 표시
  void showImageViewer(BuildContext context, ...) {
    VotingImageViewer.show(
      context,
      question: question,
      optionA: optionA,
      optionB: optionB,
      imageUrlsA: imageUrlsA,
      imageUrlsB: imageUrlsB,
    );
  }
}
```

---

## Providers - 상태 관리 레이어

### 개요

Riverpod 기반 상태 관리 시스템입니다. 2개의 핵심 Provider로 구성:

1. **vote_providers.dart**: 투표 제출 로직 (SubmitVoteUseCase 통합)
2. **vote_state_providers.dart**: 투표 상태 스트림 (WatchVoteStateUseCase 통합)

### 1. VoteSubmissionController (투표 제출)

```dart
final voteSubmissionControllerProvider = Provider((ref) {
  return VoteSubmissionController(ref);
});

class VoteSubmissionController {
  final Ref _ref;

  VoteSubmissionController(this._ref);

  /// 투표 제출 메서드
  Future<Either<VotingFailure, PostVoting>> submitVote({
    required String postId,
    required String voteOption,
    required String userId,
  }) async {
    // 1) 로딩 상태 활성화
    _ref.read(isVotingProvider.notifier).state = true;

    try {
      // 2) UseCase 호출 (GetIt DI)
      final useCase = GetIt.instance<SubmitVoteUseCase>();
      final result = await useCase.call(
        postId: postId,
        userId: userId,
        voteOption: voteOption,
      );

      // 3) 성공 시 선택된 옵션 저장
      result.fold(
        (failure) => null,
        (success) {
          _ref.read(selectedOptionProvider.notifier).state = voteOption;
        },
      );

      return result;
    } finally {
      // 4) 로딩 상태 비활성화
      _ref.read(isVotingProvider.notifier).state = false;
    }
  }
}
```

**StateProvider 정의**:
```dart
/// 선택된 투표 옵션
final selectedOptionProvider = StateProvider<String?>((ref) => null);

/// 투표 진행 중 여부
final isVotingProvider = StateProvider<bool>((ref) => false);
```

**18가지 VotingFailure 매핑**:
```dart
String _mapFailureToMessage(VotingFailure failure) {
  return failure.when(
    duplicateVote: () => '이미 투표하셨습니다',
    voteExpired: () => '투표가 종료되었습니다',
    postNotFound: () => '게시물을 찾을 수 없습니다',
    invalidVoteOption: () => '유효하지 않은 투표 옵션입니다',
    userNotAuthenticated: () => '로그인이 필요합니다',
    networkError: () => '네트워크 오류가 발생했습니다',
    serverError: () => '서버 오류가 발생했습니다',
    databaseError: () => '데이터베이스 오류가 발생했습니다',
    unknownError: () => '알 수 없는 오류가 발생했습니다',
    // ... (9가지 추가 실패 타입)
  );
}
```

### 2. VoteStateStreamProvider (투표 상태 스트림)

```dart
final voteStateStreamProvider = StreamProvider.family
    .autoDispose<VoteStateData, VoteStateParams>((ref, params) async* {
  // 1) 기본 상태 즉시 반환 (깜빡임 방지)
  final defaultState = VoteStateData(
    state: VoteState.votingRequest,
    voteEndTime: params.voteEndTime,
  );
  yield defaultState;

  // 2) UseCase 호출 (GetIt DI)
  final useCase = GetIt.instance<WatchVoteStateUseCase>();
  final stream = useCase.call(
    postId: params.postId,
    userId: params.userId,
    voteEndTime: params.voteEndTime,
  );

  // 3) 실시간 스트림 전달
  await for (final stateData in stream) {
    yield stateData;
  }
});
```

**VoteStateParams 클래스**:
```dart
@freezed
class VoteStateParams with _$VoteStateParams {
  const factory VoteStateParams({
    required String postId,
    String? userId,
    DateTime? voteEndTime,
  }) = _VoteStateParams;
}
```

**keepAlive() 패턴 (캐싱)**:
```dart
/// autoDispose 방지 - 상태 유지
ref.keepAlive();

// 설명:
// - autoDispose: Provider가 더 이상 사용되지 않으면 자동 폐기
// - keepAlive(): 명시적으로 상태 유지 (캐싱 효과)
```

**Immediate Loading 패턴**:
```dart
// ✅ 좋은 예: 기본 상태 먼저 yield
yield VoteStateData(state: VoteState.votingRequest);
await for (final data in stream) {
  yield data;
}

// ❌ 나쁜 예: 스트림 대기로 인한 깜빡임
await for (final data in stream) {
  yield data;
}
```

---

## Domain Layer 연결성

### Presentation → Domain 의존성

Presentation Layer는 **오직 Domain Layer만** 참조합니다 (Clean Architecture v4.0).

```
Presentation Layer
    ↓
    ↓ (허용: import domain entities, usecases, repositories)
    ↓
Domain Layer
    ↓
    ↓ (금지: Presentation은 Data를 직접 참조 불가)
    ↓
Data Layer
```

### Domain 의존성 맵

#### Entities

```dart
// Presentation에서 사용하는 Domain Entities
import '/features/voting/domain/entities/chat/vote_state.dart';
import '/features/voting/domain/entities/chat/vote_state_data.dart';
import '/features/voting/domain/entities/dialog/post_voting.dart';
import '/features/voting/domain/entities/dialog/vote_counts.dart';
import '/features/voting/domain/entities/dialog/versus_box_size_data.dart';
```

**VoteState enum (5가지 상태)**:
```dart
enum VoteState {
  votingRequest,     // 피클 요청 (투표 전)
  inProgress,        // 진행중 (투표 후, 타이머 중)
  completed,         // 완료 (10분 경과 or 수동 완료)
  expired,           // 만료 (타임아웃)
  notParticipated,   // 미참여 (알림 받지 않음)
}
```

**VoteStateData (투표 상태 데이터)**:
```dart
@freezed
class VoteStateData with _$VoteStateData {
  const factory VoteStateData({
    required VoteState state,
    @Default(false) bool hasUserVoted,
    String? userVoteOption,
    Duration? remainingTime,
    @Default(false) bool isTimerExpired,
    DateTime? voteEndTime,
  }) = _VoteStateData;
}
```

**VersusBoxSizeData (박스 크기 데이터)**:
```dart
@freezed
class VersusBoxSizeData with _$VersusBoxSizeData {
  const factory VersusBoxSizeData({
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    @Default(true) bool hasImageA,
    @Default(true) bool hasImageB,
  }) = _VersusBoxSizeData;
}
```

#### UseCases

```dart
// Presentation에서 호출하는 Domain UseCases
final submitVoteUseCase = GetIt.instance<SubmitVoteUseCase>();
final watchVoteStateUseCase = GetIt.instance<WatchVoteStateUseCase>();
```

**SubmitVoteUseCase (투표 제출)**:
```dart
/// Domain Layer UseCase
Future<Either<VotingFailure, PostVoting>> call({
  required String postId,
  required String userId,
  required String voteOption,
}) async {
  // 1) 비즈니스 규칙 검증
  if (voteOption != 'A' && voteOption != 'B') {
    return left(VotingFailure.invalidVoteOption());
  }

  // 2) Repository 호출 (Data Layer)
  final result = await _repository.castVote(
    postId: postId,
    userId: userId,
    voteOption: voteOption,
  );

  // 3) Either 반환
  return result.fold(
    (failure) => left(failure),
    (success) => right(success),
  );
}
```

**WatchVoteStateUseCase (상태 감시)**:
```dart
/// Domain Layer UseCase
Stream<VoteStateData> call({
  required String postId,
  String? userId,
  DateTime? voteEndTime,
}) async* {
  // 1) Repository Stream 구독
  final stream = _repository.watchVoteState(postId);

  // 2) VoteStateData 변환
  await for (final data in stream) {
    // 비즈니스 로직 적용
    final stateData = _calculateVoteState(data, userId, voteEndTime);
    yield stateData;
  }
}
```

#### Failures

```dart
// Presentation에서 처리하는 Domain Failures
import '/features/voting/domain/failures/voting_failure.dart';
```

**VotingFailure (18가지 실패 타입)**:
```dart
@freezed
class VotingFailure with _$VotingFailure {
  const factory VotingFailure.duplicateVote() = _DuplicateVote;
  const factory VotingFailure.voteExpired() = _VoteExpired;
  const factory VotingFailure.postNotFound() = _PostNotFound;
  const factory VotingFailure.invalidVoteOption() = _InvalidVoteOption;
  const factory VotingFailure.userNotAuthenticated() = _UserNotAuthenticated;
  const factory VotingFailure.networkError() = _NetworkError;
  const factory VotingFailure.serverError() = _ServerError;
  const factory VotingFailure.databaseError() = _DatabaseError;
  const factory VotingFailure.permissionDenied() = _PermissionDenied;
  const factory VotingFailure.rateLimitExceeded() = _RateLimitExceeded;
  const factory VotingFailure.idempotencyViolation() = _IdempotencyViolation;
  const factory VotingFailure.concurrentModification() = _ConcurrentModification;
  const factory VotingFailure.dataIntegrityError() = _DataIntegrityError;
  const factory VotingFailure.serviceUnavailable() = _ServiceUnavailable;
  const factory VotingFailure.timeout() = _Timeout;
  const factory VotingFailure.cacheError() = _CacheError;
  const factory VotingFailure.validationError(String message) = _ValidationError;
  const factory VotingFailure.unknownError() = _UnknownError;
}
```

#### Repository Interfaces

```dart
// Presentation은 Repository를 직접 호출하지 않음
// UseCase를 통해 간접 호출 (Dependency Inversion)

// ✅ 좋은 예: UseCase 사용
final useCase = GetIt.instance<SubmitVoteUseCase>();
final result = await useCase.call(...);

// ❌ 나쁜 예: Repository 직접 호출 (금지)
final repository = GetIt.instance<IVotingDialogRepository>();
final result = await repository.castVote(...);  // 위반!
```

#### Services

```dart
// Presentation에서 사용하는 Domain Services
import '/features/voting/domain/services/i_box_calculator_service.dart';
```

**IBoxCalculatorService (박스 크기 계산)**:
```dart
/// Domain Layer Interface
abstract class IBoxCalculatorService {
  /// 알림 다이얼로그용 크기 계산
  BoxSizes calculateForNotificationDialog({
    required double dialogWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  });

  /// 메시지 카드용 크기 계산
  BoxSizes calculateForMessageCard({
    required double bubbleWidth,
    required LayoutType layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    bool hasImageA = true,
    bool hasImageB = true,
  });
}
```

**BoxSizes (계산 결과)**:
```dart
@freezed
class BoxSizes with _$BoxSizes {
  const factory BoxSizes({
    required double boxWidthA,
    required double boxHeightA,
    required double boxWidthB,
    required double boxHeightB,
    required double spacing,
    required LayoutType layoutType,
  }) = _BoxSizes;
}
```

---

## Data Layer 연결성

### Presentation → Data (금지)

Clean Architecture v4.0에 따라 **Presentation Layer는 Data Layer를 직접 참조할 수 없습니다**.

```
❌ Presentation → Data (금지)
✅ Presentation → Domain → Data (허용)
```

### UseCase를 통한 간접 호출

```dart
// ❌ 나쁜 예: Data Layer 직접 참조
import '/features/voting/data/repositories/voting_dialog_repository_impl.dart';

final repository = VotingDialogRepositoryImpl();
final result = await repository.castVote(...);  // 위반!

// ✅ 좋은 예: Domain UseCase 사용
import '/features/voting/domain/usecases/submit_vote_usecase.dart';

final useCase = GetIt.instance<SubmitVoteUseCase>();
final result = await useCase.call(...);  // Domain Interface 호출
```

### Dependency Injection (GetIt)

**DI 설정 예시 (app/di.dart)**:
```dart
void setupDependencies() {
  // Data Layer: Repository 구현체
  GetIt.instance.registerLazySingleton<IVotingDialogRepository>(
    () => VotingDialogRepositoryImpl(),
  );

  // Domain Layer: UseCase
  GetIt.instance.registerLazySingleton<SubmitVoteUseCase>(
    () => SubmitVoteUseCase(GetIt.instance<IVotingDialogRepository>()),
  );

  // Domain Layer: Service
  GetIt.instance.registerLazySingleton<IBoxCalculatorService>(
    () => BoxCalculatorService(),
  );
}
```

**Presentation에서 DI 사용**:
```dart
class VoteSubmissionController {
  Future<Either<VotingFailure, PostVoting>> submitVote(...) async {
    // Domain Layer UseCase 획득
    final useCase = GetIt.instance<SubmitVoteUseCase>();

    // UseCase 호출 (Domain → Data → Firebase)
    return await useCase.call(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
  }
}
```

### Data Layer가 제공하는 기능

**Presentation이 간접적으로 사용하는 Data Layer 기능**:

1. **Firebase Integration**
   - Firestore: 투표 데이터 저장/조회
   - Firebase Functions: 투표 완료 처리 (onPostVoteUpdate)
   - Realtime Streaming: `watchVoteState()` 스트림

2. **IdempotencyService**
   - UUID 기반 중복 방지
   - 동일 투표 2회 제출 차단

3. **ShardUtils**
   - 256-shard 분산 카운팅
   - FNV-1a 해시 기반 샤드 ID

4. **VoteTimerService**
   - 10분 타이머 서버 동기화
   - 실시간 남은 시간 계산

5. **Local Cache (Hive)**
   - 투표 상태 캐싱
   - 오프라인 지원

**호출 체인**:
```
Presentation (VoteSubmissionController)
    ↓ submitVote()
Domain (SubmitVoteUseCase)
    ↓ _repository.castVote()
Data (VotingDialogRepositoryImpl)
    ↓ Firestore transaction
    ↓ IdempotencyService.generateKey()
    ↓ ShardUtils.incrementShard()
Firebase (posts, votes, shards collections)
```

---

## Riverpod 패턴 및 상태 관리

### Riverpod 2.x 패턴

#### 1. StreamProvider.family (PostID별 독립 상태)

```dart
/// Family: postId + userId + voteEndTime 조합으로 독립 Provider 생성
final voteStateStreamProvider = StreamProvider.family
    .autoDispose<VoteStateData, VoteStateParams>((ref, params) async* {

  // keepAlive(): autoDispose 방지 (캐싱)
  ref.keepAlive();

  // Immediate Loading 패턴
  yield VoteStateData(state: VoteState.votingRequest);

  // UseCase 스트림 구독
  final useCase = GetIt.instance<WatchVoteStateUseCase>();
  final stream = useCase.call(
    postId: params.postId,
    userId: params.userId,
    voteEndTime: params.voteEndTime,
  );

  await for (final data in stream) {
    yield data;
  }
});
```

**사용 예시**:
```dart
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1) VoteStateParams 생성
    final params = VoteStateParams(
      postId: widget.postId,
      userId: currentUserId,
      voteEndTime: widget.voteEndTime,
    );

    // 2) Provider 구독
    final voteStateAsync = ref.watch(voteStateStreamProvider(params));

    // 3) AsyncValue 패턴
    return voteStateAsync.when(
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(),
      data: (stateData) => _buildVoteCard(stateData),
    );
  }
}
```

#### 2. StateProvider (단순 상태)

```dart
/// 선택된 투표 옵션
final selectedOptionProvider = StateProvider<String?>((ref) => null);

/// 투표 진행 중 여부
final isVotingProvider = StateProvider<bool>((ref) => false);
```

**사용 예시**:
```dart
// 읽기: ref.watch()
final selectedOption = ref.watch(selectedOptionProvider);
final isVoting = ref.watch(isVotingProvider);

// 쓰기: ref.read().notifier.state
ref.read(selectedOptionProvider.notifier).state = 'A';
ref.read(isVotingProvider.notifier).state = true;
```

#### 3. Provider (인스턴스 제공)

```dart
/// VoteSubmissionController 제공
final voteSubmissionControllerProvider = Provider((ref) {
  return VoteSubmissionController(ref);
});
```

**사용 예시**:
```dart
// 컨트롤러 획득
final controller = ref.read(voteSubmissionControllerProvider);

// 메서드 호출
final result = await controller.submitVote(
  postId: postId,
  voteOption: 'A',
  userId: userId,
);
```

### AsyncValue.when() 패턴

**3가지 상태 처리**:
```dart
return asyncValue.when(
  // 1) 로딩 상태
  loading: () {
    return CircularProgressIndicator();
  },

  // 2) 에러 상태
  error: (error, stackTrace) {
    return ErrorWidget(error: error);
  },

  // 3) 데이터 상태
  data: (voteStateData) {
    return VoteCard(stateData: voteStateData);
  },
);
```

**Immediate Loading 패턴 (깜빡임 방지)**:
```dart
StreamProvider.family((ref, params) async* {
  // ✅ 기본 상태 먼저 yield
  yield VoteStateData(state: VoteState.votingRequest);

  // ✅ 실시간 데이터 스트리밍
  await for (final data in stream) {
    yield data;
  }
});

// 결과: loading → data (즉시 전환, 깜빡임 없음)
```

### keepAlive() 캐싱 전략

```dart
StreamProvider.autoDispose((ref) async* {
  // autoDispose: Provider가 더 이상 사용되지 않으면 자동 폐기

  // ✅ keepAlive(): 명시적으로 상태 유지
  ref.keepAlive();

  // 결과: postId별로 한 번만 생성, 재사용
});
```

**캐싱 시나리오**:
```dart
// 시나리오 1: 동일 postId의 여러 위젯
VoteCardWidget(postId: 'post1');  // Provider 생성
VoteCardWidget(postId: 'post1');  // ✅ 기존 Provider 재사용 (캐싱)
VoteCardWidget(postId: 'post2');  // 새 Provider 생성

// 시나리오 2: 화면 이동 후 복귀
Navigator.push(DetailPage(postId: 'post1'));  // Provider 생성
Navigator.pop();                              // ✅ Provider 유지 (keepAlive)
Navigator.push(DetailPage(postId: 'post1'));  // ✅ 기존 Provider 재사용
```

### Coordinator BehaviorSubject 대체

**이전 (BehaviorSubject 패턴)**:
```dart
class VoteStateCoordinator {
  final _stateController = BehaviorSubject<VoteStateData>();

  Stream<VoteStateData> watchVoteState(String postId) {
    // 마지막 값 캐싱
    return _stateController.stream;
  }

  void dispose() {
    _stateController.close();
  }
}
```

**현재 (StreamProvider.family + keepAlive)**:
```dart
/// BehaviorSubject 역할을 Riverpod이 대신 수행
final voteStateStreamProvider = StreamProvider.family
    .autoDispose<VoteStateData, VoteStateParams>((ref, params) async* {

  // keepAlive(): BehaviorSubject의 캐싱 역할
  ref.keepAlive();

  // Immediate Loading: BehaviorSubject의 초기값 역할
  yield VoteStateData(state: VoteState.votingRequest);

  // Stream 전달
  await for (final data in stream) {
    yield data;
  }
});
```

**개선 사항**:
1. **자동 메모리 관리**: dispose() 불필요
2. **Family 패턴**: postId별 독립 스트림
3. **keepAlive()**: 선택적 캐싱
4. **AsyncValue**: 로딩/에러 상태 자동 처리

---

## 컴포넌트 아키텍처 원칙

### Single Responsibility Principle (SRP)

**각 컴포넌트는 하나의 역할만 수행**:

```dart
/// ✅ 좋은 예: 역할 분리
class VoteCardWidget extends ConsumerWidget {
  // 역할: 4개 컴포넌트 조합 + 상태 관리
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column([
      VoteCardProfileHeader(),  // 역할: 프로필 정보
      VoteCardHeader(),          // 역할: 상태 배지 + 타이머
      VoteCardBody(),            // 역할: 제목 + 옵션/결과
      VoteCardFooter(),          // 역할: 액션 버튼
    ]);
  }
}

/// ❌ 나쁜 예: 모든 역할이 하나의 위젯에
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column([
      // 프로필 헤더
      Row([CircleAvatar(), Text(), Container()]),

      // 상태 배지
      Container([Icon(), Text()]),

      // 투표 옵션
      Row([
        _buildOptionBox(A),
        _buildOptionBox(B),
      ]),

      // 액션 버튼
      ElevatedButton(),
    ]);
  }
}
```

### Props Pattern (Config + State 분리)

```dart
/// ✅ 좋은 예: Config와 State 분리
class VotingBoxConfig {
  final String boxType;
  final Size boxSize;
  final String title;
  final String? imageUrl;
  final List<String>? imageUrls;
  // ... 불변 설정
}

class VotingBoxState {
  final bool isSelected;
  final bool showResult;
  final double? votePercentage;
  final int? voteCount;
  final VoidCallback? onTap;
  // ... 가변 상태
}

class VotingBox extends StatelessWidget {
  final VotingBoxConfig config;
  final VotingBoxState state;

  const VotingBox({
    required this.config,
    required this.state,
  });
}
```

### Component Composition (조합)

```dart
/// ✅ 좋은 예: 작은 컴포넌트 조합
class VoteCardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row([
      VoteStatusBadge(state: state, hasUserVoted: hasUserVoted),
      Spacer(),
      VoteTimerWidget(remainingTime: remainingTime),
    ]);
  }
}

/// ❌ 나쁜 예: 하나의 거대한 위젯
class VoteCardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row([
      // 상태 배지 (100줄)
      Container([
        Icon(),
        Text(),
        // ... 많은 로직
      ]),

      // 타이머 (80줄)
      Container([
        Icon(),
        Text(),
        // ... 많은 로직
      ]),
    ]);
  }
}
```

### Stateless vs Stateful 선택 기준

**Stateless Widget 사용 시**:
```dart
/// ✅ 상태가 외부에서 관리되는 경우
class VoteStatusBadge extends StatelessWidget {
  final VoteState state;
  final bool hasUserVoted;

  // 상태 변경 = 부모가 rebuild → 자동 업데이트
}
```

**Stateful Widget 사용 시**:
```dart
/// ✅ 내부 애니메이션/타이머가 필요한 경우
class VotingDialog extends StatefulWidget {
  @override
  State<VotingDialog> createState() => _VotingDialogState();
}

class _VotingDialogState extends State<VotingDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(...);
    _slideController = AnimationController(...);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
```

**ConsumerWidget 사용 시**:
```dart
/// ✅ Riverpod Provider 구독이 필요한 경우
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider 구독
    final voteStateAsync = ref.watch(voteStateStreamProvider(params));

    return voteStateAsync.when(...);
  }
}
```

### Helper 클래스 패턴

```dart
/// ✅ 좋은 예: 정적 헬퍼 메서드
class VoteCardHelpers {
  /// 검색어 하이라이팅
  static Widget highlightText({
    required String text,
    required String searchQuery,
    required TextStyle baseStyle,
  }) {
    // 구현...
  }

  /// String → VoteState 변환
  static VoteState mapStatusToState(String status) {
    switch (status) {
      case 'votingRequest': return VoteState.votingRequest;
      case 'inProgress': return VoteState.inProgress;
      default: return VoteState.notParticipated;
    }
  }

  /// 상태별 색상 반환
  static Color getStateColor(VoteState state) {
    switch (state) {
      case VoteState.votingRequest: return VersusColors.primary;
      case VoteState.inProgress: return Colors.blue;
      default: return VersusColors.textSecondary;
    }
  }
}
```

---

## TODO 및 미완성 기능

### 1. BaseVoteMessage submitVote() 연결

**현재 상태**:
```dart
/// ⚠️ TODO: chat_message_builder.dart에서 연결 필요
class BaseVoteMessage extends StatefulWidget {
  // submitVote() 메서드 존재하지만 미사용 상태

  Future<void> submitVote(String postId, String voteOption) async {
    // VoteSubmissionController 통합 준비 완료
    // chat_message_builder.dart에서 이 메서드 호출 필요
  }
}
```

**해결 방법**:
1. `chat_message_builder.dart` 파일 찾기
2. `VoteCardMessage`의 `onVote` 콜백 찾기
3. `BaseVoteMessage.submitVote()` 호출 추가

```dart
// chat_message_builder.dart (수정 필요)
VoteCardMessage(
  postId: postId,
  onVote: (voteOption) async {
    // ✅ TODO: 여기에 submitVote() 호출 추가
    await baseVoteMessage.submitVote(postId, voteOption);
  },
)
```

### 2. 프로필 네비게이션 미구현

**현재 상태**:
```dart
/// VoteCardProfileHeader
GestureDetector(
  onTap: () {
    // TODO: 프로필 페이지로 이동
    debugPrint('Navigate to profile: $displayName');
  },
  child: CircleAvatar(...),
)
```

**해결 방법**:
1. GoRouter에 프로필 라우트 추가
2. `context.pushNamed('profile', params: {'userId': userId})`

### 3. 에러 복구 전략 미흡

**현재 상태**:
```dart
/// VoteCardWidget
return voteStateAsync.when(
  error: (error, stack) => _buildErrorCard(),  // 단순 에러 메시지만 표시
);
```

**개선 방향**:
```dart
/// ✅ TODO: 재시도 버튼 추가
Widget _buildErrorCard(Object error) {
  return Container(
    child: Column([
      Text('투표 카드를 불러올 수 없습니다'),
      ElevatedButton(
        onPressed: () {
          // 재시도 로직
          ref.refresh(voteStateStreamProvider(params));
        },
        child: Text('다시 시도'),
      ),
    ]),
  );
}
```

### 4. 오프라인 상태 감지

**현재 상태**:
- 네트워크 오류 시 `VotingFailure.networkError` 반환
- 오프라인 상태 사전 감지 없음

**개선 방향**:
```dart
/// ✅ TODO: Connectivity 패키지 통합
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return Connectivity().onConnectivityChanged;
});

// VoteSubmissionController
Future<Either<VotingFailure, PostVoting>> submitVote(...) async {
  // 오프라인 체크
  final connectivity = ref.read(connectivityProvider);
  if (connectivity.value == ConnectivityResult.none) {
    return left(VotingFailure.networkError());
  }

  // 투표 제출...
}
```

### 5. 애니메이션 최적화

**현재 상태**:
- VotingDialog: `TickerProviderStateMixin` 사용
- 모든 애니메이션이 동기 실행

**개선 방향**:
```dart
/// ✅ TODO: Staggered Animation 적용
class VotingDialogAnimations {
  static Animation<double> createStaggeredFade(
    AnimationController controller,
    double begin,
    double end,
  ) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(begin, end, curve: Curves.easeOut),
      ),
    );
  }
}

// 사용
final fadeInTitle = createStaggeredFade(controller, 0.0, 0.3);
final fadeInBoxes = createStaggeredFade(controller, 0.3, 0.6);
final fadeInButtons = createStaggeredFade(controller, 0.6, 1.0);
```

---

## 베스트 프랙티스

### 1. StreamProvider.family 사용법

```dart
/// ✅ DO: keepAlive() + Immediate Loading
final voteStateStreamProvider = StreamProvider.family
    .autoDispose<VoteStateData, VoteStateParams>((ref, params) async* {

  ref.keepAlive();  // 캐싱

  yield VoteStateData(state: VoteState.votingRequest);  // 즉시 반환

  final stream = useCase.call(...);
  await for (final data in stream) {
    yield data;
  }
});

/// ❌ DON'T: autoDispose + 스트림 대기
final voteStateStreamProvider = StreamProvider.family
    .autoDispose<VoteStateData, VoteStateParams>((ref, params) async* {
  // keepAlive() 없음 → 재사용 불가
  // yield 없음 → 깜빡임 발생

  final stream = useCase.call(...);
  await for (final data in stream) {
    yield data;  // 첫 데이터까지 로딩 상태 유지
  }
});
```

### 2. AsyncValue.when() 패턴

```dart
/// ✅ DO: 3가지 상태 모두 처리
return asyncValue.when(
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
  data: (data) => VoteCard(data),
);

/// ❌ DON'T: maybeWhen + orElse()
return asyncValue.maybeWhen(
  data: (data) => VoteCard(data),
  orElse: () => SizedBox.shrink(),  // 에러 상태 무시!
);
```

### 3. Either 패턴 처리

```dart
/// ✅ DO: fold()로 양쪽 처리
result.fold(
  (failure) {
    // Left: 실패 처리
    _showErrorSnackBar(failure);
  },
  (success) {
    // Right: 성공 처리
    Navigator.pop(context);
  },
);

/// ❌ DON'T: getOrElse()로 에러 무시
final data = result.getOrElse(() => null);  // 실패 정보 손실!
if (data != null) {
  // ...
}
```

### 4. GetIt DI 사용법

```dart
/// ✅ DO: Provider에서 GetIt 사용
final voteSubmissionControllerProvider = Provider((ref) {
  final useCase = GetIt.instance<SubmitVoteUseCase>();
  return VoteSubmissionController(ref, useCase);
});

/// ❌ DON'T: Widget에서 직접 GetIt 사용
class VoteCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ Widget에서 직접 호출 금지
    final useCase = GetIt.instance<SubmitVoteUseCase>();

    // ✅ Provider를 통해 호출
    final controller = ref.read(voteSubmissionControllerProvider);
  }
}
```

### 5. 컴포넌트 분해 기준

```dart
/// ✅ DO: 100줄 이상이면 분리
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column([
      VoteCardProfileHeader(),  // 183 lines → 별도 파일
      VoteCardHeader(),          // 57 lines → 별도 파일
      VoteCardBody(),            // 129 lines → 별도 파일
      VoteCardFooter(),          // 76 lines → 별도 파일
    ]);
  }
}

/// ❌ DON'T: 500줄 거대 위젯
class VoteCardWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column([
      // 프로필 헤더 (100줄)
      Row([...]),

      // 상태 헤더 (50줄)
      Row([...]),

      // 본문 (200줄)
      Column([...]),

      // 푸터 (50줄)
      ElevatedButton([...]),
    ]);
  }
}
```

### 6. 이미지 캐싱 최적화

```dart
/// ✅ DO: memCacheWidth 동적 계산
final memCacheWidth = (boxWidth * MediaQuery.of(context).devicePixelRatio).toInt();

CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: memCacheWidth,  // 화면 밀도 고려
  placeholder: (context, url) => Container(color: Colors.grey),
  errorWidget: (context, url, error) => Icon(Icons.error),
);

/// ❌ DON'T: 고정 크기 캐싱
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 800,  // 모든 화면에서 동일 → 메모리 낭비 or 품질 저하
);
```

### 7. 애니메이션 dispose

```dart
/// ✅ DO: dispose()에서 정리
class _VotingDialogState extends State<VotingDialog>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, ...);
  }

  @override
  void dispose() {
    _fadeController.dispose();  // 필수!
    super.dispose();
  }
}

/// ❌ DON'T: dispose() 누락
class _VotingDialogState extends State<VotingDialog> {
  late AnimationController _fadeController;

  @override
  void dispose() {
    // _fadeController.dispose() 누락 → 메모리 누수!
    super.dispose();
  }
}
```

---

## 트러블슈팅 가이드

### 문제 1: 투표 카드가 로딩 상태에서 멈춤

**증상**:
```dart
return voteStateAsync.when(
  loading: () => CircularProgressIndicator(),  // 계속 표시됨
  error: (error, stack) => ErrorWidget(error),
  data: (data) => VoteCard(data),
);
```

**원인**:
- StreamProvider에서 `yield` 없이 스트림 대기
- UseCase가 첫 데이터를 emit하지 않음

**해결 방법**:
```dart
/// ✅ Immediate Loading 패턴 적용
StreamProvider.family((ref, params) async* {
  // 1) 기본 상태 즉시 yield
  yield VoteStateData(state: VoteState.votingRequest);

  // 2) 실시간 스트림
  await for (final data in stream) {
    yield data;
  }
});
```

### 문제 2: VotingFailure가 사용자 메시지로 변환되지 않음

**증상**:
```dart
// 에러 메시지가 "VotingFailure.duplicateVote()" 그대로 표시됨
_showErrorSnackBar(failure);
```

**원인**:
- `VotingFailure.when()` 패턴 미사용
- `.toString()` 직접 호출

**해결 방법**:
```dart
/// ✅ when() 패턴으로 매핑
String _mapFailureToMessage(VotingFailure failure) {
  return failure.when(
    duplicateVote: () => '이미 투표하셨습니다',
    voteExpired: () => '투표가 종료되었습니다',
    networkError: () => '네트워크 오류가 발생했습니다',
    // ... (18가지 모두 매핑)
  );
}

// 사용
final message = _mapFailureToMessage(failure);
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(message)),
);
```

### 문제 3: 이미지가 표시되지 않음

**증상**:
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  // 이미지 로딩 실패
);
```

**원인 1: Firebase Storage 권한**
```
FirebaseStorage: Permission denied
```

**해결**:
```javascript
// storage.rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if request.auth != null;  // 인증 필요
    }
  }
}
```

**원인 2: memCacheWidth 과도하게 큼**
```dart
// ❌ 메모리 부족
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: 4000,  // 너무 큼!
);
```

**해결**:
```dart
/// ✅ 화면 크기 기반 계산
final memCacheWidth = (boxWidth * MediaQuery.of(context).devicePixelRatio).toInt();
CachedNetworkImage(
  imageUrl: imageUrl,
  memCacheWidth: memCacheWidth,
);
```

### 문제 4: StreamProvider가 중복 생성됨

**증상**:
```dart
// 동일 postId로 여러 Provider 생성됨
VoteCardWidget(postId: 'post1');  // Provider 1
VoteCardWidget(postId: 'post1');  // Provider 2 (중복!)
```

**원인**:
- `keepAlive()` 누락
- `autoDispose`가 즉시 실행됨

**해결 방법**:
```dart
/// ✅ keepAlive() 추가
StreamProvider.family.autoDispose((ref, params) async* {
  ref.keepAlive();  // 캐싱 활성화

  yield defaultState;
  await for (final data in stream) {
    yield data;
  }
});
```

### 문제 5: 투표 제출 후 UI가 업데이트되지 않음

**증상**:
```dart
// 투표 제출 후에도 "투표하기" 버튼 유지
await controller.submitVote(...);
// UI 변경 없음
```

**원인**:
- StreamProvider가 Firestore 변경을 감지하지 못함
- Repository에서 로컬 상태 업데이트 누락

**해결 방법**:
```dart
/// ✅ Repository에서 로컬 상태 업데이트
Future<Either<VotingFailure, PostVoting>> castVote(...) async {
  // 1) Firestore에 투표 저장
  await _firestore.collection('votes').add(...);

  // 2) ⚠️ 중요: votes 서브컬렉션 생성 (WatchVoteStateUseCase가 감지)
  await _firestore
    .collection('posts')
    .doc(postId)
    .collection('votes')
    .doc(userId)
    .set({
      'userId': userId,
      'choice': voteOption,
      'timestamp': FieldValue.serverTimestamp(),
    });

  return right(PostVoting(...));
}
```

### 문제 6: 다이얼로그가 중복으로 표시됨

**증상**:
```dart
// 두 개의 투표 다이얼로그가 동시에 표시됨
showDialog(context: context, builder: (_) => VotingDialog(...));
showDialog(context: context, builder: (_) => VotingDialog(...));
```

**원인**:
- `VoteUIManager._isDialogShowing` 플래그 미사용
- 빠른 연속 탭으로 중복 호출

**해결 방법**:
```dart
/// ✅ VoteUIManager 사용
final voteUIManager = VoteUIManager();

Future<void> _showVotingDialog() async {
  // 중복 방지 체크
  await voteUIManager.showVotingDialog(
    context: context,
    postId: postId,
    // ...
  );
}
```

### 문제 7: dispose 후 setState() 호출 에러

**증상**:
```
setState() called after dispose()
```

**원인**:
- 비동기 작업 완료 후 `mounted` 체크 없이 setState() 호출

**해결 방법**:
```dart
/// ✅ mounted 체크
Future<void> _handleVoteSubmission() async {
  setState(() => _isVoting = true);

  final result = await controller.submitVote(...);

  // ✅ mounted 체크
  if (!mounted) return;

  setState(() => _isVoting = false);
}
```

---

## 변경 이력

### v4.0.0 (2025-01-20)
- ✨ Clean Architecture v4.0 마이그레이션 완료
- ✨ Riverpod 2.x 전면 도입
- ✨ StreamProvider.family + keepAlive() 패턴 적용
- ✨ VoteStateCoordinator BehaviorSubject 제거
- ✨ Component-Driven Architecture 전환 (4-component 분해)
- 🔧 39개 파일, ~4,500 라인 문서화

### v3.0.0 (2025-01-15)
- ✨ 멀티이미지 지원 (imageUrlsA/imageUrlsB)
- ✨ VotingImageViewer 듀얼 모드 구현
- ✨ UnifiedImageCacheService 통합
- 🔧 VotingBox 리팩토링 (Props Pattern)

### v2.0.0 (2025-01-10)
- ✨ VotingDialog 듀얼 모드 지원
- ✨ VotingDialogConstraints 동적 스케일링
- ✨ VoteUIManager 싱글톤 패턴
- 🔧 BaseVoteMessage 구조 준비 (미완성)

### v1.0.0 (2025-01-05)
- 🎉 초기 Presentation Layer 구축
- ✨ VoteCardWidget + 4-component 구조
- ✨ VotingDialog + VotingBox
- ✨ Riverpod Providers (vote_providers, vote_state_providers)

---

## 유지보수 가이드

### 새로운 VoteState 추가하기

1. **Domain Layer에서 enum 추가**:
```dart
// domain/entities/chat/vote_state.dart
enum VoteState {
  votingRequest,
  inProgress,
  completed,
  expired,
  notParticipated,
  cancelled,  // ✅ 새로운 상태
}
```

2. **VoteStatusBadge 업데이트**:
```dart
// presentation/chat_vote_card/vote_card/vote_status_badge.dart
case VoteState.cancelled:
  statusInfo['text'] = '취소됨';
  statusInfo['color'] = VersusColors.error;
  statusInfo['icon'] = Icons.cancel;
  break;
```

3. **VoteCardHelpers 업데이트**:
```dart
// presentation/chat_vote_card/vote_card/utils/vote_card_helpers.dart
static VoteState mapStatusToState(String status) {
  switch (status) {
    // ...
    case 'cancelled': return VoteState.cancelled;
    default: return VoteState.notParticipated;
  }
}
```

### 새로운 VotingFailure 추가하기

1. **Domain Layer에서 Freezed 클래스 추가**:
```dart
// domain/failures/voting_failure.dart
@freezed
class VotingFailure with _$VotingFailure {
  // ...
  const factory VotingFailure.invalidImage() = _InvalidImage;  // ✅ 새로운 실패 타입
}
```

2. **VoteSubmissionController 매핑 업데이트**:
```dart
// presentation/providers/vote_providers.dart
String _mapFailureToMessage(VotingFailure failure) {
  return failure.when(
    // ...
    invalidImage: () => '유효하지 않은 이미지입니다',
  );
}
```

### 새로운 컴포넌트 추가하기

1. **컴포넌트 파일 생성**:
```dart
// presentation/chat_vote_card/vote_card/components/vote_card_new_component.dart
import 'package:flutter/material.dart';

class VoteCardNewComponent extends StatelessWidget {
  const VoteCardNewComponent({
    super.key,
    // 필요한 props
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 구현...
    );
  }
}
```

2. **메인 위젯에 통합**:
```dart
// presentation/chat_vote_card/vote_card/vote_card_widget.dart
@override
Widget build(BuildContext context) {
  return Column([
    VoteCardProfileHeader(),
    VoteCardHeader(),
    VoteCardBody(),
    VoteCardNewComponent(),  // ✅ 새 컴포넌트 추가
    VoteCardFooter(),
  ]);
}
```

---

**마지막 업데이트**: 2025-01-20
**작성자**: AI Assistant
**리뷰어**: Development Team
