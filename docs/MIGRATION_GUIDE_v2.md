# Migration Guide v2.0.0

이 가이드는 Versus Space v1.x에서 v2.0.0으로 마이그레이션하는 방법을 설명합니다.

## 🚨 Breaking Changes

v2.0.0은 대규모 시스템 통합으로 인해 여러 Breaking Change가 있습니다. 
아래 내용을 반드시 확인하고 코드를 업데이트해주세요.

---

## 1. Firebase 컬렉션 이름 변경

### 변경 내용
모든 Firestore 컬렉션에서 `_record` 접미사가 제거되었습니다.

### 마이그레이션 방법

#### Firestore 쿼리 업데이트
```dart
// ❌ 이전 (v1.x)
FirebaseFirestore.instance.collection('users_record')
FirebaseFirestore.instance.collection('posts_record')
FirebaseFirestore.instance.collection('notifications_record')
FirebaseFirestore.instance.collection('chats_record')
FirebaseFirestore.instance.collection('messages_record')

// ✅ 현재 (v2.0.0)
FirebaseFirestore.instance.collection('users')
FirebaseFirestore.instance.collection('posts')
FirebaseFirestore.instance.collection('notifications')
FirebaseFirestore.instance.collection('chats')
FirebaseFirestore.instance.collection('messages')
```

#### Firebase Functions 업데이트
```javascript
// ❌ 이전 (v1.x)
admin.firestore().collection('users_record')

// ✅ 현재 (v2.0.0)
admin.firestore().collection('users')
```

---

## 2. Flutter 모델 파일명 변경

### 변경 내용
38개의 모델 파일이 `_record.dart`에서 `_model.dart`로 변경되었습니다.

### 마이그레이션 방법

#### Import 문 업데이트
```dart
// ❌ 이전 (v1.x)
import '/backend/schema/users_record.dart';
import '/backend/schema/posts_record.dart';
import '/backend/schema/messages_record.dart';
import '/backend/schema/notifications_record.dart';

// ✅ 현재 (v2.0.0)
import '/backend/schema/users_model.dart';
import '/backend/schema/posts_model.dart';
import '/backend/schema/messages_model.dart';
import '/backend/schema/notifications_model.dart';
```

#### 클래스명은 변경되지 않음
```dart
// 클래스명은 그대로 유지됩니다
UsersModel user = UsersModel.fromSnapshot(doc);
PostsModel post = PostsModel.fromSnapshot(doc);
```

### 전체 모델 파일 목록
```bash
# 변경된 파일들 (38개)
characters_record.dart → characters_model.dart
chat_history_record.dart → chat_history_model.dart
chat_interest_jops_record.dart → chat_interest_jops_model.dart
chats_record.dart → chats_model.dart
client_record.dart → client_model.dart
comments_record.dart → comments_model.dart
content_comments_record.dart → content_comments_model.dart
contents_interests_record.dart → contents_interests_model.dart
contents_likes_record.dart → contents_likes_model.dart
contents_shares_record.dart → contents_shares_model.dart
dislikes_record.dart → dislikes_model.dart
encodings_record.dart → encodings_model.dart
feed_details_record.dart → feed_details_model.dart
friends_list_record.dart → friends_list_model.dart
group_chats_record.dart → group_chats_model.dart
group_messages_record.dart → group_messages_model.dart
image_moderation_record.dart → image_moderation_model.dart
images_record.dart → images_model.dart
interest_record.dart → interest_model.dart
jops_category_record.dart → jops_category_model.dart
jops_name_record.dart → jops_name_model.dart
likes_record.dart → likes_model.dart
messages_record.dart → messages_model.dart
notification_record.dart → notification_model.dart
notifications_record.dart → notifications_model.dart
point_record.dart → point_model.dart
poll_details_record.dart → poll_details_model.dart
posts_record.dart → posts_model.dart
premium_users_record.dart → premium_users_model.dart
ranked_posts_record.dart → ranked_posts_model.dart
rankings_record.dart → rankings_model.dart
searches_record.dart → searches_model.dart
settings_record.dart → settings_model.dart
transactions_record.dart → transactions_model.dart
user_contents_record.dart → user_contents_model.dart
users_record.dart → users_model.dart
video_record.dart → video_model.dart
vote_expansion_requests_record.dart → vote_expansion_requests_model.dart
votecounts_record.dart → votecounts_model.dart
votes_record.dart → votes_model.dart
weights_record.dart → weights_model.dart
```

---

## 3. 로깅 시스템 업데이트

### 변경 내용
시간 기반 중복 억제에서 영구 중복 방지 시스템으로 변경되었습니다.

### 마이그레이션 방법

