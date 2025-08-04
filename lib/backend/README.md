# Backend Integration

Versus Space 앱의 백엔드 통합 레이어입니다. Firebase 및 외부 서비스와의 모든 통신을 관리합니다.

## 📋 디렉토리 구조

```
backend/
├── schema/                 # Firestore 데이터 모델
│   ├── users_model.dart
│   ├── posts_model.dart
│   ├── messages_model.dart
│   ├── notifications_model.dart
│   ├── chats_model.dart
│   └── util/              # 스키마 유틸리티
├── firebase/              # Firebase 설정 및 초기화
│   ├── firebase_config.dart
│   └── firebase.dart
├── firebase_storage/      # Firebase Storage 관리
│   └── storage.dart
├── algolia/              # Algolia 검색 통합
│   └── algolia_manager.dart
├── api_requests/         # 외부 API 호출
│   └── api_calls.dart
└── query/               # Firestore 쿼리 헬퍼
    └── query_util.dart
```

## 주요 컴포넌트

### 1. Schema (데이터 모델)

Firestore 컬렉션과 1:1 매핑되는 데이터 모델들입니다.

#### 핵심 모델
- **UsersModel**: 사용자 프로필 및 설정
- **PostsModel**: A vs B 게시물 (투표 시스템 포함)
- **MessagesModel**: 채팅 메시지 (투표 카드 지원)
- **NotificationsModel**: 알림 (JSON 파싱 지원)
- **ChatsModel**: 채팅방 정보

자세한 내용은 [schema/README.md](./schema/README.md) 참조

### 2. Firebase 통합 (/firebase)

#### 초기화
```dart
// firebase_config.dart
await initFirebase();
```

#### 설정 내용
- **프로젝트 ID**: versus-space-1lwwiw
- **지원 플랫폼**: iOS, Android, Web, macOS
- **서비스**: Auth, Firestore, Storage, Functions, Performance

#### 보안 규칙
```javascript
// Firestore Rules 예시
match /posts/{post} {
  allow read: if true;
  allow create: if request.auth != null;
  allow update: if request.auth.uid == resource.data.userid;
  allow delete: if false;
}
```

### 3. Firebase Storage (/firebase_storage)

파일 업로드 및 관리를 담당합니다.

```dart
// 이미지 업로드
final downloadUrl = await uploadData(
  'posts/images/${timestamp}_${uid}.jpg',
  imageBytes,
);

// 파일 삭제
await deleteData(downloadUrl);

// 메타데이터 설정
await uploadDataWithMetadata(
  path: 'videos/${filename}',
  data: videoBytes,
  metadata: {
    'userId': currentUser.uid,
    'uploadTime': DateTime.now().toIso8601String(),
  },
);
```

**저장소 구조:**
```
/posts
  /images         # 게시물 이미지
  /videos         # 게시물 비디오
/users
  /profiles       # 프로필 사진
  /characters     # 캐릭터 이미지
/chat
  /images         # 채팅 이미지
  /videos         # 채팅 비디오
```

### 4. Algolia 검색 (/algolia)

고급 검색 기능을 제공합니다.

```dart
// 검색 매니저 초기화
AlgoliaManager.instance.init(
  appId: 'YOUR_APP_ID',
  searchApiKey: 'YOUR_SEARCH_KEY',
);

// 게시물 검색
final results = await AlgoliaManager.instance.search(
  index: 'posts',
  query: '커피',
  filters: 'category:음식',
  hitsPerPage: 20,
);

// 사용자 검색
final users = await AlgoliaManager.instance.searchUsers(
  query: '홍길동',
  filters: 'interests:게임',
);
```

**인덱스 구조:**
- `posts`: 게시물 검색
- `users`: 사용자 검색
- `comments`: 댓글 검색

### 5. API 요청 (/api_requests)

외부 API와의 통신을 관리합니다.

```dart
// API 호출 예시
final response = await ApiCallManager.instance.makeApiCall(
  callName: 'CheckContent',
  apiUrl: 'https://api.perspective.com/v1/comments:analyze',
  callType: ApiCallType.POST,
  headers: {
    'Content-Type': 'application/json',
  },
  params: {
    'text': userInput,
    'requestedAttributes': {
      'TOXICITY': {},
      'PROFANITY': {},
    },
  },
  returnBody: true,
);
```

**통합된 API:**
- Perspective API (텍스트 검열)
- Google Cloud Vision (이미지 검열)
- Gemini AI (콘텐츠 검증)

### 6. 쿼리 유틸리티 (/query)

Firestore 쿼리를 위한 헬퍼 함수들입니다.

```dart
// 페이지네이션 쿼리
Query<Map<String, dynamic>> pageQuery = FirebaseFirestore.instance
  .collection('posts')
  .orderBy('created_at', descending: true)
  .limit(20);

// 다음 페이지
pageQuery = pageQuery.startAfterDocument(lastDocument);

// 복합 쿼리
final query = FirebaseFirestore.instance
  .collection('posts')
  .where('category', isEqualTo: 'sports')
  .where('vote_count', isGreaterThan: 100)
  .orderBy('vote_count', descending: true)
  .limit(10);
```

## 실시간 업데이트

### StreamBuilder 패턴
```dart
StreamBuilder<List<PostsModel>>(
  stream: queryPostsRecord(
    queryBuilder: (postsRecord) => postsRecord
      .where('userid', isEqualTo: currentUserUid)
      .orderBy('created_at', descending: true),
    limit: 20,
  ),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    
    final posts = snapshot.data!;
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(post: post);
      },
    );
  },
)
```

