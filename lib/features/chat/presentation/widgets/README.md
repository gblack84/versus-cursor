# 📦 /lib/features/chat/presentation/widgets

> Feature-First Architecture - Chat Widgets (Components)

## 📋 개요

채팅 기능의 **Widget/Component Layer**를 담당하는 디렉토리입니다. 재사용 가능한 UI 컴포넌트들을 포함합니다.

### 🎯 목적
- **재사용성**: 여러 화면에서 사용 가능한 컴포넌트
- **모듈화**: 독립적이고 조합 가능한 위젯
- **일관성**: 통일된 UI/UX 제공
- **유지보수성**: 컴포넌트 단위 관리

## 🏗️ 디렉토리 구조

```
widgets/
├── chat_list/                        # 채팅 목록 관련 위젯
│   ├── chat_list_item.dart          # 채팅 아이템
│   ├── chat_avatar.dart             # 채팅 아바타
│   ├── unread_badge.dart            # 읽지 않은 뱃지
│   └── chat_search_bar.dart         # 검색바
│
├── messages/                         # 메시지 관련 위젯
│   ├── message_bubble.dart          # 메시지 버블
│   ├── message_status.dart          # 메시지 상태
│   ├── message_reactions.dart       # 반응 표시
│   └── typing_indicator.dart        # 타이핑 표시
│
├── vote_cards/                       # 투표 카드 위젯
│   ├── vote_card_message.dart       # 투표 카드 메시지
│   ├── vote_option_box.dart         # 투표 옵션 박스
│   ├── vote_timer.dart              # 투표 타이머
│   └── vote_results.dart            # 투표 결과
│
├── input/                            # 입력 관련 위젯
│   ├── chat_input_bar.dart          # 입력창
│   ├── attachment_picker.dart       # 첨부 선택
│   ├── emoji_picker.dart            # 이모지 선택
│   └── reply_preview.dart           # 답장 미리보기
│
├── media/                            # 미디어 관련 위젯
│   ├── image_message.dart           # 이미지 메시지
│   ├── video_message.dart           # 비디오 메시지
│   ├── audio_message.dart           # 오디오 메시지
│   └── media_thumbnail.dart         # 미디어 썸네일
│
└── common/                           # 공통 위젯
    ├── empty_state.dart              # 빈 상태
    ├── loading_indicator.dart       # 로딩 표시
    ├── error_widget.dart            # 에러 표시
    └── shimmer_loading.dart        # 스켈레톤 로딩
```

## 📂 채팅 목록 위젯

### 1. ChatListItem

**책임**: 채팅 목록의 개별 아이템 표시

**주요 기능**:
- 채팅방 정보 표시 (제목, 마지막 메시지, 시간)
- 읽지 않은 메시지 뱃지 표시
- 그룹/1:1 채팅 구분 표시
- 터치 이벤트 처리 (탭, 롱프레스)

**Props**:
- `chat`: ChatModel - 채팅 데이터
- `currentUserId`: String - 현재 사용자 ID
- `onTap`: VoidCallback? - 탭 이벤트
- `onLongPress`: VoidCallback? - 롱프레스 이벤트
- `showLastMessage`: bool - 마지막 메시지 표시 여부
- `showUnreadBadge`: bool - 읽지 않은 뱃지 표시 여부

**UI 구성**:
- 좌측: ChatAvatar (56px)
- 중앙: 채팅 제목, 마지막 메시지
- 우측: 시간, 읽지 않은 뱃지

### 2. ChatAvatar

**책임**: 채팅방 아바타 이미지 표시

**주요 기능**:
- 프로필 이미지 표시 (CachedNetworkImage)
- 그룹/1:1 채팅 아이콘 구분
- 온라인 상태 인디케이터
- 플레이스홀더 처리

**Props**:
- `chat`: ChatModel - 채팅 데이터
- `currentUserId`: String - 현재 사용자 ID
- `size`: double - 아바타 크기 (기본값: 48)
- `showOnlineStatus`: bool - 온라인 상태 표시 여부

**상태 표시**:
- 온라인: 초록색 원
- 오프라인: 표시 없음
- 그룹 채팅: 그룹 아이콘

## 📂 메시지 위젯

### 1. MessageBubble

**책임**: 채팅 메시지 버블 표시

