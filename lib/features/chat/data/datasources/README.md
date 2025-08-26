# 📦 /lib/features/chat/data/datasources

> Feature-First Architecture - Chat Data Source 계층

## 📋 개요

채팅 기능의 **Data Source Layer**를 담당하는 디렉토리입니다. Remote(Firebase)와 Local(Cache) 데이터 소스를 구현하여 Repository에 데이터를 제공합니다.

### 🎯 목적
- **Firebase 통합**: Firestore, Storage, Functions와의 직접 통신
- **로컬 캐싱**: Hive, Memory Cache를 통한 성능 최적화
- **실시간 동기화**: WebSocket/Stream 기반 실시간 업데이트
- **오프라인 지원**: 로컬 데이터베이스를 통한 오프라인 모드

## 🏗️ 디렉토리 구조

```
datasources/
├── remote/                               # Remote 데이터 소스
│   ├── firebase_chat_datasource.dart    # Firebase 채팅 데이터
│   ├── firestore_message_datasource.dart # Firestore 메시지
│   ├── firebase_auth_datasource.dart    # Firebase 인증
│   └── cloud_functions_datasource.dart  # Cloud Functions 호출
│
├── local/                                # Local 데이터 소스
│   ├── chat_local_datasource.dart       # 채팅 로컬 저장소
│   ├── message_cache_datasource.dart    # 메시지 캐시
│   ├── hive_chat_datasource.dart        # Hive DB
│   └── memory_cache_datasource.dart     # 메모리 캐시
│
└── interfaces/                           # Data Source 인터페이스
    ├── chat_datasource.dart              # 채팅 데이터소스 인터페이스
    └── message_datasource.dart           # 메시지 데이터소스 인터페이스
```

## 📂 Remote Data Sources

### 1. FirebaseChatDatasource

**책임**: Firebase Firestore를 통한 채팅 데이터 접근

**주요 메서드**:
- `getChatListStream(userId)`: 사용자의 채팅 목록 실시간 스트림
- `createChat(participantIds, metadata)`: 새 채팅방 생성
- `deleteChat(chatId)`: 채팅방 및 메시지 삭제
- `updateLastMessage(chatId, lastMessage, timestamp)`: 마지막 메시지 업데이트
- `markAsRead(chatId, userId)`: 읽음 처리
- `addParticipants(chatId, userIds)`: 참여자 추가

**Firestore 컬렉션 구조**:
- `/chats`: 채팅방 문서
- `/chats/{chatId}/messages`: 메시지 서브컬렉션

**의존성**: FirebaseFirestore

### 2. FirestoreMessageDatasource

**책임**: Firestore를 통한 메시지 데이터 관리

**주요 메서드**:
- `getMessagesStream(chatId, limit)`: 메시지 실시간 스트림 (최신순, 페이지네이션)
- `sendMessage(message)`: 메시지 전송 및 채팅방 업데이트
- `editMessage(chatId, messageId, newContent)`: 메시지 수정
- `deleteMessage(chatId, messageId)`: 메시지 삭제 (소프트 삭제)
- `loadMoreMessages(chatId, lastMessage, limit)`: 추가 메시지 로드
- `submitVote(chatId, messageId, option, userId)`: 투표 제출

**배치 작업**:
- 메시지 추가
- 채팅방 마지막 메시지 업데이트
- 읽지 않은 메시지 카운트 증가

**트랜잭션 사용**:
- 투표 제출 시 중복 방지

### 3. CloudFunctionsDatasource

**책임**: Cloud Functions 호출 데이터소스

**주요 메서드**:
- `createVoteCard(chatId, voteData)`: 투표 카드 생성 Function 호출
- `generateAIResponse(chatId, message, userId)`: AI 응답 생성
- `sendNotification(recipientId, notification)`: 알림 전송

**Cloud Functions**:
- `createVoteCard`: 투표 카드 생성 및 알림 발송
- `generateAIResponse`: Genkit AI 응답 생성
- `sendNotification`: FCM 푸시 알림

**에러 처리**: FirebaseFunctionsException 캐치 및 변환

## 📂 Local Data Sources

### 1. ChatLocalDatasource

**책임**: Hive를 사용한 채팅 로컬 저장소

**주요 메서드**:
- `init()`: Hive Box 초기화
- `saveChatList(chats)`: 채팅 목록 저장
- `getChatList(userId)`: 사용자별 채팅 목록 조회
- `saveChat(chat)`: 단일 채팅 저장
- `getChat(chatId)`: 단일 채팅 조회
- `deleteChat(chatId)`: 채팅 삭제
- `updateReadStatus(chatId, userId)`: 읽음 상태 업데이트
- `clearCache()`: 캐시 클리어
- `getCacheSize()`: 캐시 크기 확인

**Hive Box**: 'chats' Box에 Map<dynamic, dynamic> 형태로 저장

### 2. MessageCacheDatasource

**책임**: UnifiedCacheService를 통한 메시지 캐싱

