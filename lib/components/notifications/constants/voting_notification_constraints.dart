import 'package:flutter/material.dart';

/// 투표 알림 UI의 크기 제약 조건 및 스케일링 설정
/// 
/// 다양한 화면 크기에서 일관된 사용자 경험을 제공하기 위한
/// 최대/최소 크기 및 스케일링 팩터를 정의합니다.
class VotingNotificationConstraints {
  
  // 투표 알림 전체 크기 제약 (동적 계산으로 변경)
  static const double maxNotificationWidthLimit = 500.0;  // 절대 최대 너비
  static const double minNotificationWidth = 320.0;       // 최소 너비 상향
  static const double defaultNotificationPadding = 16.0;  // 기본 패딩
  static const double largeScreenPadding = 20.0;         // 큰 화면 패딩
  
  // 박스 크기 제약 (화면 기반 동적 계산)
  static const double maxBoxHeightRatio = 0.8;   // 화면 높이의 80%까지 허용
  static const double minBoxHeight = 150.0;      // 투표 알림에서 최소 박스 높이 (상향)
  static const double defaultBoxHeight = 350.0;  // 기본 박스 높이 (상향)
  
  // 박스 간 간격
  static const double boxSpacing = 8.0;         // A/B 박스 간 간격
  static const double verticalSpacing = 12.0;   // 세로 간격
  
  // 화면 크기별 스케일링 팩터 (완화된 축소율)
  /// 큰 화면 (>400px): 축소 없음
  static const double largeScreenScale = 1.0;
  static const double largeScreenThreshold = 400.0;
  
  /// 중간 화면 (350-400px): 95% 스케일링
  static const double mediumScreenScale = 0.95;
  static const double mediumScreenThreshold = 350.0;
  
  /// 작은 화면 (<350px): 85% 스케일링
  static const double smallScreenScale = 0.85;
  
