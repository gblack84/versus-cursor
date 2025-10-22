import '../../domain/models/interest_category.dart';

/// Interest DTO
///
/// **책임**: Firestore interest 컬렉션 문서 구조와 Dart 객체 간 변환
class InterestDto {
  final String? id;
  final String? name;
  final String? category;
  final int? weight;

  const InterestDto({
    this.id,
    this.name,
    this.category,
    this.weight,
  });

  /// Firestore → DTO
  factory InterestDto.fromFirestore(Map<String, dynamic> data) {
    return InterestDto(
      id: data['id'] as String?,
      name: data['name'] as String?,
      category: data['category'] as String?,
      weight: data['weight'] as int?,
    );
  }

  /// DTO → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (weight != null) 'weight': weight,
    };
  }

  /// DTO → Domain Model
  InterestCategory toDomain() {
    return InterestCategory(
      interestId: id ?? '',
      nameInterest: name ?? '',
      userIds: const [],
      subCategories: const [],
    );
  }

  /// Domain Model → DTO
  factory InterestDto.fromDomain(InterestCategory model) {
    return InterestDto(
      id: model.interestId,
      name: model.nameInterest,
    );
  }
}
