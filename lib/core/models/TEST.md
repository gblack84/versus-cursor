# 🧪 Core Models 테스트 가이드

> 작성일: 2025-08-28 | 대상: Core Models | 목표 커버리지: 95%

## 📋 테스트 전략 개요

Core Models의 테스트는 데이터 무결성, 상태 관리, 파일 업로드 기능을 중점적으로 검증합니다.
마이그레이션 전후 동작 일관성을 보장하고, 95% 이상의 코드 커버리지를 목표로 합니다.

## 🎯 테스트 목표

### 핵심 검증 항목
- ✅ 모델 데이터 무결성
- ✅ 상태 관리 생명주기
- ✅ 파일 업로드 프로세스
- ✅ 폼 컨트롤러 동작
- ✅ 메모리 관리 및 정리

### 품질 기준
- 코드 커버리지: 95% 이상
- 성능: 각 테스트 100ms 이내
- 메모리: 누수 없음
- 신뢰성: Flaky 테스트 0%

## 📁 테스트 구조

```
test/
├── core/
│   └── models/
│       ├── app_model_test.dart
│       ├── form_field_controller_test.dart
│       ├── upload_data_test.dart
│       └── uploaded_file_test.dart
│
├── features/
│   └── upload/
│       ├── unit/
│       │   ├── selected_file_test.dart
│       │   ├── upload_config_test.dart
│       │   └── upload_service_test.dart
│       ├── integration/
│       │   └── upload_flow_test.dart
│       └── widget/
│           └── media_selector_test.dart
│
└── helpers/
    ├── mock_helpers.dart
    ├── test_data.dart
    └── widget_test_helpers.dart
```

## 🔬 단위 테스트

### 1. AppModel 테스트

```dart
// test/core/models/app_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/core/models/app_model.dart';

class TestModel extends AppModel<TestWidget> {
  int counter = 0;
  
  @override
  void initState(BuildContext context) {
    counter = 1;
  }
  
  @override
  void dispose() {
    counter = 0;
  }
}

void main() {
  group('AppModel', () {
    late TestModel model;
    late BuildContext mockContext;
    
    setUp(() {
      model = TestModel();
      mockContext = MockBuildContext();
    });
    
    tearDown(() {
      model.dispose();
    });
    
    group('초기화', () {
      test('initState는 한 번만 호출되어야 함', () {
        model._init(mockContext);
        expect(model.counter, equals(1));
        
        model._init(mockContext);
        expect(model.counter, equals(1)); // 여전히 1
      });
      
      test('context와 widget이 설정되어야 함', () {
        final widget = TestWidget();
        when(mockContext.widget).thenReturn(widget);
        
        model._init(mockContext);
        
        expect(model.context, equals(mockContext));
        expect(model.widget, equals(widget));
      });
    });
    
    group('생명주기', () {
      test('dispose 호출 시 리소스 정리', () {
        model._init(mockContext);
        model.dispose();
        
        expect(model.counter, equals(0));
      });
      
      test('maybeDispose는 설정에 따라 동작', () {
        model.disposeOnWidgetDisposal = false;
        model.maybeDispose();
        expect(model.counter, isNot(equals(0)));
        
        model.disposeOnWidgetDisposal = true;
        model.maybeDispose();
        expect(model.counter, equals(0));
      });
    });
    
    group('업데이트 콜백', () {
      test('updatePage는 콜백을 실행', () {
        var callbackCalled = false;
        var updateCalled = false;
        
        model.setOnUpdate(
          updateOnChange: true,
          onUpdate: () => updateCalled = true,
        );
        
        model.updatePage(() => callbackCalled = true);
        
        expect(callbackCalled, isTrue);
        expect(updateCalled, isTrue);
      });
    });
  });
  
  group('AppDynamicModels', () {
    late AppDynamicModels<TestModel> dynamicModels;
    
    setUp(() {
      dynamicModels = AppDynamicModels(() => TestModel());
    });
    
    tearDown(() {
      dynamicModels.dispose();
    });
    
    test('getModel은 unique key별로 모델 생성', () {
      final model1 = dynamicModels.getModel('key1', 0);
      final model2 = dynamicModels.getModel('key2', 1);
      final model1Again = dynamicModels.getModel('key1', 0);
      
      expect(identical(model1, model1Again), isTrue);
      expect(identical(model1, model2), isFalse);
    });
    
    test('getValues는 인덱스 순서대로 값 반환', () {
      dynamicModels.getModel('key1', 2).counter = 2;
      dynamicModels.getModel('key2', 0).counter = 0;
      dynamicModels.getModel('key3', 1).counter = 1;
      
      final values = dynamicModels.getValues((m) => m.counter);
      
      expect(values, equals([0, 1, 2]));
    });
    
    test('사용하지 않는 모델 자동 정리', () async {
      dynamicModels.getModel('key1', 0);
      dynamicModels.getModel('key2', 1);
      
      // key1만 다시 접근
      dynamicModels.getModel('key1', 0);
      
      // 다음 프레임 대기
      await tester.pump();
      
      // key2는 정리되어야 함
      final model2 = dynamicModels.getValueForKey('key2', (m) => m);
      expect(model2, isNull);
    });
  });
}
```

