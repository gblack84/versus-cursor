# 🧪 Firebase 백엔드 테스트 가이드

> Firebase 레이어의 포괄적 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 80%+

## 📋 테스트 전략 개요

### 테스트 피라미드
```
        E2E Tests (10%)
       /              \
    Integration (30%)
   /                    \
  Unit Tests (60%)
 /                        \
━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 커버리지 목표
- **전체 목표**: 80% 이상
- **단위 테스트**: 90% (Converters, Serializers)
- **통합 테스트**: 70% (Services, DI)
- **E2E 테스트**: 50% (실제 Firebase 연동)

## 🎯 테스트 범위

### Firebase 레이어 테스트
```
backend/firebase/
├── core/config/        → 환경 설정 테스트
├── utils/converters/   → 타입 변환 테스트
├── services/          → 서비스 로직 테스트
└── di/                → 의존성 주입 테스트
```

## 🔧 테스트 환경 설정

### 1. Firebase Emulator 설치
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# 프로젝트 초기화
firebase init emulators

# Emulator 시작
firebase emulators:start
```

### 2. firebase.json 설정
```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    },
    "singleProjectMode": true
  }
}
```

### 3. 테스트 헬퍼 설정
```dart
// test/helpers/firebase_test_helper.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseTestHelper {
  static bool _initialized = false;
  
  static Future<void> initializeTestEnvironment() async {
    if (_initialized) return;
    
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project',
        storageBucket: 'test-bucket',
      ),
    );
    
    // Emulator 연결
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
    FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    
    _initialized = true;
  }
  
  static Future<void> clearFirestore() async {
    final firestore = FirebaseFirestore.instance;
    
    // 모든 컬렉션 삭제
    await firestore.terminate();
    await firestore.clearPersistence();
  }
  
  static Future<void> clearStorage() async {
    // Storage는 Emulator UI에서 수동 삭제 또는
    // 특정 경로 삭제 로직 구현
  }
}
```

## 📝 단위 테스트

### 1. Converter 테스트

#### TimestampConverter 테스트
```dart
// test/backend/firebase/utils/converters/timestamp_converter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/backend/firebase/utils/converters/timestamp_converter.dart';

void main() {
  group('TimestampConverter', () {
    group('fromFirestore', () {
      test('Timestamp를 DateTime으로 변환', () {
        final now = DateTime.now();
        final timestamp = Timestamp.fromDate(now);
        
        final result = TimestampConverter.fromFirestore(timestamp);
        
        expect(result, isNotNull);
        expect(result!.millisecondsSinceEpoch, 
          equals(now.millisecondsSinceEpoch));
      });
      
      test('null 값은 null 반환', () {
        final result = TimestampConverter.fromFirestore(null);
        expect(result, isNull);
      });
      
      test('DateTime은 그대로 반환', () {
        final now = DateTime.now();
        final result = TimestampConverter.fromFirestore(now);
        expect(result, equals(now));
      });
      
      test('문자열 ISO8601 파싱', () {
        final dateString = '2025-08-28T10:30:00.000Z';
        final result = TimestampConverter.fromFirestore(dateString);
        
        expect(result, isNotNull);
        expect(result!.toIso8601String(), contains('2025-08-28'));
      });
      
      test('잘못된 타입은 null 반환', () {
        final result = TimestampConverter.fromFirestore(12345);
        expect(result, isNull);
      });
    });
    
    group('listFromFirestore', () {
      test('Timestamp 리스트 변환', () {
        final dates = [
          DateTime(2025, 1, 1),
          DateTime(2025, 1, 2),
          DateTime(2025, 1, 3),
        ];
        
        final timestamps = dates.map((d) => 
          Timestamp.fromDate(d)).toList();
        
        final result = TimestampConverter.listFromFirestore(timestamps);
        
        expect(result, isNotNull);
        expect(result!.length, equals(3));
        expect(result[0].year, equals(2025));
        expect(result[1].month, equals(1));
        expect(result[2].day, equals(3));
      });
      
      test('null 값은 필터링', () {
        final mixed = [
          Timestamp.now(),
          null,
          Timestamp.now(),
        ];
        
        final result = TimestampConverter.listFromFirestore(mixed);
        
        expect(result, isNotNull);
        expect(result!.length, equals(2));
      });
    });
  });
}
```

