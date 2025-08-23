# 💬 Chat Detail v2 Components - 채팅 상세 UI 컴포넌트

> Versus Space 앱의 채팅 상세 페이지를 구성하는 재사용 가능한 UI 컴포넌트 모음

## 📋 개요

이 디렉토리는 채팅 상세 페이지(ChatDetailWidgetV2)에서 사용되는 모든 UI 컴포넌트를 포함합니다. 각 컴포넌트는 단일 책임 원칙을 따르며, 독립적으로 재사용 가능하도록 설계되었습니다. flutter_chat_ui v2.9.0과 완벽하게 통합되어 있으며, 디자인 시스템을 일관되게 적용합니다.

### 🎯 주요 목적
- **모듈화**: 채팅 UI를 작은 재사용 가능한 컴포넌트로 분리
- **유지보수성**: 각 컴포넌트의 독립적 관리 및 테스트
- **일관성**: 디자인 시스템(VersusColors, VersusTextStyles) 통일 적용
- **성능**: 효율적인 렌더링과 상태 관리

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/chat_detail_v2/components/
├── chat_detail_app_bar.dart        # 채팅 앱바 (76줄)
├── chat_detail_fab.dart            # 플로팅 액션 버튼 (56줄)
├── chat_detail_loading_widgets.dart # 로딩 UI 모음 (107줄)
├── chat_media_picker.dart          # 미디어 선택기 (234줄)
├── chat_message_builder.dart       # 메시지 렌더러 (283줄)
└── chat_search_bar.dart           # 검색 바 (313줄)
```

### 📊 코드 통계
- **총 코드 라인**: 1,069줄
- **파일 수**: 6개
- **평균 파일 크기**: 178줄

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접두사**: `chat_` (채팅 관련 컴포넌트 식별)
- **예시**: `chat_detail_app_bar.dart`, `chat_message_builder.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `ChatDetailAppBar`, `ChatMediaPicker`, `ChatSearchBar`

### 메서드명
- **패턴**: camelCase
- **접두사**: 
  - `build`: 위젯 빌드 메서드
  - `show`: 다이얼로그/모달 표시
  - `pick`: 선택 작업
  - `format`: 포맷팅 작업
- **예시**: `buildCustomMessage`, `showMediaOptions`, `pickMediaFromGallery`

### 상수 및 변수
- **패턴**: camelCase
- **Private**: `_` 접두사 사용
- **예시**: `_searchController`, `_fabAnimationController`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소 (Core Components)

### 1. ChatDetailAppBar - 채팅 앱바 🎯

**채팅 화면 상단 앱바**로 뒤로가기, 채팅방 이름, 검색 버튼을 포함합니다.

#### 주요 특징
- **높이**: 45px (Android 텍스트 잘림 방지)
- **SafeArea 처리**: 상단만 적용
- **하단 테두리**: 1px 검은색 라인
- **반응형 액션**: 검색 토글, 뒤로가기

#### Props
```dart
final ChatsModel? chatDocument;      // 채팅방 정보
final bool isAiChat;                 // AI 채팅 여부
final bool isSearching;              // 검색 상태
final VoidCallback onSearchToggle;   // 검색 토글
final VoidCallback onBack;           // 뒤로가기
```

### 2. ChatDetailFAB - 플로팅 액션 버튼 ⬇️

**스크롤 다운 버튼**으로 최신 메시지로 빠르게 이동하는 기능을 제공합니다.

#### 주요 특징
- **AnimatedPositioned**: 부드러운 위치 전환
- **이중 애니메이션**: Scale + Bounce 효과
- **자동 숨김**: 하단 근처에서 자동 숨김
- **확장형 FAB**: 아이콘 + "아래로" 텍스트

#### 애니메이션 설정
```dart
duration: 300ms (위치 이동)
scaleAnimation: 0.0 → 1.0
bounceAnimation: 1.0 → 1.2 → 1.0
```

### 3. ChatDetailLoadingWidgets - 로딩 UI 모음 ⏳

