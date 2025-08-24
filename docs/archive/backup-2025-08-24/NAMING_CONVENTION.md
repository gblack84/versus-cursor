# Versus Space 네이밍 컨벤션 가이드

## 🎯 개요

이 문서는 Versus Space 프로젝트의 네이밍 컨벤션을 정의합니다.

**최종 업데이트:** 2025년 8월 21일  
**마이그레이션 상태:** snake_case → camelCase 100% 완료 ✅

## ✅ CamelCase 사용 영역

### 1. Firestore 필드명
모든 데이터베이스 필드는 **camelCase**를 사용합니다.

#### 데이터 모델 필드
```dart
// lib/backend/schema/posts_model.dart
class PostsModel {
  String? questionTitle;     // ✅ camelCase
  String? displayName;       // ✅ camelCase
  int? votesA;              // ✅ camelCase
  int? votesB;              // ✅ camelCase
  List<String>? votedUserIdsA;  // ✅ camelCase
  DateTime? createdAt;      // ✅ camelCase
  DateTime? voteEndTime;    // ✅ camelCase
}
```

#### 서브컬렉션 필드
```dart
// lib/backend/schema/messages_model.dart
class MessagesModel {
  String? messageId;        // ✅ camelCase
  String? senderId;         // ✅ camelCase
  String? voteChoice;       // ✅ camelCase
  bool? isRead;            // ✅ camelCase
}
```

#### Firebase Functions 필드
```javascript
// firebase/functions/services/notificationService.js
const postData = {
  questionTitle: title,     // ✅ camelCase
  votesA: 0,               // ✅ camelCase
  votesB: 0,               // ✅ camelCase
  createdAt: timestamp,    // ✅ camelCase
  targetAudience: {        // ✅ camelCase
    mode: 'quick',
    userIds: []
  }
};
```

### 2. 라우트명
GoRouter의 모든 경로는 **camelCase**를 사용합니다.

```dart
// lib/core/nav/nav.dart
routes: [
  GoRoute(
    name: 'testpageSelect',   // ✅ camelCase
    path: '/testpageSelect',  // ✅ camelCase
  ),
  GoRoute(
    name: 'chatDetail',       // ✅ camelCase
    path: '/chatDetail',      // ✅ camelCase
  ),
  GoRoute(
    name: 'profilePage',      // ✅ camelCase
    path: '/profilePage',     // ✅ camelCase
  ),
]
```

### 3. 변수 및 함수명
Dart 코드의 변수와 함수는 **camelCase**를 사용합니다.

```dart
// 변수
String userName = 'John';          // ✅ camelCase
bool isLoggedIn = true;           // ✅ camelCase
int voteCount = 42;               // ✅ camelCase

// 함수/메서드
Future<void> getUserData() async {}      // ✅ camelCase
void updateVoteStatus(String postId) {}  // ✅ camelCase
bool checkUserPermission() {}            // ✅ camelCase
```

## 🔧 Snake_case 유지 영역 (표준 컨벤션)

### 1. 파일명 (Dart 표준)
Dart/Flutter 공식 스타일 가이드에 따라 **snake_case**를 사용합니다.

```
✅ 올바른 파일명:
lib/pages/home/home_page_widget.dart
lib/services/vote_timer_service.dart
lib/backend/schema/posts_model.dart
lib/components/chat/vote_card_message.dart

❌ 잘못된 파일명:
lib/pages/home/HomePageWidget.dart     // PascalCase
lib/services/voteTimerService.dart     // camelCase
```

### 2. Firebase Storage 경로
URL 표준 및 기존 데이터 호환성을 위해 **snake_case**를 유지합니다.

```dart
// lib/services/media_upload_service.dart
final storageRef = FirebaseStorage.instance
    .ref()
    .child('user_uploads')      // ✅ snake_case
    .child('post_images')       // ✅ snake_case
    .child('${timestamp}_image.jpg');

// 경로 예시
'users/$userId/posts/images/'          // ✅ snake_case
'users/$userId/posts/thumbnails/'      // ✅ snake_case
'users/$userId/videos/'                // ✅ snake_case
```

### 3. 특수 식별자
시스템 식별자 및 문자열 ID는 **snake_case**를 허용합니다.

```dart
// AI 채팅방 ID
final String aiChatId = 'ai_assistant_$userId';    // ✅ snake_case ID
final String helperChatId = 'ai_helper_$userId';   // ✅ snake_case ID

// 컬렉션명 (기존 데이터베이스 구조 유지)
FirebaseFirestore.instance
    .collection('time_sync')    // ✅ snake_case 컬렉션명
    .add(data);

// 로그 태그
logger.info('voteRequestSent', data);       // ✅ camelCase 태그
logger.error('notificationFailed', error);   // ✅ camelCase 태그
```

### 4. 외부 API 필드
서드파티 서비스 요구사항에 따라 **snake_case**를 사용합니다.

```dart
// lib/services/perspective_api_service.dart
final requestBody = {
  'comment': {'text': text},
  'requested_attributes': {    // ✅ Google API 요구 형식
    'TOXICITY': {},
    'SEVERE_TOXICITY': {},    // ✅ UPPER_SNAKE_CASE
  },
};
```

## 📊 마이그레이션 완료 현황

| 카테고리 | 변환 수 | 상태 | 커밋 |
|---------|---------|------|------|
| **Firestore 필드** | 768개 | ✅ 100% camelCase | d7c53da6 |
| **라우트명** | 15개 | ✅ 100% camelCase | d7c53da6 |
| **Backward Compatibility** | 모두 제거 | ✅ 완료 | d7c53da6 |
| **Firebase Functions** | 모든 필드 | ✅ 동기화 완료 | d7c53da6 |

## 🔍 빠른 참조

### ✅ CamelCase를 사용하세요
- Firestore 데이터 필드
- 라우트명
- Dart 변수/함수명
- API 응답 필드 (자체 API)

### 🔧 Snake_case를 유지하세요
- 파일명 (Dart 표준)
- Firebase Storage 경로
- 문자열 ID/식별자
- 외부 API 요구사항
- 로그 태그

## 📝 주의사항

1. **새 필드 추가 시**: 반드시 camelCase 사용
2. **파일 생성 시**: 반드시 snake_case 사용
3. **Storage 경로**: 기존 구조 유지 (snake_case)
4. **외부 API**: 해당 서비스의 요구사항 따르기

## 🔗 관련 문서

- [CLAUDE.md](./CLAUDE.md) - 프로젝트 전체 가이드
- [MIGRATION_SUMMARY.md](./MIGRATION_SUMMARY.md) - 마이그레이션 상세 보고서
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) - Dart 공식 스타일 가이드