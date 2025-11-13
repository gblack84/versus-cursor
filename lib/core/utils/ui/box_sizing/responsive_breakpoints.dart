import 'package:flutter/material.dart';
import '/core/utils/ui/box_sizing/config/responsive_config.dart';

/// 반응형 디자인을 위한 브레이크포인트 정의
class ResponsiveBreakpoints {
  static const double mobileSmall = 320;
  static const double mobile = 375;
  static const double mobileLarge = 414;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double desktopLarge = 1440;

  /// 현재 디바이스가 모바일인지 확인
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }

  /// 현재 디바이스가 태블릿인지 확인
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// 현재 디바이스가 데스크톱인지 확인
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  /// 현재 디바이스 타입 반환
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < tablet) {
      if (width < mobile) return DeviceType.mobileSmall;
      if (width < mobileLarge) return DeviceType.mobile;
      return DeviceType.mobileLarge;
    } else if (width < desktop) {
      return DeviceType.tablet;
    } else if (width < desktopLarge) {
      return DeviceType.desktop;
    } else {
      return DeviceType.desktopLarge;
    }
  }

  /// 채팅 메시지의 최대 너비
  static double getMaxMessageWidth(BuildContext context) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobileSmall:
        return MediaQuery.of(context).size.width * ResponsiveConfig.mobileSmallMessageWidthRatio;
      case DeviceType.mobile:
      case DeviceType.mobileLarge:
        return MediaQuery.of(context).size.width * ResponsiveConfig.mobileMessageWidthRatio;
      case DeviceType.tablet:
        return ResponsiveConfig.tabletMessageMaxWidth;
      case DeviceType.desktop:
        return ResponsiveConfig.desktopMessageMaxWidth;
      case DeviceType.desktopLarge:
        return ResponsiveConfig.desktopLargeMessageMaxWidth;
    }
  }

  /// 채팅 메시지의 마진
  static EdgeInsets getMessageMargin(BuildContext context, bool isMe) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return EdgeInsets.only(
          left: isMe ? ResponsiveConfig.mobileMessageMarginMyLeft : ResponsiveConfig.mobileMessageMarginOtherLeft,
          right: isMe ? ResponsiveConfig.mobileMessageMarginMyRight : ResponsiveConfig.mobileMessageMarginOtherRight,
          bottom: ResponsiveConfig.mobileMessageMarginBottom,
        );
      case DeviceType.mobileLarge:
        return EdgeInsets.only(
          left: isMe ? ResponsiveConfig.mobileLargeMessageMarginMyLeft : ResponsiveConfig.mobileLargeMessageMarginOtherLeft,
          right: isMe ? ResponsiveConfig.mobileLargeMessageMarginMyRight : ResponsiveConfig.mobileLargeMessageMarginOtherRight,
          bottom: ResponsiveConfig.mobileLargeMessageMarginBottom,
        );
      case DeviceType.tablet:
        return EdgeInsets.only(
          left: isMe ? ResponsiveConfig.tabletMessageMarginMyLeft : ResponsiveConfig.tabletMessageMarginOtherLeft,
          right: isMe ? ResponsiveConfig.tabletMessageMarginMyRight : ResponsiveConfig.tabletMessageMarginOtherRight,
          bottom: ResponsiveConfig.tabletMessageMarginBottom,
        );
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return EdgeInsets.only(
          left: isMe ? ResponsiveConfig.desktopMessageMarginMyLeft : ResponsiveConfig.desktopMessageMarginOtherLeft,
          right: isMe ? ResponsiveConfig.desktopMessageMarginMyRight : ResponsiveConfig.desktopMessageMarginOtherRight,
          bottom: ResponsiveConfig.desktopMessageMarginBottom,
        );
    }
  }

  /// VS 박스의 높이
  static double getVsBoxHeight(
      BuildContext context, bool hasImages, bool isExpanded) {
    final deviceType = getDeviceType(context);

    final baseHeight = hasImages
        ? _getBaseImageHeight(deviceType)
        : _getBaseTextHeight(deviceType);
    final expandedHeight = hasImages
        ? _getExpandedImageHeight(deviceType)
        : _getExpandedTextHeight(deviceType);

    return isExpanded ? expandedHeight : baseHeight;
  }

  static double _getBaseImageHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return ResponsiveConfig.mobileBaseImageHeight;
      case DeviceType.mobileLarge:
        return ResponsiveConfig.mobileLargeBaseImageHeight;
      case DeviceType.tablet:
        return ResponsiveConfig.tabletBaseImageHeight;
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return ResponsiveConfig.desktopBaseImageHeight;
    }
  }

  static double _getExpandedImageHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return ResponsiveConfig.mobileExpandedImageHeight;
      case DeviceType.mobileLarge:
        return ResponsiveConfig.mobileLargeExpandedImageHeight;
      case DeviceType.tablet:
        return ResponsiveConfig.tabletExpandedImageHeight;
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return ResponsiveConfig.desktopExpandedImageHeight;
    }
  }

  static double _getBaseTextHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return ResponsiveConfig.mobileBaseTextHeight; // 이미지의 70% (200 * 0.7)
      case DeviceType.mobileLarge:
        return ResponsiveConfig.mobileLargeBaseTextHeight;
      case DeviceType.tablet:
        return ResponsiveConfig.tabletBaseTextHeight; // 240 * 0.7
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return ResponsiveConfig.desktopBaseTextHeight; // 280 * 0.7
    }
  }

  static double _getExpandedTextHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return ResponsiveConfig.mobileExpandedTextHeight; // 확장 시 약간 더 크게 (300 * 0.7)
      case DeviceType.mobileLarge:
        return ResponsiveConfig.mobileLargeExpandedTextHeight;
      case DeviceType.tablet:
        return ResponsiveConfig.tabletExpandedTextHeight; // 360 * 0.7
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return ResponsiveConfig.desktopExpandedTextHeight; // 420 * 0.7
    }
  }
}

/// 디바이스 타입 정의
enum DeviceType {
  mobileSmall,
  mobile,
  mobileLarge,
  tablet,
  desktop,
  desktopLarge,
}