#### GeoPointConverter 테스트
```dart
// test/backend/firebase/utils/converters/geopoint_converter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:versus_space/backend/firebase/utils/converters/geopoint_converter.dart';
import 'package:versus_space/core/utils/lat_lng.dart';

void main() {
  group('GeoPointConverter', () {
    group('fromFirestore', () {
      test('GeoPoint를 LatLng로 변환', () {
        final geoPoint = GeoPoint(37.5665, 126.9780);
        final result = GeoPointConverter.fromFirestore(geoPoint);
        
        expect(result, isNotNull);
        expect(result!.latitude, equals(37.5665));
        expect(result.longitude, equals(126.9780));
      });
      
      test('Map 형식 지원', () {
        final map = {
          'latitude': 37.5665,
          'longitude': 126.9780,
        };
        
        final result = GeoPointConverter.fromFirestore(map);
        
        expect(result, isNotNull);
        expect(result!.latitude, equals(37.5665));
        expect(result.longitude, equals(126.9780));
      });
      
      test('null 값은 null 반환', () {
        final result = GeoPointConverter.fromFirestore(null);
        expect(result, isNull);
      });
    });
    
    group('toFirestore', () {
      test('LatLng를 GeoPoint로 변환', () {
        final latLng = LatLng(37.5665, 126.9780);
        final result = GeoPointConverter.toFirestore(latLng);
        
        expect(result, isNotNull);
        expect(result!.latitude, equals(37.5665));
        expect(result.longitude, equals(126.9780));
      });
      
      test('null 값은 null 반환', () {
        final result = GeoPointConverter.toFirestore(null);
        expect(result, isNull);
      });
    });
  });
}
```

#### ColorConverter 테스트
```dart
// test/backend/firebase/utils/converters/color_converter_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/backend/firebase/utils/converters/color_converter.dart';

void main() {
  group('ColorConverter', () {
    group('fromFirestore', () {
      test('CSS 색상 문자열 파싱', () {
        final cssColor = 'rgb(255, 0, 0)';
        final result = ColorConverter.fromFirestore(cssColor);
        
        expect(result, isNotNull);
        expect(result!.red, equals(255));
        expect(result.green, equals(0));
        expect(result.blue, equals(0));
      });
      
      test('HEX 색상 문자열 파싱', () {
        final hexColor = '#FF0000';
        final result = ColorConverter.fromFirestore(hexColor);
        
        expect(result, isNotNull);
        expect(result!.red, equals(255));
        expect(result.green, equals(0));
        expect(result.blue, equals(0));
      });
      
      test('int 값 파싱', () {
        final intColor = 0xFFFF0000; // Red with full opacity
        final result = ColorConverter.fromFirestore(intColor);
        
        expect(result, isNotNull);
        expect(result, equals(Colors.red));
      });
      
      test('null 값은 null 반환', () {
        final result = ColorConverter.fromFirestore(null);
        expect(result, isNull);
      });
    });
    
    group('toFirestore', () {
      test('Color를 CSS 문자열로 변환', () {
        final color = Colors.red;
        final result = ColorConverter.toFirestore(color);
        
        expect(result, isNotNull);
        expect(result, contains('rgb'));
      });
      
      test('null 값은 null 반환', () {
        final result = ColorConverter.toFirestore(null);
        expect(result, isNull);
      });
    });
  });
}
```

### 2. Serializer 테스트

