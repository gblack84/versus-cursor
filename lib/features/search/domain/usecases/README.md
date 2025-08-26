# 📂 Search UseCases

> 검색 기능의 비즈니스 로직 실행 단위

## 📋 개요

UseCases는 단일 비즈니스 기능을 캡슐화한 클래스입니다. 각 UseCase는 하나의 특정 작업만을 수행하며, Clean Architecture의 Application Business Rules를 구현합니다.

## 🎯 UseCase 원칙

### 핵심 원칙
- **단일 책임**: 하나의 UseCase = 하나의 비즈니스 액션
- **의존성 역전**: Repository 인터페이스에만 의존
- **재사용성**: 여러 Presenter에서 재사용 가능
- **테스트 용이성**: 독립적으로 테스트 가능
- **비즈니스 규칙 캡슐화**: 도메인 로직 중앙화

### UseCase가 하는 일
- 비즈니스 규칙 실행
- 입력 검증
- Repository 호출 조정
- 에러 처리 및 변환
- 부가 작업 (로깅, 분석 등)

### UseCase가 하지 않는 일
- UI 로직 처리
- 직접적인 데이터 접근
- 상태 관리
- 프레임워크 의존적 작업

## 📁 파일 구조

```
usecases/
├── search_posts_usecase.dart     # 게시물 검색
├── search_users_usecase.dart     # 사용자 검색
├── search_chats_usecase.dart     # 채팅 검색
├── get_search_history_usecase.dart # 검색 기록 조회
├── clear_search_history_usecase.dart # 검색 기록 삭제
├── save_search_query_usecase.dart   # 검색어 저장
├── get_trending_searches_usecase.dart # 인기 검색어
└── get_search_suggestions_usecase.dart # 검색 제안
```

## 💻 UseCase 기본 구조

### Base UseCase 타입
- **UseCase<Type, Params>**: 파라미터를 받는 기본 UseCase
- **NoParamsUseCase<Type>**: 파라미터가 없는 UseCase
- **StreamUseCase<Type, Params>**: 스트림을 반환하는 UseCase

### 파라미터 클래스
- **Params**: Equatable 상속 기본 파라미터 클래스
- **NoParams**: 파라미터가 없음을 나타내는 클래스

## 📂 주요 UseCase 사양

### SearchPostsUseCase

**파라미터:**
- `SearchPostsParams`
  - query: String (필수) - 검색어
  - filter: SearchFilter? (선택) - 검색 필터

**의존성:**
- SearchRepository - 데이터 접근
- SearchValidator - 입력 검증
- AnalyticsService - 분석 이벤트

**주요 프로세스:**
1. 입력 검증 - 검색어 유효성 검사
2. 검색어 정규화 - trim, lowercase, 공백 처리
3. 필터 정규화 - limit(1~100), offset(0~1000) 범위 제한
4. Repository 호출 - 실제 검색 수행
5. 결과 후처리:
   - 차단된 사용자 제외
   - 부적절한 콘텐츠 필터링
   - 최소 관련성 점수 필터
6. 부가 작업:
   - 검색 기록 저장
   - 분석 이벤트 로깅
   - 에러 처리 및 로깅

### SearchUsersUseCase

**파라미터:**
- `SearchUsersParams`
  - query: String (필수) - 검색어
  - limit: int? (선택) - 결과 개수 제한

**검증 규칙:**
- 최소 2글자 이상
- 최대 50글자 제한
- 특수문자 제거 (한글, 영문, 숫자, 공백만 허용)
- 기본 limit: 10개

### GetSearchHistoryUseCase

**파라미터:**
- `GetSearchHistoryParams`
  - userId: String (필수) - 사용자 ID
  - limit: int? (선택) - 조회 개수
  - type: SearchResultType? (선택) - 검색 타입 필터

**특징:**
- StreamUseCase 구현 (실시간 업데이트)
- 시간순 정렬 (최신순)
- 타입별 필터링 지원

### ClearSearchHistoryUseCase

**파라미터:**
- `ClearSearchHistoryParams`
  - userId: String (필수) - 사용자 ID
  - confirmed: bool (기본값: false) - 삭제 확인

**검증:**
- 사용자 인증 확인
- 삭제 확인 필수
- 분석 이벤트 로깅

