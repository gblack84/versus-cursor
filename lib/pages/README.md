# Application Pages

Versus Space 앱의 모든 페이지/화면들을 관리하는 디렉토리입니다.

## 📋 디렉토리 구조

```
pages/
├── chat/                    # 채팅 관련 페이지
│   ├── chat_list/          # 채팅 목록
│   ├── chat_detail/        # 채팅 상세
│   ├── chat_search/        # 채팅 검색
│   └── friends_list/       # 친구 목록
├── home/                    # 홈 페이지
├── profile/                 # 프로필 페이지
├── search/                  # 검색 페이지
├── notifications_list/      # 알림 목록
├── image_viewer/           # 이미지 뷰어
├── pro_image_editor/       # 이미지 편집기
├── thumbnail_selection/    # 썸네일 선택
├── jop/                    # 직업/관심사 선택
├── user_info/              # 사용자 정보
├── user_info_input/        # 사용자 정보 입력
└── debug_log_page.dart     # 디버그 로그 (개발용)
```

## 주요 페이지

### 1. 홈 페이지 (/home)
앱의 메인 피드를 표시하는 페이지입니다.

**주요 기능:**
- 최신 게시물 피드
- 실시간 업데이트
- 무한 스크롤
- 새로고침 지원

**위젯 구조:**
```dart
HomePage
├── AppBar (로고 및 알림 아이콘)
├── RefreshIndicator
│   └── ListView
│       ├── PostCard (A vs B 카드)
│       ├── LoadingIndicator
│       └── EmptyState
└── FloatingActionButton (글쓰기)
```

### 2. 채팅 페이지 (/chat)

#### ChatListPage
모든 채팅 목록을 표시합니다.

```dart
ChatListPage
├── SearchBar
├── TabBar (전체 / AI 채팅 / 그룹)
└── ChatList
    └── ChatListItem
        ├── Avatar
        ├── LastMessage
        └── UnreadCount
```

#### ChatDetailPage
개별 채팅방 화면입니다.

**주요 기능:**
- flutter_chat_ui 통합
- 텍스트/이미지/비디오 메시지
- 투표 요청 메시지
- 실시간 동기화
- 링크 미리보기

**특수 기능:**
```dart
// AI 채팅방 확인
final isAIChat = chatId.contains('ai_assistant');

// 투표 메시지 전송
await ChatService.sendVoteRequest(
  chatId: chatId,
  postId: postId,
  senderId: currentUser.uid,
);
```

### 3. 프로필 페이지 (/profile)
사용자 프로필을 표시하고 편집합니다.

**섹션 구성:**
- 프로필 헤더 (사진, 이름, 포인트)
- 통계 (게시물, 투표, 친구)
- 관심사 태그
- 최근 활동
- 설정 메뉴

```dart
ProfilePage
├── ProfileHeader
│   ├── Avatar
│   ├── DisplayName
│   └── PointsDisplay
├── StatsSection
├── InterestsSection
├── RecentActivity
└── SettingsMenu
```

### 4. 검색 페이지 (/search)
게시물과 사용자를 검색합니다.

**검색 옵션:**
- 게시물 검색
- 사용자 검색
- 태그 검색
- 필터 (카테고리, 날짜, 인기도)

**Algolia 통합:**
```dart
// 검색 쿼리
final results = await AlgoliaService.search(
  query: searchText,
  index: 'posts',
  filters: 'category:${selectedCategory}',
);
```

### 5. 알림 목록 (/notifications_list)
모든 알림을 관리하는 페이지입니다.

**알림 타입:**
- 투표 요청
- 투표 결과
- 친구 요청
- 댓글 알림
- 시스템 알림

```dart
NotificationsListPage
├── NotificationTabs (전체 / 투표 / 소셜)
└── NotificationList
    └── NotificationItem
        ├── Icon
        ├── Message
        ├── Timestamp
        └── ActionButton
```

### 6. 이미지 뷰어 (/image_viewer)
전체화면 이미지 보기 페이지입니다.

**주요 기능:**
- 핀치 줌
- 더블탭 줌
- 스와이프로 이미지 전환
- 다운로드 기능

```dart
ImageViewerPage(
  imageUrls: ['url1', 'url2'],
  initialIndex: 0,
  heroTag: 'image_hero',
)
```

