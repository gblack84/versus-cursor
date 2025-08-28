# 🧪 Image Service 테스트 가이드

> Image Service의 포괄적인 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 목표 커버리지: 90%

## 📊 테스트 전략 Overview

### 목표 커버리지
- **Unit Tests**: 95% (비즈니스 로직)
- **Widget Tests**: 85% (UI 컴포넌트)
- **Integration Tests**: 80% (전체 플로우)
- **Performance Tests**: 핵심 경로 100%

### 테스트 피라미드
```
        E2E Tests (5%)
       /            \
    Integration (20%)
   /                 \
  Widget Tests (25%)
 /                    \
Unit Tests (50%)
```

## 🎯 단위 테스트 (Unit Tests)

### 1. 캐시 크기 계산 테스트

```dart
// test/services/image/domain/usecases/calculate_cache_size_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/services/image/domain/usecases/calculate_cache_size.dart';

void main() {
  group('CalculateCacheSizeUseCase', () {
    late CalculateCacheSizeUseCase useCase;
    late MockDeviceInfoRepository mockDeviceInfo;
    
    setUp(() {
      mockDeviceInfo = MockDeviceInfoRepository();
      useCase = CalculateCacheSizeUseCase(mockDeviceInfo);
    });
    
    group('calculateMemCacheWidth', () {
      test('최소값 반환', () {
        // Given
        const displaySize = 100.0;
        
        // When
        final result = useCase.calculate(displaySize);
        
        // Then
        expect(result, equals(400)); // MIN_CACHE_WIDTH
      });
      
      test('최대값 제한', () {
        // Given
        const displaySize = 2000.0;
        
        // When
        final result = useCase.calculate(displaySize);
        
        // Then
        expect(result, equals(1600)); // MAX_CACHE_WIDTH
      });
      
      test('정상 범위 계산', () {
        // Given
        const displaySize = 400.0;
        const expected = 800; // 400 * 2.0
        
        // When
        final result = useCase.calculate(displaySize);
        
        // Then
        expect(result, expected);
      });
      
      test('무한값 처리', () {
        // Given
        const displaySize = double.infinity;
        
        // When
        final result = useCase.calculate(displaySize);
        
        // Then
        expect(result, equals(400)); // MIN_CACHE_WIDTH
      });
      
      test('음수값 처리', () {
        // Given
        const displaySize = -100.0;
        
        // When
        final result = useCase.calculate(displaySize);
        
        // Then
        expect(result, equals(400)); // MIN_CACHE_WIDTH
      });
    });
    
    group('픽셀 비율 적용', () {
      test('고해상도 디스플레이', () {
        // Given
        when(mockDeviceInfo.getPixelRatio()).thenReturn(3.0);
        const displaySize = 300.0;
        const expected = 900; // 300 * 3.0
        
        // When
        final result = useCase.calculateWithPixelRatio(displaySize);
        
        // Then
        expect(result, expected);
        verify(mockDeviceInfo.getPixelRatio()).called(1);
      });
    });
  });
}
```

### 2. 이미지 프리로드 테스트

```dart
// test/services/image/domain/usecases/preload_images_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/services/image/domain/usecases/preload_images.dart';

void main() {
  group('PreloadImagesUseCase', () {
    late PreloadImagesUseCase useCase;
    late MockImageCacheRepository mockRepository;
    late MockNetworkAwareService mockNetworkService;
    
    setUp(() {
      mockRepository = MockImageCacheRepository();
      mockNetworkService = MockNetworkAwareService();
      useCase = PreloadImagesUseCase(
        repository: mockRepository,
        networkService: mockNetworkService,
      );
    });
    
    test('WiFi에서 모든 이미지 프리로드', () async {
      // Given
      const urls = ['url1', 'url2', 'url3'];
      when(mockNetworkService.getCurrentNetwork())
        .thenAnswer((_) async => NetworkType.wifi);
      when(mockRepository.saveToCache(any))
        .thenAnswer((_) async => null);
      
      // When
      await useCase(PreloadRequest(
        urls: urls,
        priority: CachePriority.normal,
      ));
      
      // Then
      verify(mockRepository.saveToCache(any)).called(urls.length);
    });
    
    test('Cellular에서 high priority만 프리로드', () async {
      // Given
      const urls = ['url1', 'url2'];
      when(mockNetworkService.getCurrentNetwork())
        .thenAnswer((_) async => NetworkType.cellular);
      
      // When
      await useCase(PreloadRequest(
        urls: urls,
        priority: CachePriority.low,
      ));
      
      // Then
      verifyNever(mockRepository.saveToCache(any));
    });
    
    test('오프라인에서 프리로드 건너뛰기', () async {
      // Given
      when(mockNetworkService.getCurrentNetwork())
        .thenAnswer((_) async => NetworkType.none);
      
      // When
      await useCase(PreloadRequest(
        urls: ['url1'],
        priority: CachePriority.high,
      ));
      
      // Then
      verifyNever(mockRepository.saveToCache(any));
    });
    
    test('병렬 프리로드 실행', () async {
      // Given
      const urls = List.generate(10, (i) => 'url$i');
      when(mockNetworkService.getCurrentNetwork())
        .thenAnswer((_) async => NetworkType.wifi);
      when(mockRepository.saveToCache(any))
        .thenAnswer((_) async => Future.delayed(
          Duration(milliseconds: 100),
        ));
      
      // When
      final stopwatch = Stopwatch()..start();
      await useCase(PreloadRequest(urls: urls));
      stopwatch.stop();
      
      // Then
      // 병렬 실행이므로 100ms 정도만 걸려야 함
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
      verify(mockRepository.saveToCache(any)).called(urls.length);
    });
  });
}
```

