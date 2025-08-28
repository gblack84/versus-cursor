# 🧪 DI 레이어 테스트 가이드

> Dependency Injection 시스템 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 예상 커버리지: 95%

## 📋 테스트 범위

### 1. 테스트 대상
- **Injection 클래스**: GetIt 초기화 및 등록
- **모듈별 DI 설정**: Firebase, Services, Repositories
- **의존성 그래프**: 순환 의존성 검증
- **Mock 주입**: 테스트용 Mock 객체 교체

### 2. 테스트 제외 대상
- GetIt 패키지 자체 (이미 테스트됨)
- Firebase SDK 내부 (외부 라이브러리)

## 🎯 테스트 전략

### Phase 1: 단위 테스트 (Week 1, Day 2-3)

#### 1.1 DI 컨테이너 테스트
```dart
// test/unit/app/di/injection_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:versus_space/app/di/injection.dart';

@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  FirebaseStorage,
])
void main() {
  late GetIt getIt;
  
  setUp(() {
    getIt = GetIt.instance;
    getIt.reset(); // 각 테스트마다 초기화
  });
  
  tearDown(() {
    getIt.reset();
  });
  
  group('Injection 초기화 테스트', () {
    test('init()이 성공적으로 완료되어야 함', () async {
      // Given
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = MockFirebaseFirestore();
      
      // When
      await Injection.init(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
      );
      
      // Then
      expect(getIt.isRegistered<FirebaseAuth>(), isTrue);
      expect(getIt.isRegistered<FirebaseFirestore>(), isTrue);
    });
    
    test('중복 초기화 시 에러가 발생해야 함', () async {
      // Given
      await Injection.init();
      
      // When & Then
      expect(
        () => Injection.init(),
        throwsA(isA<StateError>()),
      );
    });
  });
  
  group('의존성 등록 테스트', () {
    test('모든 필수 서비스가 등록되어야 함', () async {
      // When
      await Injection.init();
      
      // Then
      expect(getIt.isRegistered<AuthService>(), isTrue);
      expect(getIt.isRegistered<CacheService>(), isTrue);
      expect(getIt.isRegistered<NotificationService>(), isTrue);
      expect(getIt.isRegistered<ValidationService>(), isTrue);
    });
    
    test('Repository 인터페이스가 구현체와 매핑되어야 함', () async {
      // When
      await Injection.init();
      
      // Then
      final authRepo = getIt<AuthRepository>();
      expect(authRepo, isA<AuthRepositoryImpl>());
      
      final postsRepo = getIt<PostsRepository>();
      expect(postsRepo, isA<PostsRepositoryImpl>());
    });
  });
}
```

#### 1.2 모듈별 DI 테스트
```dart
// test/unit/app/di/modules/firebase_module_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/app/di/modules/firebase_module.dart';

void main() {
  group('FirebaseModule 테스트', () {
    test('Firebase 서비스들이 싱글톤으로 등록되어야 함', () {
      // When
      final getIt = GetIt.instance;
      FirebaseModule.register(getIt);
      
      // Then
      final auth1 = getIt<FirebaseAuth>();
      final auth2 = getIt<FirebaseAuth>();
      expect(identical(auth1, auth2), isTrue);
      
      final firestore1 = getIt<FirebaseFirestore>();
      final firestore2 = getIt<FirebaseFirestore>();
      expect(identical(firestore1, firestore2), isTrue);
    });
    
    test('Firebase Functions가 lazy singleton으로 등록되어야 함', () {
      // When
      final getIt = GetIt.instance;
      FirebaseModule.register(getIt);
      
      // Then
      expect(getIt.isRegistered<FirebaseFunctions>(), isTrue);
      // Functions는 처음 사용될 때 생성됨
      expect(getIt.isReadySync<FirebaseFunctions>(), isFalse);
    });
  });
}
```

### Phase 2: 통합 테스트 (Week 1, Day 4-5)

#### 2.1 의존성 그래프 테스트
```dart
// test/integration/app/di/dependency_graph_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/di/injection.dart';

void main() {
  group('의존성 그래프 무결성 테스트', () {
    test('순환 의존성이 없어야 함', () async {
      // When
      await Injection.init();
      
      // Then - 순환 의존성이 있으면 초기화 중 에러 발생
      final authService = getIt<AuthService>();
      final userRepo = getIt<UserRepository>();
      
      expect(authService, isNotNull);
      expect(userRepo, isNotNull);
    });
    
    test('모든 의존성이 올바른 순서로 해결되어야 함', () async {
      // Given
      final resolveOrder = <String>[];
      
      // Mock으로 순서 추적
      getIt.registerSingleton<FirebaseAuth>(
        MockFirebaseAuth(),
        signalsReady: true,
      );
      resolveOrder.add('FirebaseAuth');
      
      getIt.registerFactory<AuthRepository>(
        () {
          resolveOrder.add('AuthRepository');
          return AuthRepositoryImpl(getIt());
        },
      );
      
      getIt.registerFactory<AuthService>(
        () {
          resolveOrder.add('AuthService');
          return AuthService(getIt());
        },
      );
      
      // When
      final authService = getIt<AuthService>();
      
      // Then
      expect(resolveOrder, equals([
        'FirebaseAuth',
        'AuthRepository', 
        'AuthService',
      ]));
    });
  });
}
```

