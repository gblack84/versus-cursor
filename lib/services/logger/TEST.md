# 🧪 Logger Service 테스트 가이드

> Logger Service 레이어의 포괄적 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 90%+

## 📋 테스트 전략 개요

### 테스트 피라미드
```
        E2E Tests (5%)
       /            \
    Integration (25%)
   /                  \
  Unit Tests (70%)
 /                      \
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 커버리지 목표
- **전체 목표**: 90% 이상
- **단위 테스트**: 95% (도메인, 유틸리티)
- **통합 테스트**: 85% (서비스, 데이터 레이어)  
- **E2E 테스트**: 70% (실제 로깅 플로우)

## 🎯 테스트 범위

### Services 레이어 테스트
```
services/logger/
├── domain/          → 비즈니스 로직 검증
├── data/           → 데이터 처리 테스트
├── presentation/   → UI 컴포넌트 테스트  
└── utils/          → 유틸리티 함수 테스트
```

## 📝 단위 테스트

### 1. 현재 AppLogger 테스트
```dart
// test/services/logger/app_logger_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/logger/app_logger.dart';

void main() {
  group('AppLogger', () {
    setUp(() {
      AppLogger.clearLogs();
    });
    
    test('액션 로그 추가 및 타임스탬프 확인', () {
      AppLogger.logAction('TEST_ACTION', data: {'key': 'value'});
      
      final logs = AppLogger.getAllLogs();
      expect(logs, contains('ACTION: TEST_ACTION'));
      expect(logs, contains('key: value'));
      expect(logs, matches(r'\[\d{4}-\d{2}-\d{2}T'));
    });
    
    test('1000개 순환 버퍼 유지', () {
      for (int i = 0; i < 1100; i++) {
        AppLogger.logAction('ACTION_$i');
      }
      
      final logs = AppLogger.getAllLogs();
      final logLines = logs.split('\n');
      
      expect(logLines.length, 1000);
      expect(logs, isNot(contains('ACTION_0'))); // 첫 100개 제거됨
      expect(logs, contains('ACTION_1099')); // 마지막 로그 존재
    });
    
    test('네비게이션 로깅', () {
      AppLogger.logNavigation('home', 'profile');
      
      final logs = AppLogger.getAllLogs();
      expect(logs, contains('NAVIGATION'));
      expect(logs, contains('from: home'));
      expect(logs, contains('to: profile'));
    });
    
    test('에러 및 스택트레이스 로깅', () {
      final stackTrace = StackTrace.current;
      AppLogger.logError('Test error', stackTrace: stackTrace);
      
      final logs = AppLogger.getAllLogs();
      expect(logs, contains('ERROR: Test error'));
      expect(logs, contains('STACK:'));
    });
    
    test('최근 N개 로그 조회', () {
      for (int i = 0; i < 20; i++) {
        AppLogger.logAction('ACTION_$i');
      }
      
      final recentLogs = AppLogger.getRecentLogs(5);
      final logLines = recentLogs.split('\n');
      
      expect(logLines.length, 5);
      expect(recentLogs, contains('ACTION_19'));
      expect(recentLogs, isNot(contains('ACTION_14')));
    });
  });
}
```

### 2. 현재 FileLogger 테스트
```dart
// test/services/logger/file_logger_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:versus_space/services/logger/file_logger.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('FileLogger', () {
    late Directory tempDir;
    
    setUp(() async {
      tempDir = await getTemporaryDirectory();
      await FileLogger.clearLogs();
    });
    
    test('로그 파일 초기화', () async {
      await FileLogger.initialize();
      
      final path = FileLogger.getLogFilePath();
      expect(path, isNotNull);
      expect(path, contains('app_debug.log'));
    });
    
    test('타임스탬프와 함께 로그 작성', () async {
      await FileLogger.log('Test message');
      
      final logs = await FileLogger.readAllLogs();
      expect(logs, contains('Test message'));
      expect(logs, matches(r'\[\d{4}-\d{2}-\d{2}T'));
    });
    
    test('여러 로그 추가', () async {
      await FileLogger.log('First log');
      await FileLogger.log('Second log');
      await FileLogger.log('Third log');
      
      final logs = await FileLogger.readAllLogs();
      expect(logs, contains('First log'));
      expect(logs, contains('Second log'));
      expect(logs, contains('Third log'));
    });
    
    test('1MB 초과시 파일 리셋', () async {
      // 512KB 로그 생성
      final largeLog = 'X' * (1024 * 512);
      
      await FileLogger.log(largeLog);
      await FileLogger.log(largeLog);
      await FileLogger.log(largeLog); // 1.5MB 초과
      
      await FileLogger.initialize();
      
      final file = File(FileLogger.getLogFilePath()!);
      final size = await file.length();
      
      expect(size, lessThan(1024 * 1024)); // 1MB 이하
    });
  });
}
```

## 🔮 향후 Clean Architecture 테스트

### 1. 도메인 엔티티 테스트
```dart
// test/services/logger/domain/entities/log_entry_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/logger/domain/entities/log_entry.dart';

