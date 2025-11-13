/// Box Calculator Configuration Constants
///
/// 이 파일은 UnifiedBoxCalculator에서 사용하는 모든 매직 넘버를 정의합니다.
/// Phase 3.1: Magic Numbers → Config 분리 (2025-11-10)
///
/// **설계 원칙**:
/// 1. 컴포넌트별 그룹화 (Message Card, Notification Dialog, General)
/// 2. 의미 있는 네이밍 (용도와 컨텍스트가 명확)
/// 3. 단위 명시 (픽셀, 비율 구분)
/// 4. 문서화 (각 상수의 사용 목적 설명)
class BoxCalculatorConfig {
  // ============================================================================
  // Message Card (Chat Bubble) - calculateForMessageCard()
  // ============================================================================

  // ===== Width Ratios =====

  /// 메시지 카드 단일 이미지 박스 너비 비율
  ///
  /// 채팅 버블 내부에서 단일 이미지가 차지하는 너비 비율
  /// 사용: `boxWidth = bubbleWidth * messageCardSingleWidthRatio`
  static const double messageCardSingleWidthRatio = 0.8; // 80%

  /// 메시지 카드 가로 배치 박스 너비 비율
  ///
  /// 간격(spacing)을 제외한 후 각 박스가 차지하는 너비 비율
  /// 사용: `boxWidth = (bubbleWidth - spacing) * messageCardHorizontalWidthRatio`
  static const double messageCardHorizontalWidthRatio = 0.495; // 49.5%

  /// 메시지 카드 세로 배치 박스 너비 비율
  ///
  /// 세로 배치에서 박스가 차지하는 너비 비율 (좌우 여백 5%)
  /// 사용: `boxWidth = bubbleWidth * messageCardVerticalWidthRatio`
  static const double messageCardVerticalWidthRatio = 0.95; // 95%

  // ===== Spacing =====

  /// 메시지 카드 박스 간 간격 (픽셀)
  ///
  /// 가로 배치에서 두 박스 사이 간격, 세로 배치에서 위아래 간격
  /// 사용: `spacing = messageCardSpacing`
  static const double messageCardSpacing = 8.0;

  // ===== Max/Min Heights - Single Layout =====

  /// 메시지 카드 단일 이미지 최대 높이 (픽셀)
  ///
  /// 단일 이미지 레이아웃에서 박스의 최대 높이
  /// 채팅 버블 내부 공간을 고려하여 400px로 제한
  static const double messageCardSingleMaxHeight = 400.0;

  /// 메시지 카드 단일 이미지 최소 높이 (픽셀)
  ///
  /// 단일 이미지의 최소 높이 (자연스러운 크기 유지)
  /// 100px 미만은 너무 작아 보이므로 최소 보장
  static const double messageCardSingleMinHeight = 100.0;

  // ===== Max/Min Heights - Horizontal Layout =====

  /// 메시지 카드 가로 배치 최대 높이 (픽셀)
  ///
  /// 가로 배치에서 각 개별 박스의 최대 높이
  /// 400px로 제한하여 화면에 적절히 표시
  static const double messageCardHorizontalMaxHeight = 400.0;

  /// 메시지 카드 가로 배치 최소 높이 (픽셀)
  ///
  /// 가로 배치에서 각 박스의 최소 높이
  /// 200px 미만은 가독성이 떨어짐
  static const double messageCardHorizontalMinHeight = 200.0;

  // ===== Max/Min Heights - Vertical Layout =====

  /// 메시지 카드 세로 배치 전체 최대 높이 (픽셀)
  ///
  /// 세로 배치에서 두 박스 + 간격을 포함한 전체 최대 높이
  /// 사용: `maxHeight = (messageCardVerticalTotalMaxHeight - spacing) / 2`
  /// 결과: 각 박스는 171px (= (350 - 8) / 2)
  static const double messageCardVerticalTotalMaxHeight = 350.0;

  /// 메시지 카드 세로 배치 개별 박스 최소 높이 (두 박스) (픽셀)
  ///
  /// 세로 배치에서 두 박스가 모두 있을 때 각 박스의 최소 높이
  /// 100px 미만은 너무 작아 보임
  static const double messageCardVerticalMinHeightTwoBoxes = 100.0;

