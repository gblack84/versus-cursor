# 🧪 Core Localization 테스트 가이드

> 작성일: 2025-08-28 | 버전: 1.0.0 | 목표 커버리지: 95%

## 📋 테스트 전략

### 테스트 피라미드
```
         /\
        /  \  E2E Tests (5%)
       /    \  - 언어 전환 플로우
      /──────\ 
     /        \ Integration Tests (25%)  
    /          \ - 번역 로딩 및 표시
   /────────────\
  /              \ Unit Tests (70%)
 /                \ - 번역 서비스, 캐싱, 검증
/──────────────────\
```

## 🎯 테스트 목표

1. **번역 완성도**: 모든 키에 대한 번역 존재 확인
2. **성능 보장**: 번역 로딩 및 캐싱 성능 검증
3. **타입 안전성**: 번역 키 타입 체크
4. **사용자 경험**: 언어 전환 시 즉시 반영
5. **에러 처리**: 번역 누락 시 Fallback 동작

## 📊 테스트 범위

### 커버리지 목표
| 컴포넌트 | 목표 | 현재 | 상태 |
|---------|------|------|------|
| LocalizationService | 95% | 0% | ❌ |
| TranslationLoader | 95% | 0% | ❌ |
| TranslationCache | 90% | 0% | ❌ |
| TranslationValidator | 100% | 0% | ❌ |
| LanguageSelector | 85% | 0% | ❌ |
| **전체** | **95%** | **0%** | **❌** |

## 🔬 Unit Tests

### 1. LocalizationService Tests

```dart
// test/core/localization/services/localization_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/localization/services/localization_service.dart';

void main() {
  group('LocalizationService', () {
    late LocalizationService service;
    
    setUp(() {
      service = LocalizationService();
    });
    
    test('초기 언어는 영어여야 함', () {
      expect(service.locale.languageCode, 'en');
    });
    
    test('언어 변경이 정상 작동해야 함', () async {
      await service.setLocale(const Locale('de'));
      expect(service.locale.languageCode, 'de');
    });
    
    test('번역 키가 올바른 값을 반환해야 함', () async {
      await service.setLocale(const Locale('en'));
      final translation = service.translate('login.email');
      expect(translation, 'Email');
    });
    
    test('존재하지 않는 키는 키 자체를 반환해야 함', () {
      final translation = service.translate('non.existent.key');
      expect(translation, 'non.existent.key');
    });
    
    test('중첩된 키를 올바르게 파싱해야 함', () async {
      await service.setLocale(const Locale('en'));
      final translation = service.translate('signup.welcome');
      expect(translation, 'Welcome to Versus Space');
    });
  });
}
```

### 2. TranslationLoader Tests

```dart
// test/core/localization/services/translation_loader_test.dart
void main() {
  group('TranslationLoader', () {
    test('영어 번역 파일을 로드해야 함', () async {
      final translations = await TranslationLoader.load('en');
      expect(translations, isNotEmpty);
      expect(translations['login'], isNotNull);
    });
    
    test('독일어 번역 파일을 로드해야 함', () async {
      final translations = await TranslationLoader.load('de');
      expect(translations, isNotEmpty);
    });
    
    test('캐시된 번역을 재사용해야 함', () async {
      final first = await TranslationLoader.load('en');
      final second = await TranslationLoader.load('en');
      expect(identical(first, second), isTrue);
    });
    
    test('존재하지 않는 언어는 예외를 발생시켜야 함', () {
      expect(
        () => TranslationLoader.load('xx'),
        throwsA(isA<AssetException>()),
      );
    });
  });
}
```

### 3. TranslationCache Tests

```dart
// test/core/localization/services/translation_cache_test.dart
void main() {
  group('TranslationCache', () {
    late TranslationCache cache;
    
    setUp(() {
      cache = TranslationCache();
    });
    
    test('캐시에 번역을 저장하고 가져와야 함', () {
      cache.set('login.email', 'en', 'Email');
      final result = cache.get('login.email', 'en');
      expect(result, 'Email');
    });
    
    test('캐시에 없는 항목은 null을 반환해야 함', () {
      final result = cache.get('non.existent', 'en');
      expect(result, isNull);
    });
    
    test('LRU 정책에 따라 오래된 항목을 제거해야 함', () {
      // 최대 캐시 크기만큼 항목 추가
      for (int i = 0; i < 1000; i++) {
        cache.set('key$i', 'en', 'value$i');
      }
      
      // 첫 번째 항목 확인
      final first = cache.get('key0', 'en');
      expect(first, isNotNull);
      
      // 더 많은 항목 추가로 첫 번째 항목 제거
      for (int i = 1000; i < 1100; i++) {
        cache.set('key$i', 'en', 'value$i');
      }
      
      // 첫 번째 항목이 제거되었는지 확인
      final evicted = cache.get('key0', 'en');
      expect(evicted, isNull);
    });
    
    test('다른 언어의 같은 키는 별개로 캐시되어야 함', () {
      cache.set('login.email', 'en', 'Email');
      cache.set('login.email', 'de', 'E-Mail');
      
      expect(cache.get('login.email', 'en'), 'Email');
      expect(cache.get('login.email', 'de'), 'E-Mail');
    });
  });
}
```