```dart
// test/backend/firebase/utils/serializers/firestore_serializer_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:versus_space/backend/firebase/utils/serializers/firestore_serializer.dart';
import 'package:versus_space/core/utils/lat_lng.dart';

void main() {
  group('FirestoreSerializer', () {
    group('toFirestore', () {
      test('복합 데이터 구조 직렬화', () {
        final data = {
          'title': 'Test Post',
          'createdAt': DateTime(2025, 8, 28),
          'location': LatLng(37.5, 127.0),
          'color': Colors.blue,
          'tags': ['tag1', 'tag2'],
          'metadata': {
            'views': 100,
            'likes': 50,
          },
        };
        
        final result = FirestoreSerializer.toFirestore(data);
        
        expect(result['title'], equals('Test Post'));
        expect(result['createdAt'], isA<DateTime>());
        expect(result['location'], isA<GeoPoint>());
        expect(result['color'], isA<String>());
        expect(result['tags'], equals(['tag1', 'tag2']));
        expect(result['metadata']['views'], equals(100));
      });
      
      test('중첩된 Map 재귀 처리', () {
        final data = {
          'level1': {
            'level2': {
              'level3': {
                'value': 'deep',
                'timestamp': DateTime.now(),
              },
            },
          },
        };
        
        final result = FirestoreSerializer.toFirestore(data);
        
        expect(result['level1']['level2']['level3']['value'], 
          equals('deep'));
        expect(result['level1']['level2']['level3']['timestamp'], 
          isA<DateTime>());
      });
      
      test('List 내부 객체 변환', () {
        final data = {
          'locations': [
            LatLng(37.5, 127.0),
            LatLng(37.6, 127.1),
          ],
          'dates': [
            DateTime(2025, 1, 1),
            DateTime(2025, 1, 2),
          ],
        };
        
        final result = FirestoreSerializer.toFirestore(data);
        
        expect(result['locations'][0], isA<GeoPoint>());
        expect(result['locations'][1], isA<GeoPoint>());
        expect(result['dates'][0], isA<DateTime>());
        expect(result['dates'][1], isA<DateTime>());
      });
    });
    
    group('fromFirestore', () {
      test('Firestore 데이터 역직렬화', () {
        final firestoreData = {
          'title': 'Test',
          'timestamp': Timestamp.fromDate(DateTime(2025, 8, 28)),
          'location': GeoPoint(37.5, 127.0),
          'nested': {
            'timestamp': Timestamp.now(),
          },
        };
        
        final result = FirestoreSerializer.fromFirestore(firestoreData);
        
        expect(result['title'], equals('Test'));
        expect(result['timestamp'], isA<DateTime>());
        expect(result['location'], isA<LatLng>());
        expect(result['nested']['timestamp'], isA<DateTime>());
      });
    });
  });
}
```

## 🔄 통합 테스트

### 1. Firebase Service 테스트

```dart
// test/backend/firebase/services/firebase_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/backend/firebase/services/firebase_service.dart';
import 'package:versus_space/backend/firebase/core/config/environment.dart';
import '../helpers/firebase_test_helper.dart';

void main() {
  late FirebaseService service;
  
  setUpAll(() async {
    await FirebaseTestHelper.initializeTestEnvironment();
    EnvironmentConfig.setEnvironment(Environment.test);
    service = FirebaseService();
  });
  
  group('FirebaseService', () {
    test('초기화 테스트', () async {
      await service.initialize();
      
      expect(service.isInitialized, isTrue);
      expect(service.projectId, equals('test-project'));
    });
    
    test('중복 초기화 방지', () async {
      await service.initialize();
      await service.initialize(); // 두 번째 호출
      
      expect(service.isInitialized, isTrue);
      // 에러 없이 정상 처리되어야 함
    });
    
    test('초기화 전 서비스 접근 시 예외', () {
      final uninitializedService = FirebaseService();
      
      expect(
        () => uninitializedService.firestore,
        throwsA(isA<FirebaseNotInitializedException>()),
      );
      
      expect(
        () => uninitializedService.storage,
        throwsA(isA<FirebaseNotInitializedException>()),
      );
    });
  });
}
```

### 2. Firestore Service 테스트

