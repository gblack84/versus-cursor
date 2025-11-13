import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType, GoRoute
import '../screens/trending/trending_posts_page.dart';
import '../screens/detail/post_detail_page.dart';
import '../screens/popular/popular_posts_page.dart';

/// Post Feature Routes (Clean Architecture v4.0)
///
/// **Phase 2 마이그레이션 완료** (2025-11-10)
///
/// ## 아키텍처 개요
///
/// Feature-First 패턴에 따라 Post Feature의 모든 라우트를 독립적으로 관리합니다.
/// nav.dart의 복잡도를 줄이고 Feature별 응집도를 높입니다.
///
/// ## 라우트 구성 (3개)
///
/// 1. **TrendingPostsPage** (`/trending`)
///    - 트렌딩 게시물 목록 (AI 추천 + 인기 투표 기반)
///    - requireAuth: false → **PUBLIC** (누구나 접근 가능)
///    - 실시간 투표 카운트 업데이트
///
/// 2. **PostDetailPage** (`/post/:postId`)
///    - 게시물 상세 페이지 (A vs B 투표, 댓글, 결과)
///    - requireAuth: false → **PUBLIC** (공유 링크로 접근 가능)
///    - postId 파라미터 필수 (PathParameter)
///    - 딥링크 지원 (외부 링크로 직접 접근)
///
/// 3. **PopularPostsPage** (`/popular`)
///    - 인기 게시물 목록 (투표 수 기준 정렬)
///    - requireAuth: false → **PUBLIC**
///    - 페이징 지원 (무한 스크롤)
///
/// ## Public Access (requireAuth: false)
///
/// **Post Feature의 모든 라우트는 PUBLIC**입니다:
/// - **사용자 획득**: 비로그인 사용자도 콘텐츠 확인 가능 → 회원가입 유도
/// - **공유 최적화**: 딥링크로 게시물 공유 시 로그인 없이 바로 확인
/// - **SEO 친화**: 크롤러가 콘텐츠 인덱싱 가능
/// - **바이럴 효과**: SNS 공유 시 접근 장벽 제거
///
/// **단, 특정 액션은 인증 필요**:
/// - 투표하기: 로그인 필요 (VotingFeature에서 처리)
/// - 댓글 작성: 로그인 필요 (CommentFeature에서 처리)
/// - 게시물 생성: 로그인 필요 (CreationFeature의 CreatePostPage는 requireAuth: true)
///
/// ## Phase 2 마이그레이션 내용
///
/// **Before (Phase 1)**: nav.dart에 직접 GoRoute 정의
/// ```dart
/// GoRoute(
///   path: '/post/:postId',
///   name: 'postDetail',
///   builder: (context, state) => PostDetailPage(
///     postId: state.pathParameters['postId']!,
///   ),
/// )
/// ```
///
/// **After (Phase 2)**: AppRoute 패턴 + Feature Routes 모듈화
/// ```dart
/// AppRoute(
///   name: PostDetailPage.routeName,
///   path: PostDetailPage.routePath,
///   requireAuth: false,  // PUBLIC 명시
///   builder: (context, params) => PostDetailPage(
///     postId: params.getParam('postId', ParamType.String),
///   ),
/// ).toRoute(ref)
/// ```
///
/// **주요 변경 사항**:
/// - ✅ requireAuth: false → PUBLIC 접근 명시
/// - ✅ params.getParam() → 타입 안전 파라미터 추출
/// - ✅ AppRoute.toRoute(ref) → NoTransitionPage (즉시 전환, 0ms)
/// - ✅ 타입 안전 네비게이션 → PostRoutes.postDetail getter
///
/// ## 애니메이션
///
/// 모든 라우트는 **즉시 전환** (Duration.zero, 애니메이션 없음):
/// - 성능 최적화 우선
/// - 게시물 탐색은 빈번한 이동 → 애니메이션 불필요
/// - AppRoute 패턴 기본 동작: NoTransitionPage
///
/// ## 딥링크 지원
///
/// Post Feature는 딥링크를 완벽하게 지원합니다:
///
/// ```dart
/// // 외부 링크로 게시물 직접 접근
/// https://versus.app/post/abc123def456
///
/// // GoRouter가 자동으로 라우팅:
/// // 1. /post/abc123def456 경로 파싱
/// // 2. PostDetailPage.routePath 매칭
/// // 3. postId 파라미터 추출 (abc123def456)
/// // 4. PostDetailPage 렌더링
/// ```
///
/// **요구사항**:
/// - PostDetailPage.routePath는 `/post/:postId` 형식이어야 함
/// - postId는 PathParameter (필수)
/// - requireAuth: false (로그인 없이 접근 가능)
///
/// ## 사용 예시
///
/// ```dart
/// // 1. 타입 안전 네비게이션 (권장)
/// context.goNamed(PostRoutes.trendingPosts);
///
/// // 2. 게시물 상세로 이동 (postId 파라미터)
/// context.goNamed(
///   PostRoutes.postDetail,
///   pathParameters: {'postId': postId},
/// );
///
/// // 3. 인기 게시물 목록
/// context.goNamed(PostRoutes.popularPosts);
///
/// // 4. Push 네비게이션 (스택에 추가)
/// context.pushNamed(
///   PostRoutes.postDetail,
///   pathParameters: {'postId': postId},
/// );
///
/// // 5. 뒤로가기
/// context.safePop(); // 스택이 비면 홈으로 이동
///
/// // 6. 딥링크 테스트 (개발 중)
/// await launchUrl(Uri.parse('versus://post/abc123'));
/// ```
///
/// ## nav.dart 통합
///
/// ```dart
/// // /lib/app/router/navigation/nav.dart (line 142)
/// routes: [
///   ...PostRoutes.routes(ref), // 3개 라우트 병합
/// ],
/// ```
///
/// ## 참조 문서
///
/// - [post/README.md](../../../README.md) - Post Feature 전체 가이드
/// - [/lib/app/router/README.md](/lib/app/router/README.md) - Router 시스템 개요
/// - [/lib/app/router/navigation/README.md](/lib/app/router/navigation/README.md) - Navigation 상세 가이드
/// - [PHASE_1_EITHER_PATTERN.md](../../../PHASE_1_EITHER_PATTERN.md) - Phase 1 마이그레이션 기록
/// - [PHASE_2_RIVERPOD.md](../../../PHASE_2_RIVERPOD.md) - Phase 2 Router 통합
///
/// **참고 (ShellRoute)**:
/// - HomePageWidget은 ShellRoute 내부 (bottom navigation)에 있어서 PostRoutes에 포함되지 않음
/// - ShellRoute 페이지는 nav.dart에서 직접 관리 (lines 124-177)
class PostRoutes {
  /// Private constructor to prevent instantiation
  PostRoutes._();

