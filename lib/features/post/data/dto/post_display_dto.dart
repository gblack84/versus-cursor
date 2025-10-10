import 'package:cloud_firestore/cloud_firestore.dart';

/// Data Transfer Object for PostDisplay
/// Firestore의 원시 데이터를 담는 DTO 클래스
///
/// 역할:
/// - Firestore Map 데이터를 구조화된 객체로 변환
/// - 인프라 레이어의 데이터 타입 처리 (Timestamp, dynamic 등)
/// - Domain 모델과 분리하여 데이터 전송 전용으로 사용
class PostDisplayDto {
  final String id;
  final Map<String, dynamic> rawData;

  const PostDisplayDto({
    required this.id,
    required this.rawData,
  });

  /// Create DTO from Firestore document data
  factory PostDisplayDto.fromFirestore(Map<String, dynamic> data, String id) {
    return PostDisplayDto(
      id: id,
      rawData: data,
    );
  }

  /// Convenience getters for accessing raw data
  String? getString(String key) => rawData[key] as String?;
  int? getInt(String key) => rawData[key] as int?;
  bool? getBool(String key) => rawData[key] as bool?;
  List<dynamic>? getList(String key) => rawData[key] as List<dynamic>?;
  Map<String, dynamic>? getMap(String key) => rawData[key] as Map<String, dynamic>?;

  /// Get DateTime from various Firestore formats
  DateTime? getDateTime(String key) {
    final value = rawData[key];

    if (value == null) return null;

    if (value is DateTime) {
      return value;
    } else if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  /// Get nested option data (optionA or optionB)
  Map<String, dynamic> getOptionData(String optionKey) {
    return rawData[optionKey] as Map<String, dynamic>? ?? {};
  }

  /// Get image URLs from option
  List<String> getOptionImages(String optionKey) {
    final option = getOptionData(optionKey);
    final imagesList = option['images'] as List<dynamic>? ?? [];
    return imagesList
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList();
  }

  /// Get aspect ratios from option
  List<double> getOptionAspectRatios(String optionKey) {
    final option = getOptionData(optionKey);
    final ratiosList = option['aspectRatios'] as List<dynamic>? ?? [];
    return ratiosList
        .map((e) {
          if (e is double) return e;
          if (e is int) return e.toDouble();
          if (e is String) return double.tryParse(e) ?? 1.0;
          return 1.0;
        })
        .toList();
  }

  @override
  String toString() {
    return 'PostDisplayDto(id: $id, rawData: $rawData)';
  }
}
