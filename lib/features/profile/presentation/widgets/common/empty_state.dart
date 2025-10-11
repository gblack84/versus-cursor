import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 빈 상태 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 공통 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 커스텀 아이콘 및 액션 버튼 지원
class ProfileEmptyState extends StatelessWidget {
  const ProfileEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.description,
    this.actionButton,
  });

  final IconData icon;
  final String message;
  final String? description;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Icon(
              icon,
              size: 80,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 24),

            // 메인 메시지
            Text(
              message,
              style: AppTheme.of(context).headlineSmall.override(
                    color: AppTheme.of(context).primaryText,
                  ),
              textAlign: TextAlign.center,
            ),

            // 설명 (옵션)
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
                textAlign: TextAlign.center,
              ),
            ],

            // 액션 버튼 (옵션)
            if (actionButton != null) ...[
              const SizedBox(height: 24),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
