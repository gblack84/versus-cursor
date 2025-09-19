# 🏗️ Clean Architecture 규칙 문서 v2.0

> **최종 업데이트**: 2025-01-09  
> **상태**: 🔴 엄격 적용 중  
> **위치**: `/lib/ARCHITECTURE_RULES.md`  
> **목적**: 아키텍처 일관성 유지 및 의존성 규칙 강제

---

## 📌 핵심 원칙 (MUST FOLLOW)

### 🎯 절대 규칙
1. **Core에 구현체 금지** - 인터페이스와 유틸리티만
2. **Feature 간 의존 금지** - 각 Feature는 완전 독립
3. **역방향 의존 금지** - 내부에서 외부로만 의존
4. **상태는 Presentation만** - Core/Data에 상태관리 금지

---

## 🏛️ 3계층 아키텍처 구조

```
lib/
├── app/          # 🚀 앱 조립 및 구현체
├── core/         # 📜 인터페이스 및 유틸리티 (구현 금지!)
└── features/     # 📦 독립 기능 모듈
```

---

## 1️⃣ App Layer 규칙

### ✅ DO (해야 할 것)

```dart
lib/app/
├── main.dart                    # 앱 진입점
├── app.dart                     # MaterialApp 설정
├── router/                      # 라우팅
│   └── app_router.dart         
├── services/                    # 🔴 모든 구현체는 여기!
│   ├── cache_service_impl.dart # ICacheService 구현
│   ├── logger_service_impl.dart # ILoggerService 구현
│   ├── network_service_impl.dart # INetworkService 구현
│   ├── storage_service_impl.dart # IStorageService 구현
│   └── firebase_service_impl.dart # IFirebaseService 구현
├── di/                          # 의존성 주입
│   ├── injection.dart          # GetIt 초기화
│   ├── core_module.dart        # Core 인터페이스 바인딩
│   └── feature_modules.dart    # Feature 모듈 바인딩
└── navigation/                  # 네비게이션
    └── navigation_shell.dart
```

#### App Services 구현 예시
```dart
// ✅ GOOD: app/services/cache_service_impl.dart
import 'package:versus_space/core/interfaces/i_cache_service.dart';

class CacheServiceImpl implements ICacheService {
  @override
  Future<T?> get<T>(String key) async {
    // 실제 구현
  }
}

// app/di/core_module.dart
GetIt.I.registerLazySingleton<ICacheService>(
  () => CacheServiceImpl(),
);
```

### ❌ DON'T (하지 말아야 할 것)

```dart
// ❌ BAD: App이 Feature의 구현체 직접 import
import 'package:versus_space/features/auth/data/repositories/auth_repository_impl.dart';

// ❌ BAD: App이 Feature의 domain 외 다른 레이어 접근
import 'package:versus_space/features/posts/data/datasources/post_api.dart';
```

---

## 2️⃣ Core Layer 규칙

### ✅ DO (해야 할 것)

```dart
lib/core/
├── interfaces/                  # 🔴 인터페이스만!
│   ├── services/               # 서비스 인터페이스
│   │   ├── i_cache_service.dart
│   │   ├── i_logger_service.dart
│   │   ├── i_network_service.dart
│   │   ├── i_storage_service.dart
│   │   └── i_firebase_service.dart
│   └── common/                 # 공용 추상화
│       ├── result.dart        # Result<T> 타입
│       └── use_case.dart      # UseCase<I,O> 제네릭
├── utils/                      # 순수 유틸리티
│   ├── constants.dart
│   ├── extensions.dart
│   └── validators.dart
├── theme/                      # 디자인 시스템
│   ├── colors.dart
│   ├── typography.dart
│   └── spacing.dart
└── widgets/                    # 🔴 비즈니스 무관 위젯만!
    ├── loading_widget.dart     # 단순 로딩
    └── error_widget.dart       # 단순 에러
```

#### Core Interface 예시
```dart
// ✅ GOOD: core/interfaces/services/i_cache_service.dart
abstract class ICacheService {
  Future<T?> get<T>(String key);
  Future<void> set<T>(String key, T value);
  Future<void> delete(String key);
  Future<void> clear();
}

// ✅ GOOD: core/interfaces/common/result.dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends Result<T> {
  final String message;
  const Failure(this.message);
}
```

### ❌ DON'T (하지 말아야 할 것)

```dart
// ❌ BAD: Core에 구현체
class CacheService implements ICacheService {
  // 구현 코드... NO!
}

// ❌ BAD: Core가 Feature 의존
import 'package:versus_space/features/auth/domain/models/user.dart';

// ❌ BAD: Core에 Repository 구현
class BaseRepository {
  final FirebaseFirestore firestore; // NO!
}

// ❌ BAD: Core 위젯에 상태관리
class CoreWidget extends StatefulWidget {
  final AuthProvider authProvider; // NO!
}
```

---

## 3️⃣ Features Layer 규칙

### ✅ DO (해야 할 것)

```dart
lib/features/auth/
├── domain/                     # 비즈니스 로직
│   ├── models/                # 도메인 모델
│   │   └── user.dart
│   ├── repositories/          # 🔴 Repository 인터페이스는 여기!
│   │   └── i_auth_repository.dart
│   └── use_cases/
│       └── sign_in_use_case.dart
├── data/                       # 데이터 레이어
│   ├── repositories/          # Repository 구현
│   │   └── auth_repository_impl.dart
│   ├── datasources/           # 외부 데이터 소스
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_local_datasource.dart
│   └── adapters/              # 🔴 services 대신 adapters 사용!
│       ├── firebase_auth_adapter.dart
│       └── token_storage_adapter.dart
└── presentation/              # UI 레이어
    ├── screens/
    ├── widgets/
    └── providers/             # 🔴 상태관리는 여기만!
```

