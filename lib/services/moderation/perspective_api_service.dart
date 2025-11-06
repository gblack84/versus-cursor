import 'dart:convert';
import 'package:http/http.dart' as http;
import '/core/config/environment_config.dart';

/// Perspective API 분석 결과
class PerspectiveResult {
  final bool isToxic;
  final double toxicityScore;
  final double profanityScore;
  final double threatScore;
  final double insultScore;
  final Map<String, double> allScores;
  final List<ToxicSpan> toxicSpans;

  PerspectiveResult({
    required this.isToxic,
    required this.toxicityScore,
    required this.profanityScore,
    required this.threatScore,
    required this.insultScore,
    required this.allScores,
    required this.toxicSpans,
  });

  factory PerspectiveResult.fromJson(
      Map<String, dynamic> json, String originalText) {
    final attributeScores = json['attributeScores'] as Map<String, dynamic>;

    // 각 속성별 점수 추출
    double toxicity = _getScore(attributeScores, 'TOXICITY');
    double profanity = _getScore(attributeScores, 'PROFANITY');
    double threat = _getScore(attributeScores, 'THREAT');
    double insult = _getScore(attributeScores, 'INSULT');

    Map<String, double> allScores = {
      'TOXICITY': toxicity,
      'PROFANITY': profanity,
      'THREAT': threat,
      'INSULT': insult,
    };

    // 독성 판단 (0.7 이상이면 독성으로 판단)
    bool isToxic =
        toxicity >= 0.7 || profanity >= 0.7 || threat >= 0.7 || insult >= 0.7;

    // 독성 구간 찾기
    List<ToxicSpan> toxicSpans = [];
    if (isToxic) {
      toxicSpans = _findToxicWords(originalText, allScores);
    }

    return PerspectiveResult(
      isToxic: isToxic,
      toxicityScore: toxicity,
      profanityScore: profanity,
      threatScore: threat,
      insultScore: insult,
      allScores: allScores,
      toxicSpans: toxicSpans,
    );
  }

  /// 독성 단어들을 찾아서 위치 정보 반환
  static List<ToxicSpan> _findToxicWords(
      String text, Map<String, double> scores) {
    List<ToxicSpan> spans = [];

    // 일반적인 한국어 욕설/독성 단어 패턴들
    final toxicPatterns = [
      // 욕설
      RegExp(r'(씨발|시발|씨팔|시팔)', caseSensitive: false),
      RegExp(r'(개새끼|개세끼|개쌔끼)', caseSensitive: false),
      RegExp(r'(병신|븅신)', caseSensitive: false),
      RegExp(r'(좆|좇)', caseSensitive: false),
      RegExp(r'(미친놈|미친년)', caseSensitive: false),
      RegExp(r'(지랄)', caseSensitive: false),
      RegExp(r'(꺼져|죽어)', caseSensitive: false),

      // 영어 욕설
      RegExp(r'\b(fuck|shit|damn|bitch|asshole|stupid|idiot)\b',
          caseSensitive: false),
      RegExp(r'\b(die|kill|hate|ugly|disgusting)\b', caseSensitive: false),

      // 위협적 표현
      RegExp(r'(죽이겠다|때려죽이겠다|패죽이겠다)', caseSensitive: false),
      RegExp(r'(칼로찌르겠다|목따겠다)', caseSensitive: false),
    ];

    // 각 패턴에 대해 매칭되는 부분 찾기
    for (final pattern in toxicPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        // 어떤 카테고리에서 높은 점수인지 확인
        double maxScore = 0.0;
        scores.forEach((category, score) {
          if (score > maxScore) maxScore = score;
        });

        spans.add(ToxicSpan(
          start: match.start,
          end: match.end,
          text: match.group(0) ?? '',
          score: maxScore,
        ));
      }
    }

    // 만약 패턴 매칭으로 찾지 못했지만 독성이 감지된 경우, 전체 텍스트를 독성으로 표시
    if (spans.isEmpty && scores.values.any((score) => score >= 0.7)) {
      double maxScore = scores.values.reduce((a, b) => a > b ? a : b);
      spans.add(ToxicSpan(
        start: 0,
        end: text.length,
        text: text,
        score: maxScore,
      ));
    }

    return spans;
  }

  static double _getScore(
      Map<String, dynamic> attributeScores, String attribute) {
    try {
      final attributeData = attributeScores[attribute] as Map<String, dynamic>?;
      if (attributeData == null) return 0.0;

      final summaryScores =
          attributeData['summaryScore'] as Map<String, dynamic>?;
      if (summaryScores == null) return 0.0;

      final value = summaryScores['value'];
      return (value as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      print('점수 파싱 오류 ($attribute): $e');
      return 0.0;
    }
  }
}

/// 독성 텍스트 구간 정보
class ToxicSpan {
  final int start;
  final int end;
  final String text;
  final double score;

  ToxicSpan({
    required this.start,
    required this.end,
    required this.text,
    required this.score,
  });
}

