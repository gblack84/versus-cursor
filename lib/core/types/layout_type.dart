/// Unified layout type enum for the entire application
///
/// This enum defines all possible layout types used across features
/// for image, media, and UI layout configurations.
///
/// Consolidated from multiple duplicate definitions to resolve
/// compilation errors and maintain consistency.
enum LayoutType {
  /// Horizontal layout (left/right arrangement)
  /// 가로 배치 (좌/우)
  horizontal,

  /// Vertical layout (top/bottom arrangement)
  /// 세로 배치 (위/아래)
  vertical,

  /// Single item layout
  /// 단일 이미지
  single,

  /// Grid layout for multiple items
  /// 그리드 레이아웃
  grid,

  /// Adaptive layout that adjusts based on content
  /// 적응형 레이아웃
  adaptive,
}

/// Extension methods for LayoutType
extension LayoutTypeExtension on LayoutType {
  /// Get Korean description of the layout type
  String get koreanDescription {
    switch (this) {
      case LayoutType.horizontal:
        return '좌우 배치';
      case LayoutType.vertical:
        return '상하 배치';
      case LayoutType.single:
        return '단일 이미지';
      case LayoutType.grid:
        return '그리드 배치';
      case LayoutType.adaptive:
        return '적응형 배치';
    }
  }

  /// Check if this is a basic layout type (horizontal, vertical, single)
  bool get isBasic =>
      this == LayoutType.horizontal ||
      this == LayoutType.vertical ||
      this == LayoutType.single;

  /// Check if this is an extended layout type (grid, adaptive)
  bool get isExtended => this == LayoutType.grid || this == LayoutType.adaptive;
}
