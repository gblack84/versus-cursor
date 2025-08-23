# 💬 Chat List - 채팅 목록 페이지

> Versus Space 앱의 채팅 목록을 표시하고 관리하는 페이지 컴포넌트

## 📋 개요

ChatListWidget은 사용자가 참여 중인 모든 채팅방 목록을 표시하는 메인 채팅 목록 페이지입니다. Firestore의 실시간 스트림을 통해 채팅방 목록을 동적으로 업데이트하며, AI 채팅방과 일반 채팅방을 구분하여 표시합니다.

### 🎯 주요 목적
- **채팅방 목록 표시**: 사용자가 참여 중인 모든 채팅방 실시간 표시
- **AI 채팅 구분**: AI 피클 채팅방 특별 처리 (보라색 테마)
- **읽지 않은 메시지 표시**: 새 메시지 알림 인디케이터
- **시간 포맷팅**: 상대적 시간 표시 (방금 전, 1시간 전, 어제 등)

## 🏗️ 디렉토리 구조

```
/lib/pages/chat/chat_list/
├── chat_list_widget.dart  # 메인 채팅 목록 위젯 (265줄)
├── chat_list_model.dart   # 상태 관리 모델 (11줄)
└── README.md              # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 276줄
- **파일 수**: 2개
- **주요 위젯**: ChatListWidget (StatefulWidget)

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `chat_list_widget.dart`, `chat_list_model.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `Model`
- **예시**: `ChatListWidget`, `ChatListModel`

### 라우트명
- **정적 상수**: `routeName`, `routePath`
- **값**: 'chatList', '/chat/list'

### 메서드명
- **패턴**: camelCase
- **접두사**: 
  - `_build`: UI 빌드 메서드
  - `_format`: 포맷팅 메서드
- **예시**: `_buildEmptyState()`, `_buildChatItem()`, `_formatTime()`

### 변수명
- **패턴**: camelCase
- **예시**: `scaffoldKey`, `chatItem`, `isAIChat`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. ChatListWidget - 메인 채팅 목록 위젯 📱

**채팅 목록을 표시하는 메인 페이지 위젯**입니다.

#### 주요 기능
- **실시간 스트림**: Firestore `queryChatsModel` 스트림 구독
- **정렬**: `lastMessageAt` 기준 내림차순 정렬
- **필터링**: `participantIds`에 현재 사용자 포함된 채팅만 표시
- **AI 채팅 감지**: `ai_assistant` 또는 `chatType == 'aiChat'`
- **네비게이션**: ChatDetailWidgetV2로 이동

#### 스트림 쿼리
```dart
queryChatsModel(
  queryBuilder: (chatsRecord) => chatsRecord
    .where('participantIds', arrayContains: currentUserUid)
    .orderBy('lastMessageAt', descending: true),
)
```

#### UI 구성
- **AppBar**: "채팅" 타이틀, 새 채팅 추가 버튼 (준비 중)
- **빈 상태**: 채팅이 없을 때 안내 메시지
- **리스트 아이템**: 프로필, 채팅명, 마지막 메시지, 시간

### 2. ChatListModel - 상태 관리 모델 🎮

**ChatListWidget의 상태를 관리하는 모델 클래스**입니다.

#### 특징
- **AppModel 상속**: 프로젝트 공통 모델 패턴
- **최소 구현**: initState, dispose만 구현
- **향후 확장 가능**: 필요시 상태 관리 로직 추가

### 3. 채팅 아이템 UI 구성 🎨

#### AI 채팅방 구분
```dart
final isAIChat = chat.participantIds.contains('ai_assistant') || 
                 chat.chatType == 'aiChat';
```

#### 시각적 구분
| 타입 | 배경색 | 아이콘 | 아이콘 색상 | 채팅명 |
|------|--------|--------|------------|--------|
| **AI 채팅** | 보라색 0.1 | smart_toy | 보라색 | AI 피클 |
| **일반 채팅** | Primary 0.1 | person | Primary | 채팅명 또는 "채팅" |

#### 읽지 않은 메시지 표시
- **표시 조건**: `!chat.isRead`
- **UI**: 8x8 원형 파란색 점
- **위치**: 메시지 내용 오른쪽

### 4. 시간 포맷팅 로직 ⏰

#### _formatTime 메서드
```dart
String _formatTime(DateTime dateTime) {
  // 시간 차이에 따른 표시
  - 방금 전: < 1분
  - N분 전: 1-59분
  - N시간 전: 1-23시간
  - 어제: 1일 전
  - N일 전: 2-6일
  - MM/dd: 7일 이상
}
```

