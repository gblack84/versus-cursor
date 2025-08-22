# Schema Module - Firestore Data Models

Versus Space 앱의 Firestore 데이터 모델을 정의하고 관리하는 핵심 모듈입니다.

## 📋 개요

이 디렉토리는 Versus Space 애플리케이션의 모든 Firestore 데이터 모델을 포함합니다. 각 모델은 Firestore 문서와 Flutter 객체 간의 양방향 데이터 변환을 처리하며, 타입 안전성과 null safety를 보장합니다.

### 핵심 특징
- **43개 데이터 모델**: 완전한 앱 기능을 위한 포괄적인 모델 세트
- **FirestoreRecord 상속**: 모든 모델이 공통 기반 클래스 상속
- **타입 안전성**: 강력한 타입 체크와 null safety 지원
- **자동 직렬화**: Firestore ↔ Flutter 자동 변환
- **Backward Compatibility**: 레거시 필드명 지원

## 🎯 네이밍 컨벤션

### 파일명
- **모델 파일**: snake_case (`users_model.dart`, `posts_model.dart`)
- **유틸리티**: snake_case (`firestore_util.dart`, `schema_util.dart`)
- **인덱스**: snake_case (`index.dart`)

### 필드명 (2025-08-21 완전 마이그레이션)
- **Firestore 필드**: camelCase (`userId`, `createdAt`, `voteStartTime`)
- **Dart 변수**: camelCase (`displayName`, `photoUrl`, `lastActive`)
- **메서드**: camelCase (`hasUserId()`, `getDocumentOnce()`)
- **클래스**: PascalCase (`UsersModel`, `PostsModel`)

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
lib/backend/schema/
├── README.md                    # 이 문서
├── index.dart                   # 공통 export와 의존성
├── util/                        # 유틸리티 모듈
│   ├── firestore_util.dart     # Firestore 변환 유틸리티
│   ├── schema_util.dart        # 스키마 타입 변환
│   └── README.md               # 유틸리티 문서
└── [43개 모델 파일]            # 데이터 모델들
```

## 🔧 주요 구성요소

### 1. 모델 아키텍처

#### FirestoreRecord 기반 클래스
모든 모델이 상속하는 추상 기반 클래스:

```dart
abstract class FirestoreRecord {
  FirestoreRecord(this.reference, this.snapshotData);
  
  final DocumentReference reference;
  Map<String, dynamic> snapshotData;
  
