# 📦 /lib/features/chat/domain/usecases

> Feature-First Architecture - Chat Use Cases

## 📋 개요

채팅 기능의 **Use Case Layer**를 담당하는 디렉토리입니다. 애플리케이션의 비즈니스 규칙과 사용자 시나리오를 구현합니다.

### 🎯 목적
- **비즈니스 규칙 구현**: 도메인 로직의 orchestration
- **단일 책임 원칙**: 하나의 Use Case = 하나의 비즈니스 작업
- **의존성 역전**: Repository 인터페이스에만 의존
- **테스트 가능성**: 독립적으로 테스트 가능한 비즈니스 로직

## 🏗️ 디렉토리 구조

```
usecases/
├── chat/                              # 채팅방 관련 Use Cases
│   ├── create_chat_usecase.dart      # 채팅방 생성
│   ├── get_chat_list_usecase.dart    # 채팅 목록 조회
│   ├── delete_chat_usecase.dart      # 채팅방 삭제
│   ├── leave_chat_usecase.dart       # 채팅방 나가기
│   └── archive_chat_usecase.dart     # 채팅방 보관
│
├── message/                           # 메시지 관련 Use Cases
│   ├── send_message_usecase.dart     # 메시지 전송
│   ├── edit_message_usecase.dart     # 메시지 수정
│   ├── delete_message_usecase.dart   # 메시지 삭제
│   ├── react_to_message_usecase.dart # 메시지 반응
│   └── load_messages_usecase.dart    # 메시지 로드
│
├── vote/                              # 투표 관련 Use Cases
│   ├── create_vote_card_usecase.dart # 투표 카드 생성
│   ├── submit_vote_usecase.dart      # 투표 제출
│   ├── get_vote_results_usecase.dart # 투표 결과 조회
│   └── complete_vote_usecase.dart    # 투표 완료 처리
│
├── notification/                      # 알림 관련 Use Cases
│   ├── send_notification_usecase.dart    # 알림 전송
│   ├── mark_as_read_usecase.dart        # 읽음 처리
│   └── get_notifications_usecase.dart    # 알림 목록 조회
│
└── group/                             # 그룹 채팅 Use Cases
    ├── create_group_chat_usecase.dart    # 그룹 생성
    ├── add_participants_usecase.dart     # 참여자 추가
    ├── remove_participant_usecase.dart   # 참여자 제거
    └── update_group_info_usecase.dart    # 그룹 정보 수정
```

## 📂 채팅방 Use Cases

### 1. CreateChatUseCase

**책임**: 채팅방 생성 비즈니스 로직

**주요 기능**:
1. 중복 채팅방 확인 (1:1 채팅의 경우)
2. 채팅방 생성
3. 초기 메시지 전송 (선택사항)
4. 시스템 메시지 추가

**의존성**:
- ChatRepository
- MessageRepository

**파라미터**: CreateChatParams
- participantIds: List<String>
- createdBy: String
- isGroupChat: bool (기본값: false)
- groupName: String? (그룹 채팅용)
- groupImage: String? (그룹 이미지)
- initialMessage: String? (초기 메시지)

### 2. GetChatListUseCase

**책임**: 채팅 목록 조회 및 필터링

**주요 기능**:
1. 사용자별 채팅 목록 스트림 조회
2. 보관된 채팅 필터링
3. 그룹/1:1 채팅 필터링
4. 읽지 않은 채팅 필터링
5. 정렬 (최근 메시지, 읽지 않은 수, 알파벳)

**의존성**:
- ChatRepository

**파라미터**: GetChatListParams
- userId: String
- includeArchived: bool (기본값: false)
- groupChatsOnly: bool (기본값: false)
- directMessagesOnly: bool (기본값: false)
- unreadOnly: bool (기본값: false)
- sortBy: ChatSortBy (기본값: lastMessage)

**정렬 옵션**: ChatSortBy
- lastMessage: 최근 메시지 순
- unreadCount: 읽지 않은 메시지 수
- alphabetical: 알파벳 순

## 📂 메시지 Use Cases

### 1. SendMessageUseCase

**책임**: 메시지 전송 비즈니스 로직

**주요 기능**:
1. 메시지 타입 자동 결정 (text, image, video, audio, file, voteCard)
2. 미디어 업로드 처리 (단일/다중)
3. 메시지 전송
4. 읽음 상태 초기화
5. 푸시 알림 전송

**의존성**:
- MessageRepository
- ChatMediaUploadService

