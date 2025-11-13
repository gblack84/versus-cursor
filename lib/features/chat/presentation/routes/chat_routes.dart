import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart'; // AppRoute, ParamType
import '/features/chat/domain/entities/chat.dart' as chat_entities;
import '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart';
import '/features/chat/presentation/screens/ai_chat/ai_chat_page_clean.dart';

/// Chat Feature Routes (Clean Architecture v4.0)
///
/// **Feature-First Architecture**:
/// - 채팅 관련 모든 routes를 Feature 내부로 캡슐화
/// - nav.dart의 복잡도 감소
///
/// **Phase 2 마이그레이션**:
/// - AppRoute 패턴 유지 (requireAuth, asyncParams 지원)
/// - WidgetRef 파라미터로 Riverpod 통합
///
/// **Routes**:
/// - ChatDetailWidgetClean (1:1 채팅 상세, requireAuth: true)
/// - AIChatPageClean (AI 채팅, requireAuth: true)
///
/// **참고**:
/// - ChatListWidgetClean과 FriendsWidget은 ShellRoute 내부 (bottom navigation)에 있어서 제외
class ChatRoutes {
  /// Private constructor to prevent instantiation
  ChatRoutes._();

  /// List of all chat-related routes
  ///
  /// **사용법**:
  /// ```dart
  /// GoRouter createRouter(WidgetRef ref) => GoRouter(
  ///   routes: [
  ///     ...ChatRoutes.routes(ref),
  ///   ],
  /// );
  /// ```
  static List<GoRoute> routes(WidgetRef ref) => [
        // Chat Detail Widget Clean (1:1 채팅 상세)
        AppRoute(
          name: ChatDetailWidgetClean.routeName,
          path: ChatDetailWidgetClean.routePath,
          requireAuth: true,
          builder: (context, params) => ChatDetailWidgetClean(
            chatDocument: params.state.extra != null
                ? (params.state.extra as Map<String, dynamic>)['chatDocument']
                    as chat_entities.Chat?
                : null,
          ),
        ).toRoute(ref),

        // AI Chat Page Clean (AI 채팅)
        AppRoute(
          name: AIChatPageClean.routeName,
          path: AIChatPageClean.routePath,
          requireAuth: true,
          builder: (context, params) => AIChatPageClean(
            aiChatId: params.getParam('aiChatId', ParamType.String),
          ),
        ).toRoute(ref),
      ];

  /// Route names for type-safe navigation
  ///
  /// **사용 예시**:
  /// ```dart
  /// context.goNamed(ChatRoutes.chatDetail, extra: {
  ///   'chatDocument': chatDocument,
  /// });
  /// ```
  static String get chatDetail => ChatDetailWidgetClean.routeName;
  static String get aiChat => AIChatPageClean.routeName;

  /// Route paths for reference
  static String get chatDetailPath => ChatDetailWidgetClean.routePath;
  static String get aiChatPath => AIChatPageClean.routePath;
}
