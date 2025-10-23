import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_options.freezed.dart';
part 'vote_options.g.dart';

/// 투표 옵션 Value Object
/// Clean Architecture - 도메인 값 객체
///
/// **Freezed Migration**: Plain class → Freezed로 변환
/// - 불변성 자동 보장
/// - copyWith 자동 생성
/// - JSON 직렬화 자동 생성
/// - 7개 비즈니스 로직 유지
@freezed
sealed class VoteOptions with _$VoteOptions {
  const VoteOptions._();

  const factory VoteOptions({
    required String optionATitle,
    required String optionBTitle,
    String? optionADescription,
    String? optionBDescription,
    @Default([]) List<String> optionAImageUrls,
    @Default([]) List<String> optionBImageUrls,
    double? optionAAspectRatio,
    double? optionBAspectRatio,
    @Default([]) List<String> relatedInterests,
    @Default({}) Map<String, dynamic> metadata,
  }) = _VoteOptions;

  factory VoteOptions.fromJson(Map<String, dynamic> json) =>
      _$VoteOptionsFromJson(json);

  // ============================================================================
  // Business Logic (7개 getter 유지)
  // ============================================================================

  /// 비즈니스 검증: 유효한 투표 옵션인지
  bool get isValid {
    return optionATitle.isNotEmpty &&
        optionBTitle.isNotEmpty &&
        optionATitle != optionBTitle;
  }

  /// 설명이 있는지 확인
  bool get hasDescriptions {
    return optionADescription != null || optionBDescription != null;
  }

  /// 이미지가 있는지 확인
  bool get hasImages {
    return optionAImageUrls.isNotEmpty || optionBImageUrls.isNotEmpty;
  }

  /// 멀티미디어 투표인지 확인
  bool get isMultimedia {
    return hasImages;
  }

  /// 텍스트만 있는 투표인지
  bool get isTextOnly {
    return !hasImages;
  }

  /// 레이아웃 타입 결정
  String get layoutType {
    if (optionAAspectRatio == null || optionBAspectRatio == null) {
      return 'single';
    }

    // 세로형 이미지가 하나라도 있으면 horizontal (좌우 배치)
    final hasVerticalImage =
        (optionAAspectRatio! < 1.0) || (optionBAspectRatio! < 1.0);
    return hasVerticalImage ? 'horizontal' : 'vertical';
  }
}