```dart
// test/backend/firebase/services/firestore_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:versus_space/backend/firebase/services/firestore_service.dart';
import '../helpers/firebase_test_helper.dart';

void main() {
  late FirestoreService service;
  late FakeFirebaseFirestore fakeFirestore;
  
  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = FirestoreService(firestore: fakeFirestore);
  });
  
  group('FirestoreService', () {
    group('CRUD Operations', () {
      test('문서 생성 및 조회', () async {
        // 테스트 데이터
        final testData = {
          'id': 'test_1',
          'title': 'Test Document',
          'createdAt': DateTime.now(),
          'tags': ['tag1', 'tag2'],
        };
        
        // 생성
        await service.set(
          collection: 'test_collection',
          documentId: 'test_1',
          data: testData,
          toJson: (data) => data,
        );
        
        // 조회
        final result = await service.get(
          collection: 'test_collection',
          documentId: 'test_1',
          fromJson: (json) => json,
        );
        
        expect(result, isNotNull);
        expect(result!['title'], equals('Test Document'));
        expect(result['tags'], equals(['tag1', 'tag2']));
      });
      
      test('존재하지 않는 문서 조회', () async {
        final result = await service.get(
          collection: 'test_collection',
          documentId: 'non_existent',
          fromJson: (json) => json,
        );
        
        expect(result, isNull);
      });
      
      test('문서 업데이트', () async {
        // 초기 데이터
        await service.set(
          collection: 'test_collection',
          documentId: 'test_1',
          data: {'title': 'Original', 'count': 0},
          toJson: (data) => data,
        );
        
        // 업데이트
        await service.update(
          collection: 'test_collection',
          documentId: 'test_1',
          data: {'title': 'Updated', 'count': 10},
        );
        
        // 확인
        final result = await service.get(
          collection: 'test_collection',
          documentId: 'test_1',
          fromJson: (json) => json,
        );
        
        expect(result!['title'], equals('Updated'));
        expect(result['count'], equals(10));
      });
      
      test('문서 삭제', () async {
        // 생성
        await service.set(
          collection: 'test_collection',
          documentId: 'test_1',
          data: {'title': 'To Delete'},
          toJson: (data) => data,
        );
        
        // 삭제
        await service.delete(
          collection: 'test_collection',
          documentId: 'test_1',
        );
        
        // 확인
        final result = await service.get(
          collection: 'test_collection',
          documentId: 'test_1',
          fromJson: (json) => json,
        );
        
        expect(result, isNull);
      });
    });
    
    group('Collection Operations', () {
      test('컬렉션 조회', () async {
        // 여러 문서 생성
        for (int i = 0; i < 5; i++) {
          await service.set(
            collection: 'test_collection',
            documentId: 'doc_$i',
            data: {'index': i, 'title': 'Document $i'},
            toJson: (data) => data,
          );
        }
        
        // 컬렉션 조회
        final results = await service.getCollection(
          collection: 'test_collection',
          fromJson: (json) => json,
        );
        
        expect(results.length, equals(5));
        expect(results[0]['title'], contains('Document'));
      });
      
      test('쿼리 빌더 사용', () async {
        // 데이터 준비
        for (int i = 0; i < 10; i++) {
          await service.set(
            collection: 'test_collection',
            documentId: 'doc_$i',
            data: {'score': i * 10},
            toJson: (data) => data,
          );
        }
        
        // 쿼리: score >= 50
        final results = await service.getCollection(
          collection: 'test_collection',
          fromJson: (json) => json,
          queryBuilder: (query) => query.where('score', isGreaterThanOrEqualTo: 50),
        );
        
        expect(results.length, equals(5));
        expect(results.every((doc) => doc['score'] >= 50), isTrue);
      });
    });
    
    group('Stream Operations', () {
      test('문서 스트림', () async {
        // 초기 데이터
        await service.set(
          collection: 'test_collection',
          documentId: 'stream_test',
          data: {'value': 1},
          toJson: (data) => data,
        );
        
        // 스트림 구독
        final stream = service.documentStream(
          collection: 'test_collection',
          documentId: 'stream_test',
          fromJson: (json) => json,
        );
        
        // 변경 감지
        int updateCount = 0;
        final subscription = stream.listen((data) {
          if (data != null) {
            updateCount++;
          }
        });
        
        // 업데이트
        await service.update(
          collection: 'test_collection',
          documentId: 'stream_test',
          data: {'value': 2},
        );
        
        await Future.delayed(Duration(milliseconds: 100));
        
        expect(updateCount, greaterThan(0));
        
        await subscription.cancel();
      });
    });
  });
}
```

### 3. Storage Service 테스트

