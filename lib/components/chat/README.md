# 채팅 시스템 아키텍처

## 개요

Versus Space 채팅 시스템은 `flutter_chat_ui`를 기반으로 구축된 현대적인 메시징 시스템입니다. 텍스트, 이미지, 비디오, 그리고 A vs B 투표 메시지를 지원합니다.

## 기술 스택

### Flutter 패키지
- **flutter_chat_ui**: ^1.6.15 - 프로페셔널한 채팅 UI
- **flutter_chat_types**: ^3.6.2 - 타입 정의
- **flutter_link_previewer**: ^3.2.2 - 링크 미리보기
- **wechat_assets_picker**: ^9.5.1 - 갤러리 선택
- **wechat_camera_picker**: ^5.0.1 - 카메라 촬영
- **flutter_image_compress**: ^2.3.0 - 이미지 압축
- **video_thumbnail**: ^0.5.3 - 비디오 썸네일

### Firebase 백엔드
- **Firestore**: 메시지 저장 및 실시간 동기화
- **Firebase Storage**: 미디어 파일 저장
- **Cloud Functions**: 투표 메시지 생성

## 아키텍처

### 1. 메시지 타입

```dart
// Firestore messages_record 필드
{
  'id': String,
  'chat_ref': DocumentReference,
  'sender_ref': DocumentReference,
  'content': String,
  'sent_time': Timestamp,
  'is_read': bool,
  'messageType': String, // 'text', 'image', 'video', 'vote_request'
  
  // 미디어 메시지 필드
  'mediaType': String?,
  'imageUrl': String?,
  'videoUrl': String?,
  'thumbnailUrl': String?,
  'mediaSize': int?,
  'mediaWidth': int?,
  'mediaHeight': int?,
  
  // 투표 메시지 필드
  'votePostId': String?,
  'voteTitle': String?,
  'voteDescription': String?,
  'voteOptionA': String?,
  'voteOptionB': String?,
  'voteImageA': String?,
  'voteImageB': String?,
  'voteStatus': String?, // 'pending', 'completed', 'expired'
}
```

### 2. 주요 컴포넌트

#### ChatMessageConverter
메시지 변환 유틸리티 - Firestore 메시지를 flutter_chat_types로 변환

```dart
// 사용 예시
final chatMessage = ChatMessageConverter.fromFirestore(
  firestoreMessage,
  currentUser,
);
```

#### ChatMediaUploadService
미디어 업로드 서비스 - 이미지/비디오 압축 및 업로드

```dart
// 이미지 업로드
final result = await ChatMediaUploadService.uploadChatImage(
  chatId: chatId,
  messageId: messageId,
  imageFile: file,
);

// 비디오 업로드
final result = await ChatMediaUploadService.uploadChatVideo(
  chatId: chatId,
  messageId: messageId,
  videoFile: file,
);
```

#### VoteRequestMessage
투표 요청 메시지 위젯 - A vs B 형식의 투표 UI

```dart
VoteRequestMessage(
  postId: postId,
  title: title,
  description: description,
  optionAText: optionA,
  optionBText: optionB,
  optionAImage: imageA,
  optionBImage: imageB,
  voteStatus: status,
  isMe: isMe,
  timestamp: timestamp,
  onTap: () => navigateToVoting(postId),
)
```

### 3. 채팅 플로우

#### 텍스트 메시지
1. 사용자가 메시지 입력
2. `messages_record`에 저장
3. 실시간 리스너로 상대방에게 전달

#### 이미지/비디오 메시지
1. 미디어 선택 (갤러리/카메라)
2. 파일 압축 및 썸네일 생성
3. Firebase Storage 업로드
4. URL과 함께 메시지 저장
5. 상대방에게 실시간 전달

#### 투표 메시지
1. 투표 알림 전송 시 자동 생성
2. Cloud Functions에서 채팅방 찾기/생성
3. 투표 메시지 타입으로 저장
4. 채팅 목록과 알림 오버레이에 동시 표시

