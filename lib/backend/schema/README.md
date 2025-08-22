# Flutter Backend Schema Documentation

이 디렉토리는 Versus Space 앱의 Firestore 데이터 모델을 정의합니다. 모든 모델은 Firebase Functions와 완벽하게 동기화되어 있습니다.

## 📋 데이터 모델 개요

### 핵심 컬렉션

#### 1. **users** (UsersModel)
사용자 프로필 및 설정 정보를 저장합니다.

**주요 필드:**
- `uid`: 사용자 고유 ID
- `email`: 이메일 주소
- `display_name`: 표시 이름
- `photo_url`: 프로필 사진 URL
- `points_A`: 답변 포인트
- `points_Q`: 질문 포인트
- `interests[]`: 관심사 목록
- `expertise[]`: 전문 분야 목록
- `friends[]`: 친구 목록 (이전 `frinds` 오타 수정됨)
- `isPremiumUser`: 프리미엄 사용자 여부 (이전 `is_prmium_user` 오타 수정됨)
- `role`: 사용자 역할 (admin/tester/user)
- `lastActive`: 마지막 활동 시간

#### 2. **posts** (PostsModel) 
A vs B 형식의 게시물 정보를 저장합니다.

**주요 필드:**
- `userId`: 작성자 ID (camelCase ✅)
- `questionTitle`: 질문 제목
- `optionA`: A 옵션 정보 (Map 구조)
- `optionB`: B 옵션 정보 (Map 구조)
- `description`: 설명
- `targetAudience`: 타겟 오디언스 설정

**투표 시스템 필드 (camelCase 마이그레이션 완료):**
- `voteStartTime`: 투표 시작 시간 (이전: vote_start_time)
- `voteEndTime`: 투표 종료 시간 (이전: vote_end_time)
- `voteStatus`: 투표 상태 (이전: vote_status)
- `voteCompleted`: 투표 완료 여부 (이전: vote_completed)
- `votesA`: A 옵션 투표수 (이전: votes_a)
- `votesB`: B 옵션 투표수 (이전: votes_b)
- `votedUserIdsA[]`: A에 투표한 사용자 ID 목록 (이전: voted_user_ids_a)
- `votedUserIdsB[]`: B에 투표한 사용자 ID 목록 (이전: voted_user_ids_b)
- `totalVotes`: 총 투표수 (이전: total_votes)

#### 3. **messages** (MessagesModel)
채팅 메시지 정보를 저장합니다. (chats 컬렉션의 서브컬렉션)

**기본 메시지 필드 (camelCase):**
- `messageId`: 메시지 고유 ID (이전: message_id)
- `senderId`: 발신자 ID (이전: sender_id)
- `receiverId`: 수신자 ID (이전: receiver_id)
- `content`: 메시지 내용
- `timeStamp`: 전송 시간 (이전: time_stamp)
- `messageType`: 메시지 타입 (이전: message_type)

**투표 카드 필드 (camelCase):**
- `votePostId`: 관련 게시물 ID (이전: vote_post_id)
- `voteOptionAImages[]`: A 옵션 이미지 배열 (이전: vote_option_a_images)
- `voteOptionBImages[]`: B 옵션 이미지 배열 (이전: vote_option_b_images)
- `cardStatus`: 카드 상태 (이전: card_status)
- `voteEndTime`: 투표 종료 시간 (이전: vote_end_time)
- `userVoted`: 사용자 투표 여부 (이전: user_voted)
- `voteChoice`: 사용자 선택 (이전: vote_choice)
- `voteResults`: 투표 결과 (이전: vote_results)
- `voteParticipatedAt`: 투표 참여 시간 (이전: vote_participated_at)

#### 4. **notifications** (NotificationsModel)
알림 정보를 저장합니다.

**필드 (2025-08-03 확장):**
- `notification_id`: 알림 고유 ID
- `user_id`: 대상 사용자 ID
- `type`: 알림 타입
- `source_id`: 소스 ID (게시물 등)
- `content`: 알림 내용 (JSON 형식)
- `status`: 상태 (pending/completed)
- `completed_at`: 완료 시간
- `title`: 알림 제목
- `message`: 알림 메시지
- `image_url`: 이미지 URL
- `action_url`: 액션 URL
- `priority`: 우선순위
- `source_type`: 소스 타입

