# 🔄 Moderation Service - Services Layer 내부 리팩토링 계획

> Phase 3: Services Layer 내부에서 Clean Architecture 적용  
> 최종 업데이트: 2025-08-28 | 예상 기간: 2주

## 📋 핵심 원칙

### ⚠️ 중요: Services Layer는 유지됩니다

Moderation Service는 **전역 인프라 서비스**로서 `/lib/services/moderation/`에 유지됩니다. 이 문서는 Services Layer 내부에서 Clean Architecture를 적용하는 계획입니다. **절대 Feature로 이동하지 않습니다.**

### 의존성 규칙
```
✅ 올바른 방향:
Features → Services → Backend

❌ 금지된 방향:
Services → Features (역방향 의존성)
```

## 🏗️ 현재 상태 분석

### 현재 구조 (3개 파일, 609줄)
```
lib/services/moderation/
├── cloud_image_moderation_service.dart  # 189줄 - Cloud Vision API 통합
├── image_moderation_service.dart        # 123줄 - 이미지 검열
└── perspective_api_service.dart         # 297줄 - 텍스트 검열
```

### 현재 문제점
1. **보안 위험**: API 키 하드코딩 🔴 매우 심각
2. **정적 메서드 남용**: 테스트 불가능한 구조
3. **에러 처리 일관성 부족**: 실패 시 통과 처리 (위험!)
4. **성능 최적화 부재**: 순차 처리, 캐싱 없음
5. **확장성 부족**: 인터페이스 없이 구현만 존재

## 🎯 목표 구조 (Services Layer 내부)

### Clean Architecture를 Services 내부에 적용
```
lib/services/moderation/
├── domain/                    # 비즈니스 규칙 (인터페이스)
│   ├── entities/
│   │   ├── moderation_result.dart
│   │   ├── text_analysis.dart
│   │   └── image_safety.dart
│   ├── repositories/
│   │   ├── text_moderation_repository.dart
│   │   └── image_moderation_repository.dart
│   └── usecases/
│       ├── analyze_text.dart
│       ├── check_image.dart
│       └── monitor_moderation.dart
│
├── data/                      # 구현 레이어
│   ├── models/
│   │   ├── moderation_result_model.dart
│   │   ├── perspective_response_model.dart
│   │   └── vision_response_model.dart
│   ├── datasources/
│   │   ├── perspective_api_datasource.dart
│   │   ├── cloud_vision_datasource.dart
│   │   └── firebase_moderation_datasource.dart
│   ├── repositories/
│   │   ├── text_moderation_repository_impl.dart
│   │   └── image_moderation_repository_impl.dart
│   └── services/
│       ├── api_key_manager.dart
│       ├── moderation_cache.dart
│       └── batch_processor.dart
│
├── presentation/              # 서비스 인터페이스
│   ├── moderation_service.dart        # 메인 서비스 (DI)
│   ├── moderation_provider.dart       # Provider 패턴
│   └── moderation_config.dart         # 설정 관리
│
├── utils/                     # 유틸리티
│   ├── toxic_patterns.dart   # 욕설 패턴 정의
│   ├── image_optimizer.dart  # 이미지 최적화
│   └── result_mapper.dart    # 결과 매핑
│
├── README.md
├── MIGRATION_Part3.md
└── TEST.md
```

## 📊 마이그레이션 로드맵

### Phase 1: 보안 강화 (긴급, 1일) 🔴

#### Day 1: API 키 보안
```dart
// lib/services/moderation/data/services/api_key_manager.dart
class ApiKeyManager {
  // 환경 변수에서 API 키 로드
  static String get perspectiveApiKey => 
    const String.fromEnvironment('PERSPECTIVE_API_KEY');
  
  static String get cloudVisionApiKey =>
    const String.fromEnvironment('CLOUD_VISION_API_KEY');
  
  // Firebase Remote Config 통합 (선택적)
  static Future<String> getApiKey(String keyName) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    return remoteConfig.getString(keyName);
  }
}

// .env 파일 생성 (gitignore에 추가)
// PERSPECTIVE_API_KEY=your_key_here
// CLOUD_VISION_API_KEY=your_key_here
```

### Phase 2: Domain Layer 구축 (2일)

