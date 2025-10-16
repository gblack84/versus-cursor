# 📦 /lib/features/chat/data/services

> Feature-First Architecture - Chat Service 계층
> 최종 업데이트: 2025-01-16

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

### 1. ChatMessageService (통합 변환 서비스)

**책임**: Firestore/Entity → flutter_chat_ui Message 변환

**Clean Architecture v4.0 통합**:
- ✅ DocumentSnapshot → core.Message 변환 (기존)
- ✅ Message Entity → core.Message 변환 (v4.0 추가)
- ✅ 타입별 자동 변환 (Text, Custom, Image, System)

**주요 메서드**:

**DocumentSnapshot 변환** (기존):
- `convertDocumentToMessage(doc)`: 단일 문서 변환
- `convertDocumentsToMessages(docs)`: 배치 변환 (병렬 처리)

**Message Entity 변환** (v4.0):
- `convertEntityToMessage(entity)`: 단일 Entity 변환
- `convertEntitiesToMessages(entities)`: 배치 변환

**타입별 변환 헬퍼**:
- `_createVoteMessage()`: 투표 카드 (CustomMessage)
- `_createVoteMessageFromEntity()`: Entity → 투표 카드
- `_createImageMessage()`: 이미지 (ImageMessage)
- `_createImageMessageFromEntity()`: Entity → 이미지

**메시지 타입 지원**:
- **TextMessage**: 일반 텍스트, 첨부파일 메타데이터
- **CustomMessage**: 투표 카드 (voteTitle, voteOptions, voteResults 등)
- **ImageMessage**: 이미지 (source, size, width, height)
- **SystemMessage**: 시스템 메시지 (읽지 않은 메시지 구분선 등)

**사용처**:
- ChatDetailProvider._updateDisplayMessages()
- AIChatProvider._updateDisplayMessages()

**통합 효과**:
- 140줄 중복 TextMessage 변환 로직 제거
- 1줄 서비스 호출로 모든 타입 자동 처리
- 투표 카드, 이미지, 시스템 메시지 렌더링 복원

**의존성**: Message Entity, flutter_chat_core, AppConstants

### 2. ChatMessageLifecycleService (메시지 상태 관리)

**책임**: 메시지 읽음/전달 상태 관리 (카카오톡 스타일)

**Clean Architecture v4.0 통합**:
- ✅ ChatDetailProvider와 연결 완료
- ✅ 채팅방 진입 시 자동 읽음 처리
- ✅ 배치 업데이트를 통한 성능 최적화

**주요 메서드**:
- `markMessagesAsSeen(chatId, currentUserId)`: 채팅방 메시지 자동 읽음 처리
- `updateLastReadAt(chatId, userId)`: 마지막 읽음 시간 업데이트
- `getUnreadCount(chatId, userId)`: 읽지 않은 메시지 개수 조회
- `watchMessageStatuses(chatId, messageIds)`: 메시지 상태 실시간 스트림

**메시지 상태 타입**:
- **sent**: 전송됨
- **delivered**: 전달됨
- **seen**: 읽음

**사용처**:
- ChatDetailProvider.initializeChat() - 채팅방 진입 시 자동 호출

**통합 효과**:
- 카카오톡 스타일 메시지 읽음 처리 구현
- 배치 업데이트로 Firestore 쓰기 최적화
- 본인이 보낸 메시지는 자동 제외 처리
- 읽지 않은 메시지 카운트 추적 기반 마련

**의존성**: Firestore, Message Entity, Singleton Pattern

**구현 방식**:
```dart
// ChatDetailProvider에서 자동 호출
_lifecycleService.markMessagesAsSeen(
  chatId: chatId,
  currentUserId: currentUserId,
);
```

### 3. ChatFileSizeService (파일 크기 관리)

**책임**: 채팅 미디어 파일 크기 계산 및 검증

**Clean Architecture v4.0 통합**:
- ✅ ChatMediaUploadService와 연결 완료
- ✅ 안전한 파일 크기 조회 (에러 처리 내장)
- ✅ 사용자 친화적 크기 포맷 (B/KB/MB/GB)

**주요 메서드**:
- `getLocalFileSize(path)`: 로컬 파일 크기 조회 (에러 처리 포함)
- `checkFileSize(file, maxSize)`: 파일 크기 검증 (커스텀 제한)
- `getStorageFileSize(url)`: Firebase Storage URL에서 크기 조회
- `calculateMediaSize(url)`: URL/로컬 경로 자동 감지
- `formatFileSize(bytes)`: 사람이 읽기 쉬운 포맷 변환
- `extractStoragePathFromUrl(url)`: Storage URL 파싱

