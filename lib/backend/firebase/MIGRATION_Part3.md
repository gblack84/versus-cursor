# 🔄 Firebase 백엔드 마이그레이션 계획 Part 3

> Firebase 레이어 리팩토링 및 Feature-First Architecture 적용  
> 작성일: 2025-08-28 | 예상 기간: 5일

## 📌 Executive Summary

**현재 상황**: 264줄의 분산된 유틸리티 코드, 하드코딩된 API 키, 테스트 0%  
**목표**: 안전하고 확장 가능한 Firebase 인프라 구축  
**방법**: 환경 분리, 서비스 추상화, DI 적용, 타입 안전성 강화

## 🎯 마이그레이션 목표

### Before (현재)
```
lib/backend/firebase/
├── config/firebase_config.dart      # API 키 하드코딩
├── firestore/utils/               # 유틸리티 분산
└── storage/storage.dart           # 에러 처리 미흡
```

### After (목표)
```
lib/backend/firebase/
├── core/                          # 핵심 인프라
│   ├── config/
│   │   ├── firebase_config.dart   # 환경별 설정
│   │   ├── environment.dart       # 환경 변수 관리
│   │   └── firebase_options.dart  # 플랫폼별 옵션
│   ├── interfaces/
│   │   ├── i_firebase_service.dart
│   │   ├── i_firestore_service.dart
│   │   └── i_storage_service.dart
│   └── exceptions/
│       └── firebase_exceptions.dart
├── services/                      # 서비스 구현
│   ├── firebase_service.dart      # 초기화 서비스
│   ├── firestore_service.dart     # Firestore 래퍼
│   └── storage_service.dart       # Storage 래퍼
├── utils/                         # 유틸리티
│   ├── converters/
│   │   ├── timestamp_converter.dart
│   │   ├── geopoint_converter.dart
│   │   └── color_converter.dart
│   └── serializers/
│       ├── base_serializer.dart
│       └── firestore_serializer.dart
└── di/                           # 의존성 주입
    └── firebase_di.dart
```

## 📊 현재 문제점 분석

### 1. 보안 문제 심각도: 🔴 높음
```dart
// 현재: API 키 하드코딩
apiKey: "AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY"
```

**영향 분석**:
- API 키 GitHub 노출
- 환경별 설정 불가능
- 보안 감사 실패

### 2. 구조적 문제 심각도: 🟡 중간
```dart
// schema_util.dart의 잘못된 의존성
import '/features/search/data/services/serialization_util.dart';
```

**영향 분석**:
- Backend가 Feature에 의존 (역방향)
- 순환 의존성 위험
- 모듈 독립성 훼손

### 3. 타입 안전성 부족 심각도: 🟡 중간
```dart
// 과도한 dynamic 사용
dynamic convertAlgoliaStruct<T>(dynamic data, ...)
List<T>? getDataList<T>(dynamic value)
```

**영향 분석**:
- 런타임 에러 가능성
- IDE 자동완성 미지원
- 리팩토링 어려움

### 4. 테스트 부재 심각도: 🟡 중간
```
테스트 커버리지: 0%
Mock 구현: 없음
Emulator 설정: 없음
```

## 📝 상세 마이그레이션 단계

### Day 1: 환경 설정 및 인터페이스 정의

#### 1.1 환경 변수 설정
```dart
// core/config/environment.dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static Environment _currentEnv = Environment.development;
  
  static void setEnvironment(Environment env) {
    _currentEnv = env;
  }
  
  static String get apiKey {
    switch (_currentEnv) {
      case Environment.development:
        return const String.fromEnvironment('DEV_API_KEY');
      case Environment.staging:
        return const String.fromEnvironment('STAGING_API_KEY');
      case Environment.production:
        return const String.fromEnvironment('PROD_API_KEY');
    }
  }
  
  static String get projectId {
    switch (_currentEnv) {
      case Environment.development:
        return 'versus-space-dev';
      case Environment.staging:
        return 'versus-space-staging';
      case Environment.production:
        return 'versus-space-1lwwiw';
    }
  }
}
```

