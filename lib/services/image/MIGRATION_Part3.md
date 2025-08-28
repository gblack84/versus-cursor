# 🔄 Image Service 마이그레이션 계획 Part 3

> Image Service의 Clean Architecture 적용 및 고도화  
> 작성일: 2025-08-28 | 예상 기간: 2주

## 📌 Executive Summary

**현재 상황**: 261줄의 단일 서비스로 기본적인 이미지 캐싱만 구현  
**목표**: Services Layer 내에서 Clean Architecture 적용한 이미지 최적화 시스템 구축  
**방법**: 단계적 리팩토링, 레이어 분리, 네트워크 최적화

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/services/image/
└── unified_image_cache_service.dart  # 261줄 - 단일 서비스 파일
```

### After (목표)
```
lib/services/image/                        # 전역 이미지 캐싱 서비스
├── domain/                                # 도메인 레이어 (비즈니스 로직)
│   ├── entities/
│   │   ├── image_cache_entity.dart
│   │   ├── cache_policy.dart
│   │   ├── cache_statistics.dart
│   │   └── media_metadata.dart
│   ├── repositories/
│   │   └── image_cache_repository.dart
│   └── usecases/
│       ├── preload_images.dart
│       ├── calculate_cache_size.dart
│       ├── clear_cache.dart
│       └── get_cache_stats.dart
├── data/                                  # 데이터 레이어 (구현)
│   ├── models/
│   │   ├── image_cache_model.dart
│   │   └── cache_config_model.dart
│   ├── datasources/
│   │   ├── network_image_source.dart
│   │   ├── local_cache_source.dart
│   │   └── memory_cache_source.dart
│   ├── repositories/
│   │   └── image_cache_repository_impl.dart
│   └── services/
│       ├── image_optimization_service.dart
│       ├── cache_manager_service.dart
│       ├── preload_strategy_service.dart
│       └── network_aware_service.dart
├── presentation/                          # 프레젠테이션 레이어 (UI)
│   ├── providers/
│   │   └── image_cache_provider.dart
│   └── widgets/
│       ├── optimized_image.dart
│       ├── preloaded_image.dart
│       └── progressive_image.dart
├── utils/                                 # 유틸리티 함수
│   ├── image_size_calculator.dart
│   ├── cache_key_generator.dart
│   └── memory_estimator.dart
├── constants/                             # 상수 정의
│   ├── cache_constants.dart
│   └── image_formats.dart
└── unified_image_cache_service.dart      # (레거시 - 점진적 제거)
```

### 아키텍처 원칙
- **Services Layer 유지**: 전역 서비스는 `/lib/services/`에 위치
- **Clean Architecture 적용**: 단일 파일을 3개 레이어로 분리
- **점진적 마이그레이션**: 기존 코드를 유지하며 단계적 리팩토링
- **의존성 규칙 준수**: Features → Services 의존성 허용

## 📊 현재 문제점 분석

### 1. 아키텍처 문제 심각도: 🔴 높음
```dart
// 현재: 모든 로직이 하나의 서비스에 집중
class UnifiedImageCacheService {
  // 캐시 계산 + 프리로드 + 관리 모두 한 곳에
  static int calculateMemCacheWidth() { }
  Future<void> preloadImages() { }
  void clearOldCache() { }
}
```

**영향 분석**:
- 단일 책임 원칙 위반
- 테스트 어려움
- 확장성 제한

### 2. 네트워크 최적화 부재 심각도: 🔴 높음
```dart
// 현재: 네트워크 상태 무시
await preloadImages(context, urls);  // WiFi/Cellular 구분 없음
```

**영향 분석**:
- 모바일 데이터 과소비
- 느린 네트워크에서 성능 저하
- 사용자 경험 악화

### 3. 캐시 정책 단순 심각도: 🟡 중간
```dart
// 현재: 단순 LRU만 사용
void clearOldCache({int keepRecentCount = 100}) {
  // 오래된 것부터 삭제만
}
```

**영향 분석**:
- 중요 이미지 손실 가능
- 효율적인 메모리 관리 불가
- 우선순위 미지원

### 4. 테스트 부재 심각도: 🔴 높음
```
테스트 커버리지: 0%
통합 테스트: 없음
성능 테스트: 없음
```

## 📅 단계별 마이그레이션 계획

### Phase 1: Domain Layer 구축 (Day 1-3)

#### Day 1: Entities & Value Objects
```dart
// lib/services/image/domain/entities/image_cache_entity.dart
class ImageCacheEntity {
  final String url;
  final String cacheKey;
  final int width;
  final int height;
  final DateTime cachedAt;
  final CachePriority priority;
  final int accessCount;
  
  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
  int get memorySize => width * height * 4; // RGBA bytes
}