## 구현 세부사항

### 1. 채팅 화면 초기화

```dart
class ChatDetailWidget extends StatefulWidget {
  final ChatsRecord chatRecord;
  final DocumentReference otherUserRef;
  
  @override
  _ChatDetailWidgetState createState() => _ChatDetailWidgetState();
}

class _ChatDetailWidgetState extends State<ChatDetailWidget> {
  late types.User _user;
  late types.User _otherUser;
  
  @override
  void initState() {
    super.initState();
    _initializeUsers();
  }
  
  void _initializeUsers() {
    _user = types.User(
      id: currentUserReference!.id,
      firstName: currentUserDisplayName,
      imageUrl: currentUserPhoto,
    );
    
    // 상대방 정보 로드
    _loadOtherUser();
  }
}
```

### 2. 메시지 스트림 구성

```dart
Widget _buildMessagesList() {
  return StreamBuilder<List<MessagesRecord>>(
    stream: queryMessagesRecord(
      parent: widget.chatRecord.reference,
      queryBuilder: (q) => q.orderBy('sent_time', descending: true),
    ),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }
      
      final messages = snapshot.data!
          .map((msg) => ChatMessageConverter.fromFirestore(msg, currentUserReference!))
          .toList();
      
      return Chat(
        messages: messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: _getChatTheme(),
        onAttachmentPressed: _handleAttachmentPressed,
        customMessageBuilder: _customMessageBuilder,
        l10n: _getKoreanL10n(),
      );
    },
  );
}
```

### 3. 미디어 첨부 처리

```dart
void _handleAttachmentPressed() async {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('갤러리에서 사진 선택'),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          ListTile(
            leading: Icon(Icons.camera),
            title: Text('카메라로 사진 촬영'),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: Icon(Icons.videocam),
            title: Text('비디오 선택'),
            onTap: () => _pickVideo(),
          ),
        ],
      ),
    ),
  );
}
```

### 4. 커스텀 메시지 렌더링

```dart
Widget _customMessageBuilder(types.CustomMessage message, {required int messageWidth}) {
  final metadata = message.metadata ?? {};
  
  if (metadata['type'] == 'vote_request') {
    return VoteRequestMessage(
      postId: metadata['postId'] ?? '',
      title: metadata['title'] ?? '',
      description: metadata['description'] ?? '',
      optionAText: metadata['optionA'] ?? '',
      optionBText: metadata['optionB'] ?? '',
      optionAImage: metadata['imageA'],
      optionBImage: metadata['imageB'],
      voteStatus: metadata['status'] ?? 'pending',
      isMe: message.author.id == currentUserReference?.id,
      timestamp: DateTime.fromMillisecondsSinceEpoch(message.createdAt ?? 0),
      onTap: () => _navigateToVotingPage(metadata['postId']),
    );
  }
  
  return SizedBox.shrink();
}
```

## Firebase Functions 통합

### 투표 메시지 생성 함수

```javascript
async function createVoteRequestChatMessage(senderId, recipientId, postId, postData) {
  const db = admin.firestore();
  
  // 1. 채팅방 찾기 또는 생성
  let chatRef = await findOrCreateChat(senderId, recipientId);
  
  // 2. 투표 메시지 생성
  const messageData = {
    chat_ref: chatRef,
    sender_ref: db.doc(`users_record/${senderId}`),
    content: `📊 ${postData.question || '투표 요청'}`,
    sent_time: admin.firestore.FieldValue.serverTimestamp(),
    is_read: false,
    messageType: 'vote_request',
    
    // 투표 관련 필드
    votePostId: postId,
    voteTitle: postData.question || '',
    voteDescription: postData.description || '',
    voteOptionA: postData.title_a || '',
    voteOptionB: postData.title_b || '',
    voteImageA: postData.imagea?.length > 0 ? postData.imagea[0] : null,
    voteImageB: postData.imageb?.length > 0 ? postData.imageb[0] : null,
    voteStatus: 'pending',
  };
  
  await chatRef.collection('messages').add(messageData);
  
  // 3. 채팅방 마지막 메시지 업데이트
  await chatRef.update({
    last_message: messageData.content,
    last_message_time: admin.firestore.FieldValue.serverTimestamp(),
  });
}
```