#### Day 2: 엔티티 정의
```dart
// lib/services/moderation/domain/entities/moderation_result.dart
class ModerationResult {
  final bool isApproved;
  final SeverityLevel severity;
  final List<String> violations;
  final Map<String, double> scores;
  final DateTime timestamp;
  
  const ModerationResult({
    required this.isApproved,
    required this.severity,
    this.violations = const [],
    this.scores = const {},
    required this.timestamp,
  });
  
  // 기본값: 차단 (안전 우선)
  static const blocked = ModerationResult(
    isApproved: false,
    severity: SeverityLevel.high,
    timestamp: null,
  );
}

enum SeverityLevel {
  none(0),
  low(1),
  medium(2),
  high(3),
  critical(4);
  
  final int value;
  const SeverityLevel(this.value);
}
```

#### Day 3: Repository 인터페이스
```dart
// lib/services/moderation/domain/repositories/text_moderation_repository.dart
abstract class TextModerationRepository {
  Future<ModerationResult> analyzeText(String text);
  Future<Map<String, ModerationResult>> analyzeMultiple(Map<String, String> texts);
  Future<bool> validateTextInput(String text);
  Stream<ModerationResult> watchTextModeration(String id);
}

// lib/services/moderation/domain/repositories/image_moderation_repository.dart
abstract class ImageModerationRepository {
  Future<ModerationResult> checkImage(Uint8List imageData);
  Future<List<ModerationResult>> checkMultipleImages(List<Uint8List> images);
  Stream<ModerationResult> watchImageModeration(String imageId);
  Future<ModerationResult> waitForModeration(String imageId, {Duration timeout});
}
```

### Phase 3: Data Layer 구현 (3일)

#### Day 4-5: 데이터소스 구현
```dart
// lib/services/moderation/data/datasources/perspective_api_datasource.dart
@LazySingleton()
class PerspectiveApiDatasource {
  final http.Client _client;
  final ApiKeyManager _keyManager;
  
  static const _baseUrl = 'https://commentanalyzer.googleapis.com/v1alpha1';
  
  PerspectiveApiDatasource(this._client, this._keyManager);
  
  Future<Map<String, dynamic>> analyzeComment(String text) async {
    final apiKey = _keyManager.perspectiveApiKey;
    
    final response = await _client.post(
      Uri.parse('$_baseUrl/comments:analyze?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'comment': {'text': text},
        'requestedAttributes': {
          'TOXICITY': {},
          'PROFANITY': {},
          'THREAT': {},
          'INSULT': {},
        },
        'languages': ['ko', 'en'],
        'doNotStore': true,
      }),
    );
    
    if (response.statusCode != 200) {
      throw ModerationException('Perspective API error: ${response.statusCode}');
    }
    
    return json.decode(response.body);
  }
}

// lib/services/moderation/data/datasources/cloud_vision_datasource.dart
@LazySingleton()
class CloudVisionDatasource {
  final FirebaseFunctions _functions;
  final ImageOptimizer _optimizer;
  
  CloudVisionDatasource(this._functions, this._optimizer);
  
  Future<Map<String, dynamic>> analyzeImage(Uint8List imageData) async {
    // 이미지 최적화
    final optimized = await _optimizer.optimize(imageData);
    final base64Image = base64Encode(optimized);
    
    // Cloud Function 호출
    final callable = _functions.httpsCallable('checkImageContent');
    final response = await callable.call<Map<String, dynamic>>({
      'image': base64Image,
    });
    
    return response.data;
  }
}
```

#### Day 6: Repository 구현
```dart
// lib/services/moderation/data/repositories/text_moderation_repository_impl.dart
@LazySingleton()
class TextModerationRepositoryImpl implements TextModerationRepository {
  final PerspectiveApiDatasource _perspectiveApi;
  final ModerationCache _cache;
  final ToxicPatterns _toxicPatterns;
  
  TextModerationRepositoryImpl(
    this._perspectiveApi,
    this._cache,
    this._toxicPatterns,
  );
  
  @override
  Future<ModerationResult> analyzeText(String text) async {
    // 캐시 확인
    final cached = await _cache.get(text);
    if (cached != null) return cached;
    
    try {
      // API 호출
      final response = await _perspectiveApi.analyzeComment(text);
      final result = _mapResponseToResult(response);
      
      // 캐시 저장
      await _cache.set(text, result);
      
      return result;
    } catch (e) {
      // 에러 시 차단 (안전 우선)
      return ModerationResult.blocked;
    }
  }
  
  @override
  Future<Map<String, ModerationResult>> analyzeMultiple(
    Map<String, String> texts,
  ) async {
    // 병렬 처리
    final futures = texts.entries.map(
      (entry) => analyzeText(entry.value).then(
        (result) => MapEntry(entry.key, result),
      ),
    );
    
    final results = await Future.wait(futures);
    return Map.fromEntries(results);
  }
}
```