#### 기본 로깅
```dart
// ❌ 이전 (v1.x) - 시간 기반 중복 억제
DebugHelper.log('메시지', tag: 'MyTag');
// 500ms 내에 같은 메시지가 다시 호출되면 무시됨

// ✅ 현재 (v2.0.0) - 일반 로깅 (중복 허용)
DebugHelper.log('메시지', tag: 'MyTag');
```

#### 중복 방지가 필요한 경우
```dart
// ✅ 현재 (v2.0.0) - 영구 중복 방지
DebugHelper.logOnce('unique_id', '메시지', tag: 'MyTag');
// 같은 ID로는 세션 동안 한 번만 출력됨
```

#### 권장 사용 패턴
```dart
// 문서별 로깅
DebugHelper.logOnce(
  'doc_${doc.id}',
  '문서 처리: ${doc.id}',
  tag: 'DocumentProcessor'
);

// 이미지별 로깅
DebugHelper.logOnce(
  'img_${imageUrl.hashCode}',
  '이미지 로드: ${imageUrl}',
  tag: 'ImageLoader'
);

// 이벤트별 로깅
DebugHelper.logOnce(
  'event_${eventType}_${timestamp}',
  '이벤트 발생: $eventType',
  tag: 'EventHandler'
);
```

---

## 4. 새로운 필드 추가

### Posts 모델
```dart
// 투표 관련 필드 (13개 추가)
int? voteStartTime;
int? voteEndTime;
int? votesA;
int? votesB;
int? displayVotesA;
int? displayVotesB;
bool? voteStatus;
bool? voteCompleted;
int? voteRequestCount;
int? voteRequestSentCount;
int? totalVotes;
int? lastVoteAt;
int? voteDuration;
```

### Messages 모델
```dart
// 투표 카드 필드 (9개 추가)
String? receiverId;
List<String>? voteOptionAImages;
List<String>? voteOptionBImages;
String? cardStatus;
int? voteEndTime;
Map<String, dynamic>? userVotes;
int? voteResultsA;
int? voteResultsB;
int? voteCompletedAt;
```

### Notifications 모델
```dart
// 알림 관련 필드 (9개 추가)
String? notificationId;
String? type;
String? sourceId;
String? userId;
String? content;  // JSON 문자열
DateTime? createdAt;
bool? read;
List<String>? targetAudience;
DateTime? expiryTime;
String? interactionType;
```

---

## 5. Firebase Security Rules 업데이트

### 새로운 필드 확인
```javascript
// firestore.rules에 추가된 필드들
allow read: if request.auth != null && (
  // 투표 타이머 필드
  resource.data.voteStartTime != null &&
  resource.data.voteEndTime != null &&
  resource.data.voteStatus != null &&
  resource.data.voteCompleted != null &&
  
  // 알림 관련 필드
  resource.data.notificationsSent != null &&
  resource.data.notificationsSentAt != null
);
```

---

## 6. AI 채팅 메시지 업데이트

### user_votes Map 구조
```dart
// AI 채팅 메시지의 개별 투표 추적
Map<String, dynamic> userVotes = {
  'userId1': {
    'option': 'A',
    'voted_at': Timestamp.now(),
  },
  'userId2': {
    'option': 'B',
    'voted_at': Timestamp.now(),
  }
};
```

---

## 7. 알림 시스템 변경사항

### NotificationService 사용법
```dart
// 알림 리스닝 시작
NotificationService.instance.startListening(currentUserId);

// 알림 리스닝 중지
NotificationService.instance.stopListening();
```

### GlobalNotificationManager
```dart
// 자동으로 알림 큐 관리 및 표시
// 처리된 알림 ID는 SharedPreferences에 저장되어 중복 방지
```

---

## 마이그레이션 체크리스트

- [ ] 모든 Firestore 쿼리에서 `_record` 접미사 제거
- [ ] 모든 import 문에서 파일명 업데이트 (`_record.dart` → `_model.dart`)
- [ ] DebugHelper 로깅 패턴 검토 및 업데이트
- [ ] 새로운 필드를 사용하는 코드 추가
- [ ] Firebase Security Rules 업데이트 및 배포
- [ ] Firebase Functions 재배포
- [ ] 앱 테스트 및 검증

---

## 도움이 필요하신가요?

마이그레이션 중 문제가 발생하면 다음을 확인해주세요:

1. **에러 로그**: Firebase Console과 Flutter 디버그 콘솔 확인
2. **필드 누락**: 새로운 필드가 제대로 추가되었는지 확인
3. **컬렉션 이름**: 모든 컬렉션 참조가 업데이트되었는지 확인

추가 지원이 필요하시면 이슈 트래커에 문의해주세요.