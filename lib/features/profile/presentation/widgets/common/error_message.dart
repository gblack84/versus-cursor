import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 에러 메시지 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 공통 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 재시도 버튼 옵션 제공
class ProfileErrorMessage extends StatelessWidget {
  const ProfileErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.retryButtonText,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 에러 아이콘
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.of(context).error,
            ),
            const SizedBox(height: 16),

            // 에러 메시지
            Text(
              message,
              style: AppTheme.of(context).bodyMedium,
              textAlign: TextAlign.center,
            ),

            // 재시도 버튼 (옵션)
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  retryButtonText ??
                      AppLocalizations.of(context).getText('retry' /* 다시 시도 */),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
