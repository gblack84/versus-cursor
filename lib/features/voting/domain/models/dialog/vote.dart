import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote.freezed.dart';
part 'vote.g.dart';

/// Pure Domain Entity for individual vote
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - 순수 Dart 타입만 사용 (Firestore 의존성 제거)
/// - 불변 객체 (Freezed)
/// - 비즈니스 로직에 집중
///
/// **Freezed Migration**: Plain class에서 Freezed로 마이그레이션
/// - toJson/fromJson 수동 구현 → 자동 생성
/// - 불변성 자동 보장
/// - copyWith 자동 생성
@freezed
sealed class Vote with _$Vote {
  const Vote._();

  const factory Vote({
    /// 게시물 ID
    required String postId,

    /// 사용자 ID
    required String userId,

    /// 투표 선택 (A 또는 B)
    required String choice,

    /// 투표 시간
    DateTime? timestamp,
  }) = _Vote;

  /// Freezed's fromJson for JSON deserialization
  factory Vote.fromJson(Map<String, dynamic> json) => _$VoteFromJson(json);

  // ============================================
  // Business Logic (비즈니스 로직)
  // ============================================

  /// 투표가 A 옵션인지 확인
  bool get isOptionA => choice == 'A';

  /// 투표가 B 옵션인지 확인
  bool get isOptionB => choice == 'B';

  /// 투표 유효성 검증
  bool get isValid {
    return postId.isNotEmpty &&
        userId.isNotEmpty &&
        (choice == 'A' || choice == 'B');
  }
}
