/// AI 검열 시스템 설정 및 상수
class ModerationConfig {
  // Perspective API 임계값
  static const double toxicityThreshold = 0.6;
  static const double severeToxicityThreshold = 0.5;
  static const double insultThreshold = 0.5;
  static const double profanityThreshold = 0.5;
  static const double threatThreshold = 0.7;
  static const double identityAttackThreshold = 0.7;
  static const double sexuallyExplicitThreshold = 0.7;

  // Vision API 설정
  static const List<String> inappropriateLabels = [
    'VERY_LIKELY',
    'LIKELY',
  ];

  static const List<String> warningLabels = [
    'POSSIBLE',
  ];

  // Gemini API 설정
  static const String geminiModel = 'gemini-pro';
  static const double geminiTemperature = 0.3;
  static const int geminiMaxTokens = 1000;

  // 재시도 정책
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  // 타임아웃 설정
  static const Duration apiTimeout = Duration(seconds: 30);

  // 캐시 설정
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