  // 공통 메서드들
  static Stream<T> getDocument<T>(DocumentReference ref);
  static Future<T?> getDocumentOnce<T>(DocumentReference ref);
}
```

#### 모델 구조 패턴
```dart
class ExampleModel extends FirestoreRecord {
  ExampleModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }
  
  // 필드 정의
  String? _fieldName;
  String get fieldName => _fieldName ?? '';
  bool hasFieldName() => _fieldName != null;
  
  // 초기화 메서드
  void _initializeFields() {
    _fieldName = castToType<String>(snapshotData['fieldName']);
  }
  
  // 팩토리 메서드
  static ExampleModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) => ExampleModel._(reference, data);
}
```

### 2. 핵심 모델 카테고리

#### 사용자 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `UsersModel` | 사용자 프로필 | uid, email, displayName, pointsA/Q, interests |
| `CharactersModel` | 아바타 정보 | characterId, userId, avatarUrl |
| `FriendsListModel` | 친구 관계 | userId, friendId, status, createdAt |
| `PremiumUsersModel` | 프리미엄 구독 | userId, subscriptionType, expiresAt |

#### 콘텐츠 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `PostsModel` | 게시물 | userId, questionTitle, optionA/B, votes, voteStatus |
| `CommentsModel` | 댓글 | postId, userId, content, likes, dislikes |
| `UserContentsModel` | 사용자 콘텐츠 | userId, contentType, polls, feeds |
| `LikesModel` | 좋아요 | userId, postId, timestamp |
| `DislikesModel` | 싫어요 | userId, postId, timestamp |

#### 채팅 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `ChatsModel` | 채팅방 | participantIds, lastMessage, chatType |
| `MessagesModel` | 메시지 | senderId, content, messageType, voteCard |
| `GroupChatsModel` | 그룹 채팅 | groupName, memberIds, adminId |
| `GroupMessagesModel` | 그룹 메시지 | groupId, senderId, content |

#### 투표 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `VotesModel` | 투표 정보 | postId, userId, choice, votedAt |
| `VotecountsModel` | 투표 집계 | postId, votesA, votesB, totalVotes |
| `VoteExpansionRequestsModel` | 투표 확장 요청 | postId, requesterId, reason |

#### 알림 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `NotificationsModel` | 알림 | userId, type, content, status, priority |
| `NotificationModel` | 개별 알림 설정 | userId, pushEnabled, emailEnabled |

#### 미디어 관련 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `ImagesModel` | 이미지 메타데이터 | imageUrl, thumbnailUrl, dimensions |
| `VideoModel` | 비디오 메타데이터 | videoUrl, duration, thumbnail |
| `EncodingsModel` | 인코딩 상태 | videoId, status, progress, formats |
| `ImageModerationModel` | 이미지 검열 | imageUrl, status, moderationResults |

#### 분류 및 검색 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `InterestModel` | 관심사 카테고리 | name, weight, category |
| `JopsCategoryModel` | 직업 카테고리 | categoryName, parentId |
| `JopsNameModel` | 직업명 | jobName, categoryId, description |
| `SearchesModel` | 검색 기록 | userId, query, timestamp, results |

#### 기타 모델
| 모델명 | 용도 | 주요 필드 |
|--------|------|-----------|
| `PointModel` | 포인트 거래 | userId, amount, type, description |
| `RankingsModel` | 순위표 | userId, rank, score, category |
| `RankedPostsModel` | 인기 게시물 | postId, rank, score, period |
| `TransactionsModel` | 거래 내역 | userId, amount, type, status |
| `SettingsModel` | 앱 설정 | userId, preferences, theme |
| `ClientModel` | 클라이언트 정보 | clientId, platform, version |

### 3. Util 서브모듈

#### firestore_util.dart
Firestore와 Flutter 간 데이터 변환 핵심 유틸리티:
- `mapFromFirestore()`: Firestore → Flutter 변환
- `mapToFirestore()`: Flutter → Firestore 변환
- `mergeNestedFields()`: 점 표기법 필드 처리
- GeoPoint ↔ LatLng 변환 Extension

#### schema_util.dart
스키마 타입 변환과 구조체 빌더:
- `convertAlgoliaStruct()`: Algolia 검색 결과 변환
- `getStructList()`: 구조체 리스트 변환
- `getSchemaColor()`: 색상 값 처리
- `getDataList()`: 제네릭 리스트 변환

## 🚀 사용 예시

### 모델 생성 및 초기화
```dart
// 새 사용자 생성
final userData = createUsersModelData(
  uid: 'user123',
  email: 'user@example.com',
  displayName: 'John Doe',
  interests: ['Flutter', 'Firebase'],
  pointsA: 100,
  pointsQ: 50,
);

// Firestore에 저장
await FirebaseFirestore.instance
    .collection('users')
    .doc('user123')
    .set(userData);
```

### 데이터 읽기
```dart
// 단일 문서 읽기
final userDoc = await UsersModel.getDocumentOnce(
  FirebaseFirestore.instance.doc('users/user123')
);

if (userDoc != null) {
  print('User: ${userDoc.displayName}');
  print('Points: A=${userDoc.pointsA}, Q=${userDoc.pointsQ}');
}

// 실시간 스트림
final userStream = UsersModel.getDocument(
  FirebaseFirestore.instance.doc('users/user123')
);