#### Feature 구현 예시
```dart
// ✅ GOOD: domain/repositories/i_auth_repository.dart
abstract class IAuthRepository {
  Future<Result<User>> signIn(String email, String password);
  Future<Result<void>> signOut();
}

// ✅ GOOD: data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
}

// ✅ GOOD: data/adapters/firebase_auth_adapter.dart (services 대신!)
class FirebaseAuthAdapter {
  final IFirebaseService firebaseService; // Core interface 사용
  
  Future<UserCredential> signIn(String email, String password) {
    // Firebase 특화 로직
  }
}
```

### ❌ DON'T (하지 말아야 할 것)

```dart
// ❌ BAD: Feature 간 의존
import 'package:versus_space/features/posts/domain/models/post.dart';

// ❌ BAD: Domain이 Data 의존
// domain/use_cases/sign_in_use_case.dart
import '../data/repositories/auth_repository_impl.dart'; // NO!

// ❌ BAD: Presentation이 Data 직접 접근
// presentation/screens/login_screen.dart
import '../../data/datasources/auth_api.dart'; // NO!

// ❌ BAD: data/services 폴더 사용 (혼동 방지)
lib/features/auth/data/services/ // NO! Use adapters/ or gateways/
```

---

## 🔒 의존성 규칙 매트릭스

| From ↓ \ To → | App | Core | Feature/Domain | Feature/Data | Feature/Presentation |
|----------------|-----|------|----------------|--------------|---------------------|
| **App**        | ✅  | ✅   | ✅            | ❌           | ❌                  |
| **Core**       | ❌  | ✅   | ❌            | ❌           | ❌                  |
| **Feature/Domain** | ❌ | ✅ | ✅            | ❌           | ❌                  |
| **Feature/Data** | ❌ | ✅  | ✅            | ✅           | ❌                  |
| **Feature/Presentation** | ❌ | ✅ | ✅     | ❌           | ✅                  |

### 의존성 방향 시각화
```
App Layer
  ↓ (DI로 조립)
Features Layer ← (인터페이스 사용) → Core Layer (인터페이스만)
  ↓                                      ↑
(독립)                                (독립)
```

---

## 🛡️ Lint 규칙 설정 (analysis_options.yaml)

```yaml
analyzer:
  errors:
    # 의존성 위반을 에러로 처리
    invalid_use_of_visible_for_testing_member: error
    depend_on_referenced_packages: error
    
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    
  plugins:
    - custom_lint

custom_lint:
  rules:
    # Core → Features 금지
    - avoid_imports:
        from: "lib/core/**"
        to: "lib/features/**"
        severity: error
        
    # Features 간 의존 금지
    - avoid_imports:
        from: "lib/features/*/[!domain]/**"
        to: "lib/features/[!$1]/**"
        severity: error
        
    # App → Data/Presentation 직접 접근 금지
    - avoid_imports:
        from: "lib/app/**"
        to: "lib/features/*/data/**"
        severity: error
        
    - avoid_imports:
        from: "lib/app/**"
        to: "lib/features/*/presentation/**"
        severity: error
        
    # Domain → Data/Presentation 금지
    - avoid_imports:
        from: "lib/features/*/domain/**"
        to: "lib/features/*/data/**"
        severity: error
        
    - avoid_imports:
        from: "lib/features/*/domain/**"
        to: "lib/features/*/presentation/**"
        severity: error
```

---

## ✅ 마이그레이션 체크리스트

### Phase 1: Core 정리
- [ ] `/lib/core/repositories/` 완전 삭제
- [ ] `/lib/core/services/` → `/lib/core/interfaces/services/`로 이동 (인터페이스만)
- [ ] 모든 구현체를 `/lib/app/services/`로 이동
- [ ] Core의 Feature 의존성 모두 제거

### Phase 2: Services 재배치
- [ ] `/lib/services/cache/` → `/lib/app/services/cache_service_impl.dart`
- [ ] `/lib/services/logger/` → `/lib/app/services/logger_service_impl.dart`
- [ ] `/lib/services/api/` → 각 Feature의 `data/adapters/`로 분산
- [ ] `/lib/services/` 디렉토리 완전 삭제

### Phase 3: Features 정리
- [ ] 모든 `data/services/` → `data/adapters/` 또는 `data/gateways/`로 변경
- [ ] Domain 레이어의 Repository 인터페이스 정의
- [ ] Presentation의 Data 직접 접근 제거
- [ ] Feature 간 의존성 제거

### Phase 4: DI 재구성
- [ ] App/di에서 모든 인터페이스-구현체 바인딩
- [ ] Feature 모듈별 DI 설정
- [ ] Firebase 초기화를 App에서 수행

### Phase 5: 검증
- [ ] `flutter analyze` 0 에러
- [ ] 의존성 규칙 위반 0개
- [ ] 모든 테스트 통과
- [ ] 빌드 성공

---

## 🚨 위반 시 조치사항

1. **즉시 수정**: 의존성 규칙 위반은 PR 머지 불가
2. **코드 리뷰**: 아키텍처 위반 시 리뷰어가 거부
3. **CI/CD**: 린트 규칙 위반 시 빌드 실패
4. **문서화**: 예외사항은 반드시 문서화 및 승인 필요

---

## 📚 참고 자료

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Feature-First Architecture](https://codewithandrea.com/articles/flutter-project-structure/)

---

**이 문서는 프로젝트의 아키텍처 일관성을 위한 절대 규칙입니다.**  
**모든 개발자는 이 규칙을 엄격히 준수해야 합니다.**