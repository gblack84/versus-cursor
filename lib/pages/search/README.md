# 🔍 Search Page - 검색 페이지

> Versus Space 앱의 콘텐츠 검색 기능을 제공하는 페이지입니다. 사용자가 게시물, 사용자, 태그 등을 검색할 수 있는 통합 검색 인터페이스를 제공합니다.

## 📋 개요

Search 페이지는 앱 내의 다양한 콘텐츠를 검색할 수 있는 중앙 허브 역할을 합니다. 현재는 기본 구조만 구현되어 있으며, 향후 Algolia 검색 엔진과 통합하여 실시간 검색, 필터링, 정렬 기능을 제공할 예정입니다.

### 🎯 주요 목적
- **통합 검색**: 게시물, 사용자, 태그 통합 검색
- **실시간 검색**: 타이핑과 동시에 결과 표시 (예정)
- **필터링**: 카테고리, 날짜, 인기도 필터 (예정)
- **검색 기록**: 최근 검색어 저장 및 관리 (예정)

## 🏗️ 디렉토리 구조

```
/lib/pages/search/
├── search_page_widget.dart    # 메인 검색 페이지 위젯 (46줄)
└── README.md                   # 문서 파일
```

### 📊 코드 통계
- **총 코드 라인**: 46줄
- **파일 수**: 1개
- **주요 컴포넌트**: SearchPageWidget
- **의존성**: 2개 (Flutter, AppTheme)
- **구현 상태**: 기본 UI 구조만 구현

## 📐 네이밍 컨벤션

### 파일명
- **패턴**: snake_case (Dart 표준)
- **접미사**: `_widget`, `_page`
- **예시**: `search_page_widget.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: `Widget`, `State`
- **예시**: `SearchPageWidget`, `_SearchPageWidgetState`

### 라우팅
- **routeName**: camelCase with snake_case (`'search_page'`)
- **routePath**: camelCase with slash (`'/search'`)

### 변수 및 메서드
- **패턴**: camelCase
- **private**: 언더스코어 접두사 (`_`)
- **예시**: `scaffoldKey`

> 참조: [프로젝트 전체 네이밍 컨벤션](../../NAMING_CONVENTION.md)

## 🔑 주요 구성요소

### 1. SearchPageWidget - 메인 검색 페이지 🔍

**검색 인터페이스를 제공하는 StatefulWidget입니다.**

#### 라우팅 정보
```dart
static String routeName = 'search_page';
static String routePath = '/search';
```

#### 현재 구현 상태
- **AppBar**: "검색" 제목 표시
- **Body**: 임시 텍스트 "검색 페이지" 표시
- **기본 스캐폴드**: 구조만 구현

#### UI 구조
```dart
Scaffold(
  key: scaffoldKey,
  backgroundColor: AppTheme.of(context).primaryBackground,
  appBar: AppBar(
    title: Text('검색'),
    centerTitle: true,
  ),
  body: SafeArea(
    child: Center(
      child: Text('검색 페이지'),
    ),
  ),
)
```

### 2. 예정된 검색 기능 (TODO) 🚧

**향후 구현될 검색 시스템의 주요 기능입니다.**

#### 검색 입력 필드
```dart
// TODO: 구현 예정
TextField(
  controller: _searchController,
  decoration: InputDecoration(
    hintText: '검색어를 입력하세요',
    prefixIcon: Icon(Icons.search),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => _searchController.clear(),
    ),
  ),
  onChanged: (value) => _performSearch(value),
)
```

#### 검색 결과 표시
```dart
// TODO: 구현 예정
StreamBuilder<List<SearchResult>>(
  stream: _searchStream,
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: snapshot.data!.length,
      itemBuilder: (context, index) {
        final result = snapshot.data![index];
        return SearchResultCard(result: result);
      },
    );
  },
)
```

#### 검색 필터
```dart
// TODO: 구현 예정
enum SearchFilter {
  all,        // 전체
  posts,      // 게시물
  users,      // 사용자
  tags,       // 태그
}
```

### 3. Algolia 통합 계획 🔗

**Algolia 검색 엔진과의 통합 계획입니다.**

#### 인덱스 구조
- **posts_index**: 게시물 검색
- **users_index**: 사용자 검색
- **tags_index**: 태그 검색

#### 검색 파라미터
```dart
// TODO: Algolia 설정
final searchParams = {
  'query': searchText,
  'hitsPerPage': 20,
  'filters': 'status:active',
  'facets': ['category', 'tags'],
};
```

### 4. 검색 기록 관리 📝

**사용자의 검색 기록을 관리하는 시스템입니다.**

```dart
// TODO: 구현 예정
class SearchHistory {
  static const maxHistoryItems = 10;
  
  Future<void> addSearchTerm(String term) async {
    // SharedPreferences에 저장
  }
  
  Future<List<String>> getRecentSearches() async {
    // 최근 검색어 가져오기
  }
  
