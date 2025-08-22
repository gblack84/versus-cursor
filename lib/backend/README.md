# Backend Module - 백엔드 통합 레이어

Versus Space 앱의 모든 백엔드 서비스와 데이터 관리를 담당하는 핵심 모듈입니다.

## 📋 개요

이 모듈은 Firebase 생태계(Firestore, Storage, Authentication)와 외부 서비스(Algolia, API)의 통합을 관리합니다. 모든 데이터 모델, 저장소, 검색, API 통신을 중앙에서 조율하여 일관된 백엔드 인터페이스를 제공합니다.

### 핵심 특징
- **Firebase 완전 통합**: Auth, Firestore, Storage, Functions
- **43개 데이터 모델**: 완전한 타입 안전성과 null safety
- **실시간 동기화**: Firestore 실시간 리스너와 스트림
- **고급 검색**: Algolia 통합으로 빠른 전문 검색
- **외부 API 통합**: HTTP 클라이언트와 다양한 API 지원
- **오프라인 지원**: Firestore 캐싱과 오프라인 지속성

## 🎯 네이밍 컨벤션

### 파일명
- **모든 파일**: snake_case (`api_calls.dart`, `firebase_config.dart`)
- **디렉토리**: snake_case (`firebase_storage`, `api_requests`)

### 코드 컨벤션
- **Firestore 필드**: camelCase (`userId`, `createdAt`, `voteStatus`)
- **Dart 변수/메서드**: camelCase (`getUserData()`, `isLoggedIn`)
- **클래스**: PascalCase (`ApiManager`, `UsersModel`)
- **상수**: UPPER_SNAKE_CASE 또는 camelCase

참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/
├── README.md                    # 이 문서
├── backend.dart                 # 백엔드 모듈 export
├── algolia/                     # Algolia 검색 엔진 ✅
│   ├── algolia_manager.dart    # 검색 매니저
│   ├── serializers.dart        # 데이터 직렬화
│   └── README.md               # 244줄 문서
├── api_requests/                # HTTP API 클라이언트 ✅
│   ├── api_calls.dart          # API 호출 정의
│   ├── api_manager.dart        # HTTP 클라이언트
│   ├── api_requests_util.dart  # 유틸리티
│   └── README.md               # 382줄 문서
├── firebase/                    # Firebase 초기화 ✅
│   ├── firebase_config.dart    # 설정 및 초기화
│   └── README.md               # 250줄 문서
├── firebase_storage/            # Firebase Storage ✅
│   ├── storage.dart            # 파일 업로드/다운로드
│   └── README.md               # 257줄 문서
├── push_notifications/          # 푸시 알림
│   └── push_notifications_handler.dart
├── query/                       # Firestore 쿼리 유틸
│   └── query_util.dart         # 쿼리 헬퍼
├── schema/                      # Firestore 데이터 모델 ✅
│   ├── [43개 모델 파일]        # 데이터 모델들
│   ├── index.dart              # Export 파일
│   ├── util/                   # 유틸리티 ✅
│   │   ├── firestore_util.dart # Firestore 변환
│   │   ├── schema_util.dart    # 스키마 유틸
│   │   └── README.md           # 404줄 문서
│   └── README.md               # 435줄 문서
└── supabase/                    # Supabase (미사용)
    └── supabase.dart
```

## 🔧 주요 구성요소

### 1. Schema - Firestore 데이터 모델 (✅ 완전 문서화)

**43개 모델**이 Firestore 컬렉션과 1:1 매핑되어 완벽한 타입 안전성을 제공합니다.

#### 핵심 모델 카테고리
- **사용자**: `UsersModel`, `CharactersModel`, `FriendsListModel`, `PremiumUsersModel`
- **콘텐츠**: `PostsModel`, `CommentsModel`, `UserContentsModel`, `LikesModel`
- **채팅**: `ChatsModel`, `MessagesModel`, `GroupChatsModel`
- **투표**: `VotesModel`, `VotecountsModel`, `VoteExpansionRequestsModel`
- **알림**: `NotificationsModel`, `NotificationModel`
- **미디어**: `ImagesModel`, `VideoModel`, `EncodingsModel`

#### 모델 아키텍처
```dart
// 모든 모델이 상속하는 기반 클래스
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);
  final DocumentReference reference;
  Map<String, dynamic> snapshotData;
}

// 사용 예시
final user = await UsersModel.getDocumentOnce(userRef);
print('User: ${user.displayName}, Points: ${user.pointsA}');
```

📖 **상세 문서**: [schema/README.md](./schema/README.md) (435줄)

### 2. Firebase 초기화 (✅ 완전 문서화)

Firebase 서비스 초기화와 플랫폼별 설정을 관리합니다.

#### 지원 서비스
- **Authentication**: 7가지 인증 방식
- **Firestore**: 실시간 데이터베이스
- **Storage**: 파일 저장소
- **Functions**: 서버리스 함수 (12개 배포)
- **Performance**: 성능 모니터링

#### 초기화 코드
```dart
import 'firebase/firebase_config.dart';

