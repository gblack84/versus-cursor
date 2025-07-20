import 'package:flutter/material.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';

/// 질문 작성 페이지에서 생성된 A/B 박스 사이즈 데이터
/// 
/// 투표 알림 UI에서 동일한 비율과 레이아웃을 재현하기 위해
/// 원본 크기 정보를 저장합니다.
class VersusBoxSizeData {
  /// 레이아웃 타입 (가로/세로/단일 배치)
  final LayoutType layoutType;
  
  /// A 이미지 비율 (width/height)
  final double? aspectRatioA;
  
  /// B 이미지 비율 (width/height)
  final double? aspectRatioB;
  
  /// 질문 작성 시 A 박스 크기
  final Size originalSizeA;
  
  /// 질문 작성 시 B 박스 크기 (B박스가 없으면 Size.zero)
  final Size originalSizeB;
  
  /// 질문 작성 시 화면 너비
  final double screenWidth;
  
  /// 데이터 생성 시간
  final DateTime createdAt;
  
  /// A박스에 이미지가 있는지 여부
  final bool hasImageA;
  
  /// B박스에 이미지가 있는지 여부
  final bool hasImageB;
  
  /// 생성자
  const VersusBoxSizeData({
    required this.layoutType,
    this.aspectRatioA,
    this.aspectRatioB,
    required this.originalSizeA,
    required this.originalSizeB,
    required this.screenWidth,
    required this.createdAt,
    this.hasImageA = false,
    this.hasImageB = false,
  });
  
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
    final aspectRatioA = aspectRatiosA?.isNotEmpty == true ? aspectRatiosA!.first : null;
    final aspectRatioB = aspectRatiosB?.isNotEmpty == true ? aspectRatiosB!.first : null;
    
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
  
  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'layoutType': layoutType.name,
      'aspectRatioA': aspectRatioA,
      'aspectRatioB': aspectRatioB,
      'originalSizeA': {
        'width': originalSizeA.width,
        'height': originalSizeA.height,
      },
      'originalSizeB': {
        'width': originalSizeB.width,
        'height': originalSizeB.height,
      },
      'screenWidth': screenWidth,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'hasImageA': hasImageA,
      'hasImageB': hasImageB,
    };
  }
  
  /// JSON에서 복원
  factory VersusBoxSizeData.fromJson(Map<String, dynamic> json) {
    return VersusBoxSizeData(
      layoutType: LayoutType.values.firstWhere(
        (e) => e.name == json['layoutType'],
        orElse: () => LayoutType.horizontal,
      ),
      aspectRatioA: json['aspectRatioA']?.toDouble(),
      aspectRatioB: json['aspectRatioB']?.toDouble(),
      originalSizeA: Size(
        json['originalSizeA']['width'].toDouble(),
        json['originalSizeA']['height'].toDouble(),
      ),
      originalSizeB: Size(
        json['originalSizeB']['width'].toDouble(),
        json['originalSizeB']['height'].toDouble(),
      ),
      screenWidth: json['screenWidth'].toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      hasImageA: json['hasImageA'] ?? false,
      hasImageB: json['hasImageB'] ?? false,
    );
  }
  
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
  
  /// 디버그용 문자열 표현
  @override
  String toString() {
    return 'VersusBoxSizeData('
           'layout: $layoutType, '
           'ratioA: $aspectRatioA, '
           'ratioB: $aspectRatioB, '
           'sizeA: $originalSizeA, '
           'sizeB: $originalSizeB, '
           'screenWidth: $screenWidth, '
           'hasImages: A=$hasImageA B=$hasImageB'
           ')';
  }
  
  /// 두 VersusBoxSizeData가 같은지 비교
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is VersusBoxSizeData &&
           other.layoutType == layoutType &&
           other.aspectRatioA == aspectRatioA &&
           other.aspectRatioB == aspectRatioB &&
           other.originalSizeA == originalSizeA &&
           other.originalSizeB == originalSizeB &&
           other.screenWidth == screenWidth &&
           other.hasImageA == hasImageA &&
           other.hasImageB == hasImageB;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      layoutType,
      aspectRatioA,
      aspectRatioB,
      originalSizeA,
      originalSizeB,
      screenWidth,
      hasImageA,
      hasImageB,
    );
  }
  
  /// 데이터 복사 (일부 필드 수정용)
  VersusBoxSizeData copyWith({
    LayoutType? layoutType,
    double? aspectRatioA,
    double? aspectRatioB,
    Size? originalSizeA,
    Size? originalSizeB,
    double? screenWidth,
    DateTime? createdAt,
    bool? hasImageA,
    bool? hasImageB,
  }) {
    return VersusBoxSizeData(
      layoutType: layoutType ?? this.layoutType,
      aspectRatioA: aspectRatioA ?? this.aspectRatioA,
      aspectRatioB: aspectRatioB ?? this.aspectRatioB,
      originalSizeA: originalSizeA ?? this.originalSizeA,
      originalSizeB: originalSizeB ?? this.originalSizeB,
      screenWidth: screenWidth ?? this.screenWidth,
      createdAt: createdAt ?? this.createdAt,
      hasImageA: hasImageA ?? this.hasImageA,
      hasImageB: hasImageB ?? this.hasImageB,
    );
  }
}