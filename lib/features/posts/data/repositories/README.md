# 📦 Posts Data Repositories

> Posts Feature의 Repository 구현체 - 데이터 접근 추상화 레이어

## 📋 개요

이 디렉토리는 Posts Feature의 Repository 패턴 구현체를 포함합니다. Domain Layer의 Repository 인터페이스를 구현하며, 다양한 데이터 소스를 통합 관리합니다.

## 🏗️ 디렉토리 구조

```
data/repositories/
├── implementations/              # Repository 구현체
│   ├── post_repository_impl.dart
│   ├── media_repository_impl.dart
│   ├── vote_repository_impl.dart
│   ├── moderation_repository_impl.dart
│   └── audience_repository_impl.dart
├── mixins/                      # 재사용 가능한 Mixin
│   ├── cache_mixin.dart
│   ├── error_handler_mixin.dart
│   ├── firebase_mixin.dart
│   └── pagination_mixin.dart
└── mappers/                     # 데이터 변환 매퍼
    ├── post_mapper.dart
    ├── media_mapper.dart
    └── vote_mapper.dart
```

## 📝 Repository 구현체 명세

### 1. PostRepositoryImpl

**책임**: 게시물 데이터 관리 및 캐싱 전략 구현

**주요 메서드**:
- `createPost(PostModel)`: 게시물 생성 및 캐시 업데이트
- `getPost(String)`: 3-Layer 캐싱 전략으로 게시물 조회
- `getFeed(limit, lastDocument, category, tags)`: 피드 페이지네이션
- `updatePost(PostModel)`: 게시물 수정 및 캐시 동기화
- `deletePost(String)`: 소프트 삭제 처리
- `updateVoteCount(postId, option, userId)`: 트랜잭션 기반 투표 업데이트
- `getPostStream(String)`: 실시간 게시물 스트림

**캐싱 전략**:
1. Memory Cache (L1) - 즉시 응답
2. Local Database (L2) - 10-30ms
3. Remote Firestore (L3) - 50-100ms

**의존성**:
- FirebasePostDatasource
- PostLocalDatasource  
- PostCacheService
- FirebaseFirestore

### 2. MediaRepositoryImpl

**책임**: 미디어 파일 업로드/다운로드 및 처리

**주요 메서드**:
- `uploadImages(List<File>, path)`: 이미지 병렬 업로드 및 썸네일 생성
- `uploadVideo(File, path)`: 비디오 압축 및 업로드
- `deleteMedia(String)`: 미디어 삭제 및 캐시 정리
- `downloadMedia(String)`: 미디어 다운로드 및 캐싱

**미디어 처리**:
- 이미지 최적화 (1920px, 85% 품질)
- 썸네일 생성 (200x200)
- 비디오 압축 (medium quality)
- 메타데이터 관리

**의존성**:
- CloudStorageDatasource
- MediaCacheService
- ImageProcessingService
- VideoProcessingService

### 3. VoteRepositoryImpl

**책임**: 투표 시스템 관리 및 상태 조정

**주요 메서드**:
- `submitVote(VoteModel)`: 투표 제출 (트랜잭션 보장)
- `getVoteStatistics(String)`: 투표 통계 조회
- `getVoteUpdatesStream(String)`: 실시간 투표 업데이트

**투표 검증**:
- 중복 투표 방지
- 시간 제한 확인
- 투표 상태 검증

**의존성**:
- FirebaseVoteDatasource
- VoteLocalDatasource
- VoteStateCoordinator
- FirebaseFirestore

### 4. ModerationRepositoryImpl

**책임**: 다단계 콘텐츠 검열 시스템

**주요 메서드**:
- `moderateText(List<String>)`: 텍스트 검열 (Perspective API)
- `moderateImage(String)`: 이미지 검열 (Cloud Vision)
- `validateWithAI(question, optionA, optionB)`: AI 논리 검증 (Gemini)

**검열 기준**:
- 텍스트: 독성 0.8, 위협 0.7, 욕설 0.8
- 이미지: 성인물, 폭력, 선정성
- AI: 논리성, 공정성, 명확성

**의존성**:
- PerspectiveApiDatasource
- GeminiApiDatasource
- CloudVisionDatasource
- ModerationCacheService

## 📦 Mixin 명세

### CacheMixin

**책임**: 캐시 관련 공통 기능 제공

**주요 기능**:
- `isCacheValid(DateTime?)`: 캐시 유효성 검증 (5분 TTL)
- `generateCacheKey(Map)`: 캐시 키 생성

### ErrorHandlerMixin

**책임**: 통합 에러 처리

**주요 기능**:
- `handleError<T>(operation)`: Either 패턴 에러 처리
- Firebase, Network, Timeout 예외 처리
- Unknown 예외 폴백

## 🔄 마이그레이션 체크리스트

### Phase 1: Repository 인터페이스
- [ ] PostRepository 인터페이스 정의
- [ ] MediaRepository 인터페이스 정의
- [ ] VoteRepository 인터페이스 정의
- [ ] ModerationRepository 인터페이스 정의

### Phase 2: Repository 구현체
- [ ] PostRepositoryImpl 구현
- [ ] MediaRepositoryImpl 구현
- [ ] VoteRepositoryImpl 구현
- [ ] ModerationRepositoryImpl 구현

### Phase 3: Mixin 구현
- [ ] CacheMixin 구현
- [ ] ErrorHandlerMixin 구현
- [ ] FirebaseMixin 구현
- [ ] PaginationMixin 구현

### Phase 4: 테스트
- [ ] Repository 단위 테스트
- [ ] Mixin 테스트
- [ ] 통합 테스트

## ⚠️ 주의사항

1. **트랜잭션 처리**: 중요한 작업은 Firestore 트랜잭션 사용
2. **캐싱 전략**: 3-Layer 캐싱 (Memory → Local → Remote)
3. **에러 처리**: Either 패턴으로 명확한 에러 전달
4. **오프라인 지원**: 네트워크 실패 시 로컬 캐시 활용

---

*이 문서는 Posts Feature의 Data Repositories 레이어 구현 가이드입니다.*