## 💡 사용 가이드

### 라우팅 설정
```dart
// GoRouter 설정
GoRoute(
  name: ChatListWidget.routeName,  // 'chatList'
  path: ChatListWidget.routePath,  // '/chat/list'
  builder: (context, state) => const ChatListWidget(),
)
```

### 네비게이션
```dart
// 채팅 목록으로 이동
context.pushNamed('chatList');

// 채팅 상세로 이동 (위젯 내부)
context.pushNamed(
  ChatDetailWidgetV2.routeName,
  extra: <String, dynamic>{
    'chatDocument': chat,
    kTransitionInfoKey: TransitionInfo(
      hasTransition: false,  // 스크롤 점프 방지
    ),
  },
);
```

## 🎨 UI/UX 특징

### 디자인 시스템
- **색상**: VersusColors (primary, backgroundPrimary, borderLight 등)
- **타이포그래피**: VersusTextStyles (headingSmall, bodyMedium, labelSmall 등)
- **간격**: VersusSpacing (paddingMD, gapSM, gapXS 등)

### 레이아웃
- **배경색**: 흰색 (AppBar), VersusColors.backgroundPrimary (Body)
- **구분선**: 각 아이템 하단 1px borderLight
- **패딩**: VersusSpacing.paddingMD (16px)
- **프로필 크기**: 56x56 원형

### 애니메이션
- **페이지 전환**: `hasTransition: false` (스크롤 점프 문제 해결)
- **탭 피드백**: InkWell 리플 효과

## ⚡ 성능 최적화

### 스트림 최적화
- **쿼리 인덱스**: participantIds + lastMessageAt 복합 인덱스 필요
- **실시간 업데이트**: StreamBuilder로 자동 리빌드
- **메모리 관리**: dispose에서 자동 스트림 정리

### UI 최적화
- **ListView.builder**: 대량 채팅방 효율적 렌더링
- **텍스트 제한**: 마지막 메시지 최대 2줄
- **조건부 렌더링**: 읽지 않은 메시지 점만 필요시 표시

## 🔒 보안 고려사항

### 구현된 보안
- **사용자 필터링**: 현재 사용자가 참여한 채팅만 표시
- **Firebase Auth**: currentUserUid 사용
- **읽기 권한만**: 채팅 목록은 읽기 전용

### 권장 개선사항
1. **채팅방 생성 권한**: 새 채팅 버튼 활성화 시 권한 체크
2. **메시지 미리보기**: 민감한 정보 마스킹 고려
3. **프로필 이미지**: 실제 사용자 이미지 캐싱 및 최적화

## 🐛 알려진 이슈 및 개선사항

### 현재 이슈
1. **새 채팅 버튼**: "준비 중" 스낵바만 표시
2. **프로필 이미지**: 아이콘만 표시 (실제 이미지 미구현)
3. **채팅명 표시**: 빈 채팅명일 때 "채팅"으로 표시

### 개선 제안
1. **검색 기능**: 채팅방 검색 필터 추가
2. **슬라이드 액션**: 삭제, 알림 끄기 등 스와이프 액션
3. **그룹 채팅 표시**: 다중 참여자 프로필 표시
4. **온라인 상태**: 사용자 온라인/오프라인 표시
5. **메시지 카운트**: 읽지 않은 메시지 개수 표시

## 📊 통계 및 메트릭스

### 성능 지표
| 메트릭 | 목표 | 현재 |
|--------|------|------|
| 초기 로딩 | <300ms | 측정 필요 |
| 스크롤 성능 | 60fps | 양호 |
| 메모리 사용 | <50MB | 측정 필요 |

### 의존성
- Flutter SDK
- firebase_auth: 인증
- cloud_firestore: 데이터베이스
- go_router: 네비게이션
- intl: 날짜 포맷팅 (DateFormat)

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 1.0.0 | 2025-08-23 | 상세 문서 작성 완료 | AI Assistant |
| 0.9.0 | 2025-08-22 | 초기 README 생성 | 개발팀 |
| 0.8.0 | 2025-08-13 | ChatListWidget 구현 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 채팅 목록 페이지를 설명합니다.*
*ChatListWidget은 모든 채팅방을 표시하는 메인 채팅 목록 페이지입니다.*
*마지막 업데이트: 2025-08-23*
