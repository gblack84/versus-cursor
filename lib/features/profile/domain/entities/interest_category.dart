import 'package:freezed_annotation/freezed_annotation.dart';

part 'interest_category.freezed.dart';
part 'interest_category.g.dart';

/// InterestCategory pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - Freezed sealed class로 전환 (77줄 → 30줄, 61% 감소)
/// - copyWith, toString, hashCode, == 자동 생성
/// - fromJson/toJson 자동 생성
/// - 40줄의 boilerplate 코드 제거
///
/// **이전 변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createInterestModelData() 제거 → InterestDto.toFirestore()로 이동
/// - InterestModelDocumentEquality 제거 → == operator 사용
/// - Interest → InterestCategory (2025-01-30): 네이밍 충돌 해결
///
/// Represents an interest category that users can select from Firestore collection
@freezed
sealed class InterestCategory with _$InterestCategory {
  const factory InterestCategory({
    required String interestId,
    required String nameInterest,
    @Default([]) List<String> userIds,
    @Default([]) List<String> subCategories,
  }) = _InterestCategory;

  factory InterestCategory.fromJson(Map<String, dynamic> json) =>
      _$InterestCategoryFromJson(json);
}