## 스타일링 및 테마

### 채팅 테마 설정

```dart
DarkChatTheme _getChatTheme() {
  return DarkChatTheme(
    backgroundColor: Colors.black,
    inputBackgroundColor: const Color(0xFF1C1C1E),
    inputTextColor: Colors.white,
    inputTextStyle: VersusTextStyles.bodyMedium,
    messageBorderRadius: 20,
    primaryColor: VersusColors.primary,
    receivedMessageBodyTextStyle: VersusTextStyles.bodyMedium.copyWith(
      color: Colors.white,
    ),
    sentMessageBodyTextStyle: VersusTextStyles.bodyMedium.copyWith(
      color: Colors.white,
    ),
    userAvatarNameColors: [
      VersusColors.primary,
      VersusColors.secondary,
    ],
  );
}
```

### 한국어 지원

```dart
ChatL10nKo _getKoreanL10n() {
  return const ChatL10nKo(
    attachmentButtonAccessibilityLabel: '미디어 전송',
    emptyChatPlaceholder: '아직 메시지가 없습니다',
    fileButtonAccessibilityLabel: '파일',
    inputPlaceholder: '메시지를 입력하세요...',
    sendButtonAccessibilityLabel: '전송',
    unreadMessagesLabel: '읽지 않은 메시지',
  );
}
```

## 성능 최적화

### 1. 이미지 압축
- 업로드 전 이미지를 800px로 리사이즈
- JPEG 품질 85%로 압축
- 평균 70% 파일 크기 감소

### 2. 비디오 처리
- 자동 썸네일 생성
- 프로그레시브 다운로드 지원
- 스트리밍 재생 가능

### 3. 메시지 페이징
- 초기 50개 메시지 로드
- 스크롤 시 추가 로드
- 메모리 효율적 관리

## 최근 업데이트 (v2.0.0)

### 2025-08-06: 시스템 통합
- **컬렉션 이름 정규화**: `messages_record` → `messages`, `chats_record` → `chats`
- **AI 채팅 ID 형식 통일**: `ai_assistant_userId` 형식으로 표준화
- **투표 카드 메시지 개선**: 
  - 멀티이미지 지원 (`vote_option_a_images[]`, `vote_option_b_images[]`)
  - 실시간 상태 업데이트 (`card_status`, `vote_end_time`)
  - 개별 투표 추적 (`user_votes` Map)

## 향후 개선사항

1. **읽음 확인 기능**
   - 메시지별 읽음 상태 표시
   - 실시간 읽음 확인 업데이트

2. **타이핑 인디케이터**
   - 상대방 입력 중 표시
   - 실시간 상태 동기화

3. **메시지 반응**
   - 이모지 리액션
   - 답장 기능

4. **음성 메시지**
   - 음성 녹음 및 전송
   - 재생 컨트롤

5. **메시지 검색**
   - 채팅 내 검색
   - 미디어 필터링

## 트러블슈팅

### 일반적인 문제

1. **이미지가 표시되지 않음**
   - Firebase Storage 권한 확인
   - 이미지 URL 유효성 검증
   - 네트워크 연결 상태 확인

2. **메시지 순서 문제**
   - Firestore 타임스탬프 동기화
   - 클라이언트 시간 오프셋 보정

3. **채팅방 로딩 지연**
   - 인덱스 최적화
   - 초기 로드 메시지 수 조정

---

**작성일**: 2025-07-26  
**최종 업데이트**: 2025-08-06  
**버전**: 1.1  
**작성자**: SuperClaude Framework  