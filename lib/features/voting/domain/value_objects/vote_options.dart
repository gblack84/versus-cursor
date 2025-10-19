/// 투표 옵션 Value Object
/// Clean Architecture - 도메인 값 객체
class VoteOptions {
  final String optionATitle;
  final String optionBTitle;
  final String? optionADescription;
  final String? optionBDescription;
  final List<String> optionAImageUrls;
  final List<String> optionBImageUrls;
  final double? optionAAspectRatio;
  final double? optionBAspectRatio;
  final List<String> relatedInterests;
  final Map<String, dynamic> metadata;

  const VoteOptions({
    required this.optionATitle,
    required this.optionBTitle,
    this.optionADescription,
    this.optionBDescription,
    this.optionAImageUrls = const [],
    this.optionBImageUrls = const [],
    this.optionAAspectRatio,
    this.optionBAspectRatio,
    this.relatedInterests = const [],
    this.metadata = const {},
  });

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoteOptions &&
        other.optionATitle == optionATitle &&
        other.optionBTitle == optionBTitle;
  }

  @override
  int get hashCode => optionATitle.hashCode ^ optionBTitle.hashCode;
}
