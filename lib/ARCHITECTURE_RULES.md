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

## 🔄 마이그레이션 원칙 (MIGRATION PRINCIPLES)

> **핵심 철학: "개선이지 재창조가 아니다 (Enhance, Don't Recreate)"**

### 📌 기존 코드 보존 원칙

1. **파일명 불변 원칙** - 기존 파일명 절대 변경 금지 (import 보호)
2. **Import 최소 영향** - 다른 파일의 import가 깨지지 않도록 유지
3. **점진적 개선** - 한 번에 모든 것을 바꾸지 않고 단계적 개선
4. **작동 우선** - 현재 작동하는 기능과 데이터 흐름 보존

### ✅ 마이그레이션 DO (해야 할 것)

```dart
// ✅ GOOD: 기존 파일 내부 로직만 개선
// firebase_auth_adapter.dart (이름 유지!)
class FirebaseAuthAdapter {
  // 기존 메서드 유지
  Future<User?> signIn(String email, String password) {
    // 내부 로직만 정리
  }

  // 새로운 패턴을 선택적으로 추가
  Future<Result<User>> signInWithResult(String email, String password) {
    // Clean Architecture 버전 (점진적 마이그레이션)
  }
}

// ✅ GOOD: 기존 필드와 메서드명 재사용
class AuthRepository {
  // 기존 필드명 그대로 사용
  final FirebaseAuth firebaseAuth;

  // 기존 메서드명 유지하면서 내부 개선
  Future<User?> getCurrentUser() {
    // 로직 개선하되 인터페이스 유지
  }
}
```

### ❌ 마이그레이션 DON'T (하지 말아야 할 것)

```dart
// ❌ BAD: 파일명 변경
firebase_auth_adapter.dart → auth_remote_datasource_impl.dart // NO!

// ❌ BAD: 불필요한 새 파일 생성
// 기존 adapter가 있는데 새로운 datasource 파일 생성 // NO!

// ❌ BAD: 기존 메서드 삭제
class AuthRepository {
  // Future<User?> signIn() { } // 삭제하지 말고
  @deprecated
  Future<User?> signIn() { } // deprecated 처리만

  // 새 메서드 추가는 OK
  Future<Result<User>> signInWithResult() { }
}

// ❌ BAD: Firebase와 1:1 매핑 깨기
// Firebase의 UserCredential을 다른 타입으로 변경 // NO!
```

### 🚨 예외 처리 규칙

1. **파일 분해가 필요한 경우**
   - 반드시 팀 동의 필요
   - 분해 계획 문서화
   - 기존 파일은 Facade로 유지 (호환성)

2. **새 파일 생성이 필요한 경우**
   - 최소한으로 제한
   - 정당한 이유 문서화
   - 기존 구조를 보완하는 용도만

3. **이름 변경이 불가피한 경우**
   - 별칭(alias) 제공으로 호환성 유지
   - export 파일로 리다이렉션
   - deprecated 경고와 함께 이전 기간 제공

### 📋 마이그레이션 실행 가이드

```dart
// Step 1: 기존 코드 분석 (변경하지 않음)
class CurrentAuthService {
  // 현재 작동하는 코드 파악
}

// Step 2: 래퍼 추가 (기존 코드 유지)
class AuthUseCase {
  final CurrentAuthService _service; // 기존 서비스 재사용

  Future<Result<User>> execute() {
    // 기존 서비스 호출하며 Clean Architecture 패턴 적용
    return _service.signIn().toResult();
  }
}

// Step 3: 점진적 전환
// 새 코드는 UseCase 사용
// 기존 코드는 그대로 유지
// 시간이 지나며 천천히 마이그레이션
```

### 🔍 예외 문서화 원칙
- 모든 예외는 명시적으로 문서화되어야 함
- 예외별 제거 타임라인 설정 필수
- 예외 사용 시 `@deprecated` 또는 `// TODO(migration):` 주석 추가
- 분기별 예외 현황 검토 및 업데이트

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

## 🚦 예외 규칙 (Migration & Special Cases)

### 조립 경계 예외 (Assembly Boundaries)
- **라우팅 조립**: App/router는 Feature/Presentation 위젯을 import 가능 (라우팅 목적만)
  ```dart
  // ✅ OK: app/router/app_router.dart
  import '/features/auth/presentation/screens/login_screen.dart'; // 라우팅 조립용
  ```
- **DI 조립**: App/di는 Feature/Data 구현체를 import 가능 (포트-구현 바인딩만)
  ```dart
  // ✅ OK: app/di/auth_module.dart
  import '/features/auth/data/repositories/auth_repository_impl.dart'; // DI 바인딩용
  ```
- **대안**: Router 플러그인 패턴으로 Feature가 자체 라우트 등록

### 마이그레이션 중 예외 (Migration Exceptions)
- **FirestoreRecord in Domain**:
  - 현재 Profile domain 모델들이 사용 중
  - 직접 상속 유지하며 의존 메서드만 점진적으로 자체 구현으로 교체
  - 충분히 독립적이 되면 extends 제거
  - 새로운 모델은 처음부터 FirestoreRecord 없이 작성
  - 타임라인: 6개월 내 완전 제거 목표

- **data/services 레거시**:
  - 기존 service/manager/util 파일명은 유지 (rename 금지)
  - Repository/DataSource의 내부 헬퍼로만 사용
  - 외부 노출 금지 (특히 Presentation/Domain)

