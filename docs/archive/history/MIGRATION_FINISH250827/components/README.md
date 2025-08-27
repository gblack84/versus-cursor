# 📦 컴포넌트 라이브러리 (Components Library)

> Versus Space 앱의 재사용 가능한 UI 컴포넌트 모음

## 📋 개요

`/lib/components` 디렉토리는 앱 전체에서 재사용되는 UI 컴포넌트들을 모아놓은 중앙 라이브러리입니다. 채팅, 네비게이션, 알림, 미디어 플레이어 등 핵심 UI 요소들이 모듈화되어 있습니다.

### 주요 특징
- 🎨 **디자인 시스템 통합**: VersusColors, VersusSpacing, VersusTextStyles 일관 적용
- 🔄 **재사용성**: 모든 컴포넌트는 독립적이고 재사용 가능
- 📱 **반응형 디자인**: 다양한 화면 크기에 최적화
- ⚡ **성능 최적화**: 메모리 효율적인 위젯 구조
- ♿ **접근성**: 스크린 리더 지원, 키보드 네비게이션
- 🌍 **국제화**: 다국어 지원 (AppLocalizations)

## 🏗️ 아키텍처

```
lib/components/
│
├── 📱 메인 컴포넌트 (8개 파일)
│   ├── unified_video_player.dart     # 통합 비디오 플레이어
│   ├── youtube_player_widget.dart    # YouTube 전용 플레이어
│   ├── videoplay_widget.dart         # 비디오 재생 위젯
│   ├── videoplay_model.dart          # 비디오 재생 상태 모델
│   ├── editviedo_widget.dart         # 비디오 편집 위젯
│   ├── editviedo_model.dart          # 비디오 편집 상태 모델
│   ├── alertempty_widget.dart        # 빈 상태 알림 위젯
│   └── alertempty_model.dart         # 빈 상태 알림 모델
│
└── 📁 하위 모듈 (3개 디렉토리)
    ├── chat/                          # 채팅 컴포넌트 ✅
    │   ├── base_vote_message.dart
    │   ├── vote_card_message.dart
    │   └── vote_card/
    ├── navigation/                    # 네비게이션 컴포넌트 ✅
    │   ├── main_navigation_shell.dart
    │   └── vs_bottom_navigation_bar.dart
    └── notifications/                 # 알림 컴포넌트 ✅
        ├── notification_overlay.dart
        ├── voting_notification_dialog.dart
        └── (하위 4개 디렉토리)
```

## 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `unified_video_player.dart`, `alertempty_widget.dart`
- ✅ **기능별 접미사**: `_widget.dart`, `_model.dart`, `_service.dart`

### 클래스명
- ✅ **PascalCase 사용**: `UnifiedVideoPlayer`, `VideoplayModel`
- ✅ **Widget 접미사**: UI 컴포넌트는 `Widget` 접미사 사용
- ✅ **Model 접미사**: 상태 관리 클래스는 `Model` 접미사 사용

### 필드 및 메서드
- ✅ **camelCase 사용**: `videoUrl`, `autoPlay`, `showControls`
- ✅ **private 필드**: `_controller`, `_model`
- ✅ **boolean 접두사**: `isPlaying`, `hasVideo`, `showControls`

참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 주요 구성요소

### 1. 미디어 플레이어 컴포넌트

#### UnifiedVideoPlayer (통합 비디오 플레이어)

**역할**: URL 타입을 자동 감지하여 적절한 플레이어 선택

```dart
class UnifiedVideoPlayer extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final bool allowFullScreen;
  final bool allowPlaybackSpeedMenu;
  final bool pauseOnNavigate;
}
```

**특징**:
- YouTube URL 자동 감지
- 일반 비디오와 YouTube 비디오 자동 구분
- AppVideoPlayer와 YouTubePlayerWidget 자동 선택
- 일관된 인터페이스 제공

**사용 예시**:
```dart
// YouTube 비디오
UnifiedVideoPlayer(
  url: 'https://youtube.com/watch?v=...',
  aspectRatio: 16/9,
  autoPlay: false,
)

// 일반 비디오
UnifiedVideoPlayer(
  url: 'https://example.com/video.mp4',
  showControls: true,
  looping: true,
)
```

#### YouTubePlayerWidget (YouTube 플레이어)

**역할**: YouTube 비디오 전용 플레이어