// lib/services/image/domain/entities/cache_policy.dart
enum CachePriority { low, normal, high, fixed }

class CachePolicy {
  final Duration ttl;
  final int maxMemorySize;
  final int maxDiskSize;
  final NetworkStrategy networkStrategy;
  final EvictionStrategy evictionStrategy;
}
```

#### Day 2: Repository 인터페이스
```dart
// lib/services/image/domain/repositories/image_cache_repository.dart
abstract class ImageCacheRepository {
  Future<ImageCacheEntity?> getFromCache(String url);
  Future<void> saveToCache(ImageCacheEntity entity);
  Future<void> removeFromCache(String url);
  Future<List<ImageCacheEntity>> getAllCached();
  Stream<CacheStatistics> watchCacheStats();
  Future<void> clearCache({CachePriority? keepPriority});
}
```

#### Day 3: Use Cases
```dart
// lib/services/image/domain/usecases/preload_images.dart
class PreloadImagesUseCase {
  final ImageCacheRepository repository;
  final NetworkAwareService networkService;
  
  PreloadImagesUseCase({
    required this.repository,
    required this.networkService,
  });
  
  Future<void> call(PreloadRequest request) async {
    // 네트워크 상태 확인
    final networkType = await networkService.getCurrentNetwork();
    
    // WiFi에서만 대용량 이미지 프리로드
    if (networkType == NetworkType.cellular && 
        request.priority != CachePriority.high) {
      return;
    }
    
    // 병렬 프리로드 실행
    await Future.wait(
      request.urls.map((url) => _preloadSingle(url)),
    );
  }
}
```

### Phase 2: Data Layer 구현 (Day 4-6)

#### Day 4: 데이터 소스
```dart
// lib/services/image/data/datasources/network_image_source.dart
class NetworkImageSource {
  final Dio dio;
  
  Future<Uint8List> fetchImage(String url) async {
    final response = await dio.get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data;
  }
  
  Future<ImageMetadata> fetchMetadata(String url) async {
    // HEAD 요청으로 메타데이터만 가져오기
  }
}

// lib/services/image/data/datasources/memory_cache_source.dart
class MemoryCacheSource {
  final Map<String, ImageCacheModel> _cache = {};
  final int maxSize = 100 * 1024 * 1024; // 100MB
  int _currentSize = 0;
  
  void add(String key, ImageCacheModel model) {
    if (_currentSize + model.size > maxSize) {
      _evictLRU();
    }
    _cache[key] = model;
    _currentSize += model.size;
  }
}
```

#### Day 5: Repository 구현
```dart
// lib/services/image/data/repositories/image_cache_repository_impl.dart
class ImageCacheRepositoryImpl implements ImageCacheRepository {
  final NetworkImageSource networkSource;
  final MemoryCacheSource memorySource;
  final LocalCacheSource localSource;
  final CacheManagerService cacheManager;
  
  @override
  Future<ImageCacheEntity?> getFromCache(String url) async {
    // 1. Memory Cache 확인
    final memoryCache = memorySource.get(url);
    if (memoryCache != null) return memoryCache.toEntity();
    
    // 2. Local Cache 확인
    final localCache = await localSource.get(url);
    if (localCache != null) {
      memorySource.add(url, localCache);
      return localCache.toEntity();
    }
    
    // 3. Network에서 가져오기
    final networkData = await networkSource.fetchImage(url);
    await _cacheImage(url, networkData);
    
    return ImageCacheEntity(url: url, ...);
  }
}
```

#### Day 6: 서비스 레이어
```dart
// lib/services/image/data/services/network_aware_service.dart
class NetworkAwareService {
  final Connectivity connectivity;
  