### 7. 이미지 편집기 (/pro_image_editor)
ProImageEditor를 활용한 이미지 편집 페이지입니다.

**편집 기능:**
- 크롭/회전
- 필터 효과
- 텍스트 추가
- 그리기 도구
- 스티커/이모지

**통합 플로우:**
```dart
// 편집 후 저장
final editedImage = await Navigator.push<File>(
  context,
  MaterialPageRoute(
    builder: (_) => ProImageEditorPage(
      imageUrl: originalUrl,
    ),
  ),
);

if (editedImage != null) {
  // Firebase Storage 업로드
  final newUrl = await uploadImage(editedImage);
}
```

### 8. 썸네일 선택 (/thumbnail_selection)
멀티 이미지에서 대표 이미지를 선택하는 페이지입니다.

```dart
ThumbnailSelectionPage
├── MainImageDisplay
└── ThumbnailGrid
    └── ThumbnailItem (선택 가능)
```

### 9. 관심사 선택 (/jop)
회원가입 시 직업, 전문분야, 취미를 선택하는 페이지들입니다.

#### 페이지 구성:
- `agrred_select/`: 직업 카테고리 선택
- `expertise_select/`: 전문 분야 선택 (최대 4개)
- `hobbies_select/`: 취미 선택 (최대 8개)

**선택 플로우:**
```dart
// 1. 직업 선택
final jobCategory = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => AggreedSelectPage()),
);

// 2. 전문 분야 선택
final expertise = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => ExpertiseSelectPage()),
);

// 3. 취미 선택
final hobbies = await Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => HobbiesSelectPage()),
);
```

### 10. 사용자 정보 (/user_info, /user_info_input)
사용자 프로필 정보를 보고 수정하는 페이지들입니다.

**주요 화면:**
- 프로필 편집
- 캐릭터 선택
- 언어 설정
- 계정 설정

## 네비게이션 구조

### GoRouter 설정
```dart
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(
        child: child,
      ),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/chat',
          name: 'chat_list',
          builder: (context, state) => ChatListPage(),
          routes: [
            GoRoute(
              path: ':chatId',
              name: 'chat_detail',
              builder: (context, state) => ChatDetailPage(
                chatId: state.pathParameters['chatId']!,
              ),
            ),
          ],
        ),
        // ... 다른 라우트들
      ],
    ),
  ],
);
```

### 페이지 전환 예제
```dart
// 홈에서 채팅으로
context.goNamed('chat_list');

// 채팅 상세로 (파라미터 포함)
context.goNamed(
  'chat_detail',
  pathParameters: {'chatId': chatId},
);

// 모달로 띄우기
await showModalBottomSheet(
  context: context,
  builder: (_) => ImagePickerModal(),
);
```

## 페이지 개발 가이드

### 1. 기본 구조
```dart
class NewPage extends StatefulWidget {
  const NewPage({super.key});

  @override
  State<NewPage> createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  void initState() {
    super.initState();
    // 초기화 로직
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('페이지 제목'),
      ),
      body: SafeArea(
        child: // 페이지 콘텐츠
      ),
    );
  }
}
```

### 2. 상태 관리
- 단순 상태: StatefulWidget
- 복잡한 상태: Provider/Consumer
- 전역 상태: AppState

### 3. 디자인 시스템 사용
```dart
Container(
  padding: EdgeInsets.all(VersusSpacing.medium),
  decoration: BoxDecoration(
    color: VersusColors.surface,
    borderRadius: VersusRadius.medium,
  ),
  child: Text(
    '텍스트',
    style: VersusTextStyles.body,
  ),
)
```

## 성능 최적화

### 1. 이미지 로딩
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: VersusColors.neutral200,
    highlightColor: VersusColors.neutral100,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

### 2. 리스트 최적화
```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
  // 성능 최적화
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
)
```

### 3. 네비게이션 최적화
- 불필요한 리빌드 방지
- const 생성자 활용
- 메모리 누수 방지 (dispose)

## 향후 추가 예정 페이지

1. **게시물 상세 페이지**
   - 댓글 시스템
   - 공유 기능
   - 신고 기능

2. **설정 페이지**
   - 알림 설정
   - 프라이버시 설정
   - 테마 설정

3. **통계 페이지**
   - 게시물 통계
   - 투표 분석
   - 활동 그래프