#### 1.2 Firebase 서비스 인터페이스
```dart
// core/interfaces/i_firebase_service.dart
abstract class IFirebaseService {
  Future<void> initialize();
  bool get isInitialized;
  String get projectId;
  
  // 서비스 접근자
  IFirestoreService get firestore;
  IStorageService get storage;
  // Auth, Functions 등 추가 가능
}

// core/interfaces/i_firestore_service.dart
abstract class IFirestoreService {
  // 기본 CRUD
  Future<T?> get<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromJson,
  });
  
  Future<List<T>> getCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromJson,
  });
  
  Future<void> set<T>({
    required String collection,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  });
  
  Future<void> update({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  });
  
  Future<void> delete({
    required String collection,
    required String documentId,
  });
  
  // 스트림 지원
  Stream<T?> documentStream<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromJson,
  });
}

// core/interfaces/i_storage_service.dart
abstract class IStorageService {
  Future<String?> uploadFile({
    required String path,
    required Uint8List data,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  });
  
  Future<void> deleteFile(String path);
  Future<Uint8List?> downloadFile(String path);
  Future<String?> getDownloadUrl(String path);
}
```

#### 작업 항목
- [ ] environment.dart 생성 (30분)
- [ ] 인터페이스 3개 생성 (1시간)
- [ ] 기존 firebase_config.dart 수정 (30분)
- [ ] .env 파일 설정 및 .gitignore 추가 (15분)

### Day 2: Converter 시스템 구축

#### 2.1 타임스탬프 변환기
```dart
// utils/converters/timestamp_converter.dart
class TimestampConverter {
  static DateTime? fromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
  
  static dynamic toFirestore(DateTime? value) {
    return value; // Firestore SDK가 자동 변환
  }
  
  static List<DateTime>? listFromFirestore(dynamic value) {
    if (value == null || value is! List) return null;
    return value
        .map((e) => fromFirestore(e))
        .where((e) => e != null)
        .cast<DateTime>()
        .toList();
  }
}
```

#### 2.2 GeoPoint 변환기
```dart
// utils/converters/geopoint_converter.dart
class GeoPointConverter {
  static LatLng? fromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is GeoPoint) {
      return LatLng(value.latitude, value.longitude);
    }
    if (value is Map && value['latitude'] != null) {
      return LatLng(value['latitude'], value['longitude']);
    }
    return null;
  }
  
  static GeoPoint? toFirestore(LatLng? value) {
    if (value == null) return null;
    return GeoPoint(value.latitude, value.longitude);
  }
}
```

#### 2.3 Color 변환기
```dart
// utils/converters/color_converter.dart
class ColorConverter {
  static Color? fromFirestore(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return fromCssColor(value);
      } catch (_) {
        // HEX 형식 시도
        if (value.startsWith('#')) {
          return Color(int.parse(value.substring(1), radix: 16));
        }
      }
    }
    if (value is int) return Color(value);
    return null;
  }
  
  static String? toFirestore(Color? value) {
    return value?.toCssString();
  }
}
```

#### 2.4 통합 Serializer
```dart
// utils/serializers/firestore_serializer.dart
class FirestoreSerializer {
  static Map<String, dynamic> toFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      // DateTime 처리
      if (value is DateTime) {
        return MapEntry(key, value);
      }
      // LatLng 처리
      if (value is LatLng) {
        return MapEntry(key, GeoPointConverter.toFirestore(value));
      }
      // Color 처리
      if (value is Color) {
        return MapEntry(key, ColorConverter.toFirestore(value));
      }
      // 중첩 Map 재귀 처리
      if (value is Map<String, dynamic>) {
        return MapEntry(key, toFirestore(value));
      }
      // List 처리
      if (value is List) {
        return MapEntry(key, _serializeList(value));
      }
      return MapEntry(key, value);
    });
  }
  
  static Map<String, dynamic> fromFirestore(Map<String, dynamic> data) {
    return data.map((key, value) {
      // Timestamp 처리
      if (value is Timestamp) {
        return MapEntry(key, TimestampConverter.fromFirestore(value));
      }
      // GeoPoint 처리
      if (value is GeoPoint) {
        return MapEntry(key, GeoPointConverter.fromFirestore(value));
      }
      // 중첩 Map 재귀 처리
      if (value is Map<String, dynamic>) {
        return MapEntry(key, fromFirestore(value));
      }
      // List 처리
      if (value is List) {
        return MapEntry(key, _deserializeList(value));
      }
      return MapEntry(key, value);
    });
  }
  
  static List _serializeList(List list) {
    return list.map((item) {
      if (item is DateTime) return item;
      if (item is LatLng) return GeoPointConverter.toFirestore(item);
      if (item is Color) return ColorConverter.toFirestore(item);
      if (item is Map<String, dynamic>) return toFirestore(item);
      return item;
    }).toList();
  }
  
  static List _deserializeList(List list) {
    return list.map((item) {
      if (item is Timestamp) return TimestampConverter.fromFirestore(item);
      if (item is GeoPoint) return GeoPointConverter.fromFirestore(item);
      if (item is Map<String, dynamic>) return fromFirestore(item);
      return item;
    }).toList();
  }
}
```

