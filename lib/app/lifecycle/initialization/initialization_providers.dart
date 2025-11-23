import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_initialization_service.dart';

part 'initialization_providers.g.dart';

/// AppInitializationService Provider
///
/// **싱글톤**: 앱 전체에서 하나의 인스턴스만 사용
///
/// **사용처**:
/// - app.dart: 로그인 시 초기화 실행
/// - 테스트: Mock 서비스 주입 가능
@riverpod
AppInitializationService appInitializationService(Ref ref) {
  return AppInitializationService();
}

/// 앱 초기화 실행 Provider
///
/// **FutureProvider**: 비동기 초기화 작업 실행
/// **autoDispose**: 사용 종료 시 자동 정리
///
/// **파라미터**:
/// - `userId`: 프리로드 대상 사용자 ID
///
/// **사용 예시**:
/// ```dart
/// // app.dart에서 사용
/// final service = ref.read(appInitializationServiceProvider);
/// final result = await service.initialize(user.uid);
///
/// if (result.isSuccess) {
///   debugPrint('프리로드 성공: ${result.successCount}개');
/// }
/// ```
@riverpod
Future<InitializationResult> initializeApp(
  Ref ref,
  String userId,
) async {
  final service = ref.read(appInitializationServiceProvider);
  return service.initialize(userId);
}
