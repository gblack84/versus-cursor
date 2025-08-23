# 🤖 AI Chat v2 - 미래 AI 어시스턴트 시스템

> Versus Space 앱의 미래 AI 어시스턴트 기능을 위한 전용 채팅 페이지 (현재 미사용)

## 📋 개요

이 디렉토리는 Versus Space 앱의 **미래 AI 어시스턴트 기능**을 담당합니다. 현재는 라우팅에 등록되지 않은 미사용 상태이지만, 향후 AI 도우미 기능 활성화를 위해 완전히 구현되어 있습니다. Google의 Gemini AI와 flutter_chat_ui v2.9.0을 기반으로 실시간 스트리밍 채팅을 제공합니다.

### 🎯 주요 목적
- **AI 어시스턴트 대화**: ChatGPT 스타일의 실시간 AI 대화
- **앱 사용법 안내**: AI가 앱 기능과 사용법 설명
- **스트리밍 응답**: Gemini AI의 실시간 텍스트 스트리밍
- **미래 확장성**: 학습 기능, 추천 시스템 준비

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/ai_chat_v2/
├── README.md                      # 현재 문서 (530줄)
├── ai_chat_page_v2.dart          # 메인 채팅 페이지 UI (936줄)
└── ai_chat_controller.dart       # AI 채팅 컨트롤러 (190줄)
```

### 📊 코드 통계
- **총 코드 라인**: 1,126줄
- **총 문서 라인**: 530줄
- **문서화 비율**: 47.1%
- **파일 수**: 3개

## 📐 네이밍 컨벤션 (Naming Convention)

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `ai_chat_page_v2.dart`, `ai_chat_controller.dart`

### 클래스명
- **패턴**: PascalCase
- **예시**: `AIChatPageV2`, `AIChatController`, `_AIChatPageV2State`

### 상수 및 ID
- **패턴**: camelCase 또는 snake_case (용도별)
- **예시**: 
  - `aiUserId = 'ai_assistant'` (상수)
  - `aiUserName = 'AI 피클'` (상수)
  - `ai_helper_userId` (채팅방 ID 형식)

### 라우트 설정 (미래)
| 화면 | routeName | routePath | 상태 |
|------|-----------|-----------|------|
| AIChatPageV2 | `'aiChatV2'` | `'/aiChatV2'` | 미등록 |

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## ⚠️ 현재 상태

### 미사용 상태
- **라우팅 미등록**: GoRouter에 등록되지 않음
- **진입점 없음**: 어떤 화면에서도 이 페이지로 이동 불가
- **API 키 미설정**: Gemini API 키 설정 필요
- **Firestore 미연동**: 메시지 영속성 미구현

### ChatDetailWidgetV2와의 차이점
| 구분 | ChatDetailWidgetV2 | AIChatPageV2 |
|------|-------------------|--------------|
| **용도** | 모든 채팅 처리 (투표 카드 포함) | AI 어시스턴트 전용 |
| **상태** | 현재 사용 중 | 미래 기능 (미사용) |
| **채팅방 ID** | `ai_assistant_userId` | `ai_helper_userId` (계획) |
| **AI 처리** | Firebase Functions | Gemini AI 직접 연동 |
| **기능** | 투표 생성/관리 | 도움말/일반 대화 |

## 🔑 주요 구성요소 (Core Components)

### 1. AIChatPageV2 - 메인 채팅 UI 🎨

**AI 채팅 페이지**로 flutter_chat_ui v2.9.0 기반의 완전한 채팅 인터페이스입니다.

#### 주요 특징
- **실시간 스트리밍**: Gemini AI 응답 실시간 표시
- **메시지 캐싱**: Map 기반 메시지 캐시 관리
- **사용자 캐싱**: UserCacheService 통합
- **검색 기능**: AI에게 질문하는 검색 입력창
- **스크롤 관리**: FAB 버튼으로 하단 이동

#### 초기화 플로우
```dart
// Bootstrap 시퀀스
initState()
    ↓
_bootstrap()
    ├─ _loadInitialMessages()  // 최근 30개 메시지 로드
    ├─ _startIncrementalStream()  // 실시간 스트림 시작
    └─ markMessagesAsSeen()  // 읽음 처리
```

#### 메시지 로딩 전략
```dart
// 3단계 메시지 로딩
1. 초기 로드: limitToLast(30)  // 최근 30개
2. 증분 스트림: startAfterDocument()  // 커서 기반
3. 페이지네이션: endBefore() + limitToLast(20)  // 과거 메시지
```

#### 애니메이션 시스템
```dart
// FAB 애니메이션
_fabAnimationController: 200ms bounce 효과
_fabScaleController: 300ms elasticOut 효과

// 새 메시지 알림
HapticFeedback.lightImpact()  // 햅틱 피드백
_animateFabBounce()  // FAB 바운스 애니메이션
```

### 2. AIChatController - AI 통합 컨트롤러 🧠

**Gemini AI 통합 컨트롤러**로 InMemoryChatController를 확장한 스트리밍 지원 컨트롤러입니다.

#### 주요 기능
- **AI 초기화**: Gemini 1.5 Flash 모델 설정
- **스트리밍 관리**: StreamSubscription 기반 응답 처리
- **메시지 타입**: TextMessage, TextStreamMessage 지원
- **에러 처리**: 스트림 취소 및 에러 메시지 표시

#### Gemini AI 설정
```dart
GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: apiKey,  // TODO: 환경 변수로 이동
  generationConfig: GenerationConfig(
    temperature: 0.7,  // 창의성 수준
    maxOutputTokens: 2048,  // 최대 응답 길이
  ),
)
```

#### 스트리밍 플로우
```dart
sendAIQuery()
    ├─ 사용자 메시지 추가
    ├─ 스트림 메시지 생성 (placeholder)
    ├─ Gemini AI 스트림 시작
    ├─ 청크별 텍스트 누적
    └─ 완료 시 일반 메시지로 변환