#### 작업 항목
- [ ] 3개 Converter 클래스 생성 (1.5시간)
- [ ] FirestoreSerializer 구현 (1시간)
- [ ] 기존 mapFromFirestore/mapToFirestore 대체 (30분)
- [ ] 단위 테스트 작성 (1시간)

### Day 3: 서비스 구현

#### 3.1 Firebase 서비스
```dart
// services/firebase_service.dart
class FirebaseService implements IFirebaseService {
  static FirebaseService? _instance;
  
  late final IFirestoreService _firestore;
  late final IStorageService _storage;
  bool _isInitialized = false;
  
  FirebaseService._();
  
  factory FirebaseService() {
    return _instance ??= FirebaseService._();
  }
  
  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final options = _getFirebaseOptions();
      
      if (kIsWeb) {
        await Firebase.initializeApp(options: options);
      } else {
        await Firebase.initializeApp();
      }
      
      // 서비스 초기화
      _firestore = FirestoreService();
      _storage = StorageService();
      
      _isInitialized = true;
      
      debugPrint('✅ Firebase initialized: ${options.projectId}');
    } catch (e, stackTrace) {
      throw FirebaseInitializationException(
        'Failed to initialize Firebase',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  FirebaseOptions _getFirebaseOptions() {
    final env = EnvironmentConfig.currentEnvironment;
    
    return FirebaseOptions(
      apiKey: EnvironmentConfig.apiKey,
      authDomain: EnvironmentConfig.authDomain,
      projectId: EnvironmentConfig.projectId,
      storageBucket: EnvironmentConfig.storageBucket,
      messagingSenderId: EnvironmentConfig.messagingSenderId,
      appId: EnvironmentConfig.appId,
    );
  }
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  String get projectId => EnvironmentConfig.projectId;
  
  @override
  IFirestoreService get firestore {
    _ensureInitialized();
    return _firestore;
  }
  
  @override
  IStorageService get storage {
    _ensureInitialized();
    return _storage;
  }
  
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw FirebaseNotInitializedException();
    }
  }
}
```

#### 3.2 Firestore 서비스
```dart
// services/firestore_service.dart
class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Future<T?> get<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final doc = await _firestore
          .collection(collection)
          .doc(documentId)
          .get();
      
      if (!doc.exists) return null;
      
      final data = FirestoreSerializer.fromFirestore(
        doc.data() ?? {},
      );
      
      return fromJson(data);
    } catch (e) {
      throw FirestoreReadException(
        'Failed to get document: $collection/$documentId',
        originalError: e,
      );
    }
  }
  
  @override
  Future<List<T>> getCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>) fromJson,
    Query<Map<String, dynamic>>? Function(Query<Map<String, dynamic>>)? queryBuilder,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection(collection);
      
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) {
        final data = FirestoreSerializer.fromFirestore(
          doc.data(),
        );
        return fromJson(data);
      }).toList();
    } catch (e) {
      throw FirestoreReadException(
        'Failed to get collection: $collection',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> set<T>({
    required String collection,
    required String documentId,
    required T data,
    required Map<String, dynamic> Function(T) toJson,
  }) async {
    try {
      final jsonData = toJson(data);
      final firestoreData = FirestoreSerializer.toFirestore(jsonData);
      
      await _firestore
          .collection(collection)
          .doc(documentId)
          .set(firestoreData);
    } catch (e) {
      throw FirestoreWriteException(
        'Failed to set document: $collection/$documentId',
        originalError: e,
      );
    }
  }
  
  @override
  Stream<T?> documentStream<T>({
    required String collection,
    required String documentId,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    return _firestore
        .collection(collection)
        .doc(documentId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      
      final data = FirestoreSerializer.fromFirestore(
        snapshot.data() ?? {},
      );
      
      return fromJson(data);
    });
  }
}
```

