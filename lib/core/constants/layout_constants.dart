/// 스마트 레이아웃 시스템 - 중앙 집중식 레이아웃 상수 관리
///
/// 모든 컴포넌트에서 사용하는 박스 크기 제한값을 통합 관리합니다.
/// 질문 작성, 알림 다이얼로그, 메시지 카드에서 일관된 크기를 보장합니다.
class LayoutConstants {
  // ============================================================================
  // 질문 작성 페이지 (InPutPostImageWidget)
  // ============================================================================

  /// 가로 배치 시 최대 높이 (픽셀)
  static const double questionHorizontalMaxHeight = 500.0;

  /// 가로 배치 시 최소 높이 (픽셀)
  static const double questionHorizontalMinHeight = 150.0;

  /// 세로 배치 시 최대 높이 (픽셀)
  static const double questionVerticalMaxHeight = 400.0;

  /// 세로 배치 시 최소 높이 (픽셀)
  static const double questionVerticalMinHeight = 120.0;

  /// 단일 이미지 최대 높이 (픽셀)
  static const double questionSingleMaxHeight = 600.0;

  /// 질문 작성 페이지 기본 너비 사용률
  static const double questionWidthRatio = 1.0; // 100% 사용

  // ============================================================================
  // 투표 알림 다이얼로그 (VotingNotificationDialog)
  // ============================================================================

  /// 알림 다이얼로그 최대 높이 비율 (화면 대비)
  static const double notificationMaxHeightRatio = 0.8; // 화면의 80%

  /// 알림 다이얼로그 가로 배치 높이 비율
  static const double notificationHorizontalHeightRatio = 0.9; // 화면의 90%

  /// 알림 다이얼로그 세로 배치 높이 비율
  static const double notificationVerticalHeightRatio = 0.88; // 화면의 88%

  /// 알림 다이얼로그 너비 비율 (화면 대비)
  static const double notificationWidthRatio = 0.92; // 화면의 92%

  /// 알림 다이얼로그 최대 너비 (픽셀)
  static const double notificationMaxWidth = 500.0;

  /// 알림 다이얼로그 최소 너비 (픽셀)
  static const double notificationMinWidth = 320.0;

  /// 알림 다이얼로그 최소 박스 높이 (픽셀)
  static const double notificationMinBoxHeight = 150.0;

  // ============================================================================
  // 메시지 카드 (VoteCardMessage)
  // ============================================================================

  /// 메시지 카드 가로 배치 최대 높이 (픽셀)
  static const double messageHorizontalMaxHeight = 400.0;

  /// 메시지 카드 가로 배치 최소 높이 (픽셀)
  static const double messageHorizontalMinHeight = 200.0;

  /// 메시지 카드 세로 배치 최대 높이 (픽셀)
  static const double messageVerticalMaxHeight = 350.0;

  /// 메시지 카드 세로 배치 최소 높이 (픽셀)
  static const double messageVerticalMinHeight = 200.0;

  /// 메시지 카드 기본 너비 사용률
  static const double messageWidthRatio = 0.95; // 95% 사용

  // ============================================================================
  // 공통 레이아웃 설정
  // ============================================================================

  /// 가로 배치 시 박스 간 간격 (픽셀)
  static const double horizontalSpacing = 8.0;

  /// 세로 배치 시 박스 간 간격 (픽셀)
  static const double verticalSpacing = 12.0;

  /// 가로 배치 시 박스 너비 비율 (간격 제외 후)
  static const double horizontalBoxWidthRatio = 0.495; // 각 49.5%

  /// 세로 배치 시 박스 너비 비율
  static const double verticalBoxWidthRatio = 0.95; // 95%

  /// 단일 이미지 박스 너비 비율
  static const double singleBoxWidthRatio = 0.95; // 95%

  /// 기본 박스 높이 (비율 정보가 없을 때)
  static const double defaultBoxHeight = 350.0;

  /// 기본 aspect ratio (정사각형)
  static const double defaultAspectRatio = 1.0;

  // ============================================================================
  // 컨테이너 타입 열거형
  // ============================================================================

  /// 컨테이너 타입을 구분하기 위한 열거형
  static const String containerTypeQuestion = 'question';
  static const String containerTypeNotification = 'notification';
  static const String containerTypeMessage = 'message';

  // ============================================================================
  // 헬퍼 메서드
  // ============================================================================

  /// 컨테이너 타입별 최대 높이 반환
  static double getMaxHeight({
    required String containerType,
    required bool isHorizontal,
    bool isSingle = false,
    double? screenHeight,
  }) {
    switch (containerType) {
      case containerTypeQuestion:
        // 단일 이미지는 600px까지 허용
        if (isSingle) {
          return questionSingleMaxHeight;
        }
        return isHorizontal
            ? questionHorizontalMaxHeight
            : questionVerticalMaxHeight;

      case containerTypeNotification:
        if (screenHeight == null) {
          throw ArgumentError(
              'screenHeight is required for notification container');
        }
        return screenHeight *
            (isHorizontal
                ? notificationHorizontalHeightRatio
                : notificationVerticalHeightRatio);

      case containerTypeMessage:
        return isHorizontal
            ? messageHorizontalMaxHeight
            : messageVerticalMaxHeight;

      default:
        return defaultBoxHeight;
    }
  }

  /// 컨테이너 타입별 최소 높이 반환
  static double getMinHeight({
    required String containerType,
    required bool isHorizontal,
    bool isSingle = false,
  }) {
    switch (containerType) {
      case containerTypeQuestion:
        // 단일 이미지는 가로 배치와 같은 최소값 사용 (150px)
        if (isSingle) {
          return questionHorizontalMinHeight;
        }
        return isHorizontal
            ? questionHorizontalMinHeight
            : questionVerticalMinHeight;

      case containerTypeNotification:
        return notificationMinBoxHeight;

      case containerTypeMessage:
        return isHorizontal
            ? messageHorizontalMinHeight
            : messageVerticalMinHeight;

      default:
        return 150.0; // 기본 최소 높이
    }
  }

  /// 컨테이너 타입별 너비 사용률 반환
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
        return questionWidthRatio;

      case containerTypeNotification:
        return notificationWidthRatio;

      case containerTypeMessage:
        return messageWidthRatio;

      default:
        return 1.0;
    }
  }

  /// 박스 간격 반환
  static double getSpacing(bool isHorizontal) {
    return isHorizontal ? horizontalSpacing : verticalSpacing;
  }

  /// 박스 너비 비율 반환
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