### 4. TranslationValidator Tests

```dart
// test/core/localization/tools/translation_validator_test.dart
void main() {
  group('TranslationValidator', () {
    test('누락된 번역 키를 찾아야 함', () {
      final missing = TranslationValidator.findMissingKeys('de');
      expect(missing, isNotEmpty);
      expect(missing, contains('login.phoneLogin'));
    });
    
    test('번역 통계를 제공해야 함', () {
      final stats = TranslationValidator.getStatistics();
      expect(stats['total'], greaterThan(0));
      expect(stats['coverage_de'], lessThanOrEqualTo(100));
    });
    
    test('중복된 키를 감지해야 함', () {
      final duplicates = TranslationValidator.findDuplicateKeys('en');
      expect(duplicates, isEmpty);
    });
    
    test('사용하지 않는 키를 찾아야 함', () {
      final unused = TranslationValidator.findUnusedKeys();
      // 실제 코드에서 사용 여부 확인
      expect(unused, isNotNull);
    });
  });
}
```

## 🔄 Integration Tests

### 1. 언어 전환 통합 테스트

```dart
// test/core/localization/integration/language_switching_test.dart
void main() {
  testWidgets('언어 전환이 전체 앱에 반영되어야 함', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocalizationService()),
        ],
        child: MyApp(),
      ),
    );
    
    // 초기 언어 확인
    expect(find.text('Email'), findsOneWidget);
    
    // 설정 화면으로 이동
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    // 언어 선택기 찾기
    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();
    
    // 독일어 선택
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    
    // 홈으로 돌아가기
    await tester.tap(find.byIcon(Icons.home));
    await tester.pumpAndSettle();
    
    // 독일어 번역 확인
    expect(find.text('E-Mail'), findsOneWidget);
    expect(find.text('Email'), findsNothing);
  });
}
```

### 2. 번역 로딩 성능 테스트

```dart
// test/core/localization/integration/performance_test.dart
void main() {
  testWidgets('번역 로딩이 100ms 이내에 완료되어야 함', (tester) async {
    final stopwatch = Stopwatch()..start();
    
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizationsDelegate(),
        ],
        supportedLocales: ['en', 'de'].map((e) => Locale(e)),
        home: Container(),
      ),
    );
    
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
  
  test('1000개 번역 키 조회가 10ms 이내에 완료되어야 함', () async {
    final service = LocalizationService();
    await service.setLocale(const Locale('en'));
    
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      service.translate('login.email');
    }
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(10));
  });
}
```

## 🎨 Widget Tests

### 1. LanguageSelector Widget Test

```dart
// test/shared/widgets/language/language_selector_test.dart
void main() {
  testWidgets('언어 선택기가 현재 언어를 표시해야 함', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LanguageSelector(
            currentLanguage: 'en',
            languages: ['en', 'de', 'ko'],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    
    expect(find.text('English'), findsOneWidget);
  });
  
  testWidgets('드롭다운이 모든 언어 옵션을 표시해야 함', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LanguageSelector(
            currentLanguage: 'en',
            languages: ['en', 'de', 'ko'],
            onChanged: (_) {},
          ),
        ),
      ),
    );
    
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    
    expect(find.text('English'), findsWidgets);
    expect(find.text('Deutsch'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
  });
  
  testWidgets('국기가 올바르게 표시되어야 함', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LanguageSelector(
            currentLanguage: 'en',
            languages: ['en'],
            hideFlags: false,
            onChanged: (_) {},
          ),
        ),
      ),
    );
    
    // 영국 국기 이모지 확인
    expect(find.text('🇬🇧'), findsOneWidget);
  });
}
```

## 🚀 E2E Tests

### 1. 전체 언어 전환 플로우