### 3. Repository 구현 테스트

```dart
// test/services/image/data/repositories/image_cache_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/services/image/data/repositories/image_cache_repository_impl.dart';

void main() {
  group('ImageCacheRepositoryImpl', () {
    late ImageCacheRepositoryImpl repository;
    late MockNetworkImageSource mockNetworkSource;
    late MockMemoryCacheSource mockMemorySource;
    late MockLocalCacheSource mockLocalSource;
    
    setUp(() {
      mockNetworkSource = MockNetworkImageSource();
      mockMemorySource = MockMemoryCacheSource();
      mockLocalSource = MockLocalCacheSource();
      
      repository = ImageCacheRepositoryImpl(
        networkSource: mockNetworkSource,
        memorySource: mockMemorySource,
        localSource: mockLocalSource,
      );
    });
    
    group('getFromCache', () {
      const testUrl = 'https://example.com/image.jpg';
      final testData = Uint8List.fromList([1, 2, 3, 4]);
      
      test('메모리 캐시에서 찾기', () async {
        // Given
        when(mockMemorySource.get(testUrl))
          .thenReturn(ImageCacheModel(
            url: testUrl,
            data: testData,
          ));
        
        // When
        final result = await repository.getFromCache(testUrl);
        
        // Then
        expect(result, isNotNull);
        expect(result!.url, equals(testUrl));
        verifyNever(mockLocalSource.get(any));
        verifyNever(mockNetworkSource.fetchImage(any));
      });
      
      test('로컬 캐시에서 찾기', () async {
        // Given
        when(mockMemorySource.get(testUrl)).thenReturn(null);
        when(mockLocalSource.get(testUrl))
          .thenAnswer((_) async => ImageCacheModel(
            url: testUrl,
            data: testData,
          ));
        
        // When
        final result = await repository.getFromCache(testUrl);
        
        // Then
        expect(result, isNotNull);
        verify(mockMemorySource.add(testUrl, any)).called(1);
        verifyNever(mockNetworkSource.fetchImage(any));
      });
      
      test('네트워크에서 가져오기', () async {
        // Given
        when(mockMemorySource.get(testUrl)).thenReturn(null);
        when(mockLocalSource.get(testUrl))
          .thenAnswer((_) async => null);
        when(mockNetworkSource.fetchImage(testUrl))
          .thenAnswer((_) async => testData);
        
        // When
        final result = await repository.getFromCache(testUrl);
        
        // Then
        expect(result, isNotNull);
        verify(mockMemorySource.add(testUrl, any)).called(1);
        verify(mockLocalSource.save(testUrl, any)).called(1);
      });
      
      test('네트워크 에러 처리', () async {
        // Given
        when(mockMemorySource.get(testUrl)).thenReturn(null);
        when(mockLocalSource.get(testUrl))
          .thenAnswer((_) async => null);
        when(mockNetworkSource.fetchImage(testUrl))
          .thenThrow(NetworkException('Failed to fetch'));
        
        // When & Then
        expect(
          () => repository.getFromCache(testUrl),
          throwsA(isA<NetworkException>()),
        );
      });
    });
    
    group('clearCache', () {
      test('우선순위별 캐시 정리', () async {
        // Given
        final cachedImages = [
          ImageCacheEntity(url: 'url1', priority: CachePriority.low),
          ImageCacheEntity(url: 'url2', priority: CachePriority.high),
          ImageCacheEntity(url: 'url3', priority: CachePriority.normal),
        ];
        when(mockLocalSource.getAll())
          .thenAnswer((_) async => cachedImages);
        
        // When
        await repository.clearCache(keepPriority: CachePriority.high);
        
        // Then
        verify(mockLocalSource.remove('url1')).called(1);
        verify(mockLocalSource.remove('url3')).called(1);
        verifyNever(mockLocalSource.remove('url2'));
      });
    });
  });
}
```

