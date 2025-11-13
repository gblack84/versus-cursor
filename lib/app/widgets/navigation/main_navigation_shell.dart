import 'package:flutter/material.dart' hide NavigationMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/core/design_system/design_system.dart';
import '/app/router/navigation/navigation_notifier.dart';
import '/app/router/navigation/navigation_state.dart';

/// **메인 네비게이션 쉘 - GoRouter ShellRoute 패턴 구현**
///
/// 이 위젯은 [GoRouter]의 [ShellRoute]와 함께 사용되어 페이지 전환 시에도
/// 하단 네비게이션 바를 유지하는 역할을 합니다.
///
/// ## 핵심 기능
///
/// 1. **두 가지 네비게이션 모드**:
///    - `Main Mode`: 홈/검색/생성/채팅/프로필 (5개 탭)
///    - `Chat Mode`: 채팅목록/친구/AI채팅/홈 (4개 탭)
///
/// 2. **모드 자동 전환**:
///    - Main Mode에서 "채팅" 탭(index 3) 선택 → Chat Mode로 전환
///    - Chat Mode에서 "홈" 탭(index 3) 선택 → Main Mode로 복귀
///
/// 3. **부드러운 애니메이션**:
///    - 네비게이션 바: [AnimatedContainer] 300ms (Curves.easeInOut)
///    - 아이콘 전환: [AnimatedSwitcher] 200ms
///
/// ## Riverpod 3.x 통합
///
/// ```dart
/// // navigationProvider 구독하여 실시간 상태 반영
/// final navigationState = ref.watch(navigationProvider);
///
/// // 탭 변경 시 navigationProvider.notifier 사용
/// ref.read(navigationProvider.notifier).setTabIndex(index);
/// ```
///
/// ## 사용 예시
///
/// GoRouter 설정에서 ShellRoute의 builder로 사용:
///
/// ```dart
/// ShellRoute(
///   navigatorKey: _shellNavigatorKey,
///   builder: (context, state, child) {
///     return MainNavigationShell(child: child);
///   },
///   routes: [
///     GoRoute(path: '/home', builder: (context, state) => HomePageWidget()),
///     GoRoute(path: '/search', builder: (context, state) => SearchPageWidget()),
///     // ... 다른 routes
///   ],
/// )
/// ```
///
/// ## Clean Architecture v4.0 + Riverpod 3.x
///
/// - **Migration Status**: ✅ 완료
/// - **Before**: StatelessWidget + Provider 0.x
/// - **After**: [ConsumerWidget] + Riverpod 3.x
/// - **Benefits**: ref.watch()로 자동 리빌드, 타입 안전성 향상
///
/// ## 참고
///
/// - [NavigationState]: 현재 모드, 탭 인덱스, 아이템 목록 관리
/// - [NavigationNotifier]: 모드 전환, 탭 변경 로직 제공
/// - [VersusColors], [VersusTextStyles]: 디자인 시스템 통합
class MainNavigationShell extends ConsumerWidget {
  /// ShellRoute에서 전달받은 자식 페이지 위젯
  ///
  /// GoRouter가 현재 경로에 맞는 페이지를 child로 전달하며,
  /// 이 위젯은 child를 Scaffold.body에 배치하고
  /// bottomNavigationBar로 감싸는 역할을 합니다.
  final Widget child;

