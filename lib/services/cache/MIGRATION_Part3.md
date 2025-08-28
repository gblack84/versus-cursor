# 🔄 Cache Service 마이그레이션 계획 Part 3

> Cache Service의 Services Layer 내 Clean Architecture 적용 계획  
> 작성일: 2025-08-28 | 예상 기간: 2주

## 📌 Executive Summary

**현재 상황**: 3-Layer 캐싱 시스템 구현 완료, 역방향 의존성 문제 존재  
**목표**: Services Layer 유지하며 Clean Architecture 적용, 의존성 역전  
**방법**: 인터페이스 분리, DI 패턴, Feature별 Adapter

## 🎯 마이그레이션 목표

### 핵심 원칙
1. **Services Layer 유지**: `/lib/services/cache/`에서 계속 관리
2. **역방향 의존성 제거**: Services → Backend 직접 참조 제거
3. **Feature 독립성**: Feature별 캐시 전략 주입
4. **테스트 가능성**: DI 패턴으로 Mock 가능

### Before (현재)
```
lib/services/cache/
├── unified_cache_service.dart   # 문제: MessagesModel, PostsModel import
├── simple_memory_cache.dart     
├── cache_statistics.dart        
└── preload_strategy.dart        
```

### After (목표)
```
lib/services/cache/
├── domain/                      # 도메인 레이어
│   ├── interfaces/
│   │   ├── i_cache_service.dart
│   │   ├── i_cache_layer.dart
│   │   └── i_cache_strategy.dart
│   ├── entities/
│   │   ├── cache_entry.dart
│   │   └── cache_metrics.dart
│   └── usecases/
│       ├── get_cached_data.dart
│       └── invalidate_cache.dart
│
├── data/                        # 데이터 레이어
│   ├── services/
│   │   └── cache_service_impl.dart
│   ├── layers/
│   │   ├── memory_layer.dart
│   │   ├── hive_layer.dart
│   │   └── firestore_layer.dart
│   └── repositories/
│       └── cache_repository.dart
│
├── presentation/                # 프레젠테이션 레이어
│   ├── providers/
│   │   └── cache_provider.dart
│   └── widgets/
│       └── cache_dashboard.dart
│
└── adapters/                    # Feature별 어댑터
    ├── chat_cache_adapter.dart
    ├── post_cache_adapter.dart
    └── user_cache_adapter.dart
```

## 📊 현재 문제점 분석

### 1. 역방향 의존성 ⚠️ 심각도: 높음

```dart
// 현재 문제 코드
import '/backend/schema/messages_model.dart';  // ❌ Services → Backend
import '/backend/schema/posts_model.dart';     // ❌ Services → Backend
import '/backend/schema/users_model.dart';     // ❌ Services → Backend

class UnifiedCacheService {
  Future<List<MessagesModel>> getChatMessages(String chatId) { }  // ❌
  Future<List<PostsModel>> getFeedPosts({int limit = 20}) { }     // ❌
  Future<UsersModel?> getUserProfile(String userId) { }           // ❌
}
```

**영향**: 
- Services가 Backend에 의존하여 계층 위반
- Feature 변경 시 Services도 수정 필요
- 테스트 시 Backend 모델 필요

### 2. 싱글톤 하드코딩 ⚠️ 심각도: 중간

```dart
// 현재 문제 코드
abstract class UnifiedCacheService {
  static late UnifiedCacheService _instance;  // ❌ 하드코딩된 싱글톤
  static UnifiedCacheService get instance => _instance;
}
```

**영향**:
- 단위 테스트 시 Mock 주입 불가
- 다른 구현체 전환 어려움
- 병렬 테스트 불가능

### 3. 전략 하드코딩 ⚠️ 심각도: 중간

```dart
// 현재 문제 코드
if (dataType == 'chat_messages') {
  ttl = Duration(minutes: 5);  // ❌ 하드코딩
} else if (dataType == 'feed_posts') {
  ttl = Duration(minutes: 10); // ❌ 하드코딩
}
```

**영향**:
- Feature별 최적화 어려움
- 런타임 설정 변경 불가
- 코드 수정 없이 튜닝 불가

