import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 설정 항목 리스트 타일 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 네비게이션 및 값 표시 지원
class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.value,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      enabled: enabled,
      onTap: enabled ? onTap : null,
      leading: icon != null
          ? Icon(
              icon,
              color: enabled
                  ? AppTheme.of(context).primaryText
                  : AppTheme.of(context).secondaryText,
            )
          : null,
      title: Text(
        title,
        style: AppTheme.of(context).bodyLarge.override(
              color: enabled
                  ? AppTheme.of(context).primaryText
                  : AppTheme.of(context).secondaryText,
            ),
      ),
      subtitle: description != null
          ? Text(
              description!,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            )
          : null,
      trailing: trailing ??
          (value != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value!,
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                    if (onTap != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right,
                        color: AppTheme.of(context).secondaryText,
                      ),
                    ],
                  ],
                )
              : (onTap != null
                  ? Icon(
                      Icons.chevron_right,
                      color: AppTheme.of(context).secondaryText,
                    )
                  : null)),
    );
  }
}