### Phase 4: 성능 최적화 (2일)

#### Day 7: 캐싱 시스템
```dart
// lib/services/moderation/data/services/moderation_cache.dart
@LazySingleton()
class ModerationCache {
  final Duration _ttl;
  final int _maxSize;
  final Map<String, CacheEntry> _cache = {};
  
  ModerationCache({
    Duration ttl = const Duration(hours: 1),
    int maxSize = 1000,
  }) : _ttl = ttl,
       _maxSize = maxSize;
  
  Future<ModerationResult?> get(String key) async {
    final hash = _generateHash(key);
    final entry = _cache[hash];
    
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(hash);
      return null;
    }
    
    return entry.result;
  }
  
  Future<void> set(String key, ModerationResult result) async {
    final hash = _generateHash(key);
    
    // LRU 제거
    if (_cache.length >= _maxSize) {
      _removeOldest();
    }
    
    _cache[hash] = CacheEntry(
      result: result,
      timestamp: DateTime.now(),
      ttl: _ttl,
    );
  }
  
  String _generateHash(String text) {
    final bytes = utf8.encode(text);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
```

#### Day 8: 배치 처리
```dart
// lib/services/moderation/data/services/batch_processor.dart
@LazySingleton()
class BatchProcessor {
  static const int _batchSize = 10;
  static const Duration _batchDelay = Duration(milliseconds: 100);
  
  Future<List<T>> processBatch<T>(
    List<Future<T> Function()> tasks,
  ) async {
    final results = <T>[];
    
    for (var i = 0; i < tasks.length; i += _batchSize) {
      final batch = tasks.skip(i).take(_batchSize);
      final batchResults = await Future.wait(
        batch.map((task) => task()),
      );
      results.addAll(batchResults);
      
      // Rate limiting
      if (i + _batchSize < tasks.length) {
        await Future.delayed(_batchDelay);
      }
    }
    
    return results;
  }
}
```

### Phase 5: Presentation Layer 및 DI (2일)

#### Day 9: 서비스 인터페이스
```dart
// lib/services/moderation/presentation/moderation_service.dart
@LazySingleton()
class ModerationService {
  final TextModerationRepository _textRepo;
  final ImageModerationRepository _imageRepo;
  final BatchProcessor _batchProcessor;
  
  ModerationService(
    this._textRepo,
    this._imageRepo,
    this._batchProcessor,
  );
  
  // 통합 API
  Future<ModerationResult> checkContent({
    String? text,
    Uint8List? image,
  }) async {
    final results = await Future.wait([
      if (text != null) _textRepo.analyzeText(text),
      if (image != null) _imageRepo.checkImage(image),
    ]);
    
    // 가장 심각한 결과 반환
    return results.reduce((a, b) => 
      a.severity.value > b.severity.value ? a : b,
    );
  }
  
  // TextFormField 통합
  Future<String?> validateInput(String? value) async {
    if (value == null || value.trim().isEmpty) return null;
    
    final result = await _textRepo.analyzeText(value);
    if (!result.isApproved) {
      return _getViolationMessage(result);
    }
    
    return null;
  }
}
```

#### Day 10: DI 설정
```dart
// lib/services/moderation/presentation/moderation_config.dart
@module
abstract class ModerationModule {
  @lazySingleton
  http.Client get httpClient => http.Client();
  
  @lazySingleton
  ApiKeyManager get apiKeyManager => ApiKeyManager();
  
  @lazySingleton
  ImageOptimizer get imageOptimizer => ImageOptimizer();
  
  @lazySingleton
  ModerationCache get cache => ModerationCache(
    ttl: const Duration(hours: 1),
    maxSize: 1000,
  );
}

// GetIt 등록
void configureModerationDependencies() {
  // Datasources
  getIt.registerLazySingleton<PerspectiveApiDatasource>(
    () => PerspectiveApiDatasource(getIt(), getIt()),
  );
  
  getIt.registerLazySingleton<CloudVisionDatasource>(
    () => CloudVisionDatasource(getIt(), getIt()),
  );
  
  // Repositories
  getIt.registerLazySingleton<TextModerationRepository>(
    () => TextModerationRepositoryImpl(getIt(), getIt(), getIt()),
  );
  
  getIt.registerLazySingleton<ImageModerationRepository>(
    () => ImageModerationRepositoryImpl(getIt(), getIt()),
  );
  
  // Service
  getIt.registerLazySingleton<ModerationService>(
    () => ModerationService(getIt(), getIt(), getIt()),
  );
}
```

