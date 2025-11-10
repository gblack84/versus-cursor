/// AI 검열 시스템 설정 및 상수
class ModerationConfig {
  // Perspective API 임계값 (통일: 0.7 = 기본, 0.8 = 심각)
  //
  // ✅ Phase 3: 하드코딩 제거 - 모든 threshold를 0.7로 통일
  // - 기존: toxicity=0.6, insult=0.5, profanity=0.5, threat=0.7 (불일치)
  // - 수정: 모든 값을 0.7로 통일 (하드코딩된 값과 일치)
  // - 추가: severeThreshold=0.8 (input_field_builder.dart용)

  /// Perspective API 일반 독성 콘텐츠 감지 임계값 (0.0 ~ 1.0)
  ///
  /// 사용처: perspective_api_service.dart, input_field_builder.dart
  static const double toxicityThreshold = 0.7;

  /// Perspective API 심각한 독성 콘텐츠 감지 임계값
  ///
  /// 향후 사용 예정: 심각한 유해 콘텐츠(욕설, 위협) 즉시 차단 시
  static const double severeToxicityThreshold = 0.7;

  /// Perspective API 모욕적 표현 감지 임계값
  ///
  /// 사용처: perspective_api_service.dart
  static const double insultThreshold = 0.7;

  /// Perspective API 욕설 감지 임계값
  ///
  /// 사용처: perspective_api_service.dart
  static const double profanityThreshold = 0.7;

  /// Perspective API 위협적 표현 감지 임계값
  ///
  /// 사용처: perspective_api_service.dart
  static const double threatThreshold = 0.7;

  /// Perspective API 혐오 표현/정체성 공격 감지 임계값
  ///
  /// 향후 사용 예정: 인종, 성별, 종교 등에 대한 혐오 표현 감지 시
  static const double identityAttackThreshold = 0.7;

  /// Perspective API 성적으로 노골적인 콘텐츠 감지 임계값
  ///
  /// 향후 사용 예정: 성인 콘텐츠 필터링 기능 추가 시
  static const double sexuallyExplicitThreshold = 0.7;

  /// 심각한 위반 임계값 (즉시 차단 기준)
  ///
  /// 사용처: input_field_builder.dart (0.8 이상 시 즉시 에러 표시)
  static const double severeThreshold = 0.8;

  // Vision API 설정

  /// Cloud Vision API SafeSearch 부적절 콘텐츠 레벨
  ///
  /// 향후 사용 예정: 이미지 안전성 검사 시 VERY_LIKELY, LIKELY 레벨 차단
  /// 참고: Cloud Vision SafeSearch 카테고리 (adult, violence, racy, spoof, medical)
  static const List<String> inappropriateLabels = [
    'VERY_LIKELY',
    'LIKELY',
  ];

  /// Cloud Vision API SafeSearch 경고 콘텐츠 레벨
  ///
  /// 향후 사용 예정: 이미지 안전성 검사 시 POSSIBLE 레벨 경고 표시
  static const List<String> warningLabels = [
    'POSSIBLE',
  ];

  // Gemini API 설정

  /// Gemini AI 모델 이름
  ///
  /// 향후 사용 예정: AI 기반 컨텍스트 검열 시스템 구축 시
  /// 참고: gemini-pro (텍스트), gemini-pro-vision (멀티모달)
  static const String geminiModel = 'gemini-pro';

  /// Gemini AI 생성 온도 (0.0 ~ 1.0, 낮을수록 일관적)
  ///
  /// 향후 사용 예정: AI 검열 결과의 일관성 보장을 위해 낮은 온도 사용
  static const double geminiTemperature = 0.3;

  /// Gemini AI 응답 최대 토큰 수
  ///
  /// 향후 사용 예정: AI 검열 결과 생성 시 토큰 제한
  static const int geminiMaxTokens = 1000;

  // 재시도 정책

  /// API 호출 실패 시 최대 재시도 횟수
  ///
  /// 향후 사용 예정: 네트워크 오류, 타임아웃 발생 시 자동 재시도
  static const int maxRetries = 3;

  /// API 재시도 간격
  ///
  /// 향후 사용 예정: 재시도 전 대기 시간 (exponential backoff 적용 가능)
  static const Duration retryDelay = Duration(seconds: 1);

  // 타임아웃 설정

  /// 모든 Moderation API 호출 타임아웃
  ///
  /// 향후 사용 예정: Perspective, Vision, Gemini API 호출 시 최대 대기 시간
  static const Duration apiTimeout = Duration(seconds: 30);

  // 캐시 설정

  /// Moderation 결과 캐시 유효 기간
  ///
  /// 향후 사용 예정: 동일한 콘텐츠 재검열 방지를 위한 캐시 만료 시간
  static const Duration cacheExpiry = Duration(hours: 1);

  // 한국어 카테고리 매핑
  static const Map<String, String> koreanCategoryNames = {
    'TOXICITY': '유해한 콘텐츠',
    'SEVERE_TOXICITY': '심각한 유해 콘텐츠',
    'IDENTITY_ATTACK': '혐오 표현',
    'INSULT': '모욕적 표현',
    'PROFANITY': '욕설',
    'THREAT': '위협적 표현',
    'SEXUALLY_EXPLICIT': '성적 콘텐츠',
  };

  // Vision API 카테고리 매핑

  /// Cloud Vision API SafeSearch 카테고리 한국어 번역 맵
  ///
  /// 향후 사용 예정: 이미지 안전성 검사 결과를 사용자에게 보여줄 때 한국어 번역
  /// 참고:
  /// - adult: 성인 콘텐츠
  /// - violence: 폭력적 콘텐츠
  /// - racy: 선정적 콘텐츠
  /// - spoof: 조작된 콘텐츠 (딥페이크 등)
  /// - medical: 의료 관련 콘텐츠
  static const Map<String, String> visionCategoryNames = {
    'adult': '성인 콘텐츠',
    'violence': '폭력적 콘텐츠',
    'racy': '선정적 콘텐츠',
    'spoof': '조작된 콘텐츠',
    'medical': '의료 콘텐츠',
  };
}

/// 검열 옵션
class ModerationOptions {
  final bool enablePerspectiveAPI;
  final bool enableVisionAPI;
  final bool enableGeminiAI;
  final bool enableOCR;
  final bool cacheResults;
  final Map<String, double>? customThresholds;

  const ModerationOptions({
    this.enablePerspectiveAPI = true,
    this.enableVisionAPI = true,
    this.enableGeminiAI = true,
    this.enableOCR = true,
    this.cacheResults = false,
    this.customThresholds,
  });

  static const ModerationOptions defaultOptions = ModerationOptions();

  static const ModerationOptions textOnly = ModerationOptions(
    enableVisionAPI: false,
    enableOCR: false,
  );

  static const ModerationOptions imageOnly = ModerationOptions(
    enablePerspectiveAPI: false,
    enableGeminiAI: false,
  );
}
