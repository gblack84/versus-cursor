# 📦 Posts Domain Models

> Posts Feature의 도메인 모델 레이어 - 비즈니스 엔티티 및 값 객체

## 📋 개요

이 디렉토리는 Posts Feature의 핵심 비즈니스 모델을 포함합니다. Clean Architecture의 Domain Layer로서 외부 의존성이 없는 순수한 비즈니스 로직을 담당합니다.

## 🏗️ 디렉토리 구조

```
domain/models/
├── entities/               # 핵심 비즈니스 엔티티
│   ├── post_model.dart          # 게시물 엔티티
│   ├── comment_model.dart       # 댓글 엔티티
│   ├── vote_model.dart          # 투표 엔티티
│   ├── media_model.dart         # 미디어 엔티티
│   ├── encoding_model.dart      # 인코딩 엔티티
│   └── target_audience_model.dart # 타겟 오디언스 엔티티
├── value_objects/          # 불변 값 객체
│   ├── post_status.dart         # 게시물 상태
│   ├── vote_status.dart         # 투표 상태
│   ├── content_type.dart        # 콘텐츠 타입
│   ├── moderation_status.dart   # 검열 상태
│   └── layout_type.dart         # 레이아웃 타입
└── aggregates/             # 도메인 집합체
    ├── post_aggregate.dart       # 게시물 집합체
    └── vote_aggregate.dart       # 투표 집합체
```

## 📝 주요 모델 명세

### 1. PostModel (게시물 엔티티)

**책임**: Versus 게시물의 모든 데이터를 캡슐화

**주요 필드**:
- `id`: String - 게시물 고유 식별자
- `userId`: String - 작성자 ID
- `userName`: String - 작성자 이름
- `userProfilePic`: String? - 프로필 사진 URL

**A vs B 콘텐츠**:
- `optionA`: Map<String, dynamic> - A 옵션 데이터
- `optionB`: Map<String, dynamic> - B 옵션 데이터
- `postQuestion`: String - 질문 텍스트
- `postDescription`: String? - 설명 텍스트

**미디어 콘텐츠**:
- `imageUrlsA`: List<String>? - A 이미지 URL 리스트
- `imageUrlsB`: List<String>? - B 이미지 URL 리스트
- `videoUrlA`: String? - A 비디오 URL
- `videoUrlB`: String? - B 비디오 URL
- `youtubeUrlA`: String? - A YouTube URL
- `youtubeUrlB`: String? - B YouTube URL

**레이아웃 정보**:
- `layoutType`: String - 'horizontal', 'vertical', 'single'
- `aspectRatiosA`: List<double>? - A 이미지 비율
- `aspectRatiosB`: List<double>? - B 이미지 비율

**투표 정보**:
- `votesA`: int - A 투표 수
- `votesB`: int - B 투표 수
- `voteStartTime`: DateTime? - 투표 시작 시간
- `voteEndTime`: DateTime? - 투표 종료 시간
- `voteStatus`: String - 투표 상태
- `voteCompleted`: bool - 투표 완료 여부
- `votedUserIds`: List<String>? - 투표한 사용자 ID 리스트

### 2. CommentModel (댓글 엔티티)

**책임**: 게시물에 대한 댓글 데이터 관리

**주요 필드**:
- `id`: String - 댓글 고유 식별자
- `postId`: String - 게시물 ID
- `userId`: String - 작성자 ID
- `content`: String - 댓글 내용
- `isAnonymous`: bool - 익명 여부
- `likes`: int - 좋아요 수
- `dislikes`: int - 싫어요 수
- `parentCommentId`: String? - 부모 댓글 ID (답글인 경우)

### 3. VoteModel (투표 엔티티)

**책임**: 개별 투표 정보 관리

**주요 필드**:
- `id`: String - 투표 고유 식별자
- `postId`: String - 게시물 ID
- `userId`: String - 투표자 ID
- `selectedOption`: String - 선택한 옵션 ('A' or 'B')
- `votedAt`: DateTime - 투표 시간
- `reason`: String? - 투표 이유

