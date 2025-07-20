import 'package:flutter/material.dart';

/// 투표 알림 UI의 크기 제약 조건 및 스케일링 설정
/// 
/// 다양한 화면 크기에서 일관된 사용자 경험을 제공하기 위한
/// 최대/최소 크기 및 스케일링 팩터를 정의합니다.
class VotingNotificationConstraints {
  
  // 투표 알림 전체 크기 제약
  static const double maxNotificationWidth = 400.0;
  static const double minNotificationWidth = 300.0;
  static const double defaultNotificationPadding = 16.0;
  
  // 박스 크기 제약 (기존 180px에서 조정)
  static const double maxBoxHeight = 160.0;      // 투표 알림에서 최대 박스 높이
  static const double minBoxHeight = 80.0;       // 투표 알림에서 최소 박스 높이
  static const double defaultBoxHeight = 140.0;  // 기본 박스 높이
  
  // 박스 간 간격
  static const double boxSpacing = 8.0;         // A/B 박스 간 간격
  static const double verticalSpacing = 12.0;   // 세로 간격
  
  // 화면 크기별 스케일링 팩터
  /// 큰 화면 (>400px): 90% 스케일링
  static const double largeScreenScale = 0.9;
  static const double largeScreenThreshold = 400.0;
  
  /// 중간 화면 (350-400px): 80% 스케일링
  static const double mediumScreenScale = 0.8;
  static const double mediumScreenThreshold = 350.0;
  
  /// 작은 화면 (<350px): 70% 스케일링
  static const double smallScreenScale = 0.7;
  
  // 애니메이션 설정
  static const Duration slideAnimationDuration = Duration(milliseconds: 500);
  static const Duration fadeAnimationDuration = Duration(milliseconds: 300);
  static const double slideOffset = -1.0; // 위에서 아래로 슬라이드
  
  // 알림 자동 사라짐 시간
  static const Duration autoHideDuration = Duration(seconds: 30);
  static const Duration voteCompleteDuration = Duration(seconds: 1);
  
  // 텍스트 크기 제약
  static const double maxTextSize = 16.0;
  static const double minTextSize = 10.0;
  static const double defaultTextSize = 12.0;
  
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
  
  /// 알림 컨테이너 너비 계산
  /// 
  /// [screenWidth] 현재 화면 너비
  /// 반환값: 패딩을 고려한 실제 사용 가능한 너비
  static double getNotificationWidth(double screenWidth) {
    final maxWidth = screenWidth - (defaultNotificationPadding * 2);
    return maxWidth.clamp(minNotificationWidth, maxNotificationWidth);
  }
  
  /// 박스 크기 제약 조건 확인
  /// 
  /// [proposedSize] 제안된 박스 크기
  /// [scaleFactor] 스케일링 팩터
  /// 반환값: 제약 조건을 만족하는 조정된 크기
  static Size constrainBoxSize(Size proposedSize, double scaleFactor) {
    // 스케일링 적용
    final scaledWidth = proposedSize.width * scaleFactor;
    final scaledHeight = proposedSize.height * scaleFactor;
    
    // 높이 제약 적용
    final constrainedHeight = scaledHeight.clamp(minBoxHeight, maxBoxHeight);
    
    // 비율을 유지하면서 너비 조정
    final aspectRatio = proposedSize.width / proposedSize.height;
    final constrainedWidth = constrainedHeight * aspectRatio;
    
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
    
    print('[VotingNotificationConstraints] Debug Info:');
    print('  Screen Width: ${screenWidth.toStringAsFixed(1)}px');
    print('  Scale Factor: ${(scaleFactor * 100).toStringAsFixed(0)}%');
    print('  Notification Width: ${notificationWidth.toStringAsFixed(1)}px');
    print('  Max Box Height: ${maxBoxHeight.toStringAsFixed(1)}px');
    print('  Min Box Height: ${minBoxHeight.toStringAsFixed(1)}px');
  }
}