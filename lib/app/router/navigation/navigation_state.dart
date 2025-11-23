import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

/// 네비게이션 모드를 정의하는 enum
enum NavigationMode {
  main, // 기본 모드: 홈/검색/질문작성/채팅/유저
  chat, // 채팅 모드: 채팅/친구/검색/홈
}

/// 바텀 네비게이션 아이템 정의
class NavigationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

/// 메인 모드 네비게이션 아이템들
const List<NavigationItem> mainNavigationItems = [
  NavigationItem(
    label: '홈',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/home',
  ),
  NavigationItem(
    label: '검색',
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    route: '/search',
  ),
  NavigationItem(
    label: '질문작성',
    icon: Icons.add_circle_outline,
    activeIcon: Icons.add_circle,
    route: '/createPost',  // Fixed: Changed from /inPutPostImage to match actual route
  ),
  NavigationItem(
    label: '채팅',
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
    route: '/chat/list',
  ),
  NavigationItem(
    label: '유저',
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    route: '/profile',
  ),
];

/// 채팅 모드 네비게이션 아이템들
const List<NavigationItem> chatNavigationItems = [
  NavigationItem(
    label: '채팅',
    icon: Icons.chat_bubble_outline,
    activeIcon: Icons.chat_bubble,
    route: '/chat/list',
  ),
  NavigationItem(
    label: '친구',
    icon: Icons.people_outline,
    activeIcon: Icons.people,
    route: '/chat/friends',
  ),
  NavigationItem(
    label: '검색',
    icon: Icons.search_outlined,
    activeIcon: Icons.search,
    route: '/search',  // Fixed: Changed from /chat/search (doesn't exist) to /search
  ),
  NavigationItem(
    label: '홈',
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    route: '/home',
  ),
];

/// Navigation State
///
/// **Riverpod 3.x 마이그레이션**:
/// - ChangeNotifier → Freezed 불변 State
/// - Feature-First 아키텍처: /app/router/navigation/
/// - Clean Architecture 준수
@freezed
sealed class NavigationState with _$NavigationState {
  const NavigationState._();

  const factory NavigationState({
    /// 현재 네비게이션 모드
    @Default(NavigationMode.main) NavigationMode mode,

    /// 메인 모드 탭 인덱스
    @Default(0) int mainTabIndex,

    /// 채팅 모드 탭 인덱스
    @Default(0) int chatTabIndex,
  }) = _NavigationState;

  /// Initial state factory
  factory NavigationState.initial() => const NavigationState();

  /// 현재 모드에 따른 선택된 탭 인덱스
  int get currentTabIndex =>
      mode == NavigationMode.main ? mainTabIndex : chatTabIndex;

  /// 현재 모드에 따른 네비게이션 아이템 리스트
  List<NavigationItem> get currentItems =>
      mode == NavigationMode.main ? mainNavigationItems : chatNavigationItems;
}