```dart
// test/backend/firebase/services/storage_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:versus_space/backend/firebase/services/storage_service.dart';
import 'dart:typed_data';

@GenerateMocks([FirebaseStorage, Reference, UploadTask, TaskSnapshot])
import 'storage_service_test.mocks.dart';

void main() {
  late StorageService service;
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;
  late MockUploadTask mockUploadTask;
  late MockTaskSnapshot mockSnapshot;
  
  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    mockUploadTask = MockUploadTask();
    mockSnapshot = MockTaskSnapshot();
    
    service = StorageService(storage: mockStorage);
  });
  
  group('StorageService', () {
    group('uploadFile', () {
      test('파일 업로드 성공', () async {
        // Arrange
        final data = Uint8List.fromList([1, 2, 3, 4, 5]);
        final path = 'test/file.jpg';
        final downloadUrl = 'https://example.com/file.jpg';
        
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(path)).thenReturn(mockRef);
        when(mockRef.putData(any, any)).thenReturn(mockUploadTask);
        when(mockUploadTask.snapshot).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.state).thenReturn(TaskState.success);
        when(mockSnapshot.ref).thenReturn(mockRef);
        when(mockRef.getDownloadURL()).thenAnswer((_) async => downloadUrl);
        
        // Act
        final result = await service.uploadFile(
          path: path,
          data: data,
        );
        
        // Assert
        expect(result, equals(downloadUrl));
        verify(mockRef.putData(data, any)).called(1);
      });
      
      test('파일 업로드 실패', () async {
        // Arrange
        final data = Uint8List.fromList([1, 2, 3]);
        final path = 'test/file.jpg';
        
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(path)).thenReturn(mockRef);
        when(mockRef.putData(any, any)).thenReturn(mockUploadTask);
        when(mockUploadTask.snapshot).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.state).thenReturn(TaskState.error);
        
        // Act
        final result = await service.uploadFile(
          path: path,
          data: data,
        );
        
        // Assert
        expect(result, isNull);
      });
      
      test('진행률 콜백 호출', () async {
        // Arrange
        final data = Uint8List.fromList([1, 2, 3]);
        final path = 'test/file.jpg';
        final progressValues = <double>[];
        
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(path)).thenReturn(mockRef);
        when(mockRef.putData(any, any)).thenReturn(mockUploadTask);
        
        // Simulate progress events
        when(mockUploadTask.snapshotEvents).thenAnswer((_) => 
          Stream.fromIterable([
            _createMockSnapshot(50, 100),  // 50%
            _createMockSnapshot(100, 100), // 100%
          ])
        );
        
        when(mockUploadTask.snapshot).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.state).thenReturn(TaskState.success);
        when(mockSnapshot.ref).thenReturn(mockRef);
        when(mockRef.getDownloadURL()).thenAnswer((_) async => 'url');
        
        // Act
        await service.uploadFile(
          path: path,
          data: data,
          onProgress: (progress) {
            progressValues.add(progress);
          },
        );
        
        // Assert
        expect(progressValues, isNotEmpty);
        expect(progressValues.last, equals(1.0));
      });
    });
    
    group('deleteFile', () {
      test('파일 삭제 성공', () async {
        // Arrange
        final path = 'test/file.jpg';
        
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(path)).thenReturn(mockRef);
        when(mockRef.delete()).thenAnswer((_) async => null);
        
        // Act & Assert
        await expectLater(
          service.deleteFile(path),
          completes,
        );
        
        verify(mockRef.delete()).called(1);
      });
      
      test('파일 삭제 실패', () async {
        // Arrange
        final path = 'test/file.jpg';
        
        when(mockStorage.ref()).thenReturn(mockRef);
        when(mockRef.child(path)).thenReturn(mockRef);
        when(mockRef.delete()).thenThrow(Exception('Delete failed'));
        
        // Act & Assert
        await expectLater(
          service.deleteFile(path),
          throwsA(isA<StorageDeleteException>()),
        );
      });
    });
  });
  
  TaskSnapshot _createMockSnapshot(int transferred, int total) {
    final snapshot = MockTaskSnapshot();
    when(snapshot.bytesTransferred).thenReturn(transferred);
    when(snapshot.totalBytes).thenReturn(total);
    return snapshot;
  }
}
```

## 🎭 E2E 테스트

### Firebase Emulator를 사용한 E2E 테스트

