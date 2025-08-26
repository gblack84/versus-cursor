# 📦 Notifications Domain Models Layer

> Feature-First Architecture - 알림 도메인 모델 레이어

## 📋 개요

알림 기능의 핵심 데이터 모델을 정의하는 도메인 레이어입니다. 비즈니스 로직과 독립적인 순수한 데이터 구조를 정의합니다.

## 🏗️ 디렉토리 구조

```
domain/models/
├── notification_model.dart          # 기본 알림 모델
├── vote_notification.dart           # 투표 알림 모델
├── chat_notification.dart           # 채팅 알림 모델 (향후)
├── friend_notification.dart         # 친구 요청 알림 (향후)
├── system_notification.dart         # 시스템 알림 (향후)
├── notification_type.dart           # 알림 타입 enum
└── notification_priority.dart       # 알림 우선순위 enum
```

## 🔑 주요 모델

### 1. NotificationModel - 기본 알림 모델

**역할**: 모든 알림의 기본 데이터 모델

**필드**:
- `id`: 알림 고유 ID
- `userId`: 수신자 ID
- `type`: 알림 타입 (NotificationType enum)
- `title`: 알림 제목
- `message`: 알림 메시지
- `data`: 추가 데이터 (Map<String, dynamic>)
- `isRead`: 읽음 상태
- `createdAt`: 생성 시간
- `readAt`: 읽은 시간 (optional)
- `expiryTime`: 만료 시간 (optional)
- `priority`: 우선순위 (NotificationPriority enum)
- `imageUrl`: 이미지 URL (optional)
- `actionUrl`: 액션 URL (optional)
- `actions`: 액션 버튼 맵 (optional)

**주요 기능**:
- JSON 직렬화 지원
- Equatable로 객체 비교
- copyWith 메서드로 불변 업데이트
- Firestore 변환 지원

### 2. VoteNotification - 투표 알림 모델

**역할**: 투표 요청 및 결과 알림을 위한 확장 모델

**NotificationModel 확장 필드**:
- `postId`: 투표 게시물 ID
- `postTitle`: 투표 제목
- `optionA`: A 옵션 텍스트 (optional)
- `optionB`: B 옵션 텍스트 (optional)
- `imageUrlsA`: A 옵션 이미지 목록 (optional)
- `imageUrlsB`: B 옵션 이미지 목록 (optional)
- `aspectRatios`: 이미지 비율 맵 (optional)
- `layoutType`: 레이아웃 타입 (horizontal/vertical)
- `voteEndTime`: 투표 종료 시간
- `currentVotesA`: 현재 A 투표 수
- `currentVotesB`: 현재 B 투표 수

**특징**:
- NotificationModel을 상속
- type은 항상 NotificationType.voteRequest
- priority는 기본적으로 high
- 투표 데이터를 data 필드에 저장
- fromNotificationModel 팩토리 메서드 제공

### 3. NotificationType - 알림 타입 Enum

**알림 타입 목록**:
- `voteRequest`: 투표 요청
- `voteResult`: 투표 결과
- `chatMessage`: 채팅 메시지
- `friendRequest`: 친구 요청
- `friendAccepted`: 친구 수락
- `postLike`: 게시물 좋아요
- `postComment`: 게시물 댓글
- `systemUpdate`: 시스템 업데이트
- `promotion`: 프로모션
- `achievement`: 업적 달성

**속성**:
- `value`: 데이터베이스 저장값
- `displayName`: 화면 표시용 이름

**메서드**:
- `fromValue()`: 문자열로부터 enum 변환
- 기본값: systemUpdate

### 4. NotificationPriority - 우선순위 Enum

**우선순위 레벨**:
- `low`: 낮음 (level: 0)
- `normal`: 보통 (level: 1)
- `high`: 높음 (level: 2)
- `urgent`: 긴급 (level: 3)

**속성**:
- `value`: 데이터베이스 저장값
- `level`: 우선순위 레벨 (숫자)

**메서드**:
- `fromValue()`: 문자열로부터 enum 변환
- `isHigherThan()`: 우선순위 비교
- 기본값: normal

### 5. ChatNotification - 채팅 알림 모델 (향후)

**역할**: 채팅 메시지 알림을 위한 확장 모델

**NotificationModel 확장 필드**:
- `chatId`: 채팅방 ID
- `senderId`: 발신자 ID
- `senderName`: 발신자 이름
- `senderProfileUrl`: 발신자 프로필 URL (optional)
- `messagePreview`: 메시지 미리보기
- `isGroupChat`: 그룹 채팅 여부
- `groupName`: 그룹 이름 (optional)
- `unreadCount`: 읽지 않은 메시지 수

**특징**:
- type은 항상 NotificationType.chatMessage
- priority는 기본적으로 high
- actionUrl은 채팅방으로 이동 경로

## 🔄 모델 변환

### JSON 직렬화
- build_runner를 사용한 자동 코드 생성
- JsonSerializable 어노테이션 활용
- fromJson/toJson 메서드 자동 생성

### Firestore 변환
**fromFirestore**:
- DocumentSnapshot에서 NotificationModel로 변환
- Timestamp를 DateTime으로 변환
- null 체크 및 기본값 처리
- enum 타입 변환 (fromValue 사용)

**toFirestore**:
- NotificationModel을 Map<String, dynamic>으로 변환
- DateTime을 Timestamp로 변환
- enum을 문자열로 변환 (value 사용)
- null 값 처리

## 🧪 테스트 전략

### 단위 테스트
**NotificationModel 테스트**:
- JSON 직렬화/역직렬화 테스트
- 필드 검증 테스트
- 알림 만료 로직 테스트
- copyWith 기능 테스트

**VoteNotification 테스트**:
- NotificationModel 확장 테스트
- 투표 데이터 변환 테스트
- 이미지 URL 배열 처리 테스트

**Enum 테스트**:
- fromValue 메서드 테스트
- 기본값 처리 테스트
- 우선순위 비교 로직 테스트

## ✅ 체크리스트

### 구현 완료
- [x] NotificationModel 기본 구조
- [x] NotificationType enum
- [x] NotificationPriority enum
- [x] VoteNotification 확장 모델

### 향후 구현
- [ ] ChatNotification 모델
- [ ] FriendNotification 모델
- [ ] SystemNotification 모델
- [ ] AchievementNotification 모델
- [ ] NotificationGroup 모델 (그룹화)

## 📚 참고 자료

- [Equatable Package](https://pub.dev/packages/equatable)
- [JSON Serialization](https://flutter.dev/docs/development/data-and-backend/json)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)

---

*이 문서는 Feature-First Architecture의 일부로 작성되었습니다.*
*최종 업데이트: 2025-08-24*