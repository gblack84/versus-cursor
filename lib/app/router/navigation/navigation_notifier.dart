import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'navigation_state.dart';

part 'navigation_notifier.g.dart';

/// Navigation Provider
///
/// **Riverpod 3.x 마이그레이션**:
/// - ChangeNotifierProvider → @riverpod class pattern
/// - Feature-First 아키텍처: /app/router/navigation/
/// - Clean Architecture 준수
///
/// **제공 기능**:
/// - 네비게이션 모드 관리 (Main ↔ Chat)
/// - 탭 인덱스 추적
/// - 라우트 기반 네비게이션
@riverpod
class Navigation extends _$Navigation {
  @override
  NavigationState build() {
    return NavigationState.initial();
  }

  /// 네비게이션 모드 설정
  void setMode(NavigationMode mode) {
    if (state.mode != mode) {
      state = state.copyWith(mode: mode);
    }
  }

  /// 메인 모드로 전환
  void switchToMainMode() {
    setMode(NavigationMode.main);
  }

  /// 채팅 모드로 전환
  void switchToChatMode() {
    state = state.copyWith(
      mode: NavigationMode.chat,
      chatTabIndex: 0, // 채팅 리스트로 초기화
    );
  }

  /// 탭 인덱스 설정
  void setTabIndex(int index) {
    if (state.mode == NavigationMode.main) {
      if (state.mainTabIndex != index) {
        // 채팅 탭을 선택하면 채팅 모드로 전환
        if (index == 3) {
          // 채팅 인덱스
          switchToChatMode();
        } else {
          state = state.copyWith(mainTabIndex: index);
        }
      }
    } else {
      if (state.chatTabIndex != index) {
        // 홈 탭을 선택하면 메인 모드로 전환
        if (index == 3) {
          // 채팅 모드에서 홈 인덱스
          state = state.copyWith(
            mode: NavigationMode.main,
            mainTabIndex: 0, // 홈으로 이동
          );
        } else {
          state = state.copyWith(chatTabIndex: index);
        }
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
          state = state.copyWith(chatTabIndex: 0);
          break;
        case '/chat/friends':
          state = state.copyWith(chatTabIndex: 1);
          break;
        case '/chat/search':
          state = state.copyWith(chatTabIndex: 2);
          break;
      }
    } else {
      switchToMainMode();
      // 메인 라우트에 따라 탭 인덱스 설정
      switch (route) {
        case '/home':
          state = state.copyWith(mainTabIndex: 0);
          break;
        case '/search':
          state = state.copyWith(mainTabIndex: 1);
          break;
        case '/inPutPostImage':
          state = state.copyWith(mainTabIndex: 2);
          break;
        case '/profile':
          state = state.copyWith(mainTabIndex: 4);
          break;
      }
    }
  }
}
