import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '/backend/firebase/config/firebase_config.dart';
import 'services/cache/unified_cache_service.dart';
import 'features/notifications/data/services/notification_service.dart';
import '/app/state/providers/navigation_provider.dart';
import 'core_exports.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  await initFirebase();
  
  // Firestore 오프라인 캐시 활성화 - 앱 성능 대폭 개선
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,  // 무제한 캐시
  );
  
  // UnifiedCacheService 초기화 - 3-Layer 캐싱
  await UnifiedCacheService.initialize();

  await AppTheme.initialize();

  final appState = AppState(); // Initialize AppState
  await appState.initializePersistedState();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => appState),
      ChangeNotifierProvider(create: (context) => NavigationProvider()),
      Provider<NotificationService>(create: (context) => NotificationService.instance),
    ],
    child: const VersusApp(),
  ));
}

// For backward compatibility - MyApp is now in app/app.dart
// This stub remains for compatibility with existing code
@Deprecated('Use VersusApp from app/app.dart instead')
class MyApp extends VersusApp {
  const MyApp({super.key}) : super();
}