**파라미터**: SendMessageParams
- chatId: String
- senderId: String
- content: String
- mediaPath: String? (단일 미디어)
- mediaPaths: List<String>? (다중 미디어)
- replyToMessageId: String? (답장)
- metadata: Map<String, dynamic>?
- isVoteCard: bool (기본값: false)

## 📂 투표 Use Cases

### 1. CreateVoteCardUseCase

**책임**: 투표 카드 생성 및 알림 전송

**주요 기능**:
1. 투표 옵션 유효성 검증
2. 투표 시간 설정 (기본 10분)
3. 투표 카드 메시지 생성
4. 투표 상태 초기화
5. 타겟 사용자에게 알림 전송

**의존성**:
- MessageRepository
- VoteStateCoordinator

**파라미터**: CreateVoteCardParams
- chatId: String
- postId: String
- senderId: String
- optionAText: String
- optionBText: String
- optionAImages: List<String> (기본값: [])
- optionBImages: List<String> (기본값: [])
- optionAAspectRatios: List<double> (기본값: [])
- optionBAspectRatios: List<double> (기본값: [])
- voteDuration: Duration (기본값: 10분)
- targetUserIds: List<String> (기본값: [])

### 2. SubmitVoteUseCase

**책임**: 투표 제출 및 완료 처리

**주요 기능**:
1. 투표 가능 여부 확인 (시간, 중복, 권한)
2. 투표 제출
3. 투표 완료 여부 확인
4. 중복 투표 방지

**의존성**:
- VoteStateCoordinator

**파라미터**: SubmitVoteParams
- postId: String
- messageId: String
- chatId: String
- userId: String
- option: String ('A' 또는 'B')

## 📂 그룹 채팅 Use Cases

### CreateGroupChatUseCase

**책임**: 그룹 채팅 생성 로직

**주요 기능**:
1. 최소 참여자 수 검증 (3명 이상)
2. 그룹 이름 자동 생성
3. 채팅방 생성 및 초기 메시지 전송

**의존성**:
- CreateChatUseCase

**파라미터**: CreateGroupChatParams
- participantIds: List<String>
- participantNames: List<String>
- createdBy: String
- groupName: String? (선택사항)
- groupImage: String? (선택사항)

**그룹 이름 생성 로직**:
- 3명 이하: 모든 이름 표시
- 4명 이상: 처음 2명 + "외 N명"

## 🧪 테스트 전략

### Use Case 테스트 계획

**테스트 커버리지 목표**:
- 각 Use Case별 단위 테스트
- 성공/실패 시나리오 대비
- 에지 케이스 테스트

**테스트 카테고리**:
1. **채팅방 Use Cases**:
   - 채팅방 생성 성공/실패
   - 중복 채팅방 처리
   - 채팅 목록 필터링

2. **메시지 Use Cases**:
   - 텍스트 메시지 전송
   - 이미지/비디오 메시지 전송
   - 메시지 수정/삭제

3. **투표 Use Cases**:
   - 투표 카드 생성
   - 투표 제출 및 중복 방지
   - 투표 종료 처리

**Mock 객체**:
- MockChatRepository
- MockMessageRepository
- MockMediaUploadService
- MockVoteStateCoordinator

## ⚠️ 주의사항

### 1. 단일 책임 원칙
- 하나의 Use Case = 하나의 비즈니스 작업
- 복잡한 로직은 여러 Use Case로 분리
- Use Case 간 의존성 최소화

### 2. 의존성 역전
- Repository 인터페이스에만 의존
- 구체적 구현체 참조 금지
- DI를 통한 의존성 주입

### 3. 에러 처리
- Either 패턴 일관성 유지
- 비즈니스 에러와 기술적 에러 구분
- 사용자 친화적 에러 메시지

## ✅ 체크리스트

### 구현 완료
- [ ] CreateChatUseCase
- [ ] GetChatListUseCase
- [ ] SendMessageUseCase
- [ ] CreateVoteCardUseCase
- [ ] SubmitVoteUseCase
- [ ] CreateGroupChatUseCase

### 테스트
- [ ] 각 Use Case 단위 테스트
- [ ] 통합 시나리오 테스트
- [ ] 에러 케이스 테스트

## 📚 참고 자료

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Use Case Pattern](https://martinfowler.com/eaaDev/UseCase.html)
- [Dartz Package](https://pub.dev/packages/dartz)

---

*이 문서는 Feature-First Architecture의 Chat Use Case Layer 가이드입니다.*
*최종 업데이트: 2025-08-24*