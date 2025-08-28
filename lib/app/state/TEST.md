# 🧪 State 레이어 테스트 가이드

> Provider 기반 상태 관리 시스템 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 예상 커버리지: 85%

## 📋 테스트 범위

### 1. 테스트 대상
- **AppState**: 전역 상태 관리 (리팩토링 후)
- **Feature Providers**: ContentCreationProvider, MediaUploadProvider 등
- **State 변경 알림**: notifyListeners() 호출 검증
- **비즈니스 로직**: 상태 변환 및 유효성 검사
- **브리지 패턴**: 마이그레이션 중 호환성

### 2. 테스트 제외 대상
- Provider 패키지 자체
- Flutter 프레임워크 ChangeNotifier

## 🎯 테스트 전략

### Phase 1: Provider 단위 테스트 (Week 3, Day 1-2)

#### 1.1 ContentCreationProvider 테스트
```dart
// test/unit/features/posts/providers/content_creation_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/features/posts/presentation/providers/content_creation_provider.dart';
import 'package:versus_space/features/posts/domain/models/content_box.dart';

void main() {
  group('ContentCreationProvider 테스트', () {
    late ContentCreationProvider provider;
    
    setUp(() {
      provider = ContentCreationProvider();
    });
    
    tearDown(() {
      provider.dispose();
    });
    
    test('초기 상태가 올바르게 설정되어야 함', () {
      // Then
      expect(provider.boxA.isEmpty, isTrue);
      expect(provider.boxB.isEmpty, isTrue);
      expect(provider.title, isEmpty);
      expect(provider.description, isEmpty);
    });
    
    group('Box A 업데이트', () {
      test('텍스트를 업데이트하면 notifyListeners가 호출되어야 함', () {
        // Given
        var listenerCalled = false;
        provider.addListener(() {
          listenerCalled = true;
        });
        
        // When
        provider.updateBoxA(text: 'New text');
        
        // Then
        expect(provider.boxA.text, equals('New text'));
        expect(listenerCalled, isTrue);
      });
      
      test('이미지를 추가하면 상태가 업데이트되어야 함', () {
        // Given
        final images = ['image1.jpg', 'image2.jpg'];
        
        // When
        provider.updateBoxA(images: images);
        
        // Then
        expect(provider.boxA.imageUrls, equals(images));
        expect(provider.boxA.hasMedia, isTrue);
      });
      
      test('비디오 URL을 설정하면 다른 미디어가 제거되어야 함', () {
        // Given
        provider.updateBoxA(images: ['image.jpg']);
        
        // When
        provider.updateBoxA(videoUrl: 'video.mp4');
        
        // Then
        expect(provider.boxA.videoUrl, equals('video.mp4'));
        expect(provider.boxA.imageUrls, isEmpty);
      });
    });
    
    group('유효성 검사', () {
      test('필수 필드가 비어있으면 isValid가 false여야 함', () {
        // Given - 초기 상태 (모두 비어있음)
        
        // Then
        expect(provider.isValid, isFalse);
      });
      
      test('최소 요구사항이 충족되면 isValid가 true여야 함', () {
        // When
        provider.updateTitle('Test Title');
        provider.updateBoxA(text: 'Content A');
        
        // Then
        expect(provider.isValid, isTrue);
      });
      
      test('A박스 없이 B박스만 있으면 경고가 발생해야 함', () {
        // When
        provider.updateBoxB(text: 'Content B');
        
        // Then
        expect(provider.hasWarning, isTrue);
        expect(provider.warningMessage, contains('A 박스'));
      });
    });
    
    group('상태 초기화', () {
      test('clear()를 호출하면 모든 상태가 초기화되어야 함', () {
        // Given
        provider.updateTitle('Title');
        provider.updateBoxA(text: 'Text');
        provider.updateBoxB(images: ['image.jpg']);
        
        var listenerCalled = false;
        provider.addListener(() {
          listenerCalled = true;
        });
        
        // When
        provider.clear();
        
        // Then
        expect(provider.title, isEmpty);
        expect(provider.boxA.isEmpty, isTrue);
        expect(provider.boxB.isEmpty, isTrue);
        expect(listenerCalled, isTrue);
      });
    });
  });
}
```