### SaveSearchQueryUseCase

**파라미터:**
- `SaveSearchQueryParams`
  - query: String (필수) - 검색어
  - type: SearchResultType (필수) - 검색 타입
  - resultCount: int (필수) - 결과 개수

**프로세스:**
1. 중복 검색어 확인
2. 검색 기록 생성
3. Repository 저장
4. 오래된 기록 정리 (선택)

### GetTrendingSearchesUseCase

**파라미터:**
- `GetTrendingParams`
  - limit: int? (선택) - 조회 개수
  - period: Duration? (선택) - 기간

**특징:**
- 캐싱 지원 (30분)
- 트렌드 정보 추가:
  - query: 검색어
  - count: 검색 횟수
  - trend: 상승/하락/유지
  - category: 카테고리 분류

### GetSearchSuggestionsUseCase

**파라미터:**
- `SuggestionsParams`
  - query: String (필수) - 입력중인 검색어
  - limit: int? (선택) - 제안 개수

**프로세스:**
1. 최소 1글자 이상 검증
2. Repository 호출
3. 결과 정렬 및 필터링
4. 중복 제거

## 🧪 테스트 전략

### UseCase 테스트 패턴

**Given-When-Then 패턴:**
1. **Given**: Mock Repository 설정
2. **When**: UseCase 실행
3. **Then**: 결과 검증

**테스트 시나리오:**
- 정상 케이스 테스트
- 검증 실패 케이스
- Repository 에러 처리
- 캐싱 동작 검증
- 분석 이벤트 확인

### Mock 설정
- MockRepository 생성
- 예상 결과 설정
- 메서드 호출 검증

## 🏗️ 의존성 주입

### Injectable 패턴
- `@injectable` 어노테이션 사용
- GetIt을 통한 자동 등록
- 의존성 주입 컨테이너 활용

### 의존성 구조
```
UseCase
├── Repository (인터페이스)
├── Validator (검증 서비스)
├── Analytics (분석 서비스)
└── Cache (캐시 서비스)
```

## 📊 UseCase 분류

### Query UseCases (조회)
- SearchPostsUseCase
- SearchUsersUseCase
- SearchChatsUseCase
- GetSearchHistoryUseCase
- GetTrendingSearchesUseCase
- GetSearchSuggestionsUseCase

### Command UseCases (변경)
- SaveSearchQueryUseCase
- ClearSearchHistoryUseCase

### Stream UseCases (실시간)
- GetSearchHistoryUseCase (Stream 버전)

## 🎯 설계 고려사항

### 1. 입력 검증
- 모든 입력은 UseCase에서 검증
- 도메인 규칙 적용
- 명확한 에러 메시지

### 2. 에러 처리
- Either 패턴 사용
- 구체적인 Failure 타입
- 복구 가능한 에러 처리

### 3. 성능 최적화
- 캐싱 전략 적용
- 불필요한 호출 방지
- 비동기 작업 처리

### 4. 확장성
- 새로운 UseCase 추가 용이
- 기존 UseCase 수정 없이 확장
- 인터페이스 기반 설계

## 📝 마이그레이션 체크리스트

- [ ] Base UseCase 클래스 생성
  - [ ] UseCase 추상 클래스
  - [ ] NoParamsUseCase 클래스
  - [ ] StreamUseCase 클래스
- [ ] 검색 UseCase 구현
  - [ ] SearchPostsUseCase
  - [ ] SearchUsersUseCase
  - [ ] SearchChatsUseCase
- [ ] 검색 기록 UseCase 구현
  - [ ] GetSearchHistoryUseCase
  - [ ] SaveSearchQueryUseCase
  - [ ] ClearSearchHistoryUseCase
- [ ] 검색 제안 UseCase 구현
  - [ ] GetTrendingSearchesUseCase
  - [ ] GetSearchSuggestionsUseCase
- [ ] 테스트 작성
  - [ ] 각 UseCase별 단위 테스트
  - [ ] Mock Repository 설정
  - [ ] 에러 케이스 테스트
- [ ] 의존성 주입 설정
  - [ ] Injectable 어노테이션 추가
  - [ ] GetIt 모듈 등록

---

*UseCases는 검색 기능의 비즈니스 로직을 캡슐화합니다.*