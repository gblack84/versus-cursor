# Chat Services Layer

## Overview

채팅 시스템의 비즈니스 로직과 데이터 관리를 담당하는 서비스 레이어입니다. Firebase Firestore와의 통신, 메시지 상태 관리, 파일 처리 등의 핵심 기능을 제공합니다.

## Services

### 1. ChatMessageLifecycleService

**파일**: `chat_message_lifecycle_service.dart`

**목적**: 메시지 전송, 배달, 읽음 상태를 관리하는 핵심 서비스

**싱글톤 패턴**:
```dart
static final ChatMessageLifecycleService _instance = ChatMessageLifecycleService._internal();
factory ChatMessageLifecycleService() => _instance;
```

**주요 메서드**:

#### `markMessagesAsSeen`
채팅방 입장 시 읽지 않은 메시지를 모두 읽음 처리
```dart
Future<void> markMessagesAsSeen({
  required String chatId,
  required String currentUserId,
})
```

#### `markMessageAsDelivered`
메시지 배달 상태 업데이트
```dart
Future<void> markMessageAsDelivered({
  required String chatId,
  required String messageId,
})
```

#### `getMessageStatus`
특정 메시지의 현재 상태 조회
```dart
Future<MessageDeliveryStatus> getMessageStatus({
  required String chatId,
  required String messageId,
})
```

#### `watchMessageStatuses`
메시지 상태 변경을 실시간으로 감지
```dart
Stream<Map<String, MessageDeliveryStatus>> watchMessageStatuses({
  required String chatId,
  List<String>? messageIds,
})
```

**상태 열거형**:
```dart
enum MessageDeliveryStatus {
  sent,      // 메시지 전송됨
  delivered, // 서버 도달
  seen,      // 읽음
  unknown,   // 알 수 없음
}
```

### 2. ChatInitializationService

**파일**: `chat_initialization_service.dart`

**목적**: 채팅방 초기화 및 설정 관리

**주요 기능**:
- 채팅방 데이터 초기 로드
- 참여자 정보 캐싱
- 메시지 스트림 설정
- 캐시 데이터 프리로드

**사용 예시**:
```dart
final initService = ChatInitializationService();
await initService.initializeChat(
  chatId: 'chat_123',
  userId: 'user_456',
);
```

### 3. ChatMessageService

**파일**: `chat_message_service.dart`  

**목적**: 메시지 처리 및 변환 서비스

**주요 기능**:
- Firestore ↔ flutter_chat_ui 메시지 변환
- 메시지 타입별 처리 로직
- 투표 카드 메시지 특별 처리
- 메시지 정렬 및 필터링

**메시지 변환**:
```dart
// Firestore → flutter_chat_ui
final uiMessage = ChatMessageService.convertToUIMessage(firestoreDoc);

// flutter_chat_ui → Firestore
final firestoreData = ChatMessageService.convertToFirestore(uiMessage);
```

### 4. ChatScrollService

**파일**: `chat_scroll_service.dart`

**목적**: 채팅 스크롤 동작 관리

**주요 기능**:
- 스크롤 위치 추적
- 새 메시지 도착 시 자동 스크롤
- 스크롤 투 바텀 기능
- 무한 스크롤 페이지네이션

**스크롤 제어**:
```dart
final scrollService = ChatScrollService();
scrollService.scrollToBottom();
scrollService.scrollToMessage(messageId);
```

### 5. ChatAnimationService

**파일**: `chat_animation_service.dart`

**목적**: 채팅 UI 애니메이션 처리

**주요 기능**:
- 메시지 진입 애니메이션
- 타이핑 인디케이터 애니메이션
- 읽음 상태 전환 애니메이션
- 투표 카드 펼치기/접기 애니메이션

### 6. ChatMediaUploadService

**파일**: `chat_media_upload_service.dart`

**목적**: 미디어 파일 업로드 관리

**주요 기능**:
- 이미지/비디오 압축
- Firebase Storage 업로드
- 썸네일 생성
- 업로드 진행률 추적

