# 📦 /lib/features/chat/data/services

> Feature-First Architecture - Chat Service 계층
> 최종 업데이트: 2025-08-25

## 📋 개요

채팅 기능의 **Service Layer**를 담당하는 디렉토리입니다. 비즈니스 로직, 캐싱, 미디어 처리, 실시간 동기화 등 도메인 간 조정을 담당합니다.

### 🎯 목적
- **비즈니스 로직 캡슐화**: 복잡한 업무 규칙 구현
- **크로스 도메인 조정**: 여러 Repository/DataSource 조율
- **성능 최적화**: 캐싱, 배치 처리, 프리로딩
- **실시간 처리**: WebSocket, Stream 관리

## 🏗️ 디렉토리 구조

```
services/
├── cache/                                # 캐싱 서비스
│   ├── unified_cache_service.dart      # 3-Layer 캐시 통합
│   ├── simple_memory_cache.dart        # L1 메모리 캐시
│   ├── cache_statistics.dart           # 캐시 통계
│   └── preload_strategy.dart           # 프리로딩 전략
│
├── chat/                                # 채팅 관련 서비스
│   ├── chat_message_service.dart       # 메시지 관리
│   ├── chat_message_lifecycle_service.dart # 메시지 라이프사이클
│   ├── chat_scroll_service.dart        # 스크롤 동작
│   ├── chat_animation_service.dart     # 애니메이션
│   ├── chat_media_upload_service.dart  # 미디어 업로드
│   ├── chat_image_cache_service.dart   # 이미지 캐싱
│   ├── chat_file_size_service.dart     # 파일 크기 관리
│   └── gemini_ai_service.dart          # Gemini AI 서비스
│
├── vote/                                # 투표 관련 서비스
│   ├── vote_state_coordinator.dart     # 투표 상태 조정
│   ├── vote_timer_service.dart         # 투표 타이머
│   ├── vote_status_service.dart        # 투표 상태 관리
│   └── vote_validation_service.dart    # 투표 유효성 검증
│
└── notification/                        # 알림 서비스
    ├── global_notification_manager.dart # 전역 알림 관리
    ├── notification_service.dart       # 알림 처리
    └── target_audience_service.dart    # 타겟 오디언스
```

## 📂 캐싱 서비스

### 1. UnifiedCacheService (3-Layer 캐싱)

**책임**: 3-Layer 캐싱 시스템 통합 관리

**아키텍처**:
- **L1**: Memory Cache (LRU) - 100개 제한, 5분 TTL
- **L2**: Hive Local DB - 영구 저장소
- **L3**: Firestore Offline Cache - 무제한 크기

**주요 메서드**:
- `init()`: 캐시 시스템 초기화
- `get<T>(key)`: 3-Layer 순차 검색
- `set<T>(key, data, ttl)`: 모든 레이어에 저장
- `invalidate(key)`: 특정 키 캐시 무효화
- `invalidatePattern(pattern)`: 패턴 기반 무효화
- `clear()`: 전체 캐시 클리어
- `getStatistics()`: 캐시 통계 조회

**캐시 전략**:
- 캐시 히트 시 상위 레이어로 프로모션
- 손상된 데이터 자동 제거
- 패턴 매칭을 통한 일괄 무효화

**의존성**: MemoryCacheDatasource, CacheStatistics, Hive

### 2. PreloadStrategy (프리로딩 전략)

**책임**: 프리로딩 전략 구현 및 관리

**주요 메서드**:
- `preloadRecentChats(userId)`: 최근 10개 채팅방 프리로드
- `preloadChatMessages(chatId)`: 채팅 메시지 프리로드 (15개)
- `preloadPopularPosts()`: 인기 포스트 관련 채팅 프리로드
- `preloadAIChatRooms()`: AI 채팅방 프리로드
- `preloadUserData(userIds)`: 사용자 데이터 프리로드

**프리로딩 전략**:
- 최근 채팅 우선 로드
- 100ms 간격으로 순차 로드 (메인 스레드 부하 방지)
- 캐시 히트 시 스킵
- AI 채팅방 자동 프리로드

**의존성**: ChatRepository, MessageRepository, UnifiedCacheService

## 📂 채팅 서비스

### 1. ChatMessageService

**책임**: 채팅 메시지 관리 및 처리