#### 3.3 Storage 서비스
```dart
// services/storage_service.dart
class StorageService implements IStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  @override
  Future<String?> uploadFile({
    required String path,
    required Uint8List data,
    Map<String, String>? metadata,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      
      final uploadMetadata = SettableMetadata(
        contentType: metadata?['contentType'] ?? mime(path),
        customMetadata: metadata,
      );
      
      final uploadTask = ref.putData(data, uploadMetadata);
      
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }
      
      final snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      }
      
      return null;
    } catch (e) {
      throw StorageUploadException(
        'Failed to upload file: $path',
        originalError: e,
      );
    }
  }
  
  @override
  Future<void> deleteFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.delete();
    } catch (e) {
      throw StorageDeleteException(
        'Failed to delete file: $path',
        originalError: e,
      );
    }
  }
  
  @override
  Future<Uint8List?> downloadFile(String path) async {
    try {
      final ref = _storage.ref().child(path);
      const maxSize = 100 * 1024 * 1024; // 100MB
      return await ref.getData(maxSize);
    } catch (e) {
      throw StorageDownloadException(
        'Failed to download file: $path',
        originalError: e,
      );
    }
  }
}
```

#### 작업 항목
- [ ] FirebaseService 구현 (1.5시간)
- [ ] FirestoreService 구현 (2시간)
- [ ] StorageService 구현 (1.5시간)
- [ ] Exception 클래스들 생성 (30분)

### Day 4: DI 통합 및 마이그레이션

#### 4.1 DI 설정
```dart
// di/firebase_di.dart
import 'package:get_it/get_it.dart';

class FirebaseDI {
  static final GetIt _getIt = GetIt.instance;
  
  static void configureDependencies() {
    // 환경 설정
    _getIt.registerLazySingleton<EnvironmentConfig>(
      () => EnvironmentConfig(),
    );
    
    // Firebase 서비스
    _getIt.registerLazySingleton<IFirebaseService>(
      () => FirebaseService(),
    );
    
    // Firestore 서비스
    _getIt.registerLazySingleton<IFirestoreService>(
      () => FirestoreService(),
    );
    
    // Storage 서비스
    _getIt.registerLazySingleton<IStorageService>(
      () => StorageService(),
    );
    
    // Converter들
    _getIt.registerFactory(() => TimestampConverter());
    _getIt.registerFactory(() => GeoPointConverter());
    _getIt.registerFactory(() => ColorConverter());
    
    // Serializer
    _getIt.registerFactory(() => FirestoreSerializer());
  }
  
  static T get<T extends Object>() => _getIt<T>();
}
```

#### 4.2 기존 코드 마이그레이션
```dart
// 기존 코드 대체
// Before (firestore_util.dart)
Map<String, dynamic> mapFromFirestore(Map<String, dynamic> data) { ... }

// After (FirestoreSerializer 사용)
final data = FirestoreSerializer.fromFirestore(rawData);

// Before (storage.dart)
Future<String?> uploadData(String path, Uint8List data) { ... }

// After (IStorageService 사용)
final storage = FirebaseDI.get<IStorageService>();
final url = await storage.uploadFile(path: path, data: data);
```

#### 4.3 Feature 모듈 업데이트
```dart
// features/posts/data/datasources/posts_remote_datasource.dart
class PostsRemoteDataSource {
  final IFirestoreService _firestore;
  
  PostsRemoteDataSource({
    IFirestoreService? firestore,
  }) : _firestore = firestore ?? FirebaseDI.get<IFirestoreService>();
  
  Future<PostModel?> getPost(String postId) {
    return _firestore.get<PostModel>(
      collection: 'posts',
      documentId: postId,
      fromJson: PostModel.fromJson,
    );
  }
  
  Future<void> createPost(PostModel post) {
    return _firestore.set(
      collection: 'posts',
      documentId: post.id,
      data: post,
      toJson: (p) => p.toJson(),
    );
  }
}
```

#### 작업 항목
- [ ] DI 설정 파일 생성 (30분)
- [ ] main.dart 업데이트 (15분)
- [ ] 기존 코드 점진적 마이그레이션 (3시간)
- [ ] Feature 모듈 예시 업데이트 (1시간)

### Day 5: 테스트 및 문서화

#### 5.1 단위 테스트
```dart
// test/backend/firebase/utils/converters/timestamp_converter_test.dart
void main() {
  group('TimestampConverter', () {
    test('Timestamp를 DateTime으로 변환', () {
      final timestamp = Timestamp.now();
      final result = TimestampConverter.fromFirestore(timestamp);
      
      expect(result, isA<DateTime>());
      expect(result?.millisecondsSinceEpoch, 
        timestamp.toDate().millisecondsSinceEpoch);
    });
    
    test('null 값 처리', () {
      final result = TimestampConverter.fromFirestore(null);
      expect(result, isNull);
    });
    
    test('DateTime은 그대로 반환', () {
      final now = DateTime.now();
      final result = TimestampConverter.fromFirestore(now);
      expect(result, equals(now));
    });
  });
}
```

