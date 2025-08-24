# Versus Space 시스템 아키텍처

## 🏗️ 전체 시스템 구조

```
┌─────────────────────────────────────────────────────────────────────┐
│                           Flutter App                                │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐             │
│  │   UI Layer  │  │ State Mgmt   │  │  Services      │             │
│  │  - Pages    │  │ - Provider   │  │  - AI Mod      │             │
│  │  - Widgets  │  │ - AppState   │  │  - Notif       │             │
│  │  - Design   │  │ - Navigation │  │  - Chat        │             │
│  │  - Smart    │  │              │  │  - Layout      │             │
│  │    Layout   │  │              │  │                │             │
│  └─────────────┘  └──────────────┘  └────────────────┘             │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      Firebase Backend                                │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐             │
│  │  Firestore  │  │   Storage    │  │ Cloud Functions│             │
│  │  - Users    │  │  - Images    │  │  - Triggers    │             │
│  │  - Posts    │  │  - Videos    │  │  - Scheduled   │             │
│  │  - Messages │  │  - Thumbnails│  │  - HTTPS       │             │
│  └─────────────┘  └──────────────┘  └────────────────┘             │
└─────────────────────────────┬───────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                      External Services                               │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐             │
│  │  Gemini AI  │  │ Vision API   │  │ Perspective   │             │
│  │  - Content  │  │  - Image     │  │  - Text       │             │
│  │  - Matching │  │  - Safety    │  │  - Toxicity   │             │
│  └─────────────┘  └──────────────┘  └────────────────┘             │
└─────────────────────────────────────────────────────────────────────┘
```

## 🔄 주요 시스템 플로우

### 1. 게시물 생성 및 알림 플로우

```mermaid
sequenceDiagram
    participant User as 사용자
    participant App as Flutter App
    participant CF as Cloud Functions
    participant FS as Firestore
    participant AI as AI Services
    
    User->>App: 게시물 작성
    App->>AI: 콘텐츠 검열
    AI-->>App: 검열 결과
    App->>FS: 게시물 저장
    FS->>CF: onCreate 트리거
    CF->>AI: 사용자 매칭
    AI-->>CF: 추천 사용자
    CF->>FS: 알림 생성
    CF->>FS: AI 채팅 메시지
    FS-->>App: 실시간 알림
```

### 2. 투표 시스템 플로우

```mermaid
sequenceDiagram
    participant User as 투표자
    participant App as Flutter App
    participant FS as Firestore
    participant CF as Cloud Functions
    
    User->>App: 투표 참여
    App->>FS: 투표 저장
    FS->>CF: onUpdate 트리거
    CF->>CF: 투표 집계
    Note over CF: 10분 타이머
    CF->>FS: 상태 업데이트
    CF->>FS: 결과 알림
    FS-->>App: 실시간 업데이트
```

### 3. 채팅 시스템 아키텍처

#### 컴포넌트 구조 및 역할 분담

```
┌─────────────────────────────────────────────────────────┐
│                    채팅 시스템 구조                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐         ┌──────────────────────┐  │
│  │  ChatListWidget │ ────────▶│ ChatDetailWidgetV2   │  │
│  │  (채팅 목록)     │         │  (✅ 현재 사용 중)     │  │
│  └─────────────────┘         │                      │  │
│                              │  - 일반 채팅 처리        │  │
│                              │  - AI 투표 카드 표시    │  │
│                              │  - 검색 (AI만)         │  │
│                              └──────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              AIChatPageV2 (미래 기능)              │   │
│  │                                                 │   │
│  │  ⚠️ 현재 미사용 - 향후 AI 어시스턴트용             │   │
│  │  - 앱 사용법 안내                                │   │
│  │  - 실시간 AI 대화                               │   │
│  │  - Gemini AI 통합                              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

#### ⚠️ 중요 구분 사항

| 컴포넌트 | 상태 | 용도 | 경로 |
|----------|------|------|------|
| **ChatDetailWidgetV2** | ✅ 현재 사용 중 | 모든 채팅 처리 (일반 + 투표 카드) | `/lib/pages/chat/chat_detail_v2/` |
| **AIChatPageV2** | ⚠️ 미사용 | 미래 AI 어시스턴트 전용 | `/lib/pages/chat/ai_chat_v2/` |

#### AI 채팅 감지 로직
```dart
// ChatDetailWidgetV2에서 AI 채팅 감지
bool get isAiChat => 
  widget.chatDocument?.chatName == 'AI 피클' ||
  (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);

