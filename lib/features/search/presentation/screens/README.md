# 📂 Search Screens

> 검색 기능의 화면(페이지) 컴포넌트

## 📋 개요

Screens는 검색 기능의 전체 화면을 구성하는 위젯들입니다. 각 Screen은 독립적인 라우트를 가지며, Provider를 통해 상태를 관리합니다.

## 🎯 Screen 설계 원칙

### 핵심 원칙
- **단일 책임**: 하나의 화면 = 하나의 목적
- **상태 분리**: UI와 비즈니스 로직 분리
- **재사용성**: 공통 위젯은 widgets 폴더로
- **반응형 디자인**: 다양한 화면 크기 지원
- **접근성**: 스크린 리더 및 키보드 네비게이션

### Screen이 하는 일
- 전체 화면 레이아웃 구성
- Provider 연결 및 상태 관리
- 네비게이션 처리
- 생명주기 관리
- 사용자 입력 처리

### Screen이 하지 않는 일
- 비즈니스 로직 직접 구현
- 직접적인 데이터 접근
- 복잡한 상태 계산
- 재사용 가능한 위젯 포함

## 📁 파일 구조

```
screens/
├── search_page/         # 메인 검색 화면 (Post/User 검색)
│   ├── search_page_widget.dart
│   └── search_page_model.dart
│
├── search_results/      # 검색 결과 화면
│   ├── search_results_widget.dart
│   └── search_results_model.dart
│
├── advanced_search/     # 고급 검색 화면 (예정)
│   ├── advanced_search_widget.dart
│   └── advanced_search_model.dart
│
└── search_history/      # 검색 기록 화면 (예정)
    ├── search_history_widget.dart
    └── search_history_model.dart
```

**Note**:
- Chat 내부 검색 기능은 `/features/chat/` ChatDetailWidget에서 처리
- Friends 추천 기능은 `/features/chat/presentation/screens/friends/` FriendsWidget으로 이동 완료 (2025-01-20)

## 🔄 마이그레이션 상태

✅ **완료된 마이그레이션**:
- Friends 추천 기능 → Chat Feature로 이동 (2025-01-20)
- 채팅 내부 검색 기능 → ChatDetailWidget에 통합

⏳ **예정된 구현**:
- Post 검색 기능
- User 검색 기능
- 고급 검색 옵션
- 검색 기록 관리

## 💻 Screen 사양

### SearchPageWidget (메인 검색 화면)

**라우트:** `/search`

**주요 구성요소:**
- 검색 바 (SearchBarWidget)
- 탭 네비게이션 (전체, 게시물, 사용자, 채팅)
- 검색 제안 표시
- 검색 기록 표시
- 검색 결과 리스트

**상태 관리:**
- SearchProvider - 메인 검색 상태
- SearchSuggestionsProvider - 제안 상태
- SearchHistoryProvider - 기록 상태

**UI 레이아웃:**
- Scaffold with AppBar
- TabBarView for content switching
- Floating search bar option
- Pull-to-refresh support

### SearchResultsWidget (검색 결과 화면)

**라우트:** `/search/results?q={query}`

**주요 기능:**
- 검색 결과 표시
- 필터 적용 UI
- 정렬 옵션
- 페이지네이션
- 결과 없음 처리

**결과 표시 모드:**
- 리스트 뷰 (기본)
- 그리드 뷰 (이미지 중심)
- 컴팩트 뷰 (텍스트 중심)

### AdvancedSearchWidget (고급 검색 화면) - 예정

**라우트:** `/search/advanced`

**필터 옵션:**
- 콘텐츠 타입 선택
- 날짜 범위 설정
- 카테고리 선택
- 태그 입력
- 작성자 필터
- 정렬 옵션

**UI 구성:**
- Form with validation
- Chip selection for categories
- Date range picker
- Custom dropdown menus

### SearchHistoryWidget (검색 기록 화면) - 예정

**라우트:** `/search/history`

**기능:**
- 최근 검색어 목록
- 자주 검색한 키워드
- 검색 기록 삭제
- 검색어 재사용

**UI 요소:**
- Dismissible list items
- Grouped by date
- Clear all option
- Search from history

## 🧩 Screen Model 패턴

### BaseScreenModel
모든 Screen Model의 기본 클래스:
- 로딩 상태 관리
- 에러 처리
- 초기화/정리 메서드
- 네비게이션 헬퍼

### Model 책임
- UI 상태 관리
- Provider 조정
- 입력 검증
- 네비게이션 로직

## 🎨 UI/UX 가이드라인

### 디자인 원칙
- Material Design 3 준수
- 다크 모드 지원
- 애니메이션 사용 (300ms)
- 터치 타겟 최소 48dp

### 반응형 레이아웃
```
Mobile: < 600dp - 단일 컬럼
Tablet: 600-840dp - 2 컬럼
Desktop: > 840dp - 3 컬럼
```

### 접근성
- Semantics 라벨 제공
- 키보드 네비게이션
- 고대비 모드 지원
- 스크린 리더 호환

## 🧪 테스트 전략

### Widget 테스트
- 화면 렌더링 테스트
- 사용자 상호작용 테스트
- Provider 통합 테스트
- 네비게이션 테스트

### Golden 테스트
- 다양한 상태의 스크린샷
- 다크 모드 테스트
- 반응형 레이아웃 테스트

## 📊 성능 최적화

### 최적화 전략

**지연 로딩:**
- 스크롤 기반 페이지네이션
- 이미지 지연 로딩
- 무한 스크롤 구현

**메모리 관리:**
- AutomaticKeepAliveClientMixin 사용
- 이미지 캐싱 전략
- 위젯 재사용

**렌더링 최적화:**
- RepaintBoundary 활용
- const 생성자 사용
- 불필요한 rebuild 방지

## 🎯 네비게이션 플로우

### 라우팅 구조
```
/search (메인 - Post/User 검색)
├── /search/results (결과)
├── /search/advanced (고급 - 예정)
└── /search/history (기록 - 예정)
```

**Note**: Chat 관련 검색은 `/chat/` 경로에서 처리 (ChatDetailWidget)

### 딥링크 지원
- URL 파라미터 파싱
- 쿼리 스트링 처리
- 상태 복원

## 📝 구현 체크리스트

- [x] Screen 위젯 이동 (Phase 1 완료)
  - [x] SearchPageWidget (플레이스홀더)
  - [x] SearchResultsWidget (플레이스홀더)
  - [ ] AdvancedSearchWidget (예정)
  - [ ] SearchHistoryWidget (예정)
- [ ] Model 클래스 생성
  - [ ] BaseScreenModel
  - [ ] 각 Screen별 Model
- [ ] Provider 연결
  - [ ] Consumer 위젯 설정
  - [ ] Selector 최적화
- [ ] 라우팅 설정
  - [ ] GoRouter 경로 등록
  - [ ] 파라미터 처리
- [ ] UI 구현
  - [ ] 레이아웃 구성
  - [ ] 반응형 디자인
  - [ ] 다크 모드
- [ ] 테스트 작성
  - [ ] Widget 테스트
  - [ ] Golden 테스트
  - [ ] 통합 테스트

---

*Screens는 검색 기능의 전체 화면을 구성하고 사용자 인터페이스를 제공합니다.*