## 📝 상세 마이그레이션 계획

### Phase 1: 인터페이스 정의 (Day 1-2)

#### Step 1.1: 도메인 인터페이스

```dart
// domain/interfaces/i_cache_service.dart
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<void> remove(String key);
  Future<void> clear();
  
  // 제네릭 타입으로 변경 (모델 의존성 제거)
  Future<List<T>> getList<T>(String key);
  Future<void> setList<T>(String key, List<T> items);
}

// domain/interfaces/i_cache_layer.dart
abstract class ICacheLayer {
  String get name;
  int get priority;
  
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value, {Duration? ttl});
  Future<bool> exists(String key);
  Future<void> remove(String key);
}

// domain/interfaces/i_cache_strategy.dart
abstract class ICacheStrategy {
  Duration getTTL(String dataType);
  int getMaxSize(String dataType);
  bool shouldCache(String key, dynamic value);
  List<String> getDependentKeys(String key);
}
```

#### Step 1.2: 도메인 엔티티

```dart
// domain/entities/cache_entry.dart
class CacheEntry<T> {
  final String key;
  final T data;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic> metadata;
  
  bool get isExpired => 
    expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

// domain/entities/cache_metrics.dart
class CacheMetrics {
  final double hitRate;
  final Map<String, double> layerHitRates;
  final int totalRequests;
  final int totalHits;
  final Duration averageResponseTime;
  final int memorySizeBytes;
  
  Map<String, dynamic> toJson() => { };
}
```

### Phase 2: 레이어 구현 분리 (Day 3-4)

#### Step 2.1: 메모리 레이어 리팩토링

```dart
// data/layers/memory_layer.dart
class MemoryLayer implements ICacheLayer {
  final int maxSize;
  final Map<String, CacheEntry> _cache = {};
  
  MemoryLayer({this.maxSize = 100});
  
  @override
  String get name => 'L1-Memory';
  
  @override
  int get priority => 1;
  
  @override
  Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.data as T?;
  }
  
  void _evictLRU() {
    if (_cache.length < maxSize) return;
    
    String? oldestKey;
    DateTime? oldestAccess;
    
    _cache.forEach((key, entry) {
      final accessed = entry.metadata['lastAccessed'] as DateTime?;
      if (oldestAccess == null || 
          (accessed != null && accessed.isBefore(oldestAccess!))) {
        oldestKey = key;
        oldestAccess = accessed;
      }
    });
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }
}

// data/layers/hive_layer.dart  
class HiveLayer implements ICacheLayer {
  late Box<dynamic> _box;
  
  @override
  String get name => 'L2-Hive';
  
  @override
  int get priority => 2;
  
  Future<void> init() async {
    _box = await Hive.openBox('cache');
  }
  
  @override
  Future<T?> get<T>(String key) async {
    try {
      final data = _box.get(key);
      if (data == null) return null;
      
      // JSON 디시리얼라이즈
      if (T == List) {
        return (data as List).cast<dynamic>() as T;
      }
      return data as T;
    } catch (e) {
      // 손상된 데이터 제거
      await _box.delete(key);
      return null;
    }
  }
}
```

### Phase 3: Feature 어댑터 구현 (Day 5-6)

#### Step 3.1: 어댑터 인터페이스

```dart
// adapters/base_cache_adapter.dart
abstract class BaseCacheAdapter<T> {
  final ICacheService cacheService;
  final ICacheStrategy strategy;
  
  BaseCacheAdapter({
    required this.cacheService,
    required this.strategy,
  });
  
  // 시리얼라이즈/디시리얼라이즈
  Map<String, dynamic> toJson(T item);
  T fromJson(Map<String, dynamic> json);
  
  // 캐시 키 생성
  String generateKey(Map<String, dynamic> params);
  
  // 캐시 연산
  Future<T?> get(String id) async {
    final key = generateKey({'id': id});
    final json = await cacheService.get<Map<String, dynamic>>(key);
    return json != null ? fromJson(json) : null;
  }
  
  Future<void> set(String id, T item) async {
    final key = generateKey({'id': id});
    final ttl = strategy.getTTL(T.toString());
    await cacheService.set(key, toJson(item), ttl: ttl);
  }
}
```

