# Post Feature - 기능 개요

> **Version**: 1.0.0
> **Last Updated**: 2025-01-20
> **Clean Architecture**: v4.0

## 📱 개요

Post Feature는 **게시물 조회 및 표시**를 담당하는 기능 모듈입니다. Versus Space 앱의 핵심 기능으로, 사용자들이 생성한 A vs B 비교 게시물을 다양한 방식으로 조회하고 표시합니다.

### 핵심 특징
- ✅ **Clean Architecture v4.0** 준수
- ✅ **Firebase 의존성 완전 분리** (Domain Layer)
- ✅ **실시간 스트림 업데이트** 지원
- ✅ **5가지 조회 전략** (Feed, Detail, UserPosts, Trending, Popular)
- ✅ **BaseListProvider Mixin** 패턴으로 코드 재사용성 극대화
- ✅ **Result 패턴** 기반 에러 처리
- ✅ **페이지네이션 및 필터링** 지원

---

## 🎯 주요 기능

### 1. Feed 시스템
**홈 피드에서 게시물 목록 표시**

- **정렬 옵션**:
  - `latest`: 최신순
  - `popular`: 인기순 (좋아요 수)
  - `mostVoted`: 투표 참여 많은 순
  - `trending`: 트렌딩 (댓글 + 좋아요×2)

- **필터링**:
  - 상태 필터 (`status`)
  - 사용자 필터 (`userId`)
  - 이미지 유무 (`hasImages`)
  - 익명 여부 (`isAnonymous`)
  - 날짜 범위 (`startDate`, `endDate`)

- **페이지네이션**:
  - 초기 로드: 20개
  - 무한 스크롤 지원
  - `lastDocumentId` 기반 커서 페이지네이션

### 2. 게시물 상세 조회
**단일 게시물의 전체 정보 표시**

- 게시물 ID로 조회
- 실시간 업데이트 지원
- 투표 상태 추적
- 댓글/좋아요 수 실시간 반영

### 3. 사용자별 게시물
**특정 사용자가 작성한 게시물 목록**

- 사용자 ID로 필터링
- 익명 게시물 제외
- 최신순 정렬
- 제한 없는 조회 가능

### 4. 트렌딩 게시물
**현재 인기 있는 게시물**

- 댓글 수 + (좋아요×2) 점수 기반
- 최근 24시간 내 활동 게시물
- 상위 20개 표시

### 5. 인기 게시물
**누적 인기도 기반 게시물**

- 좋아요, 댓글, 공유 수 종합
- 선택적 시간 창 필터링 (`timeWindow`)
- 상위 20개 표시

---

## 🔐 보안 특징

### Domain Layer 격리
```
✅ Firebase 의존성 완전 제거
✅ 순수 Dart 코드만 사용
✅ Testability 극대화
```

### 인터페이스 기반 설계
- Repository Interface (`IPostDisplayRepositoryV2`)
- DataSource Interface (`IPostDisplayDataSource`)
- 의존성 역전 원칙(DIP) 준수

---

## 📊 사용자 플로우

```
[홈 Feed 진입]
    ↓
[게시물 목록 표시]
    ↓
[스크롤 → 페이지네이션]
    ↓
[게시물 선택]
    ↓
[상세 페이지 이동]
    ↓
[투표 참여]
    ↓
[댓글 작성]
```

### Feed 필터링/정렬 플로우
```
[Feed 화면]
    ↓
[정렬 옵션 선택]
    ├─ 최신순
    ├─ 인기순
    ├─ 투표 많은 순
    └─ 트렌딩
    ↓
[필터 적용]
    ├─ 이미지만
    ├─ 특정 사용자
    └─ 날짜 범위
    ↓
[결과 표시]
```

---

## 🎨 UI 화면 구성

### 1. 홈 Feed (`HomePageWidget`)
- 게시물 카드 목록
- 무한 스크롤
- 정렬/필터 버튼
- Pull-to-refresh

### 2. 게시물 상세 (`PostDetailPage`)
- 게시물 전체 내용
- A/B 옵션 표시
- 투표 결과 바
- 댓글 섹션

### 3. 트렌딩 페이지 (`TrendingPostsPage`)
- 트렌딩 게시물 그리드
- 실시간 업데이트
- 인기 지표 표시

