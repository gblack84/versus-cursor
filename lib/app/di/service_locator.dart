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