  Future<void> clearHistory() async {
    // 검색 기록 삭제
  }
}
```

## 💡 사용 가이드

### 페이지 진입
```dart
// 바텀 네비게이션에서
context.pushNamed('search_page');

// 또는 직접 경로
context.go('/search');
```

### 예정된 검색 플로우
1. 검색 페이지 진입
2. 검색어 입력
3. 실시간 결과 표시
4. 필터 적용 (선택사항)
5. 결과 선택
6. 상세 페이지로 이동

## 🎨 디자인 시스템

### 현재 적용된 스타일
- **배경색**: `AppTheme.of(context).primaryBackground`
- **텍스트 스타일**: `AppTheme.of(context).headlineSmall`
- **AppBar 색상**: `Colors.white`
- **텍스트 색상**: `Colors.black`

### 향후 적용 예정 (VersusDesign System)
- **배경**: `VersusColors.backgroundPrimary`
- **검색 바**: `VersusColors.backgroundSecondary`
- **포커스 색상**: `VersusColors.primary`
- **텍스트**: `VersusTextStyles.bodyMedium`
- **간격**: `VersusSpacing.paddingMD`

## 🚀 성능 최적화 계획

### 검색 최적화
- **디바운싱**: 300ms 타이핑 지연 후 검색
- **캐싱**: 최근 검색 결과 메모리 캐시
- **페이지네이션**: 무한 스크롤 구현
- **이미지 레이지 로딩**: 썸네일 지연 로드

### Algolia 최적화
- **인덱스 분리**: 타입별 개별 인덱스
- **필드 제한**: 검색에 필요한 필드만 반환
- **CDN 활용**: 이미지 CDN 경로 사용

## 📚 의존성

### 현재 의존성
```dart
import 'package:flutter/material.dart';
import '/core/app_theme.dart';
```

### 예정된 의존성
```dart
// TODO: 추가 예정
import '/backend/algolia/algolia.dart';
import '/backend/backend.dart';
import '/design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
```

## 🔧 개선 사항 (TODO)

### 우선순위 높음
1. **검색 입력 필드**: TextField 위젯 구현
2. **Algolia 연동**: 검색 엔진 통합
3. **검색 결과 표시**: ListView로 결과 렌더링
4. **디자인 시스템 적용**: VersusDesign System으로 마이그레이션

### 우선순위 중간
5. **검색 필터**: 카테고리별 필터링
6. **검색 기록**: 최근 검색어 저장
7. **자동완성**: 검색어 추천
8. **음성 검색**: 음성 입력 지원

### 우선순위 낮음
9. **고급 필터**: 날짜, 인기도 필터
10. **검색 분석**: 인기 검색어 통계
11. **검색 공유**: 검색 결과 공유

## 🐛 알려진 이슈

### 현재 이슈
1. **기능 미구현**: 실제 검색 기능이 구현되지 않음
   - Algolia 설정 필요
   - 검색 UI 구현 필요
   
2. **디자인 시스템**: 구형 AppTheme 사용 중
   - VersusDesign System으로 마이그레이션 필요
   - 일관된 UI/UX 적용 필요

### 해결 계획
- Algolia 계정 설정 및 인덱스 생성
- 검색 UI 컴포넌트 개발
- 디자인 시스템 전면 적용

## 📅 변경 이력

| 날짜 | 버전 | 변경 내용 | 작업자 |
|------|------|----------|--------|
| 2025-08-23 | v1.0.0 | README 문서 작성 완료 | AI Assistant |
| 2025-08-22 | v0.1.0 | 초기 페이지 생성 | 개발팀 |

## 🔗 관련 문서

- [전체 Pages 구조](../../README.md)
- [Algolia 통합 가이드](../../backend/algolia/README.md)
- [AppTheme 가이드](../../core/README.md)
- [디자인 시스템](../../design_system/README.md)
- [네이밍 컨벤션](../../NAMING_CONVENTION.md)
- [홈 페이지](../home/README.md)

## 📌 구현 예제

### 검색 결과 카드 (향후 구현)
```dart
class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  
  const SearchResultCard({required this.result});
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(result.imageUrl),
      ),
      title: Text(result.title),
      subtitle: Text(result.description),
      trailing: Text(result.type),
      onTap: () => _navigateToDetail(context, result),
    );
  }
}
```

### 검색 서비스 (향후 구현)
```dart
class SearchService {
  final AlgoliaClient algolia;
  
  Stream<List<SearchResult>> search(String query) {
    return algolia
        .index('posts')
        .query(query)
        .getObjects()
        .asStream()
        .map((response) => response.hits
            .map((hit) => SearchResult.fromJson(hit.data))
            .toList());
  }
}
```

---

*이 문서는 Versus Space 앱의 검색 페이지 구현을 상세히 설명합니다.*
*최종 업데이트: 2025-08-23*