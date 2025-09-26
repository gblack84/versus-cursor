# 📦 Posts Presentation Providers

> Posts Feature의 상태 관리 레이어 - Provider 패턴 기반 상태 관리

## 📋 개요

이 디렉토리는 Posts Feature의 **Presentation Layer 상태 관리**를 담당합니다. Provider 패턴을 사용하여 UI와 비즈니스 로직 사이의 상태를 관리합니다.

### 🎯 목적
- **상태 관리**: UI 컴포넌트의 상태 중앙 관리
- **비즈니스 로직 분리**: UI와 로직의 명확한 분리
- **반응형 업데이트**: 상태 변경 시 자동 UI 업데이트
- **성능 최적화**: 불필요한 리빌드 방지

## 🏗️ 디렉토리 구조

```
providers/
├── post_provider.dart              # 게시물 상태 관리
├── feed_provider.dart              # 피드 상태 관리
├── media_provider.dart             # 미디어 상태 관리
├── vote_provider.dart              # 투표 상태 관리
├── creation_provider.dart          # 게시물 생성 상태 관리
├── moderation_provider.dart        # 검열 상태 관리
└── target_audience_provider.dart   # 타겟 오디언스 상태 관리
```

## 📝 Provider 구현 상세

### 1. PostProvider

**책임**: 개별 게시물 상태 관리 및 상호작용

**주요 기능**:
- 게시물 로드 및 캐싱
- 게시물 업데이트/삭제
- 좋아요 토글
- 댓글 관리
- 에러 처리

**상태 변수**:
- `currentPost`: 현재 선택된 게시물
- `postCache`: 게시물 캐시 맵
- `isLoading`: 로딩 상태
- `errorMessage`: 에러 메시지

**주요 메서드**:
- `loadPost(postId)`: 게시물 로드
- `updatePost(post)`: 게시물 업데이트
- `deletePost(postId)`: 게시물 삭제
- `toggleLike()`: 좋아요 토글
- `clearCache()`: 캐시 초기화

### 2. FeedProvider

**책임**: 피드 목록 관리 및 페이지네이션

**주요 기능**:
- 피드 초기 로드
- 무한 스크롤 페이지네이션
- 카테고리/태그 필터링
- 정렬 기능
- 실시간 업데이트

**상태 변수**:
- `posts`: 게시물 목록
- `isLoading/isLoadingMore`: 로딩 상태
- `hasMore`: 추가 데이터 여부
- `lastDocument`: 페이지네이션 커서
- `currentCategory/currentTags`: 필터 상태

**주요 메서드**:
- `loadFeed(category, tags)`: 피드 로드
- `loadMore()`: 추가 데이터 로드
- `refreshFeed()`: 피드 새로고침
- `sortPosts(sortType)`: 정렬
- `changeCategory(category)`: 카테고리 변경
- `changeTags(tags)`: 태그 변경

### 3. MediaProvider

**책임**: 미디어 선택, 편집, 업로드 관리

**주요 기능**:
- 이미지/비디오 선택
- 미디어 편집 상태 관리
- 업로드 진행률 추적
- 레이아웃 자동 결정
- 스마트 레이아웃 시스템

**상태 변수**:
- `selectedImagesA/B`: 선택된 이미지
- `assetEntitiesA/B`: AssetEntity 목록
- `aspectRatiosA/B`: 이미지 비율
- `isVerticalLayout`: 레이아웃 방향
- `uploadProgress`: 업로드 진행률
- `isVideoSelectedA/B`: 비디오 선택 상태

**주요 메서드**:
- `selectImagesA/B(assets)`: 이미지 선택
- `removeImageA/B(index)`: 이미지 제거
- `reorderImagesA(oldIndex, newIndex)`: 순서 변경
- `uploadImages(userId, postId)`: 업로드
- `toggleLayout()`: 레이아웃 전환
- `setMediaTypeA/B(isVideo)`: 미디어 타입 설정

### 4. VoteProvider

**책임**: 투표 상태 관리 및 실시간 업데이트

**주요 기능**:
- 투표 제출
- 실시간 투표 상태 업데이트
- 투표 타이머 관리
- 투표 통계 계산
- 중복 투표 방지

**상태 변수**:
- `voteStates`: 투표 상태 맵
- `activeVotePostId`: 활성 투표 ID
- `isSubmitting`: 제출 중 상태

