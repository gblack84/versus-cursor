# 📦 App DI (Dependency Injection) 레이어

> Feature-First Architecture의 의존성 주입 시스템  
> 최종 업데이트: 2025-08-27 | 버전: 1.0.0

## 📋 개요

DI 레이어는 Versus Space 애플리케이션의 전체 의존성 관리를 담당합니다.
GetIt 서비스 로케이터 패턴을 사용하여 Feature-First Architecture에 맞는 의존성 주입을 구현합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/app/di/
├── README.md              # 현재 문서 (계획 단계)
└── (구현 예정 파일들)
    ├── injection.dart     # DI 초기화 및 설정
    ├── injection.config.dart  # 자동 생성 설정 (injectable)
    └── modules/          # 모듈별 의존성 정의
        ├── app_module.dart
        ├── firebase_module.dart  
        ├── cache_module.dart
        └── feature_modules.dart
```

## 🔍 현재 상태 분석

### 현재 상황
- ❌ DI 시스템 미구현 상태
- ❌ 의존성이 직접 import로 관리됨
- ❌ 테스트 시 Mock 주입 어려움
- ❌ 싱글톤 패턴이 각 서비스마다 개별 구현

### Feature-First Architecture에서 DI의 역할
- ✅ Feature 간 의존성 관리
- ✅ 전역 서비스의 일관된 접근
- ✅ 테스트 가능한 코드 구조
- ✅ 의존성 그래프 명확화

## 🛠️ 구현 계획

### Phase 1: 기본 DI 설정 (1주)

#### 1. GetIt 및 Injectable 패키지 설정
```yaml
# pubspec.yaml
dependencies:
  get_it: ^7.6.0
  injectable: ^2.3.2
  
dev_dependencies:
  injectable_generator: ^2.4.1
  build_runner: ^2.4.6
```

#### 2. injection.dart - DI 컨테이너 초기화
```dart
// lib/app/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies({
  String? environment,
}) async {
  await getIt.init(environment: environment);
}

// 환경 정의
abstract class Environment {
  static const dev = 'dev';
  static const prod = 'prod';
  static const test = 'test';
}
```

### Phase 2: 모듈 정의 (3일)

#### 1. Firebase 모듈
```dart
// lib/app/di/modules/firebase_module.dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get auth => FirebaseAuth.instance;
  
  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  
  @lazySingleton
  FirebaseStorage get storage => FirebaseStorage.instance;
}
```

#### 2. 캐시 모듈
```dart
// lib/app/di/modules/cache_module.dart
@module
abstract class CacheModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
  
  @lazySingleton
  UnifiedCacheService cacheService() => UnifiedCacheService();
  
  @singleton
  SimpleMemoryCache memoryCache() => SimpleMemoryCache(maxSize: 100);
}
```

#### 3. Feature 모듈 통합
```dart
// lib/app/di/modules/feature_modules.dart
@module
abstract class FeatureModules {
  // Auth Feature
  @lazySingleton
  AuthRepository authRepository(FirebaseAuth auth) => 
    AuthRepositoryImpl(auth);
    
  @lazySingleton
  AuthService authService(AuthRepository repo) => 
    AuthService(repo);
  
  // Posts Feature  
  @factory
  PostsRepository postsRepository(FirebaseFirestore firestore) =>
    PostsRepositoryImpl(firestore);
    
  // Chat Feature
  @factory
  ChatService chatService(
    FirebaseFirestore firestore,
    UnifiedCacheService cache,
  ) => ChatService(firestore, cache);
}
```

### Phase 3: Feature 통합 (1주)

#### 각 Feature에서 DI 사용
```dart
// lib/features/auth/presentation/screens/login_screen.dart
class LoginScreen extends StatelessWidget {
  final authService = getIt<AuthService>();
  
  @override
  Widget build(BuildContext context) {
    // authService 사용
  }
}
```

#### Provider와 통합
```dart
// lib/features/posts/presentation/providers/posts_provider.dart
class PostsProvider extends ChangeNotifier {
  final PostsRepository _repository;
  