#### Step 3.2: Feature별 어댑터

```dart
// adapters/chat_cache_adapter.dart
class ChatCacheAdapter extends BaseCacheAdapter<dynamic> {
  ChatCacheAdapter({
    required ICacheService cacheService,
    required ICacheStrategy strategy,
  }) : super(cacheService: cacheService, strategy: strategy);
  
  @override
  String generateKey(Map<String, dynamic> params) {
    if (params['chatId'] != null) {
      return 'chat_messages_${params['chatId']}';
    }
    return 'chat_${params['id']}';
  }
  
  @override
  Map<String, dynamic> toJson(dynamic item) {
    // MessagesModel → Map 변환 (모델 import 없이)
    return item.toJson();
  }
  
  @override
  dynamic fromJson(Map<String, dynamic> json) {
    // Map → MessagesModel 변환은 Feature에서 처리
    return json;
  }
  
  // 채팅 특화 메서드
  Future<List<dynamic>> getMessages(String chatId) async {
    final key = generateKey({'chatId': chatId});
    return await cacheService.getList<dynamic>(key) ?? [];
  }
  
  Future<void> setMessages(String chatId, List<dynamic> messages) async {
    final key = generateKey({'chatId': chatId});
    final ttl = strategy.getTTL('chat_messages');
    
    // JSON으로 변환하여 저장
    final jsonList = messages.map((m) => toJson(m)).toList();
    await cacheService.setList(key, jsonList);
  }
}

// adapters/post_cache_adapter.dart
class PostCacheAdapter extends BaseCacheAdapter<dynamic> {
  // 비슷한 구조로 구현
}

// adapters/user_cache_adapter.dart
class UserCacheAdapter extends BaseCacheAdapter<dynamic> {
  // 비슷한 구조로 구현
}
```

### Phase 4: DI 통합 (Day 7-8)

#### Step 4.1: DI 설정

```dart
// injection.dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> configureCacheDependencies() async {
  // 레이어 등록
  getIt.registerSingleton<ICacheLayer>(
    MemoryLayer(maxSize: 100),
    instanceName: 'memory',
  );
  
  getIt.registerSingletonAsync<ICacheLayer>(
    () async {
      final layer = HiveLayer();
      await layer.init();
      return layer;
    },
    instanceName: 'hive',
  );
  
  getIt.registerSingleton<ICacheLayer>(
    FirestoreLayer(),
    instanceName: 'firestore',
  );
  
  // 서비스 등록
  getIt.registerLazySingleton<ICacheService>(
    () => CacheServiceImpl(
      layers: [
        getIt<ICacheLayer>(instanceName: 'memory'),
        getIt<ICacheLayer>(instanceName: 'hive'),
        getIt<ICacheLayer>(instanceName: 'firestore'),
      ],
    ),
  );
  
  // 어댑터 등록 (Feature별)
  getIt.registerFactory<ChatCacheAdapter>(
    () => ChatCacheAdapter(
      cacheService: getIt<ICacheService>(),
      strategy: ChatCacheStrategy(),
    ),
  );
}
```

#### Step 4.2: Feature에서 사용

```dart
// features/chat/data/services/chat_service.dart
class ChatService {
  final ChatCacheAdapter _cacheAdapter = getIt<ChatCacheAdapter>();
  
  Future<List<MessagesModel>> getMessages(String chatId) async {
    // 1. 캐시 조회 (JSON)
    final cachedJson = await _cacheAdapter.getMessages(chatId);
    
    if (cachedJson.isNotEmpty) {
      // 2. JSON → Model 변환 (Feature에서 처리)
      return cachedJson.map((json) => 
        MessagesModel.fromJson(json as Map<String, dynamic>)
      ).toList();
    }
    
    // 3. Firestore 조회
    final messages = await fetchFromFirestore(chatId);
    
    // 4. 캐싱 (Model → JSON은 어댑터에서 처리)
    await _cacheAdapter.setMessages(chatId, messages);
    
    return messages;
  }
}
```

### Phase 5: 마이그레이션 실행 (Day 9-10)

#### Step 5.1: 점진적 마이그레이션