```dart
// test/e2e/firebase_e2e_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:versus_space/backend/firebase/services/firebase_service.dart';
import 'package:versus_space/backend/firebase/di/firebase_di.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Firebase E2E Tests', () {
    setUpAll(() async {
      // DI 설정
      FirebaseDI.configureDependencies();
      
      // Firebase 초기화
      final firebase = FirebaseDI.get<IFirebaseService>();
      await firebase.initialize();
    });
    
    test('전체 플로우 테스트', () async {
      final firestore = FirebaseDI.get<IFirestoreService>();
      final storage = FirebaseDI.get<IStorageService>();
      
      // 1. 문서 생성
      await firestore.set(
        collection: 'e2e_tests',
        documentId: 'test_doc',
        data: {
          'title': 'E2E Test',
          'timestamp': DateTime.now(),
        },
        toJson: (data) => data,
      );
      
      // 2. 파일 업로드
      final imageData = Uint8List.fromList(List.generate(100, (i) => i));
      final imageUrl = await storage.uploadFile(
        path: 'e2e_tests/image.jpg',
        data: imageData,
      );
      
      expect(imageUrl, isNotNull);
      
      // 3. 문서 업데이트 (이미지 URL 추가)
      await firestore.update(
        collection: 'e2e_tests',
        documentId: 'test_doc',
        data: {'imageUrl': imageUrl},
      );
      
      // 4. 최종 확인
      final result = await firestore.get(
        collection: 'e2e_tests',
        documentId: 'test_doc',
        fromJson: (json) => json,
      );
      
      expect(result!['title'], equals('E2E Test'));
      expect(result['imageUrl'], equals(imageUrl));
      
      // 5. 정리
      await storage.deleteFile('e2e_tests/image.jpg');
      await firestore.delete(
        collection: 'e2e_tests',
        documentId: 'test_doc',
      );
    });
  });
}
```

## 📋 테스트 실행 가이드

### 1. 단위 테스트 실행
```bash
# 모든 단위 테스트
flutter test test/backend/firebase/

# 특정 파일 테스트
flutter test test/backend/firebase/utils/converters/timestamp_converter_test.dart

# 커버리지 리포트 생성
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 2. 통합 테스트 실행
```bash
# Firebase Emulator 시작
firebase emulators:start

# 다른 터미널에서 테스트 실행
flutter test test/backend/firebase/services/
```

### 3. E2E 테스트 실행
```bash
# Emulator와 함께 실행
firebase emulators:exec 'flutter test integration_test'

# 실제 Firebase 환경에서 실행 (주의!)
flutter test integration_test --dart-define=ENV=staging
```

## 🎯 테스트 시나리오

### 시나리오 1: 사용자 프로필 업데이트
```
1. 사용자 정보 조회
2. 프로필 이미지 업로드
3. 사용자 정보 업데이트
4. 업데이트 확인
```

### 시나리오 2: 게시물 생성
```
1. 미디어 파일 업로드
2. 게시물 문서 생성
3. 타임스탬프 및 위치 정보 저장
4. 생성 확인
```

### 시나리오 3: 채팅 메시지
```
1. 채팅방 생성
2. 메시지 전송
3. 파일 첨부
4. 실시간 스트림 확인
```

## 📊 커버리지 목표

### 파일별 목표
| 파일 | 목표 | 우선순위 |
|-----|------|---------|
| timestamp_converter.dart | 95% | 높음 |
| geopoint_converter.dart | 95% | 높음 |
| color_converter.dart | 90% | 중간 |
| firestore_serializer.dart | 90% | 높음 |
| firebase_service.dart | 80% | 높음 |
| firestore_service.dart | 85% | 높음 |
| storage_service.dart | 80% | 중간 |
| environment.dart | 70% | 낮음 |

## ⚠️ 주의사항

### 1. Emulator 사용
- 항상 테스트 환경에서는 Emulator 사용
- 프로덕션 Firebase 접근 차단
- Emulator 데이터는 세션 간 유지되지 않음

### 2. 비동기 테스트
- `async`/`await` 올바른 사용
- Stream 테스트 시 적절한 대기 시간
- 타임아웃 설정

### 3. Mock 사용
- 외부 의존성은 Mock 처리
- 실제 Firebase 호출 최소화
- 테스트 격리성 보장

## 🔗 관련 문서

- [Firebase 백엔드 README](./README.md)
- [마이그레이션 계획](./MIGRATION_Part3.md)
- [Flutter 테스트 공식 문서](https://flutter.dev/docs/testing)
- [Firebase Emulator 가이드](https://firebase.google.com/docs/emulator-suite)

---

*이 문서는 Firebase 백엔드 레이어의 포괄적 테스트 전략을 담고 있습니다.*  
*80% 이상의 테스트 커버리지를 목표로 안정적인 코드 품질을 보장합니다.*