### 2. FormFieldController 테스트

```dart
// test/core/models/form_field_controller_test.dart
void main() {
  group('FormFieldController', () {
    test('초기값 설정 및 리셋', () {
      final controller = FormFieldController<String>('initial');
      
      expect(controller.value, equals('initial'));
      
      controller.value = 'changed';
      expect(controller.value, equals('changed'));
      
      controller.reset();
      expect(controller.value, equals('initial'));
    });
    
    test('리스너 알림', () {
      final controller = FormFieldController<int>(0);
      var notifyCount = 0;
      
      controller.addListener(() => notifyCount++);
      
      controller.value = 1;
      expect(notifyCount, equals(1));
      
      controller.update();
      expect(notifyCount, equals(2));
    });
  });
  
  group('FormListFieldController', () {
    test('리스트 참조 문제 방지', () {
      final initialList = [1, 2, 3];
      final controller = FormListFieldController<int>(initialList);
      
      // 초기 리스트 수정
      initialList.add(4);
      
      // 컨트롤러 값은 영향받지 않아야 함
      expect(controller.value, equals([1, 2, 3]));
      
      // reset 후에도 원래 값 유지
      controller.value = [5, 6];
      controller.reset();
      expect(controller.value, equals([1, 2, 3]));
    });
  });
}
```

### 3. UploadData 테스트

```dart
// test/core/models/upload_data_test.dart
void main() {
  group('SelectedFile', () {
    test('생성자 테스트', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final dimensions = MediaDimensions(width: 100, height: 200);
      
      final file = SelectedFile(
        storagePath: 'path/to/file',
        filePath: '/local/path',
        bytes: bytes,
        dimensions: dimensions,
        blurHash: 'hash123',
      );
      
      expect(file.storagePath, equals('path/to/file'));
      expect(file.filePath, equals('/local/path'));
      expect(file.bytes, equals(bytes));
      expect(file.dimensions?.width, equals(100));
      expect(file.blurHash, equals('hash123'));
    });
  });
  
  group('MediaDimensions', () {
    test('aspect ratio 계산', () {
      final dimensions = MediaDimensions(width: 1920, height: 1080);
      
      expect(dimensions.width, equals(1920));
      expect(dimensions.height, equals(1080));
      // aspect ratio 계산 테스트 (16:9)
      expect(dimensions.width! / dimensions.height!, 
             closeTo(1.777, 0.001));
    });
  });
  
  group('validateFileFormat', () {
    testWidgets('허용된 형식 검증', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) {
            final isValid = validateFileFormat('test.jpg', context);
            expect(isValid, isTrue);
            
            final isInvalid = validateFileFormat('test.exe', context);
            expect(isInvalid, isFalse);
            
            return Container();
          },
        ),
      ));
      
      // SnackBar 표시 확인
      await tester.pump();
      expect(find.text('Invalid file format: application/x-msdownload'), 
             findsOneWidget);
    });
  });
  
  group('Storage Path Generation', () {
    test('_getStoragePath 형식 검증', () {
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      
      // 테스트를 위한 private 함수 접근
      // 실제로는 public 래퍼나 테스트용 클래스 사용
      final path = getTestStoragePath('prefix', 'test.jpg', false, 0);
      
      expect(path, contains('prefix/'));
      expect(path, contains('.jpg'));
      expect(path, contains('_0'));
    });
    
    test('signature storage path 생성', () {
      final path = getSignatureStoragePath('signatures');
      
      expect(path, startsWith('signatures/signature_'));
      expect(path, endsWith('.png'));
    });
  });
}
```