**정적 메서드 모음**으로 다양한 로딩 상태 UI를 제공합니다.

#### 제공 메서드
- `buildLoadingIndicator()`: 초기 로딩 화면
- `buildLoadingMoreIndicator()`: 추가 메시지 로딩
- `buildEmptyChatList(bool isAiChat)`: 빈 채팅방 UI
- `buildUserLoadingScreen()`: 사용자 정보 로딩

#### 특징
- **정적 클래스**: 인스턴스 생성 불필요
- **일관된 스타일**: VersusColors/TextStyles 사용
- **조건부 메시지**: AI 채팅 여부에 따른 메시지 분기

### 4. ChatMediaPicker - 미디어 선택기 📷

**이미지/비디오 선택 및 업로드**를 담당하는 핵심 컴포넌트입니다.

#### 주요 기능
- **듀얼 옵션**: 갤러리 선택 & 카메라 촬영
- **Firebase Storage 업로드**: 자동 업로드 및 URL 생성
- **파일 크기 제한**: 10MB 체크 (ChatFileSizeService)
- **에러 처리**: BotToast를 통한 사용자 피드백

#### 업로드 플로우
```dart
1. showMediaOptions() → 모달 바텀시트
2. pickMediaFromGallery() 또는 pickMediaFromCamera()
3. _uploadAndSendAsset() → Firebase Storage
4. onMediaSelected(url, type) 콜백
```

#### 의존성
- wechat_assets_picker: 갤러리 선택
- wechat_camera_picker: 카메라 촬영
- firebase_storage: 파일 업로드
- uuid: 고유 파일명 생성

### 5. ChatMessageBuilder - 메시지 렌더러 🎨

**다양한 메시지 타입 렌더링**을 담당하는 핵심 빌더 클래스입니다.

#### 메시지 타입
- **CustomMessage**: VoteCard 등 커스텀 메시지
- **SystemMessage**: 날짜 헤더, 읽지 않은 메시지 구분선
- **TextMessage**: 일반 텍스트 (flutter_chat_ui 처리)

#### VoteCard 렌더링
```dart
metadata['type'] == 'voteRequest' || 'voteCreated'
→ VoteCardMessage 위젯 생성
→ 버블 컨테이너로 래핑
→ 시간 및 상태 표시 추가
```

#### 메시지 상태 표시
- **sent**: 단일 체크 (회색)
- **delivered**: 이중 체크 (회색)  
- **seen**: 이중 체크 (파란색)
- **unknown**: 시계 아이콘

#### 시간 포맷
```dart
formatMessageTime(): "3:30 PM" 형식 (12시간제)
```

### 6. ChatSearchBar - 검색 UI 🔍

**메시지 검색 및 AI 질문 입력**을 위한 이중 목적 컴포넌트입니다.

#### 두 가지 모드

##### ChatSearchBar (일반 검색)
- **실시간 검색**: onChange 이벤트로 즉시 검색
- **검색 결과 카운트**: "1/5" 형식 표시
- **네비게이션**: 위/아래 화살표로 결과 탐색
- **자동 포커스**: 열릴 때 자동으로 입력 포커스

##### ChatAISearchInput (AI 질문)
- **AI 아이콘**: 그라디언트 원형 아이콘
- **둥근 입력창**: 22px radius 
- **전송 버튼**: 텍스트 있을 때만 활성화
- **Enter 키 지원**: onSubmitted 처리

## 💡 사용 가이드

### AppBar 사용 예시
```dart
ChatDetailAppBar(
  chatDocument: chatDoc,
  isAiChat: false,
  isSearching: _isSearching,
  onSearchToggle: () => setState(() => _isSearching = !_isSearching),
  onBack: () => Navigator.pop(context),
)
```

### 미디어 선택 예시
```dart
await ChatMediaPicker.showMediaOptions(
  context,
  onMediaSelected: (url, type) {
    // url: Firebase Storage URL
    // type: 'image' 또는 'video'
    _sendMediaMessage(url, type);
  },
);
```