```dart
class YouTubePlayerWidget extends StatefulWidget {
  final String url;
  final double aspectRatio;
  final bool autoPlay;
  final bool mute;
  final bool loop;
  final bool showControls;
  final bool fullScreenByDefault;
}
```

**특징**:
- 다양한 YouTube URL 형식 지원
  - 표준 URL: `youtube.com/watch?v=...`
  - 단축 URL: `youtu.be/...`
  - 임베드 URL: `youtube.com/embed/...`
- YoutubePlayerController 사용
- 자동 비디오 ID 추출
- 전체화면 모드 지원

#### VideoplayWidget (비디오 재생 위젯)

**역할**: AppState의 비디오 URL을 재생하는 위젯

```dart
class VideoplayWidget extends StatefulWidget {
  final String? videoUrl;
}
```

**특징**:
- AppState.uploadVideoA 자동 연동
- Provider 패턴으로 상태 관리
- 자동 반복 재생 (looping: true)
- 전체화면 지원

### 2. 알림 컴포넌트

#### AlertemptyWidget (빈 상태 알림)

**역할**: 콘텐츠가 없을 때 표시하는 알림 위젯

```dart
class AlertemptyWidget extends StatefulWidget {
  // VS 마크 로고 표시
  // "No Text Entered" 메시지
  // 설명 텍스트
  // 재시도 및 확인 버튼
}
```

**특징**:
- VS 마크 로고 포함
- 다국어 지원 (AppLocalizations)
- 재시도 버튼 (rotateRight 아이콘)
- 확인 버튼
- 둥근 모서리 디자인 (30px radius)

### 3. 하위 모듈 통합

#### 채팅 컴포넌트 (/chat)
- **VoteCardMessage**: A/B 투표 카드 메시지
- **BaseVoteMessage**: 투표 메시지 기반 클래스
- 실시간 Firebase 동기화
- 10분 타이머 시스템
- 멀티이미지 지원

#### 네비게이션 컴포넌트 (/navigation)
- **MainNavigationShell**: 메인 네비게이션 셸
- **VsBottomNavigationBar**: 하단 네비게이션 바
- 듀얼 모드 지원 (메인/채팅)
- 300ms 부드러운 전환

#### 알림 컴포넌트 (/notifications)
- **NotificationOverlay**: 통합 알림 시스템
- **VotingNotificationDialog**: 투표 알림 다이얼로그
- 92% 화면 너비 사용
- 스마트 레이아웃 시스템

## 💻 사용 예시

### 1. 비디오 플레이어 사용

```dart
// 통합 플레이어 (자동 타입 감지)
UnifiedVideoPlayer(
  url: videoUrl,  // YouTube 또는 일반 비디오
  width: MediaQuery.of(context).size.width,
  aspectRatio: 16/9,
  autoPlay: false,
  showControls: true,
)

// YouTube 전용
YouTubePlayerWidget(
  url: 'https://youtube.com/watch?v=dQw4w9WgXcQ',
  autoPlay: true,
  loop: false,
  fullScreenByDefault: false,
)

// 비디오 재생 위젯
VideoplayWidget(
  videoUrl: uploadedVideoUrl,
)
```

### 2. 빈 상태 알림 사용

```dart
// 콘텐츠가 없을 때
if (posts.isEmpty) {
  return AlertemptyWidget();
}

// 모달로 표시
showModalBottomSheet(
  context: context,
  builder: (context) => AlertemptyWidget(),
);
```

### 3. 컴포넌트 조합

```dart
// 비디오가 있는 게시물
Column(
  children: [
    // 비디오 플레이어
    UnifiedVideoPlayer(url: post.videoUrl),
    
    // 투표 카드
    VoteCardMessage(
      postId: post.id,
      optionA: post.optionA,
      optionB: post.optionB,
    ),
    
    // 비어있을 때
    if (hasNoContent)
      AlertemptyWidget(),
  ],
)
```

## 🎨 디자인 시스템 통합

모든 컴포넌트는 통일된 디자인 시스템을 사용합니다:

```dart
// 색상 시스템
AppTheme.of(context).primary
AppTheme.of(context).secondaryBackground
AppTheme.of(context).primaryText
AppTheme.of(context).info

// 텍스트 스타일
AppTheme.of(context).bodyMedium
AppTheme.of(context).titleSmall

// 간격 및 패딩
EdgeInsets.all(8.0)
EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 20.0, 0.0)

// 둥근 모서리
BorderRadius.circular(30.0)  // AlertEmpty
BorderRadius.circular(8.0)   // 버튼
```

