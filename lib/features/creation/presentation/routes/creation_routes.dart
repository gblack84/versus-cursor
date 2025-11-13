import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType
import '/app/widgets/index.dart'; // ProImageEditorPage, ImageViewerPage

/// Creation Feature Routes (Clean Architecture v4.0)
///
/// **Feature-First Architecture**:
/// - 콘텐츠 생성 관련 모든 routes를 Feature 내부로 캡슐화
/// - nav.dart의 복잡도 감소
///
/// **Phase 2 마이그레이션**:
/// - AppRoute 패턴 유지 (requireAuth, asyncParams 지원)
/// - WidgetRef 파라미터로 Riverpod 통합
///
/// **Routes**:
/// - ProImageEditorPage (이미지 편집)
/// - ImageViewerPage (이미지 뷰어)
///
/// **참고**:
/// - CreatePostScreen은 ShellRoute 내부 (bottom navigation)에 있어서 제외
class CreationRoutes {
  /// Private constructor to prevent instantiation
  CreationRoutes._();

  /// List of all creation-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...CreationRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Pro Image Editor Page (이미지 편집)
        AppRoute(
          name: ProImageEditorPage.routeName,
          path: ProImageEditorPage.routePath,
          requireAuth: false, // 이미지 편집기는 public (게스트도 사용 가능)
          builder: (context, params) => ProImageEditorPage(
            imagePath: params.getParam(
              'imagePath',
              ParamType.String,
            ),
            box: params.getParam(
              'box',
              ParamType.String,
            ),
          ),
        ).toRoute(ref),

        // Image Viewer Page (이미지 뷰어)
        AppRoute(
          name: ImageViewerPage.routeName,
          path: ImageViewerPage.routePath,
          requireAuth: false, // 이미지 뷰어는 public (누구나 볼 수 있음)
          builder: (context, params) => ImageViewerPage(
            imageUrls: params.getParam<String>('imageUrls', ParamType.String) !=
                    null
                ? (params.getParam<String>('imageUrls', ParamType.String) ?? '')
                    .split(',')
                : [],
            imagePaths:
                params.getParam<String>('imagePaths', ParamType.String) != null
                    ? (params.getParam<String>(
                                'imagePaths', ParamType.String) ??
                            '')
                        .split('|')
                    : [],
            initialIndex: params.getParam(
                  'initialIndex',
                  ParamType.int,
                ) ??
                0,
            box: params.getParam(
              'box',
              ParamType.String,
            ),
          ),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  ///
  /// **사용 예시**:
  /// ```dart
  /// context.goNamed(CreationRoutes.imageEditor, pathParameters: {
  ///   'imagePath': imagePath,
  /// });
  /// ```
  static String get imageEditor => ProImageEditorPage.routeName;
  static String get imageViewer => ImageViewerPage.routeName;

  /// Route paths for reference
  static String get imageEditorPath => ProImageEditorPage.routePath;
  static String get imageViewerPath => ImageViewerPage.routePath;
}