void main() {
  group('LogEntry', () {
    test('생성자 테스트', () {
      final entry = LogEntry(
        id: 'test-id',
        timestamp: DateTime(2025, 8, 28),
        level: LogLevel.info,
        category: LogCategory.action,
        message: 'Test message',
        data: {'key': 'value'},
      );
      
      expect(entry.id, 'test-id');
      expect(entry.level, LogLevel.info);
      expect(entry.category, LogCategory.action);
      expect(entry.message, 'Test message');
      expect(entry.data?['key'], 'value');
    });
    
    test('JSON 직렬화', () {
      final entry = LogEntry(
        id: 'test-id',
        timestamp: DateTime(2025, 8, 28),
        level: LogLevel.error,
        category: LogCategory.error,
        message: 'Error occurred',
        stackTrace: 'Stack trace here',
      );
      
      final json = entry.toJson();
      expect(json['id'], 'test-id');
      expect(json['level'], 'error');
      expect(json['category'], 'error');
      expect(json['message'], 'Error occurred');
      expect(json['stackTrace'], 'Stack trace here');
    });
    
    test('JSON 역직렬화', () {
      final json = {
        'id': 'test-id',
        'timestamp': '2025-08-28T00:00:00.000',
        'level': 'warning',
        'category': 'performance',
        'message': 'Performance warning',
        'data': {'duration': 1500},
      };
      
      final entry = LogEntry.fromJson(json);
      expect(entry.id, 'test-id');
      expect(entry.level, LogLevel.warning);
      expect(entry.category, LogCategory.performance);
      expect(entry.data?['duration'], 1500);
    });
  });
}
```

### 2. 유스케이스 테스트
```dart
// test/services/logger/domain/usecases/log_action_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:versus_space/services/logger/domain/usecases/log_action.dart';
import 'package:versus_space/services/logger/domain/repositories/i_log_repository.dart';

@GenerateMocks([ILogRepository])
import 'log_action_test.mocks.dart';

