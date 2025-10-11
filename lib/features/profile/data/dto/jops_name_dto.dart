import '../../domain/models/jops_name_model.dart';

/// JopsName DTO (Clean Architecture v4.0)
///
/// **책임**: Firestore 문서 구조와 Domain Model 간 변환
/// - fromFirestore(): Firestore Map → DTO
/// - toFirestore(): DTO → Firestore Map
/// - toDomain(): DTO → Domain Model
/// - fromDomain(): Domain Model → DTO
class JopsNameDto {
  final String? name;
  final String? categoryRef;

  const JopsNameDto({
    this.name,
    this.categoryRef,
  });

  /// Firestore → DTO
  factory JopsNameDto.fromFirestore(Map<String, dynamic> data) {
    return JopsNameDto(
      name: data['name'] as String?,
      categoryRef: data['categoryRef'] as String?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) 'name': name,
      if (categoryRef != null) 'categoryRef': categoryRef,
    };
  }

  /// DTO → Domain Model
  JopsName toDomain() {
    return JopsName(
      name: name ?? '',
      categoryRef: categoryRef ?? '',
    );
  }

  /// Domain Model → DTO
  factory JopsNameDto.fromDomain(JopsName model) {
    return JopsNameDto(
      name: model.name,
      categoryRef: model.categoryRef,
    );
  }
}