  /// 메시지 카드 세로 배치 단일 박스 최대 높이 (픽셀)
  ///
  /// 세로 배치에서 박스가 하나만 있을 때 최대 높이
  /// 전체 공간을 활용 가능
  static const double messageCardVerticalMaxHeightSingleBox = 350.0;

  /// 메시지 카드 세로 배치 단일 박스 최소 높이 (픽셀)
  ///
  /// 세로 배치에서 박스가 하나만 있을 때 최소 높이
  static const double messageCardVerticalMinHeightSingleBox = 200.0;

  // ===== Aspect Ratio =====

  /// 메시지 카드 기본 Aspect Ratio
  ///
  /// aspectRatio 정보가 없을 때 사용하는 기본 비율
  /// 사용: `height = boxWidth / messageCardDefaultAspectRatio`
  /// 1.5 비율 = 가로가 세로의 1.5배 (3:2 비율)
  static const double messageCardDefaultAspectRatio = 1.5;

  // ============================================================================
  // Notification Dialog - calculateForNotificationDialog()
  // ============================================================================

  // ===== Width Ratios =====

  /// 알림 다이얼로그 단일 이미지 박스 너비 비율
  ///
  /// 다이얼로그 내부 공간을 최대한 활용 (95%)
  /// 사용: `boxWidth = dialogWidth * notificationDialogSingleWidthRatio`
  static const double notificationDialogSingleWidthRatio = 0.95; // 95%

  /// 알림 다이얼로그 세로 배치 박스 너비 비율
  ///
  /// 세로 배치에서 박스가 차지하는 너비 비율
  /// 사용: `boxWidth = dialogWidth * notificationDialogVerticalWidthRatio`
  static const double notificationDialogVerticalWidthRatio = 0.95; // 95%

  // ===== Spacing & Padding =====

  /// 알림 다이얼로그 박스 간 간격 (픽셀)
  ///
  /// 가로/세로 배치에서 박스 사이 간격
  static const double notificationDialogSpacing = 8.0;

  /// 알림 다이얼로그 가로 배치 좌우 패딩 (픽셀)
  ///
  /// 가로 배치에서 양쪽 여백 (각 8px씩 총 16px)
  /// 사용: `availableWidth = dialogWidth - spacing - notificationDialogHorizontalPadding`
  static const double notificationDialogHorizontalPadding = 16.0;

  // ===== Max/Min Heights - Single Layout =====

  /// 알림 다이얼로그 단일 이미지 최대 높이 (픽셀)
  ///
  /// 단일 이미지에서 박스의 최대 높이
  /// 다이얼로그 공간이 넓으므로 500px까지 허용
  static const double notificationDialogSingleMaxHeight = 500.0;

  /// 알림 다이얼로그 단일 이미지 최소 높이 (픽셀)
  ///
  /// 단일 이미지의 최소 높이
  static const double notificationDialogSingleMinHeight = 150.0;

  // ===== Max/Min Heights - Horizontal Layout =====

  /// 알림 다이얼로그 가로 배치 최대 높이 (픽셀)
  ///
  /// 가로 배치에서 각 개별 박스의 최대 높이
  static const double notificationDialogHorizontalMaxHeight = 400.0;

  /// 알림 다이얼로그 가로 배치 최소 높이 (픽셀)
  ///
  /// 가로 배치에서 각 박스의 최소 높이
  static const double notificationDialogHorizontalMinHeight = 150.0;

  // ===== Max/Min Heights - Vertical Layout =====

  /// 알림 다이얼로그 세로 배치 전체 최대 높이 (픽셀)
  ///
  /// 세로 배치에서 두 박스 + 간격을 포함한 전체 최대 높이
  /// 사용: `maxHeight = (notificationDialogVerticalTotalMaxHeight - spacing) / 2`
  /// 결과: 각 박스는 171px (= (350 - 8) / 2)
  static const double notificationDialogVerticalTotalMaxHeight = 350.0;

  /// 알림 다이얼로그 세로 배치 개별 박스 최소 높이 (두 박스) (픽셀)
  ///
  /// 세로 배치에서 두 박스가 모두 있을 때 각 박스의 최소 높이
  static const double notificationDialogVerticalMinHeightTwoBoxes = 100.0;