## 🎨 위젯 테스트 (Widget Tests)

### 1. OptimizedImage 위젯 테스트

```dart
// test/services/image/presentation/widgets/optimized_image_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/image/presentation/widgets/optimized_image.dart';

void main() {
  group('OptimizedImage Widget', () {
    testWidgets('이미지 로딩 표시', (tester) async {
      // Given
      const imageUrl = 'https://example.com/image.jpg';
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: OptimizedImage(
            imageUrl: imageUrl,
            width: 200,
            height: 200,
          ),
        ),
      );
      
      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('Progressive 이미지 로딩', (tester) async {
      // Given
      const imageUrl = 'https://example.com/image.jpg';
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: OptimizedImage(
            imageUrl: imageUrl,
            enableProgressive: true,
          ),
        ),
      );
      
      // Then
      expect(find.byType(ProgressiveImage), findsOneWidget);
    });
    
    testWidgets('에러 표시', (tester) async {
      // Given
      const invalidUrl = 'invalid://url';
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: OptimizedImage(
            imageUrl: invalidUrl,
          ),
        ),
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // Then
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
}
```

### 2. Provider 테스트

```dart
// test/services/image/presentation/providers/image_cache_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/services/image/presentation/providers/image_cache_provider.dart';

void main() {
  group('ImageCacheProvider', () {
    late ImageCacheProvider provider;
    late MockPreloadImagesUseCase mockPreloadUseCase;
    late MockClearCacheUseCase mockClearCacheUseCase;
    late MockGetCacheStatsUseCase mockStatsUseCase;
    
    setUp(() {
      mockPreloadUseCase = MockPreloadImagesUseCase();
      mockClearCacheUseCase = MockClearCacheUseCase();
      mockStatsUseCase = MockGetCacheStatsUseCase();
      
      provider = ImageCacheProvider(
        preloadImages: mockPreloadUseCase,
        clearCache: mockClearCacheUseCase,
        getCacheStats: mockStatsUseCase,
      );
    });
    
    test('프리로드 상태 변경', () async {
      // Given
      const urls = ['url1', 'url2'];
      when(mockPreloadUseCase(any))
        .thenAnswer((_) async => null);
      
      // When
      expect(provider.isPreloading, false);
      final future = provider.preloadForScreen(urls);
      
      // Then
      expect(provider.isPreloading, true);
      
      await future;
      expect(provider.isPreloading, false);
    });
    
    test('캐시 통계 업데이트', () {
      // Given
      final stats = CacheStatistics(
        hitRate: 0.75,
        totalSize: 1024 * 1024,
        imageCount: 100,
      );
      final statsStream = Stream.value(stats);
      when(mockStatsUseCase())
        .thenAnswer((_) => statsStream);
      
      // When
      provider.watchStats();
      
      // Then
      expectLater(
        provider.stream,
        emits(predicate((p) => 
          p.stats?.hitRate == 0.75
        )),
      );
    });
  });
}
```

## 🔗 통합 테스트 (Integration Tests)

### 1. 캐싱 플로우 테스트

```dart
// test/services/image/integration/caching_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:versus_space/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Image Caching Flow', () {
    testWidgets('전체 캐싱 플로우', (tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();
      
      // 채팅 화면으로 이동
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      
      // When - 이미지가 있는 메시지 로드
      await tester.drag(
        find.byType(ListView),
        Offset(0, -300),
      );
      await tester.pumpAndSettle();
      
      // Then - 이미지가 캐시됨
      final imageFinder = find.byType(CachedNetworkImage);
      expect(imageFinder, findsWidgets);
      
      // 네트워크 끊고 다시 로드
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
      
      // 캐시에서 로드됨 확인
      expect(imageFinder, findsWidgets);
    });
  });
}
```

### 2. 메모리 누수 테스트

```dart
// test/services/image/integration/memory_leak_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_testing/leak_tracker_testing.dart';

void main() {
  testWidgetsWithLeakTracking(
    'ImageCache 메모리 누수 없음',
    (tester) async {
      // Given
      final service = UnifiedImageCacheService.instance;
      
      // When - 대량 이미지 로드
      for (int i = 0; i < 100; i++) {
        await service.preloadImages(
          context,
          ['https://example.com/image$i.jpg'],
        );
      }
      
      // 캐시 정리
      service.clearOldCache(keepRecentCount: 10);
      
      // Then - 메모리 누수 없음 확인
    },
  );
}
```

## ⚡ 성능 테스트 (Performance Tests)

### 1. 로딩 시간 측정