## 🔧 상태 관리

### Model 패턴

```dart
// Model 정의
class VideoplayModel extends AppModel<VideoplayWidget> {
  @override
  void initState(BuildContext context) {}
  
  @override
  void dispose() {}
}

// Widget에서 사용
late VideoplayModel _model;

@override
void initState() {
  super.initState();
  _model = createModel(context, () => VideoplayModel());
}
```

### Provider 패턴

```dart
// AppState 감시
context.watch<AppState>();

// AppState 접근
AppState().uploadVideoA
AppState().uploadTextEditing
```

## 📊 성능 최적화

### 1. 비디오 플레이어
- 자동 일시정지 (deactivate)
- Controller 적절한 해제 (dispose)
- 메모리 효율적인 스트리밍

### 2. 이미지 캐싱
- CachedNetworkImage 사용
- 메모리 캐시 크기 제한
- Progressive loading

### 3. 위젯 최적화
- const 생성자 활용
- 불필요한 리빌드 방지
- StatelessWidget 우선 사용

## 🧪 테스팅

### 단위 테스트
```dart
testWidgets('UnifiedVideoPlayer YouTube 감지 테스트', (tester) async {
  const youtubeUrl = 'https://youtube.com/watch?v=test';
  
  await tester.pumpWidget(
    MaterialApp(
      home: UnifiedVideoPlayer(url: youtubeUrl),
    ),
  );
  
  expect(find.byType(YouTubePlayerWidget), findsOneWidget);
});
```

### 통합 테스트
```dart
testWidgets('빈 상태 알림 표시 테스트', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // 빈 상태 시뮬레이션
  await tester.tap(find.text('Clear All'));
  await tester.pump();
  
  expect(find.byType(AlertemptyWidget), findsOneWidget);
  expect(find.text('No Text Entered'), findsOneWidget);
});
```

## 🐛 트러블슈팅

### 자주 발생하는 문제

#### 1. YouTube URL이 재생되지 않음
```dart
// 원인: 잘못된 URL 형식
// 해결: isYouTubeUrl() 헬퍼 함수 사용
if (isYouTubeUrl(url)) {
  // YouTube 플레이어 사용
} else {
  // 일반 플레이어 사용
}
```

#### 2. 비디오 메모리 누수
```dart
// 원인: Controller 미해제
// 해결: dispose() 메서드에서 정리
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

#### 3. 빈 상태 알림이 표시되지 않음
```dart
// 원인: 조건 체크 누락
// 해결: isEmpty 체크 추가
if (items.isEmpty) {
  return AlertemptyWidget();
}
```

## 📈 성능 지표

### 목표 성능
- **비디오 로딩**: <2초
- **컴포넌트 렌더링**: <16ms (60fps)
- **메모리 사용량**: <50MB 추가
- **YouTube ID 추출**: <10ms

### 모니터링
```dart
// 성능 측정
final stopwatch = Stopwatch()..start();
final videoId = extractYouTubeVideoId(url);
print('추출 시간: ${stopwatch.elapsedMilliseconds}ms');
```

## 변경 이력

### v2.0.0 (2025-08-22)
- 전체 컴포넌트 라이브러리 통합 문서화
- 8개 메인 컴포넌트 문서화
- 3개 하위 모듈 통합

### v1.5.0 (2025-08-20)
- UnifiedVideoPlayer 추가
- YouTube URL 자동 감지 기능

### v1.4.0 (2025-08-15)
- AlertemptyWidget 리팩토링
- 다국어 지원 추가

### v1.3.0 (2025-08-10)
- 하위 모듈 디렉토리 구조 개선
- chat, navigation, notifications 분리

### v1.2.0 (2025-08-05)
- VideoplayWidget 추가
- AppState 연동

### v1.1.0 (2025-08-01)
- YouTubePlayerWidget 구현
- 다양한 URL 형식 지원

### v1.0.0 (2025-07-25)
- 초기 컴포넌트 라이브러리 구축
- 기본 구조 확립

---

**문서 버전**: 2.0.0  
**최종 업데이트**: 2025-08-22  
**관리**: Versus Space 개발팀