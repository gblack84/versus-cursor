import 'package:flutter/material.dart' hide NavigationMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '/core/design_system/design_system.dart';
import '/app/router/navigation/navigation_notifier.dart';
import '/app/router/navigation/navigation_state.dart';

/// 메인 네비게이션 쉘
/// 바텀 네비게이션 바와 페이지들을 관리하는 위젯
///
/// **Riverpod 3.x 마이그레이션**:
/// - StatelessWidget → ConsumerWidget
/// - Consumer<T> → ref.watch()
/// - Provider 0.x → Riverpod 3.x
class MainNavigationShell extends ConsumerWidget {
  final Widget child;

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

/// 바텀 네비게이션 아이템 위젯 (커스텀 디자인이 필요한 경우)
class NavigationItemWidget extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

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