#### 1.2 MediaUploadProvider 테스트
```dart
// test/unit/features/media/providers/media_upload_provider_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:versus_space/features/media/presentation/providers/media_upload_provider.dart';

@GenerateMocks([File, FirebaseStorage, Reference])
void main() {
  group('MediaUploadProvider 테스트', () {
    late MediaUploadProvider provider;
    late MockFirebaseStorage mockStorage;
    
    setUp(() {
      mockStorage = MockFirebaseStorage();
      provider = MediaUploadProvider(storage: mockStorage);
    });
    
    test('업로드 작업을 추가하면 큐에 저장되어야 함', () async {
      // Given
      final mockFile = MockFile();
      when(mockFile.existsSync()).thenReturn(true);
      when(mockFile.path).thenReturn('/path/to/image.jpg');
      
      // When
      final taskId = await provider.uploadImage(
        mockFile,
        box: 'A',
        index: 0,
      );
      
      // Then
      expect(provider.hasActiveUploads, isTrue);
      expect(provider.getUploadProgress(taskId), equals(0.0));
    });
    
    test('업로드 진행률이 올바르게 업데이트되어야 함', () async {
      // Given
      final mockFile = MockFile();
      final mockRef = MockReference();
      final mockTask = MockUploadTask();
      
      when(mockStorage.ref(any)).thenReturn(mockRef);
      when(mockRef.putFile(any)).thenReturn(mockTask);
      when(mockTask.snapshotEvents).thenAnswer((_) => 
        Stream.fromIterable([
          TaskSnapshot(bytesTransferred: 50, totalBytes: 100),
          TaskSnapshot(bytesTransferred: 100, totalBytes: 100),
        ])
      );
      
      // When
      final taskId = await provider.uploadImage(mockFile, box: 'A', index: 0);
      
      // Then
      await Future.delayed(Duration(milliseconds: 100));
      expect(provider.getUploadProgress(taskId), equals(1.0));
    });
    
    test('업로드 실패 시 에러 상태가 설정되어야 함', () async {
      // Given
      final mockFile = MockFile();
      when(mockStorage.ref(any)).thenThrow(Exception('Network error'));
      
      // When
      final taskId = await provider.uploadImage(mockFile, box: 'A', index: 0);
      
      // Then
      expect(provider.hasError(taskId), isTrue);
      expect(provider.getError(taskId), contains('Network error'));
    });
    
    test('취소된 업로드는 정리되어야 함', () async {
      // Given
      final taskId = await provider.uploadImage(
        MockFile(),
        box: 'A',
        index: 0,
      );
      
      // When
      provider.cancelUpload(taskId);
      
      // Then
      expect(provider.hasActiveUploads, isFalse);
      expect(provider.getUploadProgress(taskId), isNull);
    });
  });
}
```

### Phase 2: 브리지 패턴 테스트 (Week 3, Day 2-3)

#### 2.1 ContentCreationBridge 테스트
```dart
// test/unit/app/state/bridges/content_creation_bridge_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/state/app_state.dart';
import 'package:versus_space/features/posts/presentation/providers/content_creation_provider.dart';

void main() {
  group('ContentCreationBridge 호환성 테스트', () {
    late AppState appState;
    late ContentCreationProvider newProvider;
    late ContentCreationBridge bridge;
    
    setUp(() {
      appState = AppState();
      newProvider = ContentCreationProvider();
      bridge = ContentCreationBridge(
        appState: appState,
        newProvider: newProvider,
      );
    });
    
    test('기존 AppState에서 새 Provider로 동기화되어야 함', () {
      // Given
      appState.uploadTextA = 'Legacy Text A';
      appState.uploadImageA = ['legacy1.jpg', 'legacy2.jpg'];
      
      // When
      bridge.syncToNew();
      
      // Then
      expect(newProvider.boxA.text, equals('Legacy Text A'));
      expect(newProvider.boxA.imageUrls, equals(['legacy1.jpg', 'legacy2.jpg']));
    });
    
    test('새 Provider에서 기존 AppState로 동기화되어야 함', () {
      // Given
      newProvider.updateBoxA(
        text: 'New Text',
        images: ['new1.jpg'],
      );
      
      // When
      bridge.syncToOld();
      
      // Then
      expect(appState.uploadTextA, equals('New Text'));
      expect(appState.uploadImageA, equals(['new1.jpg']));
    });
    
    test('양방향 동기화가 데이터 손실 없이 작동해야 함', () {
      // Given
      appState.uploadTextA = 'Original';
      
      // When
      bridge.syncToNew();
      newProvider.updateBoxA(text: 'Modified');
      bridge.syncToOld();
      
      // Then
      expect(appState.uploadTextA, equals('Modified'));
    });
  });
}
```

