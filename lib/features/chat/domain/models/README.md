# 📦 /lib/features/chat/domain/models

> Feature-First Architecture - Chat Domain Models

## 📋 개요

채팅 기능의 **Domain Model Layer**를 담당하는 디렉토리입니다. 비즈니스 도메인의 핵심 엔티티와 값 객체를 정의합니다.

### 🎯 목적
- **도메인 엔티티 정의**: 채팅 관련 핵심 비즈니스 객체
- **불변성 보장**: Immutable 모델 설계
- **타입 안정성**: 강타입 시스템 활용
- **직렬화 지원**: JSON, Firestore 변환 지원

## 🏗️ 디렉토리 구조

```
models/
├── entities/                           # 도메인 엔티티
│   ├── chat_model.dart                # 채팅방 엔티티
│   ├── message_model.dart             # 메시지 엔티티
│   ├── user_model.dart                # 사용자 엔티티
│   ├── notification_model.dart        # 알림 엔티티
│   └── vote_model.dart                # 투표 엔티티
│
├── value_objects/                     # 값 객체
│   ├── message_type.dart              # 메시지 타입
│   ├── chat_status.dart               # 채팅 상태
│   ├── vote_status.dart               # 투표 상태
│   ├── notification_priority.dart     # 알림 우선순위
│   └── media_type.dart                # 미디어 타입
│
└── aggregates/                        # 집합체
    ├── chat_aggregate.dart            # 채팅 집합체
    └── vote_aggregate.dart            # 투표 집합체
```

## 📂 도메인 엔티티

### 1. ChatModel

**책임**: 채팅방 도메인 엔티티

**주요 필드**:
- `id`: 채팅방 고유 ID
- `participantIds`: 참여자 ID 목록
- `createdAt`: 생성 시간
- `lastMessageAt`: 마지막 메시지 시간
- `lastMessage`: 마지막 메시지 내용
- `lastMessageSenderId`: 마지막 메시지 발신자
- `unreadCounts`: 사용자별 읽지 않은 메시지 수
- `metadata`: 메타데이터
- `isGroupChat`: 그룹 채팅 여부
- `groupName`: 그룹 이름
- `groupImage`: 그룹 이미지
- `adminIds`: 관리자 ID 목록
- `isActive`: 활성 상태
- `deletedAt`: 삭제 시간

**주요 메서드**:
- `fromJson()`: JSON 변환
- `fromFirestore()`: Firestore 문서 변환
- `toFirestore()`: Firestore 저장 형식 변환
- `totalUnreadCount`: 전체 읽지 않은 메시지 수
- `getUnreadCountForUser()`: 특정 사용자의 읽지 않은 메시지 수
- `isDirectMessage`: 1:1 채팅 여부
- `getOtherParticipantId()`: 상대방 ID 조회
- `isAdmin()`: 관리자 확인
- `getChatTitle()`: 채팅방 제목 생성
- `isArchived`: 보관 상태
- `formattedLastMessageTime`: 포맷된 마지막 메시지 시간

### 2. MessageModel

**책임**: 메시지 도메인 엔티티

**주요 필드**:
- **기본 정보**: id, chatId, senderId, content, timestamp
- **메시지 타입**: type (text, image, video, voteCard 등)
- **미디어**: mediaUrl, mediaUrls
- **편집/삭제**: isEdited, editedAt, isDeleted, deletedAt
- **읽음 상태**: readBy 목록
- **반응**: reactions Map
- **투표 카드**: postId, votesA, votesB, voters, voteEndTime 등
- **답장**: replyToMessageId, replyToMessage
- **시스템**: isSystemMessage, systemAction

**주요 메서드**:
- `fromJson()`: JSON 변환
- `fromFirestore()`: Firestore 문서 변환
- `toFirestore()`: Firestore 저장 형식 변환
- `isVoteCard`: 투표 카드 여부
- `hasMedia`: 미디어 포함 여부
- `isReadBy()`: 특정 사용자 읽음 확인
- `toggleReaction()`: 반응 추가/제거
- `isVoteInProgress`: 투표 진행중 여부
- `voteRemainingTime`: 투표 남은 시간
- `formattedTime`: 포맷된 시간
- `displayContent`: 표시용 콘텐츠

### 3. NotificationModel

**책임**: 알림 도메인 엔티티

**주요 필드**:
- **기본 정보**: id, recipientId, type, title, body, createdAt
- **읽음 상태**: isRead, readAt
- **우선순위**: priority (low, normal, high, urgent)
- **투표 알림**: postId, senderId, optionAText, optionBText, 이미지 등
- **레이아웃**: layoutType, aspectRatios
- **액션**: actionType, actionUrl, actions Map
- **표시 설정**: autoClose, displayDuration, requiresInteraction

