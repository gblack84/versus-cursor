import 'package:flutter/material.dart';
import '/core_exports.dart';
import '../common/empty_state.dart';

/// 빈 친구 목록 상태 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - ProfileEmptyState 기반 일관된 디자인
/// - 친구 찾기 액션 지원
class EmptyFriendsState extends StatelessWidget {
  const EmptyFriendsState({
    super.key,
    this.onFindFriends,
  });

  final VoidCallback? onFindFriends;

  @override
  Widget build(BuildContext context) {
    return ProfileEmptyState(
      icon: Icons.people_outline,
      message: AppLocalizations.of(context).getText(
        'no_friends' /* 아직 친구가 없습니다 */,
      ),
      description: AppLocalizations.of(context).getText(
        'no_friends_description' /* 새로운 친구를 찾아보세요 */,
      ),
      actionButton: onFindFriends != null
          ? ElevatedButton.icon(
              onPressed: onFindFriends,
              icon: const Icon(Icons.person_add),
              label: Text(
                AppLocalizations.of(context).getText(
                  'find_friends' /* 친구 찾기 */,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.of(context).primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            )
          : null,
    );
  }
}
