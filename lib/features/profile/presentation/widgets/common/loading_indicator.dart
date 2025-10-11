import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 로딩 인디케이터 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 공통 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 다양한 크기 옵션 제공
class ProfileLoadingIndicator extends StatelessWidget {
  const ProfileLoadingIndicator({
    super.key,
    this.size = LoadingSize.medium,
    this.message,
  });

  final LoadingSize size;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final indicatorSize = _getIndicatorSize();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.of(context).primary,
              ),
              strokeWidth: _getStrokeWidth(),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  double _getIndicatorSize() {
    switch (size) {
      case LoadingSize.small:
        return 24.0;
      case LoadingSize.medium:
        return 36.0;
      case LoadingSize.large:
        return 48.0;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case LoadingSize.small:
        return 2.0;
      case LoadingSize.medium:
        return 3.0;
      case LoadingSize.large:
        return 4.0;
    }
  }
}

/// 로딩 인디케이터 크기 열거형
enum LoadingSize {
  small,
  medium,
  large,
}
