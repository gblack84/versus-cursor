/// Core DI Module
///
/// Core 레이어의 공유 인터페이스들을 DI에 등록
///
/// **Note**: FlutterChatUserAdapter는 싱글톤 패턴으로 직접 접근 가능하므로
/// DI 등록이 필요하지 않습니다. (FlutterChatUserAdapter.instance)
import 'package:get_it/get_it.dart';
import '../../app/di/feature_modules.dart';

class CoreModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Core';

  @override
  void register(GetIt sl) {
    // No shared interfaces to register at this time
    // FlutterChatUserAdapter uses singleton pattern: FlutterChatUserAdapter.instance

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    // No registered services to unregister
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