**업로드 플로우**:
```dart
final uploadService = ChatMediaUploadService();
final urls = await uploadService.uploadMedia(
  file: imageFile,
  onProgress: (progress) => print('$progress%'),
);
```

### 7. ChatFileSizeService

**파일**: `chat_file_size_service.dart`

**목적**: 파일 업로드 전 크기 검증 및 제한 관리

**주요 기능**:
- 파일 크기 제한 검증
- 지원 파일 형식 확인
- 압축 옵션 제공

**제한사항**:
- 이미지: 최대 10MB
- 비디오: 최대 100MB
- 문서: 최대 25MB

## Firebase Integration

### Firestore 쿼리 최적화

**메시지 로딩**:
```dart
FirebaseFirestore.instance
  .collection('chats')
  .doc(chatId)
  .collection('messages')
  .orderBy('created_at', descending: true)
  .limit(50)
  .snapshots()
```

**읽지 않은 메시지 조회**:
```dart
.where('sender_id', isNotEqualTo: currentUserId)
.where('seen_at', isNull: true)
```

### 배치 작업

읽음 상태 업데이트 시 배치 작업으로 성능 최적화:
```dart
final batch = _firestore.batch();
for (final doc in messagesQuery.docs) {
  batch.update(doc.reference, {
    'seen_at': FieldValue.serverTimestamp(),
  });
}
await batch.commit();
```

## Firebase Functions 연동

### `markMessagesAsSeen` Function
- **트리거**: HTTP 호출
- **역할**: 채팅방 입장 시 서버 사이드 읽음 처리
- **엔드포인트**: `/markMessagesAsSeen`

### `onMessageCreated` Function
- **트리거**: Firestore onCreate
- **역할**: 새 메시지 생성 시 처리
- **경로**: `chats/{chatId}/messages/{messageId}`

## Error Handling

```dart
try {
  await markMessagesAsSeen(chatId: chatId, currentUserId: userId);
} catch (e) {
  print('Error marking messages as seen: $e');
  // 사용자에게 에러 표시하지 않음 (UX 고려)
}
```

## Performance Considerations

1. **스트림 구독 관리**
   - dispose() 시 모든 구독 취소
   - 메모리 누수 방지

2. **쿼리 최적화**
   - 필요한 필드만 선택
   - 적절한 인덱스 사용
   - 페이지네이션 구현

3. **캐싱 전략**
   - 최근 메시지 로컬 캐싱
   - 이미지 캐싱 (UnifiedImageCacheService)

## Testing

```dart
// Unit test example
test('markMessagesAsSeen updates all unread messages', () async {
  final service = ChatMessageLifecycleService();
  await service.markMessagesAsSeen(
    chatId: 'test_chat',
    currentUserId: 'test_user',
  );
  
  // Verify all messages are marked as seen
  final status = await service.getMessageStatus(
    chatId: 'test_chat',
    messageId: 'test_message',
  );
  
  expect(status, equals(MessageDeliveryStatus.seen));
});
```

## Usage Example

```dart
class ChatDetailWidget extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _lifecycleService = ChatMessageLifecycleService();
    
    // 채팅방 입장 시 메시지 읽음 처리
    _lifecycleService.markMessagesAsSeen(
      chatId: widget.chatId,
      currentUserId: currentUser.id,
    );
    
    // 실시간 상태 업데이트 구독
    _statusSubscription = _lifecycleService
      .watchMessageStatuses(chatId: widget.chatId)
      .listen((statuses) {
        setState(() {
          _messageStatuses = statuses;
        });
      });
  }
  
  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }
}
```

## Future Enhancements

- [ ] 메시지 전송 큐 시스템
- [ ] 오프라인 지원
- [ ] 읽음 확인 비활성화 옵션
- [ ] 그룹 채팅 읽음 상태
- [ ] 메시지 암호화
- [ ] 미디어 파일 자동 압축

## Related Documentation

- [Chat System Architecture](../README.md)
- [Firebase Functions](../../../../firebase/functions/README.md)
- [Migration Guide](../MIGRATION_STATUS.md)