### 4. 인기 페이지 (`PopularPostsPage`)
- 인기 게시물 목록
- 누적 통계 표시
- 시간대별 필터링

---

## 🔄 상태 관리

### BaseListProvider Mixin 패턴
**5개 Provider가 공통 기능을 상속**

```dart
// 공통 기능 (150+ 줄 중복 제거)
mixin BaseListProvider<TState extends Enum, TModel> {
  - 에러 메시지 관리
  - 로딩 상태 설정
  - Failure → 사용자 메시지 변환
  - 스트림 에러 처리
}
```

### Provider 계층 구조
```
ChangeNotifier
    └─ BaseListProvider<TState, TModel>
        ├─ FeedProvider
        ├─ PostDetailProvider
        ├─ UserPostsProvider
        ├─ TrendingPostsProvider
        └─ PopularPostsProvider
```

### 상태 열거형
각 Provider는 고유한 상태 열거형을 가짐:

```dart
// FeedProvider
enum FeedLoadingState {
  initial, loading, loaded, loadingMore, error, empty
}

// PostDetailProvider
enum PostDetailLoadingState {
  initial, loading, loaded, error, notFound
}

// 기타 Provider들도 유사한 패턴
```

---

## 🌐 다국어 지원

현재 **영어(en)** 및 **한국어(ko)** 지원:
- 에러 메시지 현지화
- 로딩 상태 메시지
- UI 레이블

**지원 예정**: 독일어(de), 일본어(ja)

---

## 📈 성능 최적화

### 1. 실시간 스트림 관리
```dart
// ✅ 메모리 누수 방지
StreamSubscription? _subscription;

void dispose() {
  _subscription?.cancel();
  super.dispose();
}
```

### 2. 중복 코드 제거
- BaseListProvider mixin으로 **150+ 줄 중복 제거**
- 일관된 에러 처리 로직
- 유지보수성 향상

### 3. 효율적인 쿼리
- Firestore 인덱스 활용
- 필요한 필드만 조회
- 페이지네이션으로 대역폭 절약

### 4. 에러 복구
```dart
// ✅ Result 패턴으로 안전한 에러 처리
result.fold(
  (failure) => handleError(failure),
  (data) => processSuccess(data),
);
```

---

## 🔧 기술 스택

### 아키텍처
- **Clean Architecture v4.0**
- **Domain-Driven Design (DDD)**
- **Result Pattern** (Success/Failure)

### 의존성
- **Firebase Firestore**: 데이터 저장소
- **GetIt**: 의존성 주입
- **Provider**: 상태 관리
- **Equatable**: Value Object 비교

### 패턴
- **Repository Pattern**: 데이터 접근 추상화
- **UseCase Pattern**: 비즈니스 로직 캡슐화
- **Mixin Pattern**: 코드 재사용 (BaseListProvider)
- **DTO Pattern**: 데이터 전송 객체
- **Mapper Pattern**: DTO ↔ Domain 변환

---

## 📱 지원 플랫폼

- ✅ **iOS** (13.0+)
- ✅ **Android** (API 24+)
- ✅ **Web**
- ✅ **macOS**

---

## 🚀 향후 계획

### Phase 1: 검색 기능 강화
- [ ] Algolia 통합
- [ ] 전문 검색 (Full-text search)
- [ ] 태그 기반 검색

### Phase 2: 추천 시스템
- [ ] AI 기반 게시물 추천
- [ ] 사용자 취향 학습
- [ ] 개인화된 Feed

### Phase 3: 오프라인 지원
- [ ] 로컬 캐시 구현
- [ ] 오프라인 읽기 모드
- [ ] 동기화 전략

### Phase 4: 성능 개선
- [ ] 이미지 레이지 로딩
- [ ] 가상 스크롤링
- [ ] 프리페칭 전략

---

## 📚 관련 문서

- [API Reference](./API_REFERENCE.md) - 상세 API 문서
- [Usage Guide](./USAGE_GUIDE.md) - 사용 가이드
- [Migration Guide](../../docs/migration/POST_FEATURE_MIGRATION.md) - 마이그레이션 가이드

---

**작성자**: Claude Code Assistant
**마지막 리뷰**: 2025-01-20