### 4. UploadedFile 테스트

```dart
// test/core/models/uploaded_file_test.dart
void main() {
  group('AppUploadedFile', () {
    late AppUploadedFile file;
    late Uint8List testBytes;
    
    setUp(() {
      testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      file = AppUploadedFile(
        name: 'test.jpg',
        bytes: testBytes,
        height: 100,
        width: 200,
        blurHash: 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.',
      );
    });
    
    group('직렬화', () {
      test('serialize 메서드', () {
        final json = file.serialize();
        final decoded = jsonDecode(json);
        
        expect(decoded['name'], equals('test.jpg'));
        expect(decoded['height'], equals(100));
        expect(decoded['width'], equals(200));
        expect(decoded['blurHash'], equals('LGF5]+Yk^6#M@-5c,1J5@[or[Q6.'));
      });
      
      test('deserialize 메서드', () {
        final json = file.serialize();
        final deserialized = AppUploadedFile.deserialize(json);
        
        expect(deserialized.name, equals(file.name));
        expect(deserialized.height, equals(file.height));
        expect(deserialized.width, equals(file.width));
        expect(deserialized.blurHash, equals(file.blurHash));
        expect(deserialized.bytes, equals(file.bytes));
      });
      
      test('null 값 처리', () {
        final fileWithNulls = AppUploadedFile(
          name: null,
          bytes: null,
        );
        
        final json = fileWithNulls.serialize();
        final deserialized = AppUploadedFile.deserialize(json);
        
        expect(deserialized.name, equals(''));
        expect(deserialized.bytes, isNotNull);
        expect(deserialized.bytes!.isEmpty, isTrue);
      });
    });
    
    group('동등성', () {
      test('같은 값의 객체는 동등해야 함', () {
        final file2 = AppUploadedFile(
          name: 'test.jpg',
          bytes: testBytes,
          height: 100,
          width: 200,
          blurHash: 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.',
        );
        
        expect(file == file2, isTrue);
        expect(file.hashCode, equals(file2.hashCode));
      });
      
      test('다른 값의 객체는 동등하지 않아야 함', () {
        final file2 = AppUploadedFile(
          name: 'different.jpg',
          bytes: testBytes,
          height: 100,
          width: 200,
          blurHash: 'LGF5]+Yk^6#M@-5c,1J5@[or[Q6.',
        );
        
        expect(file == file2, isFalse);
      });
    });
    
    test('toString 형식', () {
      final str = file.toString();
      
      expect(str, contains('AppUploadedFile'));
      expect(str, contains('name: test.jpg'));
      expect(str, contains('bytes: 5'));
      expect(str, contains('height: 100'));
      expect(str, contains('width: 200'));
    });
  });
}
```

## 🔄 통합 테스트

### Upload Flow 통합 테스트