  Future<NetworkType> getCurrentNetwork() async {
    final result = await connectivity.checkConnectivity();
    
    switch (result) {
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.mobile:
        return _getMobileNetworkType();
      default:
        return NetworkType.none;
    }
  }
  
  Future<NetworkType> _getMobileNetworkType() async {
    // 3G/4G/5G 구분
    return NetworkType.cellular4G;
  }
}

// lib/services/image/data/services/image_optimization_service.dart
class ImageOptimizationService {
  Future<Uint8List> optimize(
    Uint8List originalImage, {
    required int targetWidth,
    required ImageFormat format,
    int quality = 85,
  }) async {
    // WebP 변환, 리사이징, 압축
    return optimizedImage;
  }
}
```

### Phase 3: Presentation Layer (Day 7-8)

#### Day 7: Provider 구현
```dart
// lib/services/image/presentation/providers/image_cache_provider.dart
class ImageCacheProvider extends ChangeNotifier {
  final PreloadImagesUseCase preloadImages;
  final ClearCacheUseCase clearCache;
  final GetCacheStatsUseCase getCacheStats;
  
  CacheStatistics? _stats;
  bool _isPreloading = false;
  
  Future<void> preloadForScreen(List<String> urls) async {
    _isPreloading = true;
    notifyListeners();
    
    try {
      await preloadImages(PreloadRequest(
        urls: urls,
        priority: CachePriority.normal,
      ));
    } finally {
      _isPreloading = false;
      notifyListeners();
    }
  }
  
  void watchStats() {
    getCacheStats().listen((stats) {
      _stats = stats;
      notifyListeners();
    });
  }
}
```

#### Day 8: Widget 구현
```dart
// lib/services/image/presentation/widgets/optimized_image.dart
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool enableProgressive;
  
  @override
  Widget build(BuildContext context) {
    final cacheProvider = context.read<ImageCacheProvider>();
    final calculatedWidth = _calculateOptimalWidth(context);
    
    return FutureBuilder<ImageCacheEntity?>(
      future: cacheProvider.getImage(imageUrl, width: calculatedWidth),
      builder: (context, snapshot) {
        if (enableProgressive) {
          return ProgressiveImage(
            placeholder: _buildPlaceholder(),
            thumbnail: snapshot.data?.thumbnailUrl,
            image: snapshot.data?.url ?? imageUrl,
          );
        }
        
        return CachedNetworkImage(
          imageUrl: imageUrl,
          memCacheWidth: calculatedWidth,
          fit: fit,
        );
      },
    );
  }
}
```

### Phase 4: 점진적 마이그레이션 (Day 9-10)

#### Day 9: 의존성 업데이트
```dart
// Before (기존 코드)
import 'package:versus_app/services/image/unified_image_cache_service.dart';

UnifiedImageCacheService.instance.preloadImages(urls);

// After (새 구조) - Services 레이어 유지
import 'package:versus_app/services/image/presentation/providers/image_cache_provider.dart';

context.read<ImageCacheProvider>().preloadForScreen(urls);
```

#### Day 10: Feature에서 사용
```dart
// lib/features/chat/presentation/screens/chat_detail.dart
// Features → Services 의존성 (허용됨)
import 'package:versus_app/services/image/presentation/widgets/optimized_image.dart';

class ChatMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: message.imageUrl,
      enableProgressive: true,
      fit: BoxFit.cover,
    );
  }
}
```

### Phase 5: 테스트 구현 (Day 11-12)

#### Day 11: 단위 테스트
```dart
// test/services/image/domain/usecases/preload_images_test.dart
void main() {
  group('PreloadImagesUseCase', () {
    test('WiFi에서 모든 이미지 프리로드', () async {
      // Given
      when(networkService.getCurrentNetwork())
        .thenAnswer((_) => NetworkType.wifi);
      
      // When
      await useCase(request);
      
      // Then
      verify(repository.saveToCache(any)).called(urls.length);
    });
    
    test('Cellular에서 high priority만 프리로드', () async {
      // Given
      when(networkService.getCurrentNetwork())
        .thenAnswer((_) => NetworkType.cellular);
      
      // When
      await useCase(lowPriorityRequest);
      
      // Then
      verifyNever(repository.saveToCache(any));
    });
  });
}
```

#### Day 12: 통합 테스트
```dart
// test/services/image/integration/cache_flow_test.dart
void main() {
  testWidgets('이미지 캐싱 전체 플로우', (tester) async {
    // 1. 네트워크에서 이미지 가져오기
    // 2. 메모리 캐시 확인
    // 3. 로컬 캐시 확인
    // 4. 캐시 정리 동작 확인
  });
}
```

### Phase 6: 최적화 & 모니터링 (Day 13-14)

#### Day 13: 성능 최적화
```dart
// lib/services/image/data/services/preload_strategy_service.dart
class PreloadStrategyService {
  Future<PreloadStrategy> determineStrategy(
    BuildContext context,
    List<String> urls,
  ) async {
    final screenSize = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final network = await networkService.getCurrentNetwork();
    
    return PreloadStrategy(
      batchSize: _calculateBatchSize(network),
      targetWidth: _calculateTargetWidth(screenSize, pixelRatio),
      format: _selectFormat(network),
      priority: _determinePriority(context),
    );
  }
}
```

#### Day 14: 모니터링 & 분석
```dart
// lib/services/image/data/services/cache_analytics_service.dart
class CacheAnalyticsService {
  void trackCacheHit(String url) {
    analytics.logEvent('cache_hit', parameters: {
      'url': url,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  void trackCacheMiss(String url, Duration loadTime) {
    analytics.logEvent('cache_miss', parameters: {
      'url': url,
      'load_time_ms': loadTime.inMilliseconds,
    });
  }
}
```

## 🎯 기대 효과

### 성능 개선
- **이미지 로딩**: 2-3초 → 100-200ms (캐시 히트 시)
- **메모리 사용**: 30% 감소 (효율적인 캐시 정책)
- **네트워크 사용**: 50% 감소 (네트워크 인식 프리로드)
- **배터리 소모**: 20% 감소 (불필요한 다운로드 제거)

### 코드 품질
- **테스트 커버리지**: 0% → 90%
- **유지보수성**: 단일 파일 → 레이어별 분리
- **확장성**: 새로운 캐시 전략 쉽게 추가
- **재사용성**: Feature에서 쉽게 사용

### 사용자 경험
- **즉시 로딩**: 프리로드된 이미지는 즉시 표시
- **Progressive Loading**: 저화질 → 고화질 점진적 로딩
- **오프라인 지원**: 캐시된 이미지는 오프라인에서도 표시
- **데이터 절약**: WiFi에서만 고화질 프리로드

## ⚠️ 리스크 및 대응 방안

### 리스크 1: 마이그레이션 중 서비스 중단
**대응**: 점진적 마이그레이션, 레거시 코드 유지

### 리스크 2: 메모리 사용량 증가
**대응**: 엄격한 캐시 제한, 모니터링 강화

### 리스크 3: Feature 팀과의 충돌
**대응**: 명확한 API 문서, 단계적 적용

## 📈 성공 지표

### 단기 (2주)
- [ ] Clean Architecture 레이어 분리 완료
- [ ] 테스트 커버리지 80% 달성
- [ ] 네트워크 인식 프리로드 구현
- [ ] 기존 코드와의 호환성 유지

### 중기 (1개월)
- [ ] 이미지 로딩 시간 50% 단축
- [ ] 메모리 사용량 30% 감소
- [ ] 모든 Feature에서 새 API 사용

### 장기 (3개월)
- [ ] WebP 지원으로 대역폭 40% 절약
- [ ] AI 기반 프리로드 예측
- [ ] 비디오 썸네일 지원

## 🚀 다음 단계

1. **Phase 1 시작**: Domain Layer 구축
2. **팀 리뷰**: 아키텍처 검토 및 피드백
3. **점진적 적용**: Chat Feature부터 시작
4. **모니터링**: 성능 지표 추적
5. **확대 적용**: 모든 Feature로 확산

---

*이 문서는 Services Layer 내에서 Clean Architecture를 적용하는 마이그레이션 계획입니다.*  
*Features → Services 의존성은 허용되며, 프로젝트 구조를 준수합니다.*