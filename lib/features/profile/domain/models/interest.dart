/// 사용자 관심사 도메인 모델
///
/// **책임**: 사용자의 관심 분야 표현 (직무, 전문성, 취미)
///
/// **제약사항**:
/// - expertise (전문성): 최대 4개
/// - hobbies (취미): 최대 8개
class Interest {
  const Interest({
    required this.id,
    required this.name,
    required this.category,
    this.weight = 0.5,
    this.selectedAt,
  });

  /// 관심사 고유 ID
  final String id;

  /// 관심사 이름
  final String name;

  /// 관심사 카테고리 (job, expertise, hobby)
  final String category;

  /// 가중치 (우선순위, 0.0 ~ 1.0)
  final double weight;

  /// 선택된 날짜
  final DateTime? selectedAt;

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.5,
      selectedAt: json['selectedAt'] != null
          ? DateTime.parse(json['selectedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'weight': weight,
      if (selectedAt != null) 'selectedAt': selectedAt!.toIso8601String(),
    };
  }
}
