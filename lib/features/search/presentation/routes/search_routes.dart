import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType, GoRoute

/// Search Feature Routes (Clean Architecture v4.0)
///
/// **Phase 3 준비 완료** (2025-11-10)
///
/// ## 아키텍처 개요
///
/// Feature-First 패턴에 따라 Search Feature의 모든 라우트를 독립적으로 관리합니다.
/// nav.dart의 복잡도를 줄이고 Feature별 응집도를 높입니다.
///
/// ## 현재 상태: 0 Routes (Placeholder)
///
/// 이 파일은 **Phase 3**에서 생성된 **준비 파일(Placeholder)**입니다:
/// - ✅ Feature Routes 구조 확립 (다른 7개 Feature와 동일)
/// - ✅ nav.dart 통합 완료 (`...SearchRoutes.routes(ref)` line 145)
/// - ⏳ 실제 라우트 구현 대기 중 (Phase 4-5에서 추가 예정)
///
/// **왜 지금 생성했나요?**
/// 1. **일관성**: 8개 Feature 모두 동일한 Routes 패턴 유지
/// 2. **확장성**: 향후 라우트 추가 시 nav.dart 수정 불필요
/// 3. **예측 가능성**: 개발자가 Feature Routes 위치를 쉽게 찾을 수 있음
/// 4. **Phase 완결성**: Phase 1-3 Router 모듈화 100% 달성
///
/// ## ShellRoute 제외 (SearchPageWidget)
///
/// **SearchPageWidget**은 이 파일에 포함되지 않습니다:
/// - 위치: `/lib/app/router/navigation/nav.dart` lines 150-153 (ShellRoute 내부)
/// - 역할: 하단 네비게이션 바의 검색 탭 (항상 표시)
/// - 경로: `/search` (ShellRoute 자식)
/// - 이유: ShellRoute 페이지는 nav.dart에서 직접 관리 (다른 4개 탭과 동일)
///
/// **SearchRoutes에 포함될 라우트**:
/// - 검색 결과 상세 페이지 (SearchPageWidget 외부)
/// - 검색 필터 설정 페이지
/// - 검색 기록 페이지
/// - 기타 검색 관련 독립 페이지
///
/// ## 향후 추가 예정 (Phase 4-5)
///
/// ### 1. SearchResultsPage (검색 결과 상세)
/// ```dart
/// AppRoute(
///   name: 'searchResults',
///   path: '/search/results',
///   requireAuth: false,  // PUBLIC (검색은 누구나 가능)
///   builder: (context, params) => SearchResultsWidget(
///     query: params.getParam('query', ParamType.String),
///     filters: params.getParam('filters', ParamType.JSON),
///   ),
/// ).toRoute(ref)
/// ```
///
/// **기능**:
/// - 검색어 기반 게시물 필터링
/// - 실시간 검색 결과 업데이트 (Firestore Stream)
/// - 무한 스크롤 페이징
/// - 파라미터: `query` (필수), `filters` (선택)
///
/// ### 2. SearchFilterPage (검색 필터 설정)
/// ```dart
/// AppRoute(
///   name: 'searchFilter',
///   path: '/search/filter',
///   requireAuth: false,  // PUBLIC
///   builder: (context, params) => SearchFilterWidget(
///     currentFilters: params.getParam('currentFilters', ParamType.JSON),
///   ),
/// ).toRoute(ref)
/// ```
///
/// **기능**:
/// - 카테고리, 날짜 범위, 정렬 방식 설정
/// - 필터 프리셋 저장 (로그인 사용자만)
/// - 파라미터: `currentFilters` (JSON)
///
/// ### 3. SearchHistoryPage (검색 기록)
/// ```dart
/// AppRoute(
///   name: 'searchHistory',
///   path: '/search/history',
///   requireAuth: true,  // 로그인 필요 (개인 기록)
///   builder: (context, params) => const SearchHistoryWidget(),
/// ).toRoute(ref)
/// ```
///
/// **기능**:
/// - 사용자별 검색 기록 (Firestore 저장)
/// - 최근 검색어, 인기 검색어
/// - 기록 삭제 기능
///
/// ## 구현 가이드 (Phase 4-5)
///
/// **Step 1**: 위젯 생성
/// ```bash
/// # 검색 결과 페이지 생성
/// touch lib/features/search/presentation/screens/results/search_results_widget.dart
/// ```
///
/// **Step 2**: routes() 메서드에 추가
/// ```dart
/// static List<GoRoute> routes(WidgetRef ref) => [
///   // 빈 리스트에서 실제 라우트 추가
///   AppRoute(
///     name: SearchResultsWidget.routeName,
///     path: SearchResultsWidget.routePath,
///     requireAuth: false,
///     builder: (context, params) => SearchResultsWidget(
///       query: params.getParam('query', ParamType.String),
///     ),
///   ).toRoute(ref),
/// ];
/// ```
///
/// **Step 3**: Type-safe navigation 상수 활성화
/// ```dart
/// // 주석 제거
/// static String get searchResults => SearchResultsWidget.routeName;
/// static String get searchResultsPath => SearchResultsWidget.routePath;
/// ```
///
/// **Step 4**: 사용
/// ```dart
/// context.goNamed(
///   SearchRoutes.searchResults,
///   queryParameters: {'query': searchQuery},
/// );
/// ```
///
/// ## 애니메이션 (향후 구현 시)
///
/// Search Feature 라우트는 **즉시 전환** (Duration.zero) 권장:
/// - 검색은 빈번한 이동 → 애니메이션 불필요
/// - AppRoute 패턴 기본 동작: NoTransitionPage
///
/// **단, SearchResultsPage는 Slide 애니메이션 고려 가능**:
/// - 사용자가 검색 → 결과 전환의 명확한 피드백
/// - 300ms Slide (왼쪽에서 오른쪽)
///
/// ## Public vs Private
///
/// Search Feature 라우트는 **대부분 PUBLIC** 권장:
/// - **SearchResultsPage**: requireAuth: false (비로그인 사용자도 검색 가능)
/// - **SearchFilterPage**: requireAuth: false (필터 설정도 public)
/// - **SearchHistoryPage**: requireAuth: true (개인 기록만 private)
///
/// **근거**:
/// - 사용자 획득: 검색 기능을 먼저 경험 → 회원가입 유도
/// - SEO: 검색 결과 페이지 크롤링 가능
/// - 공유: 검색 링크 공유 시 로그인 불필요
///
/// ## nav.dart 통합
///
/// ```dart
/// // /lib/app/router/navigation/nav.dart (line 145)
/// routes: [
///   ...SearchRoutes.routes(ref), // 현재 0개, 향후 3개 예정
/// ],
/// ```
///
/// ## 참조 문서
///
/// - [search/README.md](../../../README.md) - Search Feature 전체 가이드 (5,998줄)
/// - [/lib/app/router/README.md](/lib/app/router/README.md) - Router 시스템 개요
/// - [/lib/app/router/navigation/README.md](/lib/app/router/navigation/README.md) - Navigation 상세 가이드
/// - [PHASE_1_EITHER_PATTERN.md](../../../PHASE_1_EITHER_PATTERN.md) - Search Phase 1 완료
/// - [PHASE_2_RIVERPOD.md](../../../PHASE_2_RIVERPOD.md) - Search Phase 2 완료
/// - [PHASE_3_CACHE_INTEGRATION.md](../../../PHASE_3_CACHE_INTEGRATION.md) - Cache 통합 계획
///
/// **Phase 진행 상황**:
/// - ✅ Phase 1: Either Pattern (SearchFailure, Repository Interface)
/// - ✅ Phase 2: Riverpod 3.x (search_providers.dart 255줄)
/// - ✅ Phase 3: **Router 준비** (이 파일 생성)
/// - ⏳ Phase 4: Idempotency + Route 구현
/// - ⏳ Phase 5: Extension Pattern + Cache 통합
class SearchRoutes {
  /// Private constructor to prevent instantiation
  SearchRoutes._();

  /// List of all search-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...SearchRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  ///
  /// **현재**: 빈 리스트 (추가 routes 없음)
  static List<GoRoute> routes(WidgetRef ref) => [
        // TODO: SearchResultsWidget 구현 완료 시 여기에 추가
        // AppRoute(
        //   name: SearchResultsWidget.routeName,
        //   path: SearchResultsWidget.routePath,
        //   requireAuth: false,
        //   builder: (context, params) => SearchResultsWidget(...),
        // ).toRoute(ref),
      ];

  /// Route names for type-safe navigation (미래 구현 대비)
  // static String get searchResults => SearchResultsWidget.routeName;
  // static String get searchFilter => SearchFilterWidget.routeName;
  // static String get searchHistory => SearchHistoryWidget.routeName;

  /// Route paths for reference (미래 구현 대비)
  // static String get searchResultsPath => SearchResultsWidget.routePath;
  // static String get searchFilterPath => SearchFilterWidget.routePath;
  // static String get searchHistoryPath => SearchHistoryWidget.routePath;
}
