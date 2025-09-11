import 'package:flutter/material.dart';

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

/// 네비게이션 상태를 관리하는 Provider
class NavigationProvider extends ChangeNotifier {
  NavigationMode _mode = NavigationMode.main;
  int _mainTabIndex = 0;
  int _chatTabIndex = 0;

  NavigationMode get mode => _mode;
  int get mainTabIndex => _mainTabIndex;
  int get chatTabIndex => _chatTabIndex;

  /// 현재 모드에 따른 선택된 탭 인덱스
  int get currentTabIndex =>
      _mode == NavigationMode.main ? _mainTabIndex : _chatTabIndex;

  /// 메인 모드 네비게이션 아이템들
  static const List<NavigationItem> mainItems = [
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
      route: '/inPutPostImage',
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
  static const List<NavigationItem> chatItems = [
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
      route: '/chat/search',
    ),
    NavigationItem(
      label: '홈',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      route: '/home',
    ),
  ];

  /// 현재 모드에 따른 네비게이션 아이템 리스트
  List<NavigationItem> get currentItems =>
      _mode == NavigationMode.main ? mainItems : chatItems;

  /// 네비게이션 모드 설정
  void setMode(NavigationMode mode) {
    if (_mode != mode) {
      _mode = mode;
      notifyListeners();
    }
  }

  /// 메인 모드로 전환
  void switchToMainMode() {
    setMode(NavigationMode.main);
  }

  /// 채팅 모드로 전환
  void switchToChatMode() {
    setMode(NavigationMode.chat);
    _chatTabIndex = 0; // 채팅 리스트로 초기화
  }

  /// 탭 인덱스 설정
  void setTabIndex(int index) {
    if (_mode == NavigationMode.main) {
      if (_mainTabIndex != index) {
        _mainTabIndex = index;

        // 채팅 탭을 선택하면 채팅 모드로 전환
        if (index == 3) {
          // 채팅 인덱스
          switchToChatMode();
        }
        notifyListeners();
      }
    } else {
      if (_chatTabIndex != index) {
        _chatTabIndex = index;

        // 홈 탭을 선택하면 메인 모드로 전환
        if (index == 3) {
          // 채팅 모드에서 홈 인덱스
          switchToMainMode();
          _mainTabIndex = 0; // 홈으로 이동
        }
        notifyListeners();
      }
    }
  }

  /// 특정 라우트로 네비게이션
  void navigateToRoute(String route) {
    // 라우트에 따라 적절한 모드와 탭 인덱스 설정
    if (route.startsWith('/chat')) {
      switchToChatMode();
      // 채팅 관련 라우트에 따라 탭 인덱스 설정
      switch (route) {
        case '/chat/list':
          _chatTabIndex = 0;
          break;
        case '/chat/friends':
          _chatTabIndex = 1;
          break;
        case '/chat/search':
          _chatTabIndex = 2;
          break;
      }
    } else {
      switchToMainMode();
      // 메인 라우트에 따라 탭 인덱스 설정
      switch (route) {
        case '/home':
          _mainTabIndex = 0;
          break;
        case '/search':
          _mainTabIndex = 1;
          break;
        case '/inPutPostImage':
          _mainTabIndex = 2;
          break;
        case '/profile':
          _mainTabIndex = 4;
          break;
      }
    }
    notifyListeners();
  }
}