#### 5.2 통합 테스트
```dart
// test/backend/firebase/services/firestore_service_test.dart
void main() {
  late FirestoreService service;
  late FirebaseFirestore firestore;
  
  setUpAll(() async {
    // Firebase Emulator 설정
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator('localhost', 8080);
    
    service = FirestoreService();
  });
  
  group('FirestoreService', () {
    test('문서 생성 및 조회', () async {
      final testData = {
        'title': 'Test Post',
        'createdAt': DateTime.now(),
        'location': LatLng(37.5, 127.0),
      };
      
      // 생성
      await service.set(
        collection: 'test_posts',
        documentId: 'test_1',
        data: testData,
        toJson: (data) => data,
      );
      
      // 조회
      final result = await service.get(
        collection: 'test_posts',
        documentId: 'test_1',
        fromJson: (json) => json,
      );
      
      expect(result?['title'], equals('Test Post'));
      expect(result?['createdAt'], isA<DateTime>());
      expect(result?['location'], isA<LatLng>());
    });
  });
}
```

#### 5.3 Firebase Emulator 설정
```json
// firebase.json
{
  "emulators": {
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

#### 작업 항목
- [ ] Converter 단위 테스트 (1.5시간)
- [ ] Service 통합 테스트 (2시간)
- [ ] Firebase Emulator 설정 (30분)
- [ ] 문서 업데이트 (1시간)

## 📋 체크리스트

### Day 1 ✅
- [ ] 환경 변수 시스템 구축
- [ ] 인터페이스 정의
- [ ] 보안 설정 개선

### Day 2 ✅
- [ ] Converter 시스템 구현
- [ ] Serializer 통합
- [ ] 타입 안전성 강화

### Day 3 ✅
- [ ] Firebase Service 구현
- [ ] Firestore Service 구현
- [ ] Storage Service 구현

### Day 4 ✅
- [ ] DI 통합
- [ ] 기존 코드 마이그레이션
- [ ] Feature 모듈 연동

### Day 5 ✅
- [ ] 테스트 작성
- [ ] 문서 업데이트
- [ ] 성능 검증

## 🎯 성공 지표

| 지표 | 현재 | 목표 | 검증 방법 |
|-----|------|------|----------|
| **API 키 보안** | 하드코딩 | 환경 변수 | .env 파일 확인 |
| **테스트 커버리지** | 0% | 80% | coverage 리포트 |
| **타입 안전성** | 60% | 95% | strict mode 활성화 |
| **의존성 역전** | ❌ | ✅ | DI 컨테이너 확인 |
| **환경 분리** | ❌ | ✅ | 3개 환경 테스트 |

## ⚠️ 리스크 관리

### 리스크 1: 기존 코드 호환성
- **영향**: 모든 Feature 모듈 영향
- **대응**: 점진적 마이그레이션, 하위 호환성 유지

### 리스크 2: 성능 저하
- **영향**: 추상화로 인한 오버헤드
- **대응**: 프로파일링, 캐싱 전략

### 리스크 3: 테스트 복잡도
- **영향**: Emulator 설정 어려움
- **대응**: 상세 가이드 작성, CI/CD 통합

## 📌 마이그레이션 우선순위

1. **긴급**: API 키 보안 (Day 1)
2. **높음**: 타입 안전성 (Day 2)
3. **중간**: 서비스 추상화 (Day 3)
4. **낮음**: 테스트 구축 (Day 5)

## 🔍 검증 계획

### Phase 1: 개발 환경 (Day 3)
- Firebase Emulator에서 전체 테스트
- 기존 기능 동작 확인

### Phase 2: 스테이징 (Day 4)
- 실제 Firebase 프로젝트 연동
- 성능 벤치마크

### Phase 3: 프로덕션 (Day 5)
- 점진적 롤아웃
- 모니터링 및 롤백 준비

---

*이 문서는 Firebase 백엔드 레이어의 5일 마이그레이션 계획을 담고 있습니다.*  
*Feature-First Architecture 원칙에 따라 안전하고 확장 가능한 구조로 전환합니다.*