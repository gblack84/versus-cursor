# Data Models

Versus Space 앱의 데이터 모델을 정의하는 디렉토리입니다.

## 📋 개요

이 디렉토리는 Firebase Firestore 스키마와는 별개로, 앱 내부에서 사용되는 데이터 구조를 정의합니다.

## 주요 모델

### NotificationModel

실시간 알림 데이터를 관리하는 모델입니다.

```dart
class NotificationModel {
  final String notificationId;
  final String userId;
  final String type;
  final String sourceId;
  final Map<String, dynamic> content;
  final DateTime createdAt;
  final bool read;
  final String? targetAudience;
  final DateTime? expiryTime;
  final String? interactionType;
  
  // 확장 필드
  final String? status;
  final DateTime? completedAt;
  final String? title;
  final String? message;
  final String? imageUrl;
  final String? actionUrl;
  final String? priority;
  final String? sourceType;
  final Map<String, dynamic>? postData;
}
```

#### 주요 기능

**1. JSON 파싱**
```dart
// Firestore 문서에서 생성
factory NotificationModel.fromFirestore(
  DocumentSnapshot<Map<String, dynamic>> doc
) {
  final data = doc.data()!;
  return NotificationModel.fromJson({
    ...data,
    'notificationId': doc.id,
  });
}
```

**2. 콘텐츠 파싱**
```dart
// content 필드가 JSON 문자열인 경우 자동 파싱
if (json['content'] is String) {
  try {
    final parsed = jsonDecode(json['content']);
    if (parsed is Map && parsed.containsKey('postData')) {
      postData = parsed['postData'];
    }
  } catch (e) {
    // JSON이 아닌 경우 문자열로 유지
  }
}
```

**3. 투표 알림 특화 메서드**
```dart
// 투표 알림인지 확인
bool get isVotingRequest => type == 'voting_request';

// 투표 데이터 접근
String? get questionTitle => postData?['questionTitle'];
String? get optionA => postData?['optionA']['title'];
String? get optionB => postData?['optionB']['title'];
List<String>? get imageUrlsA => postData?['optionA']['imageUrls'];
List<String>? get imageUrlsB => postData?['optionB']['imageUrls'];
```

**4. 상태 관리**
```dart
// 알림 읽음 처리
NotificationModel markAsRead() {
  return copyWith(read: true);
}

// 만료 확인
bool get isExpired {
  if (expiryTime == null) return false;
  return DateTime.now().isAfter(expiryTime!);
}
```

### 사용 예제

```dart
// 1. Firestore에서 알림 가져오기
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('notifications')
    .where('userId', isEqualTo: userId)
    .where('read', isEqualTo: false)
    .snapshots(),
  builder: (context, snapshot) {
    final notifications = snapshot.data!.docs
      .map((doc) => NotificationModel.fromFirestore(doc))
      .where((n) => !n.isExpired)
      .toList();
    
    return NotificationList(notifications: notifications);
  },
);

// 2. 투표 알림 표시
if (notification.isVotingRequest) {
  return VotingNotificationDialog(
    notification: notification,
    onVote: (choice) async {
      await voteOnPost(
        notification.sourceId,
        choice,
        notification.userId,
      );
    },
  );
}

// 3. 알림 읽음 처리
await FirebaseFirestore.instance
  .collection('notifications')
  .doc(notification.notificationId)
  .update({'read': true});
```

## 모델 설계 원칙

### 1. 불변성 (Immutability)
- 모든 필드는 `final`로 선언
- 수정이 필요한 경우 `copyWith` 메서드 사용
- 상태 변경 시 새 인스턴스 생성

### 2. 널 안전성 (Null Safety)
- 필수 필드는 non-nullable 타입 사용
- 선택적 필드는 nullable 타입 사용
- 기본값 제공으로 안전성 향상

### 3. 타입 안전성
- 강타입 사용으로 런타임 오류 방지
- Generic 활용으로 재사용성 향상
- 명시적 타입 변환

### 4. 직렬화 (Serialization)
```dart
// JSON 직렬화
Map<String, dynamic> toJson() => {
  'notificationId': notificationId,
  'userId': userId,
  'type': type,
  // ...
};

// JSON 역직렬화
factory NotificationModel.fromJson(Map<String, dynamic> json) {
  return NotificationModel(
    notificationId: json['notificationId'] as String,
    userId: json['userId'] as String,
    type: json['type'] as String,
    // ...
  );
}
```

## 모델과 스키마 관계

### Firestore 스키마와의 매핑
```
Firestore Document → fromFirestore() → NotificationModel
NotificationModel → toJson() → Firestore Document
```

### 필드 매핑 규칙
- Firestore: camelCase (예: `userId`)
- Dart Model: camelCase (예: `userId`)
- 자동 변환 처리

## 테스트

```dart
// 모델 테스트 예제
test('NotificationModel JSON serialization', () {
  final notification = NotificationModel(
    notificationId: 'test123',
    userId: 'user456',
    type: 'voting_request',
    // ...
  );
  
  final json = notification.toJson();
  final restored = NotificationModel.fromJson(json);
  
  expect(restored.notificationId, equals(notification.notificationId));
  expect(restored.userId, equals(notification.userId));
});
```

## 향후 추가 예정 모델

1. **ChatMessageModel**
   - 채팅 메시지 통합 모델
   - flutter_chat_types 확장

2. **PostModel**
   - 게시물 데이터 래퍼
   - 투표 상태 관리 포함

3. **UserProfileModel**
   - 사용자 프로필 확장
   - 캐싱 및 상태 관리

4. **MediaModel**
   - 이미지/비디오 통합 관리
   - 썸네일 및 메타데이터

## 베스트 프랙티스

1. **모델 생성 시 고려사항**
   - 단일 책임 원칙 준수
   - 비즈니스 로직 분리
   - 테스트 가능한 구조

2. **성능 최적화**
   - 불필요한 객체 생성 방지
   - 메모리 효율적인 구조
   - 캐싱 전략 적용

3. **유지보수성**
   - 명확한 문서화
   - 일관된 네이밍
   - 버전 관리 고려