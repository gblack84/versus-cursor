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
  static String get firebaseApiKey => 
    dotenv.env['FIREBASE_API_KEY'] ?? '';
  
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
  static String get firebaseAppId => 
    dotenv.env['FIREBASE_APP_ID'] ?? '';

  // ============================================================================
  // External APIs
  // ============================================================================
  
  /// Perspective API Key for content moderation
  static String get perspectiveApiKey => 
    dotenv.env['PERSPECTIVE_API_KEY'] ?? '';
  
  /// Algolia App ID
  static String get algoliaAppId => 
    dotenv.env['ALGOLIA_APP_ID'] ?? '';
  
  /// Algolia API Key
  static String get algoliaApiKey => 
    dotenv.env['ALGOLIA_API_KEY'] ?? '';

  // ============================================================================
  // Default Assets
  // ============================================================================
  
  /// Default character image URL
  static String get defaultCharacterImageUrl => 
    dotenv.env['DEFAULT_CHARACTER_IMAGE_URL'] ?? 
    'https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec';

  // ============================================================================
  // Environment Settings
  // ============================================================================
  
  /// Current environment (development, staging, production)
  static String get environment => 
    dotenv.env['ENVIRONMENT'] ?? 'development';
  
  /// Debug mode flag
  static bool get isDebug => 
    dotenv.env['DEBUG'] == 'true';
  
  /// Check if running in production
  static bool get isProduction => 
    environment == 'production';
  
  /// Check if running in development
  static bool get isDevelopment => 
    environment == 'development';

  // ============================================================================
  // Validation
  // ============================================================================
  
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
      print('Firebase Project: ${firebaseProjectId.isNotEmpty ? '✅ Configured' : '❌ Missing'}');
      print('Perspective API: ${perspectiveApiKey.isNotEmpty ? '✅ Configured' : '❌ Missing'}');
      print('========================================');
    }
  }
}