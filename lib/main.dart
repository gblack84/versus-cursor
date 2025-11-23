import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '/core/config/environment_config.dart';
import '/app/config/firebase_config.dart';
import 'services/cache/unified_cache_service.dart';
import 'services/notification/fcm_service.dart';
import '/app/di.dart';
import 'package:get_it/get_it.dart';
import 'core_exports.dart'; // ✅ Phase 3: Includes IPostCreationRepositoryV2
import 'app/app.dart';

/// FCM Background Message Handler
///
/// Must be a top-level function (not inside a class).
/// Handles messages when app is terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (background에서도 필요)
  await initFirebase();

  // TODO: Process notification in background
  // This could update local database, show local notification, etc.
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  // 환경 변수 로드 (Phase 0 보안 수정)
  await EnvironmentConfig.init();

  // 환경 변수 검증
  if (!EnvironmentConfig.validateConfiguration()) {
    // Environment configuration is invalid - check .env file
  }

  // 개발 환경에서만 상태 출력
  EnvironmentConfig.printStatus();

  await initFirebase();

  // Firebase Analytics 초기화 - Production Business Metrics Tracking
  // ✅ Phase 3 Task 1 (2025-11-19): Analytics integration for INFO level logging
  //
  // **Purpose**: Track user behavior and business metrics in Production
  // - User actions: sign_in, create_post, vote_cast, etc.
  // - Content metrics: post_views, media_uploads, chat_messages
  // - System metrics: cache_performance, api_latency, feature_usage
  //
  // **Production Only**: setAnalyticsCollectionEnabled(!kDebugMode)
  // - Development: Analytics disabled (avoid polluting Production data)
  // - Production: Analytics enabled for business insights
  FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  // Firebase Crashlytics 초기화 - Production Error Tracking
  // ✅ Phase 1 (2025-11-18): Crashlytics integration
  //
  // FlutterError.onError: Flutter framework errors (위젯 빌드 에러 등)
  // PlatformDispatcher.instance.onError: Dart runtime errors (미처리 예외)
  //
  // **Important**: Only runs in production (!kDebugMode)
  // Development에서는 console logging으로 처리
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true; // true = handled, prevents app termination
  };

  // FCM Background Message Handler 등록
  // 반드시 Firebase 초기화 이후에 호출해야 함
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // UnifiedCacheService 초기화 - 3-Layer 캐싱
  // DI 설정 전에 초기화해야 함 (profile_di_module에서 instance 접근)
  await UnifiedCacheService.initialize();

  // Initialize Dependency Injection (Firebase-Centric Architecture)
  await setupDependencyInjection();

  // Firestore 오프라인 캐시 활성화 - 앱 성능 대폭 개선
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 무제한 캐시
  );

  // FCMService 초기화 - Push Notifications
  await FCMService().initialize();

  await AppTheme.initialize();

  runApp(
    riverpod.ProviderScope(
      child: const VersusApp(),
    ),
  );

  // 백그라운드 프리로딩 (앱 시작 차단하지 않음)
  _preloadNotifications();
  _preloadPosts();
  _preloadDrafts(); // ✅ Phase 3: Draft preload
}

/// 알림 프리로딩 - 백그라운드에서 최근 알림 캐시에 로드
///
/// Phase 3 Cache Integration: UnifiedCacheService 활용
/// - 500ms 지연 후 실행 (UI 렌더링 완료 대기)
/// - 실패 시 에러 로그만 출력 (앱 시작에 영향 없음)
void _preloadNotifications() {
  Future.delayed(const Duration(milliseconds: 500), () async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) return;

      final repository = getIt<INotificationRepository>();
      await repository.getUserNotifications(currentUserId);

      debugPrint('✅ Notification Preloading: Success');
    } catch (e) {
      debugPrint('⚠️ Notification Preloading: Failed - $e');
    }
  });
}

/// 게시물 프리로딩 - 백그라운드에서 인기 게시물 캐시에 로드
///
/// **Phase 3: Cache Integration**
/// - 700ms 지연 후 실행 (알림 프리로딩 완료 대기)
/// - PostCacheService를 통해 인기 & 트렌딩 게시물 프리로드
/// - 실패 시 에러 로그만 출력 (앱 시작에 영향 없음)
void _preloadPosts() {
  Future.delayed(const Duration(milliseconds: 700), () async {
    try {
      // PostCacheService를 통한 프리로딩
      await UnifiedCacheService.instance.preloadPopularPosts();
      debugPrint('✅ Post Preloading: Success');
    } catch (e) {
      debugPrint('⚠️ Post Preloading: Failed - $e');
    }
  });
}

/// Draft 프리로딩 - 백그라운드에서 사용자 Draft 캐시에 로드
///
/// **Phase 3: Creation Cache Integration**
/// - 900ms 지연 후 실행 (Post 프리로딩 완료 대기)
/// - CreationCacheService를 통해 Draft 및 TargetAudience 프리셋 로드
/// - 실패 시 에러 로그만 출력 (앱 시작에 영향 없음)
///
/// **Benefits**:
/// - Draft 복원 시간: <10ms (Memory Hit)
/// - Create Post 화면 진입 시 즉시 Draft 로드
/// - 타겟 오디언스 자동 완성 준비
void _preloadDrafts() {
  Future.delayed(const Duration(milliseconds: 900), () async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null) {
        debugPrint('⏭️ Draft Preloading: Skipped (User not logged in)');
        return;
      }

      // Get IPostCreationRepositoryV2 from GetIt
      final repository = GetIt.instance<IPostCreationRepositoryV2>();

      // Preload Draft (will cache in L1, L2, L3)
      await repository.getDraftPost(currentUserId);

      // Preload TargetAudience preset (optional)
      await repository.getTargetAudiencePreset(currentUserId);

      debugPrint('✅ Draft Preloading: Success');
    } catch (e) {
      debugPrint('⚠️ Draft Preloading: Failed - $e');
      // Don't block app startup on preload failure
    }
  });
}

// For backward compatibility - MyApp is now in app/app.dart
// This stub remains for compatibility with existing code
@Deprecated('Use VersusApp from app/app.dart instead')
class MyApp extends VersusApp {
  const MyApp({super.key}) : super();
}
