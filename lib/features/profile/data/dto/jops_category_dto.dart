import '../../domain/models/jops_category_model.dart';

/// JopsCategory DTO (Clean Architecture v4.0)
///
/// **책임**: Firestore 문서 구조와 Domain Model 간 변환
/// - fromFirestore(): Firestore Map → DTO
/// - toFirestore(): DTO → Firestore Map
/// - toDomain(): DTO → Domain Model
/// - fromDomain(): Domain Model → DTO
class JopsCategoryDto {
  final String? jopName;
  final String? categoryRefA;
  final String? categoryRefB;
  final List<String>? searchTags;

  const JopsCategoryDto({
    this.jopName,
    this.categoryRefA,
    this.categoryRefB,
    this.searchTags,
  });

  /// Firestore → DTO
  factory JopsCategoryDto.fromFirestore(Map<String, dynamic> data) {
    return JopsCategoryDto(
      jopName: data['jopName'] as String?,
      categoryRefA: data['categoryRefA'] as String?,
      categoryRefB: data['categoryRefB'] as String?,
      searchTags: (data['searchTags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (jopName != null) 'jopName': jopName,
      if (categoryRefA != null) 'categoryRefA': categoryRefA,
      if (categoryRefB != null) 'categoryRefB': categoryRefB,
      if (searchTags != null) 'searchTags': searchTags,
    };
  }

  /// DTO → Domain Model
  JopsCategory toDomain() {
    return JopsCategory(
      jopName: jopName ?? '',
      categoryRefA: categoryRefA ?? '',
      categoryRefB: categoryRefB ?? '',
      searchTags: searchTags ?? const [],
    );
  }

  /// Domain Model → DTO
  factory JopsCategoryDto.fromDomain(JopsCategory model) {
    return JopsCategoryDto(
      jopName: model.jopName,
      categoryRefA: model.categoryRefA,
      categoryRefB: model.categoryRefB,
      searchTags: model.searchTags,
    );
  }
}
