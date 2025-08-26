# 📂 Search Widgets

> 검색 기능의 재사용 가능한 UI 컴포넌트

## 📋 개요

Widgets는 검색 기능에서 재사용되는 작은 UI 컴포넌트들입니다. 각 위젯은 독립적이고 재사용 가능하며, 단일 책임을 가집니다.

## 🎯 Widget 설계 원칙

### 핵심 원칙
- **재사용성**: 여러 화면에서 사용 가능
- **독립성**: 최소한의 의존성
- **구성 가능성**: 조합하여 복잡한 UI 구성
- **테스트 가능성**: 독립적으로 테스트 가능
- **성능 최적화**: const 생성자 활용

### Widget이 하는 일
- 특정 UI 요소 렌더링
- 사용자 입력 처리
- 간단한 상태 관리
- 애니메이션 처리
- 스타일 적용

### Widget이 하지 않는 일
- 복잡한 비즈니스 로직
- 직접적인 API 호출
- 전역 상태 변경
- 네비게이션 결정

## 📁 파일 구조

```
widgets/
├── search_bar/              # 검색바 컴포넌트
│   ├── search_bar_widget.dart
│   ├── search_suggestions.dart
│   └── search_filters.dart
│
├── search_results/          # 검색 결과 표시
│   ├── search_result_item.dart
│   ├── search_result_list.dart
│   ├── search_result_grid.dart
│   └── search_empty_state.dart
│
├── search_history/          # 검색 기록
│   ├── search_history_list.dart
│   └── search_history_item.dart
│
├── search_filters/          # 검색 필터
│   ├── filter_chip_list.dart
│   ├── date_range_picker.dart
│   └── category_selector.dart
│
└── common/                  # 공통 위젯
    ├── search_loading.dart
    ├── search_error.dart
    └── highlight_text.dart
```

## 💻 Widget 사양

### SearchBarWidget (검색바)

**역할**: 메인 검색 입력 필드 제공

**Props**:
- `controller`: TextEditingController? - 텍스트 컨트롤러
- `focusNode`: FocusNode? - 포커스 노드
- `placeholder`: String - 플레이스홀더 텍스트 (기본: '검색어를 입력하세요')
- `onSearch`: Function(String) - 검색 실행 콜백
- `onChanged`: Function(String)? - 텍스트 변경 콜백
- `onClear`: VoidCallback? - 지우기 콜백
- `autofocus`: bool - 자동 포커스 (기본: false)
- `showFilter`: bool - 필터 버튼 표시 (기본: false)
- `onFilterTap`: VoidCallback? - 필터 버튼 탭 콜백
- `prefix`: Widget? - 접두사 위젯
- `suffixActions`: List<Widget>? - 접미사 액션 위젯들

**기능**:
- 텍스트 입력 및 검증
- 최대 길이 제한 (100자)
- 특수문자 필터링
- Clear 버튼 자동 표시/숨김
- Enter 키 검색 지원
- 포커스 상태 시각화

### SearchResultItem (검색 결과 아이템)

**역할**: 단일 검색 결과 표시

**Props**:
- `result`: SearchResult - 검색 결과 데이터
- `query`: String? - 하이라이트할 검색어
- `onTap`: VoidCallback - 탭 콜백
- `onLongPress`: VoidCallback? - 롱프레스 콜백
- `showType`: bool - 타입 배지 표시 (기본: true)

**표시 요소**:
- 썸네일 이미지 (60x60)
- 타입 배지 (post/user/chat/comment)
- 제목 (하이라이트 지원)
- 설명 (최대 2줄)
- 메타데이터 (작성자, 투표수, 댓글수, 날짜)
- 우측 화살표 아이콘

### SearchEmptyState (빈 상태)

**역할**: 검색 결과가 없을 때 표시

**Props**:
- `query`: String - 검색한 쿼리
- `suggestions`: List<String>? - 추천 검색어
- `onSuggestionTap`: Function(String)? - 추천어 탭 콜백
- `onRetry`: VoidCallback? - 재시도 콜백

**표시 요소**:
- 큰 아이콘 (search_off, 80px)
- "검색 결과가 없습니다" 제목
- 검색어 포함 메시지
- 추천 검색어 칩들
- 재시도 버튼 (옵션)

### HighlightText (텍스트 하이라이트)

**역할**: 검색어를 하이라이트하는 텍스트

**Props**:
- `text`: String - 전체 텍스트
- `highlight`: String - 하이라이트할 문자열
- `style`: TextStyle? - 기본 텍스트 스타일
- `highlightStyle`: TextStyle? - 하이라이트 스타일
- `maxLines`: int? - 최대 줄 수
- `overflow`: TextOverflow? - 오버플로우 처리
- `caseSensitive`: bool - 대소문자 구분 (기본: false)