```dart
// test/features/upload/integration/upload_flow_test.dart
void main() {
  group('Upload Flow Integration', () {
    late MockUploadRepository mockRepository;
    late MockUserProvider mockUserProvider;
    late UploadService uploadService;
    
    setUp(() {
      mockRepository = MockUploadRepository();
      mockUserProvider = MockUserProvider();
      uploadService = UploadService(
        userProvider: mockUserProvider,
        repository: mockRepository,
      );
      
      when(mockUserProvider.currentUserId).thenReturn('user123');
    });
    
    testWidgets('전체 업로드 플로우', (tester) async {
      // 1. 미디어 선택 UI 표시
      await tester.pumpWidget(MaterialApp(
        home: UploadTestScreen(uploadService: uploadService),
      ));
      
      await tester.tap(find.text('Select Media'));
      await tester.pumpAndSettle();
      
      // 2. 소스 선택 (갤러리)
      expect(find.text('Gallery'), findsOneWidget);
      await tester.tap(find.text('Gallery'));
      
      // 3. 파일 선택 모의
      final testFile = SelectedFile(
        storagePath: 'users/user123/uploads/test.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
      );
      
      when(mockRepository.upload(any)).thenAnswer(
        (_) async => UploadResult(
          url: 'https://storage.example.com/test.jpg',
          success: true,
        ),
      );
      
      // 4. 업로드 실행
      final result = await uploadService.upload(testFile);
      
      // 5. 결과 검증
      expect(result.success, isTrue);
      expect(result.url, contains('test.jpg'));
      verify(mockRepository.upload(testFile)).called(1);
    });
    
    testWidgets('업로드 진행률 표시', (tester) async {
      final progressController = StreamController<UploadProgress>();
      
      when(mockRepository.uploadWithProgress(any))
          .thenAnswer((_) => progressController.stream);
      
      await tester.pumpWidget(MaterialApp(
        home: UploadProgressTestScreen(
          uploadService: uploadService,
        ),
      ));
      
      // 업로드 시작
      await tester.tap(find.text('Start Upload'));
      await tester.pump();
      
      // 진행률 업데이트
      progressController.add(UploadProgress(0.25));
      await tester.pump();
      expect(find.text('25%'), findsOneWidget);
      
      progressController.add(UploadProgress(0.50));
      await tester.pump();
      expect(find.text('50%'), findsOneWidget);
      
      progressController.add(UploadProgress(1.0));
      await tester.pump();
      expect(find.text('Complete'), findsOneWidget);
      
      progressController.close();
    });
  });
}
```

## 🎨 위젯 테스트

### MediaSelector 위젯 테스트

```dart
// test/features/upload/widget/media_selector_test.dart
void main() {
  group('MediaSourceSelector', () {
    testWidgets('미디어 소스 옵션 표시', (tester) async {
      MediaSource? selectedSource;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaSourceSelector(
            onSourceSelected: (source) => selectedSource = source,
            allowPhoto: true,
            allowVideo: true,
          ),
        ),
      ));
      
      // 바텀시트 열기
      await tester.tap(find.byType(MediaSourceSelector));
      await tester.pumpAndSettle();
      
      // 옵션 확인
      expect(find.text('Choose Source'), findsOneWidget);
      expect(find.text('Gallery (Photo)'), findsOneWidget);
      expect(find.text('Gallery (Video)'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      
      // 선택
      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();
      
      expect(selectedSource, equals(MediaSource.camera));
    });
    
    testWidgets('플랫폼별 옵션 차이', (tester) async {
      // Web 환경 시뮬레이션
      debugDefaultTargetPlatformOverride = TargetPlatform.web;
      
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaSourceSelector(
            onSourceSelected: (_) {},
            allowPhoto: true,
          ),
        ),
      ));
      
      await tester.tap(find.byType(MediaSourceSelector));
      await tester.pumpAndSettle();
      
      // Web에서는 Camera 옵션이 없어야 함
      expect(find.text('Camera'), findsNothing);
      expect(find.text('Gallery'), findsOneWidget);
      
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
```

## 🧪 성능 테스트

### 메모리 및 성능 테스트