  /// List of all post-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...PostRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Trending Posts Page (인기 게시물)
        AppRoute(
          name: TrendingPostsPage.routeName,
          path: TrendingPostsPage.routePath,
          requireAuth: false, // 인기 게시물은 public (누구나 볼 수 있음)
          builder: (context, params) => const TrendingPostsPage(),
        ).toRoute(ref),

        // Post Detail Page (게시물 상세)
        AppRoute(
          name: PostDetailPage.routeName,
          path: PostDetailPage.routePath,
          requireAuth: false, // 게시물 상세는 public (누구나 볼 수 있음)
          builder: (context, params) => PostDetailPage(
            postId: params.getParam(
              'postId',
              ParamType.String,
            ),
          ),
        ).toRoute(ref),

        // Popular Posts Page (인기 게시물 목록)
        AppRoute(
          name: PopularPostsPage.routeName,
          path: PopularPostsPage.routePath,
          requireAuth: false, // 인기 게시물 목록은 public (누구나 볼 수 있음)
          builder: (context, params) => const PopularPostsPage(),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  ///
  /// **사용 예시**:
  /// ```dart
  /// context.goNamed(PostRoutes.postDetail, pathParameters: {
  ///   'postId': postId,
  /// });
  /// ```
  static String get trendingPosts => TrendingPostsPage.routeName;
  static String get postDetail => PostDetailPage.routeName;
  static String get popularPosts => PopularPostsPage.routeName;

  /// Route paths for reference
  static String get trendingPostsPath => TrendingPostsPage.routePath;
  static String get postDetailPath => PostDetailPage.routePath;
  static String get popularPostsPath => PopularPostsPage.routePath;
}