### 테스트 코드 예외 (Test Exceptions)
- `test/**` 디렉토리의 모든 파일은 import 제약에서 제외
- 단위 테스트: 구체 클래스 직접 접근 허용 (Mock/Spy용)
- 통합 테스트: Firebase 에뮬레이터 접근 허용
- E2E 테스트: 모든 레이어 접근 가능
- **주의**: 앱 코드 (`lib/**`)에서는 여전히 모든 규칙 적용

### 생성 코드 예외 (Generated Code)
- *.g.dart, *.freezed.dart 파일의 프레임워크 의존 허용
- build_runner 생성 코드는 린트 규칙 제외

---

## 🔒 의존성 규칙 매트릭스

| From ↓ \ To → | App | Core | Feature/Domain | Feature/Data | Feature/Presentation |
|----------------|-----|------|----------------|--------------|---------------------|
| **App**        | ✅  | ✅   | ✅            | ❌*          | ❌**                |
| **Core**       | ❌  | ✅   | ❌            | ❌           | ❌                  |
| **Feature/Domain** | ❌ | ✅ | ✅            | ❌           | ❌                  |
| **Feature/Data** | ❌ | ✅  | ✅            | ✅           | ❌                  |
| **Feature/Presentation** | ❌ | ✅ | ✅     | ❌           | ✅                  |

> *App/di만 예외 (DI 조립용)
> **App/router만 예외 (라우팅 조립용)

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

    # App → Data 금지 (DI 제외)
    - avoid_imports:
        from: "lib/app/**"
        to: "lib/features/*/data/**"
        except: "lib/app/di/**"  # DI 조립 예외
        severity: error

    # App → Presentation 금지 (Router 제외)
    - avoid_imports:
        from: "lib/app/**"
        to: "lib/features/*/presentation/**"
        except: "lib/app/router/**"  # 라우팅 조립 예외
        severity: error

    # Presentation에서 Firebase 직접 import 금지
    - avoid_imports:
        from: "lib/features/*/presentation/**"
        to_pattern: "package:firebase_*"
        severity: error

    - avoid_imports:
        from: "lib/features/*/presentation/**"
        to_pattern: "package:cloud_firestore/*"
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

    # Test 디렉토리는 모든 import 허용
    - avoid_imports:
        from: "test/**"
        severity: allow  # 테스트는 제약 없음
```

---

## ✅ 마이그레이션 체크리스트 (개선 중심)

### Phase 1: Features 우선 개선 ⭐
- [ ] **Auth Feature** 먼저 시작 (가장 많은 의존성)
  - [ ] `data/adapters/` → 이름 유지, 내부를 Repository helper로 개선
  - [ ] Domain Repository 인터페이스 추가 (기존 구현체 래핑)
  - [ ] Presentation → Data 직접 접근을 UseCase로 점진적 교체
  - [ ] Feature-level DI module 추가 (`/features/auth/di/`)
- [ ] **Profile Feature** FirestoreRecord 제거
  - [ ] 직접 상속 유지하며 의존 메서드를 자체 구현으로 교체
  - [ ] save(), update() 등 FirestoreRecord 메서드를 override
  - [ ] 충분히 독립적이 되면 extends FirestoreRecord 제거
  - [ ] 새로운 모델은 처음부터 순수 Dart 클래스로 작성
  - [ ] 타임라인: 3개월 내 50%, 6개월 내 100% 제거
- [ ] **다른 Features** 순차 적용
  - [ ] Posts, Profile, Chat, Voting 등 같은 패턴 적용
  - [ ] Feature 간 의존성 deprecated 처리 후 점진적 제거

### Phase 2: App 레이어 정리
- [ ] `/lib/app/di/` → Feature DI 통합 및 GetIt 설정
- [ ] `/lib/app/router/` → 기존 라우팅 유지, 내부 개선
- [ ] `/lib/app/state/` → AppState 유지, Provider 패턴 강화
- [ ] Firebase 초기화 로직은 현재 위치 유지 (동작 보장)

### Phase 3: Core 레이어 정리 (의존성 제거)
- [ ] `/lib/core/repositories/` → deprecated 마킹 (즉시 삭제하지 않음)
- [ ] `/lib/core/interfaces/` → 인터페이스만 남기고 구현체는 Feature로
- [ ] Core의 Feature 의존성 점진적 제거 (별칭 제공)
- [ ] 기존 import 유지하며 내부만 리다이렉션

### Phase 4: Services 레이어 개선 (이동 대신 래핑)
- [ ] `/lib/services/cache/` → 현재 위치 유지, 인터페이스 추가
- [ ] `/lib/services/logger/` → 현재 위치 유지, 추상화 레이어 추가
- [ ] `/lib/services/api/` → 기존 구조 유지, Feature adapter로 점진적 분산
- [ ] 기존 서비스 호출 경로 유지 (호환성)

### Phase 5: 검증 및 안정화
- [ ] 각 Phase 후 기존 기능 100% 동작 확인
- [ ] `flutter analyze` warning 수준 허용
- [ ] Feature별 핵심 경로 테스트
- [ ] 빌드 성공 및 앱 실행 확인
- [ ] 점진적 deprecated 코드 제거 (3-6개월 후)

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