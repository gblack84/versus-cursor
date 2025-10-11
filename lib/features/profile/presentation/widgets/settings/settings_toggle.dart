import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 설정 토글 스위치 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 아이콘, 제목, 설명 및 토글 스위치 지원
class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    super.key,
    required this.title,
    this.description,
    this.icon,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String title;
  final String? description;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: AppTheme.of(context).primary,
      ),
    );
  }
}
