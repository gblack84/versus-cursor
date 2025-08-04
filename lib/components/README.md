# UI Components

재사용 가능한 UI 컴포넌트를 모아놓은 디렉토리입니다.

## 📋 디렉토리 구조

```
components/
├── chat/                    # 채팅 관련 컴포넌트
│   ├── chat_bubble.dart     # 채팅 말풍선
│   ├── chat_input.dart      # 채팅 입력창
│   └── vote_request_message.dart  # 투표 요청 메시지
├── navigation/              # 네비게이션 컴포넌트
│   ├── main_navigation_shell.dart  # 메인 네비게이션 셸
│   └── vs_bottom_navigation_bar.dart  # 하단 네비게이션 바
├── notifications/           # 알림 관련 컴포넌트
│   ├── widgets/            # 알림 위젯
│   ├── models/             # 데이터 모델
│   └── services/           # 서비스 로직
├── unified_video_player.dart  # 통합 비디오 플레이어
├── youtube_player_widget.dart # YouTube 플레이어
└── alertempty_widget.dart    # 빈 상태 알림 위젯
```

## 주요 컴포넌트

### 1. 채팅 컴포넌트 (/chat)

#### ChatBubble
```dart
// 채팅 말풍선 컴포넌트
ChatBubble(
  message: message,
  isCurrentUser: isCurrentUser,
  showAvatar: true,
)
```

#### VoteRequestMessage
```dart
// A vs B 투표 요청 메시지
VoteRequestMessage(
  message: voteMessage,
  onVote: (choice) => handleVote(choice),
  currentUserId: currentUser.uid,
)
```

**특징:**
- 멀티이미지 지원 (PageView)
- 10분 타이머 표시
- 투표 상태 실시간 업데이트
- 애니메이션 효과

### 2. 네비게이션 컴포넌트 (/navigation)

#### MainNavigationShell
```dart
// 메인 네비게이션 셸
MainNavigationShell(
  child: child,
  currentIndex: navigationIndex,
)
```

**듀얼 모드 네비게이션:**
- **메인 모드**: 홈 / 검색 / 작성 / 채팅 / 프로필 (5개)
- **채팅 모드**: 채팅 / 친구 / 검색 / 홈 (4개)
- 300ms 부드러운 전환 애니메이션

#### VsBottomNavigationBar
```dart
// 커스텀 하단 네비게이션 바
VsBottomNavigationBar(
  currentIndex: currentIndex,
  onTap: (index) => handleNavigation(index),
  mode: NavigationMode.main,
)
```

### 3. 알림 컴포넌트 (/notifications)

#### NotificationOverlay
```dart
// 전체화면 알림 오버레이
NotificationOverlay.showVoting(
  context: context,
  notification: notificationData,
  onVote: (choice) => handleVoteChoice(choice),
)
```

**주요 기능:**
- 검은색 반투명 배경 (barrierColor: Colors.black54)
- 92% 화면 너비 사용
- 멀티이미지 지원
- 박스 크기 평균화
- 3가지 액션: 투표하기, 나중에, 닫기

#### VotingNotificationDialog
```dart
// 투표 알림 다이얼로그
VotingNotificationDialog(
  notification: notification,
  onVote: onVoteCallback,
  onLater: onLaterCallback,
  onClose: onCloseCallback,
)
```

### 4. 미디어 플레이어

#### UnifiedVideoPlayer
```dart
// 통합 비디오 플레이어
UnifiedVideoPlayer(
  videoUrl: videoUrl,
  aspectRatio: 16/9,
  autoPlay: false,
)
```

**지원 형식:**
- 로컬 비디오 파일
- Firebase Storage URL
- 네트워크 비디오 URL

#### YouTubePlayerWidget
```dart
// YouTube 플레이어
YouTubePlayerWidget(
  videoId: extractVideoId(youtubeUrl),
  autoPlay: false,
  showControls: true,
)
```

### 5. 상태 표시 위젯

#### AlertEmptyWidget
```dart
// 빈 상태 알림
AlertEmptyWidget(
  message: '게시물이 없습니다',
  icon: Icons.inbox_outlined,
  action: TextButton(
    onPressed: () => createPost(),
    child: Text('첫 게시물 작성하기'),
  ),
)
```

## 디자인 시스템 통합

모든 컴포넌트는 Versus 디자인 시스템을 따릅니다:

```dart
import 'package:versus_space/design_system/design_system.dart';

// 색상
VersusColors.primary
VersusColors.secondary
VersusColors.background

// 간격
VersusSpacing.small  // 8px
VersusSpacing.medium // 16px
VersusSpacing.large  // 24px

// 텍스트 스타일
VersusTextStyles.h1
VersusTextStyles.body
VersusTextStyles.caption
```

## 컴포넌트 개발 가이드

### 1. 네이밍 규칙
- 위젯: `[Name]Widget` (예: ChatBubbleWidget)
- 모델: `[Name]Model` (예: NotificationModel)
- 서비스: `[Name]Service` (예: ChatService)

### 2. 구조 패턴
```dart
class ComponentWidget extends StatelessWidget {
  // 1. Props 정의
  final String title;
  final VoidCallback? onTap;
  
  // 2. 생성자
  const ComponentWidget({
    super.key,
    required this.title,
    this.onTap,
  });
  
  // 3. Build 메서드
  @override
  Widget build(BuildContext context) {
    return Container(
      // 디자인 시스템 사용
      padding: EdgeInsets.all(VersusSpacing.medium),
      decoration: BoxDecoration(
        color: VersusColors.surface,
        borderRadius: VersusRadius.medium,
      ),
      child: Text(
        title,
        style: VersusTextStyles.body,
      ),
    );
  }
}
```

### 3. 상태 관리
- 단순 상태: StatefulWidget
- 복잡한 상태: Provider 패턴
- 전역 상태: AppState 사용

### 4. 성능 최적화
- const 생성자 사용
- 불필요한 리빌드 방지
- 이미지 캐싱 활용
- 애니메이션 최적화

## 테스트

```dart
// widget_test.dart
testWidgets('ChatBubble renders correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ChatBubble(
        message: testMessage,
        isCurrentUser: true,
      ),
    ),
  );
  
  expect(find.text(testMessage.content), findsOneWidget);
});
```

## 접근성

모든 컴포넌트는 접근성 기준을 준수합니다:
- Semantics 위젯 사용
- 적절한 contrast ratio
- 키보드 네비게이션 지원
- 스크린 리더 호환

## 향후 계획

1. **컴포넌트 라이브러리화**
   - Storybook 스타일 문서화
   - 컴포넌트 갤러리 페이지
   - 사용 예제 코드 자동 생성

2. **성능 개선**
   - 레이지 로딩 강화
   - 메모리 사용량 최적화
   - 애니메이션 성능 개선

3. **기능 확장**
   - 다크 모드 지원
   - 다국어 지원 강화
   - 커스터마이징 옵션 추가