  /// 알림 다이얼로그 세로 배치 단일 박스 최대 높이 (픽셀)
  ///
  /// 세로 배치에서 박스가 하나만 있을 때 최대 높이
  static const double notificationDialogVerticalMaxHeightSingleBox = 350.0;

  /// 알림 다이얼로그 세로 배치 단일 박스 최소 높이 (픽셀)
  ///
  /// 세로 배치에서 박스가 하나만 있을 때 최소 높이
  static const double notificationDialogVerticalMinHeightSingleBox = 150.0;

  // ===== Aspect Ratio =====

  /// 알림 다이얼로그 기본 Aspect Ratio
  ///
  /// aspectRatio 정보가 없을 때 사용하는 기본 비율
  /// 사용: `height = boxWidth / notificationDialogDefaultAspectRatio`
  /// 1.5 비율 = 가로가 세로의 1.5배 (3:2 비율)
  static const double notificationDialogDefaultAspectRatio = 1.5;

  // ============================================================================
  // General Configuration - calculate()
  // ============================================================================

  /// 세로 배치에서 컨테이너 높이 사용 비율
  ///
  /// 세로 배치에서 전체 높이가 컨테이너를 초과할 때 스케일링 기준
  /// 사용: `maxAvailableHeight = containerHeight * containerHeightUsageRatio`
  /// 88% 사용하여 상하 여백 확보 (각 6%)
  static const double containerHeightUsageRatio = 0.88; // 88%

  // ============================================================================
  // Question Container (InPutPostImageWidget) - calculate()
  // ============================================================================

  /// 질문 작성 가로 배치 최대 높이 (픽셀)
  ///
  /// 질문 작성 페이지에서 가로 배치 시 박스의 최대 높이
  static const double questionContainerHorizontalMaxHeight = 500.0;

  /// 질문 작성 가로 배치 최소 높이 (픽셀)
  ///
  /// 질문 작성 페이지에서 가로 배치 시 박스의 최소 높이
  static const double questionContainerHorizontalMinHeight = 150.0;

  /// 질문 작성 세로 배치 최대 높이 (픽셀)
  ///
  /// 질문 작성 페이지에서 세로 배치 시 박스의 최대 높이
  static const double questionContainerVerticalMaxHeight = 400.0;

  /// 질문 작성 세로 배치 최소 높이 (픽셀)
  ///
  /// 질문 작성 페이지에서 세로 배치 시 박스의 최소 높이
  static const double questionContainerVerticalMinHeight = 120.0;

  /// 질문 작성 단일 이미지 최대 높이 (픽셀)
  ///
  /// 질문 작성 페이지에서 단일 이미지 시 박스의 최대 높이
  /// 단일 이미지는 더 큰 공간 허용
  static const double questionContainerSingleMaxHeight = 600.0;

  /// 질문 작성 페이지 기본 너비 사용률
  ///
  /// 질문 작성 페이지에서 컨테이너 너비를 100% 사용
  static const double questionContainerWidthRatio = 1.0;

  // ============================================================================
  // Common Layout Configuration
  // ============================================================================

  /// 가로 배치 시 박스 간 간격 (픽셀)
  ///
  /// 가로 배치에서 두 박스 사이 간격
  static const double horizontalSpacing = 8.0;

  /// 세로 배치 시 박스 간 간격 (픽셀)
  ///
  /// 세로 배치에서 두 박스 사이 간격
  static const double verticalSpacing = 12.0;

  /// 가로 배치 시 박스 너비 비율 (간격 제외 후)
  ///
  /// 가로 배치에서 각 박스가 차지하는 너비 비율
  /// 사용: `boxWidth = (containerWidth - spacing) * horizontalBoxWidthRatio`
  static const double horizontalBoxWidthRatio = 0.495; // 49.5%

  /// 세로 배치 시 박스 너비 비율
  ///
  /// 세로 배치에서 박스가 차지하는 너비 비율
  /// 사용: `boxWidth = containerWidth * verticalBoxWidthRatio`
  static const double verticalBoxWidthRatio = 0.95; // 95%

  /// 단일 이미지 박스 너비 비율
  ///
  /// 단일 이미지에서 박스가 차지하는 너비 비율
  /// 사용: `boxWidth = containerWidth * singleBoxWidthRatio`
  static const double singleBoxWidthRatio = 0.95; // 95%

