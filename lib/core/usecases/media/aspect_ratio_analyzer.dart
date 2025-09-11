import '../../types/layout_type.dart';

/// Shared aspect ratio analysis utility for all components
///
/// This is a core utility that can be used by any layer without violating
/// Clean Architecture principles. It contains no dependencies on any feature.
class AspectRatioAnalyzer {
  // 이미지 방향 판단 기준값
  static const double landscapeThreshold = 1.2; // 가로형 기준 (가로가 세로보다 1.2배 이상)
  static const double portraitThreshold = 0.8; // 세로형 기준 (가로가 세로의 0.8배 이하)

  /// 이미지 방향 타입
  static ImageOrientation getOrientation(double aspectRatio) {
    if (aspectRatio >= landscapeThreshold) {
      return ImageOrientation.landscape;
    } else if (aspectRatio <= portraitThreshold) {
      return ImageOrientation.portrait;
    } else {
      return ImageOrientation.square;
    }
  }

  /// A/B 이미지 조합에 따른 최적 레이아웃 결정
  static LayoutType getOptimalLayout(double? ratioA, double? ratioB) {
    // 둘 다 없으면 기본 가로 배치
    if (ratioA == null && ratioB == null) {
      return LayoutType.horizontal;
    }

    // 하나만 있으면 단일 이미지 레이아웃
    if (ratioA != null && ratioB == null) {
      return LayoutType.single;
    }
    if (ratioA == null && ratioB != null) {
      return LayoutType.single;
    }

    // 둘 다 있을 때 비율 분석
    final orientationA = getOrientation(ratioA!);
    final orientationB = getOrientation(ratioB!);

    // 둘 다 가로형 → 세로 배치 (위/아래)
    if (orientationA == ImageOrientation.landscape &&
        orientationB == ImageOrientation.landscape) {
      return LayoutType.vertical;
    }

    // 둘 다 세로형 → 가로 배치 (좌/우)
    if (orientationA == ImageOrientation.portrait &&
        orientationB == ImageOrientation.portrait) {
      return LayoutType.horizontal;
    }

    // 정사각형이 포함된 경우
    if (orientationA == ImageOrientation.square ||
        orientationB == ImageOrientation.square) {
      // 정사각형과 가로형 → 세로 배치
      if (orientationA == ImageOrientation.landscape ||
          orientationB == ImageOrientation.landscape) {
        return LayoutType.vertical;
      }
      // 정사각형과 세로형 → 가로 배치
      return LayoutType.horizontal;
    }

    // 혼합형 (가로 + 세로) → 더 극단적인 비율을 가진 쪽을 우선
    return _getMixedLayout(ratioA, ratioB, orientationA, orientationB);
  }

  /// 혼합형 레이아웃 결정 (가로 이미지 + 세로 이미지)
  static LayoutType _getMixedLayout(
    double ratioA,
    double ratioB,
    ImageOrientation orientationA,
    ImageOrientation orientationB,
  ) {
    // 가로형과 세로형이 섞인 경우
    // 더 극단적인 비율을 가진 이미지를 기준으로 결정

    // A가 가로형, B가 세로형
    if (orientationA == ImageOrientation.landscape &&
        orientationB == ImageOrientation.portrait) {
      // A의 가로 비율이 더 극단적이면 세로 배치
      if (ratioA > 1.5) {
        return LayoutType.vertical;
      }
      // B의 세로 비율이 더 극단적이면 가로 배치
      if (ratioB < 0.67) {
        return LayoutType.horizontal;
      }
    }

    // A가 세로형, B가 가로형
    if (orientationA == ImageOrientation.portrait &&
        orientationB == ImageOrientation.landscape) {
      // B의 가로 비율이 더 극단적이면 세로 배치
      if (ratioB > 1.5) {
        return LayoutType.vertical;
      }
      // A의 세로 비율이 더 극단적이면 가로 배치
      if (ratioA < 0.67) {
        return LayoutType.horizontal;
      }
    }

    // 기본값: 가로 배치
    return LayoutType.horizontal;
  }

  /// 레이아웃 타입에 따른 설명 텍스트
  static String getLayoutDescription(LayoutType layout) {
    switch (layout) {
      case LayoutType.horizontal:
        return '좌우 배치';
      case LayoutType.vertical:
        return '상하 배치';
      case LayoutType.single:
        return '단일 이미지';
      case LayoutType.grid:
        return '그리드 배치';
      case LayoutType.adaptive:
        return '적응형 배치';
    }
  }
}

/// 이미지 방향 열거형
enum ImageOrientation {
  landscape, // 가로형
  portrait, // 세로형
  square, // 정사각형
}