```dart
// test/services/image/performance/loading_time_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class ImageLoadingBenchmark extends BenchmarkBase {
  ImageLoadingBenchmark() : super('ImageLoading');
  
  late ImageCacheService service;
  
  @override
  void setup() {
    service = ImageCacheService();
  }
  
  @override
  void run() {
    service.loadImage('https://example.com/image.jpg');
  }
  
  @override
  void teardown() {
    service.clearCache();
  }
}

void main() {
  test('이미지 로딩 벤치마크', () {
    final benchmark = ImageLoadingBenchmark();
    final score = benchmark.measure();
    
    // 100ms 이하여야 함
    expect(score, lessThan(100000)); // microseconds
  });
}
```

### 2. 메모리 사용량 테스트

```dart
// test/services/image/performance/memory_usage_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:memory_usage/memory_usage.dart';

void main() {
  test('메모리 사용량 한계', () async {
    // Given
    final service = UnifiedImageCacheService.instance;
    final initialMemory = await MemoryUsage.currentUsage;
    
    // When - 100개 이미지 로드
    for (int i = 0; i < 100; i++) {
      await service.preloadImages(
        context,
        ['https://example.com/image$i.jpg'],
      );
    }
    
    // Then
    final finalMemory = await MemoryUsage.currentUsage;
    final memoryIncrease = finalMemory - initialMemory;
    
    // 100MB 이하로 증가해야 함
    expect(memoryIncrease, lessThan(100 * 1024 * 1024));
  });
}
```

## 🎯 E2E 테스트

### Golden Test

```dart
// test/services/image/golden/image_display_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('Image Display Golden Tests', () {
    testGoldens('다양한 크기 이미지 표시', (tester) async {
      // Given
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1,
      )
        ..addScenario(
          'Small Image',
          OptimizedImage(
            imageUrl: 'assets/test/small.jpg',
            width: 100,
          ),
        )
        ..addScenario(
          'Large Image',
          OptimizedImage(
            imageUrl: 'assets/test/large.jpg',
            width: 400,
          ),
        )
        ..addScenario(
          'Progressive',
          OptimizedImage(
            imageUrl: 'assets/test/progressive.jpg',
            enableProgressive: true,
          ),
        );
      
      // When & Then
      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'image_display_grid');
    });
  });
}
```

## 📊 테스트 커버리지

### 측정 방법
```bash
# 전체 커버리지 측정
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 특정 디렉토리만
flutter test --coverage test/services/image/
```

### 목표 달성 전략
1. **Critical Path 100%**: 핵심 비즈니스 로직
2. **Edge Cases**: 경계값, 에러 케이스
3. **Happy Path**: 정상 시나리오
4. **Integration**: 컴포넌트 간 상호작용

## 🚀 CI/CD 통합

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test Image Service

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    - uses: subosito/flutter-action@v2
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Run tests
      run: flutter test test/services/image/ --coverage
    
    - name: Check coverage
      run: |
        coverage=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
        if (( $(echo "$coverage < 80" | bc -l) )); then
          echo "Coverage $coverage% is below threshold 80%"
          exit 1
        fi
    
    - name: Upload coverage
      uses: codecov/codecov-action@v2
      with:
        file: coverage/lcov.info
```

## 🔍 테스트 실행 가이드

### 로컬 실행
```bash
# 모든 테스트
flutter test

# 특정 파일
flutter test test/services/image/domain/usecases/preload_images_test.dart

# 특정 그룹
flutter test --name "PreloadImagesUseCase"

# 커버리지와 함께
flutter test --coverage

# Watch mode
flutter test --watch
```

### 디버깅
```bash
# 상세 로그
flutter test --verbose

# 특정 테스트만
flutter test --name "WiFi에서 모든 이미지 프리로드"

# 디버거 연결
flutter test --start-paused
```

## ✅ 체크리스트

### Unit Tests
- [ ] Domain Layer
  - [ ] Entities
  - [ ] Use Cases
  - [ ] Repository Interfaces
- [ ] Data Layer
  - [ ] Data Sources
  - [ ] Repository Implementations
  - [ ] Services
- [ ] Presentation Layer
  - [ ] Providers
  - [ ] Utilities

### Widget Tests
- [ ] OptimizedImage
- [ ] ProgressiveImage
- [ ] PreloadedImage
- [ ] Provider State Changes

### Integration Tests
- [ ] Caching Flow
- [ ] Network Switching
- [ ] Memory Management
- [ ] Error Recovery

### Performance Tests
- [ ] Loading Time
- [ ] Memory Usage
- [ ] Cache Hit Rate
- [ ] Network Usage

---

*이 문서는 Services Layer 내 Image Service의 테스트 전략입니다.*  
*목표: 90% 커버리지로 안정적인 이미지 캐싱 서비스 보장*