import 'package:http/http.dart' as http;
import 'dart:convert';

/// IP 기반 국가 자동 감지 서비스
///
/// **기능**:
/// - IP Geolocation으로 사용자 국가 자동 감지
/// - 무료 API (ip-api.com) 사용 (45 req/min 제한)
/// - 에러 시 기본값 반환 (US, en)
///
/// **사용 예시**:
/// ```dart
/// final service = CountryDetectionService();
/// final result = await service.detectCountry();
/// print('Detected: ${result.country} (${result.countryCode})');
/// ```
///
/// **API 응답 예시**:
/// ```json
/// {
///   "status": "success",
///   "country": "South Korea",
///   "countryCode": "KR",
///   "region": "11",
///   "regionName": "Seoul",
///   "city": "Seoul",
///   "zip": "",
///   "lat": 37.5665,
///   "lon": 126.9780,
///   "timezone": "Asia/Seoul",
///   "isp": "Korea Telecom",
///   "org": "Korea Telecom",
///   "as": "AS4766 Korea Telecom"
/// }
/// ```
class CountryDetectionService {
  static const String _apiUrl = 'http://ip-api.com/json/';
  static const Duration _timeout = Duration(seconds: 5);

  /// 국가 자동 감지
  ///
  /// **Returns**: [DetectedCountry] - 감지된 국가 정보
  ///
  /// **Fallback**: 네트워크 에러 시 (US, United States, en) 반환
  ///
  /// **제한사항**: 45 requests/minute (ip-api.com 무료 플랜)
  Future<DetectedCountry> detectCountry() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        // API 응답 status 확인
        if (data['status'] == 'success') {
          final countryCode = data['countryCode'] as String?;
          final country = data['country'] as String?;

          if (countryCode != null && country != null) {
            // 국가 코드 기반 언어 자동 제안
            final suggestedLanguage =
                CountryLanguageMapper.getLanguageForCountry(countryCode);

            return DetectedCountry(
              country: country,
              countryCode: countryCode,
              suggestedLanguage: suggestedLanguage,
            );
          }
        }
      }
    } on http.ClientException catch (e) {
      // 네트워크 연결 에러
      print('CountryDetectionService: Network error - $e');
    } on FormatException catch (e) {
      // JSON 파싱 에러
      print('CountryDetectionService: JSON parsing error - $e');
    } catch (e) {
      // 기타 에러 (타임아웃 등)
      print('CountryDetectionService: Unexpected error - $e');
    }

    // Fallback: 기본값 (미국, 영어)
    return DetectedCountry(
      country: 'United States',
      countryCode: 'US',
      suggestedLanguage: 'en',
    );
  }
}

/// 감지된 국가 정보
///
/// **필드**:
/// - [country]: 국가 전체 이름 (예: "South Korea")
/// - [countryCode]: ISO 3166-1 alpha-2 코드 (예: "KR")
/// - [suggestedLanguage]: 국가 기반 언어 제안 (예: "en")
class DetectedCountry {
  final String country; // "South Korea"
  final String countryCode; // "KR"
  final String suggestedLanguage; // "en"

  const DetectedCountry({
    required this.country,
    required this.countryCode,
    required this.suggestedLanguage,
  });

  @override
  String toString() =>
      'DetectedCountry(country: $country, countryCode: $countryCode, suggestedLanguage: $suggestedLanguage)';
}

/// 국가 → 언어 매핑 서비스
///
/// **기능**:
/// - ISO 3166-1 alpha-2 국가 코드 → ISO 639-1 언어 코드 매핑
/// - 주요 국가의 기본 언어 자동 제안
///
/// **예시**:
/// ```dart
/// CountryLanguageMapper.getLanguageForCountry('KR'); // 'en' (현재 앱은 en만 지원)
/// CountryLanguageMapper.getLanguageForCountry('DE'); // 'de'
/// ```
class CountryLanguageMapper {
  /// 국가 코드 → 언어 코드 매핑
  ///
  /// **현재 앱 지원 언어**: en, de
  static const Map<String, String> _countryToLanguage = {
    // 영어권 국가
    'US': 'en', // United States
    'GB': 'en', // United Kingdom
    'AU': 'en', // Australia
    'CA': 'en', // Canada
    'NZ': 'en', // New Zealand
    'IE': 'en', // Ireland
    'ZA': 'en', // South Africa
    'IN': 'en', // India

    // 독일어권 국가
    'DE': 'de', // Germany
    'AT': 'de', // Austria
    'CH': 'de', // Switzerland (다국어 국가이지만 독일어 우선)
    'LI': 'de', // Liechtenstein
    'LU': 'de', // Luxembourg (다국어 국가이지만 독일어 포함)

    // 추후 지원 예정 (현재는 en으로 Fallback)
    'KR': 'en', // South Korea → Korean (미구현, 현재 en)
    'JP': 'en', // Japan → Japanese (미구현, 현재 en)
    'CN': 'en', // China → Chinese (미구현, 현재 en)
    'ES': 'en', // Spain → Spanish (미구현, 현재 en)
    'FR': 'en', // France → French (미구현, 현재 en)
    'IT': 'en', // Italy → Italian (미구현, 현재 en)
    'PT': 'en', // Portugal → Portuguese (미구현, 현재 en)
    'BR': 'en', // Brazil → Portuguese (미구현, 현재 en)
    'RU': 'en', // Russia → Russian (미구현, 현재 en)
    'MX': 'en', // Mexico → Spanish (미구현, 현재 en)
    'AR': 'en', // Argentina → Spanish (미구현, 현재 en)
    'TH': 'en', // Thailand → Thai (미구현, 현재 en)
    'VN': 'en', // Vietnam → Vietnamese (미구현, 현재 en)
    'ID': 'en', // Indonesia → Indonesian (미구현, 현재 en)
    'PH': 'en', // Philippines → Filipino/English (미구현, 현재 en)
    'MY': 'en', // Malaysia → Malay/English (미구현, 현재 en)
    'SG': 'en', // Singapore → English/Chinese (미구현, 현재 en)
  };

  /// 국가 코드로 언어 코드 가져오기
  ///
  /// **Parameters**:
  /// - [countryCode]: ISO 3166-1 alpha-2 국가 코드 (예: "KR", "US")
  ///
  /// **Returns**:
  /// - 지원하는 언어: 해당 언어 코드 반환 (예: "de")
  /// - 미지원 언어: 'en' (기본값) 반환
  static String getLanguageForCountry(String countryCode) {
    return _countryToLanguage[countryCode] ?? 'en'; // Fallback to English
  }

  /// 현재 앱이 지원하는 언어 목록
  ///
  /// **Returns**: ['en', 'de']
  static List<String> get supportedLanguages => ['en', 'de'];

  /// 언어 코드가 현재 지원되는지 확인
  ///
  /// **Parameters**:
  /// - [languageCode]: ISO 639-1 언어 코드 (예: "en", "de", "ko")
  ///
  /// **Returns**: true if supported, false otherwise
  static bool isLanguageSupported(String languageCode) {
    return supportedLanguages.contains(languageCode);
  }

  /// 국가명 → 국가 코드 역방향 매핑 (선택적 기능)
  ///
  /// **참고**: country_code_picker 패키지가 이미 제공하므로 필요시 구현
  static String? getCountryCodeForName(String countryName) {
    // TODO: 필요시 구현
    return null;
  }
}