void main() {
  group('LogAction UseCase', () {
    late LogAction logAction;
    late MockILogRepository mockRepository;
    
    setUp(() {
      mockRepository = MockILogRepository();
      logAction = LogAction(mockRepository);
    });
    
    test('액션 로깅 성공', () async {
      // Arrange
      when(mockRepository.addLog(any))
          .thenAnswer((_) async => void);
      
      // Act
      await logAction(
        action: 'BUTTON_CLICK',
        data: {'button': 'submit'},
        level: LogLevel.info,
      );
      
      // Assert
      verify(mockRepository.addLog(any)).called(1);
      final captured = verify(
        mockRepository.addLog(captureAny)
      ).captured.single as LogEntry;
      
      expect(captured.message, 'BUTTON_CLICK');
      expect(captured.level, LogLevel.info);
      expect(captured.category, LogCategory.action);
      expect(captured.data?['button'], 'submit');
    });
    
    test('에러 발생 시 처리', () async {
      // Arrange
      when(mockRepository.addLog(any))
          .thenThrow(Exception('Storage error'));
      
      // Act & Assert
      expect(
        () => logAction(action: 'TEST_ACTION'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

### 3. Repository 통합 테스트
```dart
// test/services/logger/data/repositories/log_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:versus_space/services/logger/data/repositories/log_repository_impl.dart';

@GenerateMocks([MemoryDataSource, FileDataSource, RemoteDataSource])
import 'log_repository_impl_test.mocks.dart';

void main() {
  group('LogRepositoryImpl', () {
    late LogRepositoryImpl repository;
    late MockMemoryDataSource mockMemory;
    late MockFileDataSource mockFile;
    late MockRemoteDataSource mockRemote;
    
    setUp(() {
      mockMemory = MockMemoryDataSource();
      mockFile = MockFileDataSource();
      mockRemote = MockRemoteDataSource();
      
      repository = LogRepositoryImpl(
        memoryDataSource: mockMemory,
        fileDataSource: mockFile,
        remoteDataSource: mockRemote,
      );
    });
    
    test('일반 로그는 메모리에만 저장', () async {
      // Arrange
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Info log',
      );
      
      // Act
      await repository.addLog(entry);
      
      // Assert
      verify(mockMemory.add(entry)).called(1);
      verifyNever(mockFile.add(any));
      verifyNever(mockRemote.send(any));
    });
    
    test('경고 로그는 메모리와 파일에 저장', () async {
      // Arrange
      final entry = LogEntry(
        level: LogLevel.warning,
        message: 'Warning log',
      );
      
      // Act
      await repository.addLog(entry);
      
      // Assert
      verify(mockMemory.add(entry)).called(1);
      verify(mockFile.add(entry)).called(1);
      verifyNever(mockRemote.send(any));
    });
    
    test('에러 로그는 모든 곳에 저장', () async {
      // Arrange
      final entry = LogEntry(
        level: LogLevel.error,
        message: 'Error log',
      );
      
      // Act
      await repository.addLog(entry);
      
      // Assert
      verify(mockMemory.add(entry)).called(1);
      verify(mockFile.add(entry)).called(1);
      verify(mockRemote.send(entry)).called(1);
    });
  });
}
```

## 🔗 통합 테스트

### 1. 로깅 서비스 통합 테스트
```dart
// test/services/logger/integration/logging_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/services/logger/data/services/logging_service.dart';

void main() {
  group('LoggingService Integration', () {
    setUpAll(() async {
      await LoggingService.initialize();
    });
    
    tearDown(() {
      LoggingService.instance.clearLogs();
    });
    
    test('싱글톤 인스턴스', () {
      final instance1 = LoggingService.instance;
      final instance2 = LoggingService.instance;
      
      expect(identical(instance1, instance2), true);
    });
    
    test('액션 로깅 플로우', () async {
      await LoggingService.instance.logAction(
        'USER_LOGIN',
        data: {'userId': '123'},
      );
      
      final logs = await LoggingService.instance.getRecentLogs(1);
      expect(logs.length, 1);
      expect(logs[0].message, 'USER_LOGIN');
      expect(logs[0].data?['userId'], '123');
    });
    
    test('로그 필터링', () async {
      // 다양한 로그 추가
      await LoggingService.instance.logAction('ACTION_1');
      await LoggingService.instance.logError(Exception('Error 1'));
      await LoggingService.instance.logAction('ACTION_2');
      await LoggingService.instance.logError(Exception('Error 2'));
      
      // 에러만 필터링
      final errors = await LoggingService.instance.filterLogs(
        level: LogLevel.error,
      );
      
      expect(errors.length, 2);
      expect(errors.every((log) => log.level == LogLevel.error), true);
    });
    
    test('배치 처리', () async {
      // 100개 로그 추가
      for (int i = 0; i < 100; i++) {
        await LoggingService.instance.logAction('BATCH_$i');
      }
      
      // 배치 처리 대기
      await Future.delayed(Duration(seconds: 31));
      
      // 배치 처리 확인
      final stats = await LoggingService.instance.getStats();
      expect(stats.batchesProcessed, greaterThan(0));
    });
  });
}
```

### 2. 파일 시스템 통합 테스트
```dart
// test/services/logger/integration/file_system_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  group('File System Integration', () {
    late Directory tempDir;
    
    setUp(() async {
      tempDir = await getTemporaryDirectory();
    });
    
    test('파일 생성 및 쓰기', () async {
      final file = File('${tempDir.path}/test.log');
      
      await file.writeAsString('Test log entry\n');
      await file.writeAsString('Another entry\n', mode: FileMode.append);
      
      final contents = await file.readAsString();
      expect(contents, contains('Test log entry'));
      expect(contents, contains('Another entry'));
    });
    
    test('파일 크기 관리', () async {
      final file = File('${tempDir.path}/size_test.log');
      
      // 1MB 데이터 작성
      final largeData = 'X' * (1024 * 1024);
      await file.writeAsString(largeData);
      
      final size = await file.length();
      expect(size, greaterThanOrEqualTo(1024 * 1024));
      
      // 파일 초기화
      await file.writeAsString('');
      final newSize = await file.length();
      expect(newSize, 0);
    });
  });
}
```

## 🎬 E2E 테스트

### 1. 전체 로깅 플로우
```dart
// test/services/logger/e2e/logging_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:versus_space/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('E2E: 로깅 플로우', () {
    testWidgets('사용자 액션 전체 플로우', (tester) async {
      // 앱 시작
      app.main();
      await tester.pumpAndSettle();
      
      // 로그인 버튼 탭
      await tester.tap(find.text('로그인'));
      await tester.pumpAndSettle();
      
      // 로그 확인
      final logs = AppLogger.getAllLogs();
      
      // 네비게이션 로그 확인
      expect(logs, contains('NAVIGATION'));
      
      // 버튼 클릭 로그 확인
      expect(logs, contains('BUTTON_CLICK'));
      expect(logs, contains('로그인'));
    });
    
    testWidgets('에러 발생 및 로깅', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 에러 유발 액션 (예: 잘못된 입력)
      await tester.enterText(find.byKey(Key('email_field')), '');
      await tester.tap(find.text('제출'));
      await tester.pumpAndSettle();
      
      // 에러 로그 확인
      final logs = AppLogger.getAllLogs();
      expect(logs, contains('ERROR'));
      expect(logs, contains('validation'));
    });
  });
}
```

## ⚡ 성능 테스트

### 1. 처리량 테스트
```dart
// test/services/logger/performance/throughput_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class LoggingBenchmark extends BenchmarkBase {
  LoggingBenchmark() : super('LoggingBenchmark');
  
  @override
  void run() {
    AppLogger.logAction('BENCHMARK_ACTION', data: {
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'data': List.generate(100, (i) => i),
    });
  }
}

void main() {
  test('로깅 성능 측정', () {
    final benchmark = LoggingBenchmark();
    benchmark.report();
    
    // 결과는 콘솔에 출력됨
  });
  
  test('대량 로그 처리', () async {
    final stopwatch = Stopwatch()..start();
    
    // 10,000개 로그 추가
    for (int i = 0; i < 10000; i++) {
      AppLogger.logAction('BULK_LOG_$i');
    }
    
    stopwatch.stop();
    
    // 1초 이내 처리 확인
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    print('10,000 logs processed in ${stopwatch.elapsed}');
  });
  
  test('메모리 사용량', () {
    final initialMemory = ProcessInfo.currentRss;
    
    // 대량 로그 생성
    for (int i = 0; i < 100000; i++) {
      AppLogger.logAction('MEMORY_TEST_$i', data: {
        'index': i,
        'data': 'X' * 100,
      });
    }
    
    final finalMemory = ProcessInfo.currentRss;
    final memoryIncrease = finalMemory - initialMemory;
    
    // 메모리 증가가 2MB 이하
    expect(memoryIncrease, lessThan(2 * 1024 * 1024));
    print('Memory increased by ${memoryIncrease ~/ 1024}KB');
  });
}
```

## 📊 테스트 커버리지

### 커버리지 실행
```bash
# 전체 테스트 실행 with 커버리지
flutter test --coverage test/services/logger

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 브라우저에서 확인
open coverage/html/index.html
```

### 커버리지 목표 및 현황
```yaml
현재 커버리지:
  app_logger.dart: 85%    # ✅ 양호
  file_logger.dart: 80%   # 🟡 개선 필요

목표 커버리지 (Clean Architecture 적용 후):
  domain:
    entities: 95%        # 목표
    usecases: 90%        # 목표
    repositories: 100%   # 목표

  data:
    services: 85%        # 목표
    datasources: 80%     # 목표
    repositories: 90%    # 목표

  utils:
    formatters: 100%     # 목표
    filters: 100%        # 목표
```

## 🔄 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/logger-tests.yml
name: Logger Service Tests

on:
  push:
    paths:
      - 'lib/services/logger/**'
      - 'test/services/logger/**'
  pull_request:
    paths:
      - 'lib/services/logger/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Generate mocks
        run: flutter pub run build_runner build --delete-conflicting-outputs
      
      - name: Run tests
        run: flutter test test/services/logger --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          flags: logger-service
```

## 🛠️ 테스트 유틸리티

### Mock 헬퍼
```dart
// test/services/logger/helpers/mock_helper.dart
import 'package:mockito/annotations.dart';
import 'package:versus_space/services/logger/domain/repositories/i_log_repository.dart';
import 'package:versus_space/services/logger/data/datasources/memory_datasource.dart';
import 'package:versus_space/services/logger/data/datasources/file_datasource.dart';

@GenerateMocks([
  ILogRepository,
  MemoryDataSource,
  FileDataSource,
])
void main() {}
```

### 테스트 데이터 팩토리
```dart
// test/services/logger/helpers/test_data.dart
class TestData {
  static LogEntry createLogEntry({
    String? id,
    DateTime? timestamp,
    LogLevel level = LogLevel.info,
    LogCategory category = LogCategory.action,
    String message = 'Test message',
    Map<String, dynamic>? data,
  }) {
    return LogEntry(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: timestamp ?? DateTime.now(),
      level: level,
      category: category,
      message: message,
      data: data,
    );
  }
  
  static List<LogEntry> createLogBatch(int count) {
    return List.generate(
      count,
      (i) => createLogEntry(
        message: 'Log $i',
        data: {'index': i},
      ),
    );
  }
}
```

## ✅ 테스트 체크리스트

### 현재 구현된 테스트
- [x] AppLogger 기본 기능 테스트
- [x] FileLogger 기본 기능 테스트
- [x] 메모리 버퍼 관리 테스트
- [x] 파일 크기 관리 테스트
- [ ] 에러 처리 테스트

### Clean Architecture 마이그레이션 후 필요한 테스트
- [ ] LogEntry 엔티티 테스트
- [ ] LogLevel/LogCategory enum 테스트
- [ ] LogAction 유스케이스 테스트
- [ ] LogError 유스케이스 테스트
- [ ] FilterLogs 유스케이스 테스트
- [ ] ExportLogs 유스케이스 테스트
- [ ] LogRepository 구현 테스트
- [ ] LoggingService 통합 테스트
- [ ] BatchProcessor 테스트
- [ ] RemoteLogger 테스트
- [ ] 포맷터 테스트
- [ ] 필터 테스트
- [ ] E2E 플로우 테스트
- [ ] 성능 벤치마크 테스트

## 📚 참고 자료

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Integration Test Package](https://pub.dev/packages/integration_test)
- [Coverage Package](https://pub.dev/packages/coverage)

---

*이 문서는 Logger Service의 테스트 전략 가이드입니다.*  
*Clean Architecture 적용 후 90% 이상의 코드 커버리지를 목표로 합니다.*