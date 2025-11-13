import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/layout_type.dart';
import '/core/utils/ui/box_sizing/aspect_ratio_analyzer.dart';

part 'versus_box_size_data.freezed.dart';
part 'versus_box_size_data.g.dart';

// ============================================================================
// Custom JSON Converters
// ============================================================================

/// Flutter Size 타입을 JSON으로 직렬화/역직렬화하는 컨버터
class SizeConverter implements JsonConverter<Size, Map<String, dynamic>> {
  const SizeConverter();

  @override
  Size fromJson(Map<String, dynamic> json) {
    return Size(
      (json['width'] as num).toDouble(),
      (json['height'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(Size size) {
    return {
      'width': size.width,
      'height': size.height,
    };
  }
}

// ============================================================================
// Domain Entity
// ============================================================================

/// 질문 작성 페이지에서 생성된 A/B 박스 사이즈 데이터
///
/// 투표 알림 UI에서 동일한 비율과 레이아웃을 재현하기 위해
/// 원본 크기 정보를 저장합니다.
///
/// **Clean Architecture v4.0 - Freezed Domain Entity**:
/// - Immutable value object with auto-generated copyWith
/// - Custom SizeConverter for Flutter Size type
/// - JSON serialization support for caching/persistence
/// - 8 business logic getters (isValid, isAOnly, etc.)
@freezed
sealed class VersusBoxSizeData with _$VersusBoxSizeData {
  const VersusBoxSizeData._();

  const factory VersusBoxSizeData({
    /// 레이아웃 타입 (가로/세로/단일 배치)
    required LayoutType layoutType,

    /// A 이미지 비율 (width/height)
    double? aspectRatioA,

    /// B 이미지 비율 (width/height)
    double? aspectRatioB,

    /// 질문 작성 시 A 박스 크기
    @SizeConverter() required Size originalSizeA,

    /// 질문 작성 시 B 박스 크기 (B박스가 없으면 Size.zero)
    @SizeConverter() required Size originalSizeB,

    /// 질문 작성 시 화면 너비
    required double screenWidth,

    /// 데이터 생성 시간
    required DateTime createdAt,

    /// A박스에 이미지가 있는지 여부
    @Default(false) bool hasImageA,

    /// B박스에 이미지가 있는지 여부
    @Default(false) bool hasImageB,
  }) = _VersusBoxSizeData;

  factory VersusBoxSizeData.fromJson(Map<String, dynamic> json) =>
      _$VersusBoxSizeDataFromJson(json);

  /// 팩토리 생성자 - 질문 작성 페이지에서 현재 상태로 생성
  factory VersusBoxSizeData.fromCurrentState({
    required BuildContext context,
    required LayoutType layoutType,
    List<double>? aspectRatiosA,
    List<double>? aspectRatiosB,
    required Size boxSizeA,
    required Size boxSizeB,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 첫 번째 이미지의 비율을 대표값으로 사용 (멀티 이미지의 경우)
    final aspectRatioA =
        aspectRatiosA?.isNotEmpty == true ? aspectRatiosA!.first : null;
    final aspectRatioB =
        aspectRatiosB?.isNotEmpty == true ? aspectRatiosB!.first : null;

    return VersusBoxSizeData(
      layoutType: layoutType,
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      originalSizeA: boxSizeA,
      originalSizeB: boxSizeB,
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: aspectRatioA != null,
      hasImageB: aspectRatioB != null,
    );
  }

  // ============================================================================
  // Business Logic
  // ============================================================================

  /// 유효성 검사
  bool get isValid {
    return originalSizeA.width > 0 &&
        originalSizeA.height > 0 &&
        screenWidth > 0 &&
        (layoutType != LayoutType.single || hasImageA);
  }

  /// A박스만 있는지 확인
  bool get isAOnly => hasImageA && !hasImageB;

  /// B박스만 있는지 확인
  bool get isBOnly => !hasImageA && hasImageB;

  /// 둘 다 있는지 확인
  bool get hasBothImages => hasImageA && hasImageB;

  /// 이미지가 하나도 없는지 확인
  bool get hasNoImages => !hasImageA && !hasImageB;

  /// A박스의 이미지 방향
  ImageOrientation? get orientationA {
    if (aspectRatioA == null) return null;
    return AspectRatioAnalyzer.getOrientation(aspectRatioA!);
  }

  /// B박스의 이미지 방향
  ImageOrientation? get orientationB {
    if (aspectRatioB == null) return null;
    return AspectRatioAnalyzer.getOrientation(aspectRatioB!);
  }
}
