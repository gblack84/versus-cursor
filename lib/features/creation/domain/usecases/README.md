# 📦 Posts Domain Use Cases

> Posts Feature의 비즈니스 로직 및 Use Case 구현 사양

## 📋 개요

이 디렉토리는 Posts Feature의 핵심 비즈니스 로직을 Use Case 패턴으로 구현합니다. 각 Use Case는 단일 책임 원칙을 따르며, 특정 비즈니스 작업을 수행합니다.

## 🏗️ 디렉토리 구조

```
domain/usecases/
├── post/                    # 게시물 관련 Use Cases
│   ├── create_post_usecase.dart
│   ├── update_post_usecase.dart
│   ├── delete_post_usecase.dart
│   ├── get_post_detail_usecase.dart
│   └── get_feed_usecase.dart
├── media/                   # 미디어 관련 Use Cases
│   ├── analyze_aspect_ratio_usecase.dart
│   ├── calculate_layout_usecase.dart
│   ├── optimize_image_usecase.dart
│   └── process_video_usecase.dart
├── vote/                    # 투표 관련 Use Cases
│   ├── start_vote_usecase.dart
│   ├── submit_vote_usecase.dart
│   ├── complete_vote_usecase.dart
│   └── get_vote_results_usecase.dart
├── validation/              # 유효성 검사 Use Cases
│   ├── validate_content_usecase.dart
│   ├── moderate_content_usecase.dart
│   └── check_permissions_usecase.dart
└── interaction/             # 상호작용 Use Cases
    ├── like_post_usecase.dart
    ├── comment_post_usecase.dart
    ├── share_post_usecase.dart
    └── report_post_usecase.dart
```

## 📝 주요 Use Cases 사양

### 1. CreatePostUseCase

**책임**: 새로운 게시물 생성 및 검증

**주요 단계**:
1. 콘텐츠 유효성 검사
2. AI 콘텐츠 검열 (Perspective API + Gemini)
3. 미디어 업로드 (이미지/비디오)
4. 레이아웃 최적화 결정
5. Firestore 저장
6. 알림 발송 트리거

**입력 파라미터**:
- 사용자 정보 (userId, userName, profilePic)
- 질문 및 설명
- A/B 옵션 콘텐츠 (텍스트, 이미지, 비디오, YouTube)
- AspectRatio 정보
- 타겟 오디언스 설정

**반환값**: `Either<Failure, PostModel>`

### 2. SubmitVoteUseCase

**책임**: 사용자 투표 제출 및 검증

**주요 단계**:
1. 게시물 존재 여부 확인
2. 투표 가능 여부 검증 (시간, 상태)
3. 중복 투표 방지
4. 투표 저장 (트랜잭션)
5. 투표 수 업데이트
6. 투표 완료 체크

**입력 파라미터**:
- postId, userId, userName
- selectedOption ('A' or 'B')
- 투표 이유 (선택)
- 익명 여부

**반환값**: `Either<Failure, VoteModel>`

### 3. ModerateContentUseCase

**책임**: 다단계 콘텐츠 검열

**검열 단계**:
1. **텍스트 검열** (Perspective API)
   - 독성, 욕설, 위협 감지
   - 임계값: 0.7
2. **이미지 검열** (Cloud Vision API)
   - 성인물, 폭력, 의료 콘텐츠 감지
   - SafeSearch 레벨 확인
3. **AI 로직 검증** (Gemini)
   - A/B 옵션 논리성 검증
   - 공정성 확인

**입력 파라미터**:
- texts: 검열할 텍스트 목록
- images: 검열할 이미지 URL 목록
- useAIValidation: AI 검증 사용 여부

**반환값**: `Either<Failure, ModerationResult>`

### 4. AnalyzeAspectRatioUseCase

**책임**: 스마트 레이아웃 결정

**분석 로직**:
1. A/B 옵션 평균 비율 계산
2. 세로형/가로형/정사각형 분류
3. 최적 레이아웃 결정
   - 세로형 + 세로형 → 가로 배치
   - 가로형 + 가로형 → 세로 배치
   - 혼합형 → 극단적 비율 우선
4. 동적 박스 크기 계산

**입력 파라미터**:
- aspectRatiosA/B: 이미지 비율 배열
- containerWidth/Height: 컨테이너 크기

**반환값**: `Either<Failure, LayoutAnalysis>`

### 5. GetFeedUseCase

**책임**: 피드 데이터 조회 및 페이지네이션

**기능**:
- 무한 스크롤 지원
- 카테고리/태그 필터링
- 정렬 옵션 (최신순, 인기순, 논란순)
- 캐싱 전략 적용

**입력 파라미터**:
- lastDocument: 페이지네이션 커서
- limit: 가져올 개수
- filters: 필터 옵션
- sortBy: 정렬 기준

**반환값**: `Either<Failure, List<PostModel>>`

## 🎯 Use Case 패턴

### 기본 구조
```dart
@injectable
class SomeUseCase {
  final Repository _repository;
  
  SomeUseCase(this._repository);
  
  Future<Either<Failure, Result>> call(Params params) async {
    // 비즈니스 로직
  }
}
```

### Either 패턴 활용
- **Right**: 성공 케이스
- **Left**: 실패 케이스 (Failure 타입)
- 명시적 에러 처리

## 📦 의존성 주입

**Injectable/GetIt 활용**:
- `@injectable`: Use Case 등록
- `@lazySingleton`: 싱글톤 패턴
- 자동 의존성 해결

## 🧪 테스트 전략

### 단위 테스트
- 모든 Use Case에 대한 테스트 작성
- Mock Repository 활용
- 성공/실패 시나리오 모두 검증

### 테스트 커버리지
- 목표: 80% 이상
- 핵심 비즈니스 로직 100% 커버

## 🔄 마이그레이션 체크리스트

### Phase 1: 기본 Use Cases
- [ ] CreatePostUseCase 구현
- [ ] UpdatePostUseCase 구현
- [ ] DeletePostUseCase 구현
- [ ] GetPostDetailUseCase 구현
- [ ] GetFeedUseCase 구현

### Phase 2: 투표 Use Cases
- [ ] StartVoteUseCase 구현
- [ ] SubmitVoteUseCase 구현
- [ ] CompleteVoteUseCase 구현
- [ ] GetVoteResultsUseCase 구현

### Phase 3: 미디어 Use Cases
- [ ] AnalyzeAspectRatioUseCase 구현
- [ ] CalculateLayoutUseCase 구현
- [ ] OptimizeImageUseCase 구현
- [ ] ProcessVideoUseCase 구현

### Phase 4: 검증 Use Cases
- [ ] ValidateContentUseCase 구현
- [ ] ModerateContentUseCase 구현
- [ ] CheckPermissionsUseCase 구현

## ⚠️ 주의사항

1. **단일 책임**: 각 Use Case는 하나의 비즈니스 작업만 수행
2. **에러 처리**: Either 패턴으로 명확한 에러 처리
3. **의존성 주입**: Injectable로 의존성 관리
4. **테스트 가능**: 모든 Use Case는 테스트 가능하도록 설계
5. **비즈니스 로직 집중**: UI나 데이터 접근 로직 배제

---

*이 문서는 Posts Feature의 Domain Use Cases 레이어 사양입니다.*
*작성일: 2025-08-25*