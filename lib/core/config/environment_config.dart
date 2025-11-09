import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 설정 관리 클래스
///
/// 모든 환경 변수에 대한 중앙 집중식 접근점을 제공합니다.
/// 실제 값은 .env 파일에서 로드되며, 코드에는 하드코딩되지 않습니다.
class EnvironmentConfig {
  // Private constructor to prevent instantiation
  EnvironmentConfig._();

  /// 환경 변수 초기화
  /// main.dart에서 앱 시작 시 호출됩니다.
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // ============================================================================
  // Firebase Configuration
  // ============================================================================

  /// Firebase API Key
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';

  /// Firebase Project ID
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';

  /// Firebase Auth Domain
  static String get firebaseAuthDomain =>
      dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';

  /// Firebase Storage Bucket
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';

  /// Firebase App ID
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';

  // ============================================================================
  // External APIs
  // ============================================================================

  /// Perspective API Key for content moderation
  static String get perspectiveApiKey =>
      dotenv.env['PERSPECTIVE_API_KEY'] ?? '';

  /// Algolia App ID
  static String get algoliaAppId => dotenv.env['ALGOLIA_APP_ID'] ?? '';

  /// Algolia API Key
  static String get algoliaApiKey => dotenv.env['ALGOLIA_API_KEY'] ?? '';

  // ============================================================================
  // Default Assets
  // ============================================================================

  // TODO(cleanup): defaultCharacterImageUrl 사용처 확인 및 정리 필요
  // .env.example에 정의되어 있으나, 현재 코드베이스에서 사용되지 않을 가능성 있음
  //
  // 확인 사항:
  // 1. Profile, Creation Feature에서 사용 여부 확인
  // 2. 사용되지 않으면 .env.example, environment_config.dart에서 제거
  // 3. 사용된다면 어떤 Feature에서 사용하는지 문서화
  //
  // 검색 명령: grep -r "defaultCharacterImageUrl" lib/

  /// Default character image URL
  static String get defaultCharacterImageUrl =>
      dotenv.env['DEFAULT_CHARACTER_IMAGE_URL'] ??
      'https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec';

  // ============================================================================
  // Environment Settings
  // ============================================================================

  /// Current environment (development, staging, production)
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  /// Debug mode flag
  static bool get isDebug => dotenv.env['DEBUG'] == 'true';

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  // ============================================================================
  // Validation
  // ============================================================================

  // TODO(config): Algolia, Perspective API 키 검증 추가 필요
  // 현재 Firebase 환경 변수만 검증하고 있으나, 다른 외부 API 키도 검증 필요
  //
  // 검증해야 할 API 키:
  // 1. PERSPECTIVE_API_KEY - 콘텐츠 검열 서비스 (Creation Feature)
  // 2. ALGOLIA_APP_ID, ALGOLIA_API_KEY - 검색 서비스 (Search Feature)
  //
  // 참고: 각 Feature별로 필요한 키가 누락되면 런타임 에러 발생 가능
  // lib/core/config/README.md의 "보안 체크리스트" 섹션 참조

  /// Validate that all required environment variables are set
  static bool validateConfiguration() {
    final requiredVars = [
      'FIREBASE_API_KEY',
      'FIREBASE_PROJECT_ID',
      'FIREBASE_AUTH_DOMAIN',
      'FIREBASE_STORAGE_BUCKET',
    ];

    for (final varName in requiredVars) {
      if (dotenv.env[varName] == null || dotenv.env[varName]!.isEmpty) {
        print('⚠️ Missing required environment variable: $varName');
        return false;
      }
    }

    return true;
  }

  /// Print configuration status (for debugging only, never in production)
  static void printStatus() {
    if (isDevelopment) {
      print('=== Environment Configuration Status ===');
      print('Environment: $environment');
      print('Debug Mode: $isDebug');
      print(
          'Firebase Project: ${firebaseProjectId.isNotEmpty ? '✅ Configured' : '❌ Missing'}');
      print(
          'Perspective API: ${perspectiveApiKey.isNotEmpty ? '✅ Configured' : '❌ Missing'}');
      print('========================================');
    }
  }
}
