/// Core DI Module
/// 
/// Core 레이어의 공유 인터페이스들을 DI에 등록
import 'package:get_it/get_it.dart';
import '../../app/di/feature_modules.dart';
import '../interfaces/user_cache_interface.dart';
import '../../features/profile/data/services/user_cache_service.dart';

class CoreModule implements FeatureModule {
  static bool _isInitialized = false;
  
  @override
  String get name => 'Core';
  
  @override
  void register(GetIt sl) {
    // Register shared interfaces
    if (!sl.isRegistered<IUserCacheService>()) {
      sl.registerLazySingleton<IUserCacheService>(
        () => UserCacheService.instance,
      );
    }
    
    _isInitialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IUserCacheService>()) {
      sl.unregister<IUserCacheService>();
    }
    _isInitialized = false;
  }
  
  @override
  bool get isInitialized => _isInitialized;
}