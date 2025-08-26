# 📦 /lib/features/chat/presentation/screens

> Feature-First Architecture - Chat Screens (Pages)
> 최종 업데이트: 2025-08-25

## 📋 개요

채팅 기능의 **Screen/Page Layer**를 담당하는 디렉토리입니다. 전체 화면을 구성하는 페이지 위젯들을 포함합니다.

### ⚠️ 의존성
- **Common Feature**: 공통 위젯 및 유틸리티
- **App Feature**: 테마 시스템 및 라우팅
- **Auth Feature**: 사용자 인증 정보
- **Profile Feature**: 채팅 참여자 프로필

### 🎯 목적
- **화면 구성**: 완전한 페이지 레벨 위젯
- **네비게이션 진입점**: 라우팅의 목적지
- **상태 관리 연결**: Provider/Bloc과 UI 연결
- **레이아웃 구조**: Scaffold 및 기본 레이아웃

## 🏗️ 디렉토리 구조

```
screens/
├── chat_list/                         # 채팅 목록 화면
│   ├── chat_list_screen.dart         # 메인 채팅 목록
│   ├── chat_list_app_bar.dart        # 앱바 컴포넌트
│   ├── chat_list_body.dart           # 바디 컴포넌트
│   └── chat_list_fab.dart            # FAB 컴포넌트
│
├── chat_detail/                       # 채팅 상세 화면
│   ├── chat_detail_screen.dart       # 메인 채팅방
│   ├── chat_detail_app_bar.dart      # 채팅방 앱바
│   ├── chat_detail_messages.dart     # 메시지 목록
│   └── chat_detail_input.dart        # 입력창
│
├── ai_chat/                           # AI 채팅 화면
│   ├── ai_chat_screen.dart           # AI 채팅 메인
│   ├── ai_vote_screen.dart           # AI 투표 도우미
│   └── ai_helper_screen.dart         # AI 일반 도우미
│
├── group_chat/                        # 그룹 채팅 화면
│   ├── create_group_screen.dart      # 그룹 생성
│   ├── group_info_screen.dart        # 그룹 정보
│   └── group_settings_screen.dart    # 그룹 설정
│
├── media/                             # 미디어 관련 화면
│   ├── image_viewer_screen.dart      # 이미지 뷰어
│   ├── video_player_screen.dart      # 비디오 플레이어
│   └── media_gallery_screen.dart     # 미디어 갤러리
│
└── settings/                          # 채팅 설정 화면
    ├── chat_settings_screen.dart     # 채팅 설정
    └── notification_settings_screen.dart # 알림 설정
```

## 📂 주요 화면 구현

### 1. ChatListScreen (채팅 목록)

**책임**: 채팅 목록 화면 구성 및 관리

**주요 기능**:
- 채팅 목록 표시 (RefreshIndicator 포함)
- 검색 기능 (ChatSearchBar)
- 탭 필터링 (전체/개인/그룹)
- 채팅 옵션 (고정/음소거/삭제/보관)
- FAB로 새 채팅 시작

**상태 관리**:
- TabController: 탭 네비게이션
- SearchController: 검색 입력
- isSearching: 검색 모드 상태

**네비게이션**:
- `/chats` - 채팅 목록
- `/chats/:id` - 채팅 상세
- `/chats/new` - 새 채팅
- `/chats/archived` - 보관된 채팅
- `/settings/chat` - 채팅 설정

**의존성**: ChatListProvider, AppScaffold, ChatListItem, EmptyChatList

### 2. ChatDetailScreen (채팅방)

**책임**: 채팅방 화면 구성 및 메시지 관리

**주요 기능**:
- 메시지 목록 표시 (ListView.builder, reverse: true)
- 메시지 입력창 (ChatInputBar)
- 첨부 파일 옵션 (카메라/갤러리/파일/위치/투표카드)
- 메시지 옵션 (답장/수정/삭제/복사/전달)
- 투표 카드 지원
- 무한 스크롤 (Pagination)

**상태 관리**:
- ChatDetailProvider: 채팅 상태
- InputController: 입력 필드
- ScrollController: 스크롤 감지

**네비게이션**:
- `/chats/:id/info` - 채팅 정보
- `/chats/:id/vote-card` - 투표 카드 생성

**컴포넌트**:
- ChatAppBar: 상단 앱바
- MessageBubble: 일반 메시지
- VoteCardMessage: 투표 카드
- AttachmentOptionsSheet: 첨부 옵션

**의존성**: ChatDetailProvider, flutter_chat_ui

### 3. AIChatScreen (AI 채팅)

**책임**: AI 채팅 화면 구성 및 AI 상호작용

**AI 채팅 타입**:
- `helper`: 일반 도우미
- `vote`: 투표 도우미
- `creative`: 창작 도우미

**주요 기능**:
- AI 대화 인터페이스
- 제안 칩 (AISuggestionChips)
- AI 생각중 표시 (AIThinkingIndicator)
- 하단 검색바 (bottomNavigationBar)
- 음성 입력 지원
- 액션 버튼 (ActionChip)

**상태 관리**:
- AIChatProvider: AI 채팅 상태
- SearchController: 검색 입력

**네비게이션**:
- `/ai-chat` - AI 채팅 메인
- `/ai-chat/settings` - AI 채팅 설정

**컴포넌트**:
- AISuggestionChips: 제안 키워드
- AIThinkingIndicator: 로딩 표시
- AIMessage: 메시지 타입
- AIAction: 액션 버튼

**의존성**: AIChatProvider

## 🧪 테스트 전략

### Screen 테스트

**테스트 카테고리**:
1. **Widget 테스트**:
   - 화면 렌더링 검증
   - 사용자 상호작용 테스트
   - 네비게이션 흐름

2. **Integration 테스트**:
   - Provider와의 통합
   - 실시간 업데이트
   - 에러 처리

3. **UI 테스트**:
   - 로딩 상태
   - 빈 상태
   - 에러 상태
   - 성공 상태

**Mock 객체**:
- MockChatListProvider
- MockChatDetailProvider
- MockAIChatProvider

**테스트 시나리오**:
- 채팅 목록 표시
- 검색 기능
- 메시지 전송
- 투표 처리
- AI 상호작용

## ⚠️ 주의사항

### 1. 화면 구성
- Scaffold 기반 레이아웃
- 일관된 AppBar 스타일
- 적절한 로딩/에러 처리

### 2. 상태 관리
- Provider/Bloc 패턴 준수
- 화면별 독립적 상태 관리
- 메모리 누수 방지

### 3. 네비게이션
- GoRouter 사용
- 딥링크 지원
- 백 네비게이션 처리

## ✅ 체크리스트

### 구현 완료
- [ ] ChatListScreen
- [ ] ChatDetailScreen
- [ ] AIChatScreen
- [ ] CreateGroupScreen
- [ ] GroupInfoScreen
- [ ] ImageViewerScreen

### 테스트
- [ ] Widget 테스트
- [ ] Integration 테스트
- [ ] Navigation 테스트

## 📚 참고 자료

- [Flutter Navigation](https://docs.flutter.dev/development/ui/navigation)
- [Provider Package](https://pub.dev/packages/provider)
- [GoRouter](https://pub.dev/packages/go_router)

---

*이 문서는 Feature-First Architecture의 Chat Screen Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*