/// Abstract interface for Perspective API Service (Port Pattern)
///
/// **Clean Architecture**: Port (Interface) for text moderation service
/// **Implementation**: PerspectiveApiService (Adapter)
/// **Purpose**: Dependency Inversion Principle - Domain depends on interface, not concrete implementation
abstract class IPerspectiveApiService {
  Future<PerspectiveResult> analyzeText(String text);
  Future<Map<String, PerspectiveResult>> analyzeMultipleTexts(Map<String, String> texts);
  Future<String?> validateText(String? value);
  Future<bool> testConnection();
}

/// Google Perspective API 서비스 (Concrete Implementation)
///
/// **Migration**: Static class → Instance-based class (Phase 2-Step 1)
/// **DI Pattern**: Constructor injection for API key
/// **Clean Architecture**: Adapter implementation of IPerspectiveApiService
class PerspectiveApiService implements IPerspectiveApiService {
  // API Key는 환경 변수에서 로드됩니다 (Phase 0 보안 수정)
  final String apiKey;
  static const String _baseUrl =
      'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

  /// Constructor injection for API key
  PerspectiveApiService({required this.apiKey});

  /// Factory constructor for default setup (uses EnvironmentConfig)
  factory PerspectiveApiService.fromEnvironment() {
    return PerspectiveApiService(
      apiKey: EnvironmentConfig.perspectiveApiKey,
    );
  }

  /// 텍스트 독성 분석
  @override
  Future<PerspectiveResult> analyzeText(String text) async {
    if (text.trim().isEmpty) {
      return PerspectiveResult(
        isToxic: false,
        toxicityScore: 0.0,
        profanityScore: 0.0,
        threatScore: 0.0,
        insultScore: 0.0,
        allScores: {},
        toxicSpans: [],
      );
    }

    try {
      final requestBody = {
        'comment': {'text': text},
        'requestedAttributes': {
          'TOXICITY': {},
          'PROFANITY': {},
          'THREAT': {},
          'INSULT': {},
          'IDENTITY_ATTACK': {},
        },
        'languages': ['ko', 'en'], // 한국어, 영어 지원
        'doNotStore': true, // 구글에 데이터 저장하지 않음
      };

      final response = await http
          .post(
            Uri.parse('$_baseUrl?key=$apiKey'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
        return PerspectiveResult.fromJson(jsonResponse, text);
      } else {
        print('Perspective API 오류: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        throw Exception('Perspective API 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('Perspective API 호출 실패: $e');
      rethrow;
    }
  }

  /// 여러 텍스트 필드를 한 번에 분석
  @override
  Future<Map<String, PerspectiveResult>> analyzeMultipleTexts(
      Map<String, String> texts) async {
    final results = <String, PerspectiveResult>{};

    // 각 텍스트를 순차적으로 분석 (병렬 처리시 API 제한에 걸릴 수 있음)
    for (final entry in texts.entries) {
      final fieldName = entry.key;
      final text = entry.value;

      if (text.trim().isNotEmpty) {
        try {
          final result = await analyzeText(text);
          results[fieldName] = result;

          // API 호출 간격 (Rate Limiting 방지)
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          print('$fieldName 분석 실패: $e');
          // 실패한 경우 안전한 기본값 설정
          results[fieldName] = PerspectiveResult(
            isToxic: false,
            toxicityScore: 0.0,
            profanityScore: 0.0,
            threatScore: 0.0,
            insultScore: 0.0,
            allScores: {},
            toxicSpans: [],
          );
        }
      }
    }

    return results;
  }

  /// 텍스트 검증 (TextFormField용)
  @override
  Future<String?> validateText(String? value) async {
    if (value == null || value.trim().isEmpty) return null;

    try {
      final result = await analyzeText(value);

      if (result.isToxic) {
        String message = '부적절한 내용이 감지되었습니다';

        // 가장 높은 점수의 카테고리 찾기
        String topCategory = '';
        double maxScore = 0.0;

        result.allScores.forEach((category, score) {
          if (score > maxScore) {
            maxScore = score;
            topCategory = category;
          }
        });

        switch (topCategory) {
          case 'PROFANITY':
            message = '욕설이 포함되어 있습니다';
            break;
          case 'THREAT':
            message = '위협적인 내용이 포함되어 있습니다';
            break;
          case 'INSULT':
            message = '모욕적인 내용이 포함되어 있습니다';
            break;
          case 'TOXICITY':
            message = '독성 콘텐츠가 감지되었습니다';
            break;
        }

        return '$message (신뢰도: ${(maxScore * 100).toInt()}%)';
      }

      return null;
    } catch (e) {
      print('Perspective API 검증 오류: $e');
      return '콘텐츠 검증 중 오류가 발생했습니다';
    }
  }

  /// API 상태 테스트
  @override
  Future<bool> testConnection() async {
    try {
      final result = await analyzeText('Hello world');
      return !result.isToxic; // 정상적인 텍스트는 독성이 아니어야 함
    } catch (e) {
      print('Perspective API 연결 테스트 실패: $e');
      return false;
    }
  }
}
