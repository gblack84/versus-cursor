import '../models/notification.dart';

/// 알림 필터 Value Object
/// Clean Architecture - 도메인 값 객체
class NotificationFilter {
  final NotificationType? type;
  final bool? unreadOnly;
  final DateTime? after;
  final DateTime? before;
  final int? limit;
  final String? sortBy;
  final bool? excludeExpired;
  final String? userId;
  final SortOrder? sortOrder;

  const NotificationFilter({
    this.type,
    this.unreadOnly,
    this.after,
    this.before,
    this.limit,
    this.sortBy = 'createdAt',
    this.excludeExpired = true,
    this.userId,
    this.sortOrder = SortOrder.descending,
  });

  /// 필터가 적용되었는지 확인
  bool get hasFilters {
    return type != null ||
        unreadOnly != null ||
        after != null ||
        before != null ||
        limit != null ||
        excludeExpired != null ||
        userId != null;
  }

  /// 날짜 범위가 유효한지 확인
  bool get isDateRangeValid {
    if (after == null || before == null) return true;
    return after!.isBefore(before!);
  }

  /// 기본 필터 생성 (읽지 않은, 만료되지 않은 알림)
  factory NotificationFilter.unreadActive() {
    return const NotificationFilter(
      unreadOnly: true,
      excludeExpired: true,
      sortOrder: SortOrder.descending,
    );
  }

  /// 투표 알림 전용 필터
  factory NotificationFilter.votingRequests({
    bool unreadOnly = true,
    int? limit,
  }) {
    return NotificationFilter(
      type: NotificationType.votingRequest,
      unreadOnly: unreadOnly,
      excludeExpired: true,
      limit: limit,
      sortOrder: SortOrder.descending,
    );
  }

  /// 최근 알림 필터 (24시간 이내)
  factory NotificationFilter.recent({int days = 30, int limit = 50}) {
    return NotificationFilter(
      after: DateTime.now().subtract(Duration(days: days)),
      sortOrder: SortOrder.descending,
      limit: limit,
    );
  }

  /// 읽지 않은 알림만 필터
  factory NotificationFilter.unreadOnly() {
    return const NotificationFilter(
      unreadOnly: true,
    );
  }

  /// 타입별 필터
  factory NotificationFilter.byType(NotificationType type) {
    return NotificationFilter(
      type: type,
    );
  }

  /// 필터 복사 및 수정
  NotificationFilter copyWith({
    NotificationType? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
    String? sortBy,
    bool? excludeExpired,
    String? userId,
    SortOrder? sortOrder,
  }) {
    return NotificationFilter(
      type: type ?? this.type,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      after: after ?? this.after,
      before: before ?? this.before,
      limit: limit ?? this.limit,
      sortBy: sortBy ?? this.sortBy,
      excludeExpired: excludeExpired ?? this.excludeExpired,
      userId: userId ?? this.userId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() {
    final filters = <String>[];
    if (type != null) filters.add('type=${type!.value}');
    if (unreadOnly == true) filters.add('unreadOnly');
    if (after != null) filters.add('after=$after');
    if (before != null) filters.add('before=$before');
    if (limit != null) filters.add('limit=$limit');
    if (excludeExpired == true) filters.add('excludeExpired');
    if (userId != null) filters.add('userId=$userId');
    if (sortOrder != null) filters.add('sort=${sortOrder?.name}');

    return 'NotificationFilter(${filters.join(', ')})';
  }
}

/// 정렬 순서 열거형
enum SortOrder {
  ascending('asc'),
  descending('desc');

  final String value;
  const SortOrder(this.value);

  static SortOrder fromString(String value) {
    return SortOrder.values.firstWhere(
      (order) => order.value == value,
      orElse: () => SortOrder.descending,
    );
  }
}