**기능**:
- 부분 문자열 매칭
- 다중 하이라이트 지원
- 대소문자 구분 옵션
- RichText로 렌더링

### SearchHistoryItem (검색 기록 아이템)

**역할**: 단일 검색 기록 표시

**Props**:
- `history`: SearchHistory - 검색 기록 데이터
- `onTap`: VoidCallback - 탭 콜백
- `onDelete`: VoidCallback - 삭제 콜백

**표시 요소**:
- 히스토리 아이콘 (leading)
- 검색어 텍스트
- 결과 개수 및 시간 (subtitle)
- 삭제 버튼 (trailing)

### SearchResultList (검색 결과 리스트)

**역할**: 검색 결과 리스트 뷰

**특징**:
- ListView.builder 사용
- 무한 스크롤 지원
- 아이템 구분선
- Pull-to-refresh
- 로딩 인디케이터

### SearchResultGrid (검색 결과 그리드)

**역할**: 검색 결과 그리드 뷰

**특징**:
- GridView.builder 사용
- 2-3 컬럼 반응형
- 이미지 중심 레이아웃
- 무한 스크롤 지원

### FilterChipList (필터 칩 리스트)

**역할**: 선택 가능한 필터 칩들

**Props**:
- `filters`: List<FilterOption> - 필터 옵션들
- `selected`: Set<String> - 선택된 필터 ID들
- `onToggle`: Function(String) - 토글 콜백
- `multiSelect`: bool - 다중 선택 허용

### DateRangePicker (날짜 범위 선택기)

**역할**: 검색 날짜 범위 선택

**Props**:
- `start`: DateTime? - 시작일
- `end`: DateTime? - 종료일
- `onChanged`: Function(DateTimeRange?) - 변경 콜백
- `presets`: List<DateRangePreset>? - 프리셋 옵션

### CategorySelector (카테고리 선택기)

**역할**: 검색 카테고리 선택

**Props**:
- `categories`: List<Category> - 카테고리 목록
- `selected`: String? - 선택된 카테고리
- `onSelect`: Function(String?) - 선택 콜백
- `allowClear`: bool - 선택 해제 허용

## 🎨 Widget 카탈로그

### 검색바 관련
- `SearchBarWidget` - 메인 검색 입력 필드
- `SearchSuggestions` - 자동완성 제안 드롭다운
- `SearchFilters` - 필터 바

### 검색 결과 관련
- `SearchResultItem` - 단일 검색 결과 아이템
- `SearchResultList` - 검색 결과 리스트
- `SearchResultGrid` - 검색 결과 그리드
- `SearchEmptyState` - 결과 없음 상태

### 검색 기록 관련
- `SearchHistoryList` - 검색 기록 리스트
- `SearchHistoryItem` - 단일 검색 기록 아이템

### 필터 관련
- `FilterChipList` - 필터 칩 리스트
- `DateRangePicker` - 날짜 범위 선택기
- `CategorySelector` - 카테고리 선택기

### 공통 위젯
- `SearchLoading` - 로딩 인디케이터
- `SearchError` - 에러 상태
- `HighlightText` - 텍스트 하이라이트

## 🧪 Widget 테스트 전략

### 테스트 범위
- 위젯 렌더링 테스트
- 사용자 상호작용 테스트
- Props 전달 테스트
- 콜백 호출 검증

### 테스트 시나리오
- SearchBarWidget: 텍스트 입력, Clear 버튼, Enter 키 처리
- SearchResultItem: 데이터 표시, 탭/롱프레스 이벤트
- HighlightText: 검색어 하이라이트 정확성
- FilterChipList: 선택/해제 토글

## 📝 마이그레이션 체크리스트

- [ ] 검색바 위젯
  - [ ] SearchBarWidget 구현
  - [ ] SearchSuggestions 구현
  - [ ] SearchFilters 구현
- [ ] 검색 결과 위젯
  - [ ] SearchResultItem 구현
  - [ ] SearchResultList 구현
  - [ ] SearchResultGrid 구현
  - [ ] SearchEmptyState 구현
- [ ] 검색 기록 위젯
  - [ ] SearchHistoryList 구현
  - [ ] SearchHistoryItem 구현
- [ ] 필터 위젯
  - [ ] FilterChipList 구현
  - [ ] DateRangePicker 구현
  - [ ] CategorySelector 구현
- [ ] 공통 위젯
  - [ ] SearchLoading 구현
  - [ ] SearchError 구현
  - [ ] HighlightText 구현
- [ ] 테스트 작성
  - [ ] 각 위젯별 단위 테스트
  - [ ] Widget 테스트
  - [ ] Golden 테스트

---

*Widgets는 검색 기능의 재사용 가능한 UI 컴포넌트입니다.*