**JSON 파싱**: `content` 필드가 JSON인 경우 자동으로 `postData` Map으로 파싱됩니다.

#### 5. **chats** (ChatsModel)
채팅방 정보를 저장합니다.

**필드:**
- `user_a`, `user_b`: 참여자 ID
- `participantIds[]`: 참여자 ID 목록
- `last_message_content`: 마지막 메시지 내용
- `last_message_at`: 마지막 메시지 시간
- `chat_type`: 채팅 타입 (ai_chat/direct/group)

### 보조 컬렉션

- **comments**: 게시물 댓글
- **likes**: 좋아요 정보
- **dislikes**: 싫어요 정보
- **characters**: 사용자 아바타/캐릭터
- **encodings**: 비디오 인코딩 상태
- **friends_list**: 친구 관계
- **group_chats**: 그룹 채팅
- **interest**: 관심사 카테고리
- **jops_category**, **jops_name**: 직업 카테고리
- **point**: 포인트 거래 내역
- **premium_users**: 프리미엄 구독 정보
- **rankings**: 순위표
- **searches**: 검색 기록
- **user_contents**: 사용자 콘텐츠

## 🔄 Firebase Functions와의 동기화

모든 필드는 Firebase Functions와 완벽하게 동기화되어 있습니다:

### 필드명 규칙 (2025-08-21 업데이트)
- **Flutter**: 100% camelCase 사용 ✅
- **Firebase Functions**: 100% camelCase 사용 ✅
- **마이그레이션 완료**: 모든 snake_case 필드가 camelCase로 변환됨
- **Backward Compatibility**: 완전 제거 (커밋: d7c53da6)

### Backward Compatibility
오타 수정 시 이전 필드명도 유지:
```dart
// Users Model 예시
@Deprecated('Use friends instead')
List<String> get frinds => friends;

@Deprecated('Use isPremiumUser instead')
bool get isPrmiumUser => isPremiumUser;
```

## 📝 모델 사용 예시

### 데이터 읽기
```dart
// 사용자 정보 가져오기
final userDoc = await UsersModel.getDocumentOnce(userRef);
final displayName = userDoc.displayName;

// 게시물 스트림
final postsStream = PostsModel.getDocument(postRef);
```

### 데이터 생성
```dart
// 새 게시물 생성
final postData = createPostsModelData(
  userid: currentUserUid,
  questionTitle: '커피 vs 차',
  voteStartTime: DateTime.now(),
  voteEndTime: DateTime.now().add(Duration(minutes: 10)),
  voteStatus: 'active',
);
```

## 🚀 최근 업데이트

### 2025-08-03: 필드 불일치 완전 해결
- 총 37개 필드 추가/수정
- 투표 시스템 완전 지원
- 멀티이미지 지원
- AI 채팅 통합
- JSON 파싱 로직 추가

## 🔍 주의사항

1. **필드 추가 시**: Firebase Functions와 Flutter 모두 업데이트 필요
2. **컬렉션명**: 모든 `_record` 접미사가 제거됨 (2025-07-31)
3. **타입 안전성**: castToType 사용으로 타입 변환 안전성 확보
4. **서브컬렉션**: messages는 chats의 서브컬렉션으로만 존재

## 🐛 최근 해결된 이슈 (2025-08-03)

### 1. AI 채팅 메시지 생성 문제
**증상**: 게시물 생성 시 AI 채팅 메시지가 생성되지 않음

**원인**: 
- Firebase Functions는 정상 작동하나 Flutter에서 표시 안 됨
- 채팅방 ID가 `ai_assistant_userId` 형식으로 생성

**해결**:
```dart
// ChatsModel 쿼리 수정 필요
.where('participantIds', arrayContains: currentUserId)
.where('chat_type', isEqualTo: 'ai_chat')
```

### 2. 투표 권한 오류
**증상**: 투표 시 permission-denied 오류

**원인**: votedUserIDsA/B 필드가 없는 경우 보안 규칙 실패

**해결**: Firebase Security Rules에서 필드 존재 여부 확인 추가
```javascript
(!('votedUserIDsA' in resource.data) || !(request.auth.uid in resource.data.votedUserIDsA))
```

### 3. 필드명 불일치
**증상**: Firebase Functions와 Flutter 간 필드명 불일치

**해결**: 
- 양방향 호환성 지원 (snake_case와 camelCase)
- Deprecated 어노테이션으로 이전 필드명 유지