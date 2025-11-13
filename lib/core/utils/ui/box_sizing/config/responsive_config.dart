/// Responsive Design Configuration Constants
///
/// 이 파일은 ResponsiveBreakpoints에서 사용하는 모든 매직 넘버를 정의합니다.
/// Phase 3.2: Magic Numbers → Config 분리 (2025-11-10)
///
/// **설계 원칙**:
/// 1. 기능별 그룹화 (Message Width, Margins, VS Box Heights)
/// 2. 디바이스별 서브그룹화 (Mobile/Tablet/Desktop)
/// 3. 의미 있는 네이밍 (device_function_property 패턴)
/// 4. 단위 명시 (픽셀, 비율 구분)
class ResponsiveConfig {
  // ============================================================================
  // Message Width - getMaxMessageWidth()
  // ============================================================================

  // ===== Width Ratios (Mobile Small & Mobile) =====

  /// 모바일 스몰 디바이스에서 메시지 최대 너비 비율
  ///
  /// 화면 너비 대비 메시지가 차지하는 비율
  /// 사용: `maxWidth = screenWidth * mobileSmallMessageWidthRatio`
  static const double mobileSmallMessageWidthRatio = 0.85; // 85%

  /// 모바일/모바일 라지 디바이스에서 메시지 최대 너비 비율
  ///
  /// 화면 너비 대비 메시지가 차지하는 비율
  /// 사용: `maxWidth = screenWidth * mobileMessageWidthRatio`
  static const double mobileMessageWidthRatio = 0.80; // 80%

  // ===== Absolute Width (Tablet/Desktop) =====

  /// 태블릿 디바이스에서 메시지 최대 너비 (픽셀)
  ///
  /// 태블릿에서는 고정 너비 사용 (500px)
  static const double tabletMessageMaxWidth = 500.0;

  /// 데스크톱 디바이스에서 메시지 최대 너비 (픽셀)
  ///
  /// 데스크톱에서는 고정 너비 사용 (600px)
  static const double desktopMessageMaxWidth = 600.0;

  /// 데스크톱 라지 디바이스에서 메시지 최대 너비 (픽셀)
  ///
  /// 데스크톱 라지에서는 고정 너비 사용 (700px)
  static const double desktopLargeMessageMaxWidth = 700.0;

  // ============================================================================
  // Message Margins - getMessageMargin()
  // ============================================================================

  // ===== Mobile Small & Mobile =====

  /// 모바일 스몰/모바일: 내 메시지 왼쪽 마진 (픽셀)
  ///
  /// 내 메시지를 오른쪽 정렬하기 위한 왼쪽 여백
  static const double mobileMessageMarginMyLeft = 40.0;

  /// 모바일 스몰/모바일: 내 메시지 오른쪽 마진 (픽셀)
  ///
  /// 내 메시지의 오른쪽 여백 (화면 가장자리)
  static const double mobileMessageMarginMyRight = 12.0;

  /// 모바일 스몰/모바일: 상대방 메시지 왼쪽 마진 (픽셀)
  ///
  /// 상대방 메시지의 왼쪽 여백 (화면 가장자리)
  static const double mobileMessageMarginOtherLeft = 12.0;

  /// 모바일 스몰/모바일: 상대방 메시지 오른쪽 마진 (픽셀)
  ///
  /// 상대방 메시지를 왼쪽 정렬하기 위한 오른쪽 여백
  static const double mobileMessageMarginOtherRight = 40.0;

  /// 모바일 스몰/모바일: 메시지 하단 마진 (픽셀)
  ///
  /// 메시지 간 간격
  static const double mobileMessageMarginBottom = 8.0;

  // ===== Mobile Large =====

  /// 모바일 라지: 내 메시지 왼쪽 마진 (픽셀)
  ///
  /// 내 메시지를 오른쪽 정렬하기 위한 왼쪽 여백
  static const double mobileLargeMessageMarginMyLeft = 50.0;

  /// 모바일 라지: 내 메시지 오른쪽 마진 (픽셀)
  ///
  /// 내 메시지의 오른쪽 여백 (화면 가장자리)
  static const double mobileLargeMessageMarginMyRight = 16.0;

  /// 모바일 라지: 상대방 메시지 왼쪽 마진 (픽셀)
  ///
  /// 상대방 메시지의 왼쪽 여백 (화면 가장자리)
  static const double mobileLargeMessageMarginOtherLeft = 16.0;

  /// 모바일 라지: 상대방 메시지 오른쪽 마진 (픽셀)
  ///
  /// 상대방 메시지를 왼쪽 정렬하기 위한 오른쪽 여백
  static const double mobileLargeMessageMarginOtherRight = 50.0;

  /// 모바일 라지: 메시지 하단 마진 (픽셀)
  ///
  /// 메시지 간 간격
  static const double mobileLargeMessageMarginBottom = 8.0;

  // ===== Tablet =====

  /// 태블릿: 내 메시지 왼쪽 마진 (픽셀)
  ///
  /// 내 메시지를 오른쪽 정렬하기 위한 왼쪽 여백
  static const double tabletMessageMarginMyLeft = 100.0;

  /// 태블릿: 내 메시지 오른쪽 마진 (픽셀)
  ///
  /// 내 메시지의 오른쪽 여백 (화면 가장자리)
  static const double tabletMessageMarginMyRight = 20.0;

  /// 태블릿: 상대방 메시지 왼쪽 마진 (픽셀)
  ///
  /// 상대방 메시지의 왼쪽 여백 (화면 가장자리)
  static const double tabletMessageMarginOtherLeft = 20.0;