// AI 채팅인 경우만 검색 기능 활성화
if (isAiChat) {
  // AppBar에 검색 아이콘 표시
  // 검색 기능 활성화
}
```

#### 채팅방 생성 플로우 (현재: 투표 중심)

```mermaid
sequenceDiagram
    participant User as 사용자
    participant App as Flutter App
    participant NS as NotificationService
    participant FS as Firestore
    
    User->>App: 투표 생성
    App->>App: 타겟 사용자 선택
    App->>NS: createVoteRequestChatMessage()
    NS->>FS: 채팅방 생성 (ID: user1_user2)
    NS->>FS: 투표 카드 메시지 추가
    NS->>FS: 알림 생성
    FS-->>App: 실시간 업데이트
    Note over App: ChatDetailWidgetV2에서 처리
```

**참고**: 현재 친구에게 직접 메시지를 보내는 기능은 구현되지 않았습니다. 모든 채팅은 투표 요청을 통해서만 시작됩니다.

### 4. 스마트 레이아웃 데이터 플로우 (v1.3.0)

```mermaid
sequenceDiagram
    participant User as 사용자
    participant App as Flutter App
    participant FS as Firestore
    participant NS as NotificationService
    participant UI as VotingDialog
    
    User->>App: 이미지 선택
    App->>App: AspectRatio 계산
    App->>App: 최적 레이아웃 결정
    App->>FS: layoutType, aspectRatio 저장
    
    Note over NS: 알림 수신
    NS->>FS: Posts 데이터 조회
    FS-->>NS: optionA/B Map 데이터
    NS->>NS: aspectRatio 추출
    NS->>UI: 레이아웃 정보 전달
    UI->>UI: VersusBoxSizeData 생성
    UI-->>User: 최적화된 레이아웃 표시
```

## 🗂️ 데이터 흐름

### Firestore 컬렉션 관계

```
users
├── friends_list (서브컬렉션)
└── 연관: posts, messages, notifications

posts
├── comments (서브컬렉션)
├── likes (서브컬렉션)
└── dislikes (서브컬렉션)

chats
└── messages (서브컬렉션)

notifications
└── 연관: posts, users
```

### 실시간 업데이트 구조

1. **Firestore Listeners**
   - 채팅 메시지: `chats/{chatId}/messages`
   - 알림: `notifications` where `userId == currentUser`
   - 투표 상태: `posts/{postId}` 

2. **State Management**
   - Provider Pattern으로 전역 상태 관리
   - AppState에서 사용자 정보 및 설정 관리
   - NavigationProvider로 네비게이션 상태 관리

## 🔐 보안 구조

### Firebase Security Rules

```javascript
// 기본 읽기 권한
match /posts/{post} {
  allow read: if true;
  allow write: if request.auth.uid == resource.data.userid;
}

// 사용자별 접근 제어
match /users/{userId} {
  allow read: if true;
  allow write: if request.auth.uid == userId;
}