### Phase 3: Provider 통합 테스트 (Week 3, Day 3-4)

#### 3.1 Multi-Provider 통합 테스트
```dart
// test/integration/app/state/multi_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Multi-Provider 통합 테스트', () {
    testWidgets('여러 Provider가 함께 작동해야 함', (tester) async {
      // Given
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppState()),
            ChangeNotifierProvider(create: (_) => ContentCreationProvider()),
            ChangeNotifierProvider(create: (_) => MediaUploadProvider()),
          ],
          child: MaterialApp(
            home: TestConsumerWidget(),
          ),
        ),
      );
      
      // When
      final appState = Provider.of<AppState>(
        tester.element(find.byType(TestConsumerWidget)),
        listen: false,
      );
      final contentProvider = Provider.of<ContentCreationProvider>(
        tester.element(find.byType(TestConsumerWidget)),
        listen: false,
      );
      
      appState.updateLanguage('ko');
      contentProvider.updateTitle('Test');
      
      await tester.pump();
      
      // Then
      expect(find.text('ko'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });
    
    testWidgets('Provider 변경이 UI에 반영되어야 함', (tester) async {
      // Given
      final provider = ContentCreationProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: MaterialApp(
            home: Consumer<ContentCreationProvider>(
              builder: (context, provider, child) {
                return Text(provider.title);
              },
            ),
          ),
        ),
      );
      
      // Initial state
      expect(find.text(''), findsOneWidget);
      
      // When
      provider.updateTitle('Updated Title');
      await tester.pump();
      
      // Then
      expect(find.text('Updated Title'), findsOneWidget);
    });
  });
}
```

#### 3.2 상태 지속성 테스트
```dart
// test/integration/app/state/persistence_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('상태 지속성 테스트', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });
    
    test('AppState가 SharedPreferences에 저장되어야 함', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      final appState = AppState();
      
      // When
      appState.updateLanguage('ko');
      appState.updateDisplayName('Test User');
      await appState.persist();
      
      // Then
      expect(prefs.getString('selectedLang'), equals('ko'));
      expect(prefs.getString('displayName'), equals('Test User'));
    });
    
    test('앱 재시작 시 상태가 복원되어야 함', () async {
      // Given
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLang', 'en');
      await prefs.setString('displayName', 'Saved User');
      
      // When
      final appState = AppState();
      await appState.loadFromPrefs();
      
      // Then
      expect(appState.selectedLang, equals('en'));
      expect(appState.displayName, equals('Saved User'));
    });
  });
}
```

### Phase 4: 성능 및 메모리 테스트 (Week 3, Day 5)

#### 4.1 메모리 누수 테스트
```dart
// test/performance/app/state/memory_leak_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_tracker_flutter_testing/leak_tracker_flutter_testing.dart';

void main() {
  group('메모리 누수 테스트', () {
    testMemoryLeaks('Provider가 올바르게 dispose되어야 함', () async {
      // Given
      final providers = <ContentCreationProvider>[];
      
      // When - 여러 Provider 생성 및 삭제
      for (int i = 0; i < 100; i++) {
        final provider = ContentCreationProvider();
        provider.updateTitle('Title $i');
        providers.add(provider);
      }
      
      // Dispose all
      for (final provider in providers) {
        provider.dispose();
      }
      
      // Then - 메모리 누수가 없어야 함
      // leak_tracker가 자동으로 검증
    });
    
    testMemoryLeaks('리스너가 올바르게 제거되어야 함', () async {
      // Given
      final provider = ContentCreationProvider();
      final listeners = <VoidCallback>[];
      
      // When - 리스너 추가 및 제거
      for (int i = 0; i < 100; i++) {
        void listener() {}
        listeners.add(listener);
        provider.addListener(listener);
      }
      
      for (final listener in listeners) {
        provider.removeListener(listener);
      }
      
      provider.dispose();
      
      // Then - 메모리 누수가 없어야 함
    });
  });
}
```

