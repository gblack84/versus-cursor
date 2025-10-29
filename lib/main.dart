import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '/core/config/environment_config.dart';
import '/core/firebase/firebase_config.dart';
import 'services/cache/unified_cache_service.dart';
import 'services/notification/fcm_service.dart';
import 'features/notifications/data/adapters/notification_service.dart';
import '/app/state/providers/navigation_provider.dart';
import '/features/post/presentation/providers/feed_provider.dart';
import '/app/di.dart';
import 'package:get_it/get_it.dart';
import 'core_exports.dart';
import 'app/app.dart';

/// FCM Background Message Handler
///
/// Must be a top-level function (not inside a class).
/// Handles messages when app is terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase 초기화 (background에서도 필요)
  await initFirebase();

  if (kDebugMode) {
    print('🔔 Background message: ${message.notification?.title}');
    print('📦 Data: ${message.data}');
  }

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
    print(
        '❌ Environment configuration is invalid. Please check your .env file.');
  }

  // 개발 환경에서만 상태 출력
  EnvironmentConfig.printStatus();

  await initFirebase();

  // FCM Background Message Handler 등록
  // 반드시 Firebase 초기화 이후에 호출해야 함
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize Dependency Injection (Firebase-Centric Architecture)
  await setupDependencyInjection();

  // Firestore 오프라인 캐시 활성화 - 앱 성능 대폭 개선
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 무제한 캐시
  );

  // UnifiedCacheService 초기화 - 3-Layer 캐싱
  await UnifiedCacheService.initialize();

  // FCMService 초기화 - Push Notifications
  await FCMService().initialize();

  await AppTheme.initialize();

  final appState = AppState(); // Initialize AppState
  await appState.initializePersistedState();

  runApp(
    riverpod.ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => appState),
          ChangeNotifierProvider(create: (context) => NavigationProvider()),
          ChangeNotifierProvider(create: (context) => GetIt.instance<FeedProvider>()),
          Provider<NotificationService>(
              create: (context) => GetIt.instance<NotificationService>()),
        ],
        child: const VersusApp(),
      ),
    ),
  );
}

// For backward compatibility - MyApp is now in app/app.dart
// This stub remains for compatibility with existing code
@Deprecated('Use VersusApp from app/app.dart instead')
class MyApp extends VersusApp {
  const MyApp({super.key}) : super();
}