**주요 메서드**:
- `startVote(postId, endTime)`: 투표 시작
- `submitVote(postId, userId, option)`: 투표 제출
- `canVote(postId, userId)`: 투표 가능 여부
- `getRemainingTime(postId)`: 남은 시간
- `getPercentageA/B(postId)`: 투표 퍼센티지

### 5. CreationProvider

**책임**: 게시물 생성 워크플로우 관리

**주요 기능**:
- 다단계 생성 프로세스
- 필드 유효성 검사
- AI 콘텐츠 검열
- 미디어 업로드 조정
- 타겟 오디언스 설정

**상태 변수**:
- `question/description`: 텍스트 필드
- `textA/textB`: 옵션 텍스트
- `targetAudience`: 타겟 설정
- `currentStep`: 현재 단계
- `fieldErrors`: 필드별 에러

**주요 메서드**:
- `setQuestion/Description/TextA/TextB()`: 텍스트 설정
- `setTargetAudience()`: 타겟 설정
- `nextStep()`: 다음 단계
- `previousStep()`: 이전 단계
- `createPost(userId)`: 게시물 생성
- `validateContent()`: 콘텐츠 검증

### 6. ModerationProvider

**책임**: 콘텐츠 검열 상태 관리

**주요 기능**:
- 텍스트 검열 상태
- 이미지 검열 상태
- AI 논리 검증
- 검열 결과 캐싱
- 차단 사유 관리

**상태 변수**:
- `moderationResults`: 검열 결과 맵
- `isValidating`: 검증 중 상태
- `blockReasons`: 차단 사유 목록

**주요 메서드**:
- `validateText(text)`: 텍스트 검증
- `validateImages(urls)`: 이미지 검증
- `validateLogic(question, optionA, optionB)`: 논리 검증
- `getModerationResult(contentId)`: 결과 조회

### 7. TargetAudienceProvider

**책임**: 타겟 오디언스 선택 및 관리

**주요 기능**:
- 타겟 모드 선택 (Quick/Public/Custom/Test)
- 필터 조건 설정
- AI 추천 사용자 관리
- 알림 발송 상태 추적

**상태 변수**:
- `selectedMode`: 선택된 모드
- `targetFilters`: 필터 조건
- `recommendedUsers`: 추천 사용자 목록
- `notificationsSent`: 발송 상태

**주요 메서드**:
- `setMode(mode)`: 모드 설정
- `setFilters(filters)`: 필터 설정
- `getRecommendedUsers()`: 추천 사용자 조회
- `sendNotifications(userIds)`: 알림 발송

## 🔄 Provider 사용 패턴

### Provider 등록 (main.dart)
```
MultiProvider로 모든 Provider 등록
의존성 주입 설정
Provider 간 통신 설정
```

### Screen에서 사용
```
Consumer<Provider>로 상태 구독
context.read<Provider>()로 메서드 호출
context.watch<Provider>()로 상태 감시
```

### Provider 간 통신
```
의존성 주입으로 다른 Provider 참조
이벤트 기반 통신
Stream 기반 실시간 업데이트
```

## 🔄 마이그레이션 체크리스트

### Phase 1: 기본 Provider 생성
- [ ] PostProvider 구현
- [ ] FeedProvider 구현
- [ ] MediaProvider 구현
- [ ] VoteProvider 구현

### Phase 2: 복합 Provider 생성
- [ ] CreationProvider 구현
- [ ] ModerationProvider 구현
- [ ] TargetAudienceProvider 구현

### Phase 3: Provider 통합
- [ ] MultiProvider 설정
- [ ] Dependency Injection 설정
- [ ] Provider 간 통신 구현

### Phase 4: 테스트
- [ ] Provider 단위 테스트
- [ ] Widget 테스트
- [ ] 통합 테스트

## ⚠️ 주의사항

1. **메모리 관리**: dispose()에서 리소스 정리
2. **상태 업데이트**: notifyListeners() 호출 최적화
3. **에러 처리**: 사용자 친화적 에러 메시지
4. **성능**: 불필요한 리빌드 방지
5. **테스트**: 모든 Provider에 대한 단위 테스트 작성

---

*이 문서는 Posts Feature의 Presentation Providers 레이어 구현 가이드입니다.*