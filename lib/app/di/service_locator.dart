/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 일부입니다.
/// 신규 시스템은 /app/di.dart의 getIt를 직접 사용합니다.
///
/// 삭제 조건:
/// - 모든 코드에서 sl 대신 getIt 사용으로 변경 완료 시
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';
import 'injection.dart';

/// Service Locator - Global access point for dependency injection
///
/// Provides a convenient way to access registered services throughout the app.
///
/// Usage:
/// ```dart
/// final userRepo = sl<IUserRepository>();
/// ```
final GetIt sl = DIContainer.sl;
