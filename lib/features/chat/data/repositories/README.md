# 📦 /lib/features/chat/data/repositories

> Feature-First Architecture - Chat Repository 계층

## 📋 개요

채팅 기능의 **Repository Layer**를 담당하는 디렉토리입니다. 데이터 소스를 추상화하여 비즈니스 로직에서 데이터 접근 방식의 세부사항을 숨깁니다.

### 🎯 목적
- **데이터 접근 추상화**: Remote/Local 데이터 소스 통합 관리
- **캐싱 전략 구현**: 3-Layer 캐싱 시스템 적용
- **에러 처리 통합**: 일관된 에러 핸들링
- **비즈니스 로직 분리**: 데이터 접근과 비즈니스 로직 분리

## 🏗️ 디렉토리 구조

```
repositories/
├── interfaces/                           # Repository 인터페이스
│   ├── chat_repository.dart             # 채팅 Repository 인터페이스
│   ├── message_repository.dart          # 메시지 Repository 인터페이스
│   └── group_chat_repository.dart       # 그룹 채팅 Repository 인터페이스
│
├── implementations/                      # Repository 구현체
│   ├── chat_repository_impl.dart        # 채팅 Repository 구현
│   ├── message_repository_impl.dart     # 메시지 Repository 구현
│   └── group_chat_repository_impl.dart  # 그룹 채팅 Repository 구현
│
└── mixins/                              # 공통 기능 Mixin
    ├── cache_mixin.dart                 # 캐싱 기능
    ├── error_handler_mixin.dart        # 에러 처리
    └── realtime_sync_mixin.dart        # 실시간 동기화
```

## 📂 핵심 Repository

### 1. ChatRepository (인터페이스)

**책임**: 채팅 데이터 접근 추상화

**주요 메서드**:
- `getChatListStream(userId)`: 사용자의 채팅 목록 스트림
- `getChat(chatId)`: 특정 채팅방 정보 조회
- `createChat(participantIds, initialMessage, metadata)`: 새 채팅방 생성
- `deleteChat(chatId)`: 채팅방 삭제
- `updateLastMessage(chatId, lastMessage, timestamp)`: 마지막 메시지 업데이트
- `markAsRead(chatId, userId)`: 읽음 처리
- `addParticipants(chatId, userIds)`: 참여자 추가
- `leaveChat(chatId, userId)`: 채팅방 나가기
- `searchChats(userId, query)`: 채팅방 검색

**반환 타입**: Either<Failure, T> 패턴 사용

### 2. ChatRepositoryImpl (구현체)

**책임**: ChatRepository 인터페이스 구현

**의존성**:
- FirebaseChatDatasource: Remote 데이터 소스
- ChatLocalDatasource: Local 데이터 소스
- UnifiedCacheService: 3-Layer 캐싱 서비스

**Mixin 활용**:
- CacheMixin: 캐싱 기능
- ErrorHandlerMixin: 에러 처리

**구현 패턴**:
1. 캐시 우선 조회
2. Remote 데이터 동기화
3. Local 저장소 업데이트
4. 캐시 무효화/업데이트

### 3. MessageRepository

**책임**: 메시지 데이터 관리

**주요 메서드**:
- `getMessagesStream(chatId, limit)`: 메시지 스트림
- `sendMessage(chatId, content, mediaUrl, type, metadata)`: 메시지 전송
- `editMessage(messageId, newContent)`: 메시지 수정
- `deleteMessage(messageId)`: 메시지 삭제
- `addReaction(messageId, emoji, userId)`: 반응 추가
- `createVoteCard(chatId, options, voteDuration)`: 투표 카드 생성
- `submitVote(messageId, option, userId)`: 투표 제출
- `loadMoreMessages(chatId, lastMessage, limit)`: 페이지네이션

### 4. MessageRepositoryImpl

**책임**: MessageRepository 인터페이스 구현

**의존성**:
- FirestoreMessageDatasource: Firestore 데이터 소스
- MessageCacheDatasource: 메시지 캐시
- ChatMediaUploadService: 미디어 업로드 서비스
- VoteStateCoordinator: 투표 상태 관리

**주요 기능**:
1. 메시지 스트림 처리 (캐시 우선)
2. 미디어 업로드 통합
3. 투표 상태 동기화
4. 마지막 메시지 업데이트

## 🔄 Mixin 활용

### CacheMixin

**역할**: 캐싱 기능 제공 Mixin

**주요 기능**:
- `getCacheFirst<T>(key, fetcher)`: 캐시 우선 조회
- `invalidateCache(pattern)`: 캐시 패턴 무효화

**캐시 전략**:
- 기본 캐시 유효시간: 1시간
- 캐시 미스 시 Remote 조회 후 캐싱

### ErrorHandlerMixin

**역할**: 에러 처리 통합 Mixin

**주요 기능**:
- `handleError<T>(operation)`: Future 에러 처리
- `handleStreamError<T>(operation)`: Stream 에러 처리

**에러 타입 매핑**:
- FirebaseException → ServerFailure
- NetworkException → NetworkFailure
- Exception → UnknownFailure

## 🧪 테스트 전략

### Mock Repository

**또적**: 테스트를 위한 Mock Repository 구현

**주요 기능**:
- 메모리 기반 데이터 저장
- StreamController를 통한 실시간 스트림 시뮬레이션
- 성공/실패 시나리오 설정 가능

**테스트 용도**:
- 단위 테스트
- 통합 테스트
- UI 테스트

## ⚠️ 주의사항

### 1. 캐싱 전략
- 채팅 목록: 5분 캐시
- 메시지: 영구 캐시 (실시간 업데이트)
- 사용자 정보: 30분 캐시

### 2. 에러 처리
- 네트워크 에러 시 로컬 데이터 반환
- 재시도 로직 구현 (exponential backoff)
- 사용자 친화적 에러 메시지

### 3. 성능 최적화
- 페이지네이션 구현
- 이미지 썸네일 캐싱
- 메시지 배치 처리

## ✅ 체크리스트

### 구현 완료
- [ ] ChatRepository 인터페이스
- [ ] MessageRepository 인터페이스
- [ ] GroupChatRepository 인터페이스
- [ ] Repository 구현체
- [ ] Mixin 클래스들
- [ ] 에러 처리 로직

### 테스트
- [ ] 단위 테스트
- [ ] 통합 테스트
- [ ] Mock Repository 구현

## 📚 참고 자료

- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dartz Package](https://pub.dev/packages/dartz)

---

*이 문서는 Feature-First Architecture의 Chat Repository Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*