// 앱 시작 시 호출
await initFirebase();
```

📖 **상세 문서**: [firebase/README.md](./firebase/README.md) (250줄)

### 3. Firebase Storage (✅ 완전 문서화)

파일 업로드, 다운로드, 관리를 담당합니다.

#### 주요 기능
```dart
// 파일 업로드
String? downloadUrl = await uploadData(
  'posts/images/${timestamp}.jpg',
  imageBytes
);

// MIME 타입 자동 감지
// 지원: 이미지(jpg,png,gif,webp), 비디오(mp4,mov,avi), 문서(pdf,doc)
```

#### 저장소 구조
```
/users/{userId}/         # 사용자 콘텐츠
  profile/              # 프로필 이미지
  uploads/              # 사용자 업로드
/posts/                 # 게시물 미디어
  images/              # 이미지
  videos/              # 비디오
  thumbnails/          # 썸네일
```

📖 **상세 문서**: [firebase_storage/README.md](./firebase_storage/README.md) (257줄)

### 4. Algolia 검색 (✅ 완전 문서화)

고급 검색 기능과 위치 기반 검색을 제공합니다.

#### 검색 유형
- **텍스트 검색**: 키워드 기반 전문 검색
- **위치 기반 검색**: 좌표와 반경 설정
- **하이브리드 검색**: 텍스트 + 위치 조합

#### 사용 예시
```dart
// 텍스트 검색
final results = await AlgoliaManager.instance.search(
  'posts',
  query: '커피',
  searchType: SearchType.query,
  maxResults: 20,
);

// 위치 기반 검색
final nearbyPosts = await AlgoliaManager.instance.search(
  'posts',
  location: LatLng(37.5665, 126.9780),
  searchRadiusInMiles: 5,
  searchType: SearchType.geo,
);
```

📖 **상세 문서**: [algolia/README.md](./algolia/README.md) (244줄)

### 5. API Requests (✅ 완전 문서화)

외부 API와의 통신을 관리하는 HTTP 클라이언트입니다.

#### 지원 기능
- **모든 HTTP 메서드**: GET, POST, PUT, PATCH, DELETE
- **다양한 바디 타입**: JSON, Form, Multipart, Text
- **인증**: Bearer 토큰, API 키
- **캐싱**: 응답 캐싱 메커니즘

#### 통합된 API
```dart
// Perspective API - 텍스트 검열
final toxicity = await ApiCallManager.makeApiCall(
  callName: 'CheckToxicity',
  apiUrl: 'https://api.perspective.com/v1/comments:analyze',
  callType: ApiCallType.POST,
  // ...
);

// 비디오 인코딩 서비스
final encodingUrl = await EncoderGroup.getUploadUrlCall(
  filename: 'video.mp4',
  userToken: authToken,
);
```

📖 **상세 문서**: [api_requests/README.md](./api_requests/README.md) (382줄)

### 6. Query 유틸리티

Firestore 쿼리를 위한 헬퍼 함수들입니다.

#### 주요 기능
```dart
// 페이지네이션
Query<Map<String, dynamic>> paginatedQuery(
  Query query,
  {DocumentSnapshot? lastDoc, int limit = 20}
) {
  if (lastDoc != null) {
    return query.startAfterDocument(lastDoc).limit(limit);
  }
  return query.limit(limit);
}

// 실시간 스트림
Stream<List<T>> queryCollection<T>(
  Query query,
  T Function(DocumentSnapshot) fromSnapshot,
) {
  return query.snapshots().map((snapshot) =>
    snapshot.docs.map(fromSnapshot).toList()
  );
}
```

### 7. Push Notifications

FCM을 통한 푸시 알림 처리를 담당합니다.

#### 기능
- 토큰 관리
- 알림 권한 요청
- 포그라운드/백그라운드 처리
- 딥링크 라우팅

## 🚀 사용 예시

### 데이터 읽기/쓰기
```dart
// 사용자 프로필 읽기
final user = await UsersModel.getDocumentOnce(
  FirebaseFirestore.instance.doc('users/$userId')
);

// 게시물 생성
final postData = createPostsModelData(
  userId: currentUserUid,
  questionTitle: '커피 vs 차',
  optionA: {'text': '커피', 'imageUrl': coffeeUrl},
  optionB: {'text': '차', 'imageUrl': teaUrl},
  voteStartTime: DateTime.now(),
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
);

await FirebaseFirestore.instance
  .collection('posts')
  .add(postData);