**주요 메서드**:
- `sendMessage(chatId, content, senderId, mediaUrl, type, metadata)`: 메시지 전송
- `subscribeToMessages(chatId, limit)`: 메시지 스트림 구독
- `loadMoreMessages(chatId, lastMessage, limit)`: 추가 메시지 로드
- `editMessage(chatId, messageId, newContent)`: 메시지 수정
- `deleteMessage(chatId, messageId)`: 메시지 삭제
- `createVoteCard(chatId, voteOptions, voteDuration)`: 투표 카드 생성

**주요 기능**:
- 중복 메시지 ID 필터링
- 메시지 캐시 관리
- 실시간 스트림 처리
- 캐시 무효화 전략

**의존성**: MessageRepository, UnifiedCacheService

## 📂 투표 서비스

### VoteStateCoordinator

**책임**: 투표 상태 통합 조정 및 관리

**주요 메서드**:
- `initializeVote(postId, voteEndTime, chatId)`: 투표 초기화
- `submitVote(postId, option, userId, chatId, messageId)`: 투표 제출
- `completeVote(postId)`: 투표 완료 처리
- `getVoteStateStream(postId)`: 투표 상태 스트림
- `dispose()`: 리소스 정리

**주요 기능**:
- 타이머와 상태 서비스 통합 관리
- 중복 투표 방지
- 실시간 투표 상태 스트림
- 투표 완료 자동 처리

**의존성**: VoteTimerService, VoteStatusService, MessageRepository

**반환 타입**: VoteState
- postId: String
- status: VoteStatus
- remainingTime: Duration?
- isCompleted: bool

## 📂 알림 서비스

### GlobalNotificationManager

**책임**: 전역 알림 관리 및 큐 처리

**주요 속성**:
- `notificationStream`: 알림 브로드캐스트 스트림

**주요 메서드**:
- `addNotification(notification)`: 알림 큐에 추가
- `closeNotification(notificationId)`: 알림 닫기
- `recordUserResponse(notificationId, response, metadata)`: 사용자 응답 기록
- `dispose()`: 리소스 정리

**큐 처리 로직**:
- 우선순위 기반 정렬 (urgent > high > normal > low)
- 순차적 알림 표시
- 자동 닫기 타이머 (30초 기본값)
- 500ms 간격으로 다음 알림 표시

**의존성**: NotificationModel

## 🧪 테스트 전략

### Service Layer 테스트

**테스트 카테고리**:
1. **캐싱 서비스 테스트**:
   - 3-Layer 캐시 히트율 측정
   - 캐시 무효화 검증
   - 프리로딩 전략 효과 측정

2. **채팅 서비스 테스트**:
   - 채팅방 초기화 성공/실패
   - 메시지 중복 필터링
   - 실시간 스트림 처리

3. **투표 서비스 테스트**:
   - 중복 투표 방지
   - 타이머 동기화
   - 상태 전환 검증

4. **알림 서비스 테스트**:
   - 우선순위 정렬
   - 큐 처리 순서
   - 자동 닫기 타이머

**Mock 객체**:
- MockChatRepository
- MockMessageRepository
- MockVoteTimerService
- MockVoteStatusService

## ⚠️ 주의사항

### 1. 서비스 레이어 책임
- 비즈니스 로직만 포함
- UI 로직 배제
- Repository 패턴 준수

### 2. 성능 최적화
- 캐시 전략 적용
- 병렬 처리 활용
- 메모리 관리

### 3. 에러 처리
- Either 패턴 활용
- 적절한 에러 전파
- 사용자 친화적 메시지

## ✅ 체크리스트

### 구현 완료
- [ ] UnifiedCacheService
- [ ] PreloadStrategy
- [ ] ChatInitializationService
- [ ] ChatMessageService
- [ ] VoteStateCoordinator
- [ ] GlobalNotificationManager

### 테스트
- [ ] 단위 테스트
- [ ] 통합 테스트
- [ ] 성능 테스트
- [ ] 캐시 효율성 테스트

## 📚 참고 자료

- [Service Layer Pattern](https://martinfowler.com/eaaCatalog/serviceLayer.html)
- [Caching Strategies](https://aws.amazon.com/caching/best-practices/)
- [Dart Streams](https://dart.dev/tutorials/language/streams)

---

*이 문서는 Feature-First Architecture의 Chat Service Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*