  PostsProvider() : _repository = getIt<PostsRepository>();
  
  // 또는 생성자 주입
  PostsProvider(this._repository);
}
```

### Phase 4: 테스트 설정 (3일)

#### Mock 설정
```dart
// test/helpers/test_injection.dart
@module
abstract class TestModule {
  @test
  @lazySingleton
  AuthService mockAuthService() => MockAuthService();
  
  @test
  @lazySingleton
  PostsRepository mockPostsRepository() => MockPostsRepository();
}

void setupTestDependencies() {
  configureDependencies(environment: Environment.test);
}
```

## 🎯 마이그레이션 전략

### 1단계: 전역 서비스 마이그레이션
| 서비스 | 현재 위치 | DI 등록 타입 | 우선순위 |
|--------|----------|-------------|----------|
| UnifiedCacheService | /services/cache | @lazySingleton | 높음 |
| AuthUtil | /features/auth/data/services | @lazySingleton | 높음 |
| NotificationService | /features/notifications | @lazySingleton | 중간 |
| VoteStateCoordinator | /services | @lazySingleton | 중간 |

### 2단계: Repository 패턴 도입
```dart
// 현재: 직접 Firestore 접근
FirebaseFirestore.instance
  .collection('posts')
  .doc(postId)
  .get();

// 개선: Repository 통한 접근
final postsRepo = getIt<PostsRepository>();
postsRepo.getPost(postId);
```

### 3단계: Feature 별 점진적 적용
1. Auth Feature - 인증 관련 서비스
2. Posts Feature - 게시물 관련 서비스
3. Chat Feature - 채팅 서비스
4. 나머지 Feature 순차 적용

## 📊 구현 우선순위

### Critical (즉시 구현)
- [ ] GetIt 기본 설정
- [ ] Firebase 서비스 등록
- [ ] 캐시 서비스 등록

### High (1주 내)
- [ ] Auth 관련 서비스
- [ ] AppState DI 통합
- [ ] 테스트 Mock 설정

### Medium (2주 내)
- [ ] 모든 Repository 등록
- [ ] Feature 서비스 통합
- [ ] Provider 생성자 주입

### Low (추후)
- [ ] 자동 생성 코드 최적화
- [ ] 순환 의존성 검증 도구
- [ ] DI 그래프 시각화

## 📝 사용 가이드

### 서비스 등록하기
```dart
@injectable
class MyService {
  // 자동으로 DI에 등록됨
}

// 또는 수동 등록
getIt.registerSingleton<MyService>(MyService());
```

### 서비스 사용하기
```dart
// 직접 접근
final myService = getIt<MyService>();

// Widget에서 사용
class MyWidget extends StatelessWidget {
  final service = getIt<MyService>();
}

// Provider에서 사용  
class MyProvider extends ChangeNotifier {
  final MyService _service;
  
  MyProvider() : _service = getIt<MyService>();
}
```

### 테스트에서 Mock 사용
```dart
setUp(() {
  getIt.registerSingleton<MyService>(MockMyService());
});

tearDown(() {
  getIt.reset();
});
```

## ⚠️ 주의사항

1. **순환 의존성**: 서비스 간 순환 참조 주의
2. **메모리 관리**: Singleton은 앱 종료까지 유지
3. **초기화 순서**: 의존 관계에 따른 등록 순서
4. **테스트 격리**: 테스트마다 DI 초기화

## 📚 참고 자료

- [GetIt Documentation](https://pub.dev/packages/get_it)
- [Injectable Documentation](https://pub.dev/packages/injectable)
- [Feature-First Architecture Guide](/FEATURE_ARCHITECTURE.md)

---

*이 문서는 DI 레이어의 구현 계획과 가이드를 담고 있습니다.*
*실제 구현은 Phase별로 진행 예정입니다.*