```dart
// test/e2e/language_flow_test.dart
void main() {
  testE2E('사용자가 언어를 변경하고 유지되어야 함', (tester) async {
    // 앱 시작
    await tester.launch(MyApp());
    
    // 로그인
    await tester.enterText(find.byKey(Key('email_field')), 'test@test.com');
    await tester.enterText(find.byKey(Key('password_field')), 'password123');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    
    // 설정으로 이동
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    
    // 언어 변경
    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('한국어'));
    await tester.pumpAndSettle();
    
    // 앱 재시작
    await tester.restart();
    
    // 한국어가 유지되는지 확인
    expect(find.text('이메일'), findsOneWidget);
  });
}
```

## 🐛 Edge Case Tests

### 1. 번역 파일 손상 처리

```dart
test('손상된 번역 파일 처리', () async {
  // 잘못된 JSON 시뮬레이션
  when(mockAssetBundle.loadString(any))
    .thenThrow(FormatException('Invalid JSON'));
  
  final service = LocalizationService();
  await service.setLocale(const Locale('corrupted'));
  
  // Fallback 언어로 전환되어야 함
  expect(service.locale.languageCode, 'en');
});
```

### 2. 메모리 부족 상황

```dart
test('메모리 부족 시 캐시 정리', () {
  final cache = TranslationCache(maxSize: 10);
  
  // 캐시 채우기
  for (int i = 0; i < 20; i++) {
    cache.set('key$i', 'en', 'value$i');
  }
  
  // 최대 크기 유지 확인
  expect(cache.size, lessThanOrEqualTo(10));
});
```

## 📈 Performance Benchmarks

### 번역 로딩 벤치마크

```dart
// test/benchmarks/translation_benchmark.dart
void main() {
  bench('번역 파일 로딩', () async {
    await TranslationLoader.load('en');
  });
  
  bench('1000개 번역 조회', () {
    final service = LocalizationService();
    for (int i = 0; i < 1000; i++) {
      service.translate('login.email');
    }
  });
  
  bench('언어 전환', () async {
    final service = LocalizationService();
    await service.setLocale(const Locale('de'));
    await service.setLocale(const Locale('en'));
  });
}
```

### 예상 성능 기준

| 작업 | 목표 시간 | 허용 시간 |
|-----|----------|----------|
| 번역 파일 로딩 | < 50ms | < 100ms |
| 단일 번역 조회 | < 0.01ms | < 0.1ms |
| 1000개 번역 조회 | < 10ms | < 50ms |
| 언어 전환 | < 100ms | < 200ms |
| 캐시 히트율 | > 90% | > 80% |

## 🛡️ Security Tests

### 1. Injection 방지

```dart
test('번역 키에 스크립트 주입 방지', () {
  final maliciousKey = '<script>alert("XSS")</script>';
  final result = service.translate(maliciousKey);
  
  // 키가 그대로 반환되고 실행되지 않아야 함
  expect(result, maliciousKey);
  expect(result, isNot(contains('<script>')));
});
```

### 2. 파일 경로 조작 방지

```dart
test('상위 디렉토리 접근 방지', () {
  expect(
    () => TranslationLoader.load('../../../etc/passwd'),
    throwsA(isA<SecurityException>()),
  );
});
```

## 📝 테스트 실행 가이드

### 전체 테스트 실행
```bash
flutter test
```

### 커버리지 포함 실행
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 특정 테스트만 실행
```bash
flutter test test/core/localization
```

### 성능 벤치마크 실행
```bash
flutter test test/benchmarks --profile
```

### Watch 모드
```bash
flutter test --watch
```

## 🔧 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/localization_tests.yml
name: Localization Tests

on:
  push:
    paths:
      - 'lib/core/localization/**'
      - 'assets/translations/**'
      - 'test/core/localization/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter test test/core/localization
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## ✅ 테스트 체크리스트

### 필수 테스트
- [ ] 모든 번역 키가 존재하는지 확인
- [ ] 언어 전환이 즉시 반영되는지 확인
- [ ] 캐싱이 올바르게 작동하는지 확인
- [ ] 성능 기준을 만족하는지 확인

### 권장 테스트
- [ ] RTL 언어 지원 (향후)
- [ ] 접근성 테스트
- [ ] 다양한 화면 크기에서 테스트
- [ ] 네트워크 오프라인 상태 테스트

---

*이 문서는 Core Localization의 포괄적인 테스트 전략을 제공합니다.*
*95% 이상의 테스트 커버리지로 안정적인 다국어 지원을 보장합니다.*