  /// 기본 박스 높이 (픽셀)
  ///
  /// Aspect Ratio 정보가 없을 때 사용하는 기본 높이
  static const double defaultBoxHeight = 350.0;

  /// 기본 Aspect Ratio
  ///
  /// Aspect Ratio 정보가 없을 때 사용하는 기본 비율
  /// 1.0 = 정사각형
  static const double defaultAspectRatio = 1.0;

  // ============================================================================
  // Container Type Constants
  // ============================================================================

  /// 질문 작성 컨테이너 타입
  static const String containerTypeQuestion = 'question';

  /// 알림 다이얼로그 컨테이너 타입
  static const String containerTypeNotification = 'notification';

  /// 메시지 카드 컨테이너 타입
  static const String containerTypeMessage = 'message';

  // ============================================================================
  // Helper Methods
  // ============================================================================

  /// 컨테이너 타입별 최대 높이 반환
  ///
  /// **사용**:
  /// - Question: 가로 500px / 세로 400px / 단일 600px
  /// - Notification: 화면 높이 기반 비율 (가로 90% / 세로 88%)
  /// - Message: 가로 400px / 세로 350px
  static double getMaxHeight({
    required String containerType,
    required bool isHorizontal,
    bool isSingle = false,
    double? screenHeight,
  }) {
    switch (containerType) {
      case containerTypeQuestion:
        if (isSingle) {
          return questionContainerSingleMaxHeight;
        }
        return isHorizontal
            ? questionContainerHorizontalMaxHeight
            : questionContainerVerticalMaxHeight;

      case containerTypeNotification:
        if (screenHeight == null) {
          throw ArgumentError(
              'screenHeight is required for notification container');
        }
        // Notification은 화면 높이 기반 비율 사용
        return screenHeight *
            (isHorizontal ? 0.9 : 0.88); // 가로 90%, 세로 88%

      case containerTypeMessage:
        return isHorizontal
            ? messageCardHorizontalMaxHeight
            : messageCardVerticalTotalMaxHeight;

      default:
        return defaultBoxHeight;
    }
  }

  /// 컨테이너 타입별 최소 높이 반환
  ///
  /// **사용**:
  /// - Question: 가로 150px / 세로 120px
  /// - Notification: 150px
  /// - Message: 가로 200px / 세로 200px
  static double getMinHeight({
    required String containerType,
    required bool isHorizontal,
    bool isSingle = false,
  }) {
    switch (containerType) {
      case containerTypeQuestion:
        if (isSingle) {
          return questionContainerHorizontalMinHeight;
        }
        return isHorizontal
            ? questionContainerHorizontalMinHeight
            : questionContainerVerticalMinHeight;

      case containerTypeNotification:
        return notificationDialogSingleMinHeight;

      case containerTypeMessage:
        return isHorizontal
            ? messageCardHorizontalMinHeight
            : messageCardVerticalMinHeightSingleBox;

      default:
        return 150.0;
    }
  }

  /// 컨테이너 타입별 너비 사용률 반환
  ///
  /// **사용**:
  /// - Question: 100%
  /// - Notification: 92%
  /// - Message: 95%
  static double getWidthRatio({
    required String containerType,
    required bool isHorizontal,
    required bool isSingle,
  }) {
    if (isSingle) {
      return singleBoxWidthRatio;
    }

    switch (containerType) {
      case containerTypeQuestion:
        return questionContainerWidthRatio;

      case containerTypeNotification:
        return notificationDialogVerticalWidthRatio;

      case containerTypeMessage:
        return messageCardVerticalWidthRatio;

      default:
        return 1.0;
    }
  }

  /// 박스 간격 반환
  ///
  /// **사용**:
  /// - 가로 배치: 8px
  /// - 세로 배치: 12px
  static double getSpacing(bool isHorizontal) {
    return isHorizontal ? horizontalSpacing : verticalSpacing;
  }

  /// 박스 너비 비율 반환
  ///
  /// **사용**:
  /// - 단일: 95%
  /// - 가로 배치: 49.5%
  /// - 세로 배치: 95%
  static double getBoxWidthRatio({
    required bool isHorizontal,
    required bool isSingle,
  }) {
    if (isSingle) {
      return singleBoxWidthRatio;
    }
    return isHorizontal ? horizontalBoxWidthRatio : verticalBoxWidthRatio;
  }
}