### 실시간 리스너
```dart
// 채팅 메시지 리스너
StreamSubscription? _messageSubscription;

void startListeningToMessages(String chatId) {
  _messageSubscription = FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .orderBy('time_stamp', descending: true)
    .snapshots()
    .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // 새 메시지 처리
          handleNewMessage(change.doc);
        }
      }
    });
}

// 정리
void dispose() {
  _messageSubscription?.cancel();
}
```

## 트랜잭션 처리

### 원자적 업데이트
```dart
// 투표 처리 트랜잭션
Future<void> voteOnPost(String postId, String choice) async {
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final postRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId);
    
    final postDoc = await transaction.get(postRef);
    final postData = postDoc.data()!;
    
    // 중복 투표 확인
    final votedUsersA = List<String>.from(postData['voted_user_ids_a'] ?? []);
    final votedUsersB = List<String>.from(postData['voted_user_ids_b'] ?? []);
    
    if (votedUsersA.contains(currentUserUid) || 
        votedUsersB.contains(currentUserUid)) {
      throw Exception('이미 투표했습니다');
    }
    
    // 투표 업데이트
    if (choice == 'A') {
      transaction.update(postRef, {
        'votes_a': FieldValue.increment(1),
        'voted_user_ids_a': FieldValue.arrayUnion([currentUserUid]),
        'total_votes': FieldValue.increment(1),
      });
    } else {
      transaction.update(postRef, {
        'votes_b': FieldValue.increment(1),
        'voted_user_ids_b': FieldValue.arrayUnion([currentUserUid]),
        'total_votes': FieldValue.increment(1),
      });
    }
  });
}
```

## 오프라인 지원

### 캐싱 설정
```dart
// Firestore 오프라인 지속성 활성화
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 네트워크 상태 처리
```dart
// 네트워크 상태 감지
StreamBuilder<ConnectivityResult>(
  stream: Connectivity().onConnectivityChanged,
  builder: (context, snapshot) {
    if (snapshot.data == ConnectivityResult.none) {
      return OfflineBanner();
    }
    return Container();
  },
)
```

## 성능 최적화

### 1. 쿼리 최적화
- 필요한 필드만 선택
- 적절한 인덱스 생성
- 페이지네이션 사용

### 2. 캐싱 전략
- 이미지 캐싱 (CachedNetworkImage)
- 데이터 캐싱 (SharedPreferences)
- 메모리 캐싱 (Provider)

### 3. 배치 처리
```dart
// 배치 쓰기
final batch = FirebaseFirestore.instance.batch();

for (var item in items) {
  final docRef = FirebaseFirestore.instance
    .collection('items')
    .doc();
  batch.set(docRef, item.toJson());
}

await batch.commit();
```

## 에러 처리

### 일반적인 에러
```dart
try {
  await someFirestoreOperation();
} on FirebaseException catch (e) {
  switch (e.code) {
    case 'permission-denied':
      showToast('권한이 없습니다');
      break;
    case 'unavailable':
      showToast('서버에 연결할 수 없습니다');
      break;
    default:
      showToast('오류가 발생했습니다');
  }
}
```

## 마이그레이션 노트

### 2025-07-31: 컬렉션 이름 정규화
- 모든 `_record` 접미사 제거
- 예: `users_record` → `users`
- Flutter와 Firebase Functions 통일

### 2025-08-03: 필드 동기화
- 37개 필드 추가/수정
- 투표 시스템 필드 완성
- 멀티이미지 지원 추가

## 최근 문제 해결 (2025-08-03)

### AI 채팅 메시지 표시 문제
**문제**: Firebase Functions에서 AI 채팅 메시지를 생성하지만 Flutter 앱에 표시되지 않음

**원인 분석**:
1. Firebase Functions 로그 확인 결과 메시지는 정상 생성됨
2. 채팅방 ID: `ai_assistant_userId` 형식으로 생성
3. Flutter 쿼리가 AI 채팅방을 제대로 가져오지 못함

**해결 방법**:
```dart
// AI 채팅방 쿼리 수정
Stream<List<ChatsModel>> getAIChats() {
  return FirebaseFirestore.instance
    .collection('chats')
    .where('participantIds', arrayContains: currentUser.uid)
    .where('chat_type', isEqualTo: 'ai_chat')
    .snapshots()
    .map((snapshot) => snapshot.docs
        .map((doc) => ChatsModel.fromDocument(doc))
        .toList());
}
```

### 투표 권한 오류
**문제**: `[cloud_firestore/permission-denied]` 투표 시 권한 오류 발생

**해결**: Firebase Security Rules 수정
```javascript
// 이전 (오류 발생)
&& !(request.auth.uid in resource.data.votedUserIDsA)
&& !(request.auth.uid in resource.data.votedUserIDsB)

// 수정 후 (필드 존재 여부 확인)
&& (
  (!('votedUserIDsA' in resource.data) || !(request.auth.uid in resource.data.votedUserIDsA))
  && (!('votedUserIDsB' in resource.data) || !(request.auth.uid in resource.data.votedUserIDsB))
)
```

### 테스트 함수 추가
AI 채팅 메시지 수동 생성을 위한 테스트 함수 배포:
```bash
# 사용 예시
curl -X POST https://asia-northeast3-versus-space-1lwwiw.cloudfunctions.net/testCreateAIChatMessage \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "사용자ID",
    "postId": "게시물ID",
    "messageType": "request" // 또는 "created"
  }'
```

## 향후 개선 사항

1. **GraphQL 통합**
   - 효율적인 데이터 페칭
   - 실시간 구독

2. **캐싱 레이어**
   - Redis 통합
   - 응답 시간 개선

3. **분석 통합**
   - Firebase Analytics
   - 커스텀 이벤트 추적