```dart
// 기존 코드 호환성 유지
class UnifiedCacheService {
  final ICacheService _newService = getIt<ICacheService>();
  
  // Deprecated 마킹
  @Deprecated('Use ICacheService with adapters instead')
  Future<List<MessagesModel>> getChatMessages(String chatId) async {
    final adapter = getIt<ChatCacheAdapter>();
    final jsonList = await adapter.getMessages(chatId);
    return jsonList.map((json) => 
      MessagesModel.fromJson(json as Map<String, dynamic>)
    ).toList();
  }
}
```

#### Step 5.2: 테스트 작성

```dart
// test/services/cache/cache_service_test.dart
void main() {
  group('CacheService Tests', () {
    late ICacheService cacheService;
    late MockCacheLayer mockMemory;
    late MockCacheLayer mockHive;
    
    setUp(() {
      mockMemory = MockCacheLayer();
      mockHive = MockCacheLayer();
      
      cacheService = CacheServiceImpl(
        layers: [mockMemory, mockHive],
      );
    });
    
    test('should check layers in priority order', () async {
      when(mockMemory.get<String>('key')).thenAnswer((_) async => null);
      when(mockHive.get<String>('key')).thenAnswer((_) async => 'value');
      
      final result = await cacheService.get<String>('key');
      
      expect(result, equals('value'));
      verify(mockMemory.get<String>('key')).called(1);
      verify(mockHive.get<String>('key')).called(1);
    });
  });
}
```

## 📈 성공 지표

### 정량적 지표
| 지표 | 현재 | 목표 | 측정 방법 |
|------|------|------|----------|
| **역방향 의존성** | 3개 | 0개 | 의존성 그래프 분석 |
| **테스트 커버리지** | 40% | 80% | Coverage 리포트 |
| **Mock 가능성** | 불가 | 100% | 단위 테스트 작성 |
| **Feature 독립성** | 낮음 | 높음 | 변경 영향 분석 |

### 정성적 지표
- ✅ Services Layer가 Backend 모델을 직접 알지 못함
- ✅ Feature별 캐시 전략 독립적 관리
- ✅ DI를 통한 유연한 구성
- ✅ 테스트 가능한 구조

## 🚀 실행 계획

### Week 1: 구조 개선
- [ ] Day 1-2: 인터페이스 정의
- [ ] Day 3-4: 레이어 구현 분리
- [ ] Day 5: Feature 어댑터 설계

### Week 2: 통합 및 테스트
- [ ] Day 6-7: 어댑터 구현
- [ ] Day 8: DI 통합
- [ ] Day 9-10: 마이그레이션 및 테스트

## ⚠️ 리스크 및 대응

### Risk 1: Feature팀 협업 필요
**문제**: 어댑터 구현 시 Feature팀과 협의 필요  
**대응**: 
- 인터페이스 먼저 정의하여 병렬 작업
- Feature별 담당자 지정
- 점진적 마이그레이션

### Risk 2: 성능 저하
**문제**: 추가 추상화로 인한 오버헤드  
**대응**:
- 벤치마크 테스트 수행
- Hot path 최적화
- 필요시 인라인 처리

### Risk 3: 기존 코드 호환성
**문제**: 많은 곳에서 UnifiedCacheService 사용  
**대응**:
- Deprecated 마킹으로 점진적 전환
- Facade 패턴으로 호환성 유지
- 마이그레이션 가이드 제공

## 🏁 체크리스트

### 마이그레이션 전
- [ ] 현재 의존성 그래프 작성
- [ ] Feature팀과 협의
- [ ] 테스트 환경 준비

### 마이그레이션 중
- [ ] 인터페이스 정의
- [ ] 레이어 구현
- [ ] 어댑터 구현
- [ ] DI 설정
- [ ] 테스트 작성

### 마이그레이션 후
- [ ] 역방향 의존성 검증
- [ ] 성능 테스트
- [ ] 문서 업데이트
- [ ] 팀 교육

---

*이 문서는 Cache Service의 Services Layer 내 Clean Architecture 적용 계획입니다.*  
*Services Layer는 유지하되, 내부적으로 Clean Architecture를 적용합니다.*