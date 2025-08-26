# 📦 /lib/features/chat/presentation/providers

> Feature-First Architecture - Chat State Management (Providers)

## 📋 개요

채팅 기능의 **State Management Layer**를 담당하는 디렉토리입니다. Provider 패턴을 사용하여 상태를 관리합니다.

### 🎯 목적
- **상태 관리**: 애플리케이션 상태의 중앙 집중식 관리
- **비즈니스 로직 분리**: UI와 비즈니스 로직의 명확한 분리
- **반응형 UI**: 상태 변경에 따른 자동 UI 업데이트
- **테스트 용이성**: 독립적으로 테스트 가능한 상태 관리

## 🏗️ 디렉토리 구조

```
providers/
├── chat_list_provider.dart           # 채팅 목록 상태 관리
├── chat_detail_provider.dart         # 채팅방 상태 관리
├── message_provider.dart             # 메시지 상태 관리
├── vote_provider.dart                # 투표 상태 관리
├── ai_chat_provider.dart             # AI 채팅 상태 관리
├── notification_provider.dart        # 알림 상태 관리
├── user_provider.dart                # 사용자 상태 관리
├── group_chat_provider.dart          # 그룹 채팅 상태 관리
└── media_upload_provider.dart        # 미디어 업로드 상태 관리
```

## 📂 주요 Provider 구현

### 1. ChatListProvider

**책임**: 채팅 목록 상태 관리

**상태 속성**:
- `chats`: 필터링된 채팅 목록
- `isLoading`: 로딩 상태
- `hasError`: 에러 상태
- `errorMessage`: 에러 메시지
- `unreadCount`: 전체 읽지 않은 메시지 수
- `filterType`: 현재 필터 타입
- `sortBy`: 정렬 기준

**주요 메서드**:
- `loadChatList()`: 채팅 목록 로드
- `searchChats(query)`: 채팅 검색
- `filterByType(type)`: 필터 적용
- `sortBy(criteria)`: 정렬 기준 변경
- `deleteChat(chatId)`: 채팅 삭제
- `archiveChat(chatId)`: 채팅 보관
- `pinChat(chatId)`: 채팅 고정
- `muteChat(chatId)`: 채팅 음소거

**필터 타입**: all, direct, group, unread
**정렬 기준**: lastMessage, unreadCount, alphabetical

**의존성**: GetChatListUseCase, DeleteChatUseCase, ArchiveChatUseCase

### 2. ChatDetailProvider

**책임**: 채팅방 상태 관리

**상태 속성**:
- `chat`: 현재 채팅방 정보
- `messages`: 메시지 목록
- `participants`: 참여자 정보 Map
- `isInitializing`: 초기화 중 상태
- `isLoadingMore`: 추가 로딩 중 상태
- `isTyping`: 타이핑 상태
- `replyToMessage`: 답장 대상 메시지
- `selectedMessageIds`: 선택된 메시지 ID Set

**주요 메서드**:
- `initialize()`: 채팅방 초기화
- `subscribeToMessages()`: 메시지 실시간 구독
- `sendMessage(content, type, mediaPath, metadata)`: 메시지 전송
- `loadMoreMessages()`: 이전 메시지 로드
- `submitVote(messageId, option)`: 투표 제출
- `deleteMessage(messageId)`: 메시지 삭제
- `setReplyMessage(message)`: 답장 설정
- `toggleMessageSelection(messageId)`: 메시지 선택/해제
- `updateTypingStatus(isTyping)`: 타이핑 상태 업데이트

**의존성**: ChatInitializationService, ChatMessageService, SendMessageUseCase, LoadMessagesUseCase, SubmitVoteUseCase

### 3. VoteProvider

**책임**: 투표 상태 관리

**상태 속성**:
- `voteStates`: postId별 투표 상태 Map
- `timerStreams`: postId별 타이머 스트림 Map

**주요 메서드**:
- `getVoteState(postId)`: 투표 상태 조회
- `getTimerStream(postId)`: 타이머 스트림 조회
- `initializeVote(postId, voteEndTime, chatId)`: 투표 초기화
- `submitVote(postId, option, userId, chatId, messageId)`: 투표 제출
- `completeVote(postId)`: 투표 완료 처리
- `isVoteInProgress(postId)`: 투표 진행중 확인
- `hasUserVoted(postId, userId)`: 사용자 투표 여부
- `getVoteResults(postId)`: 투표 결과 조회
- `getVotePercentages(postId)`: 투표 퍼센티지 계산

**의존성**: VoteStateCoordinator, VoteTimerService

### 4. NotificationProvider

**책임**: 알림 상태 관리

**상태 속성**:
- `notifications`: 알림 목록
- `currentNotification`: 현재 표시중인 알림
- `unreadCount`: 읽지 않은 알림 수
- `hasUnread`: 읽지 않은 알림 존재 여부

**주요 메서드**:
- `closeCurrentNotification()`: 현재 알림 닫기
- `markAsRead(notificationId)`: 알림 읽음 처리
- `markAllAsRead()`: 모든 알림 읽음 처리
- `deleteNotification(notificationId)`: 알림 삭제
- `handleNotificationAction(notificationId, action)`: 알림 액션 처리
- `getFilteredNotifications(type, unreadOnly)`: 필터링된 알림 조회

**액션 타입**: view, skip, custom

**의존성**: GlobalNotificationManager, NotificationService

## 🧪 테스트 전략

### Provider 테스트

**테스트 카테고리**:
1. **상태 관리 테스트**:
   - 초기 상태 검증
   - 상태 변경 알림 (notifyListeners)
   - 메모리 누수 방지 (dispose)

2. **비즈니스 로직 테스트**:
   - 채팅 목록 로드/필터/정렬
   - 메시지 전송/수정/삭제
   - 투표 초기화/제출/완료
   - 알림 처리/읽음/삭제

3. **에러 처리 테스트**:
   - 네트워크 에러
   - 유효성 검증 실패
   - 타임아웃 처리

4. **통합 테스트**:
   - UseCase와의 통합
   - Service Layer와의 통합
   - 실시간 스트림 처리

**Mock 객체**:
- MockGetChatListUseCase
- MockSendMessageUseCase
- MockVoteStateCoordinator
- MockGlobalNotificationManager

## ⚠️ 주의사항

### 1. 상태 관리
- 불변성 유지
- 적절한 notifyListeners() 호출
- 메모리 누수 방지 (dispose)

### 2. 비동기 처리
- Future/Stream 적절히 사용
- 에러 처리 철저히
- 로딩 상태 관리

### 3. 성능
- 불필요한 리빌드 방지
- 선택적 Consumer 사용
- 캐싱 전략 활용

## ✅ 체크리스트

### 구현 완료
- [ ] ChatListProvider
- [ ] ChatDetailProvider
- [ ] VoteProvider
- [ ] NotificationProvider
- [ ] AIChatProvider
- [ ] UserProvider

### 테스트
- [ ] 각 Provider 단위 테스트
- [ ] 통합 테스트
- [ ] 상태 변경 테스트

## 📚 참고 자료

- [Provider Package](https://pub.dev/packages/provider)
- [State Management](https://docs.flutter.dev/development/data-and-backend/state-mgmt)
- [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)

---

*이 문서는 Feature-First Architecture의 Chat Provider Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*