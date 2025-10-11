import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/user_profile.dart';
import '../profile/profile_avatar.dart';

/// 친구 요청 카드 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - UserProfile 도메인 모델 사용
/// - 수락/거부 액션 지원
class FriendRequestCard extends StatelessWidget {
  const FriendRequestCard({
    super.key,
    required this.requester,
    this.onAccept,
    this.onReject,
    this.isLoading = false,
  });

  final UserProfile requester;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // 요청자 정보
          Row(
            children: [
              ProfileAvatar(
                photoUrl: requester.photoUrl,
                size: AvatarSize.medium,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester.displayName,
                      style: AppTheme.of(context).bodyLarge.override(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (requester.shortDescription.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        requester.shortDescription,
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).secondaryText,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 액션 버튼
          Row(
            children: [
              // 거부 버튼
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.of(context).error,
                    side: BorderSide(
                      color: AppTheme.of(context).error,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).getText('reject' /* 거부 */),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 수락 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context).getText('accept' /* 수락 */),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