userStream.listen((user) {
  if (user != null) {
    print('Updated: ${user.displayName}');
  }
});
```

### 컬렉션 쿼리
```dart
// 활성 사용자 조회
final activeUsers = await FirebaseFirestore.instance
    .collection('users')
    .where('lastActive', isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
    .get();

final users = activeUsers.docs
    .map((doc) => UsersModel.getDocumentFromData(
        doc.data(),
        doc.reference,
    ))
    .toList();
```

### 투표 시스템 사용
```dart
// 투표 게시물 생성
final postData = createPostsModelData(
  userId: currentUserUid,
  questionTitle: '커피 vs 차',
  optionA: {'text': '커피', 'imageUrl': 'coffee.jpg'},
  optionB: {'text': '차', 'imageUrl': 'tea.jpg'},
  voteStartTime: DateTime.now(),
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
  voteStatus: 'active',
  votesA: 0,
  votesB: 0,
);

// 투표하기
await FirebaseFirestore.instance
    .collection('posts')
    .doc(postId)
    .update({
  'votesA': FieldValue.increment(1),
  'votedUserIdsA': FieldValue.arrayUnion([currentUserUid]),
});
```

### 채팅 메시지 처리
```dart
// 메시지 생성
final messageData = createMessagesModelData(
  senderId: currentUserUid,
  content: 'Hello!',
  messageType: 'text',
  timeStamp: DateTime.now(),
);

// 투표 카드 메시지
final voteCardData = createMessagesModelData(
  senderId: 'ai_assistant',
  messageType: 'vote_card',
  votePostId: postId,
  voteOptionAImages: ['imageA1.jpg', 'imageA2.jpg'],
  voteOptionBImages: ['imageB1.jpg'],
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
  cardStatus: 'active',
);
```

## 📊 데이터 플로우

### 읽기 플로우
```
Firestore Document
    ↓
DocumentSnapshot
    ↓
Map<String, dynamic> (raw data)
    ↓
mapFromFirestore() [유틸리티]
    ↓
Model._initializeFields()
    ↓
Model Instance (타입 안전)
```

### 쓰기 플로우
```
Flutter Data
    ↓
createModelData() helper
    ↓
Map<String, dynamic>
    ↓
mapToFirestore() [유틸리티]
    ↓
Firestore Document
```

## ⚡ 성능 최적화

### 쿼리 최적화
```dart
// 인덱스 활용
FirebaseFirestore.instance
    .collection('posts')
    .where('voteStatus', isEqualTo: 'active')
    .where('createdAt', isGreaterThan: yesterday)
    .orderBy('createdAt', descending: true)
    .limit(20);
```

### 캐싱 전략
```dart
// DocumentSnapshot 캐싱
class UserCache {
  static final Map<String, UsersModel> _cache = {};
  
  static Future<UsersModel?> getUser(String userId) async {
    if (_cache.containsKey(userId)) {
      return _cache[userId];
    }
    
    final user = await UsersModel.getDocumentOnce(
      FirebaseFirestore.instance.doc('users/$userId')
    );
    
    if (user != null) {
      _cache[userId] = user;
    }
    return user;
  }
}
```

## 🔒 보안 고려사항

### 필드 검증
```dart
// 입력 검증
void validateUserInput(Map<String, dynamic> data) {
  // 필수 필드 확인
  assert(data['userId'] != null, 'userId is required');
  assert(data['email'] != null, 'email is required');
  
  // 타입 검증
  assert(data['pointsA'] is int, 'pointsA must be integer');
  assert(data['interests'] is List, 'interests must be array');
  
  // 범위 검증
  assert(data['pointsA'] >= 0, 'pointsA cannot be negative');
}
```

### 민감 정보 처리
```dart
// 민감 정보 필터링
Map<String, dynamic> sanitizeUserData(Map<String, dynamic> data) {
  final sanitized = Map<String, dynamic>.from(data);
  
  // 민감 필드 제거
  sanitized.remove('phoneNumber');
  sanitized.remove('email');
  
  return sanitized;
}
```

## 🐛 문제 해결

### 일반적인 에러

#### 1. 타입 캐스팅 에러
```dart
// 문제
final age = snapshotData['age'] as int; // 실패할 수 있음

// 해결
final age = castToType<int>(snapshotData['age']) ?? 0;
```

#### 2. Null Reference 에러
```dart
// 문제
String name = userDoc.displayName; // null일 수 있음

// 해결
String name = userDoc.hasDisplayName() ? userDoc.displayName : 'Unknown';
```

#### 3. 필드명 불일치
```dart
// Backward compatibility 활용
// 이전: snake_case
final oldField = data['user_name'];

// 현재: camelCase
final newField = data['userName'];

// 모델에서 처리
String get userName => _userName ?? _user_name ?? '';
```

## 🔗 관련 문서

- [Util 모듈 상세](./util/README.md)
- [Backend 모듈](../README.md)
- [Firebase 초기화](../firebase/README.md)
- [API 요청](../api_requests/README.md)
- [Algolia 검색](../algolia/README.md)
- [Firebase Storage](../firebase_storage/README.md)

## 📝 변경 이력

- **2025-08-22**: 문서 전면 개정 및 상세 설명 추가
- **2025-08-21**: snake_case → camelCase 완전 마이그레이션
- **2025-08-03**: 필드 불일치 해결, 투표 시스템 통합
- **2025-07-31**: 컬렉션명 정규화 (_record 제거)
- **초기**: Firestore 데이터 모델 구현

---

*이 문서는 `/lib/backend/schema` 디렉토리의 Firestore 데이터 모델을 설명합니다.*