  /// [MainNavigationShell] 생성자
  ///
  /// [child] 파라미터는 필수이며, GoRouter의 ShellRoute가
  /// 현재 경로에 해당하는 페이지 위젯을 주입합니다.
  const MainNavigationShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNavigationBar(
        context,
        ref,
        navigationState,
      ),
    );
  }

  /// **하단 네비게이션 바 빌더**
  ///
  /// 현재 [NavigationState]에 따라 적절한 네비게이션 바를 생성합니다.
  ///
  /// ## 구현 세부사항
  ///
  /// 1. **AnimatedContainer (300ms)**:
  ///    - 모드 전환 시 부드러운 애니메이션 제공
  ///    - [Curves.easeInOut]으로 자연스러운 가속/감속
  ///
  /// 2. **BoxShadow 스타일링**:
  ///    - 상단 그림자 효과 (offset: 0, -5)
  ///    - blurRadius: 10, color: black 10% opacity
  ///    - Material Design elevation 효과 모방
  ///
  /// 3. **디자인 시스템 통합**:
  ///    - 선택된 탭: [VersusColors.primary]
  ///    - 비선택 탭: [VersusColors.textSecondary]
  ///    - 라벨 스타일: [VersusTextStyles.labelSmall]
  ///
  /// 4. **아이콘 애니메이션**:
  ///    - [AnimatedSwitcher] 200ms duration
  ///    - 선택 시 activeIcon으로 전환
  ///    - [ValueKey]로 애니메이션 트리거
  ///
  /// ## 파라미터
  ///
  /// - [context]: BuildContext (GoRouter 네비게이션에 필요)
  /// - [ref]: WidgetRef (Riverpod provider 접근용)
  /// - [state]: 현재 [NavigationState] (모드, 탭 인덱스, 아이템 목록)
  ///
  /// ## 반환값
  ///
  /// [AnimatedContainer]로 감싼 [BottomNavigationBar] 위젯
  Widget _buildBottomNavigationBar(
    BuildContext context,
    WidgetRef ref,
    NavigationState state,
  ) {
    final items = state.currentItems;
    final currentIndex = state.currentTabIndex;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, ref, state, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: VersusColors.primary,
        unselectedItemColor: VersusColors.textSecondary,
        selectedLabelStyle: VersusTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: VersusTextStyles.labelSmall,
        elevation: 0,
        items: items.map((item) {
          final isSelected = items.indexOf(item) == currentIndex;
          return BottomNavigationBarItem(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
              ),
            ),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  /// **탭 선택 이벤트 핸들러 (모드 전환 로직 포함)**
  ///
  /// 사용자가 네비게이션 바의 탭을 선택했을 때 호출되며,
  /// 선택된 탭의 인덱스에 따라 다음 세 가지 동작 중 하나를 수행합니다:
  ///
  /// ## 동작 분류
  ///
  /// ### 1. Main Mode → Chat Mode 전환 (index == 3)
  ///
  /// **조건**: `state.mode == NavigationMode.main && index == 3`
  ///
  /// **동작**:
  /// ```dart
  /// notifier.switchToChatMode();  // 모드 변경 + chatTabIndex 초기화
  /// context.go('/chat/list');     // 채팅 목록 화면으로 이동
  /// ```
  ///
  /// **결과**:
  /// - 네비게이션 바가 Chat Mode 아이템으로 변경 (4개 탭)
  /// - 채팅 목록 화면 표시
  /// - 애니메이션: 300ms AnimatedContainer
  ///
  /// ### 2. Chat Mode → Main Mode 복귀 (index == 3)
  ///
  /// **조건**: `state.mode == NavigationMode.chat && index == 3`
  ///
  /// **동작**:
  /// ```dart
  /// notifier.switchToMainMode();  // 모드 복귀 + mainTabIndex 복원
  /// context.go('/home');          // 홈 화면으로 이동
  /// ```
  ///
  /// **결과**:
  /// - 네비게이션 바가 Main Mode 아이템으로 복귀 (5개 탭)
  /// - 이전에 선택했던 mainTabIndex 유지 (기본값: 0 - 홈)
  /// - 애니메이션: 300ms AnimatedContainer
  ///
  /// ### 3. 일반 탭 선택 (그 외 모든 경우)
  ///
  /// **조건**: 위의 두 조건에 해당하지 않는 모든 탭 선택
  ///
  /// **동작**:
  /// ```dart
  /// notifier.setTabIndex(index);  // 현재 모드의 탭 인덱스만 업데이트
  /// context.go(selectedItem.route);  // 해당 탭의 route로 이동
  /// ```
  ///
  /// **결과**:
  /// - 같은 모드 내에서 탭만 변경
  /// - GoRouter가 해당 경로의 페이지 렌더링
  /// - 애니메이션: 200ms AnimatedSwitcher (아이콘만)
  ///
  /// ## 특수 케이스: index 3의 이중 역할
  ///
  /// ```
  /// Main Mode (5개 탭):
  ///   0: 홈, 1: 검색, 2: 생성, [3: 채팅 → Chat Mode 전환], 4: 프로필
  ///
  /// Chat Mode (4개 탭):
  ///   0: 채팅목록, 1: 친구, 2: AI채팅, [3: 홈 → Main Mode 복귀]
  /// ```
  ///
  /// ## 파라미터
  ///
  /// - [context]: [GoRouter] 네비게이션을 위한 BuildContext
  /// - [ref]: [NavigationNotifier] 접근을 위한 WidgetRef
  /// - [state]: 현재 [NavigationState] (모드, 탭 인덱스 확인용)
  /// - [index]: 선택된 탭의 인덱스 (0부터 시작)
  ///
  /// ## 관련 메서드
  ///
  /// - [NavigationNotifier.switchToChatMode]: Main → Chat 모드 전환
  /// - [NavigationNotifier.switchToMainMode]: Chat → Main 모드 복귀
  /// - [NavigationNotifier.setTabIndex]: 같은 모드 내 탭 변경
  void _onItemTapped(
    BuildContext context,
    WidgetRef ref,
    NavigationState state,
    int index,
  ) {
    final notifier = ref.read(navigationProvider.notifier);
    final items = state.currentItems;
    final selectedItem = items[index];

    // 특별한 처리가 필요한 경우
    if (state.mode == NavigationMode.main && index == 3) {
      // 메인 모드에서 채팅 탭 선택 시
      notifier.switchToChatMode();
      context.go('/chat/list');
    } else if (state.mode == NavigationMode.chat && index == 3) {
      // 채팅 모드에서 홈 탭 선택 시
      notifier.switchToMainMode();
      context.go('/home');
    } else {
      // 일반적인 탭 선택
      notifier.setTabIndex(index);
      context.go(selectedItem.route);
    }
  }
}

/// **커스텀 네비게이션 아이템 위젯 (향후 사용 예정)**
///
/// **현재 상태**: ⚠️ 미사용 (Prepared for Future Use)
///
/// 이 위젯은 Flutter의 기본 [BottomNavigationBar] 대신
/// 완전히 커스터마이징된 네비게이션 바를 구현할 때 사용할 수 있도록
/// 미리 준비된 컴포넌트입니다.
///
/// ## 왜 현재 사용하지 않나요?
///
/// 현재 [MainNavigationShell]은 Flutter의 표준 [BottomNavigationBar]를 사용하고 있으며,
/// 이것으로도 프로젝트 요구사항을 충분히 만족합니다:
///
/// - Material Design 가이드라인 준수
/// - 접근성 (Accessibility) 자동 지원
/// - 플랫폼별 최적화 (iOS/Android)
/// - 유지보수 용이성
///
/// ## 언제 사용하게 되나요?
///
/// 다음과 같은 경우 이 위젯으로 교체할 수 있습니다:
///
/// 1. **독특한 디자인 요구사항**:
///    - 기본 BottomNavigationBar로 구현 불가능한 UI
///    - 예: 중앙 FAB, 불규칙한 아이템 크기, 복잡한 애니메이션
///
/// 2. **세밀한 제어 필요**:
///    - 아이템별 다른 애니메이션 타이밍
///    - 커스텀 제스처 인식 (예: 스와이프, 롱프레스)
///    - 동적 아이템 추가/제거
///
/// 3. **성능 최적화**:
///    - BottomNavigationBar의 리빌드 최소화
///    - 복잡한 애니메이션 최적화
///
/// ## 구현 세부사항
///
/// ### 애니메이션
///
/// - **Container**: 200ms duration (선택 상태 전환)
/// - **Icon Switcher**: 200ms AnimatedSwitcher
/// - **Text Style**: 200ms AnimatedDefaultTextStyle
///
/// ### 디자인 시스템
///
/// - 선택 색상: [VersusColors.primary]
/// - 비선택 색상: [VersusColors.textSecondary]
/// - 텍스트: [VersusTextStyles.labelSmall]
/// - 선택 시 fontWeight: w600 (bold)
///
/// ## 교체 방법
///
/// ```dart
/// // Before: BottomNavigationBar 사용
/// return AnimatedContainer(
///   child: BottomNavigationBar(
///     items: items.map((item) => BottomNavigationBarItem(...)).toList(),
///   ),
/// );
///
/// // After: NavigationItemWidget 사용
/// return AnimatedContainer(
///   child: Row(
///     mainAxisAlignment: MainAxisAlignment.spaceAround,
///     children: items.asMap().entries.map((entry) {
///       final index = entry.key;
///       final item = entry.value;
///       return NavigationItemWidget(
///         item: item,
///         isSelected: index == currentIndex,
///         onTap: () => _onItemTapped(context, ref, state, index),
///       );
///     }).toList(),
///   ),
/// );
/// ```
///
/// ## 참고
///
/// - Tree Shaking: 미사용 코드로 Release 빌드에서 자동 제거
/// - 번들 크기 영향: 없음 (Dead Code Elimination)
class NavigationItemWidget extends StatelessWidget {
  /// 네비게이션 아이템 데이터 ([NavigationItem] from NavigationState)
  final NavigationItem item;

  /// 현재 이 아이템이 선택된 상태인지 여부
  final bool isSelected;

  /// 아이템 탭 시 호출되는 콜백
  final VoidCallback onTap;

  /// [NavigationItemWidget] 생성자
  ///
  /// [item], [isSelected], [onTap] 모두 필수 파라미터입니다.
  const NavigationItemWidget({
    Key? key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                key: ValueKey(isSelected),
                color: isSelected
                    ? VersusColors.primary
                    : VersusColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: VersusTextStyles.labelSmall.copyWith(
                color: isSelected
                    ? VersusColors.primary
                    : VersusColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}