**사용처**:
- ChatMediaUploadService.uploadChatImage() - 이미지 압축 후 크기 검증
- ChatMediaUploadService.uploadChatVideo() - 비디오 크기 검증 (압축 없음)

**통합 효과**:
- 에러 처리 강화 (try-catch 내장)
- 더 명확한 에러 메시지 (실제 크기 표시)
- 파일 크기 로직 중앙화
- 사용자 친화적 크기 표시 (예: "3.2 MB")
- **압축 후 검증**으로 사용자 경험 개선 (5-13MB 원본 사진 허용)

**의존성**: Firebase Storage, Singleton Pattern

**검증 전략**:

1. **이미지 업로드** - 압축 후 검증:
```dart
// 1. 먼저 압축 (항상 실행)
final compressedImage = await _compressImage(imageFile);

// 2. 압축 후 크기 체크
final fileSizeService = ChatFileSizeService();
if (compressedImage.length > maxImageSize) {
  final formattedSize = fileSizeService.formatFileSize(compressedImage.length);
  throw Exception(
    '압축 후에도 이미지 크기($formattedSize)가 2MB를 초과합니다.\n'
    '다른 이미지를 선택하거나 이미지를 편집해주세요.'
  );
}

// ✅ 효과: 5-13MB 원본 사진도 압축 후 통과 가능
```

2. **비디오 업로드** - 압축 전 검증 (비디오는 압축 안 함):
```dart
final fileSizeService = ChatFileSizeService();
final isValidSize = await fileSizeService.checkFileSize(
  videoFile,
  maxSizeInBytes: maxVideoSize,
);

if (!isValidSize) {
  throw Exception(
    '비디오 크기가 10MB를 초과합니다.\n'
    '비디오는 압축되지 않으므로 10MB 이하 파일만 업로드 가능합니다.'
  );
}
```

### 4. ChatScrollService (스크롤 제어)

**책임**: 채팅 스크롤 동작 제어 및 상태 추적

**Clean Architecture v4.1 통합**:
- ✅ ChatDetailProvider와 연결 완료
- ✅ 검색 결과 자동 스크롤 기능
- ✅ 명시적 스크롤 제어 지원

**주요 메서드**:
- `scrollToBottom()`: 최신 메시지로 스크롤
- `updateScrollState(atBottom, nearBottom)`: 스크롤 상태 업데이트
- `setupScrollListener(onScrollChanged)`: 스크롤 리스너 설정
- `checkIfAtBottom()`: 하단 도달 여부 확인 (50px 기준)
- `checkIfNearBottom()`: 하단 근접 여부 확인 (200px 기준)

**스크롤 상태 추적**:
- `isAtBottom`: 현재 하단에 있는지 여부
- `isNearBottom`: 하단 근처에 있는지 여부
- `scrollController`: ScrollController 인스턴스

**사용처**:
- ChatDetailProvider - 검색 결과 자동 스크롤
- ChatDetailProvider.goToNextSearchResult() - 다음 검색 결과 이동
- ChatDetailProvider.goToPreviousSearchResult() - 이전 검색 결과 이동

**통합 효과**:
- 검색 결과 자동 스크롤 구현
- 명시적 스크롤 제어 지원 (알림, 멘션 등)
- 스크롤 상태 기반 UI 제어 가능

**의존성**: ChatDetailControllerV2

**구현 방식**:
```dart
// ChatDetailProvider 생성자에서 초기화
_scrollService = ChatScrollService(_chatController);

// 검색 결과로 스크롤
final firstResultId = _searchResultIds.first;
_chatController.scrollToMessage(firstResultId);

// 다음/이전 검색 결과 이동
void goToNextSearchResult() {
  _currentSearchIndex = (_currentSearchIndex + 1) % _searchResultIds.length;
  final nextResultId = _searchResultIds[_currentSearchIndex];
  _chatController.scrollToMessage(nextResultId);
  notifyListeners();
}
```

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
- [x] UnifiedCacheService
- [x] PreloadStrategy
- [x] ChatInitializationService
- [x] ChatMessageService (Clean Architecture v4.0 통합)
- [x] ChatMessageLifecycleService (ChatDetailProvider 연결)
- [x] ChatFileSizeService (ChatMediaUploadService 연결)
- [x] ChatScrollService (검색 기능 완성, ChatDetailProvider 연결)
- [x] VoteStateCoordinator
- [x] GlobalNotificationManager

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
*최종 업데이트: 2025-01-20*