  /// 태블릿: 상대방 메시지 오른쪽 마진 (픽셀)
  ///
  /// 상대방 메시지를 왼쪽 정렬하기 위한 오른쪽 여백
  static const double tabletMessageMarginOtherRight = 100.0;

  /// 태블릿: 메시지 하단 마진 (픽셀)
  ///
  /// 메시지 간 간격
  static const double tabletMessageMarginBottom = 12.0;

  // ===== Desktop & Desktop Large =====

  /// 데스크톱/데스크톱 라지: 내 메시지 왼쪽 마진 (픽셀)
  ///
  /// 내 메시지를 오른쪽 정렬하기 위한 왼쪽 여백
  static const double desktopMessageMarginMyLeft = 150.0;

  /// 데스크톱/데스크톱 라지: 내 메시지 오른쪽 마진 (픽셀)
  ///
  /// 내 메시지의 오른쪽 여백 (화면 가장자리)
  static const double desktopMessageMarginMyRight = 24.0;

  /// 데스크톱/데스크톱 라지: 상대방 메시지 왼쪽 마진 (픽셀)
  ///
  /// 상대방 메시지의 왼쪽 여백 (화면 가장자리)
  static const double desktopMessageMarginOtherLeft = 24.0;

  /// 데스크톱/데스크톱 라지: 상대방 메시지 오른쪽 마진 (픽셀)
  ///
  /// 상대방 메시지를 왼쪽 정렬하기 위한 오른쪽 여백
  static const double desktopMessageMarginOtherRight = 150.0;

  /// 데스크톱/데스크톱 라지: 메시지 하단 마진 (픽셀)
  ///
  /// 메시지 간 간격
  static const double desktopMessageMarginBottom = 12.0;

  // ============================================================================
  // VS Box Heights - Base Image (이미지 포함, 축소 상태)
  // ============================================================================

  /// 모바일 스몰/모바일: 기본 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 기본(축소) 높이
  static const double mobileBaseImageHeight = 200.0;

  /// 모바일 라지: 기본 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 기본(축소) 높이
  static const double mobileLargeBaseImageHeight = 200.0;

  /// 태블릿: 기본 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 기본(축소) 높이
  static const double tabletBaseImageHeight = 240.0;

  /// 데스크톱/데스크톱 라지: 기본 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 기본(축소) 높이
  static const double desktopBaseImageHeight = 280.0;

  // ============================================================================
  // VS Box Heights - Expanded Image (이미지 포함, 확장 상태)
  // ============================================================================

  /// 모바일 스몰/모바일: 확장 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 확장 높이
  static const double mobileExpandedImageHeight = 300.0;

  /// 모바일 라지: 확장 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 확장 높이
  static const double mobileLargeExpandedImageHeight = 300.0;

  /// 태블릿: 확장 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 확장 높이
  static const double tabletExpandedImageHeight = 360.0;

  /// 데스크톱/데스크톱 라지: 확장 이미지 박스 높이 (픽셀)
  ///
  /// 이미지가 있는 VS 박스의 확장 높이
  static const double desktopExpandedImageHeight = 420.0;

  // ============================================================================
  // VS Box Heights - Base Text (텍스트 전용, 축소 상태)
  // ============================================================================

  /// 모바일 스몰/모바일: 기본 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 기본(축소) 높이
  /// 이미지 높이의 70% (200 * 0.7 = 140)
  static const double mobileBaseTextHeight = 140.0;

  /// 모바일 라지: 기본 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 기본(축소) 높이
  /// 이미지 높이의 70% (200 * 0.7 = 140)
  static const double mobileLargeBaseTextHeight = 140.0;

  /// 태블릿: 기본 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 기본(축소) 높이
  /// 이미지 높이의 70% (240 * 0.7 = 168)
  static const double tabletBaseTextHeight = 168.0;

  /// 데스크톱/데스크톱 라지: 기본 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 기본(축소) 높이
  /// 이미지 높이의 70% (280 * 0.7 = 196)
  static const double desktopBaseTextHeight = 196.0;

  // ============================================================================
  // VS Box Heights - Expanded Text (텍스트 전용, 확장 상태)
  // ============================================================================

  /// 모바일 스몰/모바일: 확장 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 확장 높이
  /// 확장 이미지 높이의 70% (300 * 0.7 = 210)
  static const double mobileExpandedTextHeight = 210.0;

  /// 모바일 라지: 확장 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 확장 높이
  /// 확장 이미지 높이의 70% (300 * 0.7 = 210)
  static const double mobileLargeExpandedTextHeight = 210.0;

  /// 태블릿: 확장 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 확장 높이
  /// 확장 이미지 높이의 70% (360 * 0.7 = 252)
  static const double tabletExpandedTextHeight = 252.0;

  /// 데스크톱/데스크톱 라지: 확장 텍스트 박스 높이 (픽셀)
  ///
  /// 텍스트만 있는 VS 박스의 확장 높이
  /// 확장 이미지 높이의 70% (420 * 0.7 = 294)
  static const double desktopExpandedTextHeight = 294.0;

  // ============================================================================
  // Helper Constants
  // ============================================================================

  /// 텍스트 전용 박스 높이 비율
  ///
  /// 텍스트만 있는 박스는 이미지 박스의 70% 높이 사용
  /// 사용: `textHeight = imageHeight * textToImageHeightRatio`
  static const double textToImageHeightRatio = 0.7; // 70%
}