#### 4.2 성능 벤치마크
```dart
// test/performance/app/state/performance_test.dart
void main() {
  group('상태 업데이트 성능 테스트', () {
    test('1000번 상태 업데이트가 100ms 이하여야 함', () {
      // Given
      final provider = ContentCreationProvider();
      int listenerCallCount = 0;
      
      provider.addListener(() {
        listenerCallCount++;
      });
      
      // When
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        provider.updateTitle('Title $i');
      }
      
      stopwatch.stop();
      
      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      expect(listenerCallCount, equals(1000));
    });
    
    test('대용량 데이터 처리가 효율적이어야 함', () {
      // Given
      final provider = MediaUploadProvider();
      final largeImageList = List.generate(1000, (i) => 'image$i.jpg');
      
      // When
      final stopwatch = Stopwatch()..start();
      
      provider.batchAddImages(largeImageList);
      
      stopwatch.stop();
      
      // Then
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });
  });
}
```

## 📝 테스트 작성 가이드라인

### 1. Provider 테스트 패턴
```dart
group('Provider명 테스트', () {
  late MyProvider provider;
  
  setUp(() {
    provider = MyProvider();
  });
  
  tearDown(() {
    provider.dispose();
  });
  
  test('설명', () {
    // Given
    var notified = false;
    provider.addListener(() {
      notified = true;
    });
    
    // When
    provider.updateSomething();
    
    // Then
    expect(notified, isTrue);
    expect(provider.something, expectedValue);
  });
});
```

### 2. Consumer 위젯 테스트
```dart
class TestConsumerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        return Text(provider.value);
      },
    );
  }
}
```

### 3. Mock Provider 생성
```dart
class MockContentProvider extends Mock 
    implements ContentCreationProvider {
  @override
  ContentBox get boxA => ContentBox();
  
  @override
  void updateBoxA({String? text, List<String>? images}) {
    // Mock 구현
  }
}
```

## 🔧 테스트 도구 설정

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  provider: ^6.1.2
  mockito: ^5.4.0
  shared_preferences: ^2.5.3
  leak_tracker_flutter_testing: ^1.0.0
```

### SharedPreferences Mock 설정
```dart
void setupSharedPreferencesMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
}
```

## 📊 커버리지 목표

| 구분 | 목표 커버리지 | 우선순위 |
|-----|------------|---------|
| Provider 로직 | 90% | Critical |
| 브리지 패턴 | 95% | Critical |
| 유효성 검사 | 100% | High |
| 상태 지속성 | 85% | Medium |
| 성능 | 70% | Low |

## ✅ 체크리스트

### 작성 전
- [ ] Provider Mock 준비
- [ ] SharedPreferences Mock 설정
- [ ] 테스트 데이터 준비

### 작성 중
- [ ] notifyListeners 검증
- [ ] 상태 변경 검증
- [ ] 메모리 누수 체크
- [ ] 엣지 케이스 처리

### 작성 후
- [ ] 커버리지 85% 이상
- [ ] 성능 벤치마크 통과
- [ ] 문서화

## 🚀 실행 명령어

```bash
# State 테스트만 실행
flutter test test/app/state/
flutter test test/features/posts/providers/

# 메모리 누수 테스트
flutter test --enable-leak-tracking test/performance/app/state/

# 커버리지 측정
flutter test --coverage test/app/state/
flutter test --coverage test/features/

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
```

## 📚 참고 자료

- [Provider 테스트 가이드](https://pub.dev/packages/provider#testing)
- [ChangeNotifier 테스트](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)
- [Flutter 상태 관리 테스트](https://flutter.dev/docs/development/data-and-backend/state-mgmt/testing)

---

*이 문서는 State 관리 시스템의 테스트 전략과 구현 방법을 담고 있습니다.*