#### 2.2 Mock 교체 테스트
```dart
// test/integration/app/di/mock_injection_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('테스트용 Mock 주입', () {
    test('프로덕션 의존성을 Mock으로 교체할 수 있어야 함', () async {
      // Given
      await Injection.init(testMode: true);
      
      // When
      final mockAuth = MockFirebaseAuth();
      getIt.unregister<FirebaseAuth>();
      getIt.registerSingleton<FirebaseAuth>(mockAuth);
      
      // Then
      final authService = getIt<AuthService>();
      final injectedAuth = getIt<FirebaseAuth>();
      
      expect(injectedAuth, equals(mockAuth));
      expect(authService.auth, equals(mockAuth));
    });
    
    test('Feature별 Mock 교체가 가능해야 함', () async {
      // Given
      await Injection.init();
      
      // When - Posts Feature만 Mock으로
      final mockPostsRepo = MockPostsRepository();
      getIt.unregister<PostsRepository>();
      getIt.registerFactory<PostsRepository>(() => mockPostsRepo);
      
      // Then
      final postsRepo = getIt<PostsRepository>();
      expect(postsRepo, equals(mockPostsRepo));
      
      // 다른 Feature는 영향받지 않음
      final authRepo = getIt<AuthRepository>();
      expect(authRepo, isA<AuthRepositoryImpl>());
    });
  });
}
```

### Phase 3: 성능 테스트 (Week 1, Day 5)

```dart
// test/performance/app/di/injection_performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class InjectionBenchmark extends BenchmarkBase {
  const InjectionBenchmark() : super('Injection');
  
  @override
  void run() {
    getIt<AuthService>();
    getIt<PostsRepository>();
    getIt<NotificationService>();
  }
  
  @override
  void setup() {
    Injection.init();
  }
  
  @override
  void teardown() {
    getIt.reset();
  }
}

void main() {
  test('DI 해결 속도가 1ms 이하여야 함', () {
    final stopwatch = Stopwatch()..start();
    
    Injection.init();
    getIt<AuthService>();
    getIt<PostsRepository>();
    
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(1));
  });
  
  test('1000번 의존성 해결이 10ms 이하여야 함', () {
    Injection.init();
    
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      getIt<AuthService>();
    }
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(10));
  });
}
```

## 📝 테스트 작성 가이드라인

### 1. 명명 규칙
```dart
// ✅ Good
test('init()이 성공적으로 완료되어야 함', () {});
test('중복 초기화 시 StateError가 발생해야 함', () {});

// ❌ Bad  
test('test init', () {});
test('should work', () {});
```

### 2. AAA 패턴 준수
```dart
test('의존성이 올바르게 등록되어야 함', () {
  // Arrange (Given)
  final mockAuth = MockFirebaseAuth();
  
  // Act (When)
  Injection.init(firebaseAuth: mockAuth);
  
  // Assert (Then)
  expect(getIt.isRegistered<FirebaseAuth>(), isTrue);
});
```

### 3. 격리 보장
```dart
setUp(() {
  getIt.reset(); // 각 테스트 전 초기화
});

tearDown(() {
  getIt.reset(); // 각 테스트 후 정리
});
```

## 🔧 테스트 도구 설정

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  get_it: ^7.6.0
  injectable_generator: ^2.4.0
  benchmark_harness: ^2.2.2
```

### Mock 생성
```bash
# Mock 클래스 자동 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📊 커버리지 목표

| 구분 | 목표 커버리지 | 우선순위 |
|-----|------------|---------|
| Injection 클래스 | 100% | Critical |
| 모듈 등록 | 95% | High |
| 의존성 그래프 | 90% | High |
| Mock 교체 | 85% | Medium |
| 에러 처리 | 90% | High |

## ✅ 체크리스트

### 작성 전
- [ ] GetIt.reset() 호출 확인
- [ ] Mock 클래스 생성
- [ ] 테스트 디렉토리 구조 생성

### 작성 중
- [ ] AAA 패턴 적용
- [ ] 격리 보장
- [ ] 의미있는 테스트명
- [ ] Edge case 처리

### 작성 후
- [ ] 커버리지 측정
- [ ] 성능 테스트 실행
- [ ] CI/CD 통합

## 🚀 실행 명령어

```bash
# 단위 테스트 실행
flutter test test/unit/app/di/

# 통합 테스트 실행  
flutter test test/integration/app/di/

# 커버리지 측정
flutter test --coverage test/app/di/
genhtml coverage/lcov.info -o coverage/html

# 특정 테스트만 실행
flutter test test/unit/app/di/injection_test.dart
```

## 📚 참고 자료

- [GetIt 공식 문서](https://pub.dev/packages/get_it)
- [Mockito 사용법](https://pub.dev/packages/mockito)
- [Flutter 테스트 가이드](https://flutter.dev/docs/testing)
- [의존성 주입 테스트 패턴](https://martinfowler.com/articles/injection.html)

---

*이 문서는 DI 시스템의 테스트 전략과 구현 방법을 담고 있습니다.*