### 메시지 빌더 사용
```dart
ChatMessageBuilder.buildCustomMessage(
  context,
  message,
  index,
  isSentByMe: message.authorId == currentUserId,
  chatDocument: chatDoc,
  currentUserRecord: userRecord,
  searchQuery: _searchQuery,
);
```

## 🎨 UI/UX 특징

### 디자인 시스템 통합
- **색상**: VersusColors (primary, backgroundSecondary, textPrimary 등)
- **타이포그래피**: VersusTextStyles (headingMedium, bodyMedium, labelSmall 등)
- **간격**: VersusSpacing (sm: 8px, md: 16px, lg: 24px)

### 애니메이션
- **FAB**: ElasticOut curve로 부드러운 등장
- **위치 이동**: 300ms duration의 Curves.easeInOut
- **바운스 효과**: 200ms의 탄성 애니메이션

### 반응형 디자인
- **메시지 최대 너비**: 화면의 75%
- **버블 모서리**: 발신자/수신자에 따른 차별화
- **그림자 효과**: 5px blur의 미묘한 그림자

## ⚡ 성능 최적화

### 위젯 최적화
- **KeyedSubtree**: VoteCard 재빌드 최소화
- **정적 메서드**: 상태 없는 UI는 static 메서드 사용
- **조건부 렌더링**: 필요한 요소만 렌더링

### 리소스 관리
- **컨트롤러 dispose**: 메모리 누수 방지
- **파일 크기 체크**: 업로드 전 크기 검증
- **UUID 생성**: 파일명 충돌 방지

## 🔒 보안 고려사항

### 구현된 보안 기능
- **파일 크기 제한**: 10MB 이하만 허용
- **Firebase Storage 경로**: `chat_media/` 격리
- **고유 파일명**: UUID v4 사용

### 추가 권장사항
1. **파일 타입 검증**: 허용된 확장자만 업로드
2. **이미지 검열**: 부적절한 콘텐츠 필터링
3. **Rate Limiting**: 업로드 횟수 제한

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **검색 버튼 제거**: AppBar에서 검색 버튼이 주석 처리됨
2. **AI 프로필 하드코딩**: picsum.photos 사용
3. **미디어 타입 제한**: 이미지/비디오만 지원

### 개선 제안
1. **파일 첨부**: 문서 파일 지원 추가
2. **미리보기**: 업로드 전 미리보기 기능
3. **압축**: 이미지 자동 압축 옵션
4. **진행률 표시**: 업로드 진행률 인디케이터

## 📊 통계 및 메트릭스

### 코드 복잡도
| 파일 | 라인 수 | 복잡도 | 유지보수성 |
|------|---------|---------|------------|
| chat_detail_app_bar.dart | 76 | 낮음 | 우수 |
| chat_detail_fab.dart | 56 | 낮음 | 우수 |
| chat_detail_loading_widgets.dart | 107 | 낮음 | 우수 |
| chat_media_picker.dart | 234 | 중간 | 양호 |
| chat_message_builder.dart | 283 | 높음 | 리팩토링 고려 |
| chat_search_bar.dart | 313 | 중간 | 양호 |

### 의존성
- flutter_chat_core: ^2.8.0
- wechat_assets_picker: 최신
- wechat_camera_picker: 최신
- firebase_storage: ^12.3.2
- bot_toast: 최신
- uuid: 최신
- intl: 최신

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-08-23 | 초기 문서 작성 | AI Assistant |
| 0.9.0 | 2025-08-18 | 컴포넌트 분리 완료 | 개발팀 |
| 0.8.0 | 2025-08-13 | AppBar 높이 조정 (Android 대응) | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 채팅 상세 UI 컴포넌트를 설명합니다.*
*각 컴포넌트는 독립적으로 재사용 가능하며 테스트 가능합니다.*
*마지막 업데이트: 2025-08-23*