// 채팅 메시지 접근 제어
match /chats/{chatId}/messages/{message} {
  allow read: if request.auth.uid in parent(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
  allow create: if request.auth.uid in parent(/databases/$(database)/documents/chats/$(chatId)).data.participantIds;
}
```

### API 키 관리

- Firebase Functions Config로 안전하게 관리
- 환경별 분리 (개발/운영)
- 클라이언트에서 직접 API 호출 금지

## 🚀 성능 최적화

### 1. 이미지 처리
- **업로드 시**: 3단계 리사이징 (original, display, thumbnail)
- **캐싱**: CachedNetworkImage 사용
- **압축**: JPEG 85% 품질

### 2. 데이터베이스 최적화
- **인덱스**: 자주 사용하는 쿼리에 복합 인덱스 생성
- **배치 처리**: 대량 작업 시 배치 write 사용
- **병렬 처리**: Promise.all()로 독립적인 작업 병렬 실행

### 3. Cloud Functions 최적화
- **콜드 스타트 최소화**: 함수 분리 및 메모리 최적화
- **타임아웃 설정**: 함수별 적절한 타임아웃 설정
- **리전 설정**: asia-northeast3 (서울) 사용

### 4. 채팅 시스템 최적화 (v3.0.0)

#### 3-Layer 캐싱 아키텍처
```
┌─────────────────────────────────────────┐
│         UnifiedCacheService             │
├─────────────────────────────────────────┤
│  L1: SimpleMemoryCache                  │
│      - 100개 제한, 5분 TTL              │
│      - <10ms 응답                       │
│                ▼                        │
│  L2: Hive Local DB                      │
│      - 영구 로컬 저장소                  │
│      - 10-30ms 응답                     │
│                ▼                        │
│  L3: Firestore Offline Cache            │
│      - 무제한 크기                       │
│      - 50-100ms 응답                    │
└─────────────────────────────────────────┘
```

#### 병렬 로딩 최적화
- **사용자 정보**: Future.wait()로 병렬 로드
- **메시지 변환**: 30-50개 메시지 동시 처리
- **채팅방 진입**: 500ms → 200ms (60% 개선)

#### flutter_chat_ui v2 스크롤 문제 해결
- **문제**: Regular List 모드로 인한 스크롤 점프
- **해결**: ChatAnimatedListReversed 적용
- **결과**: 즉시 최신 메시지 표시

## 📱 클라이언트 아키텍처

### Flutter 앱 구조

```
lib/
├── backend/          # Firebase 통합
│   ├── schema/      # 데이터 모델
│   └── firebase/    # Firebase 설정
├── services/        # 비즈니스 로직
│   ├── ai_moderation/
│   ├── notification_service.dart
│   └── chat_service.dart
├── pages/          # UI 페이지
├── components/     # 재사용 컴포넌트
├── providers/      # 상태 관리
└── utils/         # 유틸리티
```

### 디자인 시스템

- **색상**: VersusColors (primary, secondary, etc.)
- **간격**: VersusSpacing (4px 기반)
- **텍스트**: VersusTextStyles (Plus Jakarta Sans)
- **컴포넌트**: 일관된 디자인 언어

### 주요 컴포넌트 구조

#### 투표 메시지 시스템 (v2.1.0)
```
components/chat/
├── base_vote_message.dart      # 추상 베이스 클래스
│   ├── 공통 상태 관리
│   ├── 투표 로직
│   └── currentUserName prop
└── vote_card_message.dart      # 통합 구현체
    ├── UI 렌더링
    ├── 스마트 레이아웃
    └── 사용자 정보 표시
```

**주요 특징**:
- 단일 컴포넌트로 통합 (VoteRequestMessage 제거)
- 사용자 이름 표시 기능
- 진행중 상태 파란색 표시
- 결과 표시: "피클! 피클! 피클! {사용자}님 결과를 보러오세요!"

## 🔄 CI/CD 파이프라인

### 배포 프로세스

1. **개발**: feature 브랜치에서 작업
2. **테스트**: 자동화된 테스트 실행
3. **스테이징**: 테스트 환경 배포
4. **프로덕션**: main 브랜치 병합 후 배포

### 모니터링

- **Firebase Performance**: 앱 성능 모니터링
- **Cloud Functions Logs**: 서버 로그 모니터링
- **Firestore Usage**: 데이터베이스 사용량 추적

## 🛠️ 개발 환경

### 필수 도구
- Flutter SDK (stable)
- Node.js 18+
- Firebase CLI
- VS Code / Android Studio

### 환경 설정
```bash
# Flutter 의존성
flutter pub get

# Functions 의존성
cd firebase/functions
npm install

# 환경 변수
firebase functions:config:set \
  gemini.api_key="KEY" \
  perspective.api_key="KEY"
```

## 📈 확장성 고려사항

### 현재 지원
- 1000명 동시 투표 처리 (<60초)
- 실시간 채팅 및 알림
- 멀티미디어 콘텐츠 지원

### 향후 확장
- 샤딩을 통한 데이터베이스 확장
- CDN을 통한 미디어 전송 최적화
- 마이크로서비스 아키텍처 전환 고려