### 4. TargetAudienceModel (타겟 오디언스 모델)

**책임**: 알림 대상 사용자 정보 관리

**모드 타입**:
- `quick`: AI 기반 자동 추천
- `public`: 랜덤 사용자 선택
- `custom`: 사용자 정의 필터링
- `test`: 테스트 모드

**필터링 옵션**:
- `interests`: List<String>? - 관심사 필터
- `ageRange`: RangeValues? - 연령대 필터
- `gender`: String? - 성별 필터
- `jobCategories`: List<String>? - 직업 카테고리
- `expertiseAreas`: List<String>? - 전문 분야

## 📦 Value Objects (값 객체)

### PostStatus (게시물 상태)

**상태 종류**:
- `draft`: 임시저장
- `published`: 게시됨
- `voting`: 투표 진행중
- `completed`: 투표 완료
- `archived`: 보관됨
- `deleted`: 삭제됨

### ContentType (콘텐츠 타입)

**타입 종류**:
- `text`: 텍스트만
- `image`: 이미지
- `video`: 비디오
- `youtube`: YouTube
- `mixed`: 혼합

### LayoutType (레이아웃 타입)

**레이아웃 종류**:
- `horizontal`: 가로 배치 (좌우)
- `vertical`: 세로 배치 (위아래)
- `single`: 단일 박스

## 🏗️ Aggregates (집합체)

### PostAggregate (게시물 집합체)

**책임**: 게시물 관련 엔티티들의 집합 관리 및 비즈니스 규칙 적용

**구성 요소**:
- `post`: PostModel - 메인 게시물
- `comments`: List<CommentModel> - 댓글 리스트
- `votes`: List<VoteModel> - 투표 리스트
- `targetAudience`: TargetAudienceModel? - 타겟 오디언스

**비즈니스 규칙**:
- `canVote()`: 투표 가능 여부 검증
- `canEdit()`: 수정 가능 여부 검증
- `canDelete()`: 삭제 가능 여부 검증

**통계 계산**:
- `votePercentageA`: A 옵션 투표 비율
- `votePercentageB`: B 옵션 투표 비율
- `remainingVoteTime`: 남은 투표 시간

## 🔄 마이그레이션 체크리스트

### Phase 1: 엔티티 생성
- [ ] PostModel 마이그레이션 (posts_model.dart)
- [ ] CommentModel 마이그레이션 (comments_model.dart)
- [ ] VoteModel 생성
- [ ] MediaModel 생성
- [ ] TargetAudienceModel 마이그레이션

### Phase 2: Value Objects 생성
- [ ] PostStatus enum 생성
- [ ] VoteStatus enum 생성
- [ ] ContentType enum 생성
- [ ] ModerationStatus enum 생성
- [ ] LayoutType enum 생성

### Phase 3: Aggregates 구현
- [ ] PostAggregate 구현
- [ ] VoteAggregate 구현
- [ ] 비즈니스 규칙 검증

### Phase 4: 테스트 작성
- [ ] 모델 시리얼라이제이션 테스트
- [ ] 비즈니스 규칙 테스트
- [ ] Value Object 테스트

## 📚 의존성

```yaml
dependencies:
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  cloud_firestore: ^5.5.0
  
dev_dependencies:
  freezed: ^2.4.5
  json_serializable: ^6.7.1
  build_runner: ^2.4.6
```

## ⚠️ 주의사항

1. **불변성 유지**: 모든 모델은 `@freezed`로 불변성 보장
2. **Null Safety**: 선택적 필드는 nullable로 명확히 표시
3. **타입 안정성**: dynamic 대신 구체적 타입 사용
4. **비즈니스 규칙**: Aggregate에서만 비즈니스 로직 구현

---

*이 문서는 Posts Feature의 Domain Models 레이어 구현 가이드입니다.*