**주요 메서드**:
- `cacheMessages(chatId, messages)`: 메시지 리스트 캐싱
- `getCachedMessages(chatId)`: 캐시된 메시지 조회
- `addMessage(message)`: 단일 메시지 추가 (중복 방지)
- `updateMessage(message)`: 메시지 업데이트
- `deleteMessage(chatId, messageId)`: 메시지 삭제
- `invalidateCache(chatId)`: 특정 채팅 캐시 무효화
- `clearAllMessageCache()`: 모든 메시지 캐시 클리어

**캐시 키 패턴**: `messages_{chatId}`

**의존성**: UnifiedCacheService (3-Layer 캐싱)

### 3. HiveChatDatasource

**책임**: Hive 기반 영구 저장소

**주요 기능**:
1. **메시지 영구 저장**:
   - `persistMessages(chatId, messages)`: 메시지 영구 저장
   - `loadPersistedMessages(chatId)`: 저장된 메시지 로드

2. **임시 저장 (Draft)**:
   - `saveDraft(chatId, draft)`: 임시 메시지 저장
   - `getDraft(chatId)`: 임시 메시지 불러오기
   - `deleteDraft(chatId)`: 임시 메시지 삭제

3. **오프라인 큐**:
   - `addToOfflineQueue(message)`: 오프라인 메시지 큐 추가
   - `getOfflineQueue()`: 오프라인 큐 조회
   - `clearOfflineQueue()`: 오프라인 큐 클리어

**Hive Boxes**:
- `messages`: 메시지 영구 저장
- `drafts`: 임시 메시지 저장

### 4. MemoryCacheDatasource

**책임**: LRU 기반 메모리 캐시 관리

**주요 기능**:
1. **채팅 캐시**:
   - `cacheChat(chat)`: 채팅 캐싱
   - `getChat(chatId)`: 채팅 조회
   - `invalidateChat(chatId)`: 채팅 캐시 무효화

2. **메시지 캐시**:
   - `cacheMessages(chatId, messages)`: 메시지 캐싱
   - `getMessages(chatId)`: 메시지 조회
   - `invalidateMessages(chatId)`: 메시지 캐시 무효화

3. **캐시 관리**:
   - `clearAll()`: 전체 캐시 클리어
   - `getStats()`: 캐시 통계 조회

**LRU 설정**:
- 최대 채팅 캐시: 100개
- 최대 메시지 캐시: 1000개
- TTL: 5분

**특징**:
- LRU (Least Recently Used) 알고리즘
- TTL 기반 만료 처리
- 접근 순서 추적

## 🔄 Data Source 인터페이스

### ChatDatasource Interface

**채팅 데이터소스 인터페이스**

**메서드**:
- `getChatListStream(userId)`: 채팅 목록 스트림
- `createChat(participantIds, metadata)`: 채팅방 생성
- `deleteChat(chatId)`: 채팅방 삭제
- `updateLastMessage(chatId, lastMessage, timestamp)`: 마지막 메시지 업데이트
- `markAsRead(chatId, userId)`: 읽음 처리

### MessageDatasource Interface

**메시지 데이터소스 인터페이스**

**메서드**:
- `getMessagesStream(chatId, limit)`: 메시지 스트림
- `sendMessage(message)`: 메시지 전송
- `editMessage(chatId, messageId, newContent)`: 메시지 수정
- `deleteMessage(chatId, messageId)`: 메시지 삭제
- `loadMoreMessages(chatId, lastMessage, limit)`: 추가 메시지 로드

## 🧪 테스트 전략

### Mock Data Sources

**테스트용 Mock 데이터소스**

**MockFirebaseChatDatasource**:
- 메모리 기반 채팅 데이터 저장
- StreamController를 통한 실시간 스트림 시뮬레이션
- 채팅 생성/삭제 기능 구현

**테스트 시나리오**:
- 성공 케이스 테스트
- 실패 케이스 테스트
- 스트림 업데이트 테스트

## ⚠️ 주의사항

### 1. 실시간 동기화
- Stream 기반 데이터 흐름 유지
- WebSocket 연결 상태 모니터링
- 자동 재연결 메커니즘

### 2. 캐시 일관성
- Remote/Local 데이터 동기화
- 캐시 무효화 전략
- TTL 기반 만료 처리

### 3. 오프라인 지원
- 오프라인 큐 관리
- 로컬 우선 읽기
- 네트워크 복구 시 자동 동기화

### 4. 성능 최적화
- 배치 작업 활용
- 페이지네이션 구현
- 메모리 캐시 크기 제한

## ✅ 체크리스트

### 구현 완료
- [ ] FirebaseChatDatasource
- [ ] FirestoreMessageDatasource
- [ ] CloudFunctionsDatasource
- [ ] ChatLocalDatasource
- [ ] MessageCacheDatasource
- [ ] HiveChatDatasource
- [ ] MemoryCacheDatasource

### 테스트
- [ ] Remote 데이터소스 테스트
- [ ] Local 데이터소스 테스트
- [ ] 캐시 일관성 테스트
- [ ] 오프라인 모드 테스트

## 📚 참고 자료

- [Firestore Best Practices](https://firebase.google.com/docs/firestore/best-practices)
- [Hive Documentation](https://docs.hivedb.dev/)
- [Stream API Documentation](https://api.dart.dev/stable/dart-async/Stream-class.html)

---

*이 문서는 Feature-First Architecture의 Chat Data Source Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*