import 'package:freezed_annotation/freezed_annotation.dart';

part 'ranking.freezed.dart';
part 'ranking.g.dart';

/// Pure Domain Entity for ranking
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - 순수 Dart 타입만 사용 (Firestore 의존성 제거)
/// - 불변 객체 (Freezed)
/// - 비즈니스 로직에 집중
///
/// **Freezed Migration**: Legacy RankingsModel에서 Freezed로 마이그레이션
/// - toJson/fromJson 수동 구현 → 자동 생성
/// - 불변성 자동 보장
/// - copyWith 자동 생성
@freezed
sealed class Ranking with _$Ranking {
  const Ranking._();

  const factory Ranking({
    /// 랭킹 ID (비즈니스 식별자)
    required String rankingId,

    /// 랭킹 유형 (daily, weekly, monthly)
    required String type,

    /// 랭킹 날짜
    DateTime? date,
  }) = _Ranking;

  /// Freezed's fromJson for JSON deserialization
  factory Ranking.fromJson(Map<String, dynamic> json) => _$RankingFromJson(json);

  // ============================================
  // Business Logic (비즈니스 로직)
  // ============================================

  /// 랭킹 유형 검증
  bool get isValidType {
    return ['daily', 'weekly', 'monthly'].contains(type.toLowerCase());
  }

  /// 일간 랭킹 여부
  bool get isDaily => type.toLowerCase() == 'daily';

  /// 주간 랭킹 여부
  bool get isWeekly => type.toLowerCase() == 'weekly';

  /// 월간 랭킹 여부
  bool get isMonthly => type.toLowerCase() == 'monthly';

  /// 랭킹 유효성 검증
  bool get isValid {
    return rankingId.isNotEmpty && isValidType;
  }

  /// 랭킹이 최신인지 확인 (24시간 이내)
  bool get isRecent {
    if (date == null) return false;
    final now = DateTime.now();
    final difference = now.difference(date!);
    return difference.inHours < 24;
  }
}