**주요 메서드**:
- `fromJson()`: JSON 변환 (Priority, Duration, AspectRatio 처리)
- `isVoteNotification`: 투표 알림 여부
- `isUrgent`: 긴급 알림 여부
- `canDisplay`: 표시 가능 여부 (읽음/만료 체크)
- `notificationIcon`: 타입별 아이콘
- `formattedTime`: 포맷된 시간
- `actionButtons`: 액션 버튼 텍스트

### 4. VoteModel

**책임**: 투표 도메인 엔티티

**주요 필드**:
- `id`: 투표 ID
- `postId`: 관련 게시물 ID
- `userId`: 투표자 ID
- `option`: 선택한 옵션 (A/B)
- `votedAt`: 투표 시간
- `status`: 투표 상태 (VoteStatus)
- `chatId`: 관련 채팅방 ID
- `messageId`: 관련 메시지 ID
- `metadata`: 메타데이터

**주요 메서드**:
- `fromJson()`: JSON 변환
- `isValid`: 유효한 투표 여부
- `isOptionA`: A 옵션 선택 여부
- `isOptionB`: B 옵션 선택 여부

## 📂 값 객체 (Value Objects)

### 1. MessageType

**메시지 타입 열거형**:
- `text`: 텍스트 메시지
- `image`: 이미지 메시지
- `video`: 비디오 메시지
- `audio`: 음성 메시지
- `file`: 파일 첫부
- `voteCard`: 투표 카드
- `system`: 시스템 메시지
- `location`: 위치 공유
- `contact`: 연락처 공유
- `sticker`: 스티커

**주요 메서드**:
- `fromString()`: 문자열에서 변환
- `toString()`: 문자열로 변환
- `isMedia`: 미디어 타입 여부
- `isFile`: 파일 타입 여부

### 2. VoteStatus

**투표 상태 열거형**:
- `pending`: 대기중
- `inProgress`: 진행중
- `completed`: 완료
- `expired`: 만료
- `cancelled`: 취소
- `valid`: 유효
- `invalid`: 무효

**주요 메서드**:
- `fromString()`: 문자열에서 변환
- `toString()`: 문자열로 변환
- `isActive`: 활성 상태 여부 (pending, inProgress)
- `isFinished`: 종료 상태 여부 (completed, expired, cancelled)
- `color`: 상태별 색상 반환

### 3. NotificationPriority

**알림 우선순위 열거형**:
- `low`: 낮음 (level: 0)
- `normal`: 보통 (level: 1)
- `high`: 높음 (level: 2)
- `urgent`: 긴급 (level: 3)

**주요 메서드**:
- `fromString()`: 문자열에서 변환
- `toString()`: 문자열로 변환
- `isHigherThan()`: 우선순위 비교
- `requiresSound`: 알림음 필요 여부 (high, urgent)
- `requiresVibration`: 진동 필요 여부 (urgent만)

## 📂 집합체 (Aggregates)

### ChatAggregate

**채팅 집합체**

**구성 요소**:
- `chat`: ChatModel 인스턴스
- `messages`: 메시지 목록
- `participants`: 참여자 Map

**주요 메서드**:
- `latestMessage`: 최신 메시지 조회
- `participantNames`: 참여자 이름 목록
- `onlineParticipantCount`: 온라인 참여자 수
- `addMessage()`: 메시지 추가
- `removeMessage()`: 메시지 삭제
- `markAsRead()`: 읽음 처리

## 🧪 테스트 전략

### Model 테스트 계획

**ChatModel 테스트**:
- 1:1 채팅 확인 로직
- 읽지 않은 메시지 카운트
- 그룹 채팅 관리자 확인
- 채팅방 제목 생성

**MessageModel 테스트**:
- 투표 진혁중 확인
- 반응 토글 기능
- 메시지 표시 콘텐츠
- 시간 포맷팅

**NotificationModel 테스트**:
- 알림 표시 가능 여부
- 우선순위 비교
- 액션 버튼 생성

## ⚠️ 주의사항

### 1. 불변성 유지
- Freezed 패키지 활용
- copyWith 메서드 사용
- 직접 수정 금지

### 2. 타입 안정성
- 강타입 사용
- null safety 준수
- 타입 캐스팅 최소화

### 3. 직렬화
- JSON 변환 지원
- Firestore 변환 지원
- DateTime/Timestamp 처리

## ✅ 체크리스트

### 구현 완료
- [ ] ChatModel
- [ ] MessageModel
- [ ] NotificationModel
- [ ] VoteModel
- [ ] UserModel
- [ ] Value Objects
- [ ] Aggregates

### 테스트
- [ ] 모델 단위 테스트
- [ ] 직렬화 테스트
- [ ] 비즈니스 로직 테스트

## 📚 참고 자료

- [Domain-Driven Design](https://martinfowler.com/tags/domain%20driven%20design.html)
- [Freezed Package](https://pub.dev/packages/freezed)
- [Value Objects](https://martinfowler.com/bliki/ValueObject.html)

---

*이 문서는 Feature-First Architecture의 Chat Domain Model Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*