```

### 실시간 업데이트
```dart
// 채팅 메시지 스트림
StreamBuilder<List<MessagesModel>>(
  stream: FirebaseFirestore.instance
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .orderBy('timeStamp', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => MessagesModel.fromDocument(doc))
      .toList()),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return LoadingIndicator();
    
    final messages = snapshot.data!;
    return MessageList(messages: messages);
  },
);
```

### 트랜잭션 처리
```dart
// 원자적 투표 처리
Future<void> voteOnPost(String postId, VoteChoice choice) async {
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    final postRef = FirebaseFirestore.instance
      .collection('posts')
      .doc(postId);
    
    final postDoc = await transaction.get(postRef);
    if (!postDoc.exists) throw Exception('Post not found');
    
    final post = PostsModel.fromDocument(postDoc);
    
    // 중복 투표 검증
    if (post.votedUserIdsA.contains(currentUserUid) ||
        post.votedUserIdsB.contains(currentUserUid)) {
      throw Exception('Already voted');
    }
    
    // 투표 업데이트
    final field = choice == VoteChoice.A ? 'votesA' : 'votesB';
    final userField = choice == VoteChoice.A 
      ? 'votedUserIdsA' : 'votedUserIdsB';
    
    transaction.update(postRef, {
      field: FieldValue.increment(1),
      userField: FieldValue.arrayUnion([currentUserUid]),
      'totalVotes': FieldValue.increment(1),
    });
  });
}
```

## 📊 데이터 플로우

### 읽기 플로우
```
Firestore Document
    ↓
DocumentSnapshot
    ↓
mapFromFirestore() [util]
    ↓
Model Instance
    ↓
UI Component
```

### 쓰기 플로우
```
User Input
    ↓
Validation
    ↓
createModelData()
    ↓
mapToFirestore() [util]
    ↓
Firestore Document
```

### 검색 플로우
```
Search Query
    ↓
AlgoliaManager
    ↓
Algolia Index
    ↓
Result Serialization
    ↓
Model Instances
```

## ⚡ 성능 최적화

### 쿼리 최적화
- **인덱스 활용**: 복합 인덱스로 쿼리 성능 향상
- **페이지네이션**: 대량 데이터 점진적 로드
- **필드 선택**: 필요한 필드만 가져오기

### 캐싱 전략
- **Firestore 오프라인 캐시**: 자동 오프라인 지원
- **이미지 캐싱**: CachedNetworkImage 사용
- **API 응답 캐싱**: 메모리 캐시로 중복 요청 방지

### 배치 처리
```dart
// 여러 문서 동시 업데이트
final batch = FirebaseFirestore.instance.batch();

items.forEach((item) {
  final docRef = collection.doc(item.id);
  batch.update(docRef, item.toJson());
});

await batch.commit();
```

## 🔒 보안 고려사항

### Firestore 보안 규칙
```javascript
// 읽기: 모든 사용자
// 쓰기: 인증된 사용자만
match /posts/{post} {
  allow read: if true;
  allow create: if request.auth != null;
  allow update: if request.auth.uid == resource.data.userId;
  allow delete: if false;
}
```

### Storage 보안 규칙
```javascript
// 사용자별 저장소 격리
match /users/{userId}/{allPaths=**} {
  allow read: if request.auth != null;
  allow write: if request.auth.uid == userId;
}
```

### API 키 관리
- 환경 변수 사용
- 키 로테이션
- 최소 권한 원칙

## 🐛 문제 해결

### 일반적인 에러

#### Permission Denied
```dart
// 권한 오류 처리
try {
  await firestoreOperation();
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    showError('권한이 없습니다. 로그인을 확인해주세요.');
  }
}
```

#### 네트워크 오류
```dart
// 오프라인 상태 처리
if (snapshot.hasError && !snapshot.hasData) {
  return OfflineWidget();
}
```

#### 타입 캐스팅 오류
```dart
// 안전한 타입 변환
final value = castToType<int>(data['field']) ?? 0;
```

## 🔗 관련 문서

### 하위 모듈 문서
- [Schema 모듈 (435줄)](./schema/README.md) - Firestore 데이터 모델
- [Schema Util (404줄)](./schema/util/README.md) - 데이터 변환 유틸리티
- [Firebase 초기화 (250줄)](./firebase/README.md) - Firebase 설정
- [Firebase Storage (257줄)](./firebase_storage/README.md) - 파일 저장소
- [Algolia 검색 (244줄)](./algolia/README.md) - 검색 엔진
- [API Requests (382줄)](./api_requests/README.md) - HTTP 클라이언트

### 프로젝트 문서
- [전체 프로젝트 구조](../../README.md)
- [네이밍 컨벤션](../../NAMING_CONVENTION.md)
- [아키텍처](../../ARCHITECTURE.md)

## 📝 변경 이력

- **2025-08-22**: 문서 전면 개정, 6개 하위 모듈 통합 문서화
- **2025-08-21**: snake_case → camelCase 완전 마이그레이션
- **2025-08-03**: 필드 동기화, 투표 시스템 통합
- **2025-07-31**: 컬렉션명 정규화 (_record 제거)
- **초기**: Backend 모듈 구현

---

*이 문서는 `/lib/backend` 디렉토리의 백엔드 통합 레이어를 설명합니다.*
*총 2,372줄의 하위 문서를 통합하여 작성되었습니다.*