**주요 기능**:
- 메시지 타입별 렌더링 (텍스트, 이미지, 비디오)
- 발신자/수신자 구분 스타일링
- 답장 미리보기 표시
- 메시지 상태 표시 (전송중, 전달됨, 읽음)
- 반응(이모지) 표시

**Props**:
- `message`: MessageModel - 메시지 데이터
- `isMe`: bool - 내 메시지 여부
- `showAvatar`: bool - 아바타 표시 여부
- `onTap`: VoidCallback? - 탭 이벤트
- `onLongPress`: VoidCallback? - 롱프레스 이벤트
- `showTime`: bool - 시간 표시 여부
- `showStatus`: bool - 상태 표시 여부

**메시지 타입**:
- text: 일반 텍스트 메시지
- image: 이미지 메시지 (ImageMessage 위젯)
- video: 비디오 메시지 (VideoMessage 위젯)
- audio: 오디오 메시지
- file: 파일 첨부
- voteCard: 투표 카드

## 📂 투표 카드 위젯

### VoteCardMessage

**책임**: 투표 카드 메시지 표시 및 상호작용

**주요 기능**:
- A/B 투표 옵션 표시
- 실시간 타이머 표시 (10분)
- 투표 상태 관리 (진행중/완료)
- 투표 결과 표시
- 중복 투표 방지

**Props**:
- `message`: MessageModel - 투표 메시지 데이터
- `isMe`: bool - 내 메시지 여부
- `onVote`: Function(String) - 투표 콜백
- `onViewResults`: VoidCallback? - 결과 보기 콜백

**투표 상태**:
- 진행중: 파란색 헤더, 타이머 표시
- 완료: 초록색 헤더, 결과 보기 버튼
- 투표함: 옵션 선택 비활성화

## 📂 입력 위젯

### ChatInputBar

**책임**: 채팅 메시지 입력 및 전송

**주요 기능**:
- 텍스트 입력 필드 (다중 라인 지원)
- 첨부 파일 선택 (이미지, 비디오, 파일)
- 이모지 피커 토글
- 음성 녹음 버튼
- 답장 미리보기
- 동적 전송/마이크 버튼 전환

**Props**:
- `controller`: TextEditingController - 텍스트 컨트롤러
- `onSend`: Function(String) - 메시지 전송 콜백
- `onAttachment`: VoidCallback? - 첨부 버튼 콜백
- `isTyping`: bool - 타이핑 상태
- `replyTo`: MessageModel? - 답장 대상 메시지
- `onCancelReply`: VoidCallback? - 답장 취소 콜백

**상태 관리**:
- 텍스트 입력 감지
- 이모지 피커 표시/숨김
- 전송 버튼 활성화/비활성화

## 🧪 테스트 전략

### Widget 테스트

**테스트 카테고리**:
1. **렌더링 테스트**:
   - 위젯 기본 렌더링
   - Props에 따른 조건부 렌더링
   - 레이아웃 검증

2. **상호작용 테스트**:
   - 터치 이벤트 처리
   - 텍스트 입력
   - 버튼 클릭

3. **상태 변경 테스트**:
   - 로딩 상태
   - 에러 상태
   - 완료 상태

**테스트 시나리오**:
- MessageBubble: 메시지 타입별 렌더링
- ChatInputBar: 텍스트 입력 및 전송
- VoteCardMessage: 투표 상호작용
- ChatListItem: 읽지 않은 뱃지 표시

## ⚠️ 주의사항

### 1. 재사용성
- 독립적이고 자족적인 컴포넌트
- 외부 의존성 최소화
- Props를 통한 커스터마이징

### 2. 성능
- const 생성자 활용
- 불필요한 리빌드 방지
- 이미지 캐싱 적용

### 3. 접근성
- Semantic 위젯 사용
- 적절한 label 제공
- 키보드 네비게이션 지원

## ✅ 체크리스트

### 구현 완료
- [ ] ChatListItem
- [ ] MessageBubble
- [ ] VoteCardMessage
- [ ] ChatInputBar
- [ ] ChatAvatar
- [ ] UnreadBadge

### 테스트
- [ ] 각 위젯 단위 테스트
- [ ] 스냅샷 테스트
- [ ] 접근성 테스트

## 📚 참고 자료

- [Flutter Widget Catalog](https://docs.flutter.dev/development/ui/widgets)
- [Material Design](https://material.io/design)
- [Flutter Testing](https://docs.flutter.dev/testing)

---

*이 문서는 Feature-First Architecture의 Chat Widget Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*