### Phase 6: 레거시 호환성 (1일)

#### Day 11: 어댑터 구현
```dart
// lib/services/moderation/perspective_api_service.dart (수정)
/// @Deprecated('Use ModerationService instead')
class PerspectiveApiService {
  static ModerationService get _service => getIt<ModerationService>();
  
  static Future<PerspectiveResult> analyzeText(String text) async {
    final result = await _service.checkContent(text: text);
    return _mapToLegacyResult(result);
  }
  
  // 기존 메서드들을 새 서비스로 위임
}

// lib/services/moderation/image_moderation_service.dart (수정)
/// @Deprecated('Use ModerationService instead')
class ImageModerationService {
  static ModerationService get _service => getIt<ModerationService>();
  
  static Future<ModerationResult> checkImage({
    required File imageFile,
    required String box,
  }) async {
    final bytes = await imageFile.readAsBytes();
    return await _service.checkContent(image: bytes);
  }
}
```

## 📈 성공 지표

### 코드 품질
| 지표 | 현재 | 목표 |
|------|------|------|
| 파일 수 | 3 | 20+ |
| 최대 파일 크기 | 297줄 | <150줄 |
| 테스트 커버리지 | 0% | 85% |
| 순환 복잡도 | 높음 | 낮음 |

### 성능
| 지표 | 현재 | 목표 |
|------|------|------|
| 텍스트 검열 | 500ms | 200ms |
| 이미지 검열 | 3초 | 1초 |
| 배치 처리 | 순차 | 병렬 |
| 캐시 히트율 | 0% | 60% |

### 보안
| 지표 | 현재 | 목표 |
|------|------|------|
| API 키 관리 | 하드코딩 | 환경변수 |
| 실패 처리 | 통과 | 차단 |
| 에러 로깅 | print | 구조화 |

## ⚠️ 주의사항

### 1. Services Layer 유지
- **절대 금지**: Feature 모듈로 이동
- **필수**: `/lib/services/moderation/` 경로 유지
- **이유**: 전역 인프라 서비스

### 2. 보안 최우선
- API 키는 절대 소스 코드에 포함 금지
- 환경 변수 또는 Remote Config 사용
- 실패 시 차단이 기본값

### 3. 레거시 호환성
- 기존 정적 메서드 유지 (Deprecated)
- 점진적 마이그레이션 지원
- Breaking change 최소화

## ✅ 체크리스트

### Week 1 (긴급)
- [ ] API 키 환경 변수로 이동
- [ ] Domain Layer 생성
- [ ] Data Layer 구현
- [ ] 에러 처리 개선 (차단 기본값)

### Week 2
- [ ] 캐싱 시스템 구현
- [ ] 배치 처리 최적화
- [ ] Presentation Layer 구축
- [ ] DI 설정
- [ ] 레거시 호환성 어댑터
- [ ] 테스트 작성

## 🔄 마이그레이션 후 구조

### Before (현재)
```
lib/services/moderation/
├── cloud_image_moderation_service.dart  # 정적 메서드
├── image_moderation_service.dart        # 정적 메서드
└── perspective_api_service.dart         # API 키 하드코딩
```

### After (목표)
```
lib/services/moderation/
├── domain/      # 비즈니스 규칙
├── data/        # 구현
├── presentation/ # 서비스 인터페이스
└── utils/       # 유틸리티
```

## 📚 참고 자료

- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [Services Layer 유지 원칙](/lib/services/README.md)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [API 보안 가이드](https://cloud.google.com/docs/authentication/api-keys)

---

*이 문서는 Moderation Service의 Services Layer 내부 리팩토링 계획입니다.*  
*Services Layer는 전역 인프라로 유지되어야 합니다.*  
*🔴 긴급: API 키 보안 문제를 즉시 해결해야 합니다.*