  // 애니메이션 설정
  static const Duration slideAnimationDuration = Duration(milliseconds: 500);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);
  static const double slideOffset = -1.0; // 위에서 아래로 슬라이드
  
  // 알림 자동 사라짐 시간
  static const Duration autoHideDuration = Duration(seconds: 30);
  static const Duration voteCompleteDuration = Duration(seconds: 1);
  
  // 텍스트 크기 제약
  static const double maxTextSize = 24.0;     // 16.0 → 24.0 (1.5배 증가)
  static const double minTextSize = 14.0;     // 10.0 → 14.0 (가독성 향상)
  static const double defaultTextSize = 18.0; // 12.0 → 18.0 (1.5배 증가)
  
  // 아이콘 크기
  static const double labelIconSize = 32.0;     // A/B 라벨 아이콘 크기
  static const double actionIconSize = 20.0;    // 액션 아이콘 크기 (닫기 등)
  static const double statusIconSize = 20.0;    // 상태 아이콘 크기 (🎯 등)
  
  // 그림자 및 elevation 설정
  static const double cardElevation = 12.0;
  static const double shadowBlurRadius = 15.0;
  static const double shadowOpacity = 0.15;
  static const Offset shadowOffset = Offset(0, 5);
  
  // Border radius 설정
  static const double cardBorderRadius = 20.0;
  static const double boxBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double labelBorderRadius = 16.0;
  
  /// 화면 크기에 따른 스케일링 팩터 계산
  /// 
  /// [screenWidth] 현재 화면 너비
  /// 반환값: 0.7 ~ 0.9 사이의 스케일링 팩터
  static double getScaleFactor(double screenWidth) {
    if (screenWidth > largeScreenThreshold) {
      return largeScreenScale;      // 큰 화면: 90%
    } else if (screenWidth > mediumScreenThreshold) {
      return mediumScreenScale;     // 중간 화면: 80%
    } else {
      return smallScreenScale;      // 작은 화면: 70%
    }
  }
  
  /// 알림 컨테이너 너비 계산 (동적 계산)
  /// 
  /// [screenWidth] 현재 화면 너비
  /// 반환값: 화면 크기에 최적화된 알림 너비
  static double getNotificationWidth(double screenWidth) {
    // 화면의 92% 사용, 최대 500px로 제한
    final dynamicWidth = screenWidth * 0.92;
    final padding = screenWidth > largeScreenThreshold ? largeScreenPadding : defaultNotificationPadding;
    final maxWidth = dynamicWidth - (padding * 2);
    
    return maxWidth.clamp(minNotificationWidth, maxNotificationWidthLimit);
  }
  
  /// 동적 패딩 계산
  static double getDynamicPadding(double screenWidth) {
    return screenWidth > largeScreenThreshold ? largeScreenPadding : defaultNotificationPadding;
  }
  
  /// 동적 박스 간격 계산
  static double getDynamicBoxSpacing(double screenWidth) {
    return screenWidth > largeScreenThreshold ? 12.0 : 8.0;
  }
  
  /// 화면 높이에 따른 최대 박스 높이 계산
  /// 
  /// [screenHeight] 현재 화면 높이
  /// 반환값: 화면 높이의 80%를 넘지 않는 최대 박스 높이
  static double getMaxBoxHeight(double screenHeight) {
    return screenHeight * maxBoxHeightRatio;
  }
  
  /// 동적 알림 최대 높이 계산
  /// 
  /// [screenHeight] 현재 화면 높이
  /// 반환값: 알림 전체가 차지할 수 있는 최대 높이
  static double getMaxNotificationHeight(double screenHeight) {
    // 상단 여백(상태바) + 하단 여백 고려
    const double systemPadding = 100.0;
    return (screenHeight - systemPadding) * maxBoxHeightRatio;
  }
  
  /// 박스 크기 제약 조건 확인
  /// 
  /// [proposedSize] 제안된 박스 크기
  /// [scaleFactor] 스케일링 팩터
  /// [maxWidth] 최대 허용 너비 (optional)
  /// [screenHeight] 화면 높이 (동적 최대 높이 계산용)
  /// 반환값: 제약 조건을 만족하는 조정된 크기
  static Size constrainBoxSize(Size proposedSize, double scaleFactor, {double? maxWidth, double? screenHeight}) {
    // 스케일링 적용
    final scaledWidth = proposedSize.width * scaleFactor;
    final scaledHeight = proposedSize.height * scaleFactor;
    
    // 초기값 설정
    double constrainedWidth = scaledWidth;
    double constrainedHeight = scaledHeight;
    
    // 동적 최대 높이 계산
    final maxHeight = screenHeight != null ? getMaxBoxHeight(screenHeight) : 500.0;
    
    // 높이 제약 적용
    if (scaledHeight > maxHeight || scaledHeight < minBoxHeight) {
      constrainedHeight = scaledHeight.clamp(minBoxHeight, maxHeight);
      // 비율 유지하면서 너비 조정
      final aspectRatio = proposedSize.width / proposedSize.height;
      constrainedWidth = constrainedHeight * aspectRatio;
    }
    
    // 너비 제약 적용 (maxWidth가 제공된 경우)
    if (maxWidth != null && constrainedWidth > maxWidth) {
      constrainedWidth = maxWidth;
      // 비율 유지하면서 높이 재조정
      final aspectRatio = proposedSize.width / proposedSize.height;
      constrainedHeight = constrainedWidth / aspectRatio;
      
      // 높이가 다시 제약을 벗어났는지 확인
      constrainedHeight = constrainedHeight.clamp(minBoxHeight, maxHeight);
    }
    
    return Size(constrainedWidth, constrainedHeight);
  }
  
  /// 텍스트 크기 계산 (박스 크기에 적응)
  /// 
  /// [boxHeight] 박스 높이
  /// [baseTextSize] 기본 텍스트 크기 (기본값: 12.0)
  /// 반환값: 박스 크기에 맞춰 조정된 텍스트 크기
  static double getAdaptiveTextSize(double boxHeight, {double baseTextSize = defaultTextSize}) {
    // 기준 높이 대비 현재 높이의 비율 계산
    final heightRatio = boxHeight / defaultBoxHeight;
    final adaptedSize = baseTextSize * heightRatio;
    
    // 최소/최대 크기 제한 적용
    return adaptedSize.clamp(minTextSize, maxTextSize);
  }
  
  /// 레이아웃 변환이 필요한지 확인
  /// 
  /// [originalLayout] 원본 레이아웃 타입
  /// [containerWidth] 컨테이너 너비
  /// 반환값: 레이아웃 변환 필요 여부
  static bool shouldConvertLayout(String originalLayout, double containerWidth) {
    // 세로 배치는 공간 절약을 위해 항상 가로 배치로 변환
    if (originalLayout == 'vertical') {
      return true;
    }
    
    // 작은 화면에서는 단일 이미지도 A+빈B 형태로 변환
    if (originalLayout == 'single' && containerWidth < mediumScreenThreshold) {
      return true;
    }
    
    return false;
  }
  
  /// 투표 버튼 크기 계산
  /// 
  /// [boxWidth] 박스 너비
  /// 반환값: 버튼에 적합한 크기
  static Size getVoteButtonSize(double boxWidth) {
    final buttonWidth = (boxWidth * 0.8).clamp(80.0, 120.0); // 박스 너비의 80%, 최소 80px, 최대 120px
    const buttonHeight = 36.0; // 고정 높이
    
    return Size(buttonWidth, buttonHeight);
  }
  
  /// 디버그용 제약 조건 정보 출력
  static void printConstraints(double screenWidth) {
    final scaleFactor = getScaleFactor(screenWidth);
    final notificationWidth = getNotificationWidth(screenWidth);
    final padding = getDynamicPadding(screenWidth);
    final spacing = getDynamicBoxSpacing(screenWidth);
    
    print('[VotingNotificationConstraints] Debug Info:');
    print('  Screen Width: ${screenWidth.toStringAsFixed(1)}px');
    print('  Scale Factor: ${(scaleFactor * 100).toStringAsFixed(0)}%');
    print('  Notification Width: ${notificationWidth.toStringAsFixed(1)}px');
    print('  Dynamic Padding: ${padding.toStringAsFixed(1)}px');
    print('  Box Spacing: ${spacing.toStringAsFixed(1)}px');
    print('  Max Box Height Ratio: ${(maxBoxHeightRatio * 100).toStringAsFixed(0)}%');
    print('  Default Box Height: ${defaultBoxHeight.toStringAsFixed(1)}px');
  }
}