```dart
// test/core/models/performance_test.dart
void main() {
  group('Performance Tests', () {
    test('AppDynamicModels 대량 모델 처리', () {
      final dynamicModels = AppDynamicModels(() => TestModel());
      final stopwatch = Stopwatch()..start();
      
      // 1000개 모델 생성
      for (int i = 0; i < 1000; i++) {
        dynamicModels.getModel('key$i', i);
      }
      
      stopwatch.stop();
      
      // 1초 이내 완료
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      // 메모리 정리 테스트
      dynamicModels.dispose();
    });
    
    test('파일 업로드 크기 제한', () {
      final largeBytes = Uint8List(11 * 1024 * 1024); // 11MB
      final config = UploadConfig(
        allowedTypes: [MediaType.image],
        maxFileSize: 10 * 1024 * 1024, // 10MB
      );
      
      expect(
        () => validateFileSize(largeBytes, config),
        throwsA(isA<FileSizeException>()),
      );
    });
    
    test('동시 업로드 처리', () async {
      final uploads = List.generate(10, (i) => 
        SelectedFile(
          storagePath: 'path$i',
          bytes: Uint8List(1024),
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      
      // 병렬 업로드
      await Future.wait(
        uploads.map((file) => mockUpload(file)),
      );
      
      stopwatch.stop();
      
      // 순차 처리보다 빨라야 함
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });
  });
}
```

## 📊 테스트 커버리지

### 커버리지 목표 및 현황

| 파일 | 목표 | 현재 | 상태 |
|------|------|------|------|
| app_model.dart | 95% | 0% | 🔴 |
| form_field_controller.dart | 95% | 0% | 🔴 |
| upload_data.dart | 90% | 0% | 🔴 |
| uploaded_file.dart | 100% | 0% | 🔴 |

### 커버리지 측정 스크립트

```bash
#!/bin/bash
# test_coverage.sh

# 테스트 실행 및 커버리지 생성
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 커버리지 요약
lcov --summary coverage/lcov.info

# 특정 디렉토리만
lcov --extract coverage/lcov.info 'lib/core/models/*' \
     -o coverage/models.info
lcov --summary coverage/models.info
```

## 🏃 테스트 실행

### 단위 테스트
```bash
# 전체 테스트
flutter test

# 특정 파일
flutter test test/core/models/app_model_test.dart

# 특정 그룹
flutter test --name "AppModel"
```

### 통합 테스트
```bash
# 통합 테스트
flutter test integration_test/

# 특정 플로우
flutter test integration_test/upload_flow_test.dart
```

### 지속적 테스트
```bash
# 파일 변경 감지 및 자동 테스트
flutter test --watch

# 병렬 실행
flutter test --concurrency=4
```

## 🐛 디버깅 가이드

### 테스트 실패 시
1. **로그 확인**: `debugPrint()` 추가
2. **단계별 실행**: `debugger()` 브레이크포인트
3. **상태 검증**: `expect()` 세분화
4. **타이밍 이슈**: `pumpAndSettle()` 사용

### Flaky 테스트 해결
```dart
// 타이밍 이슈 해결
await tester.pumpAndSettle(
  const Duration(milliseconds: 100),
  EnginePhase.persistentCallbacks,
);

// 비동기 처리
await expectLater(
  uploadFuture,
  completion(equals(expectedResult)),
);
```

## 📝 테스트 작성 체크리스트

### 테스트 작성 전
- [ ] 테스트 목적 명확히 정의
- [ ] 테스트 데이터 준비
- [ ] Mock 객체 설계
- [ ] 엣지 케이스 식별

### 테스트 작성 중
- [ ] Arrange-Act-Assert 패턴 준수
- [ ] 의미 있는 테스트 이름
- [ ] 독립적인 테스트 작성
- [ ] 적절한 assertion 사용

### 테스트 작성 후
- [ ] 커버리지 확인
- [ ] 리팩토링 기회 탐색
- [ ] 문서화 업데이트
- [ ] CI/CD 통합

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - run: flutter pub get
      
      - run: flutter analyze
      
      - run: flutter test --coverage
      
      - uses: codecov/codecov-action@v2
        with:
          file: coverage/lcov.info
```

---

*이 문서는 Core Models의 테스트 전략과 구현 가이드입니다.*
*95% 커버리지로 안정적인 코드베이스를 유지합니다.*