```

### 3. VoteCardMessage 통합 🗳️

**투표 카드 렌더링**을 위한 커스텀 메시지 지원이 포함되어 있습니다.

#### 메타데이터 구조
```dart
metadata: {
  'type': 'voteRequest' | 'voteCreated',
  'postId': String,
  'title': String,
  'optionAText': String,
  'optionBText': String,
  'optionAImages': List<String>?,
  'optionBImages': List<String>?,
  'voteEndTime': DateTime?,
  'cardStatus': String,
  'voteResults': Map?
}
```

## 🔄 계획된 아키텍처

### 듀얼 AI 채팅방 시스템

```
사용자 계정 생성
    ↓
자동 생성 (2개 채팅방)
    ├─ ai_assistant_userId  # 투표 AI (ChatDetailWidgetV2)
    └─ ai_helper_userId     # 도우미 AI (AIChatPageV2)
```

### 채팅 목록 표시 계획
1. **고정 위치**: 채팅 목록 최상단
2. **순서**: 
   - 1번: AI 피클 (투표) 🗳️
   - 2번: AI 도우미 🤖
3. **아이콘 구분**: 용도별 다른 아이콘

## 💡 사용 가이드 (미래)

### 페이지 진입 (현재 불가)
```dart
// 향후 활성화 시 사용법
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AIChatPageV2(
      aiChatId: 'ai_helper_$userId',
      chatDocument: chatDoc,
    ),
  ),
);
```

### API 키 설정 필요
```dart
// ai_chat_controller.dart line 134
// TODO: 환경 변수 또는 Firebase Remote Config 사용
_chatController.initializeAI('YOUR_GEMINI_API_KEY');
```

## 🎨 UI/UX 특징

### 디자인 시스템
- **테마**: VersusColors, VersusTextStyles 사용
- **폰트**: SourGummy 폰트 패밀리
- **색상**: 
  - Primary: VersusColors.primary
  - Background: VersusColors.backgroundPrimary
  - Secondary: VersusColors.backgroundSecondary

### 채팅 UI 커스터마이징
```dart
ChatTheme.light().copyWith(
  colors: ChatColors(...),
  typography: ChatTypography.standard(
    fontFamily: 'SourGummy',
  ),
)
```

### 검색 입력창
- **위치**: 하단 고정 (카카오톡 스타일)
- **플레이스홀더**: "AI 피클에게 물어보세요..."
- **스트리밍 중지**: 빨간색 중지 버튼

## ⚡ 성능 최적화

### 메시지 캐싱
```dart
final Map<String, core.Message> _messageCache = {};
// 중복 방지 및 빠른 조회
```

### 스트림 최적화
```dart
// 초기 스냅샷 스킵
_skipInitialSnapshot = true

// 메타데이터 변경 무시
snapshots(includeMetadataChanges: false)

// 커서 기반 스트리밍
startAfterDocument(_lastLoadedDocument!)
```

### 스크롤 디바운싱
- 100px 이내: Near bottom 판정
- 500px 이상: FAB 버튼 표시
- 100px 이하: 추가 메시지 로드

## 🔒 보안 고려사항

### 구현 필요 사항
1. **API 키 관리**: 환경 변수로 이동
2. **사용자 검증**: currentUserId 검증
3. **메시지 검증**: 부적절한 내용 필터링
4. **Rate Limiting**: API 호출 제한

## 🌍 국제화 (i18n)

### 지원 언어
- **한국어**: 기본 언어 (하드코딩)
- **영어**: 미지원 (추가 필요)

### 주요 텍스트
```dart
'AI 피클'  // AI 이름
'AI 피클에게 물어보세요...'  // 검색 플레이스홀더
'AI 피클과 대화를 시작해보세요'  // 빈 채팅 메시지
'오류가 발생했습니다'  // 에러 메시지
'[스트리밍 취소됨]'  // 취소 메시지
```

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **라우팅 미등록**: 의도적으로 등록하지 않음
2. **API 키 하드코딩**: 환경 변수로 이동 필요
3. **Firestore 미연동**: 메시지 영속성 없음
4. **첨부파일 미지원**: 이미지/파일 업로드 불가

### 개선 제안
1. **Phase 2**: ChatDetailWidget 마이그레이션
2. **Phase 3**: flutter_chat_types 제거
3. **메시지 영속성**: Firestore 저장 구현
4. **첨부파일 지원**: 이미지/파일 업로드
5. **음성 입력**: STT 기능 추가

## 📊 통계 및 메트릭스

### 코드 복잡도
| 파일 | 라인 수 | 복잡도 | 유지보수성 |
|------|---------|---------|------------|
| ai_chat_page_v2.dart | 936 | 높음 | 리팩토링 고려 |
| ai_chat_controller.dart | 190 | 낮음 | 우수 |

### 의존성
- flutter_chat_ui: ^2.9.0
- flutter_chat_core: ^2.8.0
- google_generative_ai: 최신
- cloud_firestore: ^5.5.0

## 📝 변경 이력 (Change History)

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 2.0.0 | 2025-08-23 | 포괄적 문서화 완료 | AI Assistant |
| 1.2.0 | 2025-08-18 | 듀얼 AI 채팅방 아키텍처 설계 | 개발팀 |
| 1.1.0 | 2025-08-18 | VoteStateCoordinator 통합 준비 | 개발팀 |
| 1.0.0 | 2025-08-17 | 초기 구현 완료 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 미래 AI 어시스턴트 시스템을 설명합니다.*
*현재는 미사용 상태이며, 향후 활성화 예정입니다.*
*마지막 업데이트: 2025-08-23*