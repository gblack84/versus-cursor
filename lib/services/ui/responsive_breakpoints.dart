import 'package:flutter/material.dart';

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
        return MediaQuery.of(context).size.width * 0.85;
      case DeviceType.mobile:
      case DeviceType.mobileLarge:
        return MediaQuery.of(context).size.width * 0.80;
      case DeviceType.tablet:
        return 500;
      case DeviceType.desktop:
        return 600;
      case DeviceType.desktopLarge:
        return 700;
    }
  }

  /// 채팅 메시지의 마진
  static EdgeInsets getMessageMargin(BuildContext context, bool isMe) {
    final deviceType = getDeviceType(context);

    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return EdgeInsets.only(
          left: isMe ? 40 : 12,
          right: isMe ? 12 : 40,
          bottom: 8,
        );
      case DeviceType.mobileLarge:
        return EdgeInsets.only(
          left: isMe ? 50 : 16,
          right: isMe ? 16 : 50,
          bottom: 8,
        );
      case DeviceType.tablet:
        return EdgeInsets.only(
          left: isMe ? 100 : 20,
          right: isMe ? 20 : 100,
          bottom: 12,
        );
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return EdgeInsets.only(
          left: isMe ? 150 : 24,
          right: isMe ? 24 : 150,
          bottom: 12,
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
        return 200.0;
      case DeviceType.mobileLarge:
        return 200.0;
      case DeviceType.tablet:
        return 240.0;
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return 280.0;
    }
  }

  static double _getExpandedImageHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return 300.0;
      case DeviceType.mobileLarge:
        return 300.0;
      case DeviceType.tablet:
        return 360.0;
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return 420.0;
    }
  }

  static double _getBaseTextHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return 140.0; // 이미지의 70% (200 * 0.7)
      case DeviceType.mobileLarge:
        return 140.0;
      case DeviceType.tablet:
        return 168.0; // 240 * 0.7
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return 196.0; // 280 * 0.7
    }
  }

  static double _getExpandedTextHeight(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.mobileSmall:
      case DeviceType.mobile:
        return 210.0; // 확장 시 약간 더 크게 (300 * 0.7)
      case DeviceType.mobileLarge:
        return 210.0;
      case DeviceType.tablet:
        return 252.0; // 360 * 0.7
      case DeviceType.desktop:
      case DeviceType.desktopLarge:
        return 294.0; // 420 * 0.7
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
